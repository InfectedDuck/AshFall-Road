# Ashfall Road Icon Manifest

## Purpose

This is the complete list of icons the game needs, one row per file. It is the artist handoff and the developer checklist for replacing every code-drawn silhouette, Unicode glyph, and default launcher icon with final artwork. Stable IDs come from the code and the data files; never rename them.

Portraits and journey backgrounds are not icons and are specified in `docs/UI_ASSET_MANIFEST.md` and `docs/ASSET_PROVENANCE.md`. The D20 is drawn by `scripts/ui/dice_widget.gd` from palette tokens and stays code-drawn.

## Summary

| Group | Count | Status | Where the game looks |
| --- | --- | --- | --- |
| A. Item icons | 50 | Wired | `assets/items/<icon_id>.png` |
| B. Empty equipment slots | 4 | Wired | `assets/items/slot_<slot>.png` |
| C. Weight and capacity | 1 | Wired | `assets/items/weight.png` |
| D. HUD vitals and pressure | 6 (+1 optional) | Glyph | Unicode in `survivor_hud.gd`, `pressure_strip.gd` |
| E. Stat symbols | 5 | Glyph | Unicode in `stats_capsule.gd` |
| F. Navigation and state marks | 14 | Glyph | Unicode in `main.gd`, `survivor_hud.gd`, `combat_presentation.gd` |
| G. Inventory filter rail | 5 | Glyph | Unicode in `main.gd` |
| H. Combat actions and status chips | 11 | Proposed | Text only today |
| I. Condition icons | 13 | Proposed | Text only today |
| J. Launcher, store and splash | 7 | Required | `export_presets.cfg`, `android/build/res/` |
| **Total** | **116** | | |

Status meanings:

- **Wired**: the code already looks for the file at that path. Drop the PNG in and it replaces the placeholder with no code change.
- **Glyph**: the game currently prints a Unicode character from Inter. Final art needs a small code change to swap the label for a texture. The glyph is listed so the artist can see what it replaces.
- **Proposed**: no hook exists yet. Making these is a design decision; they are listed so the set is complete and the budget is known.
- **Required**: platform deliverables that currently point at a single placeholder SVG or at Godot's default files.

## Global rules

These apply to every icon in this document. They come from `docs/UI_STYLE_GUIDE.md` and from how the code renders textures.

- **Two icon languages.** Item icons (groups A to C) are full-colour pixel art in the Ashfall palette: warm ochre, parchment highlights, sage-gray metal, restrained rust. Interface icons (groups D to I) are single-colour line icons delivered as white shapes on transparency; the game tints them per theme with `icon_ink`, `accent`, `danger`, `success`, `fatigue`, or `radiation`. Never bake a theme colour into an interface icon.
- **Ink per theme.** A white interface icon will be tinted to `#C9BFAE` (Ember & Parchment), `#DCC7B8` (Cinder Rust), `#C7D5DB` (Signal at Night), or `#F0F0F0` (High Contrast). Check every icon against all four on its darkest surface (`#111D1E`, `#21130F`, `#101C2B`, `#050708`).
- **Formats.** Items: transparent 64×64 PNG, at most twenty colours, hard pixel edges, no antialiased halo. Interface: SVG on a 24×24 grid with a 2 px stroke (Godot rasterises SVG at import), or a 48×48 PNG rendered from it. Platform icons follow the sizes in group J.
- **Square language.** Plates and frames use a zero corner radius. Do not draw rounded badges or circular backgrounds behind interface icons; the control provides the surface.
- **No text, no emoji.** Nothing baked into the image reads as a letter or number. The game never depends on an emoji font.
- **Distinct silhouettes.** Today's glyph placeholders collide: `◆` is used for Grit, the Gear filter, a full meal, a journey pip, and the permadeath marker; `◈` for Wits and the All filter; `⌁` for Agility and the Utility filter; `◇` for Status, an empty meal, an empty pip, the Dust Cloak, and an unresolved chronicle entry. Final icons for those roles must not share a silhouette.
- **Every semantic colour is paired with a label or a glyph.** An icon never carries meaning by colour alone, so the shape itself must be readable in one colour.
- **Local only.** All art is packaged in the build. No runtime download, webfont, or network dependency.
- **Provenance.** Record artist, generator if any, date, licence, and modification for every file in `docs/ASSET_PROVENANCE.md` before it ships.

