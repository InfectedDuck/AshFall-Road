# Testing

## Automated headless suite

Run the suite with the Godot 4.7.2 console executable from the project root:

`C:\Users\ASUS\Applications\Godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/test_runner.gd`

The current suite has 2,491 assertions and 0 failures. Assertion counts vary slightly when the machine is loaded, because a few UI checks are frame-timed; failures are what matter. It validates 97 v1 events and the optional 112-event v1.1 boundary; all 146 named-difficulty checks; the exponential probability curve and exact percentage-to-D20-target mapping; Level 1–8 XP thresholds; journey, difficulty, checkpoint, and combat rewards; idempotent XP recovery; cautious/selective/aggressive progression targets; 500-seed combat-opportunity limits; uncapped stats and combat scaling; full-Fatigue checkpoint rest and one-check Momentum; the complete Bunker Forty-One and Rust-Sea/Mara Venn expansions; all 76 baseline prose rewrites live in the launch build; v1 mechanical-signature equality; fifteen deterministic Living Road callbacks; callback/combat/supply priority; ten recovered item routes; the ten launch equipment routes with their critical fallback, failure Fatigue, mutual exclusivity, and restart recovery; complete launch item acquisition; the seven contextual tips, their length limits, profile defaults, and the migration that leaves an experienced profile with no new tutorial; the Road Chronicle's ten reachable chapters, preserved variant accounts, and a terminal receipt that keeps earlier discoveries and history without duplicating either; read-only equipment comparison, including run and RNG purity, neutral values during a fight, ammunition and shield conflicts, and the comparison rows the item sheet renders; Road Chronicle idempotency; Grit heart thresholds; all four packaged survivor portrait IDs and crop-to-fill rendering; harmful/helpful Status grouping, condition duration, complete remedy coverage, and direct autosaved treatment; stable item icons; bundled fonts; layered HUD and responsive overlays; typewriter and swipe behavior; permanently reachable allocation controls; distinct runtime global openings and per-event reveal-cache identity; actor-aligned horizontal combat text and critical typography; the design canvas contract — every Ember & Parchment token against the style tile, the two-family type scale with tracking that survives every font scale, the nine atmosphere mixes and their 6% grain ceiling, the canvas D20 geometry and its natural-20/natural-1 states, the choice row’s hairline-and-chevron construction, and the offset focus ring and square corners; palette contrast; guided openings; hunger and supplies; deterministic recovery; schema-5 run and profile migration; save restoration; profile and entitlement persistence; and death-marker enforcement.

Generate the mathematical launch snapshot with:

`C:\Users\ASUS\Applications\Godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/balance_report.gd`

Verify whole journeys and the robustness soak with:

`C:\Users\ASUS\Applications\Godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/full_run_harness.gd -- --soak 1000`

It proves a recorded decision record replays deterministically and runs 1,000 seeded legal-action runs. Results and the separation between encounter, robustness, and human evidence are recorded in [RUN_VERIFICATION.md](RUN_VERIFICATION.md).

Audit the integrated data package against the launch configuration with:

`C:\Users\ASUS\Applications\Godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/data_package_audit.gd`

It runs nine read-only checks and exits 1 on any discrepancy. The latest results and the documentation discrepancies it found are recorded in [DATA_PACKAGE_AUDIT.md](DATA_PACKAGE_AUDIT.md).

Audit local release blockers with:

`C:\Users\ASUS\Applications\Godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/release_readiness.gd`

Capture the real screens at the design-canvas artboard size, for a side-by-side against `Ashfall Road Canvas.dc.html`, with:

`C:\Users\ASUS\Applications\Godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe --path . --script res://tools/canvas_screenshots.gd`

It boots the real UI at 393×852, walks the title, survivor, event, revealed choices, D20 reveal, checkpoint, inventory and death screens, and writes PNGs to `user://canvas_shots`. It needs a display; it does not run headless. Survivors are rolled at random, so the numbers differ per run — read it for layout and typography, not for content.

Also parse the project and register every script with:

`C:\Users\ASUS\Applications\Godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --editor --path . --quit`

The restricted Windows development sandbox may print certificate-store and editor-settings warnings. They are environment-access warnings rather than gameplay failures. Run save/load tests with normal user-folder access, and investigate certificate access before enabling HTTPS monetization calls.

## Manual desktop checks

