# Narrative combat: implementation and balance report

Date: 7 September 2026. Combat rules 2; active-run schema 5; profile schema 5; D20 rules 3; experience rules 1.

## Implemented

- Attack hit/miss odds and exact D20 targets; successful-face damage mapping.
- Full effective-stat calculation shared by previews and resolution.
- Block, Dodge, next-action Riposte/Opening, conditional critical injuries, armor-first failure penalties.
- All 13 authored enemy sequences and literary tells, committed before input.
- All 12 weapon signatures, base-stat-six mastery, two-handed compatibility.
- Scrap Buckler and Road Shield, stable placeholder icons, starting/cache/locker routes.
- Once-per-fight Opportunities with saved pity rolls, no timer, and normal ammunition costs.
- Combat Smoke Bomb escape, usefulness-sorted consumables, unchanged journey/XP rules.
- Six stable action positions; inspectable tells and effects; player-left/enemy-right feed.
- Authored family/move/result narration, frozen variants, no immediate repetition.
- Manual/Quick Roll share the same prepare/save/resolve/save flow.
- Transactional retry and full preparation rollback, including RNG; Back cannot bypass recovery.
- Legacy fights retain their original actions, dice, stats, damage and critical behavior until they end. Their mitigation labels now distinguish armor from Guard without changing damage.

## Combat contracts

Enemy content stays in `data/adversaries.json`: `narrative_combat.organic`, ordered `sequence`, and per-move `tells`. Shared multipliers and three narration variants per move live in `data/combat_content.json`.

Weapons retain their original damage/ammunition definitions and add `signature`, `two_handed`, and `opportunity_name`. Signatures use base run stats for mastery but effective stats for actual accuracy and damage. The raw weapon multiplier and applicable bonuses are combined before the displayed damage range is rounded.

`GameEngine.combat_action_preview()` returns availability, lock reason, percentage, required face, range, cost, modifiers and effects. UI code does not decide outcomes. The prepared snapshot freezes the move, enemy definition, profile/damage inputs, armor, rolls, chance, opportunity roll and narration selections.

`CombatTransaction` rolls back the complete run after a failed preparation save. A failed resolution save retains the resolved result in memory; Retry writes that result without another resolution. Death is secured with its marker before presentation. A full restart before a successful commit recovers the already-prepared snapshot and deterministically replays it once, not a fresh roll. Atomic saves check write errors and read back the temporary file before rotating a known-good save.

Only a new encounter receives rules 2. Migration does not apply new signatures, move sequences or defenses to an in-flight legacy fight. Profile migration defaults to Manual Roll; only `manual` and `quick` are accepted.

## Deliberate mechanical content changes

- Add `scrap_buckler` and `road_shield`: item count 48 → 50.
- Add Scrap Buckler to Grit-led starting equipment.
- Append a mutually exclusive certain buckler choice to `outskirts_cache`; existing choices keep their indices and rewards.
- Add Road Shield to `industrial_locker` choice 0 success, retaining gloves and bandage.
- Update corresponding v1/v1.1 prose overrides without enabling Living Road.
- Existing adversary HP, authored damage ranges and XP rewards are unchanged.
- `tests/fixtures/combat_v2_content_contract.json` locks the new weapon/shield/sequence contracts and preserved enemy combat values.
- Run length, supply selection, XP curve, permadeath, monetization and story-chain flags are unchanged.

## Automated verification

Latest verification: **2,262 assertions, zero failures**, and **zero combat layout/input failures**. The Android debug APK was exported and its signature verified successfully at `builds/android/ashfall-road-debug.apk`. Development builds, tests and tools are excluded from the export. ADB currently reports no connected device, so this is a built APK, not a Samsung installation or physical-device acceptance result.

The combined regression suite covers legacy combat separately from the new rules. New coverage checks exact successful faces, additive damage, armor tables, benefit expiry, condition prevention, weapon/mastery thresholds, ammunition on misses, committed moves, no-repeat narration, opportunities, duplicate-source protection, actual JSON recovery, schema migration and failed write/death-marker retries.

