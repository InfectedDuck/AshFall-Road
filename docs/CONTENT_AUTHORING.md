# Content authoring guide

Gameplay content lives in `data/*.json`; UI scripts never calculate or embed individual event outcomes. Restart the project after editing data, then run the headless tests before playing.

The main `data/events.json` file holds baseline content. Self-contained narrative packs may live in their own JSON document and are merged by `ContentRepository`; `data/bunker41_events.json`, `data/rustsea_events.json`, and the staged Living Road pack are current examples. Event IDs must remain globally unique across every document.

Prose-only revisions are stored separately from mechanics. `data/narrative_overrides_v1.json` replaces the introduction and outcome text for the 33 launch-facing Outskirts, Salt Flats, global, and fallback events. `data/narrative_overrides_v11.json` contains the remaining 43 baseline rewrites. New choices are authored as a plain baseline passage in `events.json` plus the polished passage in the matching override file, so the override layer stays the single source of live prose. Both files load unconditionally, so all 76 baseline events use polished prose regardless of the Living Road setting. An override is keyed by event ID, choice index, and outcome key; it cannot add, remove, or reorder a choice or mutate a reward. The test suite removes all prose fields and compares the live launch records to `events.json` to prove mechanical equivalence across all 76 baseline events.

## Content budgets

- `regions.json`: 6 ordered regions, each with 10 regional event IDs.
- `events.json`: 60 regional events, 12 global events, 1 fallback, and 3 finale stages.
- `living_road_events.json`: 15 optional callback events plus source-outcome flag patches, loaded only when `ashfall/release/living_road_enabled` is true.
- `road_ledger.json`: 25 non-power discovery chapters with branch-specific variants and spoiler-safe locked hints.
- `items.json`: 48 items across weapons, armor, accessories, backpacks, consumables, ammunition, and utility.
- `conditions.json`: nine harmful injuries/conditions and four helpful temporary conditions.
- `adversaries.json`: 13 reusable combat threat definitions, including Mutant Crows.

## Event rules

Every normal event needs an ID, title, 60–90 word body, positive integer weight, repeat policy, and 2–4 choices. A choice may contain requirements, costs, an approach, and either a percentage check, a certain outcome, or a tactical `combat` definition.

Checked choices use `check.stat` plus one internal `check.difficulty`: `easy`, `favorable`, `risky`, `hard`, or `desperate`. Numeric targets are rejected. The engine converts the survivor's effective stat into a percentage, rounded to 5% steps and clamped to 5%–95%. Outcomes may define `success`, `failure`, `critical_success`, and `critical_failure`. Every authored outcome text must contain 30–50 words. If a critical-specific outcome is absent, the engine falls back to ordinary success or failure.

Consequences can change HP, satiety, Fatigue, Radiation, items, conditions, flags, or the follow-up event. Use `lethal: true` only for an explicitly authored death consequence; never encode lethal outcomes as an arbitrary negative HP value. Ordinary chains should stop within three direct stages. An earned, unique expansion arc may run longer only when every handoff is tested and every branch can eventually return to ordinary journey selection. Prose uses restrained second-person present tense, concrete sensory detail, teen-rated non-graphic tension, and no assumption that a repeatable/global event followed a particular encounter.

An outcome may use `experience` for an exceptional authored story milestone worth 10–20 XP. Do not use it for ordinary travel, difficulty, or combat rewards; the engine grants those centrally. Intermediate chain nodes do not receive the normal journey reward, preventing longer narrative routes from becoming XP farms.

Tag at least one eligible event in each region with `supply_opportunity`. A successful route in every supply event must provide food worth at least two satiety points. On the fifth regional draw, the selector guarantees a supply opportunity if one has not appeared earlier.

Every regional pool must also contain a combat opportunity. If none appears during the first three draws, the fourth draw guarantees one; no region presents more than two. A combat opportunity is counted even when the player chooses negotiation, avoidance, or Flee. The first run event remains non-combat.

