# Gameplay revamp plan: combat at the centre (October 2026)

Supersedes Phases 2–5 of `BALANCE_FIX_PLAN.md`. Phases 0–1 and the caught fights stay as built.

## 1. Goal

Fighting should be necessary, and the build you make should decide whether you live. A survivor who refuses every optional fight should almost never reach the Citadel.

Target win rates (simulated models, `tools/playthrough_report.py --check`):

| Model | Plays like | Today | Target |
|---|---|---|---|
| cautious | never takes an optional fight, plays forced fights well | 79.0% | **3–4%** (check band 2–5%) |
| informed | picks fights it can win, builds toward its weapon | 44.1% | 15–25% |
| aggressive | takes every fight, never flees | 0.1% | 5–10% |
| novice | random choices, mostly attacks | 1.9% | 2–5% |
| random | uniform legal actions | 0.0% | < 1% |

Order that must hold: informed > aggressive > novice ≈ cautious > random. Reach-R2 stays 80–90%: the Shattered Outskirts teaches, it doesn't filter.

## 2. Why the game is easy today

Measured at seed base 100000 after the caught-fight change (`builds/playthrough/report.md`).

1. **Avoiding pays better than fighting.** Across all content, non-fight routes give 64 Scrap, 49 equipment pieces and 148 consumables. Fight victories give 21, 19 and 33. Scrap is the only trade currency, so the "gold" also comes mostly from not fighting.
2. **XP doesn't need fights.** Every event pays 4 journey XP, every checkpoint 10, every passed check 2–10. A run that never fights reaches about level 5. At R6 the cautious survivor is level 4.2 and the informed one 5.0, less than one level apart.
3. **The road doesn't hurt.** The cautious survivor arrives at every region with 86–98% HP and more max HP than the fighter, because its level-ups go into Grit.
4. **Fights are expensive and bursty.** A MODERATE fight costs a 300-HP survivor about 150 HP. Enemies have low HP and high damage, so any build kills them in a few hits, and level and gear barely change the result. Single Heavy hits (×2.0) cause burst deaths.
5. **Very few fights are forced.** Only the four caught fights are; R2's pool has one combat scene in total.

Changing enemy HP and attack alone can't fix this. Enemy numbers only matter in fights you can't skip, and the gap between a fighter and an avoider only matters if fighting is what builds it. The plan changes three things together: **forced fights, where power comes from, and the enemy curve**.

## 3. Design pillars

1. **Every region ends at a gate fight.** One forced fight per region, sized for a survivor who has been fighting.
2. **Fights are the main source of XP, Scrap and the best gear.** The road still pays, but less.
3. **Enemies are built around an expected fighter.** More HP and less damage per hit, so fights depend on your damage output (level, weapon tier, attack stat) instead of on a few lucky rolls.
4. **Avoiding still costs something.** Failed evasions hurt or lead into a fight, and late checks need levels.

## 4. Changes

### 4.1 Gate fights (engine + content)

- `regions.json` gets `gate_event` per region. After the fifth travel scene, before the checkpoint, the engine runs that region's gate scene. It doesn't take a travel slot and can't be skipped; the run records `gate_cleared_in_region` and save migration defaults it.
- A gate scene is one combat choice, like a caught fight: `can_flee: false`. The stakes line reads `Fight: <enemy>`, and the region intro tells the player a gate is coming.
- Gate rewards: Scrap 2 / 3 / 3 / 4 / 4 / 5 (R1→R6), a modest XP award (one MODERATE fight's worth, so gates don't level the avoider), and no equipment. Gear stays the reward for optional fights and the shop.
- Proposed gates, with new elite adversary ids so the ordinary enemies keep their stats:

