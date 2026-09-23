# Narrative refinement queue

Status: **N00–N08 complete; interim 21-enemy 200-seed re-measurement complete 22 September 2026; N09 is the human-reading gate.** Governing plan: [NARRATIVE_REFINEMENT_PLAN.md](NARRATIVE_REFINEMENT_PLAN.md). The completed M-series (M00–M11) is recorded in [IMPLEMENTATION_QUEUE.md](IMPLEMENTATION_QUEUE.md) and is not repeated here.

This file records repository facts and the next ready task. Editing it changes no content, flag, or save format.

## Interim 21-adversary re-measurement — 22 September 2026

Interim step toward the full 1M+ 1,000-seed re-measurement still pending from A02/C01. **318,600** authoritative encounters (21 adversaries × 14 builds × 5 policies × 200 seeds + 123 state rows × 200) as same-tuning concatenation `builds/cb_chunk_a/b/c.json` → `builds/combat_balance_21x200.json`; tables in `builds/combat_balance_21x200_summary.md`. Combat rules 2, fixture version 3.

Result: behaviour-aware 0.746 (early 0.703, progressed 0.821); A02/C01 hardening confirmed across the roster with Kilnback easier 0.390 → 0.642 per the N05b re-anchor; new mutants pox_dogs 1.000, bile_spewer 0.931, salt_colossus 0.554, cinder_mauler 0.426; 62/1,593 stalled rows, all repeat-defense control, none under an attacking policy. Random-policy rows are robustness evidence only.

**Next:** full 1,000-seed 1M+ re-measurement on the 21-adversary roster (run per-enemy chunks — a single full run exceeds a 30-minute headless window); N09 human-reading gate still owns playtest acceptance. Also synced: `docs/RUN_VERIFICATION.md` interim section, `docs/CONTENT_AUTHORING.md` item/ledger counts (72 items, 29 chapters).

## F01 betrayal-arc loading — 21 September 2026

F01 loads the staged betrayal draft into the expanded release. `ContentRepository.reload()` merges `data/betrayal_events.json` when `living_road_enabled`, so no-argument loading and exported builds now carry **124 events and 29 Chronicle chapters** (15 callbacks plus 12 Vex/Slate/Anselm scenes and 3 new chapters); `ContentRepository.new(false)` stays the 97-event, 11-chapter compatibility mode. No save, schema, scheduler, item, condition, adversary, XP, or choice-structure change; no original event touched.

Validation: `tools/data_package_audit.gd` **9/9, zero discrepancies**. `tests/test_runner.gd` **3,276 assertions, 0 failures**, including the new `_test_betrayal_arc` (loads, trust-chain gating, variant bodies, a played meal, two started combats, settled ledger receipt with a no-source control). `tests/layout_ui_smoke.gd` **1,637 assertions, 0 failures** (`1 / 29 chapters`). `tests/combat_ui_smoke.gd` **0 failures**. `tools/full_run_harness.gd` 200-run soak: **0 engine errors, 0 recovery mismatches**. Mechanical differences against the N00 baseline are recorded in the F01 allowlist section of [CONTENT_AUTHORING.md](CONTENT_AUTHORING.md).

**Next:** full 1M+ encounter re-measurement on the 21-adversary roster (still pending from A02/C01); N09 human-reading gate still owns playtest acceptance.

## E05 activation and public-playtest packet — 15 September 2026

E05 activates the expanded release deliberately. `project.godot` now sets `ashfall/release/living_road_enabled=true`, so no-argument `ContentRepository.new()` and exported builds load **112 events, 26 Chronicle chapters, and 17 adversaries**. The retained `ContentRepository.new(false)` configuration is an explicit compatibility regression mode with 97 events and 11 chapters; it is no longer the shipping default.

The data-package audit now verifies both configurations, with the default as the release contract: **9/9 checks passed**. The core suite adds default-activation coverage and reports **3,028 assertions**; its **20 failures** are the pre-existing sandbox-only disk-save/UI checks caused by this session being unable to open `user://logs`, while the activation, content, narrative, routing, and compatibility checks pass. The compact/Large-text layout suite was updated from its stale disabled-callback expectation and passes **1,069 assertions, 0 failures**.

`Android Debug` exported successfully as `builds/android/ashfall-road-debug.apk` (76,612,026 bytes; SHA-256 `B5B129C7536591A0B747AF5DBD0D9A4679F9DB9BEC089F9C7566CBD744E2EEEF`) with version `0.2.0-playtest`. The 100-run default-content robustness harness reproduced its recorded 42-decision journey exactly and found **0 engine errors / 0 recovery mismatches**. Its random policy died in all 100 runs, so the result is robustness evidence only and is not a player-retention claim.

The reviewable upload material is [E05_PLAYTEST_PACKET.md](E05_PLAYTEST_PACKET.md), with page copy, player invitation, feedback template, cover provenance, and the remaining physical-device save/resume and full-journey checks. No itch.io page was published and no tester was contacted.

**Next:** install the APK on a clean Android device, run save/resume and one complete journey, then upload the reviewed build and invite the first ten testers using the packet.

## E04 factual recall and committed results — 15 September 2026

E04 is complete. It builds on the existing N07 reader, Chronicle, and receipt surfaces rather than adding a parallel memory system. The resume recap now places a **Committed change** line directly after the last choice and its outcome prose. It reads the already-committed `last_result.changes` array: a radio refusal correctly says `none.`, while Market labor records `Fatigue +6`. The recap does not mutate game state, roll RNG, or derive a relationship from event history.

The existing Road Chronicle remains factual, profile-only knowledge: it retains accounts from different runs, gives no gameplay advantage, and includes its 11 launch / 26 expanded definitions and 48 expanded variants. Result readers still show the complete outcome prose and a separate committed receipt; compact and Large text keep recap detail scrollable with the Resume control pinned outside it.

Validation: the two E04 receipt/recap regressions pass in `tests/test_runner.gd` (**3,025 assertions; same 20 sandbox disk-save/UI failures**). `tests/layout_ui_smoke.gd` passes **1,069 assertions, 0 failures**, including the scrolling resume recap across compact and Large-text viewports. `tools/data_package_audit.gd` remains **9/9, zero discrepancies**. No event mechanics, Chronicle trigger, profile schema, or release setting changed.

**Next: E05.** Run the final applicable integration checks, activate only when the expanded default/export has been deliberately verified, and prepare the free playtest packet.

## E03 batch 1 — Quiet Column continuity — 15 September 2026

E03 is active. Its first complete-arc batch revisits Dena and Perrin from the Tower Six source through `lr_quiet_column`, `lr_bellkeepers_son`, and `lr_siren_in_glass`. The prior N06b work already gave the thread its distinct decisions, Perrin's informed participation, final flare/siren/quiet outcomes, and contrasting final-state passages. This batch makes the remaining two source histories equally legible at the first return.

- `lr_siren_endured` now records that the survivor left Tower Six sounding and tells Dena which streets its note carried down. She treats the account as route intelligence and moves the column away from it.
- `lr_siren_followed` now records the doubled streets and lost ground caused by the persisting alarm. Dena uses those turns to change the column's route, without assigning a universal verdict to the survivor.
- `lr_siren_silenced` and `lr_siren_burned` retain their existing specific entrances. All four Tower Six flags now resolve to different Quiet Column introductions, each within the substantial 110–180 word limit.

No choice, cost, reward, flag, callback window, scheduler rule, or save format changed. The data-package audit remains **9/9, zero discrepancies**. The core suite reports **3,023 assertions and the same 20 sandbox disk-save/UI failures**; the new four-source continuity assertion passes.

**Next E03 batch: Road Debt.** Review Lio's source, ledger return, and final toll together, preserving any choices and outcomes already supported by the N06b review.

## E02 early-hook delivery — 15 September 2026

E02 is complete. It changes the opening experience only when `ContentRepository.new(true)` enables the Living Road expansion; `release/living_road_enabled=false` remains the shipping default.

