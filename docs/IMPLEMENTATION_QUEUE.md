# Ashfall Road implementation queue

Status: M00 through M11 complete; M12 is next. The release blocker M11 found was repaired by N04, so the remaining 7 are all owner or publishing tasks. The narrative expansion that supersedes the disabled-callback and short-prose boundaries runs from [NARRATIVE_REFINEMENT_QUEUE.md](NARRATIVE_REFINEMENT_QUEUE.md) under [NARRATIVE_REFINEMENT_PLAN.md](NARRATIVE_REFINEMENT_PLAN.md); N00 is complete there.

This file is the handoff point for the model-by-model improvement plan in [`IMPLEMENTATION_PLAN.md`](IMPLEMENTATION_PLAN.md). It records repository facts, not intended future work. No gameplay implementation was performed by M00.

## Current baseline

| Area | Verified baseline | Evidence |
|---|---|---|
| Automated suite | **2,469 assertions, 0 failures** (M11); 2,444 at M09, 2,432 at M08, 2,424 at M06/M07, 2,396 at M05, 2,037 at the original baseline | `builds/m11-tests.log`, `builds/m09-tests.log`, `docs/SAVE_TRANSACTIONS.md` |
| Save-recovery UI | **201 assertions, 0 failures** at compact, design, and tall portrait sizes with Large text | `builds/m07-action-ui.log`, `tests/action_ui_smoke.gd` |
| Compact-screen layout | **660 assertions, 0 failures** at 360×640, 393×852, and tall 540×1200 in normal and Large text, including contextual guidance and the Road Chronicle | `builds/m09-layout-ui.log`, `tests/layout_ui_smoke.gd` |
| Combat UI smoke tests | 0 layout/input failures across 360×640, 393×852, 540×1200, font sizes, palettes, and High Contrast | `builds/m07-combat-ui.log`, `docs/NARRATIVE_COMBAT_REPORT.md` |
| Encounter simulation | **666,000** authoritative seeded encounters across all 15 adversaries (the Reed Widow and Kilnback joined the roster in N05b), 10 named-stat builds, 4 policies, and 5 road states; fixture version 3 | `builds/combat_balance.json`, `docs/RUN_VERIFICATION.md` |
| Whole-run verification | Recorded decision records replay deterministically; **1,000** seeded legal-action runs with **0** engine errors and **0** recovery mismatches. Robustness evidence only, never a human estimate | `builds/full_run_harness.json`, `docs/RUN_VERIFICATION.md` |
| Android artifact | API-36 arm64 debug APK exported and signature-verified | `builds/android/ashfall-road-debug.apk` |
| Physical device | ADB currently reports no attached phone; Samsung acceptance is pending | `docs/PROJECT_STATUS.md`, latest `adb devices` check |

## Configuration and schemas

- Project: Godot 4.7.2, Compatibility renderer, portrait, 393×852 design viewport (the design-canvas artboard), `canvas_items`/`expand` stretching.
- `ashfall/release/monetization_enabled=false`: launch v1 contains no ads or purchases.
- `ashfall/release/living_road_enabled=false`: callback events, their source patches, and the fifteen callback chapters of the Road Chronicle are not available in launch v1. The other ten chapters ship.
- Active run schema: **5**.
- Profile schema: **5**.
- Entitlement schema: **1**.
- Narrative combat rules version: **2**.
- Experience rules version: **1**.
- M02 provides schema-5 contextual tip migration/progress and profile receipt IDs. Contextual prompt UI remains assigned to M08.

## Content inventory

### Enabled launch content

The current launch configuration loads:

1. `data/events.json` — 76 baseline events.
2. `data/narrative_overrides_v1.json` — 33 active prose overrides.
3. `data/narrative_overrides_v11.json` — 43 active prose overrides.
4. `data/bunker41_events.json` — 13 Bunker Forty-One events.
5. `data/rustsea_events.json` — 8 Rust-Sea events.

The active content boundary is **97 events**. Together the two override files polish all 76 baseline events; they affect prose only, and their mechanical fields are covered by the existing snapshot checks.

### Staged, not enabled in v1

- `data/living_road_events.json` — 15 callback events and source-flag patches.
- `data/road_ledger.json` — 25 discovery entries for the disabled expansion package.

When the Living Road flag is false, the repository does not load these staged layers.

### Equipment acquisition