| Region | Gate | Based on | Tier |
|---|---|---|---|
| R1 Shattered Outskirts | Cutter's crew blocks the overpass | road_bandits | MODERATE (teaching fight) |
| R2 Salt Flats | The Toll Captain | toll_gang | DANGEROUS |
| R3 Drowned Marches | Raider skiff at the weir | bog_raiders | DANGEROUS+ |
| R4 Hollow Industrial | Foundry sentinel | drone_swarm | SEVERE |
| R5 Glass Wastes | Choir champion | glass_cult | SEVERE+ |
| R6 The Underrail | Hunter pack leader | tunnel_hunters | APEX |
| Citadel | Citadel Guard (Warden for Bunker 41 runs) | citadel_guard / warden_machine | GATE |

The final row also closes the open Citadel Guard question: on the gate route, the guard is the last fight.

The target is that an avoider survives each gate with probability falling from about 0.9 (R1) to about 0.35 (R6). Combined, that comes to about 3–5% for a full run.

### 4.2 XP economy (`ExperienceRules`, bump `RULES_VERSION`)

| Source | Today | Proposed |
|---|---|---|
| Journey per event | 4 | 1 |
| Checkpoint | 10 | 5 |
| Passed check (easy / favorable / risky / hard / desperate) | 0 / 2 / 4 / 7 / 10 | 0 / 1 / 2 / 3 / 5 |
| Optional fight victory (`xp_reward`) | 16–62 | by tier: LOW 20, MODERATE 30, DANGEROUS 45, SEVERE 60, APEX 90 |
| Gate victory | — | 25 + 5 × region |

Target level curve (level on arrival):

| | R2 | R3 | R4 | R5 | R6 |
|---|---|---|---|---|---|
| fighter (2 optional fights per region) | 2–3 | 3–4 | 4–5 | 5–6 | 6–7 |
| avoider (gates only) | 1–2 | 2 | 2–3 | 3 | 3–4 |

### 4.3 Loot and Scrap

- Adversaries get a `scrap_reward` that is added automatically on victory: LOW 1, MODERATE 2, DANGEROUS 3, SEVERE 4, APEX 5. Caught fights pay half, rounded up.
- Halve Scrap in non-fight outcomes (64 → about 30 across the content). Keep food, water and healing on the road: survival supplies stay reachable by everyone.
- Move the strong gear (weapons with affinity ≥ 4, top armor) from non-fight outcomes into fight victories and the shop. A road scene that currently hands out a tier-3 weapon gives Scrap or a tier-1 item instead.
- Shop: tier 2 from R2, tier 3 from R4, priced so that two or three won fights buy one upgrade (tier 2 ≈ 5–6 Scrap, tier 3 ≈ 8–10).
- Scrap is the game's gold. The plan keeps it as the single currency and makes it visible as such on the HUD and the trade screen.

### 4.4 Enemy curve (`adversaries.json`, `combat_content.json`)

Method: define the expected fighter for each region, then set enemy HP from the number of exchanges a fight should last, and enemy damage from the share of HP a fighter should lose. Heuristics come from the harness: about a 75% hit rate, and when tells are read, about 45% of the enemy's average damage is taken per exchange.

| Region | Expected fighter (level, attack stat, weapon) | Average hit | Avoider | Average hit | Ratio |
|---|---|---|---|---|---|
| R1 | L1, 5, starter | 60 | L1, 5, starter | 60 | 1.0 |
| R2 | L2, 6, starter | 64 | L1, 5, starter | 60 | 1.1 |
| R3 | L3, 7, tier 2 | 84 | L2, 5, starter | 60 | 1.4 |
| R4 | L4, 7, tier 2+ | 93 | L2, 5, starter | 60 | 1.6 |
| R5 | L5, 8, tier 3 | 115 | L3, 5, cheap upgrade | 68 | 1.7 |
| R6 | L6, 9, tier 3 | 126 | L3, 5, cheap upgrade | 68 | 1.9 |

Per-tier targets for the expected fighter: LOW 3 exchanges / 12% HP lost, MODERATE 4 / 20%, DANGEROUS 5 / 28%, SEVERE 6 / 36%, GATE 6 / 45%, APEX 7 / 50%.

