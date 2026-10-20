# Balance fix plan — October 2026

Source evidence: `builds/playthrough/report.md`, produced by `tools/playthrough_analytics.gd` (10,000 simulated runs, 2,000 per player model, combat rules v4, Living Road on). These are simulated player models, not human estimates. Every phase below ends by re-running the same harness and comparing against the baseline.

## Baseline (20 October 2026)

| Model | Win | Reach R2 | Mean regions | Fights/run |
|---|---|---|---|---|
| random (no upkeep) | 0.3% | 93% | 3.62 | 1.3 |
| novice | 7.0% | 94% | 3.96 | 1.6 |
| cautious (never fights) | **99.5%** | 100% | 6.00 | 0.0 |
| informed | 40% | 95% | 4.39 | 2.9 |
| aggressive | 0.3% | 93% | 3.15 | 3.3 |

## Decisions needed before tuning

1. **Should a no-combat run be able to win?** Recommended: possible but rare — cautious ≤ 20% wins, below informed. Today it is the best strategy by far.
2. **Which ending is canonical?** Today every run that reaches the Glass Wastes gets `b41_contact`, so `final_gate_2`, `final_gate_3` and the Citadel Guard are never reached. Recommended: Bunker 41 ending only for runs that engaged with the Bunker 41 arc, and the original gate for the rest.
3. **Target win rate per model.** Recommended starting targets: novice 2–5% (matches the 3–5% human target), informed 15–25%, cautious 5–20%, aggressive 2–8%, random < 1%. Reach R2 is 93–95% today against a stated 50–70% target. Recommended: keep R1 forgiving for onboarding and relax that target to 80–90%, unless you want the opening region harder.

## Phase 0 — Measurement guardrails (½ day)

- Commit `tools/playthrough_analytics.gd` and `tools/playthrough_report.py`; save the current `builds/playthrough/*.json` as `docs/baselines/playthrough_2026-10-20/`.
- Add `--check` to the report script: exit 1 when a model falls outside the agreed target bands, so each tuning step gets a pass/fail.
- Harness improvements so later measurements are trustworthy:
  - Informed fight decisions use a quick `combat_balance.gd`-style simulation of the actual fight instead of the current rough estimate (it currently over-commits to Toll Gang and Road Bandits).
  - Optional cross-run memory (`apply_cross_run_unlocks`) so Tess/Mina chapters can appear.
  - Record per-hit damage as a share of max HP, to test the burst-death hypothesis in Phase 3.
- Keep the old `full_run_harness.gd` soak as a robustness check; it works again after the `%%` fix in `narrative_combat.gd`.

## Phase 1 — Event selection and dead content (1–2 days)

Do this first. Every later number depends on which events players actually see.

**Problem.** `GameEngine._select_next_event` keeps only the eligible events with the highest `narrative_priority`. Story events (Bunker 41, Living Road, betrayal, Rhea, hunts) are global and prioritised, so they take nearly every free slot. In Salt Flats, 9 of 10 regional events never appeared in 10,000 runs; only the forced-combat (`flats_toll`) and forced-supply (`flats_nightfire`) slots reach the regional pool. Overall, 30 of 153 events were never seen and 28 more appeared in under 1% of runs.

**Changes.**
1. Only *continuations* (events gated on a flag from an earlier chapter) keep the absolute reservation. Thread *openers* (`rhea_meeting`, `betrayal_vex_meeting`, `lr_blue_van`, `bunker41_static`, …) join the weighted draw with a weight boost instead.
2. Cap story chapters at 2 of the 5 slots per region; the rest draw from the region pool and generic globals. The forced combat and supply slots keep their precedence, as `CONTENT_AUTHORING.md` already specifies.
3. Update `CONTENT_AUTHORING.md` (`narrative_priority` paragraph) to describe the new rule.

**Ending routing.** Every choice in `bunker41_rusted_hatch`, including "Mark it and leave", adds `b41_contact`, and `final_gate_1` routes to `bunker41_warden_remembers` on that flag. Under the recommendation for decision 2: drop `b41_contact` from "Mark it and leave", or require a deeper Bunker 41 flag in the `final_gate_1` variants.

**Done when:**
- every regional pool event appears in at least 1% of runs;
- in every region, at least 50% of events come from the regional pool;
- `final_gate_2` is reached by a meaningful share of finishing runs;
- the Citadel Guard is fought at least occasionally.

Add an engine test asserting the regional share over a fixed seed set, so a future chain cannot silently crowd a region out again.

## Phase 2 — Make fighting worth it and avoidance cost something (2–3 days)

**Problem.**
- Every fight has a non-combat alternative, and the alternatives are nearly free: a 50–60% roll whose failure costs a few Fatigue or one food item (`flats_toll` "Circle them", `industrial_scavs` "Slip through", `outskirts_bandits` "Break through the alley").
- A moderate fight costs about half of a 300-HP survivor's health (Road Bandits about 146 HP lost, Toll Gang about 170).
- In the novice comparison, choosing the fight lowered the chance of reaching the next region by 48–99 points in every combat scene.
- Levels are not needed to win: the never-fight model finishes at level 4.9.