- Items defined: **50**.
- Equipment items: **32**.
- Equipment items obtainable from v1 starting inventories or positive rewards: **32**.
- Equipment items without a launch-v1 acquisition route: **0**.

M05 appended ten launch routes to five existing unique events and added a `climbing_rope` route to `global_drop`, so all **50** defined items now have a starting or authored acquisition route in launch v1. `ContentRepository.validate_all()` enforces this in every build. The routes and their exact rewards are recorded in the mechanical-change allowlist in [`CONTENT_AUTHORING.md`](CONTENT_AUTHORING.md).

### Portrait coverage

The stable portrait registry expects 17 IDs: 4 survivor IDs and 13 enemy IDs.

- Concrete matching runtime assets currently exist for 7 expected IDs: `survivor_1`, `survivor_2`, `survivor_3`, `survivor_4`, `enemy_dogs`, `enemy_stalker`, and `enemy_toll`.
- 10 expected enemy IDs use the documented fallback/silhouette path: `enemy_bandits`, `enemy_leeches`, `enemy_raiders`, `enemy_drones`, `enemy_scavs`, `enemy_cult`, `enemy_hunters`, `enemy_guard`, `enemy_warden`, and `enemy_crows`.
- `enemy_toll_v2` is an additional source/runtime file, not a separate stable registry ID.

Fallbacks preserve gameplay and layout, but common enemies and the Warden need presentation review before release.

## Release blockers recorded by the local audit

The latest `tools/release_readiness.gd` run reports **7 blockers**:

1. Choose a permanent reverse-domain package identifier; `com.yourstudio.ashfallroad` is still a placeholder.
2. Configure the release upload keystore.
3. Configure the release upload-key alias.
4. Create and host the completed privacy policy (`docs/PRIVACY_POLICY_TEMPLATE.md` is only a draft).
5. Add `assets/store/icon_512.png`.
6. Add `assets/store/feature_graphic_1024x500.png`.
7. Add at least two real-device screenshots under `assets/store/screenshots` (six are planned).

These are owner/store-preparation blockers, not M00 implementation failures.

## Worktree baseline

M00 inspected the worktree and preserved all existing changes:

- 22 tracked files currently differ from the repository index.
- 65 untracked paths are present.
- `git status --short` returned 87 status lines.
- No reset, checkout, deletion, commit, or unrelated cleanup was performed.

The worktree is intentionally dirty because it contains the existing project implementation and documentation. Later tasks must preserve unrelated changes.

## Ordered task queue

Statuses use `Complete`, `Ready`, `Queued`, or `Blocked`. A task is not complete until its evidence is recorded in this file or its handoff document.