Starting numbers derived from that (calibrate with `tools/combat_balance.gd`, see §6):

| Enemy | Region | Tier | HP now → new | Damage now → new | Fighter loses | Avoider loses |
|---|---|---|---|---|---|---|
| shutter_skitters, feral_dogs, pox_dogs | R1 | LOW | 115–150 → 130 | 28–58 → 21–32 | 12% | 12% |
| road_bandits | R1 | MODERATE | 200 → 180 | 44–66 → 27–40 | 20% | 20% |
| mutant_crows | R2 | LOW | 110 → 140 | 36–54 → 21–32 | 12% | 11% |
| toll_gang | R2 | MODERATE | 240 → 190 | 48–72 → 27–40 | 20% | 18% |
| marsh_leeches, reed_widow | R3 | MODERATE | 120–160 → 250 | 32–56 → 31–47 | 20% | 24% |
| bile_spewer, bog_raiders | R3 | DANGEROUS | 220–270 → 320 | 48–80 → 35–52 | 28% | 35% |
| vault_scavs | R4 | DANGEROUS | 300 → 350 | 58–85 → 35–52 | 28% | 38% |
| drone_swarm, kilnback | R4 | SEVERE | 280–300 → 420 | 56–88 → 37–56 | 36% | 49% |
| ossuary_hound | R5 | DANGEROUS | 260 → 430 | 56–84 → 40–60 | 28% | 47% |
| glass_cult, cinder_mauler | R5 | SEVERE | 340 → 520 | 64–100 → 43–64 | 36% | 62% |
| salt_colossus | R5 | APEX | 450 → 600 | 85–125 → 51–76 | 50% | 85% |
| ash_stalkers, cable_eater | R6 | DANGEROUS | 240–250 → 470 | 52–80 → 40–60 | 28% | 52% |
| tunnel_hunters | R6 | SEVERE | 320 → 570 | 68–100 → 43–64 | 36% | 67% |
| reservoir_maw | R6 | APEX | 380 → 660 | 68–102 → 51–76 | 50% | 93% |
| citadel_guard, warden_machine | Citadel | GATE | 430–600 → 570 | 85–158 → 53–80 | 45% | 84% |

The shape matters more than the exact values. Early enemies get a little weaker; late enemies get much tougher but hit softer. A good fighter loses less HP per fight than today, and the avoider's late-game losses roughly double.

Also:
- v4 Heavy ×2.0 → 1.75, so a single non-critical hit stays under 40% of max HP (the old Phase 3 burst target).
- Enemies keep their move sets, traits and flee difficulty. Only HP, damage, `xp_reward` and the new `scrap_reward` change.
- Optional extra lever if gear still separates too little: a flat enemy `armor` (0–15) subtracted per hit on late enemies, which punishes low-damage weapons hardest. Add only if the measured fighter/avoider ratio is under 1.6 at R5.

### 4.5 Avoiding costs something

- Failed evasions in combat scenes: either the caught-fight chain, or a real cost (20–40 HP, a harmful condition, or the loot only the fight pays). A successful evasion costs Fatigue or time.
- Add the R5 caught fight once the curve makes `glass_cult` beatable for a fighter.
- R4–R6 road checks move one difficulty step harder (risky → hard and so on) for the stat the region tests most. A level-3 survivor fails noticeably more often than a level-6 one, and failures cost HP.
- No change to Grit hearts. The avoider's HP pool stays large; its damage output is what falls behind.

### 4.6 Measurement

- Analytics: XP, Scrap and equipment by source (road, optional fight, caught fight, gate, shop) per model; gate survival per region per model; level and weapon tier on arrival.
- `--check`: the new win bands from §1, plus the ordering rule, plus a gate-survival gradient check for cautious (R1 ≥ 85%, R6 ≤ 45%).
- `tools/combat_balance.gd`: new fixture builds `fighter_r1`–`fighter_r6` and `avoider_r1`–`avoider_r6` from the §4.4 tables, so each enemy can be tuned against both directly.

