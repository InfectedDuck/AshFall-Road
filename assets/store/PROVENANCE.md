# Store asset provenance

Drafts for the Google Play listing, rendered on 8 September 2026. Both are composed entirely from assets already in this repository; no external image, external font, or image-generation model was used for the composition itself. Owner visual approval is still required before upload, and this record should be merged into `docs/ASSET_PROVENANCE.md` once that file is free.

| File | Size | Format | Built from |
|---|---|---|---|
| `icon_512.png` | 512x512 | 24-bit PNG, no alpha | `assets/ui/icon.svg`, unchanged except that the rounded-corner mask was removed. Google Play applies its own corner mask, so the store icon is full-bleed. |
| `feature_graphic_1024x500.png` | 1024x500 | 24-bit PNG, no alpha | `assets/backgrounds/region_1_outskirts.png` (project background, see `docs/ASSET_PROVENANCE.md`), the title lettering "ASHFALL ROAD" and tagline "Walk until the road ends." exactly as the title screen shows them, the D20 mark from `assets/ui/icon.svg`, and the bundled OFL fonts Inter and Literata. Copy states only launch-v1 facts: offline, six regions, one concealed D20, permadeath. No expansion content is shown or named. |

Sources and the render script live in `tools/store/`. Re-render with:

```
powershell -ExecutionPolicy Bypass -File tools/store/render_store_assets.ps1
```

This folder carries a `.gdignore`, so nothing here is imported or exported into the game binary. `tools/release_readiness.gd` reads the files directly and still finds them.

Not produced here: the six real-device screenshots, which need a physical phone.
