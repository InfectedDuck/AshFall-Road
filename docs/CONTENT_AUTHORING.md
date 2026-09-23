# Content authoring guide

Gameplay content lives in `data/*.json`; UI scripts never calculate or embed individual event outcomes. Restart the project after editing data, then run the headless tests before playing.

The main `data/events.json` file holds baseline content. Self-contained narrative packs may live in their own JSON document and are merged by `ContentRepository`; `data/bunker41_events.json`, `data/rustsea_events.json`, and the Living Road pack are current examples. Event IDs must remain globally unique across every document.

Prose-only revisions are stored separately from mechanics. `data/narrative_overrides_v1.json` replaces the introduction and outcome text for the 33 launch-facing Outskirts, Salt Flats, global, and fallback events. `data/narrative_overrides_v11.json` contains the remaining 43 baseline rewrites. New choices are authored as a plain baseline passage in `events.json` plus the polished passage in the matching override file, so the override layer stays the single source of live prose. Both files load unconditionally, so all 76 baseline events use polished prose regardless of the Living Road setting. An override is keyed by event ID, choice index, and outcome key; it cannot add, remove, or reorder a choice or mutate a reward. The test suite removes all prose fields and compares the live launch records to `events.json` to prove mechanical equivalence across all 76 baseline events.

## Content budgets

- `regions.json`: 6 ordered regions, each with 10 regional event IDs.
- `events.json`: 60 regional events, 12 global events, 1 fallback, and 3 finale stages.
- `living_road_events.json`: 15 callback events plus source-outcome flag patches, loaded by the default release configuration when `ashfall/release/living_road_enabled` is true.
- `road_ledger.json`: 29 non-power discovery chapters with branch-specific variants and spoiler-safe locked hints (the explicit compatibility configuration loads 11).
- `items.json`: 72 items across weapons, armor, accessories, backpacks, consumables, ammunition, and utility (50 launch, 15 Phase A build items, 3 grit/wire build weapons, 4 build accessories §A01 §C01; verified by `tools/data_package_audit.gd` 9/9).
- `conditions.json`: twelve harmful injuries/conditions and seven helpful temporary conditions (19 total with Phase A, §A01).
- `adversaries.json`: 21 reusable combat threat definitions, including Mutant Crows, the four N-series creatures, and four Phase A mutants (§A01).

## Event rules

Every normal event needs an ID, title, 60–90 word body, positive integer weight, repeat policy, and 2–4 choices. A choice may contain requirements, costs, an approach, and either a percentage check, a certain outcome, or a tactical `combat` definition.

Checked choices use `check.stat` plus one internal `check.difficulty`: `easy`, `favorable`, `risky`, `hard`, or `desperate`. Numeric targets are rejected. The engine converts the survivor's effective stat into a percentage, rounded to 5% steps and clamped to 5%–95%. Outcomes may define `success`, `failure`, `critical_success`, and `critical_failure`. Every authored outcome text must contain 30–50 words. If a critical-specific outcome is absent, the engine falls back to ordinary success or failure.

Consequences can change HP, satiety, Fatigue, Radiation, items, conditions, flags, or the follow-up event. Use `lethal: true` only for an explicitly authored death consequence; never encode lethal outcomes as an arbitrary negative HP value. Ordinary chains should stop within three direct stages. An earned, unique expansion arc may run longer only when every handoff is tested and every branch can eventually return to ordinary journey selection. Prose uses restrained second-person present tense, concrete sensory detail, teen-rated non-graphic tension, and no assumption that a repeatable/global event followed a particular encounter.

## Choice costs and committed receipts

Use `costs.items` and `costs.pressures` only for a guaranteed price paid when the choice is made. The event UI exposes each such price on every choice row, including an affordable row and its accessibility label; do not hide a certain payment in outcome prose. Checks, combat, and their outcomes remain uncertain and are presented separately.

The result screen reads the engine's committed receipt. It lists only item and pressure changes actually applied, including a combat choice's entry cost on victory or Flee. Author outcome text so it agrees with that receipt, especially when capacity, full health, or a clamp means no corresponding change can occur. Reading a result, recap, or Chronicle never applies content fields or rolls RNG.

An outcome may use `experience` for an exceptional authored story milestone worth 10–20 XP. Do not use it for ordinary travel, difficulty, or combat rewards; the engine grants those centrally. Intermediate chain nodes do not receive the normal journey reward, preventing longer narrative routes from becoming XP farms.

Tag at least one eligible event in each region with `supply_opportunity`. A successful route in every supply event must provide food worth at least two satiety points. On the fifth regional draw, the selector guarantees a supply opportunity if one has not appeared earlier.

Every regional pool must also contain a combat opportunity. If none appears during the first three draws, the fourth draw guarantees one; no region presents more than two. A combat opportunity is counted even when the player chooses negotiation, avoidance, or Flee. The first run event remains non-combat.

## Experience progression

- Survivors start at Level 1 with 0 XP; levels and XP are erased by permadeath.
- Normal journey completion grants 4 XP and regional checkpoints grant 10 XP.
- Successful Favorable/Risky/Hard/Desperate checks add 2/4/7/10 XP; Easy adds none.
- Combat victory grants the adversary's authored `xp_reward`; Flee grants no combat XP.
- Natural 20 never multiplies XP, and damage dealt never awards partial XP.
- Level thresholds are 40, 88, 144, 208, 280, 360, and 456 cumulative XP.
- Each level banks one point. Points remain allocatable only at checkpoints and do not heal until a confirmed Grit increase crosses a heart threshold.

Use `unique: true` for once-per-run events. Repeatable events automatically respect the engine's three-event cooldown. Eligibility can require or forbid flags or require items. It also supports `min_region_index`/`max_region_index` for natural narrative timing and `requires_any_flags` when any earlier branch may lead to the same chapter. `narrative_priority` reserves the next eligible event slot for an earned continuation, except when the fifth regional draw must guarantee food. Choice `requires` supports `flags` and `any_flags`; locked copy must describe the missing context rather than expose raw flag names. Never manually add the fallback event to a regional pool; the selector supplies it only when nothing else is eligible.

## Living Road callbacks

The Living Road callback pack is enabled in the default release project setting. Use `ContentRepository.new(false)` only for documented baseline compatibility checks; no-argument loading and exported builds use the expanded 124-event configuration (15 callbacks plus the 12-scene betrayal arc).

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
- Heavier weapons may declare top-level `affinity_min` (2–6): the base attack-stat value needed for full power. Below it the weapon stays usable but unwieldy (−15 accuracy, −25% damage). Starting-kit weapons carry no requirement.
- Combat victory rolls the defeated adversary's `loot` table at 40% per entry through the run RNG; table-less kills pay exactly their authored reward and fleeing pays nothing.
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

### E02 — expanded opening hooks and Channel Nine refusal

The launch configuration is unchanged. In the expanded configuration only, the first regional draw is limited to the existing safe events tagged `opening_hook`; the third draw reserves an eligible, unvisited Channel Nine or Quiet Column source only if neither source appeared in the first two draws. The existing second-draw resource/equipment teaching rule, five-event regional size, combat cap, supply guarantee, callbacks, and save schema are unchanged.

| Event | Intentional data change | Resolution |
|---|---|---|
| `outskirts_market` | Adds `opening_hook` to its existing safe/equipment tags. | No choice, reward, flag, or condition changes. |
| `outskirts_cache` | Adds `opening_hook` to its existing safe/resource tags. | No choice, reward, flag, or condition changes. |
| `outskirts_child_radio` | Adds `opening_hook`; appends choice 2, **Leave the broadcast running**. | Certain; no authored item, pressure, condition, or flag. The ordinary event transaction still applies. |

Assertions added: expanded seeded openings select only safe hooks, all three hooks appear, the complementary second teaching event remains available, a third-slot source is present when the first two omitted both sources, and release content retains its existing opening pool. Outcome passages move from 401 to 402 in launch and 484 to 485 in expanded; choices move from 245 to 246 in launch and 297 to 298 in expanded. The original radio choices and their Living Road source patches retain their indices and contracts.

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

### N03/N04 — the pilot arc, ten scenes, and the support they need

Recorded before the content changed, per [NARRATIVE_REFINEMENT_PLAN.md](NARRATIVE_REFINEMENT_PLAN.md) §2. Each row is contracted in [NARRATIVE_CONSEQUENCE_MAP.md](NARRATIVE_CONSEQUENCE_MAP.md); the record or card that owns it is named. Nothing here is a silent snapshot update: `tools/mechanical_snapshot.gd -- --diff` is expected to report exactly these differences and no others.