## A. Item icons (50)

Wired. Path: `assets/items/<icon_id>.png`. Loaded by `scripts/ui/item_icon.gd`; if the file is missing, the control draws a category silhouette and the temporary rune shown below. The runes are only a fallback, but the test suite requires all fifty to stay distinct, so the `PLACEHOLDER_SYMBOLS` table must be left in place even after art lands.

The control draws the texture inside a 5 px inset, so the art is shown smaller than the control:

| Screen | Control size | Art drawn at |
| --- | --- | --- |
| Equipment slot button | 34×34 | 24×24 |
| Inventory grid tile | 48×48 | 38×38 |
| Item sheet header | 56×56 | 46×46 |
| Default | 42×42 | 32×32 |

Keep the central object readable at 24 px. Reserve the outer four pixels of the 64×64 canvas as breathing room. Every size in this document is the base size before the player's text scale is applied.

### Weapons (12)

| Icon ID | Item | Rune | Brief |
| --- | --- | --- | --- |
| `item_salvage_cleaver` | Salvage Cleaver | ╱ | Truck-spring cleaver with a wrapped scrap handle. |
| `item_pipe_pistol` | Pipe Pistol | ⌐ | Crude pipe-frame pistol with a single exposed chamber. |
| `item_shock_probe` | Shock Probe | ϟ | Slim diagnostic probe with a small charged tip. |
| `item_wrecking_bar` | Wrecking Bar | ┼ | Heavy hooked steel wrecking bar. |
| `item_holdout_revolver` | Holdout Revolver | ◎ | Compact five-chamber revolver. |
| `item_rusted_hatchet` | Rusted Hatchet | ⌑ | Rusted camp hatchet with a taped handle. |
| `item_rebar_spear` | Rebar Spear | △ | Rebar spear with cloth-wrapped grip. |
| `item_nail_bat` | Nail Bat | ╳ | Short bat with a sparse ring of protruding nails. |
| `item_hunting_rifle` | Hunting Rifle | ╤ | Long rifle with a worn wood stock. |
| `item_scrap_shotgun` | Scrap Shotgun | ╫ | Double-pipe improvised shotgun. |
| `item_stun_baton` | Stun Baton | │ | Security baton with a faint charged cap. |
| `item_flare_gun` | Flare Gun | ⌒ | Signal flare pistol and one bright chamber. |

### Armor (8)

| Icon ID | Item | Rune | Brief |
| --- | --- | --- | --- |
| `item_scrap_vest` | Scrap Vest | ▰ | Canvas vest with overlapping sheet-metal scales. |
| `item_runner_jacket` | Runner Jacket | ▱ | Light hooded travel jacket with reinforced elbows. |
| `item_plated_coat` | Plated Coat | ▣ | Long coat showing hidden rectangular armor plates. |
| `item_dust_cloak` | Dust Cloak | ◇ | Folded waxed cloak with an ash-stained hem. |
| `item_tire_armor` | Tire Armor | ◒ | Rubber-tire slab shoulder and chest protection. |
| `item_riot_padding` | Riot Padding | ⊞ | Faded riot padding and hard elbow guard. |
| `item_hazmat_wrap` | Hazmat Wrap | ▧ | Sealed polymer wrap with a repair patch. |
| `item_scout_leathers` | Scout Leathers | ◈ | Quiet leather layers with stitched joint guards. |

### Accessories (8)

