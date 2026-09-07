# Blender enemy portrait assets

Created 8 September 2026 with Blender 5.2.1 LTS. Thirteen editable, posed 3D portrait scenes are saved in `art_sources/blender/`; their renders are installed in the game's existing `assets/portraits/enemy_*.png` slots. No gameplay IDs, saves, or combat rules were changed.

Open `art_sources/blender/index.html` to compare all models and their actual game portraits. Open any `enemy_*.blend` in Blender to edit its geometry, camera, materials, and lights. The Warden is a useful starting point: `art_sources/blender/enemy_warden.blend`.

## What these assets are

This is a first pass of stylized, faceted portrait sculptures. Humans are head-and-shoulder busts; the creatures and machines contain the geometry needed for their portrait compositions. They are actual editable meshes, not flat image planes. Each scene has named parts, a root object, one orthographic camera, and the same three-light studio setup. The game uses their pre-rendered PNGs, so Blender and 3D rendering are not required on a player's device.

They are not rigged characters or finished realistic sculpts. Full-body animation, deformation topology, UV texture painting, detailed scars, and subtle facial acting are outside this first pass. The 64-pixel results simplify some prompt details substantially. Treat technical validation and final art approval separately: the files work in the game, while the look remains available for your review and further art direction.

## Briefs and selected variants

The base brief is `docs/ENEMY_PORTRAIT_PROMPTS_V4.md`, revision `enemy-portrait-v4.2`, with faction direction from `docs/ENEMY_DESIGN_BIBLE.md`. Pixel-art descriptions were translated into 3D silhouettes, broad material planes, and deliberately simple geometry.

Two later, specifically selected generation records take precedence for their characters:

- Bog Raiders: `docs/ENEMY_RAIDERS_GENERATION.md` preserves the weathered red-haired unmasked woman and long-black-haired masked man with one non-glowing red eye.
- Crows: `docs/ENEMY_CROWS_GENERATION.md` preserves the stolen brass ring pull instead of the earlier key.

| Scene | Subjects | Authored identifying detail |
| --- | ---: | --- |
| `enemy_bandits.blend` | 4 adults | Copper-haired leader, narrow patterned backpack straps |
| `enemy_toll.blend` | 3 adults | Silver-haired leader and empty clipboard spring clip |
| `enemy_raiders.blend` | 2 adults | Opposing profiles and projecting lashed heron mask |
| `enemy_scavs.blend` | 4 adults | Role tape, forelock, bun, weapons held at rest |
| `enemy_hunters.blend` | 2 adults | Raised five-digit stop signal and wrapped equipment |
| `enemy_cult.blend` | 5 adults | Covered faces, averted gazes, asymmetric solar-film veil |
| `enemy_guard.blend` | 3 adults | Maintained armor and three shield tally strokes |
| `enemy_stalker.blend` | 1 creature | Sealed eye creases, listening mouth, throat folds, five-digit hand |
| `enemy_dogs.blend` | 4 dogs | Different skulls and ears; only the pale sighthound has a collar |
| `enemy_leeches.blend` | 10 parasites | Nine hungry bodies and one pale distended outlier |
| `enemy_crows.blend` | 7 birds | Distinct wing poses and a stolen brass ring pull |
| `enemy_drones.blend` | 5 machines | Utility fork supports the dead alarm disk |
| `enemy_warden.blend` | 1 machine | Reused octagonal road sign, scanner, tracks, rotary cannon |

The six proposed monsters in the narrative plan do not yet have completed portrait briefs and are not part of this thirteen-enemy asset set.

## Files and runtime integration

- `art_sources/blender/enemy_*.blend`: compressed editable scene files.
- `art_sources/blender/renders/`: 256×256 Cycles renders.
- `art_sources/blender/portraits/`: normalized 64×64 portraits using one shared twenty-color palette.
- `assets/portraits/enemy_*.png`: installed runtime copies, loaded through the existing `PortraitArt` class.
- `art_sources/blender/previous_runtime/`: original Stalker, Dogs, and Toll PNGs, retained byte-for-byte.
- `art_sources/blender/installation.json`: original and installed SHA-256 hashes and whether a previous PNG existed.
- `art_sources/blender/manifest.json`: scene inventory, subject counts, mesh counts, sources, and signatures.
- `art_sources/blender/validation.json`: most recent technical portrait audit.
- `art_sources/blender/portrait_review.png`: captured initial game-control review, before the final shared-palette revision. Use `index.html` for current images.

The entire `art_sources` directory is already excluded from Godot import/export through `.gdignore`. Existing high-resolution painted sources and the extra Toll variant were preserved.

## Rebuild or edit

Run from the project root in PowerShell:

```powershell
& 'C:\Users\ASUS\Applications\blender-5.2.1-windows-x64\blender.exe' --background --factory-startup --python tools/blender/build_enemy_portraits.py -- --ids all
```

Use `--ids enemy_warden` or a comma-separated list to rebuild selected scenes. **Generation replaces the generated `.blend` files for those IDs**; save hand-edited versions under a new filename before regenerating. Use Blender's Render Image / Save As to update a render after manual scene edits without rebuilding its geometry.

Prepare and install the renders:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/blender/prepare_enemy_portraits.ps1 -Install
```

The execution-policy flag applies to that one PowerShell process; it does not change the machine's policy. Omit `-Install` to prepare the source-side PNGs only. The installer saves original PNGs on the first installation and refuses to silently replace runtime portraits edited after its last installation.

The normalization script `tools/blender/normalize_portrait.gd` reserves all twenty palette colors across the set. This retains small colored details that per-image histogram quantization discarded during review. It uses nearest-neighbor downsampling, opaque output, and the flat `#20272B` background.

Import and audit:

```powershell
& 'C:\Users\ASUS\Applications\Godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe' --headless --editor --path . --quit
& 'C:\Users\ASUS\Applications\Godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --script res://tools/blender/review_enemy_portraits.gd
```

The audit checks all thirteen actual loader results, 64×64 dimensions, opaque pixels, a maximum of twenty colors, and the exact four background corners. Run the second command without `--headless` to regenerate the labelled board using the actual game portrait controls. It does not enter a game run or touch saves.

To restore a previous portrait, copy its preserved PNG from `previous_runtime` back to its matching runtime path and reimport. Do not erase that backup. For newly filled slots, the installation receipt records that no previous PNG existed. Review any newer runtime edits before changing them.

## Review status

All scenes were built and rendered successfully. The runtime importer and thirteen-portrait technical audit passed; the initial board was also captured through actual `PortraitArt` controls at enlarged, 64-pixel, and 50-pixel sizes. That review prompted the shared-palette correction and clearer drone carrying fork. User art approval remains pending. Desktop control was stopped with Escape before a generated scene was opened interactively in Blender; the saved scenes and renders remain available.
