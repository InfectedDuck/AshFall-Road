# Consequence cards — Batch B: Salt Flats and Drowned Marches

Cards for the twenty pool events of region 1 (`salt_flats`) and region 2 (`drowned_marches`), in the order the pools list them. Template and rules: [NARRATIVE_CONSEQUENCE_MAP.md](../NARRATIVE_CONSEQUENCE_MAP.md) §1–§3. Canon is quoted by section from [STORY_CANON.md](../STORY_CANON.md); creatures from [CREATURE_STORY_BIBLE.md](../CREATURE_STORY_BIBLE.md); prose judgement from [LIVING_ROAD_NARRATIVE_BIBLE.md](../LIVING_ROAD_NARRATIVE_BIBLE.md). Every percentage is copied from [builds/choice_comparison.md](../../builds/choice_comparison.md); none is estimated.

The prose read here is what loads: `data/events.json` with `narrative_overrides_v1.json` and `narrative_overrides_v11.json` applied. The `source_flag_patches` in `data/living_road_events.json` are treated as present, so `marsh_filter` and `flats_nightfire` write their `lr_*` source flags.

**Field notes that apply to every card** (measured in `scripts/domain/game_engine.gd`, recorded once so no card repeats them):

- A `pressures.health: -N` field is a legacy scale. `_apply_legacy_pressure` applies `roundi(N * 2.5 / 5.0) * 5` HP, so `-12` is −30 HP, and a branch carrying `damage_type: "physical"` is then reduced by armor. Cards quote the JSON field, per §2.
- A positive `pressures.hunger: N` always removes exactly 1 satiety, whatever N is. The number is flavour.
- A negative `items` entry is applied by `_change_item`, which clamps at zero. A survivor who does not carry the item loses nothing and still reads `<Item> -1` in the changes list. Cards flag this wherever prose narrates a confiscation.
- Adversary `loot` arrays are decorative; no code path grants them. A fight's reward is the choice's `victory.items` and nothing else.
- Flee resolves no outcome and writes no flag (§2). Neither combat choice in this batch authors a failure branch: defeat is death.
- Every body in this batch is 63–73 words and every outcome 31–49 words, inside the 60–90 / 30–50 contract. Length is not a finding anywhere below.

---

## Salt Flats pool

### flats_toll — Toll Across Nothing   [data/events.json +overrides v1/v11; region 1 Salt Flats; unique=n; weight=5; tags=—]
Scene: uniformed collectors hold the only raised track above the salt and charge for road they do not maintain.
Evidence on screen: a revolver under the striped umbrella and a school ledger recording each traveler ([0], [1]); the clerk who keeps the book ([1]); wheel ruts continuing east past not one repaired marker, which is the lie the negotiation attacks ([1]); open glare on both flanks ([2]).
Comparison: [0] fight T13 +30xp flee:y in all six states; [1] presence favorable 55 healthy / 45 depleted, identical across the four measured kits (the Presence kit itself is unmeasured, §3); [2] agility risky 45–70 healthy (Agility 70) / 35 depleted. No dominance or redundancy flag.

[0] Break the barricade — intention: take the road by force and end the toll.
    known cost: combat with `toll_gang` (threat 13, xp_reward 30, can_flee true, flee difficulty risky; 220 HP, 40–60 damage, critical `shaken`) | uncertain risk: no failure branch authored — defeat is death; fleeing forfeits the reward and writes nothing
    success (victory): items revolver_rounds 3, scrap_parts 1 | failure: none authored
    local significance: the collectors scatter; the ledger stays open on a page describing the survivor.
    durable: none. The only combat-bearing event in the Salt Flats pool, so `_select_next_event` forces it at the region's fourth ordinary slot when no combat has been seen.

[1] Negotiate a smaller toll — intention: pay less by making them account for the toll in front of each other.
    known cost: items ration_bar −1 on success | uncertain risk: items canned_meat −1, clean_water −1
    success: items ration_bar −1; add_flags crater_warning | failure: items canned_meat −1, clean_water −1
    local significance: the clerk cannot say which stretch her toll repaired, and warns that the crater route killed two collectors yesterday.
    durable: orphan: `crater_warning` — no consumer in `events.json`, `bunker41_events.json`, `rustsea_events.json`, `living_road_events.json`, or `road_ledger.json`. Proposed consumer in the `flats_crater` card below.

[2] Circle them through the glare — intention: pay nothing and be recorded by nobody.
    known cost: pressures fatigue 5 on success | uncertain risk: pressures fatigue 14, hunger 5
    success: pressures fatigue 5 | failure: pressures fatigue 14, hunger 5
    local significance: no clerk opens the pack or writes the face into the ledger.
    durable: none.

Disposition: revise — the victory pays ammunition almost no survivor can fire, and the negotiated toll is narrated even when the pack cannot pay it.
Findings:
P0: [1] both branches narrate handing over food and water that `_change_item` silently clamps to zero, so an empty-handed survivor is told they paid a toll they did not pay → conditional outcome variant for the no-item case (she raises the barrier on a promise, or takes what the survivor does carry); fields unchanged otherwise.
P1: `revolver_rounds` appears exactly once in all loaded content and only `holdout_revolver` fires it, the Presence kit's weapon §3 does not measure, so a threat-13 victory pays most survivors one scrap → now: revolver_rounds 3, scrap_parts 1 | proposed: revolver_rounds 3, scrap_parts 1, canned_meat 1, the collected toll the scene already says they take.
P1: `crater_warning` orphan → consumer named in `flats_crater` (introduction variant); if that is refused, retire the flag.

### flats_mirage — Water on the Horizon   [data/events.json +overrides v1/v11; region 1 Salt Flats; unique=n; weight=4; tags=—]
Creature host: **Salt Colossus** (CREATURE_STORY_BIBLE). Environmental giant: no adversary, no portrait, no health bar, and **no appended combat choice** — "a giant offers navigation, not combat."
Scene: a blue line on the horizon that widens when looked away from and retreats when faced.
Evidence on screen: the line moving against the survivor's own movement; damp cloth strips on broken stakes in air too dry to allow it; a map showing neither water nor shelter that way ([0]); the sun angle and the freshest edge of the survivor's tracks ([1]).
Comparison: [0] grit risky 45–70 healthy (Grit 70) / 35 depleted; [1] wits easy 65–90 healthy (Wits 90) / 55 depleted. No dominance flag.

[0] Trust the apparent landmark — intention: follow the sign of water to water.
    known cost: pressures fatigue 5 on success | uncertain risk: pressures fatigue 15, hunger 6
    success: items clean_water 1; pressures fatigue 5 | failure: pressures fatigue 15, hunger 6
    local significance: an unopened bottle from a rain trap under corrugated metal, or an hour spent walking into the survivor's own crossing footprints.
    durable: none.

[1] Check the sun and your tracks — intention: refuse the horizon and navigate by instrument.
    known cost: none | uncertain risk: pressures fatigue 8
    success: no fields — the reward is not paying [0]'s fatigue or this branch's failure | failure: pressures fatigue 8
    local significance: the mirage slides sideways and is exposed without costing another hour.
    durable: none.