| ID | Assigned model | Prerequisites | Status | Completion evidence |
|---|---|---|---|---|
| **M00** | Luna / current agent | None | **Complete** | This baseline, current flags/schemas, content inventory, release blockers, and worktree record. |
| **M01** | Terra, Medium | M00 | **Complete** | Fixture version 2: named stats, preserved `agile_rifle`, genuine Wits-8 `mastered_rifle`, preflight assertions/metadata, and 84,000 reproducible results. See `builds/combat_balance.json` and `docs/NARRATIVE_COMBAT_REPORT.md`. |
| **M02** | Astra, High | M00 | **Complete** | Shared event/combat/immediate-action transactions, retained-result Retry, Android Back lock, profile-only receipts/startup replay, schema-5 tip migration. 2,259 regression + 201 recovery-UI assertions pass; combat UI has 0 failures. Interface and evidence: [SAVE_TRANSACTIONS.md](SAVE_TRANSACTIONS.md). |
| **M03** | Terra, Medium | M00 | **Complete** | Remaining baseline prose loads unconditionally; the 15 callback events and their source patches stay behind the Living Road flag; mechanical equality passes at the unchanged 97-event boundary. |
| **M04** | Sol, Medium/High | M03 | **Complete** | Nine regional batches reviewed; 13 prose-only corrections for combat-wound, condition-symptom, supply, and repeatability contradictions. Two remaining mismatches need a mechanical change and are recorded for M05. |
| **M05** | Terra, Medium | M02–M04 | **Complete** | Ten appended equipment routes across five unique events plus a `climbing_rope` route; original choice indices, labels, and rewards unchanged; 134 new assertions cover resolution, criticals, failure cost, mutual exclusivity, and restart recovery. |
| **M06** | Terra, Medium | M02, M05 | **Complete** | `EquipmentComparison` evaluates a hypothetical loadout on a sandbox copy through the ordinary domain calls; the item sheet shows attack, defence, check, carrying, and ammunition differences labelled as neutral. |
| **M07** | Terra, Medium | M02, M06 | **Complete** | Item sheet and run summaries scroll with pinned actions; clue/window/consequence grouped; dice targets read `ROLL N+`; inventory filter and scroll survive an item sheet; 312 layout assertions across four configurations. |
| **M08** | Sol, Medium/High | M02, M07 | **Complete** | Seven one-line contextual tips replace the first-run wall; dismissal persists, Settings switches them off or resets them, and guidance provably changes no run state. |
| **M09** | Terra, Medium | M02, M07 | **Complete** | ROAD CHRONICLE with Runs and Discoveries tabs, ten reachable chapters with a matching denominator, preserved variant accounts, and a dismissible resume recap. |
| **M10** | Luna, Low | M03–M09 | **Complete** | Eight read-only checks in `tools/data_package_audit.gd`, all passing; nine documentation discrepancies found and fixed; no mechanical defect to return. See [DATA_PACKAGE_AUDIT.md](DATA_PACKAGE_AUDIT.md). |
| **M11** | Sol for tooling; Luna for execution | M01, M05, M10 | **Complete** | 586,000 encounters over all 13 adversaries with tiered fixtures and road states; deterministic replay plus a 1,000-run soak; found one release blocker. See [RUN_VERIFICATION.md](RUN_VERIFICATION.md). |
| **M12** | Owner/testers; Sol/Luna support | M11 | Queued | Five uncoached observations, replay decisions, understood-death and voluntary-restart evidence. |
| **M13** | Luna/Terra; owner for approvals | M12 | Queued | Common-enemy art inventory, truthful store assets/copy, provenance records, no expansion marketing claims. |
| **M14** | Sol; Astra only for unresolved cross-system issues | M00–M13 | Queued | Full regression, release-readiness audit, signed AAB, Samsung/lower-end device and offline/interruption evidence. |
| **Expansion** | Terra/Sol/Luna | M14 plus post-launch stability | Deferred | Living Road callbacks, remaining Chronicle entries, and expansion closed-test evidence. |

## Next ready task: M12

M11 is complete. Before shipping, `global_stranger` needs one ungated choice; the data-package audit fails until it does.

M11 completion record:

- Encounter benchmark extended from 3 prototype adversaries to **all 13**, from 7 fixtures to **10** covering every weapon family in an early 15-point tier and a progressed 21-point tier, so no comparison mixes budgets. **586,000** authoritative encounters.
- Road states measured rather than assumed: fresh, hungry, injured, unarmed, and out of ammunition. The unarmed and dry rows confirm the fallback contract across 21,000 encounters.
- Controls retained and meaningful: behaviour-aware 0.778, without Opportunity 0.736, attack-only 0.707, repeat-defense 0.000. All 71 stall rows are the repeat-defense control; no stall occurred under any policy that attacks.
- New `tools/full_run_harness.gd`. A recorded decision record replays from its seed to a byte-identical run state and traces regional resources, equipment, XP, encounters, and death. **1,000** seeded legal-action runs produced **0** engine errors and **0** recovery mismatches.
- Random-policy results are labelled robustness evidence everywhere they appear. 765 of 981 soak deaths are starvation, which describes an unmanaged policy rather than human difficulty.
- **Release blocker found**: `global_stranger` gates every choice behind an item, so a survivor with no bandage and no clean water is stranded on disabled buttons. Reproduced at soak seeds 9103 and 9876. Not repaired here, because adding a choice is a mechanical change owned by a content plan; `tools/data_package_audit.gd` gained check 9 to hold the line and now reports 9 checks, 8 passed, 1 discrepancy.
- No rebalance was made. Tunnel Hunters (0.268 win rate, 321.7 HP spent) is recorded as the hardest matchup for whoever takes tuning next.
- Reconciled with a concurrent title/summary restyle that landed in `scripts/ui/main.gd` during this milestone. It kept the M09 wiring but renamed the menu entry back to "Road ledger" and raised safe-area padding from 24/20 to 54/34, which pushed combat actions and the guidance strip off a 360×640 screen at Large text. The menu entry now reads "Road chronicle" again, safe-area padding is responsive below 700 logical pixels, and the layout suite matches copy case-insensitively so a rewording no longer reads as a layout failure.

M10 completion record:

- New read-only tool `tools/data_package_audit.gd` runs eight checks over the launch configuration and exits 1 on any discrepancy: polished prose actually loaded, no prohibited or repeated sentences, all fifty item routes, appended choices legal and capped at four, original indices and mechanics unchanged, callbacks disabled, lore chapters reachable, and no unknown icon/item/condition/outcome reference.
- Result: **8 checks, 8 passed, 0 discrepancies.** Nothing was returned to an owning mini-plan because no mechanical defect was found.
- The ninth check, documentation against code, found nine discrepancies and all were fixed here: profile schema still documented as 4 in two places, a stale "preserve schema 4" scope line, three player-facing Road Ledger references that are now the Road Chronicle, a manual step that treated launch discoveries as callback-only, and two uses of Guard as current combat terminology.
- Carried forward, not a blocker: `bunker41_cartographer` choice 0 still deducts no ration. Recorded by M04 and out of scope for both M05 and this audit.
- `tools/release_readiness.gd` still reports the same **7 blockers**, all owner or publishing tasks rather than data defects.
- Verification at the audited commit: regression **2,444 assertions, 0 failures**; layout **624**; save-recovery UI **201**; combat UI **0 failures**.

M09 completion record:

- One title-menu entry, **ROAD CHRONICLE**, present in every build. It replaces the expansion-gated ROAD LEDGER screen and holds two tabs.
- Runs tab: the stored latest twenty summaries with survivor, region reached, level, equipment, strongest defeated enemy, and cause of death. A field an older summary never captured reads "Not recorded" rather than being filled in.
- Discoveries tab: `ContentRepository` now loads `road_ledger.json` in every build but keeps only chapters whose event is loaded. Launch exposes exactly the ten Bunker Forty-One, Rust-Sea, and ending chapters; the fifteen callback chapters are absent from the list and from the progress denominator. Enabling the expansion restores all twenty-five.
- Variants are preserved rather than replaced, in both `StoryDiscovery` and the receipt applier. Two runs that ended a thread differently leave two accounts, shown under one chapter as accounts from different runs. Chapters and accounts are counted separately.
- Choosing CONTINUE RUN opens a dismissible recap derived from the saved run: location and region, what the run is waiting on, the last choice and its outcome, and the survivor's current conditions. Nothing else opens it.
- Done-when proven directly: a terminal receipt keeps earlier discoveries and history while adding its own, replaying it duplicates neither, and no disabled callback chapter is listed or counted.
- Verification: `tests/test_runner.gd` **2,444 assertions, 0 failures**; `tests/layout_ui_smoke.gd` **624 assertions, 0 failures**; `tests/combat_ui_smoke.gd` **0 layout/input failures**; `tests/action_ui_smoke.gd` **201 assertions, 0 failures**.

M08 completion record:

- The first-run tutorial wall no longer opens by itself. The same full reference stays under Settings → HOW TO PLAY, and `_show_first_run_tutorial` is now only reachable from there.
- Seven tips fire at their moments: a checked choice, the first result screen, a committed Heavy or Sweep, an earned Riposte or Opening, opening a weapon's sheet, a ready Opportunity, and a checkpoint carrying points.
- Guidance is a single tappable strip in the shell column beside the page, so it can never cover a control. Tapping it dismisses that tip; Settings switches every tip off and resets their progress.
- Tips are one short line each, capped at 80 characters and two sentences by assertion, because a tip shares a 360×640 combat screen with six actions.
- Combat makes room rather than losing anything: while a tip is visible the round log stops reserving rows and the portraits shrink, so the clue, the windows, and all six actions keep their places. No tip opens while a die is resolving or a saved roll waits to be revealed.
- Guidance provably changes nothing: the event, checkpoint, and combat suites all compare the whole run state, RNG included, across showing and dismissing a tip.
- Profiles: `contextual_tips_enabled` defaults to true, progress persists to disk, and a pre-schema-5 profile with `tutorial_seen` still migrates with all seven tips already dismissed.
- Verification: `tests/test_runner.gd` **2,432 assertions, 0 failures**; `tests/layout_ui_smoke.gd` **468 assertions, 0 failures**; `tests/combat_ui_smoke.gd` **0 layout/input failures**; `tests/action_ui_smoke.gd` **201 assertions, 0 failures**.

M07 completion record:

- Item sheet: description, modifiers, and the equipment comparison share one `ItemDetailScroll`; the header Close and every Equip/Use/Drop/Unequip action stay outside it.
- Run summaries: the record scrolls in `RunSummaryScroll` while Begin Another Run and Main Menu stay pinned, for both death and victory.
- Stat allocation keeps its apply and return actions above the scrolling stat list; this is now asserted rather than assumed.
- Dice targets read `ROLL N+` everywhere: the event roll screen, the six combat action buttons, and the prepared roll button. The post-roll recap keeps `ROLLED N • NEEDED M+` because it reports a result rather than a target.
- Combat groups the enemy clue, the attack windows it opens, and the latest consequence into one `CombatExchangePanel` between the dice and the action grid.
- Compact-screen space reclaimed without shrinking a single 44px target: tighter grouping chrome, one-line attack-window chips, root separation 3, a 56px item icon, and no `YOU //` / `ENEMY //` prefix on a compact combat card, where position, border colour, and tooltip already carry the side. Narrative combat now measures 545px tall at 360×640 with Large text, inside the 563px available; it was 596px and clipping its bottom action row.
- Returning from an item sheet restores the inventory filter and scroll position.
- Player-left/enemy-right and the fixed six-action grid are unchanged and still asserted.
- Verification: `tests/layout_ui_smoke.gd` **312 assertions, 0 failures**; `tests/combat_ui_smoke.gd` **0 layout/input failures**; `tests/action_ui_smoke.gd` **201 assertions, 0 failures**; `tests/test_runner.gd` **2,424 assertions, 0 failures**.

M06 completion record: Later mutation/UI work must follow [SAVE_TRANSACTIONS.md](SAVE_TRANSACTIONS.md); do not call domain mutations followed by an unchecked save.

- New read-only domain module `scripts/domain/equipment_comparison.gd`. `compare(game, item_id)` deep-copies the run, clears combat on the copy, equips the proposed item through `GameEngine.equip_item`, and reads `NarrativeCombat.preview` and `combat_effective_stats` from it. No value is recalculated locally, so the sheet cannot drift from gameplay.
- Purity: the live `run_state` and its `rng_state` are unchanged by a comparison, including during an active fight. Asserted by deep-equality on the whole run state.
- Neutral by construction: with no committed enemy move, Riposte, or Opening on the copy, the previews return neutral values. A comparison taken mid-fight equals the same comparison taken outside one, and every panel carries the "Neutral values" label.
- Reported: current → proposed, neutral damage range, hit chance and attack stat, signature with mastery state, armor rating with a sample hit and neutral Block/Dodge, effective stat and approach differences, carry capacity and overweight changes, ammunition needed against ammunition carried, and shield removal or two-handed incompatibility.
- A shield blocked by an equipped two-handed weapon still produces a full comparison reporting that it would add nothing, rather than refusing to compare.
- UI: `_comparison_panel` in the item detail sheet renders the rows inside a `ScrollContainer`, so the sheet's actions stay reachable; the sheet grows to 0.74 height when a comparison is present.
- Regression: `tests/test_runner.gd` exit code 0 - **2,424 assertions, 0 failures** (`builds/m06-tests.log`); `tests/action_ui_smoke.gd` **201 assertions, 0 failures**; `tests/combat_ui_smoke.gd` **0 layout/input failures**.

M05 completion record:

- Ten choices appended to `outskirts_market`, `flats_convoy`, `marsh_body`, `industrial_locker`, and `industrial_office`. Every original choice keeps its index, label, check, and rewards; each event stays unique at four choices.
- Rewards exactly as specified: one selected equipment item per success, `hunting_rifle` with four `rifle_rounds`, `flare_gun` with three `shotgun_shells`, failure costing only Fatigue (6 in the Flats and Marshes, 8 in the Industrial Zone).
- No `critical_success`/`critical_failure` is defined on the new choices, so a natural 20 or 1 resolves through the ordinary reward with no multiplier.
- `global_drop` choice 1 success also grants `climbing_rope` +1. It was the last item with no launch route, and `outskirts_sinkhole` and `marsh_bridge` each gate a choice behind carrying it.
- `_validate_item_acquisition` moved from the Living Road validation into `validate_all`, so an unobtainable item now fails the launch build too.
- Prose: a plain baseline passage in `events.json` and the polished passage in the matching override file for all 18 new outcomes. Word-count, filler, and duplicate-sentence checks pass corpus-wide.
- Regression: `tests/test_runner.gd` exit code 0 - **2,396 assertions, 0 failures**, `builds/m05-tests.log`.
- Out of scope and still open: `bunker41_cartographer` choice 0 "Share a ration with Mara" deducts no item. The M05 plan names the five events it may change, so the missing `costs` entry was left for a later content task rather than added here.