`tests/combat_ui_smoke.gd` exercises 360×640, 540×960 and 540×1200 layouts at Small/Normal/Large text, both ready and prepared states, theme palettes and High Contrast. It also verifies reduced-motion health, Manual versus Quick results, input locking, save retries and Back behavior. OpenGL-rendered screenshots were inspected locally; they are in `builds/combat-*.png`.

Commands (from project root; use the installed Godot console executable):

- `--headless --path . --script tests/test_runner.gd`
- `--headless --path . --script tests/combat_ui_smoke.gd`
- `--headless --path . --script tools/combat_balance.gd`
- Optional rendered QA: `--path . --rendering-method gl_compatibility --script tests/combat_ui_smoke.gd -- --screenshots`

## Simulation methodology

84,000 authoritative encounters: 3 prototype enemies × 7 representative builds × 4 policies × 1,000 seeds. No forced successful dice. The same engine used by the game calculates ammunition, damage, conditions, fatigue, opportunities, victory and XP. `builds/combat_balance.json` records fixture-version-2 metadata alongside every result, including named base stats, budgets, weapon attack stat, mastery, compatibility, ammunition, and starting HP.

Policies:
- **Attack-only:** never defend or use an Opportunity.
- **Repeat-defense:** repeatedly choose the lower expected-damage Block/Dodge, without attacking.
- **Read tells:** defend Heavy/Sweep when there is no banked attack window, exploit other moves, take likely killing blows, and use a ready Opportunity.
- **Read tells, no Opportunity:** the same policy with the Opportunity disabled for the entire encounter. This separates benefits of reading tells from the bonus attack.

Fixtures start at full Grit-based HP and no survival strain. Five profiles have 15 base-stat points; the two 21-point rifle comparisons are deliberately distinct: **Agile Rifle** has Strength 3, Agility 8, Wits 3, Grit 5, Presence 2 and is **not mastered**; **Mastered Rifle** has Strength 3, Agility 3, Wits 8, Grit 5, Presence 2 and is mastered. This corrects the former misleading `master_rifle` label, which actually described the former build. Stats/equipment are specified in `tools/combat_balance.gd`. Fixtures carry 12 of each ammunition type, two medkits and two smoke bombs, but policies do not use items or flee. Weight penalties remain active. These are controlled loadout comparisons, not exact starting inventories or full-run survival estimates. The simple policies are not an optimal solver and do not time every signature optimally.

A 60-exchange limit flags stalls. “HP spent” includes losses in failed encounters and is capped by starting HP; “conditions” counts unique conditions remaining at encounter end, not every application. Victory exchange averages exclude losses. This avoids interpreting early deaths as fast, well-paced victories.

### Comparison

| Enemy | Build | Attack wins | Read-tells wins | No-Opportunity wins | Read-tells mean HP spent | Read-tells rounds when won |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| feral_dogs | cleaver | 100.0% | 100.0% | 100.0% | 36.2 | 3.5 |
| feral_dogs | pistol | 100.0% | 100.0% | 100.0% | 34.1 | 3.4 |
| feral_dogs | probe | 100.0% | 100.0% | 100.0% | 57.4 | 4.1 |
| feral_dogs | buckler_counter | 100.0% | 100.0% | 100.0% | 33.1 | 3.8 |
| feral_dogs | revolver | 100.0% | 100.0% | 100.0% | 51.1 | 3.6 |
| feral_dogs | agile_rifle (unmastered) | 100.0% | 100.0% | 100.0% | 32.2 | 2.8 |
| feral_dogs | mastered_rifle (Wits 8) | 100.0% | 100.0% | 100.0% | 25.2 | 2.2 |
| road_bandits | cleaver | 100.0% | 100.0% | 99.8% | 84.0 | 5.1 |
| road_bandits | pistol | 99.0% | 99.9% | 99.7% | 87.9 | 5.0 |
| road_bandits | probe | 94.7% | 97.2% | 94.4% | 139.5 | 6.0 |
| road_bandits | buckler_counter | 100.0% | 100.0% | 100.0% | 79.7 | 5.5 |
| road_bandits | revolver | 97.0% | 98.6% | 96.7% | 115.3 | 5.2 |
| road_bandits | agile_rifle (unmastered) | 100.0% | 100.0% | 100.0% | 73.1 | 4.0 |
| road_bandits | mastered_rifle (Wits 8) | 100.0% | 100.0% | 100.0% | 64.6 | 3.3 |
| warden_machine | cleaver | 0.0% | 29.4% | 22.8% | 261.5 | 13.4 |
| warden_machine | pistol | 0.0% | 63.6% | 57.3% | 201.7 | 14.0 |
| warden_machine | probe | 1.5% | 11.7% | 7.9% | 284.2 | 18.1 |
| warden_machine | buckler_counter | 1.4% | 48.9% | 41.2% | 309.9 | 14.7 |
| warden_machine | revolver | 0.0% | 17.9% | 12.6% | 276.4 | 14.8 |
| warden_machine | agile_rifle (unmastered) | 14.4% | 89.2% | 84.7% | 167.5 | 9.6 |
| warden_machine | mastered_rifle (Wits 8) | 49.3% | 92.1% | 86.8% | 156.0 | 7.6 |