Repeatability: `unique=false`, and `_select_next_event` blocks only the last three events, so a second sighting inside region 1 is ordinary. Per the bible, **each sighting is a different point on the migration and no passage may remember an earlier one** — no "again", no "the same shape", no second bottle from the same trap.
Disposition: revise — prose only, no mechanical change. Choice 0 becomes following the Colossus's bearing toward the water its resting places condense (the existing `clean_water` and fatigue stand); choice 1 becomes reading its wake and keeping off it. The name arrives inside the passage by the survivor's own reckoning, per the bible's naming rule.
Findings:
P1: no durable effect and no flag. The bible allows N02 to name a consumer for the wake knowledge; this card declines, because a flag on a repeatable scene fires identically on the first and second sighting, and the knowledge is better carried the other way (see `flats_bones`) → keep local.
P2: choice 1's success describes the mirage but not the wake it belongs to → rewrite around the bible's third warning, long parallel crust fractures too regular for weather.

### flats_tanker — Sunken Tanker   [data/events.json +overrides v1/v11; region 1 Salt Flats; unique=y; weight=3; tags=—]
Scene: a fuel tanker axle-deep in salt with a sealed cargo locker and vapour trapped behind the crust.
Evidence on screen: faded red warning diamonds; petroleum smell gathering at the hinges whenever wind crosses them; something heavy shifting inside as the metal expands.
Comparison: [0] strength risky 50–65 healthy (Strength 65) / 35 depleted; [1] wits favorable 55–90 healthy (Wits 90) / 45–55 depleted. No dominance flag.

[0] Cut open the cargo locker — intention: take the locker now and accept what is behind the seal.
    known cost: none up front | uncertain risk: pressures health −18, damage_type physical, add_conditions burned
    success: items frame_pack 1, scrap_parts 2 | failure: pressures health −18 (physical), add_conditions burned
    local significance: the locker opens with salt sliding from the door, or warps shut around whatever remains.
    durable: none. `frame_pack` is the +12 capacity backpack the comparison's supplied state equips, so this is a real build reward.

[1] Test for fumes first — intention: make the same locker safe before opening it.
    known cost: none up front | uncertain risk: pressures health −7, fatigue 8
    success: items scrap_shotgun 1, shotgun_shells 2 | failure: pressures health −7, fatigue 8
    local significance: fumes spill across the salt and the compartment gives up a weapon instead of a pack.
    durable: none.

Disposition: keep — force against procedure, different rewards for different builds, and each failure is exactly the risk its route named.
Findings: none.

### flats_dustwall — The Moving Wall   [data/events.json +overrides v1/v11; region 1 Salt Flats; unique=n; weight=5; tags=—]
Scene: a dust front from salt to cloud, with a chained truck frame near and a culvert farther east.
Evidence on screen: wrecks vanishing one by one as the front advances; static lifting the hair along the arms; loose buckles striking the pack; two named shelters at two distances.
Comparison: [0] grit risky 45–70 healthy (Grit 70) / 35 depleted; [1] agility risky 45–70 healthy (Agility 70) / 35 depleted. No dominance flag — each route belongs to a different kit at the same band.

[0] Anchor beneath a wreck — intention: stop moving and survive where you stand.
    known cost: pressures fatigue 6 on success | uncertain risk: pressures health −10, fatigue 14, add_conditions exhausted
    success: pressures fatigue 6 | failure: pressures health −10, fatigue 14, add_conditions exhausted
    local significance: the chain holds across the pack while daylight goes black, or slips after the first impact.
    durable: none.

[1] Run for the culvert — intention: beat the front to better shelter.
    known cost: none | uncertain risk: pressures health −14, damage_type physical, fatigue 16, add_conditions shaken
    success: no fields | failure: pressures health −14 (physical), fatigue 16, add_conditions shaken
    local significance: concrete and old water take the storm's roar, or the wall catches the survivor several strides short of the opening.
    durable: none.

Disposition: keep — identical odds bands, genuinely different trades: the anchor costs fatigue on success and leaves `exhausted` on failure; the sprint costs nothing on success and hits harder with `shaken`.
Findings: none.

### flats_bones — Circle of Bones   [data/events.json +overrides v1/v11; region 1 Salt Flats; unique=y; weight=3; tags=—]
Creature traces: **Salt Colossus** (CREATURE_STORY_BIBLE) — the wired ring marks where its wake left thin crust over a pit, and the darker, smoother salt inside the ring is the wake itself. No combat choice; the giant is never fought.
Scene: human bones wired into a circle around one fresh boot print, with an intact pair of boots beside the skull.
Evidence on screen: joints wired so wind cannot move them; salt inside the ring smoother and darker than the crust around it; the single print showing the last safe step backward; the boots' toes pointing away.
Comparison: [0] wits favorable 55–80 healthy (Wits 80) / 45 depleted; [1] agility favorable 55–80 healthy (Agility 80) / 45 depleted. No dominance flag — each kit owns one route at the same band.

[0] Study the warning — intention: read what the builder meant and leave it standing.
    known cost: none | uncertain risk: pressures radiation 10, health −5
    success: add_flags read_bone_warning (no items, no pressures) | failure: pressures radiation 10, health −5
    local significance: the warning is understood and left undisturbed; the survivor leaves by the ring's open side.
    durable: orphan: `read_bone_warning` — written here, read nowhere in any data file. Proposed consumer below.

[1] Recover the intact boots — intention: take the usable gear without crossing the circle.
    known cost: none | uncertain risk: pressures radiation 8, health −8
    success: items scrap_parts 1, pistol_rounds 3 | failure: pressures radiation 8, health −8
    local significance: the warning loses its boots; the pit keeps everything else.
    durable: none.

Disposition: revise — the flag needs a consumer or retirement, and the darker crust should be named as the wake of the thing that made it.
Findings:
P1: `read_bone_warning` orphan. CREATURE_STORY_BIBLE says N02 either retires it or gives it one. Decision: **give it one** — `flats_mirage` gains an introduction variant with `requires_any_flags: [read_bone_warning]` in which the parallel fractures ahead read as the same darker crust the wired bones ringed. Mechanics unchanged there (grit risky / wits easy stand); the default introduction stands when the flag is absent, and because `flats_mirage` is repeatable it can still be met after the bones. Retiring the flag instead would leave choice 0 with no reward at all, since its success grants no items and no pressure relief.
P2: the introduction shows the wake without naming what makes wakes → one clause tying the darker salt to the shape that crosses the flats, per the bible's warning list.