#### Schema additions (N04)

All optional, all defaulted so every existing passage and choice keeps its current behaviour.

| Field | Where | Meaning |
|---|---|---|
| `scene_role` | event | `compact` (default), `substantial`, `chapter`, `finale`; selects the word band in plan §3. The default band, 60–100 setup and 30–65 outcome, is wider than the old fixed 60–90 / 30–50, so no legacy passage moves. |
| `body_variants` | event | `[{requires_any_flags, text}]`, first match wins, `body` is the required fallback. |
| `variants` | outcome | Same shape, `text` is the required fallback. Matched against the flags held **before** the outcome applies. |
| `requires.forbids_flags` | choice | Locks the choice when the run holds any listed flag. |
| `requires.reason` | choice | The player-facing lock label, replacing the two hard-coded Bunker strings as the default. |
| `requires.hidden_when_locked` | choice | The choice is absent rather than shown disabled. Used only where a visible lock would promise something the survivor cannot yet know about. |

`body_variants` and outcome `variants` are prose and are stripped by the snapshot before hashing. `requires.forbids_flags` is mechanical and is hashed.

**`scene_role` is hashed, deliberately** (corrected during N03, which found the tool and this note disagreeing). It is not prose: it is the contract that decides which word band a scene must satisfy, so silently demoting a chapter to compact is exactly the kind of change the snapshot exists to surface. A scene that changes role therefore appears as a signature difference and must be recorded here like any other mechanical change.

#### Engine repairs (N04)

- **X1, false costs.** `_change_item` clamped at zero while `_apply_outcome` printed the loss regardless, so an outcome removing an item the survivor lacked cost nothing and still reported a payment. The result line now reports only what actually moved. No content JSON changes; all 25 negative item entries keep their fields.
- **X2, `b41_voice_heard`.** Added to the `add_flags` of all three `bunker41_static` outcomes, beside the existing `b41_recording` / `b41_answered` / `b41_unprepared`. It is the only flag that means *heard the duty voice*; STORY_CANON §5 explains why `b41_contact` cannot serve and why the obvious substitute set over-fires. Consumers are the recognition variants in `bunker41_warden_remembers` and `final_gate_1`.

#### Content changes, by event

| Event | Change | Owner |
|---|---|---|
| `outskirts_child_radio` | drop orphan `helped_family` from choice 0 success; the four `lr_channel_*` flags carry the thread | record 1 |
| `lr_blue_van` | choice 0 gains `requires.any_flags [lr_channel_helped, lr_channel_misled]`, `reason "You never spoke to them"`, `hidden_when_locked`; new choice 3 *Show them the relay bearing*, `requires.flags [lr_channel_traced]`, `costs.items {signal_compass: 1}`, certain → `lr_family_linked`, `lr_callback_region_1`; four introduction variants keyed on the source flags | record 1 |
| `lr_voice_in_reeds` | introduction variants per source state, including the concrete `lr_family_silenced` case where no receiver exists (**P0 false history**) | record 1, batch F |
| `lr_last_battery` | same variant contract extended to region 3, where the introduction currently asserts a working transmitter after the set was destroyed (**P0 false history**) | record 1, batch F |
| `outskirts_bus` | prose only: the introduction names the ration shapes under the driver's seat and the first-aid bracket beside the release cable, so the food/medicine split is visible before commitment (plan §6). Items, checks, tags, weight unchanged | batch A |
| `global_quiet` | no change; carried as the pilot's compact-scene control | batch A |
| `bunker41_cartographer` | choice 0 gains `costs.items {canned_meat: 1}` and `requires.reason "You have no food to share"`, visible rather than hidden because the price is the point (**P0 false cost**); drop orphan `b41_mercy_refused` from choice 2 | record 6 |
| `marsh_lights` | appended choice 2 *Clear the nesting pool*, combat adversary `reed_widow` (portrait `enemy_widow`), `can_flee: true`; victory `items {purifier_ampoule: 1, clean_water: 2}` and `add_flags [widow_pool_cleared]`; introduction gains the raft that reads as firm ground and the laced boot | record 11, creature bible |
| `industrial_tank` | appended choice 2 *Clear the cooling jacket*, combat adversary `kilnback` (portrait `enemy_kilnback`), `can_flee: true`; victory `items {clean_water: 2}` and `add_flags [kilnback_rhythm_known]`; choice 1 success also gains `kilnback_rhythm_known`; drop orphan `rescued_engineer` from choice 0; introduction gains the scorch-rings | record 9, creature bible |
| `glass_shadow` | choice 0 success gains `add_flags [cinder_traveler_rescued]` and is rewritten as a rescue, items unchanged; introduction gains the fresh pale dust and the travelling shadow with nothing above it | record 10, creature bible |
| `bunker41_chapel_car` | choice 0 gains `requires.flags [b41_mercy_key]`, `forbids_flags [rustsea_key_with_mara]`, `reason "You do not hold the Key"`, visible; choices 1 and 2 stay ungated, so a survivor who never took the Key can no longer surrender it (**P0**) | record 7, card E |
| `rustsea_cartographers_debt` | choice 2 gains `requires.forbids_flags [b41_key_surrendered]`, so the Key cannot be handed over twice; `requires.flags [b41_mercy_key]` unchanged | record 7 |
| `bunker41_warden_remembers` | choice 2 gains `requires.forbids_flags [b41_key_surrendered, rustsea_key_with_mara]` and `requires.reason "You no longer hold the Key"`, visible; choice 0's outcome prose is rewritten so the weapon stays tracked and unfired and the machine holds because its protocol has no answer. `next_event`, choice count and the index-1 `warden_machine` fight are unchanged | record 7; plan §6 |
| `bunker41_door_closes` | choice 1 gains the same `forbids_flags` and the same `reason` (**P0**: Mercy was offered after the Key was given away); choice 3's `requires.any_flags` narrows from `[b41_choir_joined, b41_choir_records, b41_choir_split, b41_choir_bound]` to `[b41_choir_records, b41_choir_bound]` (**P0**: Ash was unlocked by affiliation without the confession), and its outcome gains one `variants` entry keyed on `b41_choir_bound` so the bound survivor hears the Choir play the record they kept instead of playing one they never took | records 7 and 8; STORY_CANON §6, §8 |
| `global_stranger` | appended ungated choice 2 *Press the wound with your own coat*, approach `medical`, Grit risky; success `pressures {fatigue: 4}` and `add_conditions [inspired]`, failure `pressures {fatigue: 4}` and `add_conditions [shaken]`; no items, no costs, no flags. The introduction gains the survivor's own coat lining so the route has evidence before it is offered (**P0 blocked action**) | batch A; plan §6 |
| `flats_tanker` | choice 0 success also grants `smoke_bomb` +1; `frame_pack` 1 and `scrap_parts` 2 are unchanged, as are choice 1 and both failures. The outcome now hands over the repacked flare casing its own prose already described | X4 |

Choice indices 0 and 1 are unchanged everywhere. The two appended combat choices take index 2 on events that had two choices; `lr_blue_van` takes index 3 on an event that had three.

`global_stranger` takes index 2 on an event that had two choices, so both item routes keep their indices, labels, requirements, checks and rewards. It is a check, so it can never dominate the certain water route, and it charges fatigue where that route returns it; it exists so the scene always has a legal action, not so it is ever the best one.

**X4, resolved by giving `smoke_bomb` a pre-marsh source rather than retiring the choice.** `marsh_raiders` choice 2 is region 2 and its only authored source was `rail_hunters` choice 0 victory in region 5, so no survivor could ever take it in its own region. `flats_tanker` choice 0 is the receiver because it is region 1, because it is the only reward in regions 0–1 whose passage already promises the object — "the locker opens on road flares" — and pays nothing for it, and because it is a unique Strength-risky salvage whose failure burns, so the charge stays earned. Retiring the choice was rejected: it is the only non-combat, non-social exit from the marsh ambush, and the item, its escape tag and its combat use all already exist. This repeats the `climbing_rope` repair recorded in the M05 section above, with the same rule: one existing reward gains one existing item and nothing else in the receiving scene moves.