## Experience progression

- Survivors start at Level 1 with 0 XP; levels and XP are erased by permadeath.
- Normal journey completion grants 4 XP and regional checkpoints grant 10 XP.
- Successful Favorable/Risky/Hard/Desperate checks add 2/4/7/10 XP; Easy adds none.
- Combat victory grants the adversary's authored `xp_reward`; Flee grants no combat XP.
- Natural 20 never multiplies XP, and damage dealt never awards partial XP.
- Level thresholds are 50, 110, 180, 260, 350, 450, and 570 cumulative XP.
- Each level banks one point. Points remain allocatable only at checkpoints and do not heal until a confirmed Grit increase crosses a heart threshold.

Use `unique: true` for once-per-run events. Repeatable events automatically respect the engine's three-event cooldown. Eligibility can require or forbid flags or require items. It also supports `min_region_index`/`max_region_index` for natural narrative timing and `requires_any_flags` when any earlier branch may lead to the same chapter. `narrative_priority` reserves the next eligible event slot for an earned continuation, except when the fifth regional draw must guarantee food. Choice `requires` supports `flags` and `any_flags`; locked copy must describe the missing context rather than expose raw flag names. Never manually add the fallback event to a regional pool; the selector supplies it only when nothing else is eligible.

## Living Road callbacks

The v1.1 callback pack is intentionally disabled in the release project setting until its closed-track update. Enable `ashfall/release/living_road_enabled` only in a deliberate v1.1 build; tests use `ContentRepository.new(true)` to qualify it without changing the release binary.

Every callback event must:

- Be `global`, `unique`, and declare one exact `callback_region` matching its eligibility range.
- Use `living_road_callback: true` and a stable `callback_thread`.
- Forbid `lr_callback_region_N`, then add that same consumed flag in every possible outcome.
- Add another meaningful branch flag in every outcome, including refusal and failure.
- Use higher `narrative_priority` for continuing chapters than for thread openings.
- Return cleanly to the normal journey; no callback is required for the Citadel.
- Avoid lethal outcomes before the Glass Wastes and avoid adding new adversary rules.

Only one callback may consume a normal slot in a region. The fourth-slot combat guarantee and fifth-slot supply guarantee override narrative priority. If a callback misses its exact region, its eligibility expires without blocking the run.

Source-event patches add branch flags only when the callback pack is enabled. Never edit the established source choice order to support a callback. Each source outcome must identify a distinct remembered interpretation so success, failure, combat, avoidance, and refusal remain valid story paths.

## Road Chronicle discoveries

Chapters are authored in `data/road_ledger.json` and shown to the player in the Road Chronicle. A chapter is profile knowledge, never survivor power. Definitions use an event trigger or a produced narrative flag, optional branch variants, a spoiler-safe hint, and stable character IDs. `StoryDiscovery` records a chapter only after an authoritative result exists and saves the profile idempotently. Every discovered variant is kept: a later run adds a second account for the same chapter rather than overwriting what an earlier survivor recorded, and the Chronicle presents them as separate accounts from different runs. Chapters and accounts are therefore counted separately. Ledger entries may not grant items, stats, XP, odds, currency, healing, or resurrection.

Adding an entry requires checking:

1. Every referenced event exists in the enabled content boundary. `ContentRepository` drops any chapter whose event is not loaded, so a chapter belonging to disabled content never appears in the Chronicle or in its progress denominator.
2. Every required flag is produced by at least one authored outcome.
3. Variant IDs are non-empty and unique within the chapter.
4. The locked hint suggests atmosphere or location, never the mechanical solution.
5. Character state describes the last known situation without pretending uncertainty was resolved.

## Health and survival rules

