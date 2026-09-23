# Project status

## M11 balance and full-run verification - 8 September 2026

- Encounter benchmark now covers **all 13 adversaries** with 10 named-stat fixtures across an early 15-point and a progressed 21-point tier, 4 policies, and 5 road states: **586,000** authoritative encounters.
- New `tools/full_run_harness.gd` replays a recorded decision record from its seed to a byte-identical run state and traces regional resources, equipment, XP, encounters, and death. A **1,000-run** seeded legal-action soak produced **0** engine errors and **0** recovery mismatches.
- Encounter, robustness, and human evidence are kept separate and labelled. Random-policy soak results are never quoted as human completion or retention. Full report: [RUN_VERIFICATION.md](RUN_VERIFICATION.md).
- **New release blocker**: `global_stranger` gates every choice behind an item, so a survivor carrying no bandage and no clean water is stranded on a screen of disabled buttons. Found at soak seeds 9103 and 9876; deliberately not repaired by a verification milestone. The data-package audit now fails on it.
- Release readiness is now **8 blockers**: the 7 owner/publishing tasks plus this content defect. *(N04 repaired the content defect; the count is back to the 7 owner/publishing tasks.)*

## M10 data-package audit - 7 September 2026

- New read-only `tools/data_package_audit.gd` verifies the launch configuration in eight checks and exits 1 on any discrepancy. Current result: **8 checks, 8 passed, 0 discrepancies**.
- Confirmed in the actual launch build: the polished prose is what loads, no prohibited or repeated sentences remain, all fifty items have routes, no event exceeds four choices, loading changes no mechanics and no choice index or label, the fifteen callbacks stay disabled, the ten lore chapters are reachable, and nothing references an unknown ID.
- Nine documentation discrepancies were found and fixed, including two documents that still claimed profile schema 4, three player-facing Road Ledger references, and two uses of Guard as current combat terminology.
- No mechanical defect was found, so nothing was returned to an owning mini-plan. Full report: [DATA_PACKAGE_AUDIT.md](DATA_PACKAGE_AUDIT.md).
- Release readiness is unchanged at **7 blockers**, all owner or publishing tasks.

## M09 Road Chronicle update - 7 September 2026

- One title-menu entry, ROAD CHRONICLE, replaces the expansion-gated Road Ledger screen and carries two tabs.
- Runs lists the stored latest twenty summaries with survivor, region reached, level, equipment, strongest defeated enemy, and cause of death. Fields an older summary never captured read "Not recorded" instead of being invented.
- Discoveries exposes the ten reachable Bunker Forty-One, Rust-Sea, and ending chapters. Chapters whose event is not loaded are dropped from the list and from the progress denominator, so the disabled expansion is never advertised; enabling it restores all twenty-five.
- Discovered variants are preserved rather than replaced. Two runs that ended a thread differently are shown as two accounts under one chapter, and chapters are counted separately from accounts.
- Choosing Continue Run opens a dismissible recap derived from the saved run: where it stopped, what it is waiting on, the last choice and outcome, and current conditions.
- Verification: **2,444 regression assertions, 0 failures**; layout **624 assertions, 0 failures**; combat UI **0 layout/input failures**; save-recovery UI **201 assertions, 0 failures**.

## M08 contextual guidance update - 7 September 2026

- The first-run tutorial wall is gone. Seven one-line tips appear at the moment each rule applies, and the full reference stays under Settings → HOW TO PLAY.
- Guidance is a tappable strip beside the page rather than an overlay, so it cannot cover a control; tapping dismisses it, and Settings switches every tip off or resets their progress.
- No tip opens while a die is resolving or a saved roll waits to be revealed. Combat makes room for a visible tip by collapsing the round log's reserved rows and shrinking the portraits, keeping the clue, the windows, and all six actions in place.
- Guidance changes nothing: the event, checkpoint, and combat suites compare the entire run state, RNG included, across showing and dismissing a tip.
- Existing experienced profiles receive no new mandatory tutorial; a pre-schema-5 profile with `tutorial_seen` migrates with all seven tips already dismissed.
- Verification: **2,432 regression assertions, 0 failures**; layout **468 assertions, 0 failures**; combat UI **0 layout/input failures**; save-recovery UI **201 assertions, 0 failures**.

## M07 compact-screen readability update - 7 September 2026