**One lock label is deliberately broader than its gate, and is recorded rather than hidden.** `requires.reason` replaces the generated label for *whichever* gate closed the choice, and a choice has one reason. Record 7's `"You no longer hold the Key"` therefore also answers the positive gate on both choices that carry it: at `bunker41_door_closes` choice 1 a survivor who never took the Key reads it instead of the old `Requires the relevant Bunker Forty-One record`, and at `bunker41_warden_remembers` choice 2 a survivor carrying no Bunker evidence at all reads it instead of `Requires Bunker Forty-One testimony or evidence`. Both states are common, because most runs reach the Citadel without entering the Bunker. Card E scopes the string to `door_closes` 1 only and gives `chapel_car` 0 the wider `"You do not hold the Key"`, which is true of a survivor who never held it and of one who gave it away. `_test_key_possession_and_endings` pins the current string in every state, including the unevidenced one, so changing this decision is a two-string edit with a failing assertion to point at it.

#### New adversaries

`reed_widow` (threat 13, 130 HP, 30 XP, flee risky, critical `sprain`) and `kilnback` (threat 17, 360 HP, 65 XP, flee favorable, critical `burned`) join `data/adversaries.json` as new IDs, carrying `portrait_id` `enemy_widow` and `enemy_kilnback`; no existing adversary is renamed or reused. The Kilnback's 65 sits three above its threat band deliberately, because its host scene's safer choice already pays the same items for a two-XP check. Both are organic, use only the six existing moves with honest tells, take a critical condition from the thirteen defined (`sprain` and `burned`), and declare a `portrait_id` with no image, so they exercise the deliberate missing-portrait presentation rather than the raw `PORTRAIT / ID` fallback. The Salt Colossus and Cinder Giant remain environmental: no ID, no profile, no portrait.

**The Kilnback profile in the paragraph above was superseded on 8 September 2026.** It is left as the N03/N04 record of what shipped; the current profile is threat 16, 300 HP, 62-88 damage, 50 XP, and the reasoning is in the N05b section at the end of this document.

#### Assertions that move with this content

| Assertion | Was | Becomes | Why |
|---|---|---|---|
| Adversary count | 13 | 15 | Reed Widow and Kilnback |
| Combat choices (expanded) | 11 | 13 | the two appended creature fights |
| Checked choices | 146 launch / 176 expanded | 147 launch / 177 expanded | `lr_blue_van` choice 3 is certain and the two creature choices are combat, so only `global_stranger` choice 2 adds one |
| Outcome passages | 390 launch / 465 expanded | 394 launch / 470 expanded | four appended choices, each with its branches: two creature victories, `lr_blue_van` 3 (expanded only), and the `global_stranger` success/failure pair |
| Total choices | 236 launch / 281 expanded | 239 launch / 285 expanded | the same four appended choices |
| Word budgets | fixed 60–90 / 30–50 | role-driven bands | plan §3, defaulted so nothing legacy moves |
| Callback chapter shape | exactly 3 choices | 3 or 4 | `lr_blue_van` gains a fourth route for a survivor who traced the signal instead of answering it. The three original paths — a checked success/failure pair twice, then a certain refusal — are still required of every callback, so the contract that assertion protects is intact. |

Measured after the Channel Nine arc landed: **2,591 assertions, 0 failures**. The arc itself is locked by `_test_channel_nine_arc`, which proves all four source histories open the van on different words, that the cadence check is offered only to a survivor who spoke, that the relay bearing appears only for one who traced the signal and still carries the compass and withdraws when the compass is spent, that neither later chapter opens on a working radio after the set was destroyed, and that reopening a passage repeats it exactly without rolling anything.

Measured after the plan §6 repairs landed: **2,734 assertions, 0 failures**; layout 660, combat UI 0 failures, action UI 201; `tools/data_package_audit.gd` reaches **9 checks, 9 passed, 0 discrepancies** for the first time, because `global_stranger` was its last outstanding finding. The repairs are locked by `_test_key_possession_and_endings`, which proves that taking the Key and giving it to Mara closes Mercy at the gate with the authored reason while Silence and an earned Witness stay open, that a survivor still carrying it can still offer it, that the Key cannot be given to two people or by someone who never held it, that Choir membership alone no longer opens Ash while each of the two records still does and the two read as different passages, and that the Warden's refusal keeps a tracked, unfired weapon and its original chain; and by `_test_legal_actions_and_item_reach`, which proves the depleted pack still has one legal action in `global_stranger`, that no event in either configuration gates every choice, and that a Smoke Bomb is earnable in region 1 before the marsh asks for one.

Narrowing the Ash requirement leaves `b41_choir_split` written and unread; card E already owns its replacement consumer, a `bunker41_door_closes` introduction variant, which is not part of this change.

Counts are recorded from the run, not predicted here; the milestone record carries the measured numbers.



### N05 — the 73 ordinary scenes, by region

Drafted region by region and checked by an independent adversarial pass per region before anything was applied. Agents produced patch files rather than editing the repository, because three regional groups share `narrative_overrides_v1.json`, four share `v11`, and all of them write `scene_role` into `data/events.json`; a deterministic applier merged them one group at a time.

**Scope applied: 52 scenes touched, 43 introductions and 138 outcome passages rewritten, 20 scenes promoted to `substantial`, 34 mechanical fields changed.** The remaining ordinary scenes were left alone because their cards recorded no finding and their passages already work; the plan is explicit that compact scenes which work should stay compact.

Mechanical changes, grouped by kind:

| Kind | Events | Change |
|---|---|---|
| **Orphan flags retired** | `flats_signal` 0, `glass_antenna` 0, `marsh_filter` 0, `outskirts_siren` 0 | `success.add_flags` emptied, retiring `decoded_numbers`, `underrail_bearing`, `restarted_filter`, `silenced_siren`. Each had no consumer anywhere in either configuration. Under the retained 97-event compatibility build, `outskirts_siren` and `marsh_filter` now write no flag at all; their thread flags come from the Living Road source patches, so this is a deliberate consequence of retiring the orphan, not a loss. |
| **Orphan flags given consumers** | `flats_mirage`, `flats_crater` | `body_variants` keyed on `read_bone_warning` and `crater_warning`, so both flags are now read. |
| **Conditional passages** | `flats_convoy` 3, `marsh_ferryman` 0 | `success.variants` keyed on `crater_warning` and `marsh_map`. `flats_convoy` 3 was a **P0**: its success asserted detailed knowledge of the toll barricade that most runs never acquire. |
| **False costs repaired** | `global_trader` 0, `rail_hunters` 2 | Both were **P0**. The price moved from inside the outcome, where `_change_item` clamps it to nothing and the player is never told, to `requires.items` plus `costs.items`, where the choice previews and gates honestly. |
| **Rewards added to unpaid successes** | `flats_toll` 0, `glass_cult` 0, `glass_antenna` 0, `industrial_fire` 0, `marsh_ferryman` 1, `marsh_hut` 1, `global_crows` 1, `outskirts_sinkhole` 0, `rail_flood` 0, `rail_switch` 1, `rail_collapse` 1 | Each was a hard or riskier choice whose success paid nothing while a safer sibling paid the same or more. Items, pressure relief, or a beneficial condition added per the owning card. |
| **Honest failures** | `glass_storm` 0, `glass_meteor` 0, `industrial_scavs` 0 | Failure fields now match what the prose describes: radiation where irradiated dust enters skin, `burned` where the passage narrates a burn, fatigue where a loss could otherwise resolve to nothing. |
| **Costs that are actually spent** | `marsh_bridge` 1 | `costs.items.climbing_rope` added, so the rope is consumed rather than being a permanent free advantage once acquired. |
| **Beneficial conditions as reward** | `industrial_drones` 1, `industrial_crane` 0 | `steady_hands` added where the success had no field at all. |

`flats_toll` choice 1 keeps its negative item fields and was repaired in prose instead: the passage now reads true whether or not the survivor can pay ("she prices you at one ration and takes what your pack will give up"; "they stop when the pack stops yielding, sooner than they expected"). That is the honest form of the fix, because the fields are the toll's demand and the clamp is the survivor's poverty.

**Assertions moved:** the N03-era check that pinned the exact list of four scenes declaring a `scene_role` was replaced. Pinning a list broke on every package and taught nothing; it now asserts the invariants instead — every declared role is a known role other than the implicit default, a promoted scene genuinely carries a longer introduction than the compact band allows, and the pilot promotions survive.