**Changes** (in this order, re-measuring after each):
1. **Price the avoid routes.** In combat scenes, give failed avoid checks real costs (HP 20–40, a harmful condition, or losing loot that only the fight pays). Successful avoid routes keep a small cost (Fatigue or time).
2. **Make LOW and MODERATE fights cheaper for good play.** Target: an informed survivor at the expected level loses ≤ 25% HP against LOW and ≤ 40% against MODERATE threats, matching the "strong gear defeats weak enemies in 2–3 attacks" target in `BALANCE_WORKFLOW.md`. Prefer lowering enemy HP over damage, so fights stay short.
3. **Give levels a job late in the run.** Raise the difficulty of a few R4–R6 checks, or add stat requirements to key late choices, so a level-4 survivor with no combat XP fails noticeably more often than a level-6 one.
4. **Make victory loot worth the risk** where the fight drops only items the avoid route also gives (see the `kilnback` and `reed_widow` notes in `RUN_VERIFICATION.md`).

**Done when:**
- informed wins more often than cautious;
- cautious wins at most 20% (or whatever decision 1 sets);
- for LOW/MODERATE fights in the novice comparison, the fight-vs-avoid gap in reaching the next region is within ±15 points.

## Phase 3 — Enemy tuning (1–2 days)

| Issue | Evidence | Proposed change | Target |
|---|---|---|---|
| Toll Gang is the deadliest enemy but labelled MODERATE | Informed 36.5% death, about 1/3 of all informed deaths. Always forced in R2 through `flats_toll`. | Damage 48–72 → about 40–60, or HP 240 → 200; or relabel threat 13 → 14 DANGEROUS and move `flats_toll` out of the R2 forced-combat pool. | Informed death ≤ 15% |
| Burst deaths | 48% of informed deaths still had healing items. The v4 Heavy is ×2.0 (Toll Gang Heavy 96–144 before armor). | Use the Phase 0 per-hit telemetry. If single hits regularly exceed 40% of max HP, lower v4 `heavy.damage` to 1.6–1.75 in `combat_content.json`. | No single non-crit hit above 40% max HP for LOW/MODERATE |
| XP doesn't scale with risk | XP per 100 HP lost is about 30–39 for easy enemies and 20–25 for dangerous ones. | Raise `xp_reward` for DANGEROUS/SEVERE, or let Phase 2 cheapen them, so XP/100 HP rises with threat. | Moderate threats give the best practical return (`BALANCE_WORKFLOW.md` step 8) |
| SEVERE late enemies | Tunnel Hunters 96%, Glass Cult 73% informed deaths | Confirm previews warn clearly and flee is available. Tune only if those fights are meant to be winnable. | Informed death ≤ 60% with flee available |

Re-run `tools/combat_balance.gd` for every enemy touched (`--enemies toll_gang,... --seeds 200`) in addition to the playthrough harness. Update the content contract tests that pin HP/damage.

## Phase 4 — Starting kits (1 day)

**Problem.** Informed win rate by starting archetype: Grit 54%, Agility 48%, Wits 40%, Presence 35%, Strength 27%. Runs that ended still holding the Holdout Revolver won only about 20%. Its 4 starting rounds run out early.

**Changes.**
- Presence: revolver rounds 4 → 8, or a starting ammunition trade at checkpoint 1.
- Strength: check the Cleaver's damage and Scrap Vest's Agility penalty against the `combat_balance.gd` early builds, then raise the weakest.

**Done when:** every archetype is within ±10 points of the informed mean.

## Phase 5 — Lethal choices and clarity (½ day)

- Certain-death choices: "Enter the breathing chamber" (`bunker41_door_breathes`), "Enter the hollow below" (`rustsea_false_coordinates`), "Climb into the hollow" (`rustsea_salt_crown_wake`). Confirm each shows **Death** in its stakes line and in its prose. They are intentional, but every one picked so far was fatal.
- `industrial_conveyor` "Grab a crate before the crusher" kills 7.2% of the time on an ordinary check. Confirm the stakes line shows Death, or make the failure heavy damage instead of lethal.
- 24 events have a ≥90% dominant choice for the informed model. Review the top ones (`flats_nightfire`, `outskirts_cache`, `outskirts_child_radio`, `outskirts_market`, `final_gate_1`) for trap or filler options.

## Phase 6 — Human check

After Phases 1–5 pass the simulation targets, run the closed-test build (`docs/CLOSED_TESTING.md`). Record human results separately in `RUN_VERIFICATION.md`, and compare the novice model's reach-R2 and death causes with the real testers'. That comparison is the main check on whether the simulation models are trustworthy.

## Working rules

- Change one subsystem at a time. After each change, run:
  ```
  for p in random novice cautious informed aggressive; do Godot --headless --path . --script res://tools/playthrough_analytics.gd -- --policies $p --runs 2000 --seed-base 100000 --output res://builds/playthrough/$p.json & done; wait; python tools/playthrough_report.py
  ```
  This takes about 3 minutes in parallel.
- Keep the seed base fixed (100000) for comparisons. Confirm a finished phase on a second seed base (200000) before treating it as done.
- Run `tests/test_runner.gd` after every phase, and update the pinned content contracts deliberately rather than loosening them.