### Findings and remaining tuning

- Reading Heavy/Sweep tells is materially useful in relevant matchups, even when no Opportunity can occur.
- The old `master_rifle` rows are now correctly labelled **agile_rifle (unmastered)**: its Wits is 3, so its Warden comparison improves from 14.4% Attack-only wins to 84.7% without Opportunities, or 89.2% with them. That result is about equipment, defence, and the 21-point fixture—not Wits mastery.
- The genuine **mastered_rifle (Wits 8)** comparison improves from 49.3% Attack-only wins to 86.8% without Opportunities, or 92.1% with them. This is a benchmark correction, not a gameplay balance change.
- All repeated-defense policies produced zero victories. Some low-threat fights survived to the 60-exchange cap; this is stalling, not an infinite guaranteed-safe loop. Defense chances remain capped and fatigue accumulates.
- Dogs often take roughly 3–4 exchanges with good gear, shorter than the generic 4–6 matched-fight target; they are the weak-enemy benchmark.
- Bandit fights generally sit closer to the ordinary pacing target.
- The unmastered agile rifle's successful Warden fights average 9.6 exchanges with Opportunities and 11.0 without. The genuine mastered rifle averages 7.6 with Opportunities and 8.5 without; it reaches the lower edge or slightly below the intended 8–12 major-fight pacing range and should inform later tuning, not this fixture-only task.
- Several starting-equipment Warden victories take 13–19 exchanges. This remains a tuning/playtest concern, not a claim that every build meets the 8–12 target.
- No single simulated build proves universal dominance: the full journey adds resource depletion, ammunition availability, loot constraints and other enemy sequences.
- No overall 3–5% run-win rate has been established. These encounter samples cannot measure full-run retention or human learning.
- Do not reduce boss HP globally based on these isolated fixtures. First collect human runs, particularly Block-counter and low-damage disruption builds; distinguish under-equipment from tedious matched combat.

## Physical-device release gate

ADB reported no attached device during this implementation. The debug APK exports and signs, but this is **not** a completed Samsung acceptance pass.

Before release:
- Reconnect/authorize the Samsung; install the latest debug APK without deleting the existing run.
- Resume a legacy fight and confirm it stays legacy; begin a new fight and confirm the six-action layout.
- Test all fonts, normal/Quick Roll, reduced motion, item sheets, tell inspection, status chips and Android Back.
- Airplane-mode launch, full run, backgrounding during dice, force-close before/after damage, victory and death.
- Observe fresh testers explaining a Heavy/Sweep tell and why they chose Block or Dodge.
- Review ordinary fight length and high-Grit counter builds in real resource-depleted runs.

## Full simulation measurements

Each row contains 1,000 encounters. Raw totals also exist in `builds/combat_balance.json`; values here are normalized per encounter except wins and stalls.