**Measured after N05:** suite **2,766 assertions, 0 failures**; layout 660; combat UI 0 failures; save-recovery UI 201; data-package audit **9 checks, 9 passed, 0 discrepancies**.

**Carried forward:** `glass_pilgrim`'s `pilgrim_disk` remains written and unread. Its only honest consumer is a `bunker41_door_closes` success variant, which is N06's to deliver; the scene's prose is in the belief register and does not promise a payoff the game owes, so the flag stays with a named owner rather than being retired.


### N05b — the Kilnback retune, after the encounter benchmark measured it

The benchmark in [RUN_VERIFICATION.md](RUN_VERIFICATION.md) priced the appended Kilnback fight against the route that avoids it and found it strictly dominated. Over 10,000 seeded behaviour-aware encounters the early builds that actually reach region 3 won **0.238** and died **0.762**, spending **301.8 HP** against 300-400 HP pools, while `industrial_tank` choice 1 *Listen for a pattern* is Wits **favorable** (55-90% healthy, the best odds in its batch), has `shaken` as its worst case, and paid the **identical** reward: `clean_water 2` plus `add_flags [kilnback_rhythm_known]`. Plan §3 requires a hard checked success to carry a clear premium over the safer alternative; this one carried none, so choice 2 was a mistake button rather than a choice.

The cause was a specification error rather than a data-entry error. [CREATURE_STORY_BIBLE.md](CREATURE_STORY_BIBLE.md) had asked for "HP the largest of the four, below the Warden", which anchors the creature to the other creatures in that file and to the Warden Machine's 550 HP at the far end of the game, and to nothing in its own region. The result out-ranked `glass_cult` (region 4) and `tunnel_hunters` (region 5) and was the second-hardest adversary in the package, sitting in region 3. That file now carries the rule the sketch was missing — a profile is anchored to its own region's roster, written down in the sketch — so the same mistake cannot be re-derived from the specification.

| File | Change | Owner |
|---|---|---|
| `data/adversaries.json` | `kilnback`: threat 17 → **16**, `max_health` 360 → **300**, `damage_min` 75 → **62**, `damage_max` 105 → **88**, `xp_reward` 65 → **50**. `sequence`, all four `tells`, `critical_condition: burned`, `flee_difficulty: favorable`, `organic`, `portrait_id` and `field_note` are unchanged, and no other adversary is touched | creature bible, retuned entry |
| `data/events.json` | `industrial_tank` choice 2 `victory.items` `{clean_water: 2}` → **`{clean_water: 2, scrap_parts: 2}`**. Labels, indices, `approach`, `combat.adversary_id`, `can_flee`, `add_flags` and both sibling choices are unchanged | creature bible |
| `data/narrative_overrides_v11.json` | `industrial_tank` choice 2 victory passage rewritten so the plates are visibly taken: "Two of them are cut sheet with the fittings still on, and you take them." 108 words, inside the `substantial` band's 60-110. The engineer's exit loses "wedged above the sump" and the oilcloth bundle to pay for the salvage sentence; nothing else in the passage moves | creature bible |
| `tests/fixtures/combat_v2_content_contract.json` | `reed_widow` and `kilnback` appended to `adversaries`, in package order after `mutant_crows`, in the fixture's existing shape (`id`, `combat`, `sequence`, `organic`, `xp_reward`). Both were previously unprotected, so any later HP, damage or XP drift on the two newest adversaries would have passed silently | this section |

**Why 300 / 62-88 / 50 and not something else.** The profile is now anchored to the Hollow Industrial Zone, which is region 3 and already fields `vault_scavs` at 280 HP, 55-80 damage, 46 XP. The Kilnback is that region's apex: above the Scavengers on every axis, below `glass_cult` (320 HP, 60-90, 62 XP) which belongs to region 4, and level in HP with but softer in damage than `tunnel_hunters` (300 HP, 65-95, 52 XP) which belongs to region 5. `threat` is display-only — it selects the `SEVERE` / `APEX` label and the strongest-enemy line in the Chronicle, nothing in the combat maths — and 16 and 17 both read `SEVERE`, so the choice row's wording does not move; the visible change is `+50 XP` and `Enemy damage 62-88`.

**Why `scrap_parts 2` is the premium.** Choice 1 cannot pay it. The creature bible has the Kilnback "stack insulating plates around its body" inside the cooling jacket, so killing it leaves the plates on the grating while merely listening to it leaves the creature, and the plates, in place. It is a small premium by value (2 x 5 currency, 1.6 kg) and is not what makes the fight worth taking; the 50-XP award against choice 1's 2-XP favorable check bonus is.

### N06 — returning stories: the five Living Road arcs, Bunker Forty-One, the Rust-Sea, and the finale

Design decisions were settled first and recorded in [NARRATIVE_CONSEQUENCE_MAP.md](NARRATIVE_CONSEQUENCE_MAP.md) §5b: the dead finale is re-routed by Bunker history rather than retired, focus stays with the first chapter that resolves, and deferred consumers ship as conditional passages. Four writer agents then drafted one group each (Living Road, Bunker, Rust-Sea, finale) as patch files, four independent verifiers tried to break each patch against the loaded corpus and the real loader in sandbox copies, and deterministic appliers merged the patches one group at a time. Each arc file has one owner, so the groups could not collide; the finale group owns `data/events.json` and the override layer that carries its scenes.

**One engine extension, landed before any content:** an outcome variant may carry `next_event`. `GameEngine.resolve_outcome_next_event` resolves it from the same first-match, pre-outcome, flags-only rule that resolves variant text, so text and routing never disagree; a matched variant without `next_event`, and a run no variant matches, keep the outcome's own follow-up. The loader accepts routing-only variants (no `text`) on outcomes and rejects `next_event` anywhere a variant cannot route; `tools/mechanical_snapshot.gd` hashes routing variants, so a routing change is a mechanical change here. Body variants with `next_event` are not yet rejected by the loader; N08 adds that lint.

**Scope applied: 32 scenes touched across four files, 19 introductions rewritten, 5 scenes promoted to `substantial` and the three gates given `finale`, `substantial`, and `chapter` roles, 58 introduction variants and 27 outcome variants added, 8 choices appended, 8 orphan flags retired, 2 new flags written and read, 3 Chronicle variants added, and the Citadel ending made reachable.**

Mechanical changes, by file:

