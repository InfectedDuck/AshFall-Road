# Ashfall Road UI style guide

## Direction

The interface should feel like a field dossier read by firelight: dark, quiet, and atmospheric, with the story as the visual focus. Surfaces support decisions; they never compete with the prose. Use one meaningful accent per theme and reserve semantic colours for real game information.

## Themes and stable IDs

| Saved / entitlement ID | Player-facing name | Direction |
|---|---|---|
| `default` | Ember & Parchment | Deep teal-black, parchment prose, worn ochre accents. |
| `rust` | Cinder Rust | Dark umber, warm ivory, copper-orange salvage light. |
| `night` | Signal at Night | Deep navy, cool white, restrained signal blue. |

The IDs above are permanent profile and purchase keys. Never rename them to change a displayed name.

## Semantic palette contract

`scripts/ui/ui_palette.gd` is the single source of truth. Every palette supplies these tokens:

| Token group | Purpose |
|---|---|
| `background`, `background_tint`, `scrim` | Scenic backdrop treatment and modal separation. |
| `surface`, `surface_overlay`, `surface_raised`, `surface_pressed` | Cards, quiet controls, selected areas, and pressed states. |
| `border`, `border_subtle` | Structure only; borders should not become decorative frames. |
| `text`, `muted`, `disabled` | Prose, secondary labels, and unavailable controls. |
| `accent`, `accent_strong` | Selection, focus, actionable choices, and the D20's ordinary state. |
| `danger`, `success`, `critical` | Damage/failure, recovery/success, and natural-20 emphasis. |
| `fatigue`, `radiation`, `meter_track` | Survival-pressure meters and their quiet track. |
| `icon_ink`, `die_surface`, `die_line` | Placeholder-rune cut-outs and D20 contrast. |

Locked principal values:

| Theme | Prose | Accent | Surface | Danger |
|---|---|---|---|---|
| Ember & Parchment | `#F4EBDD` | `#D9A458` | `#111D1E` | `#D9695B` |
| Cinder Rust | `#F8E7D2` | `#E47745` | `#21130F` | `#DF6C5E` |
| Signal at Night | `#EAF1F3` | `#7EB8DB` | `#101C2B` | `#D96D68` |

High Contrast is an independent accessibility override, not a fourth cosmetic theme. It uses near-black surfaces, white prose, and reinforced white/yellow focus outlines.

## Component states

- Normal controls use a raised surface with a subtle structural border.
- Hover/focus uses the active theme accent; keyboard focus uses `accent_strong` and a two-pixel outline.
- Pressed controls darken to `surface_pressed`; they do not flash unrelated colours.
- Disabled and locked controls use `disabled` plus written explanation. Do not depend on low opacity alone.
- Choices retain the ochre/copper/blue leading marker and probability line. Their surface is faint so they read as interactive prose, not oversized menu cards.
- Health and damage use `danger`; healing uses `success`; critical success uses `critical`; critical failure uses `danger`. Written labels always accompany colour.
- Fatigue remains blue and Radiation moss across all three themes. Capacity warnings use `danger` and text.
- The drawn D20 and placeholder item runes must use `die_surface`, `die_line`, and `icon_ink` so they remain readable without final art.

## Screenshot review checklist

Before accepting a visual change, inspect event, result, checkpoint, combat, inventory, item detail, settings, tutorial, store, death, and victory screens in all three themes plus High Contrast.

- Prose is the brightest, easiest thing to read; it has no opaque card.
- Selected/filter/focus states are obvious without creating a noisy border grid.
- Damage, healing, fatigue, radiation, locked state, and overweight warning have both an icon or label and their semantic colour.
- Text and active controls retain intended contrast on the darkest local surface.
- Small, normal, and large text do not clip; reduced motion changes animation only.
- Theme switching changes no run, inventory, purchase, or profile data.