- The item sheet and both run summaries now scroll their content while every action that leaves the screen stays pinned outside the scroll. Stat allocation keeps its permanently visible apply and return actions.
- Dice targets read `ROLL N+` on the event roll screen, the six combat actions, and the prepared roll button, so a target can no longer be mistaken for a quantity.
- Combat groups the enemy clue, the attack windows it opens, and the latest consequence into one block between the dice and the action grid. Player-left/enemy-right and the fixed six-action grid are unchanged.
- Narrative combat fits 360×640 with Large text again: 545px tall inside the 563px available, where it previously measured 596px and pushed its bottom action row off screen. The space came from padding, wrapped lines, and separators; no touch target is below 44px.
- Returning from an item sheet restores the inventory filter and scroll position.
- Verification: new `tests/layout_ui_smoke.gd` **312 assertions, 0 failures** at 360×640, 540×960, and tall 540×1200 in normal and Large text; combat UI **0 layout/input failures**; save-recovery UI **201 assertions, 0 failures**; regression **2,424 assertions, 0 failures**.

## M06 equipment comparison update - 7 September 2026

- The item detail sheet compares the equipped item against the proposed one: neutral damage range, hit chance, attack stat, signature and mastery, armor rating with a sample hit, neutral Block and Dodge, effective stat and approach differences, carry capacity and overweight changes, ammunition needed against ammunition carried, and shield removal or two-handed incompatibility.
- `scripts/domain/equipment_comparison.gd` produces those numbers by equipping the proposed item on a deep copy of the run and reading the ordinary gameplay previews from it. Nothing is recalculated in presentation, and the live run and its RNG are provably untouched.
- Combat state is cleared on the copy, so values are neutral rather than a prediction about the current enemy, and every panel says so. A comparison taken during a fight equals the same comparison taken outside one.
- The comparison scrolls inside the sheet so the equip, use, and drop actions stay reachable.
- Verification: **2,424 regression assertions, 0 failures**; save-recovery UI **201 assertions, 0 failures**; combat UI **0 layout/input failures**.

## M05 equipment routes update - 7 September 2026

- Ten appended choices across `outskirts_market`, `flats_convoy`, `marsh_body`, `industrial_locker`, and `industrial_office` make the previously unreachable equipment obtainable in launch v1. Original choices keep their indices, labels, checks, and rewards, and each event stays unique with four choices.
- Success grants exactly one selected item, with four Rifle Rounds for the Hunting Rifle and three Shotgun Shells for the Flare Gun. Failure costs only Fatigue: 6 in the Flats and Marshes, 8 in the Industrial Zone. Criticals resolve through the same reward with no multiplier.
- `global_drop` now also yields a Climbing Rope, the last item with no launch route and a requirement for one choice in `outskirts_sinkhole` and `marsh_bridge`.
- All **50** defined items have a starting or authored acquisition route, and `validate_all()` now enforces that in every build rather than only with the expansion enabled.
- Verification: **2,396 regression assertions, 0 failures**, including deterministic resolution, critical fallback, failure cost, mutual exclusivity, and restart recovery for each of the ten routes.

## M04 narrative consistency update - 7 September 2026

- All 97 launch events reviewed in nine regional batches against their authoritative items, pressures, conditions, flags, and combat resolution.
- 13 prose-only corrections: a combat critical victory no longer claims a bloodless encounter, new conditions appear through observable symptoms rather than their labels, acquired and lost supplies match each outcome's item list, and a repeatable event no longer assumes an earlier encounter.
- No mechanics, rewards, costs, flags, choice labels, or choice order changed. Second-person present tense and the 60-90/30-50 word targets are preserved.
- Two remaining prose/mechanics mismatches need a mechanical change rather than an edit and are recorded in the queue for M05.
- Verification: **2,262 regression assertions, 0 failures**; word-count, prohibited-filler, and duplicate-sentence checks pass corpus-wide.

## M03 prose activation update - 7 September 2026

- `data/narrative_overrides_v11.json` now loads unconditionally, so all 76 baseline introductions and their outcomes ship with the polished prose. Prose quality no longer depends on the Living Road setting.
- The 15 callback events, their source-flag patches, and the 25-chapter Road Ledger remain gated behind `ashfall/release/living_road_enabled=false`.
- The launch content boundary is unchanged at 97 events, with 372 outcome passages, 138 checked choices, and 11 combat choices. No mechanics, rewards, costs, flags, or choice orders changed.
- Mechanical equality re-verified before any M05 equipment-route work: stripping prose from the live launch records reproduces `data/events.json` exactly for every baseline event.
- Verification: **2,262 regression assertions, 0 failures**. No new Android export or physical-device verification was performed for M03.

## M02 save consistency update - 7 September 2026