| File | Event | Change |
|---|---|---|
| `data/events.json` | `final_gate_1` | `scene_role: finale`. Choice 0 *Answer with the recovered gate code* gains `requires.any_flags [gate_code, access_core]` with the visible reason "You recovered no gate code" (**P0**: it asserted a code most runs never recovered). All five outcomes' `next_event` move from `bunker41_warden_remembers` to **`final_gate_2`**, and each carries a text-less routing variant keyed on `b41_contact` whose `next_event` is `bunker41_warden_remembers`. Introduction variants keyed on `b41_voice_heard` (recognition, ordered first) and `[gate_code, access_core]`. |
| `data/events.json` | `final_gate_2` | `scene_role: substantial`. Choice 1's victory writes the new flag **`warden_broken`**. Introduction variant on `b41_voice_heard`. |
| `data/events.json` | `final_gate_3` | `scene_role: chapter` (the finale introduction band with a 100-word outcome floor, so six deaths are not padded). Choice 1 *Complete the emergency override* gains `requires.any_flags [gate_code, access_core, citadel_signal]`, reason "You never read a Citadel controller" (**P0**). Choice 2 *Order the guard to open it now* gains `requires.any_flags [warden_broken]`, reason "The Warden is still tracking you" (**P1**: choices 0 and 2 were field-identical and a victory leaves no post-success field to differentiate them). Choice 0 stays ungated as the always-available answer. Introduction variant on `warden_broken`; outcome variants on 0 success/failure (`warden_broken`), 1 success (`access_core`, then `gate_code`), 2 success (`b41_voice_heard`). Lethal and victory flags unchanged: six and six. |
| `data/events.json` | `rail_survivors` | Choice 2 appended: *Let the traveler speak for you*, `requires.flags [cinder_traveler_rescued]`, hidden when locked, certain, `medkit 1` and `inspired` (record 10's consumer). Introduction variants on `cinder_traveler_rescued` (ordered first, as the evidence for the choice) and `met_train_family`. |
| `data/bunker41_events.json` | `bunker41_last_evacuation` | `eligibility.forbids_flags [b41_relay_fragment]` (**P0**: a survivor who fled with the relay could be dealt the command room later, narrated as still inside). |
| `data/bunker41_events.json` | `bunker41_fragment_calls` 2 | `outcome.add_flags` `[b41_fragment_discarded, b41_ash_invite]` → `[b41_ash_invite]`; the orphan is retired. |
| `data/bunker41_events.json` | `bunker41_ash_procession` 2 | `outcome.items.canned_meat 1`; the theft now yields the tin the passage names. The default introduction and both new variants now show the bearers' packs, per the evidence rule. |
| `data/bunker41_events.json` | `bunker41_warden_remembers` | Choice 1's victory writes the new flag **`b41_warden_destroyed`**. Four introduction variants (`b41_public_signal`; `b41_records_destroyed` or `b41_ledger_burned`; `b41_answered`; `b41_voice_heard`, the only passage that claims recognition). Choice 2's variant list becomes five entries: N04's `key_surrendered` entry unchanged and first, then `b41_rescued_survivors`, `b41_archive_truth`, `b41_ledger_copy`, `b41_abandoned_names`. |
| `data/bunker41_events.json` | `bunker41_door_closes` | Four introduction variants (`b41_warden_destroyed`, `b41_warden_heard`, `b41_choir_hostile`, `b41_choir_split`). Outcome variants: Silence on `b41_fragment_followed` and `b41_mercy`; Mercy on `b41_rescued_survivors` and `b41_warden_destroyed`; Witness on `b41_rescued_survivors`, `[b41_ledger_copy, b41_archive_truth]`, and `pilgrim_disk`. Witness carries three where the brief allowed two, because the pilgrim variant was itself mandated; it is ordered last deliberately, so the people let out of the sealed rooms outrank the disk when both are true. |
| `data/bunker41_events.json` | `bunker41_green_platform`, `bunker41_door_breathes` | Introduction variant on `[b41_key_surrendered, rustsea_key_with_mara]`; the lethal Door body rewritten so the scale, the failed protection, and the way back are all on the page. |
| `data/rustsea_events.json` | `rustsea_quay_names` | `eligibility.requires_flags [rustsea_green_line]` → `requires_any_flags [rustsea_green_line, rustsea_map_self_marked]`, so the Quay also admits a survivor who marked Mara's map themselves. |
| `data/rustsea_events.json` | `rustsea_salt_crown_wake` 1 | A certain choice that granted nothing (canon §10) becomes **Agility, risky**, `approach: salvage`: success pays `canned_meat 1` and `clean_water 1`, failure costs `fatigue 6`, both write `rustsea_mara_route` and chain to `rustsea_cartographers_debt`. The stale certain branch was removed, retiring `rustsea_caravan_taken`. |
| `data/rustsea_events.json` | `rustsea_cartographers_debt` | `scene_role: substantial`. Choice 2 *Give Mara the Mercy Key* chains to **`rustsea_last_coordinate`** (it dead-ended before the Spire). Choice 3 appended: *Return what you took*, `requires.flags [b41_mara_abandoned]`, hidden when locked, certain, writes `rustsea_mara_allied` and `rustsea_spire_route`, chains to the Last Coordinate. Introduction variants on `b41_mara_helped`, `b41_mara_abandoned`, `rustsea_maps_burned`. |
| `data/rustsea_events.json` | `rustsea_voice_map` | Choice 1 `outcome.add_flags [rustsea_voices_silenced]` → `[]`, retiring the orphan and its promise sentence. Choice 2 *Name the dead aloud* chains to `rustsea_last_coordinate` and gains a success variant on `rustsea_names_copied`. Introduction variant on `rustsea_children_clue`. |
| `data/rustsea_events.json` | `rustsea_green_line`, `rustsea_last_coordinate` | Introduction variants: the Green Line on `b41_mara_helped` and `b41_mara_abandoned`; the Last Coordinate on `rustsea_key_with_mara`, `rustsea_mara_allied`, `rustsea_mara_betrayed`, `rustsea_named_dead`, `rustsea_voice_trusted`. |
| `data/road_ledger.json` | `ledger_rustsea_spire` | Three variants keyed on `rustsea_mapped_entry`, `rustsea_late_entry`, `rustsea_route_shared`, one per Last Coordinate route. The file was rewritten by the applier in the package's indented style; every existing entry is unchanged. |
| `data/living_road_events.json` | 25 outcomes | The five `*_thread_complete` flags (`lr_family_thread_complete`, `lr_column_thread_complete`, `lr_road_debt_complete`, `lr_water_thread_complete`, `lr_caravan_thread_complete`) removed from every `add_flags`. The scheduler derives focus from `event_history` and nothing in data, scripts, tools, or tests read them. |
| `data/living_road_events.json` | rewards | `lr_bellkeepers_son` 0 success `bitter_tonic 1`; `lr_pharmacy_witness` 0 success `painkillers 1`; `lr_cup_passed_east` 0 success `clean_water 2 → 3`; `lr_thirst_court` 0 success `purifier_ampoule 1`; `lr_names_on_smoke` 1 success `ration_bar 2`. Each was a checked success that paid nothing or less than its safer sibling, per batch F. |
| `data/living_road_events.json` | six earned routes appended | `lr_voice_in_reeds` 3 *Cross the cleared cut* (`widow_pool_cleared`; certain; `climbing_rope 1`, `lr_family_reunited`). `lr_quiet_column` 3 *Hand over the charge pack* (`lr_siren_silenced` and `scrap_parts 1`, spent; certain; `lr_column_sheltered`). `lr_pharmacy_witness` 3 *Return the leader's pistol* (`lr_bandit_leader_disarmed` and `pipe_pistol 1`, spent; `forbids_flags [lr_bandit_leader_killed]` because the bandit source is repeatable; certain; `lr_lio_believes`, `lr_ledger_clue`). `lr_cup_passed_east` 3 *Fit the stripped housing back* (`lr_filter_stripped` and `scrap_parts 2`, spent; Wits favorable; success `clean_water 1`, `lr_water_shared`; failure the same burn as choice 1's, `lr_water_line_damaged`). `lr_embers_in_rain` 3 *Ask about the missing can* (`lr_nightfire_robbed`; certain; `canned_meat 1`, `lr_caravan_debt_owed`). `lr_warm_windows` 3 *Tune the heater to the Kilnback's cycle* (`kilnback_rhythm_known`; certain; `stun_baton 1`, `lr_caravan_two_fires`). All six are hidden when locked, each writes its chapter's callback-window flag, and each pays what an earlier act left in the survivor's hands rather than a new premium. |
| `data/living_road_events.json` | roles and variants | `lr_quiet_column`, `lr_pharmacy_witness`, `lr_cup_passed_east`, `lr_embers_in_rain` promoted to `substantial`. Thirty introduction variants across fourteen scenes, four outcome variants (`lr_pharmacy_witness` 0 success on killed and disarmed; `lr_warm_windows` 1 success on `lr_caravan_mechanic_surrendered`; `lr_embers_in_rain` 2 on `lr_nightfire_shared`, added after the verifier caught the default contradicting the shared-fire introduction). |