| Icon ID | Item | Rune | Brief |
| --- | --- | --- | --- |
| `item_scrap_buckler` | Scrap Buckler | ▽ | Small salvaged road-sign shield, bent rim and hand strap. |
| `item_road_shield` | Road Shield | ⬡ | Broad riveted shield with reinforced edge. |
| `item_field_scanner` | Field Scanner | ◌ | Handheld scanner with a small circular display. |
| `item_trader_token` | Trader Token | ○ | Weathered market coin or stamped trade seal. |
| `item_lucky_die` | Lucky Die | ⚄ | Worn bone die, one face polished nearly blank. |
| `item_filter_mask` | Filter Mask | ◍ | Repaired respirator with a visible filter cartridge. |
| `item_signal_compass` | Signal Compass | ⌖ | Compass with a directional antenna needle. |
| `item_mechanic_gloves` | Mechanic Gloves | ✥ | Pair of insulated work gloves with magnetic fingertips. |

### Backpacks (4)

| Icon ID | Item | Rune | Brief |
| --- | --- | --- | --- |
| `item_canvas_pack` | Canvas Pack | ▥ | Small patched canvas rucksack. |
| `item_frame_pack` | Frame Pack | ▤ | Tall aluminum-frame hiking pack. |
| `item_medic_satchel` | Medic Satchel | ▦ | Compact medical satchel with organized pouches. |
| `item_scavenger_rig` | Scavenger Rig | ▩ | Harness with dangling salvage loops. |

### Consumables (12)

| Icon ID | Item | Rune | Brief |
| --- | --- | --- | --- |
| `item_canned_meat` | Canned Meat | ● | Dented unlabeled food tin. |
| `item_clean_water` | Clean Water | ◐ | Clear sealed water bottle. |
| `item_cloth_bandage` | Cloth Bandage | ≋ | Rolled wax-paper bandage. |
| `item_medkit` | Field Medkit | ⊕ | Field medkit pouch with a simple cross closure. |
| `item_rad_tabs` | Rad Tabs | ☷ | Civil-defense pill packet. |
| `item_stimulant` | Stimulant Injector | ▯ | Narrow injector vial. |
| `item_ration_bar` | Ration Bar | ▬ | Wrapped rectangular emergency ration. |
| `item_bitter_tonic` | Bitter Tonic | ≀ | Stoppered herbal tonic bottle. |
| `item_purifier_ampoule` | Purifier Ampoule | ⎈ | Heavy glass decontamination ampoule. |
| `item_painkillers` | Painkillers | ◓ | Cracked orange tablet bottle. |
| `item_glow_moss` | Glow Moss | ✹ | Small luminous green moss clump. |
| `item_smoke_bomb` | Smoke Bomb | ☁ | Homemade smoke canister with a short fuse. |

### Ammunition (4)

| Icon ID | Item | Rune | Brief |
| --- | --- | --- | --- |
| `item_pistol_rounds` | Pistol Rounds | ¦ | Three small-caliber cartridges. |
| `item_revolver_rounds` | Revolver Rounds | ∶ | Two heavy revolver cartridges. |
| `item_rifle_rounds` | Rifle Rounds | ⋮ | Two long rifle cartridges. |
| `item_shotgun_shells` | Shotgun Shells | ⌇ | Two worn red shotgun shells. |

### Utility (2)

| Icon ID | Item | Rune | Brief |
| --- | --- | --- | --- |
| `item_scrap_parts` | Scrap Parts | ∷ | Wire, bolts, and a small metal plate. |
| `item_climbing_rope` | Climbing Rope | ┄ | Coiled faded climbing rope. |

## B. Empty equipment slots (4)

Wired. When a slot is empty the equipment strip asks the item icon control for `slot_<slot>` with the slot name as its category, so the file is looked up at `assets/items/slot_<slot>.png`. Today it falls back to the solid category silhouette, which reads as "something is here" rather than "nothing is here". These are missing from the existing manifest.

Same 64×64 transparent PNG format as items, drawn at 24×24 in the 34 px slot button. Use an outline-only ghost of the category in the item palette's muted metal, with no fill, so an empty slot is visibly hollow beside a filled one.

| Icon ID | Slot | Brief |
| --- | --- | --- |
| `slot_weapon` | Weapon | Hollow outline of a short blade or barrel, tilted the same way as the weapon silhouette. |
| `slot_armor` | Armor | Hollow outline of a vest or breastplate. |
| `slot_accessory` | Accessory | Hollow ring with a small gap, echoing the accessory silhouette. |
| `slot_backpack` | Backpack | Hollow outline of a pack with a strap arc. |

