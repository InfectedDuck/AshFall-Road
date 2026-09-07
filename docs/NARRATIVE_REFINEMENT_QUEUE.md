# Narrative refinement queue

Status: **N00 and N01 complete; N02 is next.** Governing plan: [NARRATIVE_REFINEMENT_PLAN.md](NARRATIVE_REFINEMENT_PLAN.md). The completed M-series (M00–M11) is recorded in [IMPLEMENTATION_QUEUE.md](IMPLEMENTATION_QUEUE.md) and is not repeated here.

This file records repository facts and the next ready task. Editing it changes no content, flag, or save format.

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
| `tools/data_package_audit.gd` | 9 checks, 8 passed, **1 discrepancy** (`global_stranger`) |
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
| N02 Design every choice, reward, and return | **Next** | — |
| N03 Complete sample arc and varied scenes | Queued | Channel Nine first: `outskirts_child_radio` → `lr_blue_van` → `lr_voice_in_reeds` → `lr_last_battery` |
| N04 Richer text, memory, and reliable returns | Queued | Build alongside N03 |
| N05 Expand ordinary scenes by region | Queued | — |
| N06 Expand returning stories and major arcs | Queued | Includes the dead-finale decision (finding 1) |
| N07 Reading and reward delivery | Queued | — |
| N08 Verify the expanded story | Queued | — |
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

## Next ready task: N02

Create `docs/NARRATIVE_CONSEQUENCE_MAP.md`: a design card for every one of the 112 target events plus the four appended creature choices, giving each indexed choice its intention, evidence, known cost, uncertain risk, exact success reward, failure aftermath, local significance, and durable effect; for every major commitment fill the eleven-line return record from plan §4; compare healthy, hungry, injured, irradiated, supplied, and depleted survivors across builds using the dossiers; map critical fallback, combat victory/flee, refusal, delayed eligibility, and ending variants; and give every event a keep / revise / redesign disposition with P0 / P1 / P2 priority. Start from the canon's §10 table and the creature bible's "What N02 owes" section, which together list every promise that still lacks a consumer or a cost. Quote the canon; do not re-derive it.

## Working notes for the next session

- The `opus-coder` agent definition in `.claude/agents/` registers only on session start. N00 ran implementation agents as `model: opus` without it; restart before N03/N04.
- Do not run `tools/rewrite_literary_content.js`.
- Prose edits for baseline events belong in the override files; mechanics in `data/events.json` with the allowlist; callbacks in `data/living_road_events.json`.
- Before any content edit in later packages, run `tools/mechanical_snapshot.gd -- --diff` and record the expected differences in the allowlist first.
