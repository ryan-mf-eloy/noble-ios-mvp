"""
Strip the outer matte-black plastic frame from every bundled card photo.

The 3D viewer now models the slab case as a textured matte body, so the
bundled image only needs to show what sits INSIDE the case window: the
PSA/BGS label at top, the card art, and the brand logo at bottom. With the
outer frame removed, the photo plane in the viewer can sit smaller than the
geometry, exposing the case body around it — the "card-inside-case" effect
real PSA slabs have.

Crop ratios are tuned for typical Fanatics Collect / Goldin slab shots: the
plastic case adds ~5-6% of width as outer frame on the left/right and ~3% on
top/bottom. The crop is symmetric horizontally and vertically so the
resulting image still centers around the card.

Run after fresh scrapes (or once for the existing bundle) — re-running on an
already-cropped image will trim it again, so check git status before re-run.
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image

ASSETS_DIR = Path(__file__).resolve().parent.parent / "NobleApp" / "Assets.xcassets"

CROP_LEFT_PCT   = 0.055
CROP_RIGHT_PCT  = 0.055
CROP_TOP_PCT    = 0.030
CROP_BOTTOM_PCT = 0.030


def crop_in_place(path: Path) -> tuple[int, int, int, int]:
    img = Image.open(path)
    w, h = img.size
    L = int(w * CROP_LEFT_PCT)
    R = w - int(w * CROP_RIGHT_PCT)
    T = int(h * CROP_TOP_PCT)
    B = h - int(h * CROP_BOTTOM_PCT)
    cropped = img.crop((L, T, R, B))
    cropped.save(path, optimize=True)
    return w, h, cropped.size[0], cropped.size[1]


def main() -> None:
    items = sorted(p for p in ASSETS_DIR.iterdir() if p.is_dir() and p.name.startswith("card_"))
    width = max(len(p.name) for p in items) if items else 0

    n = 0
    for imageset in items:
        for png in imageset.glob("*.png"):
            ow, oh, nw, nh = crop_in_place(png)
            print(f"{imageset.name.ljust(width)}  {ow}×{oh} → {nw}×{nh}")
            n += 1
    print(f"\nCropped {n} images")


if __name__ == "__main__":
    main()