1. Start a new run and confirm every candidate has 15 stat points, 4–8 hearts from base Grit, four food icons, a name, and a portrait placeholder.
2. Confirm the event title and numerical event label are absent. Let the story reveal, then verify choices fade in; repeat by double-tapping the narrative to reveal it immediately.
3. Select a checked event choice. Confirm it shows the relevant stat, exact success percentage, and minimum D20 target. Before rolling, verify the same target appears; afterward verify **ROLL N • NEEDED M+ • SUCCESS/FAIL** uses the original percentage.
4. Confirm reduced-motion mode reveals prose instantly and does not rotate or cycle the die.
5. Complete two normal events and verify exactly one food icon drains. Repeat at zero food and verify exactly 50 HP is lost.
6. Trigger a supply event and verify a successful route can provide at least two satiety.
7. Confirm normal journey completion grants 4 XP, successful difficult checks add their displayed category reward, Flee grants no combat XP, and defeating an enemy grants its exact previewed XP.
8. At each checkpoint, confirm 10 XP is awarded exactly once. Open allocation and verify **APPLY POINTS & RETURN** and **RETURN WITHOUT SPENDING** remain above the scrollable stat list. Press `+`, apply the draft, and then use the checkpoint's explicit **CONTINUE JOURNEY** or Rest route.
9. At a checkpoint, verify Rest consumes one selected food, restores its satiety, sets Fatigue exactly to zero, heals 25 HP, and cannot be repeated. In another run, verify Press On keeps the food, adds normal travel Fatigue, and grants +1 to every stat for exactly the next checked choice.
9a. Open **STATUS** from the journey utility row. Confirm harmful and helpful conditions are separated, exact modifiers and remaining checks are visible, owned remedies have a **USE** action, unavailable remedies are named as not carried, and successful treatment consumes one item and autosaves. During combat, confirm STATUS remains readable but treatment directs the player to the turn-consuming **USE ITEM** action.
10. Enter combat and verify only one Fatigue/Radiation strip appears; the player portrait is left and the enemy portrait is right; exact HP and meters visibly change; armor/status chips match the combat state; player feed entries begin on the left; enemy entries begin on the right in red; critical text uses the larger literary typeface; and the 2×2 action grid stays reachable.
11. Test new Attack hit/miss, Block, Dodge, Item, Flee and Opportunity. Verify committed Heavy/Sweep tells, Riposte/Opening expiry, shields, mastery and ammunition on misses. Separately resume a legacy fight and test its original Guard/critical rules.
12. Fire a ranged weapon until empty and confirm each attack consumes ammunition and the next attack clearly uses Unarmed.
13. Close and reopen before an event roll, after its reveal, before a killing combat round, after victory XP, at checkpoint XP/allocation, and on death. No action, point, or XP source may apply twice.
14. Die, restart, and confirm Continue never returns the dead survivor while all run XP, levels, and points vanish and settings, history, and entitlements remain.
15. Equip every item category and test overweight Agility percentage penalties.
16. Increase font size and enable high contrast on every core screen; confirm prose scrolls independently, controls remain reachable, and color is never the only result label.
17a. Open ROAD CHRONICLE from the title menu. Confirm the Runs tab lists the latest completed runs with survivor, region, level, equipment, strongest defeated enemy, and cause, that an older summary says "Not recorded" rather than inventing a value, and that the Discoveries tab counts only reachable chapters and never names a disabled callback thread. Choose CONTINUE RUN and confirm the recap describes where you stopped and dismisses.
17. Confirm no tutorial wall opens on a first run, that HOW TO PLAY under Settings still holds the full reference, and that each contextual tip appears once at its moment, dismisses with one tap, and does not return.
18. Open Inventory and verify four equipment slots, category placeholders, responsive filter/grid layout, item details, equip replacement, unequip, use, Drop One/All confirmation, last-stack removal, and immediate weight/capacity feedback.
19. Open Inventory or Settings during a story reveal, close with both `X` and Back, and confirm the same passage resumes without restarting. Repeat at Slow, Normal, Fast, Instant, and reduced-motion settings.
20. At 360×640-equivalent, 393×852, and the Samsung's full aspect ratio, test all three text sizes and confirm the allocation footer, choices, inventory actions, and overlay close buttons remain visible.
21. Complete fixed-seed runs twice with identical candidates and decisions and compare event order, percentages, rolls, damage, ammo, and outcomes.
22. Review every core screen in Ember & Parchment, Cinder Rust, Signal at Night, and High Contrast in daylight and low light. Use `docs/UI_STYLE_GUIDE.md` as the screenshot checklist.
23. Play the Bunker Forty-One arc through the quiet hatch, forced hatch, and refusal routes. Confirm the Hush Sovereign route is visibly warned, the appropriate Underrail continuation pre-empts ordinary filler, and the final gate offers only the endings earned by the run’s testimony, key, or Choir record.
24. Play the Rust-Sea/Mara Venn chain after helping and abandoning Mara. Confirm the Green Line begins only from an earned Bunker Forty-One hook, all Salt Crown warnings remain obvious, copied names and named witnesses persist, and the Sunken Spire route does not alter an interrupted run.
25. In a v1.1 test build with `ashfall/release/living_road_enabled=true`, resolve positive, failed, and refusal paths through each of the five recurring-human threads. Confirm no region draws more than one callback, combat and supply guarantees still take priority, and missed chapters expire cleanly.
26. Open ROAD CHRONICLE from the title menu, force-close, die, and begin a new run. Confirm the ten reachable Bunker Forty-One, Rust-Sea, and ending chapters, their character state, and the run history remain while granting no run benefit. With the expansion enabled, confirm a callback chapter keeps every recorded account rather than replacing an earlier one.