## 5. Phases

Each phase ends with the full 5-model harness on seed base 100000, `tests/test_runner.gd` and `tools/data_package_audit.gd`. A finished phase is confirmed on seed base 200000.

| Phase | Work | Done when |
|---|---|---|
| R0 · telemetry (½ day) | §4.6 analytics and fixture builds; baseline report | XP/Scrap/gear-by-source tables exist for today's build |
| R1 · gate fights (1–2 days) | §4.1 engine hook, 7 gate scenes, elite adversaries at current-style numbers, tests, save default | Every region ends at its gate; cautious win drops sharply (expected 20–40%); no engine errors |
| R2 · economy (1–2 days) | §4.2 XP table and §4.3 Scrap/loot moves | Cautious arrives at R6 at level 3–4 and informed at 6–7; ≥ 60% of Scrap and ≥ 60% of tier-2+ gear come from fights |
| R3 · enemy curve (2–3 days) | §4.4 numbers, Heavy 1.75, tuned per enemy with `combat_balance.gd` against fighter/avoider fixtures | Each enemy within ±5 points of its fighter HP-loss target; avoider/fighter loss ratio ≥ 1.6 from R4 |
| R4 · avoid costs and late checks (1 day) | §4.5 | Fight-vs-avoid gap in reaching the next region within ±15 points for LOW/MODERATE |
| R5 · tuning loop (1–3 days) | Adjust gate numbers and XP rewards only, one at a time | All §1 bands pass on both seed bases |
| R6 · human check | Closed test build (`CLOSED_TESTING.md`) | Testers' reach-R2 and death causes are close to the novice model; record in `RUN_VERIFICATION.md` |

Order matters. Gates first: without forced fights nothing else reaches the avoider. Then economy, so the expected-fighter build actually exists. Then the curve, which is tuned against that build.

## 6. Tuning method for one enemy

```text
Godot --headless --path . --script res://tools/combat_balance.gd -- --seeds 200 --enemies toll_gang --builds fighter_r2,avoider_r2
```

1. Set HP and damage from §4.4.
2. Read tells win rate and HP lost for both fixtures. Move HP first (it changes fight length and the fighter/avoider gap), damage second (it changes HP loss).
3. Stop when the fighter is within ±5 points of the tier target and the avoider's loss is at least 1.6× the fighter's from R4 onward.
4. Update the content contract tests that pin HP and damage on purpose, never by loosening them.

## 7. Risks

- **Death spiral.** A fighter who loses one fight falls behind on HP and can't afford the next. Mitigation: checkpoint rest stays strong, and gate rewards include a heal item from R3 on.
- **R1 onboarding.** The R1 gate is a teaching fight at MODERATE; reach-R2 must stay 80–90%.
- **Feeling grindy.** Optional fights should stay optional *per fight*: the informed model should still skip about 30–40% of the fights it is offered.
- **Story runs.** Bunker 41 and Rust-Sea chains add scenes but no gates; the Warden replaces the Citadel Guard on that route.
- **Saves.** Content numbers change under in-progress runs. Running fights keep their frozen combat rules version; new XP rules apply through `xp_curve_version` like earlier migrations.
- **Model trust.** The cautious model plays forced fights skilfully, so 3–4% for it means a real build gap, not bad play. The human check in R6 is still the real test.

## 8. Decisions needed

1. **Can gates be fled?** Proposed: no. Alternative: flee allowed but costs half your Scrap and a heal item.
2. **Gold.** Proposed: Scrap stays the currency and is labelled as such. Alternative: a separate coin currency only fights pay.
3. **Informed target.** 15–25% (proposed), or harder (10–15%).
4. **R1 gate.** Proposed: a MODERATE teaching fight. Alternative: start gates at R2.
