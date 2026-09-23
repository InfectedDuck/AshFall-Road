# Ashfall Road UI style guide

## Direction

The interface should feel like a field dossier read by firelight: dark, quiet, and atmospheric, with the story as the visual focus. Surfaces support decisions; they never compete with the prose. Use one meaningful accent per theme and reserve semantic colours for real game information.

The source of truth is the **Ashfall Road design canvas** (`Ashfall Road Canvas.dc.html`): ten artboards at 393x852 covering the title, survivor selection, event, D20 reveal, combat, inventory, item sheet, checkpoint, and death screens, plus a style tile. Its measurements are design points at that artboard width, which is also the project's design viewport, so a canvas measurement can be read straight into the code. Accent is budgeted at **three uses per screen**, and every semantic colour is paired with a label or a glyph.

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
| `background`, `background_tint`, `scrim` | Reserved backdrop and modal tones. The atmosphere stack scrims backdrops with `surface_overlay`, so these are currently unused by any screen; they stay in the contract because every palette must answer the same questions. |
| `surface`, `surface_overlay`, `surface_raised`, `surface_pressed` | The page, the scrim over a region backdrop (carrying its own 72% alpha), raised plates and cards, and pressed states. |
| `border`, `border_subtle` | Structure only; borders should not become decorative frames. |
| `text`, `muted`, `disabled` | Prose, secondary labels, and unavailable controls. |
| `accent`, `accent_strong` | Selection, focus, actionable choices, and the D20's ordinary state. |
| `danger`, `success`, `critical` | Damage/failure, recovery/success, and natural-20 emphasis. |
| `fatigue`, `radiation`, `meter_track` | Survival-pressure meters and their quiet track. |
| `icon_ink`, `die_surface`, `die_line` | Line-icon stroke on a dark surface, D20 face, and D20 linework. |

Locked principal values:

| Theme | Prose | Accent | Surface | Danger |
|---|---|---|---|---|
| Ember & Parchment | `#F4EBDD` | `#D9A458` | `#111D1E` | `#D9695B` |
| Cinder Rust | `#F8E7D2` | `#E47745` | `#21130F` | `#DF6C5E` |
| Signal at Night | `#EAF1F3` | `#7EB8DB` | `#101C2B` | `#D96D68` |

High Contrast is an independent accessibility override, not a fourth cosmetic theme. It uses near-black surfaces, white prose, and reinforced white/yellow focus outlines.

## Type scale

`scripts/ui/ui_type.gd` owns the canvas type scale. Call sites ask for a **role**, never a number, so a scale change lands everywhere at once. Two families carry the whole game: **Literata** for anything the survivor reads as prose, **Inter** for anything the interface says about itself.

| Role | Size | Family | Tracking | Used for |
|---|---|---|---|---|
| `wordmark` | 30 | Inter | 0.42em | The title-screen lettering only. |
| `display` | 34 | Inter | — | The D20 numeral. |
| `heading` | 28 | Literata | — | The one sentence that ends a run. |
| `numeric` | 22 | Inter | — | Roll arithmetic on the reveal screen. |
| `lede` | 20 | Literata | — | The line under a screen's eyebrow. |
| `prose` | 17 | Literata | — | Event and result narrative, with compact phone leading (4px extra at Normal text). |
| `title` | 17 | Inter | — | Names: survivors, enemies, items. |
| `flavour` | 15 | Literata | — | Choices, item flavour, asides. |
| `action` | 15 | Inter | 0.14em | Full-width button labels, uppercased. |
| `body` | 13 | Inter | — | Stat rows, ledger values, readouts. |
| `label` | 12 | Inter | 0.14em | Meter labels and costs. |
| `eyebrow` | 11 | Inter | 0.22em | The uppercase locator at the top of a screen. |
| `caption` | 10 | Inter | 0.1em | Footnotes and provenance. |

Rules that follow from the scale:

- Tracking is real letter-spacing via `FontVariation`, and it never rounds to zero — an untracked eyebrow is just small text. Only tracked roles allocate a font variation; the rest return the plain face.
- Narrative roles wrap; interface roles do not. An eyebrow or a verdict that wraps inside a tight row sets one letter per line.
- Tracking belongs to full-width actions. Do not put the `action` face on an 11-pixel utility chip — the same tracking that opens up a primary button crowds a small one off the screen.
- Every size multiplies by the player's font scale before it is used.

## Atmosphere layers

`scripts/ui/atmosphere_layers.gd` stacks the same four layers over the region backdrop on every screen; screens differ only in how hard they lean on each. Screens pick a named mix, never a colour.