## C. Weight and capacity (1)

Wired. The inventory capacity row configures an item icon with the ID `weight`, so the game looks for `assets/items/weight.png`. Note that `docs/UI_ASSET_MANIFEST.md` calls this `ui_weight`; the code path is authoritative, so deliver it under `weight`. It is drawn at 14×14 inside a 24 px control, the smallest item-style icon in the game, so keep it to a single bold shape.

| Icon ID | Brief |
| --- | --- |
| `weight` | Hanging field scale: a hook arc over a trapezoid pan. Overweight state is signalled by the label turning `danger`, not by a second icon. |

## D. HUD vitals and pressure (6, plus 1 optional)

Glyph. Rendered by `scripts/ui/icon_meter.gd` and `scripts/ui/pressure_strip.gd`. Hearts are shown at 14 px and meals at 12 px on the journey HUD, times the player's text scale. A partial heart is made by clipping the full heart horizontally over the empty one, so `ui_heart_partial` is optional and only needed if the art direction wants a distinct half-heart drawing.

| Icon ID | Replaces | Tint | Brief |
| --- | --- | --- | --- |
| `ui_heart_full` | ♥ | `danger` | Minimal segmented heart, filled. Must clip cleanly along a vertical cut. |
| `ui_heart_empty` | ♡ | `muted` | Same outline, hollow. |
| `ui_heart_partial` | (clipped ♥) | `danger` | Optional: half-filled heart. Only if clipping the full heart is rejected in review. |
| `ui_food_full` | ◆ | `accent` | Small ration diamond, filled. Four sit in one row. |
| `ui_food_empty` | ◇ | `muted` | Same diamond, hollow. |
| `ui_fatigue` | ◉ | `fatigue`, `danger` at 75+ | Circular strain mark: a ring with a heavy inner dot. Fatigue stays blue in every theme. |
| `ui_radiation` | ☢ | `radiation`, `danger` at 75+ | Restrained radiation trefoil. Radiation stays moss in every theme. |

## E. Stat symbols (5)

Glyph. Drawn at 11 px inside the stats capsule and printed inline inside choice previews as `[symbol]`, so each must survive 11 px in one colour and be unmistakable beside the other four. The stat strip prints `STR AGI WIT GRT PRE` instead; the icon set does not replace those letters.

| Icon ID | Stat | Replaces | Brief |
| --- | --- | --- | --- |
| `ui_stat_strength` | Strength | ✦ | Four-point force mark. |
| `ui_stat_agility` | Agility | ⌁ | Flowing movement line. Must differ from the Utility filter icon. |
| `ui_stat_wits` | Wits | ◈ | Faceted observation diamond. Must differ from the All filter icon. |
| `ui_stat_grit` | Grit | ◆ | Solid endurance diamond. Must differ from the meal, pip, and Gear icons. |
| `ui_stat_presence` | Presence | ◎ | Signal ring. Must differ from the Holdout Revolver rune. |

## F. Navigation and state marks (14)

Glyph. These live in buttons and labels across the shell. Sizes are the font sizes the glyph is printed at today, before text scaling; the icon replaces the glyph at the same optical size.

