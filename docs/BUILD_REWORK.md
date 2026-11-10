# Build rework (combat rules v5)

Status: implemented on `main`, uncommitted. Verification is in section 8 and balance results in section 9.

## 1. Why

Feedback after the combat revamp: combat and build-making were still not interesting. Two specific asks:

1. Stats should visibly give more damage.
2. Accessories should have to be combined with the weapon and the armor.

Before this change a stat point above 5 was worth +10% of a weapon's base damage, a point below 5 was worth less each time, and only one stat mattered per weapon. An accessory was a +1 stat or an event-approach bonus that never looked at the rest of the kit. Nothing rewarded a loadout for fitting together.

The reference was Life in Adventure and games like it, where a weapon answers to named stats and the gear you wear decides which bonuses you hold. Research sources are listed in section 10.

## 2. Pillar 1: stats give damage

Every weapon now has a **main stat** (its existing attack stat) and a **support stat**. Damage is linear in both:

```
power      = main stat + 0.5 × support stat
multiplier = 0.35 + 0.15 × power
damage     = weapon base damage × multiplier
```

- One point in the main stat is **+15%** of the weapon's base damage, at any value.
- One point in the support stat is **+7.5%**.
- Effective stats are used, so a +1 Strength charm, a strain penalty or being over capacity all move damage.
- Hit chance still reads the main stat only. Mastery, specialization and the unwieldy penalty are unchanged.
- Bare hands scale on Strength alone.

Constants: `CombatResolver.V5_BASE`, `V5_PER_POINT`, `V5_SUPPORT_WEIGHT` in [combat_resolver.gd](../scripts/domain/combat_resolver.gd).

Old curve against new, for typical builds:

| main / support | old (v3) | new (v5) | change |
| --- | --- | --- | --- |
| 3 / 2 | ×1.18 | ×0.95 | −19% |
| 4 / 3 | ×1.24 | ×1.18 | −6% |
| 5 / 3 | ×1.30 | ×1.33 | +2% |
| 6 / 3 | ×1.40 | ×1.48 | +5% |
| 7 / 4 | ×1.50 | ×1.70 | +13% |
| 8 / 4 | ×1.60 | ×1.85 | +16% |
| 9 / 5 | ×1.70 | ×2.08 | +22% |
| 10 / 6 | ×1.80 | ×2.30 | +28% |

An ordinary starting build (main 5, support 3) is where the two curves meet. A survivor who invests is rewarded; one who holds a weapon their stats do not fit hits softer than before. That is the intent.

### Support stats

| weapon | main | support | signature | hands |
| --- | --- | --- | --- | --- |
| Salvage Cleaver | Strength | Grit | execution | 1H melee |
| Rusted Hatchet | Strength | Agility | execution | 1H melee |
| Rusted Machete | Strength | Agility | execution | 1H melee |
| Nail Bat | Strength | Presence | execution | 1H melee |
| Kiln-Forged Sword | Strength | Grit | execution | 1H melee |
| Bone Cleaver | Strength | Grit | execution | 2H melee |
| Silvered Cleaver | Strength | Agility | counter | 1H melee |
| Rebar Spear | Strength | Agility | counter | 2H melee |
| Wrecking Bar | Grit | Strength | counter | 1H melee |
| Slag Maul | Grit | Strength | counter | 2H melee |
| Chain Wrench | Grit | Strength | disruption | 1H melee |
| Stun Baton | Agility | Wits | disruption | 1H melee |
| Pipe Pistol | Agility | Wits | precision | 1H firearm |
| Nail SMG | Agility | Grit | precision | 1H firearm |
| Scrap Shotgun | Agility | Strength | execution | 2H firearm |
| Shock Probe | Wits | Agility | disruption | 1H melee |
| Spark Lance | Wits | Agility | disruption | 2H melee |
| Hunting Rifle | Wits | Agility | precision | 2H firearm |
| Wire Rifle | Wits | Agility | precision | 2H firearm |
| Rail-Spike Rifle | Wits | Strength | precision | 2H firearm |
| Holdout Revolver | Presence | Agility | suppression | 1H firearm |
| Officer Revolver | Presence | Wits | suppression | 1H firearm |
| Flare Gun | Presence | Wits | suppression | 1H firearm |

The support stat is the top-level `support_stat` field of a weapon in [items.json](../data/items.json). Content validation rejects a weapon without one, or with one equal to its attack stat.

