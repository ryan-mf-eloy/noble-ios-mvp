"""
Bulk-scrape PSA-slabbed card photos from Fanatics Collect / Goldin Auctions
and write them into the iOS Asset Catalog as front + back imagesets.

For each card we:
  1. Fetch the lot page HTML
  2. Extract og:image (the slabbed product photo)
  3. Download the JPEG/PNG
  4. Save card_<id>.imageset/card_<id>.png  (the front)
  5. PIL-hflip and save card_<id>_back.imageset/card_<id>_back.png
     (back is pre-flipped to compensate for Three.js BoxGeometry's -Z UV mirror)
  6. Write Contents.json for both imagesets

Run: python3 scripts/scrape_new_cards.py
"""

from __future__ import annotations

import io
import json
import re
import sys
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

from PIL import Image, ImageOps

ASSETS_DIR = Path(__file__).resolve().parent.parent / "NobleApp" / "Assets.xcassets"

UA = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_0) "
    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
)

CARDS = [
    # (asset_id, lot_url)
    (
        "card_kobe_topps_1996",
        "https://www.fanaticscollect.com/buy-now/ca8debf8-b4f5-409a-8063-bbe289f83054/"
        "1996-topps-chrome-kobe-bryant-rookie-138-psa-9-mint",
    ),
    (
        "card_wembanyama_prizm_2023",
        "https://www.fanaticscollect.com/buy-now/09c745a8-5090-499b-8e83-3e21c06c54c2/"
        "2023-panini-prizm-silver-victor-wembanyama-rookie-136-psa-10-gem-mint",
    ),
    (
        "card_lebron_exquisite_2003",
        "https://goldin.co/item/2003-04-upper-deck-exquisite-collection-rookie-patch-autograph-rpa-parobgk8",
    ),
    (
        "card_mantle_topps_1952",
        "https://www.fanaticscollect.com/premier/490e5034-7ef9-11f0-9ed5-0a58a9feac02/"
        "1952-topps-mickey-mantle-311-psa-8-nm-mt",
    ),
    (
        "card_trout_bowman_2009",
        "https://www.fanaticscollect.com/weekly/601ae688-5706-11ee-b671-0adcfec45dd3/"
        "2009-bowman-chrome-refractor-mike-trout-rookie-auto-500-bdpp89-psa-10-gem-mint",
    ),
    (
        "card_blastoise_pokemon_1999",
        "https://www.fanaticscollect.com/fixed/c1917894-6f44-11ef-a33e-0a58a9feac02",
    ),
    (
        # Pikachu Illustrator's lot pages 404 their og:image; sub in the next-most-iconic
        # Pokémon card — yellow-cheeks Pikachu Base Set 1st Ed (closes the starter trio
        # alongside Charizard + Blastoise, which we already have).
        "card_pikachu_base_1999",
        "https://www.fanaticscollect.com/buy-now/dc08f6a2-24b9-4ec0-923e-a08675c524a9/"
        "1999-pokemon-base-set-shadowless-1st-edition-yellow-cheeks-pikachu-58-psa-7-nrmt",
    ),
    (
        "card_blueeyes_yugioh_2002",
        "https://www.fanaticscollect.com/premier/10d3df62-925a-11f0-b24e-0a58a9feac02/"
        "2002-yu-gi-oh-lob-1st-edition-blue-eyes-white-dragon-lob-001-psa-10-gem-mint",
    ),
    (
        "card_darkmagician_yugioh_2002",
        "https://www.fanaticscollect.com/buy-now/d2c7be50-227d-4ac4-8a36-e9a2fc08686b/"
        "2002-yu-gi-oh-legend-of-blue-eyes-1st-edition-dark-magician-lob-005-psa-10-gem-mint",
    ),
    (
        "card_blacklotus_mtg_1993",
        "https://www.fanaticscollect.com/buy-now/04eb503e-8551-4509-bac0-7f974472ef7e/"
        "1993-magic-the-gathering-mtg-alpha-black-lotus-bgs-95-gem-mint",
    ),
    (
        "card_mbappe_prizm_2018",
        "https://www.fanaticscollect.com/fixed/304d858e-6798-11ef-8e4f-0a58a9feac02",
    ),
]


def http_get(url: str, timeout: int = 30) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        return resp.read()


