# Combat difficulty tuning — 12 September 2026

Playtest feedback: random button presses felt safe, and crows could not kill a survivor after 20–30 exchanges.

The cause was numerical: crows dealt 7–10 raw damage, which Scrap Vest reduced to 1 HP per hit, and they spent every third exchange recovering. A survivor with 300 HP and armor 3 could withstand roughly 450 unanswered exchanges. Thirty combat exchanges also added only 20 Fatigue, below the first strain threshold of 25.

## Changes

| Adversary | HP before → after | Raw damage before → after |
|---|---:|---:|
| Mutant Crows | 70 → 110 | 7–10 → 36–54 |
| Feral Dogs | 120 → 150 | 22–36 → 38–58 |
| Marsh Leeches | 90 → 120 | 12–24 → 32–48 |
| Reed Widow | 130 → 160 | 18–30 → 36–56 |
| Road Bandits | 180 → 200 | 35–55 → 44–66 |
| Toll Gang | 220 → 240 | 40–60 → 48–72 |
| Ash Stalker | 220 → 240 | 45–70 → 52–80 |
| Drone Swarm | 260 → 280 | 50–80 → 56–88 |

Crows now use Strike, Sweep, Strike, Recover. Every ongoing rules-2 exchange adds 3 Fatigue, including successful defense, item use and recovery. A fresh survivor reaches the first strain threshold after nine exchanges and the strongest fatigue penalty after 25. Action previews disclose the cost; the result log reports the amount actually gained. Successful escapes retain their existing 5-Fatigue cost; killing blows and death do not add exertion.

HP pools, armor, healing, rewards, escape chances and the strongest enemy profiles retain their existing values. Recovery windows and successful defenses remain useful. Legacy rules-1 fights retain their original fatigue cadence. An already prepared round retains its saved enemy definition; existing fights retain their saved enemy HP.

## Matched encounter comparison

100 seeded, normally generated starting survivors per enemy/policy, seeds 1–100, candidate index `seed % 3`, full starting health and ordinary starting equipment/inventory. Random actions choose uniformly among Attack, Block, Dodge and an available Opportunity, using a separate decision RNG seeded with `seed + 7000`. No healing or escape actions. The informed policy is `read_tells` from the encounter benchmark. These are encounter simulations, not human completion estimates.

| Enemy | Random deaths before → after | Informed deaths before → after |
|---|---:|---:|
| Mutant Crows | 0% → 6% | 0% → 0% |
| Feral Dogs | 4% → 18% | 0% → 0% |
| Marsh Leeches | 0% → 4% | 0% → 1% |
| Reed Widow | 0% → 20% | 0% → 4% |
| Road Bandits | 26% → 45% | 6% → 10% |
| Toll Gang | 47% → 62% | 18% → 28% |
| Ash Stalker | 56% → 73% | 15% → 28% |
| Drone Swarm | 53% → 73% | 15% → 23% |
| Warden Machine | 100% → 100% | 78% → 81% |

Random crow encounters consumed an average of **121.6 HP**, up from **10.3 HP**; informed play consumed **72.0 HP**, up from **6.3 HP**. Under the repeated-defense policy, survivors still fighting crows after 30 exchanges fell from **100% to 29%**, and deaths by the 60-exchange cap rose from **1% to 95%**. Durable defensive builds can still last longer than 30 turns.

The sequence-weighted report now shows **21.6 damage per unanswered exchange** against armor 3, equivalent to **13.9 exchanges per 300 HP**, before active defenses or healing.

## Reproduction

The ordinary test suite includes crow lethality, seeded random-versus-informed play and fatigue regression checks. The content contract explicitly records the new HP, damage and crow sequence.

`tools/balance_report.gd` now reports sequence-weighted pressure, including non-attacking exchanges. `tools/combat_balance.gd` adds a reproducible `random_actions` policy, independent of the engine RNG, and supports smaller complete comparisons:

```text
Godot --headless --path . --script res://tools/combat_balance.gd -- --seeds 40 --enemies mutant_crows,feral_dogs,road_bandits,warden_machine --output res://builds/combat_balance_difficulty.json
```

Filtered runs default to `builds/combat_balance_subset.json`. Full defaults now cover 816,000 encounters (15 enemies × 10 builds × 5 policies × 1,000 seeds, plus 66 state rows). The old `--controls-only` cache merge is rejected to prevent mixing old and new tuning. Injured rows measure HP spent from actual starting HP; a fight ending on exchange 60 is not counted as a stall.

The September 8 encounter tables in RUN_VERIFICATION.md describe the previous tuning.

## Validation

- Headless suite: **2,913 assertions, 0 failures**, including disk save/recovery checks.
- Combat UI smoke: **0 layout/input failures**.
- Current encounter benchmark: **10,640 encounters**, four enemies × ten builds × five policies × 40 seeds, plus 66 state rows × 40 seeds. Standard-row mean win rates: random 61.9%, attack-only 75.7%, informed 84.6%, informed without Opportunity 82.7%. All 37 turn-limit stalls belonged to the deliberately non-attacking defense policy.
- Journey robustness: **100 runs, 0 engine errors, 0 unfinished**, with **25 recovery checks and 0 mismatches**. A recorded 76-decision run replayed identically. All 100 uniform-random journeys ended in death; this checks robustness and does not estimate human completion.

Local outputs are in `builds/difficulty-tests.out`, `builds/difficulty-combat-ui.out`, `builds/combat_balance_difficulty.json`, and `builds/difficulty-full-run.out`. The matched generated-starter probe is recorded in `builds/difficulty_probe_before.json` and `builds/difficulty_probe_after.json`.