## 3. Pillar 2: loadout synergies

A synergy links **two equipped slots**: weapon + armor, weapon + accessory, or armor + accessory. It is on while both pieces match and off the moment one is swapped. All 21 are authored in [loadout_synergies.json](../data/loadout_synergies.json); the rules are in [loadout_rules.gd](../scripts/domain/loadout_rules.gd).

Armor weight follows protection: rating 1–2 is light, 3 is medium, 4–5 is heavy.

### Weapon + armor

| synergy | weapon | armor | effect |
| --- | --- | --- | --- |
| Skirmisher | one-handed weapon | light | +5 Dodge, Opening +25% damage |
| Vanguard | one-handed counter weapon | medium or heavy | +5 Block, Riposte +25% damage |
| Brawler | one-handed execution weapon | medium or heavy | +20% damage to a weakened enemy, −5% damage taken |
| Juggernaut | two-handed melee weapon | heavy | +10% damage, −10% damage taken |
| Sharpshooter | two-handed firearm | light | +10 accuracy, first exchange +50% damage |
| Enforcer | suppression weapon | medium or heavy | +5% damage, −10% damage taken |

### Weapon + accessory

| synergy | weapon | accessory | effect |
| --- | --- | --- | --- |
| Shield Wall | one-handed weapon | any shield | Riposte +20% damage |
| Deadeye | precision weapon | Sniper Scope or Field Scanner | +10 accuracy, Opening +15% damage |
| Quickdraw | one-handed firearm | Gunslinger Holster | first exchange +50% damage, start with 1 Momentum |
| Predator | execution weapon | Wolf-Fang Charm | +25% damage to a weakened enemy, heal 15 HP on victory |
| Lawbringer | suppression weapon | Brass Star or Trader Token | +15% damage |
| Live Wire | disruption weapon | Mechanic Gloves or Grounding Straps | +5 accuracy, Opportunity +50% damage |
| Anchor | counter weapon | Dredge Chain | +10 Block, Riposte +15% damage |
| Gambler | any weapon | Lucky Die | Opportunity +40% damage |
| Trickster | precision or disruption weapon | Mirror Shard or Stalkhide Wraps | +5 Dodge, Opening +20% damage |

### Armor + accessory

| synergy | armor | accessory | effect |
| --- | --- | --- | --- |
| Bastion | heavy | any shield | +10 Block, −10% damage taken |
| Buckler Dance | light | any shield | +10 Dodge |
| Phantom | light | Stalkhide Wraps, Gunslinger Holster, Signal Compass or Lucky Die | +10 Dodge |
| Wastelander | Hazmat Wrap, Dust Cloak, Ashen Wrap, Stalker Cloak or Mutant-Hide Vest | Filter Mask | −10% damage taken, heal 10 HP on victory |
| Road Warden | medium or heavy | Brass Star, Trader Token, Dredge Chain or Wolf-Fang Charm | −8% damage taken |
| Field Rig | light or medium | Field Scanner, Mechanic Gloves, Grounding Straps, Sniper Scope or Mirror Shard | +5 accuracy |

### Road-Ready (full kit)

Holding one synergy of **each** pair type at once makes the loadout a full kit: a further **+10% damage and −10% damage taken**. This is the reason to plan all three slots together instead of picking each on its own.

### Rules

- Effects are flat, deterministic bonuses to numbers the combat screen already shows. A synergy never rolls dice.
- Effects of every active synergy add up. Damage-taken reductions are capped at −40% in total.
- Accuracy, Block and Dodge bonuses are multiples of 5, because the combat screen rounds chances to 5.
- "Weakened enemy" is the execution threshold: 40% HP or below, 60% with Bloodlust. Only execution weapons reach it.
- "First exchange" is the first round of a fight.
- An empty firearm fights as bare hands, so it holds no weapon synergy until it is loaded.
- Synergy damage reduction applies after armor and before suppression.
- Victory healing is applied once, with the rest of the victory rewards.
- One accessory slot, as before. The run save schema did not change.

Content validation requires every weapon, armor and accessory to belong to at least one synergy, every pair type to exist, every effect to be a known key and a bonus (never a penalty), and every named item to go in the slot the synergy names.

## 4. Where the player sees it