- Base Grit determines maximum hearts: `3 + min(Grit, 5) + floor(max(Grit − 5, 0) / 5)`.
- Starting Grit 1–5 still gives 4–8 hearts. Crossing a later Grit threshold during checkpoint allocation grants one 50-HP heart immediately.
- Equipment and temporary Grit modifiers never alter maximum hearts.
- Each heart is one 50-HP segment. Exact HP and partial segments are derived from the same HP pool.
- Satiety is an integer from 0–4. Normal journey progress removes one point every two events; a tick at zero instead removes 50 HP.
- Event content should change health through `vitals.health` and satiety through `vitals.satiety`.
- Fatigue and Radiation remain named pressure values and may be changed through `pressures`.
- A supply opportunity should reward items whose total `effects.satiety` is at least 2.

## Item and combat rules

New encounters use **combat rules 2**. The full authoring contract, save boundary, deliberate shield reward changes and measured balance results are in [NARRATIVE_COMBAT_REPORT.md](NARRATIVE_COMBAT_REPORT.md). Existing saved fights retain rules 1 until completion.

- Equipment slots are exactly `weapon`, `armor`, `accessory`, and `backpack`.
- Every item needs a unique, stable `icon_id`. Until matching artwork exists, the UI resolves that ID to the item's category silhouette; final local textures can later use `assets/items/<icon_id>.png` without changing content or saves.
- Every weapon needs a `combat` object with `attack_stat`, `damage_min`, `damage_max`, and `ammo_per_attack`.
- Ranged weapons also declare `ammo_type`. Each attack consumes compatible ammunition; an unloaded ranged weapon visibly falls back to unarmed combat.
- The displayed weapon range uses the uncapped diminishing multiplier `0.8 + stat / (stat + 5)`, full effective stats, additive applicable bonuses and enemy Brace reduction, with one final rounding step. Rules 2 maps successful faces from the required face to 20; misses deal zero. Rules 1 alone keeps the former 1-to-20 damage mapping.
- Every weapon also declares `signature`, `two_handed` and `opportunity_name`. Mastery checks its associated base run stat against 6, never equipment or temporary bonuses.
- Armor retains its rating and flat/percentage reduction. In rules 2, apply armor before active defense, suppression and the single exposure/failure multiplier; report each cause separately. Guard remains only in legacy encounters.
- Each adversary declares `narrative_combat.organic`, a committed repeating `sequence`, and an honest literary `tell` for every move it uses. Shared move numbers and three-variant narration are in `data/combat_content.json`. Machines must never receive organic-only suppression or biological death narration.
- Shield accessories declare `shield`, `block_bonus`, and `dodge_bonus`. Two-handed weapon equip returns a shield to inventory; shield equip is refused while a two-handed weapon is active.
- Backpacks use `capacity_bonus`; modifiers may target a stat or named approach.
- Consumables may change HP, satiety, pressures, remove conditions, or add a temporary condition. Every harmful condition without a natural checked-choice duration must appear in at least one consumable's `effects.remove_conditions`; validation rejects permanent conditions with no treatment route.
- Positive temporary conditions use `duration_checks`; they tick after contributing to a check.
- The Status sheet derives its remedy buttons directly from `effects.remove_conditions`. Keep `use_text` honest about treatment, HP, and pressure side effects because the item is consumed and autosaved immediately.

Each combat choice needs `combat.adversary_id`, `victory`, and optionally `critical_victory`. The referenced adversary must define maximum HP, minimum/maximum damage, displayed weapon, portrait ID, named flee difficulty, `xp_reward` from 1–100, and optional critical condition. Set `can_flee: false` only where escape is deliberately forbidden. Do not retain old one-roll failure damage on a combat choice, because the enemy round already applies damage.

All referenced IDs must exist. The repository validator rejects missing events, items, conditions, outcomes, portraits, combat weapons, adversaries, regional supply opportunities, duplicate polished sentences, prohibited filler, unreachable callback flags, callbacks without exits, duplicate Ledger variants, and defined items without any starting or acquisition route before the main menu becomes playable.

## Balance review for each event

