# Balance and full-run verification

Date: 8 September 2026. Combat rules 2; fixture version 3; harness version 1.

Historical measurements below predate the September 12 difficulty change. See [DIFFICULTY_TUNING.md](DIFFICULTY_TUNING.md) for current tuning and matched comparisons.

## Interim 21-adversary measurement — 22 September 2026

**318,600** authoritative encounters: 21 adversaries × 14 named-stat builds × 5 policies × 200 seeds, plus 123 state-variant rows × 200 seeds. Same-tuning concatenation of three filtered runs (`builds/cb_chunk_a/b/c.json`); no old-tuning rows mixed. Combat rules 2; fixture version 3. Combined source: `builds/combat_balance_21x200.json`; tables: `builds/combat_balance_21x200_summary.md`.

This is interim evidence toward the pending full 1,000-seed 1M+ re-measurement (A02/C01/F01 follow-up), not a replacement for it.

- Policy controls, fresh state: behaviour-aware 0.746, without Opportunity 0.703, attack-only 0.657, random 0.466, repeat-defense 0.000.
- Early tier 0.703, progressed tier 0.821 at equal budgets within each comparison.
- A02/C01 direction confirmed: most of the roster got harder (e.g. Tunnel Hunters 0.268 → 0.164, Citadel Guard 0.423 → 0.265, Glass Cult 0.625 → 0.483); Kilnback moved easier 0.390 → 0.642, so the N05b re-anchor worked.
- New Phase A mutants: `pox_dogs` 1.000, `bile_spewer` 0.931, `salt_colossus` 0.554, `cinder_mauler` 0.426. N-series optionals stay fair: `shutter_skitters` 1.000, `cable_eater` 0.973.
- Stalls: 62 of 1,593 rows, all under the deliberately non-attacking repeat-defense control; no stall under any policy that attacks.

Random-policy rows remain robustness evidence only, never human completion or retention estimates.

Three kinds of evidence are kept separate on purpose:

| Class | Source | What it can support |
|---|---|---|
| **Encounter** | `tools/combat_balance.gd` | How a build, policy, and state perform against one adversary |
| **Robustness** | `tools/full_run_harness.gd` soak | That the engine survives long legal play without erroring or stranding |
| **Human** | Real testers | Difficulty, completion, and retention |

No human results are recorded here. Nothing in this document is a completion or retention estimate.

## Encounter benchmark

`--headless --path . --script res://tools/combat_balance.gd`

**666,000 authoritative encounters**: 15 adversaries × 10 named-stat builds × 4 policies × 1,000 seeds, plus 66 state-variant rows at 1,000 seeds each. Output: `builds/combat_balance.json`.

The roster is every adversary in `data/adversaries.json`. `reed_widow` and `kilnback`, added in N03, entered the standard comparison here; the previous run measured only the thirteen that existed then. `tests/narrative_combat_tests.gd` now fails if the benchmark roster and the package ever disagree again. The thirteen previously measured adversaries reproduced their earlier rows field for field, and the 66 state-variant rows are byte-identical to the previous run, so the two additions did not perturb the comparison.

Builds cover every weapon family at equal point budgets within each tier, so a comparison never mixes a 15-point survivor with a 21-point one:

- **Early, 15 points**: Cleaver (execution), Pistol (precision), Shock Probe (disruption), Buckler Counter (counter), Revolver (suppression).
- **Progressed, 21 points**: Agile Rifle and Mastered Rifle (precision, unmastered vs mastered), Rebar Spear (counter), Stun Baton (disruption), Flare Gun (suppression).

Each fixture is validated before use: named stat budget, equipped slots, attack stat, mastery state, ammunition type and cost, loaded state, and starting HP.

### Policy controls

| Policy | Mean win rate |
|---|---|
| Behaviour-aware (`read_tells`) | 0.767 |
| Behaviour-aware without Opportunity | 0.725 |
| Attack-only | 0.695 |
| Repeat-defense control | 0.000 |