| Change | Result | Evidence |
|---|---|---|
| First expanded event | Only `outskirts_child_radio`, `outskirts_market`, and `outskirts_cache` can be selected. Each carries both `opening_safe` and the new `opening_hook` tag. | `data/events.json`, 500 seeded guidance assertions |
| Second expanded event | The existing complementary resource/equipment teaching rule remains in force. | 500 seeded guidance assertions |
| Third expanded event | If neither `outskirts_child_radio` nor `outskirts_siren` appeared in the first two draws, an eligible, unvisited one is reserved. If none is available, ordinary selection remains the documented fallback. | `GameEngine._apply_opening_guidance`, 500 seeded guidance assertions |
| Channel Nine refusal | Choice 2, **Leave the broadcast running**, is certain and adds no resource, pressure, condition, or source flag. It leaves no false Vale relationship or bearing. | `data/events.json`, `narrative_overrides_v1.json`, refusal assertion |
| Factual opening prose | Market no longer claims a first-event survivor knows the eastern underpass; Cache no longer invents an absent clerk, contents, or later traveler. | `narrative_overrides_v1.json`, E01 cards |
| Counts | Launch: 97 events, 246 choices, 402 outcomes, 11 discoveries, 17 adversaries. Expanded: 112 events, 298 choices, 485 outcomes, 26 discoveries, 17 adversaries. | `tools/content_dossier.gd`, `builds/content_dossier_{launch,expanded}.md` |

Validation: the data-package audit is 9/9 with zero discrepancies. The core suite reports **3,022 assertions and 20 failures**, unchanged from the known sandbox disk-save/UI limitation; all E02 guidance assertions pass. The mechanical snapshot now records 200 documented differences against N00, four more than the E00 baseline: the three opening tags and the appended radio choice. `git diff --check` passes for the E02 files.

**Next: E03.** Review and improve existing middle/return arcs one complete thread at a time. Preserve E02's expanded-only selection, unchanged launch pool, and no-source refusal behavior.

## E01 opening design — 15 September 2026

E01's three story cards and one editorial review are complete in [E01_OPENING_STORY_CARDS.md](E01_OPENING_STORY_CARDS.md). The review covers all 9 existing choices and 15 authored outcomes, plus the proposed certain radio refusal. It preserves existing indices, rewards, Channel Nine source facts, Market's four-choice limit, and Cache's compact role. It identifies targeted false-knowledge edits at the Market and Cache, and distinguishes existing guaranteed fatigue from failure-only scrap loss. **No game content, selection rule, save contract, or release setting changed in E01.**

**E02 handoff accepted:** implementation preserved the launch default and original source contracts. The next story batch is E03.

## E00 implementation baseline — 15 September 2026

E00 is complete. It reconciled the current implementation before the opening-engagement work begins; it made no content, routing, save, or release-setting change.

| Check | Current result | Evidence |
|---|---|---|
| Shipping default | `release/living_road_enabled=false`; no-argument loading remains the 97-event launch build | `project.godot`, `ContentRepository._init` |
| Explicit configurations | At E00: Launch: 97 events, 245 choices, 401 outcomes, 11 discoveries, 17 adversaries. Expanded: 112 events, 297 choices, 484 outcomes, 26 discoveries, 17 adversaries. E02 adds one certain radio refusal to both configurations: 246/402 launch and 298/485 expanded. Each has 3 intentional compatibility/fallback unreachable records. | `tools/content_dossier.gd`, `builds/content_dossier*.{json,md}` |
| Content contracts | 9/9 audit checks passed with 0 discrepancies. | `tools/data_package_audit.gd` |
| Story routing | The suite confirms Bunker contact routes to the Bunker finale; heard-voice-only uses standard screening with recognition; Key possession and independent testimony remain distinct; the disk, Kilnback, Cinder Giant, five callbacks, and competing-hook completion contracts pass. | `tests/test_runner.gd` focused assertions |
| Baseline comparison | 196 mechanical differences exist from the N00 snapshot. They correspond to the documented N04–N06 data, creature, finale, and callback delivery work; no unreviewed E00 delta was introduced. | `tools/mechanical_snapshot.gd -- --diff` |
| Core suite | 3,012 assertions, 20 failures. All story, routing, callback, ownership, and content assertions pass. | `tests/test_runner.gd` |

**Blocked verification, not a confirmed game defect:** this headless session cannot open Godot's `user://` directory, including its own log location. The 20 failed assertions are all direct disk-save or UI paths that depend on those disk writes: treatment, checkpoint allocation, terminal receipts, profile/entitlement migration, hidden-choice resolution through the UI transaction path, and prepared-combat persistence. The equivalent workspace-backed transaction/fault-store checks pass. Re-run the disk-save subset on a writable local Windows account or physical device before claiming save safety for a public playtest.

**E01 handoff:** Preserve the launch default until E05 activation. Build several strong, safe opening dilemmas on the existing `outskirts_child_radio`, `outskirts_market`, and `outskirts_cache` scenes, then verify their consequences through the already-tested expanded callback system. Do not change `living_road_enabled` as part of E01.

## Both configurations, as they actually load

Measured on 8 September 2026 by two independent derivations that agreed exactly: `tools/content_dossier.gd` (graph over pools, globals, eligibility flags to a fixed point, and `next_event` chains) and a manual trace of `game_engine.gd` `_select_next_event`, `_event_eligible`, `continue_after_result`, and `leave_checkpoint`.

| Measure | Launch `new(false)` | Expanded `new(true)` |
|---|---|---|
| Events loaded | 97 (76 baseline + 13 Bunker + 8 Rust-Sea) | 112 (+15 Living Road) |
| Reachable in play | **94** | **109** |
| Choices / outcomes | 236 / 390 | 281 / 465 |
| Checked / combat choices | 146 / 11 | 176 / 11 |
| Lethal outcomes | 9 | 9 |
| Flags produced / consumed | 72 / 28 | 179 / 130 |
| Discoveries loaded / reachable | 10 / **9** | 25 / **24** |
| Adversaries defined / ever fought | 13 / **10** | 13 / **10** |
| Source-flag patches applied | 0 | 22 (5 baseline events) |
| Loader errors | 0 | 0 |

Runtime default is launch: `project.godot:16` `release/living_road_enabled=false`, read by `ContentRepository._init` only when no argument is passed.

Artifacts (regenerate with the named tool; `builds/` is gitignored, so durable copies live in `docs/baselines/`):

- `builds/content_dossier.json`, `builds/content_dossier_launch.md`, `builds/content_dossier_expanded.md` — `tools/content_dossier.gd`. Every event's labels, checks, requirements, costs, all outcomes with mechanical fields and word counts, flag producer/consumer index, reachability with reasons, discoveries, adversary usage. Durable copy: `docs/baselines/content_dossier_n00.json`.
- `builds/mechanical_snapshot_narrative_baseline.json` — `tools/mechanical_snapshot.gd`. Independent before-change record: SHA-256 of every `data/*.json`, and for both configurations a hash of every event's mechanical signature (prose stripped), choice labels in index order, items, conditions, adversaries, discoveries, and counts. `-- --diff` exits 1 on any change, so a change made to a data file and its override together is still caught. Durable copy: `docs/baselines/mechanical_snapshot_narrative_baseline.json`; restore it to `builds/` before diffing if `builds/` was cleaned.

## Baseline verification

| Suite | Result |
|---|---|
| `tests/test_runner.gd` | **2,481 assertions, 0 failures** at N00; **2,491** at N01 (the plan's 2,444 and the M11 record's 2,469 are behind; another engineer keeps adding assertions concurrently) |
| `tests/layout_ui_smoke.gd` | 624 assertions, 0 failures |
| `tests/combat_ui_smoke.gd` | 0 layout/input failures |
| `tests/action_ui_smoke.gd` | 201 assertions, 0 failures |
| `tools/data_package_audit.gd` | at N00: 9 checks, 8 passed, 1 discrepancy (`global_stranger`). **After N04: 9 checks, 9 passed, 0 discrepancies.** |
| `tools/mechanical_snapshot.gd -- --diff` | no differences |
| `tools/full_run_harness.gd` | reused; 1,000-run soak and deterministic replay recorded in [RUN_VERIFICATION.md](RUN_VERIFICATION.md) |

Worktree: HEAD tracks only the 64 foundation files (`9968623`). `git status` lists 22 modified tracked files and 89 untracked entries; **all M-series and narrative work is uncommitted.** Another engineer is editing `scripts/ui/main.gd` (a title/summary restyle landed 8 September 01:40); N00 touched no existing file.

