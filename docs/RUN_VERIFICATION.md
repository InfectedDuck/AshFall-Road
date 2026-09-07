# Balance and full-run verification

Date: 8 September 2026. Combat rules 2; fixture version 3; harness version 1.

Three kinds of evidence are kept separate on purpose:

| Class | Source | What it can support |
|---|---|---|
| **Encounter** | `tools/combat_balance.gd` | How a build, policy, and state perform against one adversary |
| **Robustness** | `tools/full_run_harness.gd` soak | That the engine survives long legal play without erroring or stranding |
| **Human** | Real testers | Difficulty, completion, and retention |

No human results are recorded here. Nothing in this document is a completion or retention estimate.

## Encounter benchmark

`--headless --path . --script res://tools/combat_balance.gd`

**586,000 authoritative encounters**: 13 adversaries × 10 named-stat builds × 4 policies × 1,000 seeds, plus 66 state-variant rows at 1,000 seeds each. Output: `builds/combat_balance.json`.

Builds cover every weapon family at equal point budgets within each tier, so a comparison never mixes a 15-point survivor with a 21-point one:

- **Early, 15 points**: Cleaver (execution), Pistol (precision), Shock Probe (disruption), Buckler Counter (counter), Revolver (suppression).
- **Progressed, 21 points**: Agile Rifle and Mastered Rifle (precision, unmastered vs mastered), Rebar Spear (counter), Stun Baton (disruption), Flare Gun (suppression).

Each fixture is validated before use: named stat budget, equipped slots, attack stat, mastery state, ammunition type and cost, loaded state, and starting HP.

### Policy controls

| Policy | Mean win rate |
|---|---|
| Behaviour-aware (`read_tells`) | 0.778 |
| Behaviour-aware without Opportunity | 0.736 |
| Attack-only | 0.707 |
| Repeat-defense control | 0.000 |

Reading tells beats attacking blindly, and removing the saved Opportunity costs 4.2 points of win rate, so the Opportunity is doing measurable work rather than being decoration. The repeat-defense row never attacks and therefore never wins; it exists to prove defending alone cannot resolve a fight.

### Difficulty ordering, behaviour-aware policy

| Adversary | Win rate | Mean HP spent | Mean exchanges |
|---|---|---|---|
| Mutant Crows | 1.000 | 4.6 | 2.5 |
| Marsh Leeches | 1.000 | 14.9 | 3.3 |
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
| Tunnel Hunters | 0.268 | 321.7 | 7.3 |

### Progression at equal budgets

| Tier | Budget | Win rate | Mean HP spent | Mean ammunition | Mean conditions |
|---|---|---|---|---|---|
| Early | 15 | 0.715 | 170.1 | 1.74 | 0.16 |
| Progressed | 21 | 0.841 | 167.0 | 2.80 | 0.16 |

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

**71 rows recorded a stall, and every one is the repeat-defense control**, which stalls by construction because it never attacks. No stall occurred under attack-only, behaviour-aware, or behaviour-aware-without-Opportunity in any of the 390 rows those policies cover.

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

## Findings

### Release blocker: an event that can strand a run

`global_stranger` ("Injured Stranger") is the only event in the package where **every** choice is gated behind an item: choice 0 requires a Cloth Bandage and choice 1 requires Clean Water. Unavailable choices render as disabled buttons, so a survivor carrying neither has no legal action and the autosaved run cannot continue.

- Reproduction: seeds **9103** (candidate 1) and **9876** (candidate 0) in the soak; both reached `global_stranger` with no bandage and no water and consumed the 400-step cap.
- Frequency: 2 in 1,000 random-policy runs. A human is less likely to reach it with both consumables exhausted, but the outcome is an unrecoverable run.
- Not repaired here. M11 is verification; adding a choice is a mechanical change that belongs to a content plan and its allowlist. The minimal fix is one ungated choice, for example staying with the stranger without treating them, which the existing failure prose already describes.
- A permanent guard was added to `tools/data_package_audit.gd`: check 9, "Every event is resolvable without a specific item". The audit now reports **9 checks, 8 passed, 1 discrepancy** and exits 1 until this is fixed.

### Observations, not tuning proposals

No rebalance is authorised by this milestone, and none was made. Recorded for whoever takes tuning next:

- Tunnel Hunters is the hardest adversary by a clear margin (0.268 win rate, 321.7 HP spent) and is reached in the Underrail, late in a run. Any proposal should state the affected matchups and the expected tradeoff first.
- Citadel Guard (0.423) and Warden Machine (0.450) sit close together, but the Warden takes half again as many exchanges (12.2 vs 8.4), so they are hard in different ways.

## Reproducing

```
tools/combat_balance.gd                      full encounter benchmark, ~40 minutes
tools/combat_balance.gd -- --controls-only   re-run only the Opportunity control rows
tools/full_run_harness.gd -- --soak 1000     robustness soak and determinism check
tools/full_run_harness.gd -- --replay P      replay one recorded decision record
```

`tests/test_runner.gd` carries a fast regression of the same property: one legal-action run must drive a whole journey with no rejected action, and its recorded decisions must replay to an identical state.