Reading tells beats attacking blindly, and removing the saved Opportunity costs 4.2 points of win rate, so the Opportunity is doing measurable work rather than being decoration. The repeat-defense row never attacks and therefore never wins; it exists to prove defending alone cannot resolve a fight.

### Difficulty ordering, behaviour-aware policy

| Adversary | Win rate | Mean HP spent | Mean exchanges |
|---|---|---|---|
| Mutant Crows | 1.000 | 4.6 | 2.5 |
| Marsh Leeches | 1.000 | 14.9 | 3.3 |
| Reed Widow | 1.000 | 34.4 | 4.2 |
| Feral Dogs | 1.000 | 39.5 | 3.7 |
| Road Bandits | 0.995 | 97.2 | 5.4 |
| Toll Gang | 0.977 | 129.5 | 6.5 |
| Drone Swarm | 0.972 | 134.1 | 6.4 |
| Ash Stalkers | 0.944 | 147.5 | 6.0 |
| Vault Scavs | 0.797 | 219.2 | 7.7 |
| Bog Raiders | 0.663 | 246.6 | 8.1 |
| Glass Cult | 0.625 | 263.1 | 7.3 |
| Warden Machine | 0.450 | 271.1 | 12.2 |
| Citadel Guard | 0.423 | 302.4 | 8.4 |
| Kilnback | 0.390 | 305.8 | 8.1 |
| Tunnel Hunters | 0.268 | 321.7 | 7.3 |

### The two creatures, all four policies

`reed_widow` and `kilnback` are the appended combat routes in `marsh_lights` and `industrial_tank`. Both fights are optional, and in both scenes a safer sibling choice already pays the same items, so these rows exist to price the fight against the route that avoids it. **These are encounter measurements only. They say how a fight resolves, not whether anyone enjoys it.**

| Adversary | Policy | Win rate | Mean HP spent | Mean exchanges | Deaths |
|---|---|---|---|---|---|
| Reed Widow | Attack-only | 1.000 | 43.2 | 4.2 | 0.000 |
| Reed Widow | Repeat-defense | 0.000 | 268.7 | 53.7 | 0.328 |
| Reed Widow | Behaviour-aware | 1.000 | 34.4 | 4.2 | 0.000 |
| Reed Widow | Behaviour-aware, no Opportunity | 1.000 | 38.4 | 4.7 | 0.000 |
| Kilnback | Attack-only | 0.229 | 339.3 | 6.6 | 0.771 |
| Kilnback | Repeat-defense | 0.000 | 359.8 | 18.3 | 0.998 |
| Kilnback | Behaviour-aware | 0.390 | 305.8 | 8.1 | 0.610 |
| Kilnback | Behaviour-aware, no Opportunity | 0.300 | 319.7 | 8.5 | 0.700 |

Split by budget under the behaviour-aware policy, because the two scenes sit in regions 2 and 3 where a survivor is still an early build:

| Adversary | Early, 15 points | Progressed, 21 points |
|---|---|---|
| Reed Widow | 1.000 win, 39.1 HP | 1.000 win, 29.8 HP |
| Kilnback | 0.238 win, 301.8 HP | 0.542 win, 309.9 HP |

**Reed Widow** is the third-cheapest fight in the package: it never lost a single one of the 10,000 behaviour-aware encounters, and it costs 34.4 HP, between Marsh Leeches (14.9) and Feral Dogs (39.5). **Kilnback** is the second-hardest adversary measured, between Citadel Guard (0.423) and Tunnel Hunters (0.268); at 305.8 HP it costs more than the Citadel Guard (302.4) and a little less than Tunnel Hunters (321.7). Its outcome is decided by weapon and HP pool rather than by policy: the two rifle builds win 0.907 and 0.936, while Shock Probe wins 0.004 and Flare Gun 0.039.