| Icon ID | Replaces | Shown at | Where | Brief |
| --- | --- | --- | --- | --- |
| `ui_settings` | ⚙ | 18–19 px | Title screen and journey HUD utility button. | Small gear outline, six teeth. |
| `ui_close` | × and ✕ | 12–19 px | Overlay headers, tip strip dismiss. | Two-stroke close mark. One file serves both. |
| `ui_choice` | › | 17 px | Leading edge of every event choice, tinted `accent` or `disabled`. | Slim single chevron. |
| `ui_inventory` | ▣ | 11 px | `INVENTORY` link on the journey HUD. | Compact backpack outline. |
| `ui_status` | ◇ | 11 px | `STATUS n` conditions link. | Hollow diamond with a short centre tick. |
| `ui_locked` | ▣ | 12 px | `LOCKED:` detail line inside an unavailable choice, tinted `disabled`. | Small padlock outline. |
| `ui_equipped` | ✓ | 9–11 px | Equipment slot label and inventory tile corner. | Short check mark. |
| `ui_info` | ⓘ | 11–12 px | Combat status button and enemy tell. | Ringed "i" without a letterform: ring, dot, stem. |
| `ui_pip_full` | ◆ | 11 px | Region breadcrumb, five per region. | Filled journey pip. |
| `ui_pip_empty` | ◇ | 11 px | Region breadcrumb. | Hollow journey pip. |
| `ui_danger_marker` | ◆ | 13 px | Permadeath notice, tinted `danger`. | Rotated danger square, as on the canvas. |
| `ui_unresolved` | ◇ | 15 px | Road Chronicle entry not yet discovered, tinted `disabled`. | Hollow diamond with a dashed edge. |
| `ui_log_player` | › | 11 px | Combat feed prefix for the survivor's line. | Right-pointing chevron. |
| `ui_log_enemy` | ‹ | 11 px | Combat feed prefix for the enemy's line. | Left-pointing chevron. Mirror of `ui_log_player`. |

Keep as text, no icon needed: item quantities (`×3`), stat allocation `+` and `−`, and the `ROLL N+` targets.

## G. Inventory filter rail (5)

Glyph. Five 44×44 toggle tiles down the left of the pack. The active tile is marked by a 2 px accent edge on its leading side, so the icon itself carries no selected state; it is tinted `accent` when active and `muted` otherwise. Printed at 16 px today.

| Icon ID | Filter | Replaces | Brief |
| --- | --- | --- | --- |
| `ui_filter_all` | All items | ◈ | Three stacked short rules. |
| `ui_filter_gear` | Gear | ◆ | Small vest over a blade. |
| `ui_filter_supplies` | Supplies | + | Tin with a cross closure. |
| `ui_filter_ammo` | Ammunition | • | Two cartridges side by side. |
| `ui_filter_utility` | Utility | ⌁ | Coil of rope or a bolt. |

## H. Combat actions and status chips (11)

Proposed. The six-action grid and the status chips are text only, and the style guide keeps them that way at 360×640 because a wrapped label costs a row. Icons here are optional and would sit at the leading edge of each 44 px action button at 16 px. Make these only after groups A to G are in and reviewed on the compact screen.

| Icon ID | Action or chip | Brief |
| --- | --- | --- |
| `ui_action_attack` | Attack | Forward blade stroke. |
| `ui_action_block` | Block (Guard in the older grid) | Small shield face. |
| `ui_action_dodge` | Dodge | Sidestep arc with a trailing dash. |
| `ui_action_item` | Use Item | Open hand with a vial. |
| `ui_action_flee` | Flee | Running figure or footprint pair. |
| `ui_action_opportunity` | Opportunity | Crosshair with one open quadrant. |
| `ui_chip_guard` | GUARD chip, tinted `critical` | Shield outline. |
| `ui_chip_exposed` | EXPOSED chip, tinted `danger` | Open bracket pair. |
| `ui_chip_riposte` | RIPOSTE window | Returning arrow over a blade. |
| `ui_chip_opening` | OPENING window | Gap in a ring. |
| `ui_chip_suppressed` | SUPPRESSED chip | Downward pressure bar over a figure. |

## I. Condition icons (13)

Proposed. Conditions come from `data/conditions.json` and are listed as text in the status popup. Icons would sit beside each row and in the combat status button. Harmful conditions tint `danger`, helpful ones tint `success`, so the shapes must read in one colour.