M04 completion record:

- Reviewed all 97 launch events in nine regional batches (six regions, globals/final gates, Bunker Forty-One, Rust-Sea) against each outcome's authoritative items, pressures, conditions, flags, and combat.
- 13 prose-only corrections in `data/narrative_overrides_v1.json` (7), `data/narrative_overrides_v11.json` (4), `data/bunker41_events.json` (1), and `data/rustsea_events.json` (1). No mechanics, choice labels, or choice order changed.
- Categories fixed: one combat critical victory claiming a bloodless encounter; four conditions named rather than shown as symptoms; four supply claims that did not match the outcome's item list; three condition words used where the outcome applies no such condition; one repeatable event assuming an earlier encounter.
- Word-count (60-90 introductions, 30-50 outcomes), prohibited-filler, and duplicate-sentence checks pass across all 97 events, not only the polished 76.
- Regression: `tests/test_runner.gd` exit code 0 - **2,262 assertions, 0 failures**, `builds/m04-tests.log`.
- Two prose/mechanics mismatches needed a mechanical change rather than an edit: `bunker41_ash_procession` and `rustsea_salt_crown_wake` reward nothing for choices labelled as taking supplies (their prose now matches the empty outcome), and `bunker41_cartographer` choice 0 "Share a ration with Mara" deducts no item. See the open item below.

M03 completion record:

- `scripts/domain/content_repository.gd` applies `data/narrative_overrides_v11.json` unconditionally; `data/living_road_events.json`, its source-flag patches, and `data/road_ledger.json` remain gated on `ashfall/release/living_road_enabled`.
- Launch boundary unchanged: **97 events**, 372 outcome passages, 138 checked choices, 11 combat choices.
- Mechanical equality re-verified — stripping prose from the live launch records reproduces `data/events.json` for all 76 baseline events — before any M05 equipment-route work.
- Word-count, prohibited-filler, and duplicate-sentence checks pass across all 76 polished events.
- Regression: `tests/test_runner.gd` exit code 0 — **2,262 assertions, 0 failures**.

M02 completion record:

- Full regression: **2,259 assertions, 0 failures**, exit 0, `builds/m02-tests.log`.
- Final shared-state rerun after concurrent M03 changes: **2,262 assertions, 0 failures**, exit 0, `builds/m02-combined-tests.log`. M03 edits were preserved.
- Save-recovery UI: **201 assertions, 0 failures**, exit 0, `builds/m02-action-ui.log`.
- Existing combat UI: **0 layout/input failures**, exit 0, `builds/m02-combat-ui.log`.
- Run schema remains 5; profile schema is now 5. No combat math, content selection, release flags, or entitlement contracts changed.
- No commit, revert, or unrelated cleanup was performed. The M00 worktree counts above are a historical baseline, not the current file count.
- Device export/installation and physical Samsung low-storage/force-close acceptance remain pending; automated write-failure/process-recreation checks are not a claim of device verification.

M01 completion record:

- Command: `Godot_v4.7.2-stable_win64_console.exe --headless --path . --script tools/combat_balance.gd`.
- Result: exit code 0; **84,000** deterministic encounters, 7 fixtures, 3 prototype enemies, 4 policies, and 1,000 seeds per row.
- Regression: `tests/test_runner.gd` completed with exit code 0 — **2,037 assertions, 0 failures**.
- Corrected rifle facts: `agile_rifle` is Wits 3 / unmastered; `mastered_rifle` is Strength 3, Agility 3, Wits 8, Grit 5, Presence 2 / mastered. Both have a deliberate 21-point budget, 400 starting HP, Scout Leathers, Hunting Rifle, and loaded Rifle Rounds.
- No balance, combat, save, content, or UI values changed. The only code change is the benchmark harness; the JSON/report are generated evidence.

## Model-use policy for this queue

- Model names in this document are assignments, not automatic model switches.
- Manually select the assigned model before each fresh task unless explicitly delegating a subagent with a specified model.
- Use the lowest reasoning effort that safely completes the bounded task.
- Escalate to Sol or Astra only for a documented ambiguity, failed repair, or cross-system risk.
- Routine checks should be run locally and summarized, not reproduced as large model-generated output.
