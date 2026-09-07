# Ashfall Road UI and Item Asset Manifest

## Purpose

This document is the handoff for replacing the current local, code-drawn placeholders. It does not request generated artwork and does not change the stable asset IDs already used by the game.

The complete icon list, including the empty equipment slot icons, the `weight` icon, the launcher icon set, and every Unicode glyph the interface still prints, is `docs/ICON_MANIFEST.md`. This file keeps the item briefs and the portrait and background rules.

All final item artwork uses a transparent **64×64 PNG** at `assets/items/<icon_id>.png`. Keep the central object readable at 32 px, use the Ashfall palette (warm ochre, parchment highlights, sage-gray metal, restrained rust), and avoid text baked into the image. The temporary outlines and distinct abstract runes remain a fallback if a texture is absent.

## Item icons

Combat-build additions (both use existing tinted code-drawn fallbacks; no new artwork generated):

| Item / stable ID | Temporary symbol | Final path | Brief |
| --- | --- | --- | --- |
| Scrap Buckler / `scrap_buckler` | ▽ | `assets/items/item_scrap_buckler.png` | Small salvaged road-sign shield, bent rim and hand strap; transparent 64×64 PNG. |
| Road Shield / `road_shield` | ⬡ | `assets/items/item_road_shield.png` | Broad riveted shield with reinforced edge; transparent 64×64 PNG. |

Riposte, Opening, interruption cooldown and Opportunity use named UI labels and existing palette accents. They require no attack frames or new portraits. Keep the two shield symbols distinct from all 48 earlier item symbols. The existing licensing/provenance checklist applies to future replacement art.

| ID | Final image brief |
| --- | --- |
| `item_salvage_cleaver` | Truck-spring cleaver with a wrapped scrap handle. |
| `item_pipe_pistol` | Crude pipe-frame pistol with a single exposed chamber. |
| `item_shock_probe` | Slim diagnostic probe with a small charged tip. |
| `item_wrecking_bar` | Heavy hooked steel wrecking bar. |
| `item_holdout_revolver` | Compact five-chamber revolver. |
| `item_rusted_hatchet` | Rusted camp hatchet with a taped handle. |
| `item_rebar_spear` | Rebar spear with cloth-wrapped grip. |
| `item_nail_bat` | Short bat with a sparse ring of protruding nails. |
| `item_hunting_rifle` | Long rifle with a worn wood stock. |
| `item_scrap_shotgun` | Double-pipe improvised shotgun. |
| `item_stun_baton` | Security baton with a faint charged cap. |
| `item_flare_gun` | Signal flare pistol and one bright chamber. |
| `item_scrap_vest` | Canvas vest with overlapping sheet-metal scales. |
| `item_runner_jacket` | Light hooded travel jacket with reinforced elbows. |
| `item_plated_coat` | Long coat showing hidden rectangular armor plates. |
| `item_dust_cloak` | Folded waxed cloak with an ash-stained hem. |
| `item_tire_armor` | Rubber-tire slab shoulder and chest protection. |
| `item_riot_padding` | Faded riot padding and hard elbow guard. |
| `item_hazmat_wrap` | Sealed polymer wrap with a repair patch. |
| `item_scout_leathers` | Quiet leather layers with stitched joint guards. |
| `item_field_scanner` | Handheld scanner with a small circular display. |
| `item_trader_token` | Weathered market coin or stamped trade seal. |
| `item_lucky_die` | Worn bone die, one face polished nearly blank. |
| `item_filter_mask` | Repaired respirator with a visible filter cartridge. |
| `item_signal_compass` | Compass with a directional antenna needle. |
| `item_mechanic_gloves` | Pair of insulated work gloves with magnetic fingertips. |
| `item_canvas_pack` | Small patched canvas rucksack. |
| `item_frame_pack` | Tall aluminum-frame hiking pack. |
| `item_medic_satchel` | Compact medical satchel with organized pouches. |
| `item_scavenger_rig` | Harness with dangling salvage loops. |
| `item_canned_meat` | Dented unlabeled food tin. |
| `item_clean_water` | Clear sealed water bottle. |
| `item_cloth_bandage` | Rolled wax-paper bandage. |
| `item_medkit` | Field medkit pouch with a simple cross closure. |
| `item_rad_tabs` | Civil-defense pill packet. |
| `item_stimulant` | Narrow injector vial. |
| `item_ration_bar` | Wrapped rectangular emergency ration. |
| `item_bitter_tonic` | Stoppered herbal tonic bottle. |
| `item_purifier_ampoule` | Heavy glass decontamination ampoule. |
| `item_painkillers` | Cracked orange tablet bottle. |
| `item_glow_moss` | Small luminous green moss clump. |
| `item_smoke_bomb` | Homemade smoke canister with a short fuse. |
| `item_pistol_rounds` | Three small-caliber cartridges. |
| `item_revolver_rounds` | Two heavy revolver cartridges. |
| `item_rifle_rounds` | Two long rifle cartridges. |
| `item_shotgun_shells` | Two worn red shotgun shells. |
| `item_scrap_parts` | Wire, bolts, and a small metal plate. |
| `item_climbing_rope` | Coiled faded climbing rope. |