Save contracts (from [SAVE_TRANSACTIONS.md](SAVE_TRANSACTIONS.md)): active run schema 5, profile schema 5, entitlements 1. Run-state `flags` is an append-only array written only by `_apply_outcome` `add_flags`; there is **no `remove_flags` contract**. Callbacks, discoveries, and terminal summaries commit once through receipts; UI narration owns no gameplay mutation.

## Findings that shape the plan

Recorded now so later packages design against facts rather than assumptions.

1. **The original finale is dead content.** Nothing routes to `final_gate_2`: no pool lists it, it is not global, and no outcome chains to it. `final_gate_1`'s five outcomes all chain to `bunker41_warden_remembers` → `bunker41_door_closes`. Consequently `final_gate_3` — which holds the only `victory: true` outcomes in `data/events.json` — can never be shown, and the discovery `ledger_ending_citadel` (event `final_gate_3`) can never be recorded while it still counts in the Chronicle's ending denominator. This is the "compatibility-only content" the plan asks N06 to trace before removing or re-routing anything; it also means the Chronicle currently advertises an ending no run can reach. Owner: N06 (finale) and N07 (Chronicle review).
2. **Three adversaries are never fought**: `marsh_leeches`, `drone_swarm`, and `citadel_guard` appear only as event-level `adversary_id` (portrait and default target) with no choice carrying a `combat` block. `warden_machine` is fought only through `bunker41_warden_remembers:1`. Owner: N05 creature/combat work and N06.
3. **Flags without consumers**: 44 of 72 launch flags and 49 of 179 expanded flags are written and never read by any eligibility, choice requirement, or Chronicle variant (for example `access_core`, `b41_answered`, `b41_archive_truth`). Every consumed flag has a producer. The plan's rule stands: a flag without a consumer is not a callback. Owner: N02 consequence map.
4. **A due chapter can be lost.** The one-callback-per-region rule is `forbids_flags: ["lr_callback_region_N"]` plus every callback outcome adding that flag; once any region-N callback resolves, every other region-N callback and its downstream chapters are gone for the run. Callbacks are scheduled only as global candidates at priority 7 (region-1 openers) or 9, competing with `bunker41_static` (9, region 1), `bunker41_rusted_hatch` (10, region 4), `rustsea_green_line` (11, region 5), the forced-combat slot 4 and forced-supply slot 5 guarantees, and the unique/recent filters. Nothing today reserves a slot for a followed thread. Owner: N04 focused scheduling.
5. **Content validators are not uniform.** The loader's duplicate-sentence and filler checks cover only overridden events plus enabled callbacks (76 launch / 91 expanded); the 13 Bunker and 8 Rust-Sea events are exempt in the loader, while the audit's own repeat scan covers all 97. The audit never enforces word budgets and runs every content check against `new(false)` except the discovery counts. `_word_count` splits on a single space, so paragraph breaks written without surrounding spaces merge words. Owner: N04 shared budget contract; N08 both-configuration verification.
6. **Flag-gated choices carry Bunker-specific lock copy.** `_choice_availability` has exactly two hard-coded reasons ("Requires the relevant Bunker Forty-One record", "Requires Bunker Forty-One testimony or evidence"). Any non-Bunker gate added by N04–N06 needs authored reason text. `_choice_availability` also supports `requires.stats`, `requires.forbids_conditions`, and `costs.pressures`, but `_validate_choice` validates only `requires.items` and `costs.items`. Owner: N04.
7. **Missing portraits render raw text.** `portrait_art.gd:76` shows `PORTRAIT` plus the upper-cased ID when no image loads; 10 of 13 current adversaries already show this in combat. The plan's creatures must not. Owner: N04.
8. **Stale authoring doc contracts**: `CONTENT_AUTHORING.md:15` says 48 items (data and tests say 50); `:27` says story milestone XP is 10–20 while the validator accepts 0–20. Owner: N10.
9. **Journey XP is per event by design.** `_event_experience_awards` grants the "journey" award for every non-chained event in regions 0–5; this matches [TESTING.md](TESTING.md) manual step 7 ("normal journey completion grants 4 XP") and is not a defect. Recorded so it is not re-investigated.

## Contracts the plan will revise deliberately

Full inventory with file:line in the N00 workflow journal; the ones N04 and N08 must change as documented scope, not accidental breakage:

| Contract | Location | Current |
|---|---|---|
| Introduction words 60–90 | `content_repository.gd:209-211`, `test_runner.gd:95-96` | enforced |
| Outcome words 30–50 | `content_repository.gd:465-471`, `test_runner.gd:106-107` | enforced |
| Launch / expanded event counts | `test_runner.gd:90`, `:172` | 97 / 112 |
| Checked / outcome / combat counts | `test_runner.gd:98-110` | 146 / 390 / 11 launch |
| Adversary count and roster | `test_runner.gd:89`, `portrait_art.gd:5-20` | 13; 17 portrait IDs |
| Discovery counts | `content_repository.gd:49-59`, tests | 10 / 25 |
| Callback shape (3 choices), distribution, priority | `test_runner.gd:186-197` | pass |
| Launch keeps callbacks staged | `test_runner.gd:157`, audit check 6 | pass |
| Mechanical-signature equality (launch only) | `test_runner.gd:203-208`, audit check 5 | holds for launch; the 22 patches make it false for expanded by design |
| Mechanical-change allowlist | `CONTENT_AUTHORING.md:132-163` | records M05 only |

Unchanged by the plan: 50 items and unique icons, 13 conditions, 2–4 choices per event, region supply/combat pool guarantees, adversary `portrait_id` required.

## Packages

| Package | Status | Record |
|---|---|---|
| N00 Establish both configurations and the baseline | **Complete** | This file; `tools/content_dossier.gd`; `tools/mechanical_snapshot.gd`; `docs/baselines/` |
| N01 Story canon and creature identities | **Complete** | [STORY_CANON.md](STORY_CANON.md); [CREATURE_STORY_BIBLE.md](CREATURE_STORY_BIBLE.md); enemy bible §8 |
| N02 Design every choice, reward, and return | **Complete** | [NARRATIVE_CONSEQUENCE_MAP.md](NARRATIVE_CONSEQUENCE_MAP.md); `consequence_map/` A–F; `tools/choice_comparison.gd`; `builds/flag_index.md` |
| N03 Complete sample arc and varied scenes | **Complete** | Ten playable scenes; [N03_REVIEW_PACKET.md](N03_REVIEW_PACKET.md) |
| N04 Richer text, memory, and reliable returns | **Complete** | Passage, gating and budget engine; focused scheduling; the §6 repairs; creature profiles and presentation |
| N05 Expand ordinary scenes by region | **Complete** | 52 scenes rewritten across seven groups; allowlist section in [CONTENT_AUTHORING.md](CONTENT_AUTHORING.md) |
| N06 Expand returning stories and major arcs | **Complete** | N06a reconciled routing/focus; N06b verified five Living Road arcs; N06c closed finale promises; N06d added and verified the two residual creature fights |
| N07 Reading and reward delivery | **Complete** | Visible choice costs, committed receipts, compact-reader verification, and Chronicle audit |
| N08 Verify the expanded story | **Complete** | Both configurations, routes, recovery, presentation, deterministic soak, and evidence index verified |
| N09 Verify reading with people | Human gate | — |
| N10 Activate the expanded default and reconcile docs | Queued | — |

## N00 completion record