- Shared save-aware transactions now cover event preparation/resolution, combat, equipment, consumables/treatment, travel, checkpoint decisions, and confirmed stat allocation. Failed preparations restore the full state/RNG; failed commits retain the result and block actions/Back behind Retry.
- Inventory/allocation refresh and dice/result presentation occur only after commitment. Immediate-action intents survive process restart without duplicate allocation, food, rewards, or XP.
- Atomic profile-only receipts preserve discoveries and completed-run summaries before terminal cleanup, replay idempotently at startup, and preserve death-marker precedence. Receipts contain no restorable living run.
- Profile schema 5 adds contextual tip progress and processed receipt IDs; legacy tutorial-seen profiles dismiss the seven current tips. M08 added the `contextual_tips_enabled` preference on the same schema and built the prompt UI. Run schema stays 5; gameplay and release flags are unchanged.
- Verification: **2,259 regression assertions, 0 failures**; **201 save-recovery UI assertions, 0 failures**; existing combat layout/input smoke tests report **0 failures**. No new Android export or physical-device verification was performed for M02.
- Required later-UI calling conventions and crash/retry evidence: [SAVE_TRANSACTIONS.md](SAVE_TRANSACTIONS.md). Next ready task: M12 in [IMPLEMENTATION_QUEUE.md](IMPLEMENTATION_QUEUE.md).

## Complete in this repository

- Godot 4.7.2 Compatibility project with a portrait 540 × 960 design viewport.
- Full deterministic journey loop: survivor selection, 6 regions × 5 drawn events, checkpoints, and 3-stage finale.
- Data-driven definitions for regions, events, choices, outcomes, items, adversaries, combat profiles, and conditions.
- Stat-and-percentage event checks with an exact visible D20 target before rolling, explicit roll-versus-target results, concealed persisted rolls, and automatic natural 1/natural 20 behavior.
- Hybrid run-only XP progression: steady journey/checkpoint XP, difficulty bonuses, authored enemy rewards, Level 1–8 thresholds, atomic checkpoint allocation, and carry-forward points.
- Grit-based threshold hearts, partial heart display, exact HP, four-icon satiety, starvation, Fatigue, and Radiation.
- Multi-round cinematic portrait combat with Attack, Block, Dodge, combat consumables, fleeing, Opportunities, a central prepared D20, animated HP meters, armor-block feedback, status chips, a full-width actor-aligned damage feed, distinct critical typography, ammunition, and weapon damage ranges.
- Guaranteed regional supply and combat opportunities, a two-combat-opportunity regional ceiling, and a checkpoint tradeoff between a food-consuming full-Fatigue rest or one-check Momentum from pressing onward.
- Weight, equipment, consumables, conditions, travel, rest, strict permadeath, and victory. A dedicated Status sheet separates harmful and helpful effects, shows exact modifiers and remaining duration, identifies carried/missing remedies, and permits safe direct treatment outside combat.
- One active JSON run, atomic replacement, backup recovery, schema-5 combat migration (including prior XP migrations), idempotent XP award IDs, save-aware gameplay transactions, versioned prepared-roll recovery, death marker, and schema-5 profile with Manual/Quick Roll, contextual tip progress, recoverable discovery/summary receipts, history, settings, and cached entitlements.
- Layered Dossier journey HUD: portrait/identity, heart and food vitals, a tappable five-symbol stat capsule, a persistent Fatigue/Radiation strip, quiet Inventory link, and compact Settings gear.
- Responsive portrait UI for menu, candidates, title-free journey prose, typewritten outcomes with swipe-only story scrolling, icon-first inventory, item details, checkpoint allocation with an always-visible top action panel, combat, death/victory, tutorial, compact settings, store catalog, and privacy summary.
- Configurable Slow/Normal/Fast/Instant story reveal, punctuation pauses, double-tap skip, choice fade-in, reduced-motion bypass, and session-cached reveal progress beneath overlays.
- Four equipment slots, five icon-rail inventory filters, three/four-column responsive item grid, fixed capacity footer, distinct tinted item-rune placeholders, equip replacement, unequip, use, confirmed Drop One/Drop All, overweight feedback, and immediate action autosaves.
- Seven portrait backgrounds, four packaged survivor portraits (including a temporary same-ID fourth-survivor placeholder), crop-to-fill portrait framing, vector app icon, locally bundled OFL-licensed Literata/Inter fonts, generated UI sounds, optional haptics, high contrast, large text, and reduced motion.
- Centralized visual palettes: Ember & Parchment (default), Cinder Rust, and Signal at Night, with semantic HUD/combat/inventory/dice colours and a separate High Contrast override. See `docs/UI_STYLE_GUIDE.md`.
- Android debug and release export presets; Android 12+ and legacy backup-rule resources exclude active-run files.
- Explicitly disabled launch-v1 advertising and billing boundaries plus a deferred, type-checked TypeScript purchase-verification function.
- Guided first-region opening: the first event is non-combat and the first two events introduce both resource and equipment decisions across deterministic seeds.
- Permadeath summaries record fatal context, final conditions, and equipped loadout so a loss teaches the next run.
- Repeatable balance-report and release-readiness tools, four-week sprint board, closed-tester guide, feedback form, and exact release gate.
- Base content plus the thirteen-scene, branching Bunker Forty-One arc and the first eight-scene Rust-Sea/Mara Venn expansion: 97 validated events in the v1 content boundary. All 76 bespoke baseline rewrites are active without mechanical changes.
- The complete Living Road v1.1 package is implemented behind `ashfall/release/living_road_enabled=false`: 15 cross-region callback events across five recurring-human threads, ten previously unavailable equipment reward routes, and the 15 callback chapters of the 25-chapter non-power Road Chronicle. The other ten chapters ship in v1. The authoring package contains 20,562 words across 473 rewritten or new passages.
- Mechanical snapshot validation proves the launch prose layer leaves every baseline rule, requirement, reward, cost, flag, and choice order unchanged. Expansion validation rejects repeated filler, duplicate long sentences, unreachable callback flags, multiple callbacks per region, missing callback exits, invalid Ledger variants, and unobtainable items.
- Automated domain/content/save/UI/responsive/typewriter/inventory/balance/prose/palette/experience/Living Road suite. Current result: 2,469 assertions, 0 failures; separate save-recovery UI suite: 201 assertions, 0 failures.
- API-36, arm64 debug APK generated at `builds/android/ashfall-road-debug.apk` and verified with Android APK Signature Schemes v2 and v3.

