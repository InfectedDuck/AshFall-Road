# Combat baseline - October 2026 (rules v3)

Source: tools/combat_balance.gd with T0.2 SKILL_GAP / ENEMY_GAP lines.

Command:

```text
Godot --headless --path . --script res://tools/combat_balance.gd -- --seeds 30 --enemies road_bandits,feral_dogs,ash_stalkers,toll_gang,marsh_leeches,bog_raiders,drone_swarm,vault_scavs,glass_cult,tunnel_hunters,citadel_guard,warden_machine,mutant_crows,reed_widow,kilnback,shutter_skitters,cable_eater,pox_dogs,bile_spewer,cinder_mauler,salt_colossus,reservoir_maw,ossuary_hound --builds cleaver,pistol,probe --output res://builds/combat_balance_baseline_2026-10.json
```

- rules: v3, fixture_version: 6, seeds_per_row: 30, encounters: 11520
- builds: cleaver (early execution), pistol (early precision), probe (early disruption) - 3 representative early builds
- strategies compared: attack_only, random_actions, read_tells (standard fresh rows only; state rows excluded from gap)
- SKILL_GAP attack_only=0.533 read_tells=0.653 gap=+0.119 (standard rows: 69)

| Enemy | attack_only | random_actions | read_tells | skill gap (read - attack) |
|---|---|---|---|---|
| road_bandits | 0.889 | 0.456 | 0.945 | +0.056 |
| feral_dogs | 1.000 | 0.789 | 1.000 | +0.000 |
| ash_stalkers | 0.545 | 0.200 | 0.778 | +0.233 |
| toll_gang | 0.778 | 0.289 | 0.834 | +0.056 |
| marsh_leeches | 1.000 | 0.967 | 1.000 | +0.000 |
| bog_raiders | 0.422 | 0.089 | 0.344 | -0.078 |
| drone_swarm | 0.767 | 0.222 | 0.878 | +0.111 |
| vault_scavs | 0.322 | 0.067 | 0.522 | +0.200 |
| glass_cult | 0.178 | 0.000 | 0.289 | +0.111 |
| tunnel_hunters | 0.000 | 0.000 | 0.033 | +0.033 |
| citadel_guard | 0.000 | 0.000 | 0.144 | +0.144 |
| warden_machine | 0.011 | 0.000 | 0.256 | +0.245 |
| mutant_crows | 1.000 | 0.922 | 1.000 | +0.000 |
| reed_widow | 0.944 | 0.600 | 0.978 | +0.034 |
| kilnback | 0.278 | 0.033 | 0.467 | +0.189 |
| shutter_skitters | 1.000 | 0.967 | 1.000 | +0.000 |
| cable_eater | 0.756 | 0.167 | 0.789 | +0.033 |
| pox_dogs | 1.000 | 0.900 | 1.000 | +0.000 |
| bile_spewer | 0.800 | 0.278 | 0.900 | +0.100 |
| cinder_mauler | 0.078 | 0.011 | 0.289 | +0.211 |
| salt_colossus | 0.011 | 0.000 | 0.534 | +0.523 |
| reservoir_maw | 0.056 | 0.011 | 0.333 | +0.278 |
| ossuary_hound | 0.433 | 0.056 | 0.700 | +0.267 |

Notes
- Representative subset (3 builds x 30 seeds = 90 encounters per enemy/strategy). Full 14-build x 1000-seed benchmark is ~1.6M encounters (~20h) and is deferred; re-run with defaults to refresh this file before B6 tuning.
- Plan target (GAMEPLAY_IMPROVEMENT_PLAN.md section 2): attack-only <= 0.550, read_tells >= 0.800. Current subset: attack_only 0.533 (already at target on easy early builds), read_tells 0.653 (below target - expected because late bosses are near-unwinnable with early builds). B6 must use matched build tiers per enemy.
- Raw JSON: builds/combat_balance_baseline_2026-10.json (includes per_enemy + skill_gap).