| Enemy | Build | Policy | Wins | Mean HP spent | Mean ammo spent | Mean final conditions | Mean exchanges (all outcomes) | 60-round stalls |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| feral_dogs | cleaver | attack_only | 1000 | 39.93 | 0.00 | 0.089 | 3.05 | 0 |
| feral_dogs | cleaver | repeat_defense | 0 | 299.94 | 0.00 | 0.690 | 35.88 | 3 |
| feral_dogs | cleaver | read_tells | 1000 | 36.18 | 0.00 | 0.082 | 3.52 | 0 |
| feral_dogs | pistol | attack_only | 1000 | 62.19 | 3.33 | 0.103 | 3.33 | 0 |
| feral_dogs | pistol | repeat_defense | 0 | 246.77 | 0.00 | 0.342 | 55.79 | 609 |
| feral_dogs | pistol | read_tells | 1000 | 34.15 | 2.39 | 0.061 | 3.42 | 0 |
| feral_dogs | probe | attack_only | 1000 | 71.89 | 0.00 | 0.098 | 3.87 | 0 |
| feral_dogs | probe | repeat_defense | 0 | 299.86 | 0.00 | 0.344 | 30.25 | 2 |
| feral_dogs | probe | read_tells | 1000 | 57.40 | 0.00 | 0.084 | 4.13 | 0 |
| feral_dogs | buckler_counter | attack_only | 1000 | 39.52 | 0.00 | 0.111 | 3.63 | 0 |
| feral_dogs | buckler_counter | repeat_defense | 0 | 379.89 | 0.00 | 0.930 | 54.32 | 368 |
| feral_dogs | buckler_counter | read_tells | 1000 | 33.09 | 0.00 | 0.137 | 3.84 | 0 |
| feral_dogs | revolver | attack_only | 1000 | 63.21 | 3.18 | 0.096 | 3.18 | 0 |
| feral_dogs | revolver | repeat_defense | 0 | 300.00 | 0.00 | 0.351 | 26.66 | 0 |
| feral_dogs | revolver | read_tells | 1000 | 51.07 | 2.59 | 0.077 | 3.60 | 0 |
| feral_dogs | agile_rifle (unmastered) | attack_only | 1000 | 41.61 | 2.83 | 0.079 | 2.83 | 0 |
| feral_dogs | agile_rifle (unmastered) | repeat_defense | 0 | 258.77 | 0.00 | 0.406 | 59.74 | 955 |
| feral_dogs | agile_rifle (unmastered) | read_tells | 1000 | 32.24 | 2.45 | 0.064 | 2.76 | 0 |
| road_bandits | cleaver | attack_only | 1000 | 108.92 | 0.00 | 0.158 | 4.94 | 0 |
| road_bandits | cleaver | repeat_defense | 0 | 300.00 | 0.00 | 0.614 | 23.37 | 0 |
| road_bandits | cleaver | read_tells | 1000 | 83.95 | 0.00 | 0.136 | 5.09 | 0 |
| road_bandits | pistol | attack_only | 990 | 150.30 | 5.23 | 0.170 | 5.23 | 0 |
| road_bandits | pistol | repeat_defense | 0 | 290.04 | 0.00 | 0.300 | 43.34 | 146 |
| road_bandits | pistol | read_tells | 999 | 87.87 | 3.98 | 0.119 | 5.03 | 0 |
| road_bandits | probe | attack_only | 947 | 163.48 | 0.00 | 0.164 | 5.83 | 0 |
| road_bandits | probe | repeat_defense | 0 | 300.00 | 0.00 | 0.262 | 20.84 | 0 |
| road_bandits | probe | read_tells | 972 | 139.47 | 0.00 | 0.152 | 6.07 | 0 |
| road_bandits | buckler_counter | attack_only | 1000 | 98.16 | 0.00 | 0.177 | 5.50 | 0 |
| road_bandits | buckler_counter | repeat_defense | 0 | 398.98 | 0.00 | 0.875 | 38.71 | 17 |
| road_bandits | buckler_counter | read_tells | 1000 | 79.66 | 0.00 | 0.195 | 5.53 | 0 |
| road_bandits | revolver | attack_only | 970 | 151.40 | 5.09 | 0.161 | 5.09 | 0 |
| road_bandits | revolver | repeat_defense | 0 | 300.00 | 0.00 | 0.263 | 18.21 | 0 |
| road_bandits | revolver | read_tells | 986 | 115.31 | 4.18 | 0.134 | 5.24 | 0 |
| road_bandits | agile_rifle (unmastered) | attack_only | 1000 | 96.61 | 4.09 | 0.139 | 4.09 | 0 |
| road_bandits | agile_rifle (unmastered) | repeat_defense | 0 | 361.70 | 0.00 | 0.416 | 52.89 | 416 |
| road_bandits | agile_rifle (unmastered) | read_tells | 1000 | 73.09 | 3.45 | 0.110 | 3.95 | 0 |
| warden_machine | cleaver | attack_only | 0 | 300.00 | 0.00 | 0.099 | 5.99 | 0 |
| warden_machine | cleaver | repeat_defense | 0 | 300.00 | 0.00 | 0.175 | 12.21 | 0 |
| warden_machine | cleaver | read_tells | 294 | 261.46 | 0.00 | 0.145 | 10.61 | 0 |
| warden_machine | pistol | attack_only | 0 | 300.00 | 5.58 | 0.075 | 5.58 | 0 |
| warden_machine | pistol | repeat_defense | 0 | 300.00 | 0.00 | 0.101 | 19.81 | 0 |
| warden_machine | pistol | read_tells | 636 | 201.70 | 6.97 | 0.061 | 12.78 | 0 |
| warden_machine | probe | attack_only | 15 | 298.81 | 0.00 | 0.061 | 6.16 | 0 |
| warden_machine | probe | repeat_defense | 0 | 300.00 | 0.00 | 0.131 | 11.19 | 0 |
| warden_machine | probe | read_tells | 117 | 284.19 | 0.00 | 0.124 | 10.61 | 0 |
| warden_machine | buckler_counter | attack_only | 14 | 399.61 | 0.00 | 0.145 | 8.68 | 0 |
| warden_machine | buckler_counter | repeat_defense | 0 | 400.00 | 0.00 | 0.374 | 17.49 | 1 |
| warden_machine | buckler_counter | read_tells | 489 | 309.92 | 0.00 | 0.297 | 13.30 | 0 |
| warden_machine | revolver | attack_only | 0 | 300.00 | 5.06 | 0.071 | 5.06 | 0 |
| warden_machine | revolver | repeat_defense | 0 | 300.00 | 0.00 | 0.126 | 10.48 | 0 |
| warden_machine | revolver | read_tells | 179 | 276.37 | 5.00 | 0.112 | 9.64 | 0 |
| warden_machine | agile_rifle (unmastered) | attack_only | 144 | 388.41 | 6.43 | 0.099 | 6.43 | 0 |
| warden_machine | agile_rifle (unmastered) | repeat_defense | 0 | 399.94 | 0.00 | 0.309 | 23.79 | 5 |
| warden_machine | agile_rifle (unmastered) | read_tells | 892 | 167.49 | 5.59 | 0.128 | 9.59 | 0 |
| feral_dogs | cleaver | read_tells_no_opportunity | 1000 | 37.74 | 0.00 | 0.088 | 3.67 | 0 |
| feral_dogs | pistol | read_tells_no_opportunity | 1000 | 35.87 | 2.52 | 0.065 | 3.57 | 0 |
| feral_dogs | probe | read_tells_no_opportunity | 1000 | 63.66 | 0.00 | 0.098 | 4.55 | 0 |
| feral_dogs | buckler_counter | read_tells_no_opportunity | 1000 | 35.51 | 0.00 | 0.151 | 4.09 | 0 |
| feral_dogs | revolver | read_tells_no_opportunity | 1000 | 54.04 | 2.74 | 0.085 | 3.78 | 0 |
| feral_dogs | agile_rifle (unmastered) | read_tells_no_opportunity | 1000 | 32.98 | 2.51 | 0.066 | 2.83 | 0 |
| road_bandits | cleaver | read_tells_no_opportunity | 998 | 94.15 | 0.00 | 0.146 | 5.75 | 0 |
| road_bandits | pistol | read_tells_no_opportunity | 997 | 99.33 | 4.53 | 0.130 | 5.62 | 0 |
| road_bandits | probe | read_tells_no_opportunity | 944 | 163.05 | 0.00 | 0.176 | 6.93 | 0 |
| road_bandits | buckler_counter | read_tells_no_opportunity | 1000 | 90.77 | 0.00 | 0.210 | 6.33 | 0 |
| road_bandits | revolver | read_tells_no_opportunity | 967 | 131.37 | 4.84 | 0.152 | 5.96 | 0 |
| road_bandits | agile_rifle (unmastered) | read_tells_no_opportunity | 1000 | 77.03 | 3.67 | 0.125 | 4.22 | 0 |
| warden_machine | cleaver | read_tells_no_opportunity | 228 | 270.89 | 0.00 | 0.163 | 10.94 | 0 |
| warden_machine | pistol | read_tells_no_opportunity | 573 | 216.33 | 7.33 | 0.079 | 13.60 | 0 |
| warden_machine | probe | read_tells_no_opportunity | 79 | 290.08 | 0.00 | 0.125 | 10.75 | 0 |
| warden_machine | buckler_counter | read_tells_no_opportunity | 412 | 325.67 | 0.00 | 0.321 | 13.90 | 0 |
| warden_machine | revolver | read_tells_no_opportunity | 126 | 282.85 | 5.02 | 0.118 | 9.81 | 0 |
| warden_machine | agile_rifle (unmastered) | read_tells_no_opportunity | 847 | 194.72 | 6.26 | 0.159 | 10.93 | 0 |