### flats_convoy — Convoy of Mirrors   [data/events.json +overrides v1/v11; region 1 Salt Flats; unique=y; weight=3; tags=—; choices 2–3 are M05 equipment routes]
Scene: three mirror-plated carts stop beyond speaking range and flash four deliberate bursts at a lone traveler.
Evidence on screen: narrow firing slots and road-sign plate; the square mirror repeating a sequence ([0]); wrecks whose shadows are thinner than a body ([1]); a crew who trade for road nobody else has walked ([3]). Nothing on screen shows the sun awning that choice 2 repairs.
Comparison: [0] presence risky 45 healthy / 35 depleted (Presence kit unmeasured, §3); [1] agility favorable 55–80 healthy (Agility 80) / 45 depleted; [2] wits favorable 55–90 (Wits 90) / 45–55; [3] presence favorable 55 / 45. No dominance or redundancy flag.

[0] Return a peaceful signal — intention: be read as a trader rather than a target.
    known cost: none | uncertain risk: pressures health −6, fatigue 5, add_conditions shaken
    success: items clean_water 2, pistol_rounds 4 | failure: pressures health −6, fatigue 5, add_conditions shaken
    local significance: a hatch opens wide enough for one exchange, or shots land on either side of a misread greeting.
    durable: none.

[1] Hide among the wrecks — intention: not be seen at all.
    known cost: none | uncertain risk: pressures fatigue 12, hunger 4
    success: no fields | failure: pressures fatigue 12, hunger 4
    local significance: axle heat passes close enough to touch the face, or an hour goes under hot metal while the convoy waits without searching.
    durable: none.

[2] APPENDED (M05 allowlist) Repair the awning for a Dust Cloak — intention: buy gear with labour instead of trust.
    known cost: an hour standing under a firing slot | uncertain risk: pressures fatigue 6
    success: items dust_cloak 1 | failure: pressures fatigue 6
    local significance: the lead cart has shade again, or a folded frame across its roof.
    durable: none. Keep as authorized.

[3] APPENDED (M05 allowlist) Trade a useful warning for the Lucky Die — intention: buy gear with information.
    known cost: giving up the advantage of knowing alone | uncertain risk: pressures fatigue 6
    success: items lucky_die 1 | failure: pressures fatigue 6
    local significance: a weighted die passed back through a gloved hand, or a courteous refusal from sealed steel.
    durable: none. Keep as authorized.

Disposition: revise — choice 3's success asserts knowledge the survivor is not guaranteed to have.
Findings:
P0: [3] success narrates describing "the toll barricade east of here", its staffing and its thin hours. `flats_toll` is a separate pool event many runs never draw, and only its own [1] success records having met it (`crater_warning`). STORY_CANON §5's prior-knowledge rule applies → make the toll account a variant keyed on `crater_warning` with a neutral default (the dust wall, the crater's flags, the numbers station), or rewrite the traded warning as road the survivor has walked. Prose only; M05 fields unchanged.
P1: [2] has no on-screen evidence — the awning exists only in the label and the success text → one clause in the body showing the torn awning frame over the lead cart.

### flats_solar — Solar Field   [data/events.json +overrides v1/v11; region 1 Salt Flats; unique=y; weight=3; tags=—]
Scene: a field of tracking solar panels still following the sun, with a live controller cabinet and a blade of shade beneath.
Evidence on screen: motors clicking across the field in sequence; a green charge light on the central cabinet ([0]); reliable shade under panels already adjusting toward the afternoon angle ([1]); one split drive belt.
Comparison: [0] wits risky 45–80 healthy (Wits 80) / 35–45 depleted; [1] grit easy 65–90 healthy (Grit 90) / 55 depleted. No dominance flag.

[0] Salvage a charge controller — intention: take the working part out of a working machine.
    known cost: none | uncertain risk: pressures health −12, add_conditions concussed
    success: items scrap_parts 3, stimulant 1 | failure: pressures health −12, add_conditions concussed
    local significance: one row stops following the sun and casts a fixed, unnatural shadow.
    durable: none.

[1] Shelter beneath the panels — intention: spend the machinery on rest instead of parts.
    known cost: none | uncertain risk: pressures fatigue 5
    success: pressures fatigue −10 | failure: pressures fatigue 5
    local significance: ten quiet minutes under the panel whose belt has split, or full sun before rest has become recovery.
    durable: none.

Disposition: keep — one of only two fatigue-negative successes in the region, priced honestly against a concussion.
Findings: none.

### flats_crater — Fresh Crater   [data/events.json +overrides v1/v11; region 1 Salt Flats; unique=y; weight=3; tags=—]
Scene: a days-old crater cuts the road, its survey flags clean and its crew missing.
Evidence on screen: a glass floor clicking as buried heat escapes; flags too clean to be old; a strip of lead shielding tied like mourning cloth; the radius where teeth begin to taste of metal.
Comparison: [0] wits risky 45–70 healthy (Wits 70) / 35 depleted; [1] certain in every state. No dominance flag.

[0] Search the rim — intention: recover what the survey crew left without touching the glass.
    known cost: none | uncertain risk: pressures radiation 15
    success: items rad_tabs 2, purifier_ampoule 1 | failure: pressures radiation 15
    local significance: a lead-lined case of treatment under the last marker, or a dose taken through the crust from a buried hot pocket.
    durable: none.

[1] Give it a wide distance — intention: refuse the crater entirely.
    known cost: pressures fatigue 8, hunger 3, certain and disclosed | uncertain risk: none
    success (outcome): pressures fatigue 8, hunger 3 | failure: n/a
    local significance: the clicking glass never passes underfoot and the missing survey crew stays unexplained.
    durable: none.

Disposition: revise — this is the scene the toll clerk's warning is about, and it does not know it.
Findings:
P1: consumer for `flats_toll`'s orphan `crater_warning` → introduction variant with `requires_any_flags: [crater_warning]`: these are the flags the clerk said killed two collectors yesterday, and the buried hot pocket of [0]'s failure is what killed them. No mechanical change; the default introduction stands for the many runs that never meet the toll, and because order between the two events is random, nothing may be implied when the flag is absent.

### flats_signal — Numbers in the Static   [data/events.json +overrides v1/v11; region 1 Salt Flats; unique=y; weight=2; tags=—]
Scene: a numbers broadcast repeats six figures, a pause, then four more, restarting on every low ridge above a grid of rusted stakes.
Evidence on screen: no callsign and no emergency phrase; the restart at each ridge; the incomplete stake grid in the salt ([0]); signal strength that can be walked toward ([1]).
Comparison: [0] wits hard 35–70 healthy (Wits 70) / 25–35 depleted; [1] wits favorable 55–80 healthy (Wits 80) / 45 depleted. No dominance flag. Both are the same stat, so the hard route is the same expertise at a worse band buying the better reward — the premium plan §3 asks for.

[0] Decode the sequence — intention: turn the broadcast into a place.
    known cost: none | uncertain risk: pressures fatigue 10, add_conditions shaken
    success: items medkit 1, rifle_rounds 3; add_flags decoded_numbers | failure: pressures fatigue 10, add_conditions shaken
    local significance: a sealed canister under the correct stake, and the transmission stops when it is lifted — evidence shown and not explained, per STORY_CANON §5.
    durable: orphan: `decoded_numbers`.