### Progression at equal budgets

| Tier | Budget | Win rate | Mean HP spent | Mean ammunition | Mean conditions |
|---|---|---|---|---|---|
| Early | 15 | 0.702 | 170.1 | 1.75 | 0.16 |
| Progressed | 21 | 0.832 | 167.4 | 2.81 | 0.16 |

### Road states

Behaviour-aware policy, three representative adversaries, five early builds:

| State | Win rate | Mean HP spent | Mean exchanges | Unarmed fallbacks |
|---|---|---|---|---|
| Fresh | 0.778 | 136.8 | 6.83 | 0 |
| Hungry (no food, Fatigue 40) | 0.652 | 174.7 | 7.47 | 0 |
| Injured (40% HP) | 0.552 | 278.8 | 4.83 | 0 |
| Unarmed | 0.199 | 293.4 | 16.53 | 15,000 |
| Out of ammunition | 0.144 | 289.2 | 15.93 | 6,000 |

The unarmed and dry rows confirm the fallback contract: every encounter in those rows resolved through the unarmed profile, and a ranged build with no rounds behaves as an unarmed one rather than firing for free.

### Stalls

**84 rows recorded a stall, and every one is the repeat-defense control**, which stalls by construction because it never attacks. No stall occurred under attack-only, behaviour-aware, or behaviour-aware-without-Opportunity in any of the 450 rows those policies cover.

## Full-run harness

`--headless --path . --script res://tools/full_run_harness.gd -- --soak 1000`

Output: `builds/full_run_harness.json`, with a sample decision record at `builds/run_record_sample.json`. A recorded record can be replayed with `-- --replay <path>`.

Nothing forces a heal, a victory, or a successful roll. Every roll comes from the engine's seeded RNG and every decision is chosen from what the engine reports as legal at that moment.

### Replay determinism

A recorded run of **68 decisions across 30 events** replays from its seed to a byte-identical run state. The comparison ignores only `started_at`, which is a wall-clock reading rather than gameplay. This is what makes a tester's recorded session reproducible: seed plus decisions is enough.

The trace records, per region, health, satiety, Fatigue, Radiation, level, experience, and conditions; then every encounter and its outcome, every equipment acquisition, and the ending with its cause.

### Robustness soak — not a human estimate

1,000 seeded runs under a uniform legal-action policy:

| Measure | Value |
|---|---|
| Engine errors | **0** |
| Recovery checks / mismatches | 24 / **0** |
| Deaths | 981 |
| Victories | 17 |
| Unfinished | 2 |
| Mean regions reached | 3.98 |
| Mean events resolved | 17.28 |
| Mean level | 2.70 |

**These numbers describe a random policy, not a person.** 765 of the 981 deaths are starvation, which is what happens when nothing manages supplies; it is evidence that the hunger system applies consistently over long play, and it is not a statement about how hard the game is for a human. Deaths concentrate in the Hollow Industrial Zone (288), Drowned Marches (247), and Glass Wastes (196).

### Robustness soak after talents and checkpoint trading — September 2026

The soak policy was extended to the new checkpoint systems: it takes a talent when offered (about half the time), buys an affordable trade offer, and otherwise rests or presses on as before. Recorded talent and trade decisions replay deterministically.

1,000 seeded runs under the extended policy:

| Measure | Value |
|---|---|
| Engine errors | **0** |
| Recovery checks / mismatches | 25 / **0** |
| Replay reproduces the recorded run | **true** |
| Deaths | 998 |
| Victories | 2 |
| Unfinished (stranded) | **0** |
| Mean regions reached | 3.59 |
| Mean events resolved | 15.37 |
| Mean level | 2.83 |
| Mean talents taken | 1.05 |
| Mean trades made | 0.69 |