| screen | what it shows |
| --- | --- |
| Inventory | Under the four equipment slots: `SYNERGY • names` and the summed effects, or a one-line hint when nothing links |
| Item sheet, weapon | `SCALES WITH Grit 8 (+15% damage per point) and Strength 4 (+7.5% per point)` and the multiplier in hand. A spare weapon is read as if equipped, with its own stat bonus |
| Item sheet, any gear | A SYNERGIES panel: each synergy the item can join, what the partner slot needs, the effect, and whether it is ACTIVE, READY (equipping this switches it on) or still needs a partner |
| Item sheet, comparison | "Synergy gained" and "Synergy lost" notes; damage and damage-taken rows include synergy effects |
| Stats sheet | Per stat: main stat or support stat of the weapon in hand and what a point is worth, or "no effect" |
| Level-up | On the two stats that matter: `Wrecking Bar damage x1.85 → x2.00 (+15% per point, main stat)` as points are drafted |
| Combat, status strip | `SYNERGY • NAME • NAME` |
| Combat, tactics sheet | The weapon multiplier line, and per action the synergy effects that apply to it right now |
| Combat log | `SYNERGY −N` after `ARMOR` when a synergy absorbed damage |
| Victory receipt | `HP +15 (synergy)` |

## 5. Saved fights

Combat rules are versioned. A fight saved on rules v4 finishes on v4: old damage curve, no synergies, no status label, no victory heal. A fight started after this change runs on v5. `NarrativeCombat.VERSION` is 5 and `V4_VERSION` is 4.

## 6. Tools

- [playthrough_analytics.gd](../tools/playthrough_analytics.gd): the `cautious`, `informed` and `aggressive` models now build a kit. They keep the best weapon and the highest armor rating, then wear the armor of that rating and the accessory that switch on the most synergy, and will buy an accessory that completes a kit. `random` and `novice` wear what they find. Every run records the synergies worn at the end. A firearm is now scored by the ammunition left for it (full value from five shots), after one run stalled for 80 rounds in a gate fight holding a revolver with one round.
- [playthrough_report.py](../tools/playthrough_report.py): section 14 gains the share of runs ending with any synergy and with Road-Ready, and a per-synergy table for `informed`.
- [enemy_curve.py](../tools/enemy_curve.py) fixtures are unchanged: the expected fighter wears a weapon and armor and no accessory, so it holds at most a weapon + armor synergy. A full kit is meant to beat the curve.

## 7. Not built (staged)

- **A second accessory slot.** More combinations, but it changes the run save schema and the inventory layout.
- **Stat-pair passives.** A passive that switches on at a stat threshold, for example Strength 7 and Grit 5. This is the closest match to Life in Adventure's ability unlocks.
- **Synergy tags on items** instead of id lists, so new gear joins a synergy without editing the synergy file.

## 8. Verification

| check | result |
| --- | --- |
| Test suite ([test_runner.gd](../tests/test_runner.gd)) | 4167 pass, 6 fail. The six are the number pins deferred since balance Phase 0 (Warden two-to-three hits, eight-heart attrition, the three XP projections, random actions against crows). None is new. |
| Data audit ([data_package_audit.gd](../tools/data_package_audit.gd)) | 9 of 9 |
| Layout smoke ([layout_ui_smoke.gd](../tests/layout_ui_smoke.gd)) | 2229 assertions, 0 failures |
| Enemy curve (`enemy_curve.py --check`) | 21 of 21 optional adversaries on target |
| Screens at 393 × 852 | Inventory, item sheets (worn weapon, spare weapon, spare armor, spare accessory), stats, level-up, combat, tactics sheet |

The screen pass found two faults, both fixed and covered by tests:

- The stats sheet's weapon line did not wrap, so a long weapon name pushed the sheet past the screen edge.
- A spare weapon's scaling ignored that weapon's own stat bonus (a Hunting Rifle read Wits 2 when holding it gives Wits 3).

Not verified: a real phone, and play by a person.

## 9. Balance

### Enemies

Under v5 the expected fighter (Strength 7 to 9 by R4 to R6, no accessory) deals 13% to 19% more than under v3, plus up to 10% from Juggernaut. With no other change, 10 of the 11 optional R4 to R6 adversaries fell below their tier's loss target, by 5 to 25 points, and late gates were easier. Health and damage were raised until the curve was back on target:

| adversary | health | damage |
| --- | --- | --- |
| Vault Scavengers | 350 → 440 | 39–58 → 42–63 |
| Security Drones | 420 → 525 | 44–66 → 53–79 |
| Kilnback | 420 → 490 | 37–56 → 38–57 |
| Foundry Sentinel (gate) | 470 → 515 | unchanged |
| Glass Cult | 460 → 575 | 43–64 → 45–67 |
| Cinder Mauler | 480 → 600 | 47–70 → 49–74 |
| Salt Colossus | 600 → 800 | 56–84 → 77–116 |
| Ossuary Hound | 400 → 500 | 40–60 → 42–63 |
| Choir Champion (gate) | 420 → 490 | unchanged |
| Ash Stalker | 420 → 540 | 45–67 → 47–70 |
| Tunnel Hunters | 450 → 545 | 43–64 → 45–67 |
| Cable Eater | 450 → 575 | 48–72 → 58–87 |
| Reservoir Maw | 580 → 780 | 51–76 → 62–93 |
| Pack Leader (gate) | 380 → 445 | unchanged |
| Citadel Guard | 460 → 535 | 45–68 → 47–71 |
| Warden Machine | 570 → 670 | 53–80 → 55–83 |

R1 to R3 are unchanged. The Slag Maul's base damage went from 52–80 to 46–70: its main stat, Grit, also buys hearts, and in the first tuned pass informed runs that started with Grit highest won 64%. That fell to 56%; Grit still leads (see below).

### Playthrough harness

2000 runs per model, seed base 100000 (the base the numbers were tuned on). "Before" is the same harness on the v4 rules just before this change.

| model | target | before | v5, enemies untouched | v5, final |
| --- | --- | --- | --- | --- |
| random | below 1% | 0.0% | 0.0% | 0.0% |
| novice | 2–5% | 0.0% | 0.0% | 0.0% |
| cautious | 2–5% | 5.7% | 5.7% | **3.0%** |
| informed | 15–25% | 18.9% | 24.4% | **19.6%** |
| aggressive | 5–10% | 8.7% | 17.9% | **9.9%** |

On fresh seeds (seed base 200000, never used for tuning) the final numbers hold: random 0.0%, novice 0.0%, cautious 3.0%, informed 20.1%, aggressive 7.0%.

The target check now misses 3 bands instead of 5 (2 on the fresh seeds), and every miss is the novice model (0% wins, so it is not above random, and on seed base 100000 it sits just over 3 points below cautious). That was true before this change and is left to the balance plan.

Cautious gate survival still falls from 99% at R1 to 26% at R6 (targets: at least 85%, at most 45%).

Synergies in play at the end of a run: about 97% of runs of every model wear at least one, because most pairs switch on by accident. A full Road-Ready kit is worn at the end of 18% (cautious) to 24% (aggressive) of runs. Wins by synergy worn at the end, informed model: Anchor 70%, Juggernaut 53%, Road-Ready 38%, Brawler 28%, Road Warden 23%, Lawbringer 4%, Enforcer 3%. These mostly follow the weapon underneath: the heavy melee weapons win and the revolvers lose.

### Known imbalance: starting stat

The rework widened the gap between starting builds. Informed wins by highest starting stat:

| highest starting stat | before | after |
| --- | --- | --- |
| Grit | 43.4% | 56% |
| Strength | 28.1% | 22% |
| Presence | 5.5% | 17% |
| Agility | 5.8% | 7% |
| Wits | 9.9% | 3% |

Grit gives both hearts and, now, more damage per point on the Grit weapons. Wits weapons are the Shock Probe (a cheap tier-1 weapon; informed runs ending with it win 2%, 9% before) and the rifles, which need ammunition. The R4 to R6 health increase was set against a Strength fighter with a tier-3 sword, so it falls hardest on builds still holding a tier-1 weapon. A weapon pass (the Shock Probe, pistols and revolvers up; Grit's double value looked at) is the next balance step.

## 10. Sources

Research into Life in Adventure and similar games, used for the two pillars:

- Life in Adventure abilities: https://cobraknife.com/life-in-adventure/abilities/abilities/
- Life in Adventure one-handed weapons: https://cobraknife.com/life-in-adventure/one-handed/one-handed-weapons-list/
- Life in Adventure armor and clothing: https://cobraknife.com/life-in-adventure/armor/armor-clothing-list/
- Life in Adventure stats: https://life-in-adventure.fandom.com/wiki/Stats
- Review: https://random-games.com/2023/02/10/life-in-adventure/
- Stat priorities: https://www.appgamer.com/life-in-adventure/where-should-focus-my-stats