## Narrative combat update — 7 September 2026

- All 13 enemy sequences, all 12 weapon signatures/mastery, shields, Smoke escape, full-stat odds and saved Opportunities are implemented. Existing active fights finish under legacy rules.
- Save-aware combat transactions restore RNG after failed preparation and block input/presentation until a resolved round or death marker is safely committed.
- Separate armor/defense/suppression/exposure reporting; six-action responsive UI, inspectable tells, instant actor-aligned narration, named combat windows and compact portrait framing.
- 2,037 assertions pass. Separate ready/prepared layout and input tests pass at 360×640, 540×960 and 540×1200 across three font sizes, palettes and High Contrast; Manual/Quick equivalence and reduced motion are verified.
- 72,000 seeded encounters completed. Behavior-aware policies outperform Attack-only in relevant matchups, including a control with Opportunities disabled. Some under-equipped boss fights exceed the intended length; human balance remains a release gate.
- ADB currently detects no attached phone. Desktop rendered screenshots were inspected; Samsung installation, real-device interruption tests and airplane-mode play are still pending.
- Detailed methods, results, file contracts and the deliberate cache/locker shield reward changes: [NARRATIVE_COMBAT_REPORT.md](NARRATIVE_COMBAT_REPORT.md).

## Installed on this PC

- Godot 4.7.2 Standard: `C:\Users\ASUS\Applications\Godot-4.7.2`.
- Matching export templates in the Godot user template directory.
- Android Studio Quail 3 Patch 1.
- Temurin OpenJDK 17.0.20.1.
- Android SDK Platforms 35 and 36, Build-Tools 35.0.1/36.0.0, command-line tools 23.0, Platform-Tools/ADB 37.0.1, NDK r28b, and CMake 3.10.2.
- Samsung SM-G991B was previously authorized for USB debugging; reconnect it to install the latest debug build.

## Remaining release work

- Choose the permanent reverse-domain package name before the first Play upload; `com.yourstudio.ashfallroad` remains a placeholder.
- Replace placeholder glyphs and silhouettes with final licensed art while retaining the stable asset IDs.
- Keep the Living Road project setting disabled for v1; enable it only in the planned v1.1 closed-track build after launch stability is established.
- Complete human combat balance, accessibility, low-end-device, and interruption testing.
- Generate and securely back up the release upload key. Keystore secrets must never be committed.
- Complete closed-test, policy, store-listing, and asset-licensing work.
- Produce the 512x512 icon, 1024x500 feature graphic, and real-device screenshots required by the release gate.
- Recruit at least 12 continuously opted-in closed testers for 14 days; recruit 15–20 to keep a buffer.

Post-launch only: isolate and pin compatible AdMob/UMP and Google Play Billing plugins, create products/backend resources, update privacy and Data Safety declarations, then deliberately enable the monetization flag.

The project is a substantial playable implementation, not a production-certified release. Follow `LAUNCH_SPRINT.md` and `RELEASE_CHECKLIST.md`; do not enable ads or payments in version 1.