| Icon ID | Condition | Kind | Brief |
| --- | --- | --- | --- |
| `cond_bleeding` | Bleeding | Harmful | Single falling drop. |
| `cond_sprain` | Sprained Joint | Harmful | Bent limb with a strain mark. |
| `cond_infection` | Infection | Harmful | Wound outline with three radiating dots. |
| `cond_fever` | Fever | Harmful | Thermometer with a high mark. |
| `cond_shaken` | Shaken | Harmful | Head outline with tremor lines. |
| `cond_concussed` | Concussed | Harmful | Head outline with a spiral. |
| `cond_burned` | Burned | Harmful | Small flame. |
| `cond_irradiated` | Irradiated | Harmful | Trefoil inside a body outline. Distinct from `ui_radiation`. |
| `cond_exhausted` | Exhausted | Harmful | Slumped figure. |
| `cond_inspired` | Inspired | Helpful | Rising spark. |
| `cond_focused` | Focused | Helpful | Eye with a centre point. |
| `cond_steady_hands` | Steady Hands | Helpful | Open hand with a level line. |
| `cond_momentum` | Momentum | Helpful | Forward chevron pair. |

## J. Launcher, store and splash (7)

Required. `project.godot` and both Android presets in `export_presets.cfg` point the main, adaptive foreground, and adaptive monochrome layers at the same `assets/ui/icon.svg`, the adaptive background is empty, and `android/build/res/drawable/splash_icon.webp` is Godot's default. The current SVG also bakes the numeral "20" in Arial, which breaks the no-text rule and renders with whatever font the importer finds.

Redraw the mark once as a vector master (a D20 face over a road or an ember, in the Ember & Parchment palette) and export the set below from it. Keep the mark's identity the same across every export.

| Deliverable | File | Size | Notes |
| --- | --- | --- | --- |
| Master mark | `assets/ui/icon.svg` | 512×512 viewBox | No text. Also the Godot project icon. |
| Play Store listing icon | `art_library/ui/store_icon_512.png` | 512×512 | 32-bit PNG, full square with opaque corners and no drop shadow; Play applies its own rounding. Not bundled in the build. |
| Legacy launcher | `assets/ui/launcher_192.png` | 192×192 | Referenced as `launcher_icons/main_192x192`. |
| Adaptive foreground | `assets/ui/launcher_foreground_432.png` | 432×432 | Transparent; keep the mark inside the centred 264 px safe circle. |
| Adaptive background | `assets/ui/launcher_background_432.png` | 432×432 | Opaque flat `#111D1E` or a quiet ember gradient; no detail, it is masked and parallaxed. |
| Adaptive monochrome | `assets/ui/launcher_monochrome_432.png` | 432×432 | Single white silhouette on transparency for Android 13 themed icons. Not the colour mark. |
| Splash icon | `android/build/res/drawable/splash_icon.webp` (or `.png`) | 288×288 | Android 12 splash: mark inside the centred 192 px safe circle. Set `application/boot_splash/image` in `project.godot` to the same mark on the `#0B1415` clear colour. |

## Delivery checklist

For the artist:

1. Deliver items and slot icons as 64×64 transparent PNGs, interface icons as white SVGs on a 24×24 grid, and platform icons at the sizes above.
2. Name every file exactly as its ID. Lowercase, underscores, no version suffixes in `assets/`; keep versions in `art_sources/` or `art_library/`.
3. Check each icon at its smallest shown size: 24 px for items, 11 px for stats and pips, 14 px for hearts and pressure marks.
4. Check every interface icon tinted with all four inks over its darkest surface, and every item icon over `#111D1E`, `#21130F`, and `#101C2B`.
5. Confirm no two icons in groups D to G share a silhouette, and that no interface icon repeats an item rune.

For the developer, when art lands:

1. Set `texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST` on the item icon control, as `scripts/ui/portrait_art.gd` already does. Pixel art drawn at 24 px through the default linear filter will blur.
2. Keep `PLACEHOLDER_SYMBOLS` intact. The test suite asserts fifty distinct runes and they remain the fallback for a missing file.
3. For each Glyph group, replace the `Label` or button text with a `TextureRect` tinted through `modulate` with the palette token in the table. Keep the tooltip and `accessibility_name` on the control; the icon is drawn, not spoken.
4. Point the four `launcher_icons/*` keys in both Android presets at the separate layer files, and set the boot splash image in `project.godot`.
5. Add a provenance entry for every new file in `docs/ASSET_PROVENANCE.md`, then run the screenshot review in `docs/UI_STYLE_GUIDE.md` across all three themes and High Contrast.
