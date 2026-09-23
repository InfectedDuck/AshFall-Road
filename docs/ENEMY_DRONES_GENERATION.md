# Security Drones generation record

- Asset: `enemy_drones`
- Date: 2026-09-08
- Generator: none. Hand-authored pixel art drawn by script on a true 64×64 grid from the prompt block in `docs/ENEMY_PORTRAIT_PROMPTS_V4.md` §2 prompt 9. No image-generation model, no external reference, and no other portrait was used as input.
- Script: `tools/pixel_art/draw_enemy_drones.py` (Python 3, Pillow). Re-run it to regenerate every output below byte-for-byte:

  ```
  python tools/pixel_art/draw_enemy_drones.py <output directory>
  ```

- Selected source: `art_sources/portraits/enemy_drones_source.png` (1024×1024, the 64×64 grid enlarged 16× with nearest-neighbour sampling, so the source is already pixel-exact).
- Runtime: `assets/portraits/enemy_drones.png`, 64×64 RGBA, **19 colours**, fully opaque flat `#20272B` background identical in all four corners. Written directly from the named palette, so `tools/prepare_portrait.gd` was not needed; running it on the source with 20 colours and `#20272B` should be a no-op.
- State: installed as a candidate. **Final visual approval pending.** The previous runtime file at this path was the reverted Blender experiment, which `art_sources/blender/rollback.json` records as removed after visual review; this file replaces nothing that was approved.

## What the brief asked for, and where it is

| Brief line | In the portrait |
| --- | --- |
| Exactly five drones, four working and one dead, every chassis different | Rectangle (patrol), narrow upright (inspection), caged sphere (utility), flat disk (dead alarm), three-pronged hub (emitter) |
| Unit 1 patrol, large, below centre, tilted counterclockwise | Wide soot-gray housing, 4° column shear, crushed viewer-left corner, dirty cream replacement panel on top, two square-shrouded lift fans, cracked horizontal grille right, brass nameplate scraped blank |
| Only the patrol lens is red | One red circular sensor, offset left, with a single cream catchlight. Every other sensor is dark glass |
| Unit 2 inspection, high-left, looks past the viewer | Thin oxidized-steel body leaning 12° left, tall vertical dark-glass lens with its reflection pushed to one side, compact lift duct behind the upper end, rust repair band around the lower third |
| Unit 3 utility, high-right | Round faded-ochre housing, three charcoal cage ribs (two meridians and a low equator), one pale square replacement section on the right rib, small recessed rectangular sensor facing the viewer, two short lift pods |
| Unit 4 dead alarm, mid-right, carried by the utility fork | Flat charcoal-black disk, warped rust-brown rim, broken beacon stump, completely dark blank sensor slot, the only two-colour hazard band. A one-pixel background gap keeps its hull separate from the broad fork beneath it |
| Unit 5 emitter, low-left, tilted clockwise, rear corner cropped | Dirty-cream triangular hub, three blunt steel prongs with the right one broken short, recessed dark sensor between them, rear lift block cropped at the left edge only so all four corners stay flat background |
| Materials | Cracked grille, blank brass plaque, bolted mismatched panels (lighter left panel, seam with bolts), rust rim light on upper-right edges |
| Palette | Charcoal, soot gray, oxidized steel, dirty parchment, faded ochre, dull brass, rust, one warning red, dark glass: 19 colours total, shared ochre and brass ramp |
| Thumbnail test at 50×50 | One large patrol unit with the red sensor, four smaller orbiting machines, and the dead dark hull all remain separable |

## Review notes

- Judged at 64×64 and at 50×50 (nearest-neighbour), never only enlarged.
- Ribs were first drawn in the lighter charcoal and vanished against the sphere's shadow side; they now use the darkest charcoal so the cage reads at 50×50.
- The rear lift block was first cropped through the bottom-left corner, which violated the flat-corner rule; it now crops only the left edge.
- Composition is a loose orbit, not a triangle: inspection high-left, utility high-right, dead alarm mid-right, patrol below centre, emitter low-left, with background channels between every hull except the single fork.

## Not yet done

- Owner visual approval.
- Entry in `docs/ASSET_PROVENANCE.md`, which was being edited by the portrait session when this record was written. The facts above are complete enough to copy across.
- The Godot `.import` file will be regenerated on the next editor or headless scan.