### Genuine mastered-rifle correction measurements

These 12 rows are the newly added named fixture: Strength 3, Agility 3, Wits 8, Grit 5, Presence 2; Hunting Rifle; Scout Leathers; 400 starting HP; 12 Rifle Rounds; mastery enabled. They are reported separately from the preserved **agile_rifle (unmastered)** rows above so no historical result is relabelled as mastery.

| Enemy | Build | Policy | Wins | Mean HP spent | Mean ammo spent | Mean final conditions | Mean exchanges (all outcomes) | 60-round stalls |
| --- | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| feral_dogs | mastered_rifle (Wits 8) | attack_only | 1000 | 28.72 | 2.24 | 0.053 | 2.24 | 0 |
| feral_dogs | mastered_rifle (Wits 8) | repeat_defense | 0 | 358.71 | 0.00 | 0.495 | 55.88 | 493 |
| feral_dogs | mastered_rifle (Wits 8) | read_tells | 1000 | 25.20 | 2.04 | 0.048 | 2.24 | 0 |
| feral_dogs | mastered_rifle (Wits 8) | read_tells_no_opportunity | 1000 | 25.45 | 2.06 | 0.049 | 2.26 | 0 |
| road_bandits | mastered_rifle (Wits 8) | attack_only | 1000 | 74.11 | 3.38 | 0.110 | 3.38 | 0 |
| road_bandits | mastered_rifle (Wits 8) | repeat_defense | 0 | 397.28 | 0.00 | 0.417 | 40.99 | 43 |
| road_bandits | mastered_rifle (Wits 8) | read_tells | 1000 | 64.55 | 3.05 | 0.099 | 3.32 | 0 |
| road_bandits | mastered_rifle (Wits 8) | read_tells_no_opportunity | 1000 | 67.25 | 3.19 | 0.104 | 3.46 | 0 |
| warden_machine | mastered_rifle (Wits 8) | attack_only | 493 | 340.18 | 6.08 | 0.099 | 6.08 | 0 |
| warden_machine | mastered_rifle (Wits 8) | repeat_defense | 0 | 400.00 | 0.00 | 0.274 | 19.26 | 0 |
| warden_machine | mastered_rifle (Wits 8) | read_tells | 921 | 156.02 | 4.55 | 0.109 | 7.61 | 0 |
| warden_machine | mastered_rifle (Wits 8) | read_tells_no_opportunity | 868 | 176.73 | 5.00 | 0.117 | 8.54 | 0 |
