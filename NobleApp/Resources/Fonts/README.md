# Fonts

These 4 `.ttf` files are required and **already downloaded** to this directory:

| File | Family name | Use |
|---|---|---|
| `Anton-Regular.ttf` | Anton | `Font.druk(size:)` — Druk Wide substitute (free) |
| `Inter-Variable.ttf` | Inter | `Font.inter(size, weight:)` — UI body (variable, all weights) |
| `Caveat-Variable.ttf` | Caveat | `Font.caveat(size:)` — script accent (variable, used bold) |
| `JetBrainsMono-Bold.ttf` | JetBrains Mono | `Font.mono(size:)` — tabular numerals for stats |

> **Why variable fonts for Inter and Caveat?** Google Fonts migrated these to single-file variable fonts. `Font.weight()` modifier in SwiftUI iOS 17+ correctly selects the weight axis at render time.

## Re-downloading

If files are missing or corrupted, re-run from project root:

```bash
cd NobleApp/Resources/Fonts/
curl -fLso Anton-Regular.ttf https://github.com/google/fonts/raw/main/ofl/anton/Anton-Regular.ttf
curl -fLso Inter-Variable.ttf "https://github.com/google/fonts/raw/main/ofl/inter/Inter%5Bopsz%2Cwght%5D.ttf"
curl -fLso Caveat-Variable.ttf "https://github.com/google/fonts/raw/main/ofl/caveat/Caveat%5Bwght%5D.ttf"
curl -fLso JetBrainsMono-Bold.ttf https://github.com/JetBrains/JetBrainsMono/raw/master/fonts/ttf/JetBrainsMono-Bold.ttf
```

## Verifying registration

After running the app once, open Xcode → Debug Console. SwiftUI silently falls back to system if fonts fail to load. To confirm, add this to `NobleApp.init()`:

```swift
init() {
    UIFont.familyNames.filter { ["Anton", "Inter", "Caveat", "JetBrains Mono"].contains($0) }
        .forEach { print("✓ \($0): \(UIFont.fontNames(forFamilyName: $0))") }
}
```
