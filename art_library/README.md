# Ashfall Road — Art Library

Every image asset in the project, collected in one place, plus the documents that specify them.

`.gdignore` keeps Godot from importing this directory. It is a handoff and review folder, **not** a runtime source. The game still loads from `assets/`; these are copies. If you change art, change it in `assets/` (or `art_sources/`) and re-copy here.

## Contents

| Folder | What's in it | Runtime home |
| --- | --- | --- |
| `portraits_enemies/` | Approved 64×64 adversary sprites | `assets/portraits/` |
| `portraits_survivors/` | Approved 64×64 survivor sprites | `assets/portraits/` |
| `backgrounds/` | Seven vertical region scenes | `assets/backgrounds/` |
| `ui/` | App/UI vector icon | `assets/ui/` |
| `sources_hires/` | High-resolution production sources (1024–1254 px) | `art_sources/portraits/` |
| `prompts/` | Specification documents (mirrors of `docs/`) | `docs/` |

## Portrait roster status

Thirteen adversaries and four survivors are specified. Delivered so far:

**Enemies — 5 of 13**

| Portrait | Sprite | Hi-res source | Status |
| --- | --- | --- | --- |
| `enemy_dogs` | yes | yes | Final visual approval pending |
| `enemy_stalker` | yes | yes | Approved to proceed |
| `enemy_toll` | yes | yes | Final visual approval pending |
| `enemy_toll_v2` | yes | yes | Alternate pass |
| `enemy_leeches` | yes | yes | Final visual approval pending |

**Missing enemy portraits — 9**

`enemy_crows`, `enemy_bandits`, `enemy_warden`, `enemy_raiders`, `enemy_scavs`, `enemy_drones`, `enemy_hunters`, `enemy_cult`, `enemy_guard`

Listed in production order. `prompts/ENEMY_PORTRAIT_PROMPTS_V4.md` now contains complete v4.2 prompts for all thirteen enemies, including these ten missing portraits and regeneration briefs for the three existing IDs.

**Survivors — 4 of 4** (`survivor_4` is still a vector placeholder; a future `survivor_4.png` takes priority automatically without changing the ID.)

**Not yet started:** the 48 item icons and the HUD symbol set in `prompts/UI_ASSET_MANIFEST.md`. These are currently code-drawn at runtime by `scripts/ui/item_icon.gd`.

## Which document to read

| Document | Use it for |
| --- | --- |
| `ENEMY_DESIGN_BIBLE.md` | **Who each enemy is.** Design thesis, silhouette, signature detail, and anti-AI rules per adversary. Start here. |
| `ENEMY_PORTRAIT_PROMPTS_V4.md` | **Complete v4.2 prompts for all thirteen enemies**, with fixed adult casts, precise faces, rough hair, clothing, individual survival wear and expressions, creature anatomy, machine parts, and signature details. This is the one to work from. |
| `GEMINI_ENEMY_PORTRAIT_PROMPTS.md` | The historical v3.0 pack. All enemy generation blocks are superseded by v4.2; prefer v4.2 corrections for casting or gaze changes. |
| `GEMINI_PIXEL_ART_PROMPTS.md` | The portrait contract and the four survivor prompts. |
| `UI_ASSET_MANIFEST.md` | Item icons, HUD symbols, and delivery/licensing checklist. |
| `UI_STYLE_GUIDE.md` | Interface palette tokens and theme rules. |
| `ASSET_PROVENANCE.md` | Generator, date, licence, and modification record for every shipped asset. Update it before shipping anything new. |

`ENEMY_DESIGN_BIBLE.md` explains the faction theses and signature details. `ENEMY_PORTRAIT_PROMPTS_V4.md` v4.2 is authoritative for exact casting, appearance, wardrobe, anatomy, construction, and the technical contract — 64×64 logical grid, 16–20 colors, flat opaque `#20272B` background. Do not import the older packs' casts into a new prompt.

## Non-negotiables

- Portraits are opaque 64×64 PNG on a perfectly flat `#20272B` field. No transparency, gradient, vignette, frame, or scenery.
- 16–20 colors, one apparent pixel size, hard edges, nearest-neighbour scaling only.
- Must read at 64×64 and at the 50×50 journey HUD, not just enlarged.
- Teen-rated: no blood in motion, open wounds, exposed organs, corpses, or cruelty in progress.
- No baked-in text, logo, signature, or watermark.
- Everything ships packaged locally. No runtime download, webfont, or network dependency.

## Refreshing this folder

```bash
cp assets/portraits/enemy_*.png            art_library/portraits_enemies/
cp assets/portraits/survivor_*.png assets/portraits/survivor_4.svg art_library/portraits_survivors/
cp assets/backgrounds/*.png                art_library/backgrounds/
cp assets/ui/icon.svg                      art_library/ui/
cp art_sources/portraits/*.png             art_library/sources_hires/
cp docs/ENEMY_DESIGN_BIBLE.md docs/ENEMY_PORTRAIT_PROMPTS_V4.md docs/GEMINI_ENEMY_PORTRAIT_PROMPTS.md docs/GEMINI_PIXEL_ART_PROMPTS.md docs/UI_ASSET_MANIFEST.md docs/UI_STYLE_GUIDE.md docs/ASSET_PROVENANCE.md art_library/prompts/
```