_OG_IMAGE_RE = re.compile(
    r'<meta\s+property=["\']og:image["\']\s+content=["\']([^"\']+)["\']',
    re.IGNORECASE,
)
_JSONLD_RE = re.compile(
    r'<script[^>]*type=["\']application/ld\+json["\'][^>]*>(.*?)</script>',
    re.IGNORECASE | re.DOTALL,
)


def extract_og_image(html: str) -> str | None:
    m = _OG_IMAGE_RE.search(html)
    return m.group(1) if m else None


def extract_product_images(html: str) -> list[str]:
    """
    Fanatics Collect embeds a schema.org Product JSON-LD block with an `image`
    array — `image[0]` is the front, `image[1]` is the back (when shot). This
    is the only place in the static HTML where the back URL is exposed.
    Returns an empty list when no JSON-LD product block is found.
    """
    for m in _JSONLD_RE.finditer(html):
        try:
            data = json.loads(m.group(1).strip())
        except json.JSONDecodeError:
            continue
        if not isinstance(data, dict) or data.get("@type") != "Product":
            continue
        images = data.get("image")
        if isinstance(images, str):
            return [images]
        if isinstance(images, list):
            return [u for u in images if isinstance(u, str)]
    return []


def write_imageset(folder: Path, image: Image.Image) -> None:
    folder.mkdir(parents=True, exist_ok=True)
    name = folder.stem
    image_path = folder / f"{name}.png"
    image.save(image_path, format="PNG", optimize=True)
    contents = {
        "images": [
            {"filename": f"{name}.png", "idiom": "universal", "scale": "1x"}
        ],
        "info": {"author": "xcode", "version": 1},
    }
    (folder / "Contents.json").write_text(json.dumps(contents, indent=2) + "\n")


def fetch_image(url: str) -> Image.Image:
    data = http_get(url, timeout=45)
    img = Image.open(io.BytesIO(data)).convert("RGB")
    img.thumbnail((1200, 1680), Image.Resampling.LANCZOS)
    return img


def process_card(card_id: str, url: str) -> tuple[str, str]:
    try:
        html = http_get(url).decode("utf-8", errors="replace")

        # Prefer JSON-LD `Product.image[]` (has both front + back). Fall back to
        # og:image when missing (some less-trafficked Goldin/Fanatics pages).
        product_images = extract_product_images(html)
        if not product_images:
            og = extract_og_image(html)
            product_images = [og] if og else []

        if not product_images:
            return card_id, "no product images in HTML"

        front = fetch_image(product_images[0])

        real_back: Image.Image | None = None
        if len(product_images) >= 2:
            try:
                real_back = fetch_image(product_images[1])
            except Exception:  # noqa: BLE001 — keep going with mirrored front
                real_back = None

        if real_back is not None:
            # Three.js BoxGeometry's -Z face UV is mirrored. Pre-flipping the
            # source cancels that mirror so the back reads correctly in 3D.
            back = ImageOps.mirror(real_back)
            back_status = "real-back"
        else:
            # Lot was front-only — mirror the front so the 3D viewer doesn't
            # show a black face. Reads as a "double-sided front" only when
            # rotated, which is rare in the demo flow.
            back = ImageOps.mirror(front)
            back_status = "mirrored-front"

        write_imageset(ASSETS_DIR / f"{card_id}.imageset", front)
        write_imageset(ASSETS_DIR / f"{card_id}_back.imageset", back)
        return card_id, f"OK ({front.size[0]}×{front.size[1]}, back={back_status})"
    except Exception as exc:  # noqa: BLE001 — surface every failure
        return card_id, f"FAIL: {exc!s}"


def main() -> int:
    results: list[tuple[str, str]] = []
    with ThreadPoolExecutor(max_workers=6) as pool:
        futures = {pool.submit(process_card, cid, url): cid for cid, url in CARDS}
        for fut in as_completed(futures):
            results.append(fut.result())

    results.sort(key=lambda r: r[0])
    width = max(len(c) for c, _ in results)
    for cid, status in results:
        print(f"{cid.ljust(width)}  {status}")

    fails = [r for r in results if not r[1].startswith("OK")]
    return 0 if not fails else 1


if __name__ == "__main__":
    sys.exit(main())