728 of the 998 deaths are starvation, and deaths concentrate in the same three zones (Hollow Industrial Zone 321, Drowned Marches 252, Glass Wastes 173). The shape matches the pre-change soak: a random policy still dies unmanaged, and no run strands. The small dip in reach versus the earlier table comes with the policy change itself — it now spends supplies on trades a person would weigh first — so it is not read as a difficulty change. Trade prices (2–8 scrap, water for food) clear regularly at 0.69 purchases per run, which keeps Barter a live option without making it the default. No cost or difficulty retune follows from this soak; talent values stay at their initial tuning until human playtests report.

## Findings

### Release blocker: an event that can strand a run — REPAIRED BY N04

`global_stranger` ("Injured Stranger") is the only event in the package where **every** choice is gated behind an item: choice 0 requires a Cloth Bandage and choice 1 requires Clean Water. Unavailable choices render as disabled buttons, so a survivor carrying neither has no legal action and the autosaved run cannot continue.

- Reproduction: seeds **9103** (candidate 1) and **9876** (candidate 0) in the soak; both reached `global_stranger` with no bandage and no water and consumed the 400-step cap.
- Frequency: 2 in 1,000 random-policy runs. A human is less likely to reach it with both consumables exhausted, but the outcome is an unrecoverable run.
- Not repaired *by M11*, deliberately: M11 is a verification milestone, and adding a choice is a mechanical change that belongs to a content plan and its allowlist. The minimal fix identified at the time was one ungated choice, for example staying with the stranger without treating them.
- A permanent guard was added to `tools/data_package_audit.gd`: check 9, "Every event is resolvable without a specific item". **N04 repaired the defect**: `global_stranger` gained an ungated third choice, "Press the wound with your own coat" (Grit risky, no items, no flags), so the scene is always resolvable. The audit now reports **9 checks, 9 passed, 0 discrepancies**. The guard remains, and the soak seeds 9103 and 9876 that found it now complete.

### Observations, not tuning proposals

No rebalance is authorised by this milestone, and none was made. Recorded for whoever takes tuning next:

- Tunnel Hunters is the hardest adversary by a clear margin (0.268 win rate, 321.7 HP spent) and is reached in the Underrail, late in a run. Any proposal should state the affected matchups and the expected tradeoff first.
- Citadel Guard (0.423) and Warden Machine (0.450) sit close together, but the Warden takes half again as many exchanges (12.2 vs 8.4), so they are hard in different ways.

#### The two creatures, priced against the route that avoids them

Both creature fights were authored as optional alternatives that pay their scene's existing items, so the XP was meant to be what buys the risk. The benchmark can price that, and only that: it measures the fight, not the scene, and nothing here says whether a player enjoys either encounter.