## Android/offline matrix

- Fresh launch and complete run in airplane mode.
- Background/foreground from every phase.
- Force-stop before pressing Roll, during dice animation, after damage, after victory, and during the death screen.
- Android Back follows the same nested close order as `X`: confirmation, item detail, allocation/action/tutorial/store, inventory, then settings before returning to the menu.
- Small and tall portrait displays at every font scale and within Android safe areas.
- One-handed access to the combat action grid and event choices.
- Red damage, green healing, gold critical success, and red critical failure always include written labels.
- Low storage while writing a prepared roll and resolved result.
- A prepared event or combat roll must resume with the same concealed authoritative result.
- Health reaching zero before the death animation must still persist the death and remove Continue on restart.
- Android backup/device transfer must restore profile/cosmetics but never `active_run.json`.
- Rotate/background during an ad opportunity; never show the missed interstitial later.
- Consent required, not required, refused, previous choice, privacy-options entry point, and UMP error.
- Largest font on candidate, event, result, inventory, checkpoint, combat, tutorial, settings, death, and victory screens.

The ad no-fill, consent, pending/cancelled/restored/refunded-purchase, and store matrices are deferred until a post-launch monetization build deliberately enables and bundles those integrations.

## Release blockers

Any known save loss, dead-run resurrection, duplicated action/reward, progression dead end, crash/ANR, invisible choice, unreadable HUD, or policy-severity defect blocks launch v1. A cosmetic alignment defect may be triaged; core readability and accessibility defects may not. Purchase-loss checks become blocking when monetization is introduced later.

## Combat rules 2 regression and balance

Run `--headless --path . --script tests/layout_ui_smoke.gd` for compact-screen layout: the item sheet, inventory, stat allocation, event roll, the D20 reveal, and death/victory summaries at 360×640, 393×852 and tall 540×1200 in normal and Large text. It has **660 assertions and 0 failures**, and it fails if a scrollable region swallows an action, a touch target drops below 44 pixels, a pinned control falls past the bottom of its sheet, or the inventory loses its filter or scroll position.

Run `--headless --path . --script tests/combat_ui_smoke.gd` for ready/prepared geometry and input recovery at 360×640, 393×852 and 540×1200, three font sizes, palettes and High Contrast. Manual and Quick Roll must produce identical state. Back must not leave a failed-save recovery screen, and no animation input may start a second round.

Run `--headless --path . --script tools/combat_balance.gd` for 72,000 encounters, including a no-Opportunity control. This takes several minutes. Compare HP, wins, ammunition, conditions and victorious fight length; do not infer a full-run victory rate from encounter samples. See [NARRATIVE_COMBAT_REPORT.md](NARRATIVE_COMBAT_REPORT.md) for results and remaining phone/human acceptance gates.

Real-device qualification is pending: ADB found no attached Samsung during this update. Desktop geometry tests and rendered screenshots are not substitutes for phone touch, backgrounding, force-stop and full-run offline checks.