[1] Use it only as a bearing — intention: take the useful part and leave the meaning alone.
    known cost: none | uncertain risk: pressures fatigue 8
    success: no fields | failure: pressures fatigue 8
    local significance: an east bearing across three ridges corrects a wind-erased road; the numbers continue, useful without being understood.
    durable: none.

Disposition: revise — one orphan flag to settle.
Findings:
P1: `decoded_numbers` has no consumer in any data file. It is **not** the salt-flats SOTERIA signal — that is the global `bunker41_static` (region 1 eligibility), which writes `b41_recording` / `b41_answered` / `b41_unprepared` — so folding this flag into the Bunker thread would invent history the survivor never heard → **retire `decoded_numbers`**. Choice 0 keeps its full premium (medkit 1 + rifle_rounds 3 against choice 1's nothing), so no reward is lost. If N06 prefers to keep the flag, it must arrive with a named consumer in the same change.

### flats_nightfire — Fire After Sunset   [data/events.json +overrides v1/v11 + living_road source_flag_patches; region 1 Salt Flats; unique=n; weight=3; tags=supply_opportunity]
**Source of §5 record 5 (Noma's Nightfire Caravan).** See §5 record 5 for the four `lr_nightfire_*` flags, their consumers (`lr_embers_in_rain` → `lr_names_on_smoke` → `lr_warm_windows`) and the changes proposed there. Recorded here: the immediate effects, and what the record does not state.
Scene: after sunset a woman sits beyond the smoke of a wheel-rim fire with two cups laid out and a second bedroll empty.
Evidence on screen: both hands open on her knees; one blanket, two cups, a covered pot within reach; the empty bedroll; spilled water already hardening on the salt; she gives her name and asks nothing until the survivor decides.
Comparison: [0] presence favorable 55 healthy / 45 depleted (Presence kit unmeasured, §3); [1] agility easy 65–90 healthy (Agility 90) / 55 depleted. No dominance flag.

[0] Share the fire — intention: accept hospitality and sleep in turns beside a stranger.
    known cost: none up front; the risk is sleeping within reach of someone unknown | uncertain risk: items canned_meat −1; pressures fatigue −5
    success: pressures fatigue −12; items ration_bar 2; add_flags lr_nightfire_shared | failure: pressures fatigue −5; items canned_meat −1; add_flags lr_nightfire_robbed
    local significance: a second set of footprints continues east for miles, or a folded blanket, embers left burning, and one missing can.
    durable: see §5 record 5.

[1] Pass unseen — intention: take the road without entering anyone's light.
    known cost: none | uncertain risk: pressures fatigue 5, add_conditions shaken
    success: no fields; add_flags lr_nightfire_passed | failure: pressures fatigue 5, add_conditions shaken; add_flags lr_nightfire_spooked
    local significance: the offered bedroll stays visible until dark, neither accepted nor withdrawn; or both people retreat from one broken salt crust.
    durable: see §5 record 5.

Not stated in record 5, and owed to the repeatable + supply-tag combination: this is the **only** `supply_opportunity` in the Salt Flats pool, so `_select_next_event` forces it at the region's fifth ordinary slot when no supply scene has been seen, and `recent` blocks only the last three events — so one run can meet Noma twice and hold two contradictory source flags. Record 5 fixes that consumers read presence only and never count; it does not fix which flag wins when two are present.
Disposition: revise — precedence between repeat visits, and a theft that may charge nothing.
Findings:
P1: repeat visits can leave two contradictory `lr_nightfire_*` flags with no precedence → N04 fixes one order for the `lr_embers_in_rain` variants (shared > robbed > passed > spooked) and records it in §5 record 5.
P1: [0] failure narrates a stolen can and applies items canned_meat −1, clamped to nothing when the survivor carries none, so the theft that starts Noma's debt may never happen → conditional outcome variant for the no-can case; the flag still writes, because what Noma did is what the thread reads.

---

## Drowned Marches pool

### marsh_leeches — Red Water   [data/events.json +overrides v1/v11; region 2 Drowned Marches; unique=n; weight=5; tags=—; event-level adversary_id `marsh_leeches`]
Scene: the raised road disappears into an iron-red channel where hand-long parasites turn toward the survivor's shadow.
Evidence on screen: pale undersides surfacing wherever the shadow crosses; twenty strides to dry ground; a blade that can be heated ([0]); silt that will not hold a settled boot ([1]).
Comparison: [0] wits favorable 55–80 healthy (Wits 80) / 45 depleted; [1] agility risky 45–70 healthy (Agility 70) / 35 depleted. No dominance flag: choice 0 leads for three kits and choice 1 leads for the Agility kit (70 against 60 at early healthy), which is exactly the invested-expertise inversion §3 protects.

[0] Burn them away — intention: make the water refuse them long enough to wade.
    known cost: none | uncertain risk: pressures health −12, fatigue 8, add_conditions bleeding
    success: no fields | failure: pressures health −12, fatigue 8, add_conditions bleeding
    local significance: the crossing is made without feeding them; the far bank smells of scorched water.
    durable: none.

[1] Sprint through the channel — intention: deny them purchase by never letting a boot settle.
    known cost: pressures fatigue 5 on success | uncertain risk: pressures health −10, fatigue 12, add_conditions infection
    success: pressures fatigue 5 | failure: pressures health −10, fatigue 12, add_conditions infection
    local significance: the channel knots closed behind the survivor, or a submerged curb puts them chest-deep.
    durable: none.

Combat alternative, judged: **no — Leeches stay sighting-only.** STORY_CANON §4 fixes this region's creature presence as "Marsh Leeches (sighted, never fought); the Reed Widow", and CREATURE_STORY_BIBLE's shared rules name exactly four appended combat alternatives, at `outskirts_apartment`, `marsh_lights`, `industrial_tank`, and `rail_signal`. A fifth here would contradict canon; would put a second optional fight in the marsh pool beside `marsh_raiders` and the appended Widow, against the plan's combat-opportunity cap; and would take the region's creature-led encounter away from the Widow, whose single idea ("the ground you trust is carrying you somewhere") is the marsh's. The scene keeps two crossings and no fight.
Disposition: keep — a two-route crossing whose kit inversion is the point.
Findings:
P2: `data/adversaries.json` defines `marsh_leeches` in full (threat 12, xp_reward 24, 90 HP, 12–24 damage, critical `bleeding`, sequence sweep/strike/recover, loot `bitter_tonic`) and no choice in any file fights it; the event-level `adversary_id` is read only as a fallback for a combat choice, so it changes nothing today → keep the profile as deliberate reserve and record it as intentional in the data audit rather than adding a fight. Any future fight anywhere must author its reward in `victory.items`, because `loot` is never granted.

### marsh_ferryman — The Ferryman   [data/events.json +overrides v1/v11; region 2 Drowned Marches; unique=y; weight=3; tags=—]
Scene: a ferryman whose coat is sewn with ticket stubs asks for one true account instead of payment, while a drowned service path may cross nearby.
Evidence on screen: the ticket-stub coat and the refusal of objects ([0]); a road sign standing out of black water; current wrinkling around submerged curbs ([1]); the ferryman watching to see which the survivor trusts.
Comparison: [0] presence favorable 55 healthy / 45 depleted (Presence kit unmeasured, §3); [1] wits risky 45–70 healthy (Wits 70) / 35 depleted. No dominance flag.

[0] Tell the truth about your road — intention: buy passage with an account that costs something to give.
    known cost: none | uncertain risk: pressures fatigue 10, health −4
    success: items bitter_tonic 1; pressures fatigue −5 | failure: pressures fatigue 10, health −4
    local significance: the boat crosses without another question and a tonic is handed over on the far bank, or it pushes away mid-sentence and the survivor wades beside its wake.
    durable: none.

[1] Read the current and cross alone — intention: owe nobody an account.
    known cost: none | uncertain risk: items clean_water −1; pressures fatigue 10
    success: no fields | failure: items clean_water −1; pressures fatigue 10
    local significance: the buried service road carries the survivor over and the boat is gone when they look back, or the road ends where floodwater tore it away.
    durable: none.

Disposition: revise — the marsh's one scene that trades in accounts cannot hear the account the marsh actually gave the survivor.
Findings:
P1: `marsh_map` (`marsh_body` [0] success) has no consumer in any data file → name this one: choice 0 gains a success variant with `requires_any_flags: [marsh_map]` in which the account the ferryman accepts is Lysa Dorn's name and the markings copied from her pocket. Mechanics unchanged (bitter_tonic 1, fatigue −5). Both events are region 2 in random order, so the default text must stand untouched when the flag is absent and never imply a body was found.
P1: [1] failure narrates a bottle pulled from its loop and applies items clean_water −1, clamped to nothing when the survivor is dry → conditional outcome line for the empty case.

### marsh_raiders — Skiffs in the Reeds   [data/events.json +overrides v1/v11; region 2 Drowned Marches; unique=n; weight=4; tags=—; adversary `bog_raiders`]
Scene: three poled skiffs cut the raised path off across a chemical rainbow the riders will not touch.
Evidence on screen: engines wrapped in cloth and poles instead of noise; short guns held high above the water; one rider gesturing for the pack while another closes the path behind; stains on their own poles, which is the material choice 1 uses.
Comparison: [0] fight T15 +44xp flee:y in all states (`bog_raiders`: 250 HP, 50–75 damage, critical `bleeding`, flee difficulty hard); [1] presence risky 45 healthy / 35 depleted (Presence kit unmeasured); [2] certain, gated on `smoke_bomb` ×1. No dominance or redundancy flag. Ungated routes exist for every survivor ([0] and [1]), so there is no blocked action here.

[0] Fire before they close — intention: break the ambush before it is at arm's length.
    known cost: combat with `bog_raiders` (threat 15, xp_reward 44, can_flee true, flee difficulty hard) | uncertain risk: no failure branch authored — defeat is death; fleeing writes nothing
    success (victory): items shotgun_shells 2, clean_water 1 | failure: none authored
    local significance: the nearest skiff overturns and the others choose distance over rescue.
    durable: none. The only combat-bearing event in the marsh pool, so it is what the forced-combat slot picks.

[1] Claim the water is poisoned — intention: turn their own caution into the fee they pay.
    known cost: none | uncertain risk: items rad_tabs −1, cloth_bandage −1
    success: no fields | failure: items rad_tabs −1, cloth_bandage −1
    local significance: doubt spreads between boats and the reeds close behind the survivor, or the bluff is recognized and medicine buys the same passage.
    durable: none.

[2] Use a smoke bomb — intention: remove yourself from a decision you cannot win.
    known cost: requires items smoke_bomb 1; costs items smoke_bomb 1, consumed | uncertain risk: none, certain
    success (outcome): no fields | failure: n/a
    local significance: boats, reeds, and path become one gray absence; one useful escape becomes an empty casing.
    durable: none.

Disposition: revise — choice 2's key cannot exist in this region.
Findings:
P1: `smoke_bomb` has one source in loaded content — `rail_hunters` [0] victory, region 5 — and `marsh_raiders` is drawn only from the region 2 pool, so [2] can never be taken in a real run. This is the defect CONTENT_AUTHORING's M05 note repaired for `climbing_rope` via `global_drop` [1] → give `smoke_bomb` one pre-marsh source in an existing reward (owner: the M05 allowlist holder; the item already exists), or retire [2].
P1: [1] failure narrates medicine handed into the lead skiff and applies items rad_tabs −1, cloth_bandage −1, both clamped to nothing when absent → conditional outcome line for a survivor carrying neither.

### marsh_clinic — Clinic on Stilts   [data/events.json +overrides v1/v11; region 2 Drowned Marches; unique=y; weight=3; tags=—]
Scene: a flooded rural clinic on timber stilts, with an intact pharmacy window above and algae-dark rooms at water level.
Evidence on screen: exterior supports forming a climb toward the intact window ([0]); cabinet doors hanging open at water level and pale mold following the ceiling in branching fans ([1]); rotten wood against spores, stated as the trade.
Comparison: [0] agility favorable 55–80 healthy (Agility 80) / 45 depleted; [1] wits risky 45–70 healthy (Wits 70) / 35 depleted. No dominance flag.

[0] Climb the exterior supports — intention: reach the medicine looters could not.
    known cost: none | uncertain risk: pressures health −13, damage_type physical, add_conditions sprain
    success: items medkit 1, painkillers 1 | failure: pressures health −13 (physical), add_conditions sprain
    local significance: a childproof latch that defeated hurried looters gives up its contents, or a wet crossbeam drops the survivor and the pharmacy stays above them.
    durable: none.

[1] Test the lower rooms first — intention: take the safer floor and manage the air.
    known cost: none | uncertain risk: pressures health −6, add_conditions fever
    success: items cloth_bandage 2, bitter_tonic 1 | failure: pressures health −6, add_conditions fever
    local significance: one room where air still moves outward gives up supplies above its mold line, or a cabinet releases what was trapped behind its door.
    durable: none.

Disposition: keep — better medicine for the harder climb, lesser supplies for the safer floor, and each failure is the risk its route named.
Findings: none.

### marsh_bridge — Bridge of Vines   [data/events.json +overrides v1/v11; region 2 Drowned Marches; unique=n; weight=4; tags=—]
Scene: a footbridge grown through with vine, over water carrying branches fast enough to strike the pylons.
Evidence on screen: the bridge shifting before it is stepped on, with no wind reaching the reeds; the intact side that could take a rope ([1]); branch strikes below; the longer swing the timing must beat ([0]).
Comparison: [0] agility risky, early healthy by kit 45 / 70 / 50 / 45, 35 depleted; [1] wits easy, early healthy by kit 70 / 70 / 95 / 65, 55–65 depleted, gated on `climbing_rope` ×1. The tool reports no dominance only because `requires.items` counts as a greater known cost; the rope is **not** consumed, so once it is carried, [1] equals or beats [0] in every measured cell with an identical (empty) success and a milder failure.

[0] Cross quickly — intention: be off the bridge before movement becomes collapse. Ungated, so the scene keeps a legal action for everyone.
    known cost: none | uncertain risk: pressures health −12, damage_type physical, fatigue 8
    success: no fields | failure: pressures health −12 (physical), fatigue 8
    local significance: the structure survives "changed enough that nobody should repeat the method", or a cable parts and the deck tilts under the survivor.
    durable: none.

[1] Reinforce it with rope — intention: make the crossing methodical instead of desperate.
    known cost: requires items climbing_rope 1, with no `costs`, so the rope is not spent | uncertain risk: pressures fatigue 8
    success: no fields | failure: pressures fatigue 8
    local significance: the bridge complains without changing shape; the failure text already leaves the rope behind, "still marking a route another traveler might trust".
    durable: none. `climbing_rope` is reachable before region 2: `global_drop` [1] success grants it, and globals are eligible in any region.

Disposition: revise — the gate is legitimate and reachable, but the unspent rope makes choice 0 decoration for anyone who owns one.
Findings:
P1: dominance after acquisition, and [0] preserves no expertise the tool can see (Agility only ties [1] at 70) → now: requires climbing_rope 1, no costs | proposed: requires climbing_rope 1, costs items climbing_rope 1, which the authored failure text already describes and which the marsh's ethic of leaving safe passage behind supports. If N06 would rather read this as the intended "equipment sometimes solves problems cleanly" payoff (plan §3), the card asks that it be written into the allowlist as a deliberate exception rather than left unexamined. Note for batch A's owner: `outskirts_sinkhole` [1] has the identical requires-without-costs shape on the same item.

### marsh_lights — Lights Beneath the Water   [data/events.json +overrides v1/v11; region 2 Drowned Marches; unique=y; weight=3; tags=—]
Creature host: **Reed Widow** (CREATURE_STORY_BIBLE). **Source of §5 record 11** — see record 11 for `widow_pool_cleared`, its consumer `lr_voice_in_reeds`, and the hidden choice 3 proposed there. Recorded here: the immediate effects, and what the record does not state.
Scene: pale lights repeat three close, one apart, then dark beneath the drowned road, each cycle beginning farther east.
Evidence on screen: a sequence too regular for animals and too mobile for fixed lamps; the cycle paralleling the road before curving into deeper reeds ([0]); visible roots as the slower footing ([1]). **Absent, and needed for choice 2:** the bible's second and third warnings — a "bank" that moves against the current while the reeds around it move with it, and a single boot, laces still tied, on the raft's edge.
Comparison: [0] wits risky 45–70 healthy (Wits 70) / 35 depleted; [1] grit easy 65–90 healthy (Grit 90) / 55 depleted. No dominance flag. Combat choices are excluded from dominance by §3, so [2] is held non-dominant by design rather than by the tool.

[0] Follow the pattern — intention: reach the cache the beacons appear to mark.
    known cost: none | uncertain risk: pressures radiation 12, fatigue 6
    success: items purifier_ampoule 1, clean_water 2 | failure: pressures radiation 12, fatigue 6
    local significance: a civil-defense cache is opened between pulses and the lights move on guiding nobody, or the beacons drift and the survivor is in radioactive silt before the drift shows.
    durable: none.

[1] Stay on visible ground — intention: refuse an invitation whose source is unknown.
    known cost: none | uncertain risk: pressures fatigue 10
    success: no fields | failure: pressures fatigue 10
    local significance: the lights pace the survivor from below and finally turn away; the possible cache is left where it is.
    durable: none.

[2] APPENDED — Clear the nesting pool (creature combat; CREATURE_STORY_BIBLE and §5 record 11) — intention: make the drainage cut passable instead of gambling on the beacon route.
    known cost: a fight in water — threat mid, HP near Feral Dogs, damage between Leeches and Dogs, sequence Brace / Strike / Heavy / Recover, critical condition `sprain`, **flee risky** because it is faster in water than a person on roots; flee writes no flag | uncertain risk: no failure branch — defeat is death; fleeing forfeits both the cache and the flag
    victory: items purifier_ampoule 1, clean_water 2, exactly choice 0's success reward per record 11; add_flags widow_pool_cleared. XP is the adversary's own `xp_reward`, set with the profile in N05; no story XP on top.
    local significance: the raft is off the drainage cut, the cut is passable dry, and the eggs are what the survivor saw pulsing.
    durable: `widow_pool_cleared` → `lr_voice_in_reeds` (see §5 record 11).
    why it is not dominant: the victory pays choice 0's cache exactly and nothing more, while carrying the scene's largest known cost — health, a `sprain`, and the only death risk in it. Choice 0 stays the cheapest route to the same items; the fight buys certainty and the durable flag with blood.

Not stated in record 11: **the adversary does not exist yet.** `data/adversaries.json` holds thirteen definitions and none is the Widow; the bible reserves `portrait_id: enemy_widow` and the field note "Reed raft over water; pale eggs in sequence; one laced boot". `ContentRepository.validate_all()` raises "Event 'marsh_lights' combat choice references missing adversary" if the choice lands first, so N05's profile must precede N04/N06's choice. Appending it also makes `marsh_lights` count as combat-bearing in `_select_next_event`, beside `marsh_raiders`, for the forced-combat slot and the two-combat cap.
Disposition: revise — append choice 2 exactly as record 11 specifies, and put the bible's warnings on screen first.
Findings:
P1: the introduction shows only the lights; the raft that reads as firm ground and the laced boot are missing, so choice 2 would be offered with no on-screen evidence → add both to the body inside the 60–90 word budget.
P2: no passage names the Widow. The bible requires the name to arrive in the passage, by the survivor's own reckoning, a chalk warning, or a note → name it in the body or in choice 2's prose.

### marsh_hut — Smoke from a Hut   [data/events.json +overrides v1/v11; region 2 Drowned Marches; unique=y; weight=3; tags=supply_opportunity]
Scene: smoke from a hut raised on mismatched poles, with herbs dry beneath the eaves and one shutter that closes as the survivor steps onto the approach.
Evidence on screen: dry herb bundles hanging in mist; no boat tied outside; the shutter moving when the approach is used; the scene states its own trade — announce yourself and be judged, or find out whether anyone is home while announcing what kind of visitor you are.
Comparison: [0] presence favorable 55 healthy / 45 depleted, flat across the four measured kits (Presence kit unmeasured); [1] agility risky 45–70 healthy (Agility 70) / 35 depleted. No dominance flag.

[0] Call out from the reeds — intention: buy supplies as a guest.
    known cost: none | uncertain risk: add_conditions shaken
    success: items ration_bar 2, bitter_tonic 1 | failure: add_conditions shaken
    local significance: an herbalist trades from a concealed platform, crossbow lowered but ready; or nobody answers while the chimney keeps smoking and the shutter shifts against the wind.
    durable: none.

[1] Approach silently — intention: learn whether the hut is occupied before being seen.
    known cost: none | uncertain risk: pressures health −8, damage_type physical, add_conditions fever
    success: items filter_mask 1 | failure: pressures health −8 (physical), add_conditions fever
    local significance: an empty hut with a banked insect fire and a mask left to whoever secures the door; or a warning dart from someone who chooses not to release the second.
    durable: none.

Scheduling note: this is the **only** `supply_opportunity` in the marsh pool and it is unique, so `_select_next_event` forces it at the region's fifth ordinary slot if it has not yet appeared — a supply opportunity, not a supply guarantee, since both failure branches grant nothing.
Recorded, not adopted: CREATURE_STORY_BIBLE offers this hut's wall as an optional recognition echo for a survivor who cleared the Shutter Skitters' stairwell ("if no consumer is named, no flag is written"). That flag would belong to `outskirts_apartment` in batch A, so this card does not name it. If batch A proposes one, a single conditional line lands here at no mechanical cost.
Disposition: keep — guest against intruder, with rewards and failures that follow the manner of approach.
Findings: none.

### marsh_filter — Filter Station   [data/events.json +overrides v1/v11 + living_road source_flag_patches; region 2 Drowned Marches; unique=y; weight=3; tags=—]
**Source of §5 record 4 (Iven's Water Commons).** See §5 record 4 for the four `lr_filter_*` flags, their consumers (`lr_cup_passed_east` → `lr_thirst_court` → `lr_valve_below`), the retirement of `restarted_filter`, and the choice 3 proposed at the consumer. Recorded here: the immediate effects, and what the record does not state.
Scene: a municipal filter station still humming above the flood, with one output gauge showing pressure east and another stripped to bare threads.
Evidence on screen: pipes vibrating under the walkway; the live gauge still carrying pressure toward the eastern settlements ([0]); the stripped mount and the inactive pump beside the live line ([1]); the scene states its own moral term, serving people beyond sight against certain parts now.
Comparison: [0] wits risky 45–80 healthy (Wits 80) / 35–45 depleted; [1] strength favorable 60–75 healthy (Strength 75) / 45 depleted. No dominance flag.

[0] Restart the clean-water line — intention: put water back into a line other people drink from.
    known cost: none | uncertain risk: pressures radiation 10, health −5
    success: items clean_water 3; add_flags restarted_filter, lr_filter_repaired | failure: pressures radiation 10, health −5; add_flags lr_filter_poisoned
    local significance: three bottles fill from the test outlet while the main line carries pressure east, or a coupling parts and the intake closes on a line nobody can now use.
    durable: see §5 record 4. `restarted_filter` is the orphan that record retires; `lr_filter_repaired` / `lr_filter_poisoned` carry the thread.

[1] Strip the inactive pump — intention: take certain parts and stop pretending the line is repairable.
    known cost: none | uncertain risk: pressures health −9, damage_type physical
    success: items scrap_parts 3, filter_mask 1; add_flags lr_filter_stripped | failure: pressures health −9 (physical); add_flags lr_filter_broken
    local significance: the empty mount makes future repair visibly less likely; or blood on a component too heavy to recover, and the station no easier to restore.
    durable: see §5 record 4.

Not stated in record 4: in the 97-event compatibility configuration the `source_flag_patches` do not apply, so this scene writes only `restarted_filter` and Iven's thread never begins. Retiring that flag must therefore be paired with the expanded configuration becoming the default, or the compatibility build loses the only mark this scene leaves.
Disposition: revise — as record 4 specifies; nothing here contradicts or extends it beyond the compatibility note.
Findings:
P1: `restarted_filter` orphan → retire, per §5 record 4, together with the compatibility note above.

### marsh_body — Body in a Raincoat   [data/events.json +overrides v1/v11; region 2 Drowned Marches; unique=y; weight=3; tags=—; choices 2–3 are M05 equipment routes]
Scene: a body in a yellow raincoat is held against a road marker by its own hood, the material clean enough that death came after the last storm.
Evidence on screen: the fastened waterproof pocket under the collar where swelling has not reached ([0]); the scene's own statement that leaving preserves dignity and every unanswered reason ([1]). **Absent:** the ground-down reinforcing bar through the marker ([2]) and the tire plates under the coat ([3]) appear only in the labels and the success texts.
Comparison: [0] wits favorable 55–80 healthy (Wits 80) / 45 depleted; [1] certain in every state; [2] strength risky 50–65 (Strength 65) / 35; [3] strength risky 50–65 (Strength 65) / 35. No dominance or redundancy flag — [1] is certain, but its outcome carries no fields at all.

[0] Search for identification — intention: return a name and a route to the record.
    known cost: none | uncertain risk: pressures health −5, add_conditions infection
    success: items rad_tabs 1; add_flags marsh_map | failure: pressures health −5, add_conditions infection
    local significance: the pocket gives up tablets, a route map, and identification for Lysa Dorn; the survivor copies the marsh markings and returns her face beneath the water. On failure the coat tears and no name is recovered.
    durable: orphan: `marsh_map` — proposed consumer `marsh_ferryman` [0] success variant (see that card).

[1] Leave the dead undisturbed — intention: refuse to convert a person into supplies.
    known cost: none | uncertain risk: none, certain
    success (outcome): no fields at all | failure: n/a
    local significance: a branch wedged so the current cannot drag her into open water, and the yellow coat left visible for anyone searching by description.
    durable: none.

[2] APPENDED (M05 allowlist) Recover the Rebar Spear — intention: take the weapon somebody else already made.
    known cost: none | uncertain risk: pressures fatigue 6
    success: items rebar_spear 1 | failure: pressures fatigue 6
    local significance: the bar comes free in chest-deep pulls with the raincoat undisturbed, or the post is given back to the flood.
    durable: none. Keep as authorized.

[3] APPENDED (M05 allowlist) Recover the Tire Armor — intention: take the protection she no longer needs.
    known cost: none | uncertain risk: pressures fatigue 6
    success: items tire_armor 1 | failure: pressures fatigue 6
    local significance: plates cut from truck tire come free after longer than respect would prefer, or the body settles deeper and the survivor stops while stopping is still their decision.
    durable: none. Keep as authorized.

Disposition: revise — evidence for the two equipment routes, and a consumer for the name.
Findings:
P1: [2] and [3] have no opening evidence; the bar and the plates exist only in labels and success texts → one clause in the body for each (a ground-down bar driven through the marker; rubber plates showing at the coat's hem). Prose only; M05 fields untouched.
P1: `marsh_map` orphan → consumer named in `marsh_ferryman` [0] success variant. If that is refused, retire the flag; nothing else reads it.

### marsh_storm — Black Rain   [data/events.json +overrides v1/v11; region 2 Drowned Marches; unique=n; weight=4; tags=—]
Scene: rain that starts black, spreading oily rings, with frogs and insects stopping together.
Evidence on screen: the oil ring on standing water and the simultaneous silence; a fallen road sign with enough metal for a low roof ([0]); a tree line visible but farther than the storm's advancing curtain ([1]); the stated risk that poor shelter holds poisoned water close.
Comparison: [0] strength favorable 60–75 healthy (Strength 75) / 45 depleted; [1] agility risky 45–70 healthy (Agility 70) / 35 depleted. No dominance flag.

[0] Build cover from a road sign — intention: make shelter here rather than reach shelter later.
    known cost: pressures fatigue 5, radiation 3 on success, disclosed as minor contamination | uncertain risk: pressures health −8, radiation 14, fatigue 10
    success: pressures fatigue 5, radiation 3 | failure: pressures health −8, radiation 14, fatigue 10
    local significance: runoff drains behind the raised verge and the metal booms without folding; or the sign is driven into mud across the survivor's legs and pools contamination around them.
    durable: none.

[1] Push for the tree line — intention: outrun the curtain to cover that already exists.
    known cost: none | uncertain risk: pressures radiation 16, fatigue 14
    success: pressures fatigue 8 | failure: pressures radiation 16, fatigue 14
    local significance: layered canopy spends the contaminated drops instead of skin; or the rain overtakes the survivor among reeds with nothing high enough to hide beneath.
    durable: none.

Disposition: keep — an honest exposure trade where even the better success still takes radiation 3, and neither route is free.
Findings: none.

---

## Batch summary

DISPOSITIONS:
flats_toll | revise | victory pays unusable ammunition and the negotiated toll can be narrated without being charged
flats_mirage | revise | prose only: name the Salt Colossus, make choice 0 its bearing and choice 1 its wake, and never remember an earlier sighting
flats_tanker | keep | force against procedure, distinct rewards, failures that match their routes
flats_dustwall | keep | same odds band, genuinely different costs and conditions
flats_bones | revise | read_bone_warning takes the consumer proposed here and the wake needs naming
flats_convoy | revise | choice 3 claims knowledge of the toll barricade the survivor may never have seen
flats_solar | keep | rest against parts, priced against a concussion
flats_crater | revise | takes the crater_warning consumer as an introduction variant
flats_signal | revise | decoded_numbers is retired
flats_nightfire | revise | repeat visits need flag precedence and the theft can charge nothing
marsh_leeches | keep | sighting-only per STORY_CANON §4; the kit inversion is the scene
marsh_ferryman | revise | takes the marsh_map consumer and needs an empty-bottle variant
marsh_raiders | revise | the smoke bomb cannot be obtained before this region
marsh_clinic | keep | two medicine routes with matching failures
marsh_bridge | revise | the unspent rope makes choice 0 decoration once acquired
marsh_lights | revise | append the Reed Widow fight per §5 record 11 and put its warnings on screen
marsh_hut | keep | guest against intruder, with rewards and failures that follow the approach
marsh_filter | revise | per §5 record 4, plus the compatibility note on retiring restarted_filter
marsh_body | revise | the two equipment routes need opening evidence and marsh_map needs its consumer
marsh_storm | keep | honest exposure trade with no free success

FINDINGS:
P0 | flats_toll | 1 | success and failure narrate food and water handed over that _change_item clamps to zero → conditional outcome variant for a survivor who cannot pay; fields unchanged
P0 | flats_convoy | 3 | success asserts detailed knowledge of the toll barricade that many runs never acquire (STORY_CANON §5) → variant keyed on crater_warning with a neutral default, or rewrite the traded warning; M05 fields unchanged
P1 | flats_toll | 0 | threat-13 victory pays revolver_rounds 3 (usable only by the unmeasured Presence kit's holdout_revolver) plus scrap_parts 1 → now: revolver_rounds 3, scrap_parts 1 | proposed: revolver_rounds 3, scrap_parts 1, canned_meat 1
P1 | flats_toll | 1 | crater_warning orphan → consumer: flats_crater introduction variant, or retire
P1 | flats_mirage | - | no durable effect; the bible permits a flag → keep local, because a flag on a repeatable scene cannot distinguish sightings
P2 | flats_mirage | 1 | success describes the mirage but not the wake → rewrite around the parallel crust fractures
P1 | flats_bones | 0 | read_bone_warning orphan → consumer: flats_mirage introduction variant keyed on requires_any_flags [read_bone_warning]; retiring it would leave choice 0 with no reward
P2 | flats_bones | - | the darker crust inside the ring is never tied to what made it → name the wake
P1 | flats_convoy | 2 | the sun awning appears only in the label and success text → add it to the body
P1 | flats_crater | - | consumes flats_toll's crater_warning as an introduction variant; the default text must stand when the flag is absent
P1 | flats_signal | 0 | decoded_numbers orphan and not the SOTERIA signal (that is global bunker41_static) → retire; choice 0 keeps medkit 1 and rifle_rounds 3 as its premium
P1 | flats_nightfire | - | repeat visits can write two contradictory lr_nightfire_* flags → N04 fixes precedence (shared > robbed > passed > spooked) in §5 record 5
P1 | flats_nightfire | 0 | failure narrates a stolen can, clamped to nothing when the survivor has none → conditional outcome variant; the flag still writes
P2 | marsh_leeches | - | the full marsh_leeches adversary profile and the event-level adversary_id are unreachable (no combat choice anywhere) → keep sighting-only per STORY_CANON §4 and record the profile as deliberate reserve; loot arrays are never granted
P1 | marsh_ferryman | 0 | no way to offer the account the marsh gave → success variant keyed on marsh_map naming Lysa Dorn; mechanics unchanged
P1 | marsh_ferryman | 1 | failure narrates a lost bottle, clamped to nothing when dry → conditional outcome line
P1 | marsh_raiders | 2 | smoke_bomb exists only from rail_hunters [0] victory in region 5, so this choice is unreachable in region 2 → give smoke_bomb one pre-marsh source in an existing reward, or retire the choice
P1 | marsh_raiders | 1 | failure narrates medicine taken, clamped to nothing when absent → conditional outcome line
P1 | marsh_bridge | 1 | the rope is required but never consumed, so after acquisition this choice equals or beats choice 0 in every measured cell with a milder failure → now: requires climbing_rope 1, no costs | proposed: add costs.items climbing_rope 1 (the failure text already leaves the rope on the bridge), or record the dominance in the allowlist as a deliberate equipment payoff
P1 | marsh_lights | 2 | the appended fight has no on-screen evidence: the raft that reads as firm ground and the laced boot are missing → add both to the body
P2 | marsh_lights | 2 | the Reed Widow is never named in any passage → name it in the body or in choice 2's prose
P1 | marsh_filter | 0 | restarted_filter orphan → retire per §5 record 4, paired with the expanded configuration becoming the default, or the compatibility build loses this scene's only mark
P1 | marsh_body | 2 | the ground-down rebar has no opening evidence → one clause in the body; M05 fields unchanged
P1 | marsh_body | 3 | the tire plates have no opening evidence → one clause in the body; M05 fields unchanged
P1 | marsh_body | 0 | marsh_map orphan → consumer: marsh_ferryman [0] success variant, or retire