- **Reed Widow, 30 XP, is above the package's own curve.** The fight cost 34.4 HP and lost none of its 10,000 behaviour-aware encounters, which is 0.87 XP per HP spent against 0.16–0.37 for every other adversary that can kill a survivor. Toll Gang shares its threat band and its exact 30 XP and costs 129.5 HP. The scene's safer route, choice 0 (Wits risky, 45–70 healthy), already pays the same `purifier_ampoule 1, clean_water 2` for a 4-XP check bonus, so at a measured 1.000 win rate the fight is the *more reliable* way to those items before any XP is counted, and the 30 is surplus rather than compensation. A curve-consistent value would be 22–24 (Feral Dogs 22 at 39.5 HP, Marsh Leeches 24 at 14.9 HP). Lowering it would not restore the scene's non-dominance: certainty is what makes the fight attractive, and only the 34.4 HP and the `sprain` chance argue against it.
- **Kilnback, 65 XP, is not a question XP can answer.** It is the second-hardest adversary in the package and it sits in region 3. The early builds that reach it win 0.238 and die 0.762, spending 301.8 HP against 300–400 HP pools; the two rifle builds win 0.907 and 0.936, so the fight is decided by kit rather than by reading it. The scene's safer route, choice 1 (Wits favorable, 55–90 healthy, the best odds in its batch), pays the same `clean_water 2` and the same `kilnback_rhythm_known` flag for a 2-XP check. By XP per HP spent it is unremarkable — 0.213, inside the 0.16–0.37 band every killing adversary occupies — so the rate is not the defect; the defect is that the HP is nearly the whole pool and the failure is the run. Death forfeits the run's experience (`xp_lost`), and the soak's mean level at that depth is 2.70, with level 3 beginning at 110 XP and level 4 at 180. At 0.762 death the fight therefore stakes roughly 84–137 XP of accumulated progress, plus the run's items and its remaining regions, to gain an expected 15.5. Paying for that in XP alone would take roughly 350–480, three to five times the Warden Machine. The measurable mismatch is between the Kilnback's difficulty and its region, not between its difficulty and its reward, so a proposal belongs on the combat profile or on what victory pays; it should state the affected matchups first. The engine does disclose the danger at the point of decision: the choice reads `FIGHT • …+65 XP` with the enemy's 75–105 damage.
- **The Kilnback was retuned on this evidence, and re-measured.** The measurement above is what the fight looked like at threat 17, 360 HP, 75–105 damage, 65 XP — a profile the creature bible had anchored to the Warden Machine at the far end of the game instead of to its own region. N05b (see the allowlist in [CONTENT_AUTHORING.md](CONTENT_AUTHORING.md)) re-anchored it to the Hollow Industrial Zone's roster: threat 16, **300 HP, 62–88 damage, 50 XP**, and a victory premium of `scrap_parts 2` that the safer listening route cannot pay. Re-measured with the same fixtures, policies, and 1,000 seeds per row, behaviour-aware policy:

  | | Early tier (the builds that reach region 3) | All ten builds |
  |---|---|---|
  | Before | win **0.238**, death 0.762, 301.8 HP | win 0.390, death 0.610, 305.8 HP |
  | After | win **0.552**, death 0.448, 257.4 HP | win 0.674, death 0.326, 253.5 HP |

  In the difficulty ordering it now sits between Bog Raiders (0.663) and Glass Cult (0.625) rather than second only to Tunnel Hunters, which is where a region-3 apex belongs: harder than the Scavengers that share its region, not harder than the Cult and the Guard that come later. Attack-only rose from 0.229 to 0.490. The fight is still decided by kit — Buckler 0.839, Pistol 0.705, Cleaver 0.666 against Shock Probe 0.192 and Revolver 0.358 — and that is coherent rather than a defect: the Wits build most likely to be hurt by it is exactly the build the scene's Wits-favorable listening route already serves best. What changed is that a Strength or Grit survivor now has a real fight in front of them rather than a mistake button. Expected XP for an early build is 27.6 against the run it stakes, so on XP alone the fight is still not the rational choice; it is now a *choice*, which is all an optional alternative owes.
- **Supplementary, and not part of the benchmark**: a bail-out policy the four standard policies cannot express (fight, then flee below 40% HP; the Kilnback's flee is `favorable`) resolved 0.699 escapes, 0.269 deaths and 258.6 HP spent for early builds. Fleeing limits the loss but pays no XP and no loot, so it does not make the fight worth choosing. This measurement is not in `builds/combat_balance.json`. It was taken with a probe left at `builds/flee_probe.gd` beside its output; `builds/` is untracked, so promoting the probe to `tools/` is a decision for whoever takes tuning next.

## Reproducing

```
tools/combat_balance.gd                      full encounter benchmark, ~65 minutes for fifteen adversaries
tools/combat_balance.gd -- --controls-only   re-run only the Opportunity control rows
tools/full_run_harness.gd -- --soak 1000     robustness soak and determinism check
tools/full_run_harness.gd -- --replay P      replay one recorded decision record
```

`tests/test_runner.gd` carries a fast regression of the same property: one legal-action run must drive a whole journey with no rejected action, and its recorded decisions must replay to an identical state.