**What the verifiers caught, and what was done.** Bunker: two blocking defects (a Choir-hostile introduction that asserted a callsign history only one of the flag's two producers creates; a Silence variant that asserted an empty pack the flag does not guarantee) and seven quality items, all fixed in place. Living Road: passed, with a contradiction between the shared-fire introduction and the decline outcome (new variant), a poisoned-filter introduction that refused water every outcome then paid (softened to contaminated-tasting but usable), a default success that claimed a theft (reworded), an X1 hedge on the pledge can, the painkillers described as foil instead of the cracked orange bottle `items.json` names, and the missing forbid on the pistol return, all fixed. The verifiers' remaining notes are design observations recorded in the queue, not defects.

**Process breach, recorded.** The Rust-Sea drafter wrote `data/rustsea_events.json` and `data/road_ledger.json` directly, 191 ms after writing its patch, against an explicit no-repository-edit rule. The files on disk were verified byte-for-byte against what the applier produces from the previous state plus the patch, so the content is exactly what review covered and nothing else; the only follow-ups were the stale `outcome` branch on `rustsea_salt_crown_wake` 1 (a check cannot use it, the passage count could) and an empty `requires_flags` list left on `rustsea_quay_names`, both removed by hand. The applier now refuses to re-apply an `append` to a choice that already exists, which is how the breach was noticed.

**Assertions moved:** checked choices 147 → **148** (the Salt Crown salvage is now a roll) and launch outcome passages 394 → **397** (the Rust-Sea return, the two Salt Crown branches, the rail_survivors route, less the stale branch). A new suite section, `_test_returning_stories`, walks every group: the Bunker forbid, the retired orphan, the Warden trace and the gate that reads it, the pilgrim's disk and its precedence, the Key-surrendered testimony, recognition keyed on hearing rather than entering; the Salt Crown roll, the Spire routes and their Chronicle coverage, the pistol return's hidden lock and forbid; every earned route hidden then opened then paid, the retired thread flags, the pharmacy and battery consequences; and the finale routed both ways, the visible code lock, the always-available answer, the two last-gate gates, a full walk to the Citadel victory, and the Chronicle's Citadel chapter reachable.

**Measured after N06:** suite **2,873 assertions, 0 failures**; layout 660; combat UI 0 failures; save-recovery UI 201; data-package audit **9 checks, 9 passed, 0 discrepancies**; `mechanical_snapshot.gd -- --diff` lists every change above and nothing else against the never-regenerated N00 baseline.

### N06c — ownership, a guaranteed disk payoff, and final withdrawal

This is a narrow extension of the N06 mechanical record. It introduces no save field, changes no old choice index, and does not change the nine existing lethal outcomes.

| File | Change | Contract and regression coverage |
|---|---|---|
| `data/bunker41_events.json` | `bunker41_warden_remembers` choice 2 *Invoke the Bunker record* now requires independent testimony or records; appended choice 3 *Present the Mercy Key* requires the Key and forbids both transfer flags. | A transferred Key alone cannot masquerade as testimony; transferred Key plus `b41_witness` still invokes the record; a held Key has a dedicated presentation route. The Warden fight remains choice 1. |
| `data/events.json` | `final_gate_3` gains choice 3 *Step back from the seam*, a certain nonlethal victory. Its introduction now names the closing seam, live controller, recovering Warden, and open outer court. | Every lethal commitment is visibly telegraphed and the player can withdraw before choosing one. The former three final choices retain labels, indices, checks, and outcomes. |
| `data/road_ledger.json` | Added `ledger_pilgrim_disk`, triggered by `final_gate_1` with `pilgrim_disk`. | The outer reader records the disk's scratched name as intake rather than admission. It is a factual recap before Bunker/standard ending variants, so first-match priority cannot erase it and it grants neither Bunker contact nor Witness eligibility. |
| `tools/data_package_audit.gd`, `tests/test_runner.gd` | Chronicle totals 10 → 11 launch and 25 → 26 expanded; assertions cover Key states, disk priority, Kilnback and Cinder rescue consumers, and withdrawal. | The audit remains 9/9. The test suite's unrelated persistence/UI failures are tracked separately in the refinement queue. |

### N06d — Shutter Skitters and Cable Eater

`outskirts_apartment` and `rail_signal` now each append a fleeable combat choice at index 2. Choices 0 and 1 retain their labels, checks, and outcomes. The roster grows from 15 to **17** stable adversary IDs: `shutter_skitters` / `enemy_skitters` and `cable_eater` / `enemy_cable_eater`; IDs used by combat remain separate from portrait placeholders.

Skitters are anchored below the Outskirts' Feral Dogs at 115 HP, 28–44 damage, and 16 XP. Their victory pays the same medkit and canned meat cache as searching, with no durable flag because clearing the stairwell is its complete local consequence. Cable Eater is anchored below Underrail Tunnel Hunters at 250 HP, 54–80 damage, and 44 XP. Its victory pays `scrap_parts: 3` and writes `citadel_signal`; `final_gate_3` choice 1 is the guaranteed controller consumer even when `rail_door` was drawn first. The three Underrail combat candidates are preserved, while the scheduler's existing per-run cap continues to allow at most two selected combat opportunities.

### A01 — Phase A build loot: six conditions, fifteen items, four mutants

Data-only expansion, no engine or save change. Every new item has at least one authored acquisition route (quest check, kill victory, or supply cache); every new harmful condition has an item cure. No original choice keeps its index changed except by appending; the four new combat choices all sit at index 2 with `can_flee: true`.

| File | Change | Balance anchor |
|---|---|---|
| `data/conditions.json` | 13 → **19**: `gutrot` (STR-2/GRIT-1), `spore_cough` (AGI-1/WITS-1), `mind_static` (WITS-2/PRE-1), all permanent; `adrenaline` (STR+2/2 checks), `bloodlust` (STR+1/AGI+1/2), `iron_will` (GRIT+2/2). | Debuffs mirror existing -1/-2 severity; boons mirror `steady_hands` duration. Cures: `purifier_poultice` (gutrot, spores, infection), `choir_incense` (static, shaken → iron_will), `mutant_serum` (exhausted → adrenaline). |
| `data/items.json` | 50 → **65**. Weapons: `rusted_machete` STR 26-40, `bone_cleaver` STR 2H 48-72, `kiln_sword` STR 58-88 relic, `nail_smg` AGI 38-58 pistol, `rail_spike_rifle` WITS 2H 60-95 rifle, `officer_revolver` PRE 38-60 revolver. Armor: `mutant_hide_vest` DR3, `kiln_plates` DR5/agi-1, `stalker_cloak` DR2/agi+1/survival+1. Accessories: `wolf_fang_charm` STR+1/combat+1, `gunslinger_holster` AGI+1, `sniper_scope` WITS+1/technical+1. Consumables: serum, poultice, incense. | Each weapon sits 4-9% above its stat-line predecessor except the cult-gated relic (+57%, region 4 desperate-flee fight). New armors match existing DR tiers (3/5/2) with sidegrade modifiers. All signatures reuse the six mastered families. |
| `data/adversaries.json` | 17 → **21**: `pox_dogs` (130 HP, 34-50, flee favorable, crit `spore_cough`, 22 XP), `bile_spewer` (220 HP, 48-70, risky, `gutrot`, 38 XP), `cinder_mauler` (340 HP, 70-100, hard, `burned`, 58 XP), `salt_colossus` (450 HP, 85-125, desperate, `gutrot`, 90 XP). | Anchored inside their regions' rosters and below the Warden (550 HP, 100-150, 100 XP). Colossus is the mirage creature made fightable at the carcass; the mirage itself stays a sighting. |
| `data/events.json` | 14 existing victory/success outcomes gain one build item each (kill loot, hard-check rewards, supply cache); 4 appended fleeable fights: `outskirts_sinkhole` → pox_dogs, `marsh_bridge` → bile_spewer, `glass_ruins` → cinder_mauler, `glass_carcass` → salt_colossus. | The pox fight lives on the sinkhole rather than the bus so the opening draw stays combat-free and the supply guarantee keeps its non-combat fallback. Combat choices 15 → 19, outcome passages 402 → 406, checked choices unchanged at 148. |
| `data/narrative_overrides_v1.json`, `data/narrative_overrides_v11.json` | Prose-only: each changed outcome names its new loot inside its existing word band (fire 65, toll 109, bandits crit 107, lights 107, body 109; all compact outcomes ≤ 65). No sentence of six or more words repeats another polished passage; no prohibited filler. | Mechanical snapshot equality holds for everything except the recorded A01 additions. |
| `scripts/ui/item_icon.gd` | 15 unique placeholder runes for the new icon IDs; the 50 launch atlas cells are untouched and Phase A items use the documented rune fallback until art lands. | No visual contract change for launch items. |
| `tests/test_runner.gd`, `tests/fixtures/combat_v2_content_contract.json`, `tools/combat_balance.gd`, `tools/data_package_audit.gd` | Counts 50/13/17/15/402 → 65/19/21/19/406; XP table and creature profiles extended; benchmark roster covers all 21; audit expects 65 with routes. | Suite: 3,164 assertions. The only failures are three pre-existing UI-string mismatches from uncommitted `main.gd`/`stats_capsule.gd` changes (checkpoint label spacing, tips settings lookup, stat-details copy); all three fail identically without this package. Audit 9/9. |

### B01 — Phase B text diet: the micro scene role

Prose-only except for the role markers themselves. Twenty-four basic loot, crossing, and weather scenes declare the new `micro` role (35–55 words setup, 15–30 words outcome) in `data/events.json`; their live passages were rewritten inside the matching override files. No choice was added, removed, reordered, or re-gated; no reward, cost, check, flag, or tag moved. Fights and hard checks (raiders, scavs, office, cult, carcass, ruins, hunters, nest) stay `compact` or longer, and the bus stays the compact opening control.

| File | Change | Contract and regression coverage |
|---|---|---|
| `scripts/domain/content_repository.gd` | `SCENE_ROLE_BANDS` gains `micro`: body 35–55, outcome 15–30. The default band is unchanged, so nothing legacy moves. | The role test pins all five budgets and asserts micro scenes carry introductions shorter than the compact band allows. |
| `data/events.json` | 24 events gain `"scene_role": "micro"`: outskirts_dogs/overpass/cache/sinkhole, flats_tanker/dustwall/bones/solar, marsh_leeches/clinic/bridge/storm, industrial_drones/conveyor/fire/crane, glass_storm/bunker/meteor/spring, rail_flood/switch/collapse, global_drop. | `scene_role` is hashed, so the snapshot regenerates with exactly these 24 role differences and no others. The pox fight sits on the sinkhole (never the bus) so the opening draw stays combat-free. |
| `data/narrative_overrides_v1.json`, `data/narrative_overrides_v11.json` | 24 bodies and their outcomes rewritten to micro bands. Tested evidence is preserved: cache keeps four-language instructions, lock, and buckler-on-hook; tanker keeps the `smoke charge` line; bridge keeps the rope method and the pale shape between pylons; sinkhole keeps lip, shelf, ladder, and coughing below. | Word-band, prohibited-filler, and duplicate-sentence checks pass corpus-wide; the `smoke charge` pin and the bus control pins are untouched. |
| `data/events.json` | Sinkhole and bridge victories tightened to 25 and 24 words (no override cover, so the raw text is live). | Micro outcome band holds for every passage, including the two Phase A victories. |
| `docs/STORY_MAP.md` | New: scene taxonomy, run-structure diagram, chain inventory, and the Phase A acquisition map. Linked from the README guide list. | Documentation only; no content or test dependency. |
| `tests/test_runner.gd` | `known_roles` gains `micro`; longer-role promotion checks apply to substantial/chapter/finale only; new assertion pins 24 micro scenes with sub-compact introductions plus the micro budget itself. | Suite: 3,166 assertions. The only failures remain the three pre-existing UI-string mismatches. Audit 9/9. |

### A02 — Phase A integration follow-up: portrait registry, apex bloodlust, early-threat retune

Completes the wiring A01 left open. No save, schema, or scheduler change; no choice added, removed, reordered, or re-gated.

| File | Change | Contract and regression coverage |
|---|---|---|
| `scripts/ui/portrait_art.gd`, `tests/test_runner.gd` | `ENEMY_IDS` registers `enemy_pox_dogs`, `enemy_bile_spewer`, `enemy_cinder_mauler`, `enemy_salt_colossus` (17 → 21 enemy IDs, 25 expected IDs total). The portrait test pins 25 IDs, all eight creature portrait IDs, and the described missing-image presentation for all eight creatures. | All eight creatures carry a `field_note`, so with no artwork the frame shows the name over the note, never raw `PORTRAIT / ID`. No PNG was added; final art can land later without content or save changes. |
| `data/events.json` | `glass_ruins` and `glass_carcass` victories gain `add_conditions [bloodlust]`; each victory text gains one distinct sentence (carcass: "The taste of the hard kill sharpens every strike."; ruins: "The kill sings in your blood and steadies your hands for what comes next."). 57 and 60 words, inside the compact 30–65 outcome band, with no repeated six-word sentence. Neither scene has override cover for choice 2, so the raw text is live. | `bloodlust` (STR+1/AGI+1, 2 checks) previously had no live source. Both apex kills now grant it. The fight-reward assertions check item subsets, so they hold; a new assertion kills both apex mutants and reads `bloodlust` in `survivor.conditions`. |
| `data/adversaries.json` | Early-threat retune, recorded here because A01 omitted it: `road_bandits` 180→200 HP, 35–55→44–66 dmg; `feral_dogs` 120→150, 22–36→38–58; `ash_stalkers` 220→240, 45–70→52–80; `toll_gang` 220→240, 40–60→48–72; `marsh_leeches` 90→120, 12–24→32–48; `drone_swarm` 260→280, 50–80→56–88; `mutant_crows` 70→110, 7–10→36–54, plus one `strike` beat in its sequence. | Threat, XP, flee, crit, sequence honesty (all tells present), and loot are unchanged. The buffs make room for Phase A player power (relic sword, spike rifle, DR5 plates) and sit the Crows near the 115-HP Skitters. Full encounter re-measurement against the new roster is still pending; see `docs/RUN_VERIFICATION.md`. |
| Staged, not loaded | `data/betrayal_events.json` (12 Vex/Slate/Anselm events, untracked draft) is **not** loaded by `ContentRepository` and has no ledger, region-pool, audit, or test coverage. Since D01, `mind_static` has a live source (`industrial_drones` choice 3 failure); its cure (`choir_incense`) is live via the Colossus victory and also covers `shaken`. The draft itself is now scene-band compliant (3 former `chapter` roles corrected to `substantial`, short `substantial` outcomes lengthened, `anselm_ash` body raised to the `compact` floor). | Loading the betrayal arc (12 globals, new flags, Chronicle chapters, count contracts) is owned future work, not part of this follow-up. |

### C01 — Builds and pace: affinity, salvage luck, faster points, harder mid-game

Playtest asked for slower-feeling advancement without longer runs: more stat points and more weapons, enemies that stay hard, and luck in what makes a good build. No save, schema, scheduler, or choice-structure change; no event added, removed, reordered, or re-gated.

| File | Change | Contract and regression coverage |
|---|---|---|
| `data/items.json`, `scripts/domain/combat_resolver.gd`, `scripts/domain/narrative_combat.gd`, `scripts/domain/game_engine.gd` | Soft weapon affinity: optional top-level `affinity_min` (2–6, enforced by `validate_all`) names the base attack-stat value a weapon needs for full power. Below it the weapon stays usable but unwieldy: −15 accuracy (rules-2 preview, clamped 5–95) and ×0.75 damage (single rounding step, both rules paths). Build identity is base stats, like mastery. Starting-kit weapons carry no requirement. Set on 8 existing weapons (rebar 3, hunting rifle 3, scrap shotgun 3, bone cleaver 4, kiln sword 5, nail SMG 3, spike rifle 4, officer revolver 3) and the 3 new ones below. | Fixture stats are all 5 and every minimum is ≤ 5, so all pinned signature/benchmark math holds. New assertions kill nothing: they preview Bone Cleaver at STR 2 (warns, −15, reduced damage) and STR 4 (clear), and pin starter weapons requirement-free. |
| `data/items.json`, `data/events.json`, both override files | 65 → **68** weapons for the thin grit line: `chain_wrench` (grit 1H disruption 27–42, affinity 2) from `outskirts_bandits` victory; `slag_maul` (grit 2H counter 52–80, affinity 4) from `industrial_scavs` victory; `wire_rifle` (wits 2H precision 57–92 on rifle rounds, affinity 4) from `rail_signal` victory. Victories keep indices/labels/flags; live prose names each weapon inside its band (bandits 110/110 substantial, scavs 53/65 compact, signal 101/110 substantial). | Item/icon/placeholder counts move 65 → 68 in suite and audit; atlas stays 50 with the three new IDs on documented rune fallback. Victory-reward assertions read item subsets, so they hold. |
| `scripts/domain/game_engine.gd` | Battlefield salvage: each entry of the defeated adversary's `loot` table drops on an independent 40% run-RNG roll inside the victory commit, applied through the clamped receipt path. Table-less kills (Widow, Kilnback) pay exactly their authored reward. Flee still pays nothing. | Same-seed replay asserts identical salvage; a table-less kill asserts exact authored amounts. The eight-fight reward loop reads at-least now that salvage can top up a named reward. |
| `scripts/domain/experience_rules.gd` | Thresholds 50/110/180/260/350/450/570 → **40/88/144/208/280/360/456** (≈×0.8), so builds come online about two points earlier per run. Check bonuses, journey/checkpoint XP, and the 8-level cap are unchanged. | Threshold-derived assertions hold; the three hardcoded XP assertions move to 39/40 with level-7-at-400 intact. |
| `data/adversaries.json`, `tests/fixtures/combat_v2_content_contract.json` | Mid/late threats rise ~8–10% to stay hard against faster builds: Bog Raiders 250→270 / 50–75→54–80; Vault Scavs 280→300 / 55–80→58–85; Glass Cult 320→340 / 60–90→64–96; Tunnel Hunters 300→320 / 65–95→68–100; Citadel Guard 400→430 / 80–120→85–128; Warden 550→600 / 100–150→105–158. Threat, XP, flee, crit, sequences, and loot untouched. | Data and locked fixture move together, so the contract holds. Encounter re-measurement on the new roster is pending; see `docs/RUN_VERIFICATION.md`. |
| UI | Stat-details sheet keeps its N07 separation (abilities only; the layout suite forbids condition duplication) and now names the way out with an injuries-live-under-STATUS hint; the older runner assertion that demanded conditions inside the sheet now enforces the separation instead, with exact-penalty coverage moved to the Status sheet where it belongs. Each stat row carries a hover tooltip (base value, gear/condition adjustments, answering weapons); the HUD capsule tooltip lists live values; allocation confirm reports hearts and newly unlocked mastery; checkpoint departures read without icon-padding spaces and expose their action accessibly. | The three pre-existing UI-string failures (stat-details copy, checkpoint Continue Journey, tips settings lookup) are repaired; both suites expect zero failures. |

### D01 — Builds open doors: unfought fights, stat gates, weapon routes, combat boons

Continues C01 without new items, adversaries, events, flags, XP, saves, or scheduler changes. Every appended choice takes the next free index; every original choice keeps its index, label, check, and rewards.

| File | Change | Contract and regression coverage |
|---|---|---|
| `data/events.json`, `data/narrative_overrides_v11.json` | `marsh_leeches` gains choice 2 *Drain the breeding pool*, combat vs `marsh_leeches`, `can_flee: true`; victory pays `cloth_bandage 1` + `purifier_poultice 1` (the thematic cure kit for a bleeding/infection scene). `industrial_drones` gains choice 2 *Bring down the swarm*, combat vs `drone_swarm`, `can_flee: true`; victory pays `scrap_parts 3`. Both victories sit inside the micro 15–30 word band in baseline and polished text. | Combat choices 19 → **21**; outcome passages 406 → **414** (with the gates below). Forced-combat pools move to `[marsh_bridge, marsh_leeches, marsh_lights, marsh_raiders]` and `[industrial_drones, industrial_scavs, industrial_tank]`; the ten-fight reward loop opens, flees, and pays both. `citadel_guard` stays a parley gate: the finale is untouched deliberately. |
| `data/events.json`, `data/narrative_overrides_v11.json` | `industrial_drones` gains choice 3 *Ground the swarm with a wired probe*: `requires.items {shock_probe: 1}`, Wits favorable; success pays `scrap_parts 2` + `focused`, failure costs Fatigue 6 + `mind_static` (feedback shriek, symptom shown). The Wits starting weapon now matters outside combat, and `mind_static` gains its first live source one region before the colossus `choir_incense` cure. | Checked choices 148 → **149**. Locked without the probe, unlocked with it; success focuses, failure statics — all asserted. |
| `data/events.json`, both override files | Four stat-gated certain routes, one per build: `rail_collapse` 2 *Lift the fallen beam* (STR 4; Fatigue −4, removes `sprain`/`concussed`); `marsh_clinic` 2 *Read the dosage chart* (WITS 4; Fatigue −4, removes `infection`/`fever`); `flats_tanker` 2 *Walk the fume line* (GRIT 4; Fatigue +6, gains `iron_will`); `flats_toll` 3 *Trade them the eastern road* (PRE 4; gains `inspired`, no ration spent). Generated lock labels (`Requires Strength 4`, …) carry the gates; every event keeps its ungated originals. | Each gate asserts locked below 4, open at 4, and its exact outcome (cures, buff, fatigue). Toll takes the event to four choices, the validated maximum. |
| `data/events.json` (raw-live victories, no override cover) | `outskirts_sinkhole` victory rewritten inside micro band and gains `adrenaline`; `marsh_bridge` victory rewritten inside micro band and gains `iron_will`. Both name their existing loot and show the symptom (singing blood, steady hands). | The reward loop asserts both boons alongside the existing apex `bloodlust` pair. No other victory, flag, loot table, or XP value moves. |

### D02 — Agility completes the build set: the pack wire

D01 left agility without a stat-gated door while strength, wits, grit, and presence each opened one. This package closes that gap on the most redundant chest in the game, following the D01 contract exactly: no new items, adversaries, events, flags, XP, saves, or scheduler changes. The appended choice takes the next free index; both original choices keep their indices, labels, checks, and rewards.

| File | Change | Contract and regression coverage |
|---|---|---|
| `data/events.json`, `data/narrative_overrides_v1.json` | `global_pack` gains choice 2 *Work the wire with quick hands*: `requires.stats {agility: 4}`, approach `evade`, certain; outcome pays `pistol_rounds 2` + `steady_hands` (AGI+2, two checks). The Wits risky route still pays the unique pack + food + ammo; the certain refusal still leaves cleanly; the agility route pays ammo + buff with no pack or food, so each build has a distinct best answer instead of three ways to open the same box. | Outcome passages 414 → **415**; checked choices stay **149**, combat stays **21**. Gate asserts locked below 4, open at 4, and the exact ammo + buff payment. The event moves from two to three choices, inside the validated two-to-four band, and keeps its ungated refusal so depleted survivors retain a legal action. Baseline (35 words) and polished (40 words) outcomes both sit inside the compact 30–65 band with no prohibited filler and no repeated six-word sentence. |
| `data/narrative_overrides_v1.json`, `data/narrative_overrides_v11.json` | Polished victories for the four Phase A fights that shipped raw-live in A01: `outskirts_sinkhole` 2 (28 words, micro), `marsh_bridge` 2 (29 words, micro), `glass_carcass` 2 (33 words, compact), `glass_ruins` 2 (47 words, compact). Each names its authored loot and shows its boon symptom (high eager pulse, steady hands, hungry stride, hot certain hands). No mechanics, rewards, costs, flags, or choice order change; the snapshot is untouched because overrides are prose-only. | Word-band, prohibited-filler, and duplicate-sentence checks pass corpus-wide; the ten-fight reward loop still opens, flees, and pays all four alongside their boons. |

### F01 — Betrayal arc loading: Vex, Slate, and Anselm join the expanded release

Loads the staged `data/betrayal_events.json` draft behind `living_road_enabled`, so the compatibility baseline stays 97 events / 11 chapters and the default release grows 112 → **124** events. No save, schema, scheduler, item, condition, adversary, XP, or choice-structure change; no original event touched.

| File | Change | Contract and regression coverage |
|---|---|---|
| `scripts/domain/content_repository.gd` | `reload()` merges `data/betrayal_events.json` when `living_road_enabled`. The 12 betrayal events are ordinary globals (no `living_road_callback`, no source patches), so focused scheduling, the callback cap, and the compatibility build are untouched. | Compatibility `new(false)` still loads 97 events; default loads 124. |
| `data/road_ledger.json` | Three Chronicle chapters: `ledger_vex_reckoning` (settled / allied / closed), `ledger_slate_office` (betrayed / freed / closed), `ledger_anselm_ash` (allied / reckoned / closed), triggered by the three final events with first-match variant priority. | Discoveries 26 → **29** default, 11 compatibility unchanged; variants 48 → **57**. Every variant flag is written by a loaded outcome; audit check 7 passes. |
| `data/betrayal_events.json` | Band compliance before loading: three `chapter` roles corrected to `substantial` (their 130–156-word bodies and 60–98-word outcomes sit inside `substantial`, not `chapter`); twelve short `substantial` outcomes lengthened and `anselm_ash` body raised to the `compact` floor. No choice, cost, reward, flag, or gate changed. | Word-band, prohibited-filler, and duplicate-sentence checks pass corpus-wide; every event keeps an ungated choice. |
| `tests/test_runner.gd`, `tests/layout_ui_smoke.gd`, `tools/data_package_audit.gd` | Count pins move 112 → 124 and 26 → 29 (variants 48 → 57); new `_test_betrayal_arc` walks all 12 loads, the Vex trust chain gating, variant bodies, a played meal, two started combats, and the settled/allied ledger receipts with a no-source control. | Suite: 3,276 assertions, 0 failures. Audit 9/9. Layout Chronicle pin reads `1 / 29 chapters`. |