## HUD and interface symbols

These may be final 24×24 transparent PNGs or clean vector equivalents. Maintain a one-color outline version for high contrast and a muted disabled state.

| Stable semantic ID | Subject |
| --- | --- |
| `ui_stat_strength` | Four-point force/star mark. |
| `ui_stat_agility` | Flowing movement line. |
| `ui_stat_wits` | Faceted observation diamond. |
| `ui_stat_grit` | Solid endurance diamond. |
| `ui_stat_presence` | Signal/ring mark. |
| `ui_heart_full`, `ui_heart_partial`, `ui_heart_empty` | Minimal segmented health hearts. |
| `ui_food_full`, `ui_food_empty` | Small ration diamond, filled and hollow. |
| `ui_fatigue` | Circular strain mark. |
| `ui_radiation` | Restrained radiation trefoil. |
| `ui_inventory` | Compact backpack outline. |
| `ui_settings` | Small gear outline. |
| `ui_weight` | Hanging field scale. |
| `ui_filter_all`, `ui_filter_gear`, `ui_filter_supplies`, `ui_filter_ammo`, `ui_filter_utility` | Five compact vertical-rail filter icons. |
| `ui_equipped`, `ui_locked`, `ui_close`, `ui_choice` | Check, lock, close, and slim choice-chevron marks. |

## Portrait assets

Portraits are opaque 64×64 PNG sprites on one perfectly flat near-black charcoal-slate background. They are displayed in candidate selection, the 50×50 journey HUD, and the combat presentation. Keep faces and central forms large enough to survive those native sizes.

- Four survivor portraits: `survivor_1` through `survivor_4`; close head-and-shoulder crop, identity-flexible clothing, no fixed profession or prominent weapon.
- Thirteen adversary portraits: `enemy_bandits`, `enemy_dogs`, `enemy_stalker`, `enemy_toll`, `enemy_leeches`, `enemy_raiders`, `enemy_drones`, `enemy_scavs`, `enemy_cult`, `enemy_hunters`, `enemy_guard`, `enemy_warden`, and `enemy_crows`.
- Human groups use one dominant face plus unobstructed secondary faces; creature groups retain an unmistakable group silhouette.
- Regional identity appears only through restrained edge-light colors. Portrait backgrounds contain no scene, gradient, decorative shape, frame, or transparency.
- High-resolution production sources belong under the Godot-ignored `art_sources/portraits/` directory. Only approved 64×64 sprites belong under `assets/portraits/`.
- Journey backgrounds remain seven separate vertical scenes; do not bake interface text into them.

## Delivery and licensing checklist

- Preserve each stable file name and the required background treatment exactly.
- Use nearest-neighbor scaling; no antialiased edge halos.
- Test every icon at 32 px, 48 px, and against the near-black teal background.
- Record artist, source, licence, and modification status in `docs/ASSET_PROVENANCE.md` before shipping.
- Keep all art packaged locally. No runtime download, webfont, emoji font, or network dependency is permitted.