| Mix | Scrim | Vignette | Firelight | Grain |
|---|---|---|---|---|
| `title` | 45% | 50% | — | 5% |
| `survivor` | — | 45% | 10% | 5% |
| `event` | 72% | 50% | 12% | 5% |
| `reveal` | 86% | 60% | — (10% accent bloom) | 5% |
| `combat` | 72% | 50% | — | 5% |
| `inventory` | — | 45% | — | 5% |
| `checkpoint` | 55% | 45% | 22% | 6% |
| `death` | — | 60% | — | 4% |
| `plain` | — | — | — | 5% |

Grain is capped at 6% and the suite fails if a mix exceeds it. Firelight is derived per theme by pulling the accent toward its own danger tone, so it stays warmer than the accent beside it.

## Component states

- Every plate is square. Buttons, panels, popups, cards and meters use a zero corner radius; the only rounded shapes in the design are the phone frame itself and the item sheet's top corners.
- Normal controls use a raised surface with a subtle structural border, and a primary action is 52 pixels tall.
- Hover/focus uses the active theme accent; keyboard focus is a two-pixel `accent_strong` outline drawn **outside** the control with a two-pixel gap, so a focused control keeps its resting fill and nothing reflows.
- Pressed controls darken to `surface_pressed`; they do not flash unrelated colours.
- Disabled and locked controls use `disabled` plus written explanation. Do not depend on low opacity alone.
- Choices are rules, not cards. Each is a hairline `border_subtle` rule with an accent chevron, the choice itself in Literata, and its stat and odds beneath in tracked Inter. There is no fill until hover. This is what keeps a three-choice screen inside the accent budget.
- Health and damage use `danger`; healing uses `success`; critical success uses `critical`; critical failure uses `danger`. Written labels always accompany colour.
- Fatigue remains blue and Radiation moss across all three themes. Capacity warnings use `danger` and text.
- The drawn D20 and placeholder item runes must use `die_surface`, `die_line`, and `icon_ink` so they remain readable without final art.

## Compact-screen layout rules

The design viewport is 393×852. Page and overlay layout checks also cover 320×568 and 360×640 with Large text; combat is checked from 360×640 upward.

- Long content scrolls; the controls that leave a screen never do. Item descriptions, modifiers, and comparisons scroll inside the item sheet while Close, Equip, Use, and Drop stay pinned outside it. Run summaries scroll while Begin Another Run and Main Menu stay pinned. Stat allocation keeps its apply and return actions above the scrolling stat list.
- Touch targets keep a 44-pixel minimum height. Reclaim vertical space from padding, wrapped lines, and separators — never from a target.
- Safe-area padding uses 24 pixels above, 20 below, and 12 on each side. Below 700 logical pixels of height, top and bottom tighten to 12. Device insets can push these further in.
- Scroll by sliding over prose, cards, items, and settings. All scrolling surfaces share native touch inertia and a 10-pixel deadzone; scrollbars stay hidden. A swipe cancels the pending button press, and settings toggle only on release. Mouse dragging in the desktop preview uses the same behavior.
- A dice target is always written as `ROLL N+`. A bare `N+` beside other numbers reads as a quantity.
- The enemy clue, the attack windows it opens, and the latest consequence belong to one exchange and are grouped in one block rather than separated by the dice column.
- Combat keeps the player left, the enemy right, and a fixed six-action grid at every size.
- Returning from an item sheet restores the inventory filter and scroll position.
- Contextual guidance is one tappable strip in the shell column beside the page, never an overlay. It cannot cover a control, and tapping it dismisses that tip. Turning every tip off and resetting their progress live in Settings.
- A tip is one short line. On the combat screen the round log gives up its reserved rows and the portraits shrink slightly while a tip is visible, so the clue, the windows, and all six actions keep their places.
- No tip opens while a die is resolving or while a saved roll is waiting to be revealed.
- On a compact combat screen the portrait cards drop the `YOU //` and `ENEMY //` prefixes; position, border colour, and the tooltip already carry the side, and the prefix costs a wrapped line inside a 157-pixel card.

## Screenshot review checklist

Before accepting a visual change, inspect event, result, checkpoint, combat, inventory, item detail, settings, tutorial, store, death, and victory screens in all three themes plus High Contrast.

- Prose is the brightest, easiest thing to read; it has no opaque card.
- Selected/filter/focus states are obvious without creating a noisy border grid.
- Damage, healing, fatigue, radiation, locked state, and overweight warning have both an icon or label and their semantic colour.
- Text and active controls retain intended contrast on the darkest local surface.
- Small, normal, and large text do not clip; reduced motion changes animation only.
- At 360×640 with Large text, no action, restart, or close control sits below the bottom edge of its screen or sheet.
- Theme switching changes no run, inventory, purchase, or profile data.