- Read: the plan, [IMPLEMENTATION_QUEUE.md](IMPLEMENTATION_QUEUE.md), [CONTENT_AUTHORING.md](CONTENT_AUTHORING.md), [LIVING_ROAD_NARRATIVE_BIBLE.md](LIVING_ROAD_NARRATIVE_BIBLE.md), [BUNKER41_NARRATIVE.md](BUNKER41_NARRATIVE.md), [MEGA_CHAIN_EXPANSION.md](MEGA_CHAIN_EXPANSION.md), the loader, scheduler, and [SAVE_TRANSACTIONS.md](SAVE_TRANSACTIONS.md).
- New read-only tools: `tools/content_dossier.gd` (both-configuration dossiers with reachability and flag consumers) and `tools/mechanical_snapshot.gd` (independent hashed baseline with a `--diff` mode, verified against seven injected mutations). Neither modifies any existing file.
- Inventory of the 112-event target, 25 discoveries, adversary availability, and compatibility-only nodes recorded above, with the two independent reachability derivations agreeing on the same three unreachable events in both configurations: `final_gate_2`, `final_gate_3`, and `fallback_dust` (the last is the engine's empty-pool literal at `game_engine.gd:1152` and is not a defect).
- Baseline verification re-established at 2,481 regression assertions.
- Not done here, by design: no content, flag, contract, or test was changed. The `global_stranger` audit discrepancy and the finale finding are carried into N04 and N06 respectively.

## N01 completion record

- `docs/STORY_CANON.md`: the central question; why people travel east and what the Citadel actually does; a relative timeline in three registers (known / believed / mystery); the six regions as questions with human authority and creature presence per region, verified against the actual pools; the observation / belief / mystery rule with the standing mysteries that must never be resolved (Hush Sovereign, Salt Crown, the Cinder Wives' nature, the voice map, the Spire, onward transport); SOTERIA as the single admission protocol linking Bunker Forty-One, the duty voice, the Warden, and the gate; the Mercy Key as evidence rather than permission, with possession rules; records, testimony, and rescued people as the three kinds of evidence; wants / knows / cannot / trades / sounds entries for Mara, the Vales, Dena and Perrin, Lio, Iven, Noma, the Cinder Wives, the Ash Choir (kept distinct from the Glass Cult), the Warden, and the Citadel; the four endings with their real requirements and meanings; what the Chronicle keeps; and a table of nine contradictions in loaded content, each assigned to N02, N04, N06, or N07.
- One canon rule resolves the plan's "entrance histories" defect without new content: **SOTERIA recognizes everyone; the survivor recognizes SOTERIA only after contact.** The Warden may confront any survivor; recognition of the duty voice is written only when `b41_contact` exists.
- `docs/CREATURE_STORY_BIBLE.md`: shared rules (one idea each, mechanics must exist, warnings in threes, names in the passage, no-portrait presentation via `portrait_id` plus a `field_note`, fixed combat vocabulary, appended alternatives at index 2 only); then Shutter Skitters, Salt Colossus, Reed Widow, Kilnback, Cinder Giant, and Cable Eater, each with what it owns, what it is, habitat and need, escalating warnings, the decision mapped onto the host scene's existing choices, a combat sketch (sequence, honest tells, critical condition from the thirteen, flee difficulty) for the four combat creatures, the durable consequence with its named consumer candidate, and a field note. Reward items named are all existing IDs. The two giants have no ID, profile, or portrait.
- Two consumers the plan asked for are now named: Kilnback rhythm → `lr_warm_windows` choice 1; Cinder Giant rescue → `rail_survivors`. Two more are proposed with the order-independence caveat: Reed Widow → `lr_voice_in_reeds` choice 0; Cable Eater → `rail_switch`, `rail_door`, or `bunker41_green_platform`, N02 to pick exactly one.
- `docs/ENEMY_DESIGN_BIBLE.md` §8 (new): scoped addendum registering the four creature IDs and two giants under the existing register and unique-axis rule. No casting, wardrobe, composition, or technical line changed; no artwork requested.
- Corrected during writing: Ash Stalkers are fought in the Underrail (`rail_nest`), not the flats; Mutant Crows are global; the Salt Flats and Glass Wastes have no creature today, and Leeches and Drones are sighted but never fought. The creature proposals are therefore also the fix for finding 2.
- Nothing mechanical changed: no data file, flag, contract, or test. `mechanical_snapshot.gd -- --diff` reports no differences. The suite reads **2,491 assertions, 0 failures** after N01; the ten added since N00's 2,481 are the concurrent engineer's, not this package's, since N01 touched no test.

## N02 completion record

- [NARRATIVE_CONSEQUENCE_MAP.md](NARRATIVE_CONSEQUENCE_MAP.md) holds the definitions, a card template N08 can lint, the six survivor states, **twelve return records** covering the five Living Road threads, Mara's treatment, Key possession, records and testimony, and the four creature consequences, then the consolidated dispositions (§6) and findings (§7).
- **112 design cards** in `docs/consequence_map/` A–F, one per event in the expanded configuration, ~53,000 words. Every indexed choice carries its intention, evidence, known cost, uncertain risk, exact success and failure fields, local significance, and durable effect with a named consumer.
- **Dispositions: 37 keep, 72 revise, 3 redesign.** The three redesigns are `final_gate_2`, `final_gate_3` (unreachable compatibility content) and `industrial_office`/`industrial_locker`-class evidence gaps recorded per card.
- **Findings: 151 — 30 P0, 102 P1, 19 P2**, each written as `problem → required change` so N03–N06 implement rather than re-diagnose.
- Two **cross-cutting engine findings** are recorded above the per-event list. X1: `_change_item` clamps at zero while `_apply_outcome` reports the loss unconditionally, so **all 25 negative item entries** are potential false costs that also print a payment that never happened. X2: no loaded flag means *heard the duty voice*.
- New measured tooling: `tools/choice_comparison.gd` (13,968 previews across six states, four kits and two levels, with RNG proven unchanged in all 48 blocks) and `builds/flag_index.md` (179 flags, 130 consumed, **49 orphans**, 0 dangling reads).
- **Reconciliation passed**: all 49 orphans are addressed by a card, no card contradicted the index, and one creature-bible suggestion was correctly refused as false history.
- Corrected during the package, both found by the cards: STORY_CANON §5 keyed voice recognition on `b41_contact`, which actually means *entered the bunker* in region 4 — the canon now specifies a new `b41_voice_heard` on the three `bunker41_static` outcomes and explains why the obvious substitute set over-fires. CREATURE_STORY_BIBLE's `rescued_engineer` consumer was retired for the same reason.
- Four **cross-batch escalations** were resolved centrally rather than by the batch that found them: the `b41_contact` canon error (three batches found it independently); the `rescued_engineer` consumer refused as false history; §5 record 6's consumer list corrected from two flags to the four `rustsea_green_line` actually reads, which is why that scene can name Mara to a stranger; and the record-versus-testimony question, where the canon now states that a record becomes testimony when a person reads it aloud, with the ending-key decision assigned to N06 rather than taken by a batch.
- Nothing mechanical changed: no data file, flag, contract, or test. `mechanical_snapshot.gd -- --diff` reports no differences; the suite is **2,481 assertions, 0 failures**.

## N03 completion record

Ten pilot scenes are playable, not drafted. The suite is **2,631 assertions, 0 failures**; layout 660, combat UI 0 failures, save-recovery UI 201; the data-package audit is unchanged at 9 checks, 8 passed, and its one pre-existing `global_stranger` discrepancy.

**The complete story, source to payoff.** `outskirts_child_radio` leaves one of four histories, and `lr_blue_van` opens on four genuinely different scenes because of it — not a changed greeting. A survivor who guided the family finds Talia waiting on a signal rather than hunting one, the children already out, their pencil line stopping exactly where the directions stopped. One who answered a dead channel watches her answer a recording the same way. One who only triangulated has never spoken to her and she has no reason to know their voice. The cadence check is offered only to a survivor who actually spoke; a fourth route, handing over the relay bearing for the compass, appears only for one who traced the signal and **withdraws when the compass is spent** rather than dangling a promise.

**The P0 false history is fixed concretely.** `lr_voice_in_reeds` and `lr_last_battery` both opened on Channel Nine transmitting even when the player's own failed repair destroyed the family's radio. That history now has its own scene: a child shouting across open water on a count, then beating a security door with conduit, while the survivor carries the dead set they broke.

**The other six.** `outskirts_bus` now shows the ration shapes and the first-aid bracket before the player picks a door, closing the plan §6 defect with prose alone and no field changed. `bunker41_cartographer` is a 245-word chapter in which Mara's ration visibly leaves the survivor's pack, and locks with an authored reason when there is no food to give. `marsh_lights` and `industrial_tank` carry the Reed Widow and the Kilnback as optional fights with the creature bible's warnings on screen first. `glass_shadow` turns a scavenged pack into a living, dust-sick traveler walked clear of the Cinder Giant's passage. `global_quiet` is unchanged, the compact control proving the new bands did not force every scene to grow.

**Verified, not asserted.** Each history was walked through the real engine before the tests were written; `_test_channel_nine_arc` and `_test_pilot_scene_batch` then locked all of it, including that reopening a passage repeats it exactly and rolls nothing.

**Two defects found and fixed in passing.** A flaky replay assertion, mine from M11: `run_id` is stamped from the wall clock and embedded in every XP award and encounter id, so a record and replay straddling a second boundary differed in identity while playing identically — roughly 2 in 60. The comparison now normalizes that identity rather than erasing the fields, so it still proves the same awards happened in the same order, and a test locks both halves. Separately, the allowlist claimed `scene_role` was stripped by the snapshot; it is hashed, which is the better behaviour, so the document was corrected rather than the tool.

**Assertions moved, all recorded in the allowlist:** combat choices 11 → 13, outcome passages 390 → 392 launch and 465 → 468 expanded, callback chapter shape exactly 3 → 3 or 4 with all three original paths still required, and the compact-band assertion split so it names the four scenes deliberately promoted. Checked choices did not move: both creature choices are combat.

**Known and carried forward:** an affordable `costs.items` is not surfaced on an unlocked choice anywhere in the game, so Mara's price is legible only from her label, the scene, and the lock when the pack is empty — N07 owns that UI. The baseline bodies of the three promoted `events.json` scenes would not satisfy `substantial` if the override layer were ever stripped; that is the existing pattern for all 76 baseline events but is now worth knowing.

## N04 completion record

Suite **2,734 assertions, 0 failures**; layout 660, combat UI 0 failures, save-recovery UI 201. **`tools/data_package_audit.gd` reports 9 checks, 9 passed, 0 discrepancies for the first time** — the `global_stranger` stranding defect that M11 found and N00 carried forward is repaired, so the release-blocker list is back to the seven owner and publishing tasks.

**Focused thread scheduling.** A story the player has engaged with can no longer be lost to random selection. Focus is *derived*, never stored — the thread of the earliest callback in `event_history` — so the save schema stays 5 and a run saved before N04 enrolls itself with no migration. The due chapter takes the first ordinary slot of its region, after the forced combat and supply guarantees and ahead of every competitor including `bunker41_rusted_hatch` at priority 10 and `rustsea_green_line` at 11, and it consumes no RNG. Measured over 200 seeded journeys with all five sources live: **focused-thread completion rose from 0.670 to 1.000**, independently reproduced at 100/100. Pacing is unchanged — exactly five events drawn per region, supply guaranteed 200/200 in every region, combat opportunities in the same 1–2 band — and the launch configuration is bit-identical.

**The engine that N03's prose needed**, landed with it: scene-role word bands, conditional passages for bodies and outcomes with per-event duplicate namespacing, `requires.forbids_flags` / `reason` / `hidden_when_locked`, the X1 false-cost repair, and `b41_voice_heard`.

**The §6 repairs.** The Mercy Key can no longer be offered at the gate after being given to Mara or surrendered to the Choir. The Ash ending now requires the founder's confession rather than mere affiliation, with a passage variant so it is true for a survivor whose Choir holds the Key instead. The Warden's refusal keeps its weapon level and unfired rather than raising it and then forgetting. `global_stranger` gained an ungated third choice. `smoke_bomb` gained a Salt Flats source, so `marsh_raiders` choice 2 is reachable in its own region for the first time.

**Creatures.** Reed Widow and Kilnback are defined, fought, and rendered: with no artwork the frame now reads the creature's name over its field note instead of `PORTRAIT / WIDOW`. The roster registration and the fallback landed together, deliberately — registering the ids before the fallback existed would have made the game display exactly the string the creature bible forbids.

**Corrections made to my own earlier work, both found by the agents doing it.** Consequence-map record 7 over-applied the Key forbid: it put `forbids_flags` on `bunker41_warden_remembers` choice 2, which accepts five kinds of evidence, so a survivor who transferred the Key but still carried testimony was locked out of a legitimate route and told it was about a Key they may never have held. The forbid now sits only on `bunker41_door_closes` choice 1, whose entire subject is the Key, with the label "You do not hold the Key" — true both of a survivor who never took it and of one who gave it away. The Warden's passage gains a variant instead, so a survivor whose Key is in Mara's hands answers with what they still carry. Separately, the allowlist claimed `scene_role` was stripped from the mechanical snapshot; it is hashed, which is the better behaviour, so the document was corrected rather than the tool.

**Recorded limitations, not hidden.** The window widening is inert: every chapter gained a region of slack and the loader enforces it, but across 800 journeys no chapter has ever resolved there, because the reservation means none loses its slot. Making it engage would require `lr_callback_region_N` to become a per-region-visit gate rather than a run-permanent flag, changing the one-callback-per-region contract. And only three of the five threads can hold focus in a run that resolved an Outskirts source, since focus goes to the first chapter that resolves and three threads open in region 1; all five still complete 1.000 in isolation, so every arc is provable across different histories, which is what plan §4 asks. Whether focus should instead follow the most recent engagement is N06's call. One residual: a survivor whose only evidence was the Key can still invoke it after transferring, because a flag cannot be cleared and no per-flag clearing contract exists.

## N05 completion record

Suite **2,766 assertions, 0 failures**; layout 660; combat UI 0 failures; save-recovery UI 201; data-package audit **9 checks, 9 passed, 0 discrepancies**.

**52 of the 73 ordinary scenes were rewritten**: 43 introductions, 138 outcome passages, 20 promotions to the `substantial` band, and 34 mechanical field changes. The rest were left alone because their cards recorded no finding and their passages already work — the plan is explicit that compact scenes which work should stay compact, and treating the bands as quotas would have been the wrong reading.

**All six P0 findings on ordinary scenes are closed.** Two false costs moved from inside an outcome, where `_change_item` silently clamps them and the player is never told, to `requires`/`costs` where the choice previews and gates honestly (`global_trader`, `rail_hunters`). One success that asserted knowledge most runs never acquire became a conditional passage (`flats_convoy`). `global_stranger` was repaired in N04. `flats_toll` was fixed in prose rather than fields, which is the better answer there: the toll's demand is real and the clamp is the survivor's poverty, so the passage now reads true either way — "she prices you at one ration and takes what your pack will give up". The sixth, `glass_pilgrim`, is deliberately carried to N06, which owns its only honest consumer.

**Four orphan flags retired and two given consumers.** `decoded_numbers`, `underrail_bearing`, `restarted_filter` and `silenced_siren` had no reader anywhere in either configuration and are gone; `read_bone_warning` and `crater_warning` now drive `body_variants` in `flats_mirage` and `flats_crater`.

**How it was run.** Seven regional writers and seven independent adversarial checkers, paired so each region was verified as soon as it was drafted. Agents produced patch files rather than editing the repository, because three groups share one override file, four share the other, and all of them write `scene_role` into `data/events.json`; a deterministic applier merged them one group at a time behind a dry run and a rollback copy.

**What the verification actually caught**, which is why it was worth the cost: four of the seven regions failed their check. Three groups had wrong mechanical field paths that would have written junk keys into `data/events.json` and silently dropped the fix; two scenes used an event-level block the applier ignored without a word, turning them into no-ops. **That silent discard was my applier's bug, not the writers'** — it now rejects unknown keys, supports the event-level form, and normalizes or refuses absolute paths. Hardening it immediately caught two more broken paths in a region whose own checker had passed it, so the applier, not the reviewer, is the real backstop.

**Two verifier findings were themselves wrong and were dismissed with evidence.** One blocking claim quoted an injury sentence that does not appear anywhere in the patch it was reviewing; the actual passage narrates only a loss downstream, which matches its `clean_water -1`. Another called `glass_pilgrim`'s introduction a broken promise, but the passage is in the belief register that STORY_CANON §5 permits — attributed to the pilgrim and explicitly unproven — and its fields match its prose. Findings from a reviewer are evidence, not verdicts.

**Assertion moved:** the N03-era check pinning the exact four scenes that declare a `scene_role` was replaced by invariants — a declared role is a known role other than the implicit default, a promoted scene genuinely carries a longer introduction than compact allows, and the pilot promotions survive. Pinning a list broke on every package and taught nothing.

## N05b completion record — the Kilnback, measured and retuned

Run alongside N05 in files N05 did not touch. The encounter benchmark was extended to all 15 adversaries (**666,000** encounters) and priced both creature fights against the safer sibling choice that pays the same items. The Reed Widow at 30 XP is generous but coherent: zero deaths in 10,000 behaviour-aware encounters, so the fight is rational at any XP and the 30 is surplus, left as is. **The Kilnback at 65 XP was a mistake button**: the early builds that actually reach region 3 won 0.238 and died 0.762 against a Wits-favorable listening route that paid the identical reward for a 2-XP check. The benchmark's own verdict was that no XP value could fix it, because the mismatch was between a second-hardest-in-the-package profile and a region-3 placement.

The root cause was a specification error in my creature bible, which anchored the Kilnback's HP to "the largest of the four, below the Warden" — to the other creatures and to a 550-HP machine at the far end of the game, and to nothing in its own region. **The retune re-anchored it to the Hollow Industrial Zone's roster**: threat 16, 300 HP, 62–88 damage, 50 XP, above the Scavengers on every axis and below the Cult and Hunters of later regions, plus a `scrap_parts 2` victory premium the listening route cannot pay. **Re-measured**: early-tier win rose from 0.238 to **0.552**, death fell from 0.762 to **0.448**, and the creature now sits between Bog Raiders and Glass Cult in the difficulty ordering, where a region-3 apex belongs. It is still decided by kit — Buckler 0.84 against Shock Probe 0.19 — and that is coherent: the Wits build it punishes is the build the scene's listening route already serves. On XP alone it is still not the rational choice; it is now a *choice*, which is all an optional alternative owes.

The bible now carries the rule the sketch was missing, and flags that the Skitters and Cable Eater sketches still carry the same cross-creature anchors and must be re-anchored to their own regions before their profiles are written. Both creatures are now locked in `tests/fixtures/combat_v2_content_contract.json`, so a later drift in their HP, damage or XP fails a test instead of passing silently. Suite **2,768 assertions, 0 failures**; all other gates unchanged.

This work was interrupted twice by process exits and once by a rate limit, and resumed each time from the recorded state rather than from memory; the only thing the last interruption left undone was one pinned assertion and the re-measurement itself, both completed here.

## N06a completion record — current implementation reconciled

Completed 14 September 2026 against the effective loaded content, `game_engine.gd`, the N06 tests, and consequence-map §5b. This was a targeted reconciliation; it did not regenerate the dossiers, canon, cards, or baseline.

| Contract | Status | Evidence |
| --- | --- | --- |
| Finale split | **Present and verified** | `final_gate_1` defaults all five resolved outcomes to `final_gate_2`, with `b41_contact` routing variants to `bunker41_warden_remembers`; `test_runner.gd` checks every outcome, the heard-voice-only case, and both resulting chains. `final_gate_2` → `final_gate_3` and `ledger_ending_citadel` are now reachable. |
| Prepared/pending finale route | **Present and verified** | Added two real-engine regressions: a restored prepared gate choice reaches standard screening without Bunker contact and the Bunker finale with it. The route is resolved from pre-outcome flags, so no new save field is needed. |
| Voice recognition | **Present and verified** | `b41_voice_heard` changes the gate/Warden passage but does not select the Bunker finale; both content and regression coverage confirm it. |
| First-resolved callback focus | **Present and verified** | `_focused_callback_thread()` derives focus from the earliest Living Road event in `event_history`; existing tests cover advancement, competing openers, terminal chapters, and launch compatibility. Added a schema-4 migration/restoration regression proving an old history enrolls without a new field. Keep first-resolved focus; do not reopen the rejected most-recent rule. |
| Pilgrim disk | **Present but incomplete** | `bunker41_door_closes` Witness text reads the disk when it is the highest applicable variant; a rescued-survivors variant intentionally outranks it and is tested. N06c must give disk carriers a reachable payoff in another ending or the standard screening, and check first-match masking across the complete priority table. |
| Shutter Skitters and Cable Eater | **Missing** | The loaded roster remains 15: Widow and Kilnback exist; `outskirts_apartment` and `rail_signal` still have two choices. N06d owns the two appended fights, profiles, and the Cable Eater late-consumer fallback. |

Validation: `tools/data_package_audit.gd` — **9/9 checks passed, 0 discrepancies**. `tests/test_runner.gd` executed **2,918 assertions**. All N06a routing, focus, migration, and pilgrim assertions passed, including the two added restored-prepared-route assertions. The suite still reports **20 unrelated failures** in treatment/checkpoint, terminal receipt/profile persistence, hidden-choice UI indexing, and combat-save persistence. Those are existing failures in the current worktree and prevent a whole-suite pass; they did not fail an N06a assertion. The headless environment also could not create `user://logs`, which did not stop either run.

**Residual ownership after N06c:** N06d — Skitters/Cable Eater plus regional balance and late consumer; N07 — visible costs/results, reading UI, and Chronicle denominator. N08 reruns affected regression checks once those batches change contracts.

## N06b completion record — five returning stories

Completed 14 September 2026. The review read every choice and success/failure/refusal outcome across each source and its three callback chapters, then checked current effective content rather than rewriting scenes to meet a quota. Source flags remain the state contract; no routes, costs, rewards, item requirements, callback windows, or scheduler rules changed in this package.

| Arc / disposition | Opening need → changed relationship → final decision → local resolution | State, exact reward, recurring element, fallback |
| --- | --- | --- |
| Channel Nine — **targeted revision, verified** | A family needs a reliable signal → Talia distinguishes the survivor's voice, a traced bearing, distance, and bad directions → the last battery is spent on access, leverage, or separation → the family receives a reunion, a changed arrangement, or an honest lost contact. | Source `lr_channel_*`; returns `lr_family_*`; successful final rewards remain Dust Cloak or Lucky Die. Radio cadence/counting moves from a means of contact to a choice about access. No offscreen reunion fallback. Added a `lr_family_reunited` Last Battery opening so a reunited family arrives together and acts together. |
| Quiet Column — **targeted revision, verified** | Dena needs to move families without creating another beacon → her procedural trust meets Perrin's chosen warning work → flare, siren, or quiet becomes a decision about who receives danger and warning → the column crosses, scatters, or stays hidden with the result named. | Source `lr_siren_*`; returns `lr_column_*`, `lr_perrin_*`, `lr_dena_stayed`; successful final rewards remain Flare Gun + 3 Shotgun Shells or Rebar Spear. Rotor, bell, and chosen alarm carry the theme. No invented reunion fallback. Revised `lr_bellkeepers_son`: Perrin tied the rope, volunteered, and has already responded to Dena's signal, so he is a participant rather than only a rescue objective. |
| Road Debt — **keep, verified** | Lio needs an account he can defend → the survivor's evidence can earn belief, invite accusation, or decline judgment → the ledger becomes a disputed public record → the final toll limits the court, preserves a verified record, or leaves it running without the survivor. | Source `lr_bandit_*`; returns `lr_lio_*`, `lr_ledger_*`, `lr_road_*`; successful final rewards remain Nail Bat or Hunting Rifle + 3 Rifle Rounds. Bottles, rows, and marks change from private grief to public procedure. No Lio appearance without the source; no fallback claim. |
| Water Commons — **keep, verified** | Iven needs a line that can serve people rather than an owner → repair, stripping, contamination, or failure changes what he can ask → surface allocation becomes a practical dispute over current and future water → the Underrail valve becomes common, decentralized, guarded, or left to others. | Source `lr_filter_*`; returns `lr_water_*` and `lr_underrail_water_reserved`; successful final rewards remain Tire Armor or Scavenger Rig. Cups, schedules, housings, and pressure make the abstraction physical. No unrelated water payoff is invented; the immediate source rewards stand. |
| Nightfire Caravan — **keep, verified** | Noma needs a rule for warmth under shortage → the survivor is admitted, repaid, kept at a distance, or asked to help a patient → the mechanic's case tests whether hospitality includes disputed people → the train shares fire, restores a second carriage, or closes its doors. | Source `lr_nightfire_*`; returns `lr_caravan_*`; successful final rewards remain Rusted Hatchet or Stun Baton. The bedroll/list, bowls, and heater change meaning as the caravan grows. No false claim that a declined or surrendered person is safe; the final state records the arrangement that survives. |

Focused verification added to `tests/test_runner.gd`:

- Every first callback rejects a no-source run.
- Every arc has different opening text for a helpful versus adverse/source-distance history.
- Every final chapter has different present-conflict text for two relevant earlier states.
- Perrin's opening is locked as an informed decision: he tied the rope, volunteered for the roof, and responds to Dena's signal.

All 16 N06b assertions passed in the 14 September run. The focused suite now reports **2,934 assertions** and retains the same **20 unrelated existing failures** recorded under N06a; no N06b assertion failed. `tools/data_package_audit.gd` remains **9/9 passed, 0 discrepancies**. The headless environment still cannot create `user://logs`, without preventing either check.

## N06c completion record — bounded finale and promise matrix

Completed 14 September 2026. The revision keeps the N06a route split and does not add a save field or an invented `remove_flags` contract. It makes object possession explicit at the Warden, gives the disk a non-maskable factual payoff, and preserves the distinct meanings of the five endings: **Silence** enters by taking the opening, **Mercy** presents an inherited object without claiming its authority, **Witness** makes erasure public, **Ash** exposes the founder's confession, and the standard route either forces, understands, persuades, or declines the Citadel's last mechanism.

| State at the last approach | Route / priority | Verified player-facing result |
| --- | --- | --- |
| No Bunker contact | `final_gate_1` → `final_gate_2` → `final_gate_3` | The standard survivor can blind, break, or cross the Warden, then force, use earned controller knowledge, persuade a guard after disabling the machine, or step back safely. The new withdrawal says the survivor can “turn from the wall with your life.” |
| Heard voice only | Standard route; recognition prose outranks no route | The salt-flats voice is recognized at the gate and screening, but all five first-gate outcomes still select standard screening. It does not manufacture Bunker contact or Witness access. |
| Bunker contact | `final_gate_1` → `bunker41_warden_remembers` → `bunker41_door_closes` | The Warden asks what the survivor will do with an incomplete record; the four door choices retain Silence, Mercy, Witness, and Ash. The Cinder Wives remain unexplained. |
| Key held | Dedicated `Present the Mercy Key` Warden choice, then Mercy remains open | The Warden sees an authorization and casualty count; the survivor refuses to claim the authority. At the door, the Key is “evidence, not permission.” |
| Key transferred, no other evidence | Both Warden evidence choices locked | The historical acquisition flag remains for truthful history, but cannot present an object the survivor no longer holds. The door's Mercy choice remains locked too. |
| Key transferred + independent testimony | Generic Warden record choice | The survivor can still answer with people, orders, ledgers, or names; its passage says the core is “no longer yours to raise.” This preserves a legitimate testimony route without a global evidence ban. |
| No Key, no independent evidence | Both Warden evidence choices locked | Refusal and the Warden fight still remain; the game does not invent proof. |
| `pilgrim_disk` plus another high-priority ending state | Dedicated Chronicle recap after `final_gate_1` | **The Unlisted Name** records that the outer reader takes the scratched name as an intake entry, “not permission,” even when rescued-survivor Witness prose properly outranks the disk. The disk never grants Bunker history or Witness eligibility. |
| `kilnback_rhythm_known` / `cinder_traveler_rescued` | Existing later consumers, with no-source controls | Kilnback knowledge opens the safe, certain second-heater route at `lr_warm_windows` and pays a Stun Baton; the rescued traveler appears at `rail_survivors`, speaks for the survivor, and pays a field Medkit. Both routes are hidden without their source state. |
| Followed thread resolved or unresolved | Local callback resolution, then bounded ending recap | The finale does not claim a road thread resolved unless its own ending flag establishes it. The Road Chronicle retains the concrete callback account; no end passage pretends an unscheduled callback became bittersweet closure. |

**First-match policy.** Passage variants remain first-match, pre-outcome, and deterministic. Rescued survivors still outrank the pilgrim disk in Witness wording because a living chorus is the immediate admission action. The disk moves to a separate, guaranteed Chronicle fact at the preceding outer gate, so it cannot disappear when a higher-priority variant wins. No all-flags compositor was added.

**Lethal audit.** The loaded total remains the original **nine**: six resolution branches at `final_gate_3`, `bunker41_door_breathes` choice 2, `rustsea_false_coordinates` choice 2, and `rustsea_salt_crown_wake` choice 2. Bunker and Rust-Sea cards already show scale, failed ordinary protection, and an open retreat. The final gate now also names the scored closing seam, live controller, recovering weapon, and open outer court, and adds the certain `Step back from the seam` withdrawal. No lethal record was added. The Shutter Skitters and Cable Eater fights remain visibly assigned to N06d and are not counted here.

Focused verification added to `tests/test_runner.gd` covers all four Key cases, held-object presentation, the disk's guaranteed Chronicle record despite competing Bunker history, Kilnback's useful route plus no-source fallback, Cinder Giant recognition plus no-source fallback, and the final-gate withdrawal. The Chronicle denominator and data-package audit now expect the intentionally added disk chapter (11 launch / 26 expansion).

Validation: JSON parsing succeeded; `tools/data_package_audit.gd` passed **9/9** with **0 discrepancies**; the suite ran **2,945 assertions** with the same **20 unrelated existing failures** in treatment, checkpoint/terminal persistence, hidden-choice UI, and combat-save persistence. No N06c assertion failed. The headless environment still cannot create `user://logs`, but both checks completed.

## N06d completion record — remaining creature fights

- Added `shutter_skitters` / `enemy_skitters` and `cable_eater` / `enemy_cable_eater`, bringing the roster from 15 to the planned **17**. Both have stable combat IDs separate from their portrait IDs, sequences with defined tells, organic classifications, field notes, critical conditions, and flee difficulties.
- `outskirts_apartment` and `rail_signal` retain their original two choices verbatim and append the fleeable fights at index 2. Effective prose names each creature before the decision and gives its escalating physical warnings. Skitters clear the stairwell locally and pay the same medkit/canned-meat cache as search. Cable Eater pays three scrap parts and writes `citadel_signal`.
- Cable's guaranteed, ordering-safe consumer is `final_gate_3` choice 1: it accepts `citadel_signal` as controller knowledge after every Underrail draw. The regression covers `rail_door` before `rail_signal`, then verifies the controller opens only with the earned signal fact. It does not write Bunker contact or Witness evidence.
- The Outskirts and Underrail now each have three combat candidates, preserving Bandits/Dogs and Hunters/Ash Stalkers. The existing scheduler has always capped selected opportunities at two per five-event regional run; the seeded regional test continues to verify that runtime cap rather than deleting an authored route to force a smaller candidate pool.

Validation: JSON parsing succeeded; `tools/data_package_audit.gd` passed **9/9** with 0 discrepancies. `tests/test_runner.gd` ran **3,004 assertions** and verifies the six creature scenes, both new victories and flee outcomes, portrait fallback, acquisition, consumers, and the scheduling cap; it retains the same **20 unrelated existing failures** in treatment, checkpoint/terminal persistence, hidden-choice UI indexing, and combat-save persistence. `builds/n06d_creatures.json` records a completed deterministic 200-seed, 20,000-encounter two-creature sample; re-run it with more seeds before a later difficulty retune.

## N07 completion record — readable decisions and factual delivery

- Every choice with an authored `costs` block now displays a **GUARANTEED COST** line before its odds, combat information, certainty marker, or lock explanation. The same complete text is the choice control's accessibility name, so an affordable price is read aloud as well as shown. Costs remain separate from uncertain consequences.
- Resolution receipts now begin with **COMMITTED RECEIPT**. The engine records only the item and pressure changes it actually applied, including an entry cost carried into combat victory or Flee; a result with no tracked change says so plainly. Opening a receipt still only reads the already-committed `last_result` and cannot grant, spend, or roll anything.
- The existing typewriter keeps instant reveal, skip, reduced-motion instant display, and saved interrupted position. Result, recap, Chronicle, inventory, item-detail, death, and victory readers retain independent scrolling with navigation outside the scroll body. Popup bounds are re-applied after Godot's deferred minimum-size layout, keeping compact phone sheets inside the safe rectangle while preserving their scrollable content and pinned actions.
- Chronicle audit: the live content contains **11 launch / 26 expanded definitions** and **48 expanded variants**. The plan's count of 25 became stale when N06c added the non-maskable `ledger_pilgrim_disk` factual recap. Every definition has an existing trigger, non-empty spoiler-safe hint, and locally unique variant IDs; the existing reader continues to retain separate accounts across runs without carrying survivor state into gameplay.
- Existing presentation was reviewed without a redesign: portrait fallback uses authored names/field notes rather than raw combat IDs, and the combat/result path uses the committed victory or flee state. No story text was shortened or replaced with generated summaries.

Validation: `tests/test_runner.gd` ran **3,008 assertions**; the N07 paid-choice receipt, capped-value receipt, choice-row accessibility/cost, and 26-definition/48-variant Chronicle assertions pass. The run retains the same **20 unrelated existing failures** in treatment, checkpoint/terminal persistence, hidden-choice UI indexing, and combat-save persistence. `tests/layout_ui_smoke.gd` passed **1,069 assertions, 0 failures** across the compact phone matrix at normal and Large text. `tools/data_package_audit.gd` remains **9/9 passed, 0 discrepancies**.

## N08 completion record — integration evidence

The integration pass added one preventive loader rule: `body_variants` cannot declare `next_event`; only an outcome variant may route a survivor. The probe is in the core suite, so a future text-only edit cannot silently become a routing change.

**Current loaded scope after E02.** Launch: **97 events, 246 choices, 402 outcomes, 11 Chronicle definitions, 17 adversaries**. Expanded: **112 events, 298 choices, 485 outcomes, 26 Chronicle definitions, 17 adversaries**. The original 25-expanded-entry expectation is a justified departure: N06c added the factual `ledger_pilgrim_disk` entry so a disk carrier's payoff cannot be masked by finale-variant priority. Both configurations retain three intentional compatibility/fallback unreachable records; the dossier identifies them.

| Evidence | Configuration / history / seed | Expected difference or contract | Command and result | Artifact |
|---|---|---|---|---|
| Content boundary and counts | Launch + expanded | Both explicit configurations load with the final counts above | `content_dossier.gd` passed | `builds/content_dossier.json`, `builds/content_dossier_launch.md`, `builds/content_dossier_expanded.md` |
| JSON, references, prose, legal choices, acquisition | Launch plus expansion boundary | No bad reference, repeated/prohibited passage, inaccessible item, or stranded event | `data_package_audit.gd`: **9/9**, 0 discrepancies | console result; current content dossier |
| Baseline comparison | Launch + expanded | Only N04–N06 documented mechanics differ from N00 | `mechanical_snapshot.gd -- --diff`: 196 expected deltas across listed package scope; no N07/N08 data change | `builds/mechanical_snapshot_narrative_baseline.json`; allowlist in `CONTENT_AUTHORING.md` |
| Threads, ownership, legacy, receipt | Both configurations; 200 isolated callback journeys, 60 competing-hook journeys; N06c Key/disk states; N06d door-before-signal order | Five threads complete with their own source facts; no false history; object possession and evidence stay distinct; costs/rewards/Chronicle receipts apply once | `test_runner.gd`: **3,009 assertions**; all N08-related checks pass | suite output; focused fixtures in `tests/test_runner.gd` |
| Save/retry/force-close presentation | 360×640, 540×960, 540×1200 at Large text | Prepared/committed action cannot duplicate a reward or escape its receipt | `action_ui_smoke.gd`: **201 assertions, 0 failures** | console result |
| Reader, combat, touch, portrait fallback | Compact/tall desktop viewports; normal/Large text; prepared and live combat | Scroll/reveal/reopen, controls, no-portrait combat, and typewriter/touch behavior remain reachable | layout **1,069 assertions, 0 failures**; combat UI **0 failures**; touch **32 assertions, 0 failures** | console results; presentation fixtures |
| Determinism and full journey | Seed 4242 replay; 1,000 legal-action seeds | Same seed and decisions reproduce state; legal runs never strand or recovery-mismatch | `full_run_harness.gd -- --soak 1000`: replay true; 0 engine errors; 0/25 recovery mismatches | `builds/full_run_harness.json`, `builds/run_record_sample.json` |
| Creature balance and resource use | Reused N06d 200-seed × 10-build samples for each new adversary | No reward/roster/combat data changed by N07/N08; retain current fight-length, resource, fallback evidence | Shutter Skitters: 10,000 samples, 5.07 victory exchanges, 114.3 mean HP, 1.27 ammo, 0 fallback. Cable Eater: 10,000, 8.04, 208.3, 2.34, 0 fallback. | `builds/n06d_creatures.json`, `builds/n08_balance_report.md` |

The full core suite retains **20 existing unrelated failures** in treatment/checkpoint and terminal persistence, hidden-choice indexing, and combat-save persistence. They predate this package and none is in the N08 routing, receipt, story, or presentation assertions. Headless output also reports unavailable user-log and certificate-store paths; neither prevented the tests. Human enjoyment and real-phone behavior remain deliberately separate for N09.

## Next ready task: N09 — human reading and real-phone gate

Use the N08 artifacts for factual setup, then test reading rhythm, emotional clarity, and device behavior with people and a real phone. Do not infer human enjoyment or phone lifecycle safety from the desktop automation above.

### The old N05 handoff, for reference

Expand the ordinary scenes region by region, using the batch cards in `consequence_map/` and the 102 P1 findings consolidated in the map's §7. The pilot proved the shape: scene roles, conditional passages, evidence before commitment, and rewards that fulfil the intention. Work in regional batches rather than rewriting everything at once, keep the mechanical-change allowlist current as you go, and run `tools/mechanical_snapshot.gd -- --diff` before each batch.

### The old N04 handoff, for reference

The passage, gating, and budget engine landed with N03, along with the X1 false-cost repair, `b41_voice_heard`, and the Reed Widow and Kilnback profiles. What remains: focused scheduling and its fallback from plan §4, so a followed thread reserves a slot and cannot be lost to random selection; the remaining repairs from plan §6, including Key transfer and possession, the depleted-action legality that `global_stranger` still fails, and the Warden passage; the Shutter Skitters and Cable Eater with their host choices; the deliberate missing-portrait presentation and the roster registration deliberately deferred with it; and enrollment of runs saved before the expansion. Consequence-map §5 records 7 and 12 and the batch D and E cards specify most of it.

### The old N03 handoff, for reference

Deliver one complete Living Road arc end to end, plus the varied scenes around it, so the shape is proven before N05 and N06 scale it. Start with Channel Nine: `outskirts_child_radio` → `lr_blue_van` → `lr_voice_in_reeds` → `lr_last_battery`, building exactly what §5 record 1 and the batch A and F cards specify — the four source flags, the introduction variants per history, the gated choice 0, the new choice 3 that spends the signal compass, and the reserved-slot scheduling. N04 builds the two engine extensions the records assume (conditional passages; `requires.forbids_flags` / `reason` / `hidden_when_locked`) and fixes X1 and X2, so N03 and N04 are built alongside each other. Before any content edit run `tools/mechanical_snapshot.gd -- --diff` and record the expected differences in the allowlist in `CONTENT_AUTHORING.md` first.

### The old N02 handoff, for reference

Create `docs/NARRATIVE_CONSEQUENCE_MAP.md`: a design card for every one of the 112 target events plus the four appended creature choices, giving each indexed choice its intention, evidence, known cost, uncertain risk, exact success reward, failure aftermath, local significance, and durable effect; for every major commitment fill the eleven-line return record from plan §4; compare healthy, hungry, injured, irradiated, supplied, and depleted survivors across builds using the dossiers; map critical fallback, combat victory/flee, refusal, delayed eligibility, and ending variants; and give every event a keep / revise / redesign disposition with P0 / P1 / P2 priority. Start from the canon's §10 table and the creature bible's "What N02 owes" section, which together list every promise that still lacks a consumer or a cost. Quote the canon; do not re-derive it.

## Working notes for the next session

- The `opus-coder` agent definition in `.claude/agents/` registers only on session start. N00 ran implementation agents as `model: opus` without it; restart before N03/N04.
- Do not run `tools/rewrite_literary_content.js`.
- Prose edits for baseline events belong in the override files; mechanics in `data/events.json` with the allowlist; callbacks in `data/living_road_events.json`.
- Before any content edit in later packages, run `tools/mechanical_snapshot.gd -- --diff` and record the expected differences in the allowlist first.