1. The body establishes enough information to choose without guessing.
2. Each checked choice communicates only its stat and exact success percentage.
3. Failure is painful but not an unexplained instant death.
4. Different stat/equipment strategies receive meaningful opportunities.
5. The easiest choice is not automatically the best expected value.
6. Rewards match the region and do not invalidate survival pressure.
7. Eligibility cannot create a dead end.
8. Unique/repeat behavior is intentional.
9. Follow-up depth is three or less.
10. Combat HP and damage fit the encounter's intended threat tier.
11. Supply routes provide at least two total satiety on success.
12. Teen-rated language and imagery remain non-graphic.
13. Introduction and outcome prose meets the validated word-count targets.
14. Combat XP is tempting but does not repay the full survival cost of an apex threat.
15. No sentence of six or more words is reused in another polished baseline passage.
16. The outcome states what physically happened, why it happened, and what symptom, object, debt, or relationship remains.
17. A callback failure or refusal changes the later interpretation instead of silently ending the thread.

## Validation loop

Run the command in `docs/TESTING.md`. Then play at least one fixed seed twice with the same candidate and decisions. Event order, prepared rolls, combat results, ammunition use, and outcomes must match. Extend the assertions for new content and rules rather than relying only on manual play.

## Mechanical-change allowlist

Mechanical snapshots are never updated silently. Every intentional change to `data/events.json` is recorded here with the assertions that had to move.

### M05 — equipment acquisition routes

Appended choices only; every original choice keeps its index, label, check, and rewards.

| Event | New choice | Resolution | Success | Failure |
|---|---|---|---|---|
| `outskirts_market` | 2 Earn the Rusted Hatchet | certain | `rusted_hatchet` +1, Fatigue +6 | — |
| `outskirts_market` | 3 Earn the Nail Bat | certain | `nail_bat` +1, Fatigue +6 | — |
| `flats_convoy` | 2 Repair the awning for a Dust Cloak | Wits / favorable | `dust_cloak` +1 | Fatigue +6 |
| `flats_convoy` | 3 Trade a useful warning for the Lucky Die | Presence / favorable | `lucky_die` +1 | Fatigue +6 |
| `marsh_body` | 2 Recover the Rebar Spear | Strength / risky | `rebar_spear` +1 | Fatigue +6 |
| `marsh_body` | 3 Recover the Tire Armor | Strength / risky | `tire_armor` +1 | Fatigue +6 |
| `industrial_locker` | 2 Open the security locker for the Stun Baton | Wits / risky | `stun_baton` +1 | Fatigue +8 |
| `industrial_locker` | 3 Salvage the Scavenger Rig | Strength / risky | `scavenger_rig` +1 | Fatigue +8 |
| `industrial_office` | 2 Unlock the Hunting Rifle cabinet | Wits / hard | `hunting_rifle` +1, `rifle_rounds` +4 | Fatigue +8 |
| `industrial_office` | 3 Recover the Flare Gun | Agility / risky | `flare_gun` +1, `shotgun_shells` +3 | Fatigue +8 |

One further reward change closes the last unreachable item: `global_drop` choice 1 success now also grants `climbing_rope` +1 from the pod's cut parachute line. Without it, `climbing_rope` existed only as a Living Road callback reward while `outskirts_sinkhole` choice 1 and `marsh_bridge` choice 1 required it, so both choices were unreachable in launch v1.

Rules these routes follow:

- No `critical_success` or `critical_failure` is defined, so a natural 20 or 1 resolves through the ordinary reward with no multiplier.
- Failure grants no equipment and changes nothing except Fatigue: no health damage, conditions, satiety, or currency.
- Each of the five events stays unique and stops at four choices, so the two alternatives are mutually exclusive within a run.
- The routes are present in both builds; Living Road callback rewards remain mutually exclusive inside their own encounters.
- Event weights, tags, and supply guarantees are unchanged.

Assertions moved with the content: checked choices 138 → 146, outcome passages 372 → 390. `ContentRepository.validate_all()` now runs `_validate_item_acquisition` in every build rather than only when the expansion is enabled.
