# Testing

## Automated headless suite

Run the suite with the Godot 4.7.2 console executable from the project root:

`C:\Users\ASUS\Applications\Godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/test_runner.gd`

The current suite has 147 assertions. It validates content references and budgets, natural 1/20 behavior, exact odds, equal-budget candidates, inventory weight, pressure clamping, ammunition, temporary conditions, deterministic seeds, prepared-roll recovery, complete-run progression, save restoration, profile persistence, verified entitlement persistence, and death-marker enforcement.

Also parse/start the real scene with:

`C:\Users\ASUS\Applications\Godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --quit-after 5`

The Windows sandbox used during development may print a root-certificate-store warning. It is unrelated to gameplay and the test process still exits successfully; investigate it before enabling HTTPS monetization calls.

## Manual desktop checks

1. Start a new run and compare all three candidate totals.
2. Confirm every event choice displays its stat, modifier, DC, and exact percentage.
3. Close and reopen during an event, result, checkpoint, and inventory action.
4. Die, restart, and confirm Continue never returns the dead survivor.
5. Reach a checkpoint, rest with food, and verify the stated meter changes.
6. Equip each item category and test overweight Agility penalties.
7. Increase font size and enable high contrast on every core screen.
8. Fire a ranged weapon until empty and confirm its bonus disappears.
9. Use a stimulant and confirm Steady Hands applies to two checks only.
10. Confirm the tutorial appears once and remains available from Settings.
11. Complete three fixed-seed runs twice with identical choices and compare every event/roll/outcome.

## Android/offline matrix

- Fresh launch in airplane mode.
- Complete run in airplane mode.
- Background/foreground from every phase.
- Force-stop after a roll and during the death screen.
- Android Back closes popups before returning to the menu.
- Small and tall portrait displays at every font scale.
- Ad no-fill and disconnected billing never delay gameplay.
- Pending, cancelled, restored, duplicated, and refunded purchases once Play integration is configured.
- Low storage while writing the prepared roll and resolved result.
- Kill the process immediately before and after tapping a choice; restart must resolve the same persisted roll once.
- Kill the process after Health reaches zero but before the death screen; restart must record death and offer no Continue.
- Android backup/device transfer must restore profile/cosmetics but never `active_run.json`.
- Rotate/background during an ad opportunity; never show the missed interstitial later.
- Consent required, not required, refused, previous choice, privacy-options entry point, and UMP error.
- Largest font on candidate, event, result, inventory, checkpoint, tutorial, settings, store, death, and victory screens.

## Release blockers

Any known save loss, dead-run resurrection, duplicated reward, verified-purchase loss, progression dead end, crash/ANR, invisible choice, or policy-severity defect blocks release. A known cosmetic alignment defect may be triaged; a core readability or accessibility defect may not.
