# Consequence cards — Batch C: Hollow Industrial Zone and Glass Wastes

Batch C of [NARRATIVE_CONSEQUENCE_MAP.md](../NARRATIVE_CONSEQUENCE_MAP.md) §4: the ten `hollow_industrial` pool events (region 3, travel radiation 2) and the ten `glass_wastes` pool events (region 4, travel radiation 3, the highest on the road). Cards use the §2 template.

Prose is what loads: `data/events.json` with both override files applied. No event here is touched by `living_road_events.json` `source_flag_patches`. `Comparison:` numbers are `builds/choice_comparison.md`, never estimated; glass cards add a radiation-stacking note on the same line because travel alone charges 3 per leg. All twenty introductions and all sixty-three outcome passages sit inside the 60–90 / 30–50 budgets, so no card flags length. `industrial_tank` is §5 record 9 and `glass_shadow` is §5 record 10; those cards record immediate effects only.

---

### industrial_drones — Evacuation Order   [events.json+overrides; Hollow Industrial (r3); unique=n; weight=5; tags=none; event-level `adversary_id: drone_swarm`]
Scene: A bay door lifts by itself and three security drones resume an evacuation order decades too late.
Evidence on screen: "The control link pulses from a relay above the yard" ([0]); painted blind spots that "end beneath hanging chains that turn whenever the drones pass" ([1]).
Comparison: [0] healthy 35-70, depleted 25-35; [1] healthy 35-60, depleted 25. No dominance, no redundancy.

[0] Disable their control link — intention: stop the machines at their source.
    known cost: none; wits hard (technical) | uncertain risk: `pressures {health: -20}`, `damage_type physical`, `add_conditions [concussed]`
    success: `items {scrap_parts: 3, field_scanner: 1}` | failure: the fields above; the drones leave, nothing recovered
    local significance: three drones inert on the concrete; the bay is quiet for whoever crosses next.
    durable: none.
[1] Sprint between blind spots — intention: cross without touching them.
    known cost: none; agility hard (evade) | uncertain risk: `pressures {health: -16, fatigue: 10}`, `damage_type physical`, `add_conditions [sprain]`
    success: no fields, passage only | failure: the fields above
    local significance: the drones keep the yard and the order follows the survivor out.
    durable: none.

Combat judgement (batch question): **sighting-only; no combat at index 2.** STORY_CANON §4 lists Security Drones as "sighted, never fought"; CREATURE_STORY_BIBLE fixes four appended fights elsewhere and requires "Organic is true for all four; none is a machine"; `drone_swarm`'s `loot` is exactly `scrap_parts, field_scanner`, so a victory branch would be redundant with [0] under §3; and at unique=n weight 5 a threat-16 fight would be farmable 48 XP against the combat-opportunity cap. No reward here is behind a fight today.

Disposition: revise — the evade route pays nothing on a repeatable scene while risking a permanent condition.
Findings:
P1: [1] success writes no field though its failure matches [0]'s severity (`sprain` agi −2 vs `concussed` wits −2 / agi −1) → now: no fields | proposed: `add_conditions ["steady_hands"]`, a real reward under §3's beneficial-condition caveat with no supply inflation.
P2: `adversary_id: drone_swarm` is inert (the engine reads it only as a fallback for a combat choice) → drop it or record it as deliberate.

### industrial_generator — Generator Three   [events.json+overrides; Hollow Industrial (r3); unique=y; weight=3; tags=none]
Scene: A failing generator behind a mesh cage still feeds power deeper into the factory; repair it or strip it.
Evidence on screen: "Half the indicator lamps glow green" and an emergency store the intro says could reopen ([0]); "A copper bus shakes against its ceramic mounts" ([1]).
Comparison: [0] healthy 45-80, depleted 35-45; [1] healthy 50-65, depleted 35. No dominance, no redundancy; [1] is the Strength cell, [0] the Wits cell.

[0] Stabilize the output — intention: make the machine work and open what its power locks.
    known cost: none; wits risky (technical) | uncertain risk: `pressures {health: -13}`, `add_conditions [burned]`
    success: `items {stimulant: 1, medkit: 1, scrap_parts: 1}` | failure: the fields above; the flywheel turns on
    local significance: the emergency locker is open and Generator Three still runs.
    durable: none.
[1] Tear out the copper — intention: convert the machine into carried salvage.
    known cost: none; strength risky (force) | uncertain risk: `pressures {health: -14}`, `damage_type physical`, `add_conditions [sprain]`
    success: `items {scrap_parts: 4}` | failure: the fields above
    local significance: "Darkness spreads through the connected corridor" — the region loses its last working power.
    durable: none.

Disposition: keep — repair against theft, the region's own question, priced differently per kit and honestly paid.
Findings:
P2: [1]'s failure names the mechanic — "a sprain's bright warning" → describe the joint, per the bible's "Conditions appear through their symptoms".

### industrial_scavs — Claimed Warehouse   [events.json+overrides; Hollow Industrial (r3); unique=n; weight=4; tags=none; `adversary_id: vault_scavs`]
Scene: A disciplined crew holds a warehouse roof and asks what news travels east.
Evidence on screen: the masked woman's question and her marked map ([0]); "no weapon wavers" ([1]); "Freight cars offer a concealed route around them" ([2]).
Comparison: [0] healthy 45, depleted 35; [1] fight T15 +46xp flee:y (`flee_difficulty: hard`); [2] healthy 45-70, depleted 35. No dominance, no redundancy. [0] is Presence and that kit is unmeasured (comparison header), so 45 is the measured kits' floor.

[0] Offer information for passage — intention: buy the road with what the road told you.
    known cost: none; presence risky (social) | uncertain risk: `items {medkit: -1, rad_tabs: -1}` and nothing else
    success: `items {ration_bar: 1}` | failure: the confiscation above
    local significance: the crew keeps the survivor's face on file "without pretending friendship".
    durable: none.
[1] Challenge their weakest guard — intention: take passage instead of trading for it. Combat `vault_scavs`, threat 15, 46 XP, flee `hard`; flee resolves nothing and writes no flag.
    known cost: the fight | uncertain risk: defeat is death; no `defeat` branch authored
    success (`victory`): `items {rifle_rounds: 3}` | failure: none authored
    local significance: the same road opens, "earned rather than forgiven".
    durable: none.
[2] Slip through the rail yard — intention: never be seen.
    known cost: none; agility risky (evade) | uncertain risk: `pressures {fatigue: 15, health: -4}`
    success: no fields — "no prize except an unchallenged route" | failure: the fields above
    local significance: the crew never learns anyone passed.
    durable: none.

Disposition: revise — [0]'s failure can resolve with no mechanical effect at all.
Findings:
P1: [0]'s failure is `items {medkit: -1, rad_tabs: -1}` only, and the engine erases only what is present, so a survivor carrying neither loses nothing while a supplied one loses two consumables → now: items only | proposed: add `pressures {fatigue: 8}`. ([2]'s unpaid success is correct: its failure is the scene's mildest. This batch flags an unpaid route only where it also carries the heaviest failure.)

### industrial_conveyor — The Moving Line   [events.json+overrides; Hollow Industrial (r3); unique=y; weight=3; tags=supply_opportunity]
Scene: A conveyor wakes and feeds sealed crates into a crusher.
Evidence on screen: labels promising "medical packing, food reserve, and riot-control stock", unreadable per crate ([0]); "The emergency panel blinks behind a guard rail" and takes longer to reach ([1]).
Comparison: [0] healthy 45-70, depleted 35; [1] healthy 45-80, depleted 35-45. No dominance, no redundancy.

[0] Grab a crate before the crusher — intention: one gamble at the belt's own speed.
    known cost: none; agility risky (evade) | uncertain risk: `pressures {health: -17}`, `damage_type physical`, `add_conditions [sprain]`
    success: `items {riot_padding: 1, shotgun_shells: 2}` | failure: the fields above; the crate is crushed
    local significance: one crate off the line; the crusher keeps working.
    durable: none.
[1] Stop the line at its panel — intention: end the machine's appetite and keep what is still on it.
    known cost: none; wits risky (technical) | uncertain risk: `pressures {fatigue: 6}`
    success: `items {canned_meat: 2, clean_water: 2}` | failure: fatigue only; the belt runs on
    local significance: the sorting floor is silent and the reserve crates survive.
    durable: none.

Disposition: keep — [0] is priced harder on both branches and its premium is real: `riot_padding` is the highest-`damage_reduction` armor in `items.json`, the comparison header's supplied armor for every kit.
Findings: none.

### industrial_office — Executive Shelter   [events.json+overrides; Hollow Industrial (r3); unique=y; weight=3; tags=none; choices 2–3 are M05 appended equipment routes, CONTENT_AUTHORING.md allowlist]
Scene: A shelter for eight stands on pillars above the floor, its frame scratched by more than eight.
Evidence on screen: "A chemical lock protects the keypad. Personnel notices curl behind dusty glass" ([0]); "Thin wall panels offer another entrance" ([1]); nothing for [2] or [3].
Comparison: [0] 35-70 / 25-35; [1] 40-55 / 25; [2] 35-70 / 25-35; [3] 45-70 / 35 (healthy / depleted). No dominance, no redundancy. At the four-choice maximum.

[0] Guess the manager's override — intention: open the door the way its owner did.
    known cost: none; wits hard (technical) | uncertain risk: `pressures {radiation: 7}`
    success: `items {medic_satchel: 1, painkillers: 1}` | failure: chemical lockout; the room stays sealed
    local significance: entered without breaking; the names under the chairs undisturbed.
    durable: none.
[1] Cut through the wall — intention: refuse the lock entirely.
    known cost: none; strength hard (force) | uncertain risk: `pressures {health: -8, fatigue: 8}`, `add_conditions [fever]`
    success: `items {canned_meat: 2, clean_water: 1}` | failure: the fields above; the office visible and unreachable
    local significance: a hole in the wall; "The unopened door preserves whatever promise the shelter once made."
    durable: none.
[2] Unlock the Hunting Rifle cabinet — APPENDED (M05) — intention: leave with a long weapon.
    known cost: none; wits hard (technical) | uncertain risk: `pressures {fatigue: 8}`
    success: `items {hunting_rifle: 1, rifle_rounds: 4}` | failure: fatigue only; the cabinet bars itself
    local significance: the cabinet is open, or seized permanently.
    durable: none.
[3] Recover the Flare Gun — APPENDED (M05) — intention: take the kit nobody could reach.
    known cost: none; agility risky (salvage) | uncertain risk: `pressures {fatigue: 8}`
    success: `items {flare_gun: 1, shotgun_shells: 3}` | failure: fatigue only; the kit stays mounted
    local significance: the bracket above the door is empty, or still full.
    durable: none.

Disposition: revise — keep all four routes per the allowlist; two are invisible until the choice list appears and two solve the same puzzle.
Findings:
P1: weak opening evidence — the body shows the keypad and the panels but never the gun cabinet or the door-mounted kit → add one clause each (67 words today; both fit 60–90).
P2: [0] and [2] both resolve by reading a date off the personnel board → give [2] its own evidence, not the worn dial `industrial_locker` [2] already uses.

### industrial_fire — Chemical Fire   [events.json+overrides; Hollow Industrial (r3); unique=n; weight=4; tags=none]
Scene: Blue flame crosses a loading dock toward pressure drums that have started to tick.
Evidence on screen: "Suppression pipes run overhead, each valve painted a different emergency color beneath identical rust" ([0]); "The outer fence offers distance if you can reach it before rupture" ([1]).
Comparison: [0] healthy 45-80, depleted 35-45; [1] healthy 45-70, depleted 35. No dominance, no redundancy. Neither branch touches radiation, correct against the region's 2 per leg.

[0] Open the suppression valves — intention: put the fire out and keep the dock.
    known cost: none; wits risky (technical) | uncertain risk: `pressures {health: -18}`, `add_conditions [burned]` (grit −2, permanent)
    success: `items {scrap_parts: 1}` | failure: the fields above; the dock burns
    local significance: the drums hold and the dock survives under chemical snow.
    durable: none.
[1] Run the outer fence — intention: be elsewhere when the drums go.
    known cost: `pressures {fatigue: 8}` on success | uncertain risk: `pressures {health: -16, fatigue: 10}`, `damage_type physical`, `add_conditions [concussed]`
    success: `pressures {fatigue: 8}` | failure: the fields above
    local significance: the dock and everything on it are gone.
    durable: none.

Disposition: revise — the promised preserved dock pays one scrap for the scene's worst failure.
Findings:
P1: weak reward — [0] risks `health -18` plus permanent `burned` for `items {scrap_parts: 1}` while the intro offers to "bury the fire and preserve the dock" → now: `items {scrap_parts: 1}` | proposed: `items {scrap_parts: 1, purifier_ampoule: 1}`, the intact chemical stock suppression saved. Deliberately modest: the event repeats at weight 4.
P2: [1]'s failure says "concussed and depleted", two status words in a row → show the symptoms.

### industrial_tank — Knocking in the Tank   [events.json+overrides; Hollow Industrial (r3); unique=y; weight=3; tags=none] — §5 record 9; CREATURE_STORY_BIBLE, Kilnback
Scene: Three knocks and an exact pause repeat inside a sealed tank whose needle sits below the red mark: a person rationing breath, or a body living on the heat.
Evidence on screen: "Condensation trembles on the inspection hatch, and the pressure needle sits just below its red mark" ([0]); the exact pause ([1]); the bible's scorch-rings are the missing warning for [2].
Comparison: [0] healthy 45-70, depleted 35; [1] healthy 55-90, depleted 45-55, the best odds in the batch. No dominance, no redundancy. [0]'s failure `radiation: 13` against travel 2 per leg reads correctly for a contaminated jet to the face.

[0] Open the inspection hatch — intention: get a trapped person out before the argument matters.
    known cost: none; grit risky (risk) | uncertain risk: `pressures {radiation: 13, health: -7}`
    success: `items {field_scanner: 1}`, `add_flags [rescued_engineer]` | failure: the fields above; the knocking stops
    local significance: a dehydrated engineer walks out and limps "toward a route you mark west".
    durable: **orphan: `rescued_engineer`** (no consumer in any of the four data files or `road_ledger.json`). **Decision: retire.** The bible offers "the engineer among `rail_survivors`", but the loaded outcome sends them *west* while `rail_survivors` is region 5 east; seating them at the council would be false history under STORY_CANON §5. Same treatment as `helped_family`, `silenced_siren`, `restarted_filter` (§5 records 1, 2, 4). The scanner and the life stay.
[1] Listen for a pattern — intention: learn what the knocking is before touching it.
    known cost: none; wits favorable (technical) | uncertain risk: `add_conditions [shaken]` only
    success: `items {clean_water: 2}` | failure: `add_conditions [shaken]`; the tank stays shut
    local significance: the line is drained and the knocking slows, then stops.
    durable: see §5 record 9 — success gains proposed `kilnback_rhythm_known` (consumer `lr_warm_windows`).
[2] Clear the cooling jacket — APPENDED (bible; §5 record 9) — intention: reach the water and free the service side by fighting instead of gambling on pressure.
    known cost: a heavy fight | uncertain risk: `critical_condition: burned`; flee **favorable** ("it will not leave the heat"), resolving nothing and writing no flag. **`enemy_kilnback` is not defined in `data/adversaries.json` today**; threat, HP, damage, and `xp_reward` are N05's from the bible's sketch (threat high, HP largest of the four and below the Warden, Brace / Heavy / Strike / Recover).
    success (`victory`): `items {clean_water: 2}`, `add_flags [kilnback_rhythm_known]` — record 9's "the water"; the engineer walks out in the passage and `field_scanner` stays exclusive to [0], so the fight cannot collect the scene | failure: defeat is death; no `defeat` branch
    local significance: the cooling jacket is empty and nothing lives in the processing floor's heat.
    durable: see §5 record 9.

Disposition: revise — append [2] per record 9 and the bible; retire `rescued_engineer`.
Findings:
P1: orphan `rescued_engineer` → retire, keeping the rescue in the passage.
P1 (for N05): [1] already reaches both of [2]'s rewards at 55-90 healthy, so [2] is bought with risk alone → set `enemy_kilnback`'s `xp_reward` high enough to pay for the death chance.

### industrial_crane — Crane Above the Yard   [events.json+overrides; Hollow Industrial (r3); unique=n; weight=3; tags=none]
Scene: A cargo pallet hangs over the only clear path on one corroded cable shedding wires as the survivor watches.
Evidence on screen: "individual wires snap and recoil with soft metallic pings" ([0]); "The crane cab overlooks the load from a rusted ladder" ([1]).
Comparison: [0] healthy 55-80, depleted 45; [1] healthy 45-80, depleted 35-45. No dominance, no redundancy.

[0] Dash beneath it — intention: spend seconds instead of an hour.
    known cost: none; agility favorable (evade) | uncertain risk: `pressures {health: -18}`, `damage_type physical`, `add_conditions [concussed]`
    success: no fields, passage only | failure: the fields above; the cargo is buried
    local significance: the cable parts behind the survivor and closes the route for anyone following.
    durable: none.
[1] Lower it from the cab — intention: land the load and open it.
    known cost: none; wits risky (technical) | uncertain risk: `pressures {fatigue: 8}`
    success: `items {scrap_parts: 3, ration_bar: 1}` | failure: fatigue only; the pallet stays overhead
    local significance: the pallet is grounded and cut free, or still hanging.
    durable: none.

Disposition: revise — the unpaid route carries the scene's only injury risk.
Findings:
P1: [0] risks `health -18` and permanent `concussed` for no field while [1] risks `fatigue: 8` for `scrap_parts: 3` and a `ration_bar`; the fast route is worse on both branches and saves time the run does not price → now: no fields | proposed: `add_conditions ["steady_hands"]` on [0] success.

### industrial_locker — Names on the Lockers   [events.json+overrides; Hollow Industrial (r3); unique=y; weight=3; tags=none; choices 2–3 are M05 appended equipment routes, CONTENT_AUTHORING.md allowlist]
Scene: Worker lockers scratched with family names and dates that stop on evacuation day; one door carries no name.
Evidence on screen: "One locker remains unmarked and tightly sealed" ([0]); the named doors ([1]); nothing for [2] or [3].
Comparison: [0] 55-80 / 45; [1] certain; [2] 45-80 / 35-45; [3] 50-65 / 35 (healthy / depleted). No dominance, no redundancy. At the four-choice maximum.

[0] Open only the unmarked locker — intention: take supplies without opening a grave.
    known cost: none; wits favorable (salvage) | uncertain risk: `pressures {health: -6}`, `add_conditions [bleeding]`
    success: `items {mechanic_gloves: 1, cloth_bandage: 1, road_shield: 1}` | failure: the fields above; the latch holds
    local significance: every named door stays shut — "useful things demand no trespass against the dead".
    durable: none.
[1] Leave the names closed — intention: refuse the room entirely.
    known cost: none; certain | uncertain risk: none
    success (`outcome`): `add_conditions [focused]`, wits +2 for two checks — a real reward under §3 | failure: n/a
    local significance: the boundary the workers drew holds.
    durable: none.
[2] Open the security locker for the Stun Baton — APPENDED (M05) — intention: take the guard's weapon out of the room.
    known cost: none; wits risky (technical) | uncertain risk: `pressures {fatigue: 8}`
    success: `items {stun_baton: 1}` | failure: fatigue only; the cabinet seizes
    local significance: the security cabinet is open, or locked harder than before.
    durable: none.
[3] Salvage the Scavenger Rig — APPENDED (M05) — intention: leave carrying more than you arrived with.
    known cost: none; strength risky (salvage) | uncertain risk: `pressures {fatigue: 8}`
    success: `items {scavenger_rig: 1}` | failure: fatigue only; the rig is creased beyond use
    local significance: a locker frame torn open, or bent shut.
    durable: none.

Disposition: revise — keep all four per the allowlist; the appended two are invisible in the introduction and borrow [0]'s action.
Findings:
P1: weak opening evidence — the body shows only the unmarked locker, yet [2] opens "behind the unmarked door" and [3] finds a rig "inside the locker frame", narrating a step taken only under [0] → name the bolted security cabinet and the bolted-through rig in the body (74 words today; fits 60–90) and let each passage open its own object.

### industrial_alarm — Red Shift Alarm   [events.json+overrides; Hollow Industrial (r3); unique=n; weight=4; tags=none]
Scene: Blast doors seal in sequence down an assembly corridor while a flat voice announces a shift evacuation.
Evidence on screen: "The wall console can freeze the pattern if its surviving circuits still obey" ([0]); "the closing gaps form a race whose finish keeps narrowing", with dents at shoulder height and scratches near the floor ([1]).
Comparison: [0] healthy 35-70, depleted 25-35; [1] healthy 45-70, depleted 35. No dominance, no redundancy; [0] is the harder check and exists for Wits expertise.

[0] Override the door sequence — intention: take the corridor away from the machine.
    known cost: none; wits hard (technical) | uncertain risk: `items {clean_water: -1, canned_meat: -1}`, `pressures {fatigue: 6}`
    success: no fields — "one clean passage through" | failure: the fields above; the survivor escapes carrying less
    local significance: every barrier stops at a different height; the corridor stays open behind you.
    durable: none.
[1] Race the closing doors — intention: outrun the sequence rather than argue with it.
    known cost: none; agility risky (evade) | uncertain risk: `pressures {health: -15}`, `damage_type physical`, `add_conditions [sprain]`
    success: no fields, passage only | failure: the fields above
    local significance: the doors finish closing and seal the alarm away behind the survivor.
    durable: none.

Disposition: keep — a hazard crossing whose successes are the crossing, whose failures differ in kind (supplies against a joint), and whose harder check belongs to the stat that paid for it.
Findings: none. (Noted: [0]'s item loss is inventory-dependent, but `fatigue: 6` keeps the failure from ever resolving empty — contrast `industrial_scavs` [0].)

### glass_cult — Pilgrims of the Flash   [events.json+overrides; Glass Wastes (r4); unique=n; weight=4; tags=none; `adversary_id: glass_cult`]
Scene: Robed pilgrims kneel across the fused plain reciting a road blessing while a child watches for mistakes, between the survivor and east.
Evidence on screen: "old burns polished with oil" and the alternating blessing ([0]); "each pilgrim holds a blade made from the ground itself" ([1]); "A glass ridge offers concealment beneath reflected heat" ([2]).
Comparison: [0] healthy 35, depleted 25 — the batch's hardest odds; [1] fight T17 +62xp flee:y (`flee_difficulty: desperate`); [2] healthy 45-70, depleted 35. No dominance, no redundancy. [0] is Presence and that kit is unmeasured. Radiation stack (travel 3/leg): only [2] adds any, `radiation: 5` for lying under a sun-magnifying ridge through a whole procession — plausible beside the leg cost.

[0] Recite their road blessing — intention: pass as someone this faith recognizes.
    known cost: none; presence hard (social) | uncertain risk: `pressures {health: -18}`, `damage_type physical`, `add_conditions [shaken]`
    success: `items {rad_tabs: 2}` | failure: the fields above; the ring drives the survivor out as profane
    local significance: the ranks open and the survivor is counted "another traveler carrying damage toward meaning" — STORY_CANON §7's Cult, election rather than admission, distinct from the Ash Choir.
    durable: none.
[1] Break through their line — intention: refuse the ceremony outright. Combat `glass_cult`, threat 17, 62 XP, flee `desperate`; flee writes no flag.
    known cost: the fight | uncertain risk: defeat is death; no `defeat` branch authored
    success (`victory`): `items {purifier_ampoule: 1, glow_moss: 2}` | failure: none authored
    local significance: the procession scatters and leaves its offerings behind.
    durable: none.
[2] Wait beneath the glass ridge — intention: let the faith pass without meeting it.
    known cost: none; agility risky (evade) | uncertain risk: `pressures {fatigue: 13, radiation: 5}`
    success: no fields; warm knee prints in the glass | failure: the fields above
    local significance: the procession moves east never knowing it was watched.
    durable: none.

Disposition: revise — the social route is the least likely and the least paid in a scene where the fight pays most.
Findings:
P1: weak reward on the hardest check — [0] is 35 healthy and 25 hungry/injured/irradiated/depleted for `rad_tabs: 2`, against 62 XP plus two consumables on [1] → now: `items {rad_tabs: 2}` | proposed: `items {rad_tabs: 2, glow_moss: 1}`, the offering the victory text says they abandon. Reward, not difficulty: the forgotten final line should stay hard to know. Combat stays one route of three.

### glass_storm — Needle Storm   [events.json+overrides; Glass Wastes (r4); unique=n; weight=5; tags=none]
Scene: Wind lifts slivers off the plain into a moving wall of needles fine enough to enter seams and lungs.
Evidence on screen: "Layered cloth may turn the smallest fragments if wrapped before the gale arrives" ([0]); "An overturned crawler waits across open ground, armored belly facing the storm" ([1]).
Comparison: [0] healthy 35-60, depleted 25; [1] healthy 35-60, depleted 25 — no dominance or redundancy, but [1] leads in the injured and irradiated columns and [0] only in supplied. Radiation stack (travel 3/leg): both failures are `radiation: 0`, the batch's one implausible reading — see below.

[0] Wrap up and endure — intention: survive the storm where it finds you.
    known cost: `pressures {fatigue: 8}` on success | uncertain risk: `pressures {health: -18, fatigue: 12}`, `damage_type physical`, `add_conditions [bleeding]`
    success: `pressures {fatigue: 8}` | failure: the fields above
    local significance: the crossing is made inside cut cloth instead of cut skin.
    durable: none.
[1] Reach the overturned crawler — intention: put armor between yourself and the air.
    known cost: none; agility hard (evade) | uncertain risk: `pressures {health: -16, fatigue: 15}`, `damage_type physical`, no condition
    success: no fields | failure: the fields above
    local significance: the survivor waits under the hull while glass buries their tracks.
    durable: none.

Disposition: revise — the Grit route is worse on both branches at tied odds.
Findings:
P1: [0]'s success costs `fatigue: 8` and its failure adds `bleeding`, while [1] pays nothing on success and adds no condition on failure → now: [1] success has no fields | proposed: `pressures {fatigue: 4}`, the wait its own passage describes ("you listen to glass bury your tracks and wait for silence") and the cost missing today.
P2: both failures put irradiated glass dust in clothing and lungs — "sparkling with fragments too small to remove" — for `radiation: 0`, less than the 3 the region charges to walk the leg → give [0]'s failure a small radiation value.

### glass_bunker — Bunker 41   [events.json+overrides; Glass Wastes (r4); unique=y; weight=3; tags=supply_opportunity]
Scene: A civil-defense blast door protrudes from fused ground with its number half buried, holding cold air behind an inspection slit.
Evidence on screen: "The keypad still blinks green" and emergency placards ([0]); "A maintenance hatch lies lower, its hinges swollen but reachable through a narrow shaft" ([1]).
Comparison: [0] healthy 35-70, depleted 25-35; [1] healthy 40-55, depleted 25. No dominance, no redundancy. Radiation stack (travel 3/leg): [0]'s `radiation: 16` is the batch's second-largest dose and reads correctly for coolant vapor caught at eye level; [1] is physical only, right for a dropped hatch.

[0] Reconstruct the entry code — intention: enter the way the shelter was meant to be entered.
    known cost: none; wits hard (technical) | uncertain risk: `pressures {radiation: 16, health: -5}`
    success: `items {purifier_ampoule: 1, medkit: 1, ration_bar: 2}` | failure: the fields above; the display "calmly requests another authorized attempt"
    local significance: a sealed shelter is open and its stores are not sealed any more.
    durable: none.
[1] Force the maintenance hatch — intention: go around the lock through the shaft.
    known cost: none; strength hard (force) | uncertain risk: `pressures {health: -14}`, `damage_type physical`, `add_conditions [sprain]`
    success: `items {hazmat_wrap: 1, rad_tabs: 1}` | failure: the fields above; the shaft is abandoned
    local significance: the equipment room loses the protection its empty suits no longer need.
    durable: none.

Disposition: revise — the mechanics are sound; the scene borrows two things it should not.
Findings:
P1: the title claims an identity STORY_CANON §6 assigns elsewhere. Bunker Forty-One is entered through `bunker41_rusted_hatch`, a global in this same region 4 writing `b41_contact`, and canon shows it warm, inhabited, breathing — not "dust no living occupant disturbed". The body already keeps the number "half buried beneath black glass", so the title is the only conflict, and titles surface in death summaries and design references → retitle (for example "Buried Shelter") and leave the number unread.
P2: [0]'s success reuses the finale's image — "The door releases a hand's width" — which STORY_CANON §1 and §8 reserve for the Citadel gate → reword.

### glass_shadow — Shadow Without a Body   [events.json+overrides; Glass Wastes (r4); unique=y; weight=3; tags=none] — §5 record 10; CREATURE_STORY_BIBLE, Cinder Giant
Scene: A shadow is burned into the last standing wall; fresh boot prints approach from the west and stop, with no return tracks.
Evidence on screen: prints that "simply stop. No return tracks cross the glass" and "a shallow ravine where reflected heat hides the ground" ([0]); "Leaving asks you to accept a disappearance without adding yourself to it" ([1]).
Comparison: [0] healthy 45-70, depleted 35; [1] certain. No dominance, no redundancy. Radiation stack (travel 3/leg): [0]'s `radiation: 12` for a pocket where "your meter climbs faster than your footsteps" reads correctly and is what the gamble is about.

[0] Search for the missing traveler — intention: find out what happened to the person whose prints stop.
    known cost: none; wits risky (navigation) | uncertain risk: `pressures {radiation: 12, fatigue: 7}`
    success: `items {scout_leathers: 1, clean_water: 1}` | failure: the fields above; the trail proves a loop
    local significance now: a sheltered pack and a note saying its owner turned back | proposed (§5 record 10, bible): the traveler is alive, dust-sick under the mirrored shelf, and success is walking them clear of the Giant's passage; the leathers and water become what they give in return.
    durable: now: none | proposed: `add_flags [cinder_traveler_rescued]` — see §5 record 10 (consumer `rail_survivors`). Items unchanged.
[1] Leave the shadow behind — intention: refuse a disappearance that "wanted company".
    known cost: none; certain | uncertain risk: none
    success (`outcome`): no fields | failure: n/a
    local significance: the prints stay unfinished; the survivor keeps their distance and their meter.
    durable: none.
No appended combat: the Cinder Giant has "no combat, no portrait, no health bar" (bible); the scene stays at two choices.

Disposition: revise — implement record 10's rescue and put the Giant on screen so the rescue has something to be a rescue from.
Findings:
P1: weak opening evidence — only the old burned silhouette appears, so the thing that killed the traveler and now threatens the survivor is absent; the bible requires three escalating warnings plus a giant's fourth (the way back stays visible) → add the fresh pale dust on the sleeve and the shadow crossing the glass with nothing above it to cast it (74 words today; fits 60–90). Without them [0] reads as scavenging a pack.

### glass_meteor — Hot Metal   [events.json+overrides; Glass Wastes (r4); unique=y; weight=3; tags=none]
Scene: A machined, fist-sized object pulses in a crater too new to hold dust, softening the glass beneath it.
Evidence on screen: "Its casing is machined, not stone, and four black vanes have folded around a pulsing central seam" ([0]); "Marking the site and leaving avoids direct exposure" ([1]).
Comparison: [0] healthy 35-70, depleted 25-35; [1] healthy 65-90, depleted 55, the batch's easiest check. No dominance, no redundancy. Radiation stack (travel 3/leg): [0]'s `radiation: 18` is the batch's largest and earns it — a pressurized seam opening toward the face — and [1] carries none, correct because curiosity never becomes contact.

[0] Cool and recover it — intention: get the core out before the heat ruptures it.
    known cost: none; wits hard (technical) | uncertain risk: `pressures {radiation: 18, health: -8}`
    success: `items {scrap_parts: 4, field_scanner: 1}` | failure: the fields above; the crater is abandoned
    local significance: the fallen core is open and carried; the pulse stops.
    durable: none.
[1] Mark the crater and move on — intention: leave a warning instead of taking a prize.
    known cost: none; grit easy (survival) | uncertain risk: `pressures {fatigue: 5}`
    success: no fields — "Nothing enters your pack, and nothing dangerous opens beside your hands" | failure: fatigue only, from circling twice for a better look
    local significance: a scratched warning circle stands outside the crater for whoever comes next.
    durable: none.

Disposition: keep — a clean greed-against-discipline pair whose safe route is genuinely safe (fatigue 5, the batch's mildest failure), with the object left as the mystery STORY_CANON §5 allows.
Findings:
P2: [0]'s failure narrates "burns beneath your clothing and contamination beneath the burns" but applies no `burned` condition → add `burned` or stop naming burns; the region uses that condition elsewhere.

### glass_pilgrim — The Last Pilgrim   [events.json+overrides; Glass Wastes (r4); unique=y; weight=3; tags=none]
Scene: A dying pilgrim offers a stamped prayer disk and asks the survivor to carry it to the Citadel, where someone may still remember the name scratched behind it.
Evidence on screen: "One hand guards a sealed purifier ampoule; the other offers a metal prayer disk stamped with an eastern sun"; "burns shining beneath torn robes"; breathing that "leaves little time for persuasion".
Comparison: [0] healthy 55, depleted 45; [1] certain, gated `requires.items {medkit: 1}`. No dominance, no redundancy. **An ungated choice exists** — [0] is available in every state, so the gate is not a blocked action; [0] is Presence and that kit is unmeasured. Radiation stack (travel 3/leg): [1] is the pool's only relief, `radiation: -8`, nearly three legs' worth.

[0] Accept the burden — intention: take a stranger's last errand honestly.
    known cost: none; presence favorable (social) | uncertain risk: `add_conditions [shaken]` only; the ampoule is destroyed in the fiction but the survivor never held it
    success: `items {purifier_ampoule: 1, scrap_parts: 1}`, `add_flags [pilgrim_disk]` | failure: `add_conditions [shaken]`
    local significance: the pilgrim dies facing east having been believed, or having decided they were lied to again.
    durable: **orphan: `pilgrim_disk`** — no consumer in any data file or `road_ledger.json`. See P0.
[1] Treat their burns instead — intention: spend medicine on the living instead of bargaining with the dying.
    known cost: `requires.items {medkit: 1}`, `costs.items {medkit: 1}`, stated before commitment | uncertain risk: none; certain
    success (`outcome`): `pressures {radiation: -8}`, `add_conditions [inspired]` (presence +2 for two checks, a real reward under §3) | failure: n/a
    local significance: the pilgrim lives long enough to describe a clean route around the hot zone.
    durable: none.

Disposition: revise — the scene's whole promise is a delivery nothing ever receives.
Findings:
P0: lost promised return — the intro asks the survivor to carry the disk "toward the Citadel, where someone may still remember the name scratched behind it", [0] writes `pilgrim_disk`, and nothing reads it → give it one consumer as a conditional success variant on `bunker41_door_closes` choice 2 (Read the names aloud), where §5 record 8 already plans "success variants naming the evidence used": the scratched name is read among the refused. Availability must not change; STORY_CANON §8 and record 8 own what unlocks Witness. Cross-batch: `door_closes` is batch E's card. Fallback if that is declined: retire `pilgrim_disk` and make the ask local.
P2: [0] renders the sacred burden as `items {scrap_parts: 1}` beside the ampoule, so the interface reports the prayer disk as salvage → keep the quantity, name the scrap as the pilgrim's other kit, separately from the disk.

### glass_antenna — Antenna Forest   [events.json+overrides; Glass Wastes (r4); unique=y; weight=3; tags=none]
Scene: Hundreds of antennas rise from the plain humming one note; at the centre the tones change in a way that might be coordinates.
Evidence on screen: "At the field's center, changing tones resemble coordinates hidden inside a warning" ([0]); "Quiet rows along the edge carry weaker current" ([1]).
Comparison: [0] healthy 35-70, depleted 25-35; [1] healthy 45-70, depleted 35. No dominance, no redundancy. Radiation stack (travel 3/leg): [1]'s `radiation: 10` for being thrown onto radioactive glass by a current sheet reads correctly; [0]'s failure is neurological only, which is right.

[0] Map the signal pattern — intention: turn the field's noise into a bearing.
    known cost: none; wits hard (technical) | uncertain risk: `pressures {fatigue: 10}`, `add_conditions [concussed]`
    success: `add_flags [underrail_bearing]`, `pressures {fatigue: -4}` | failure: the fields above; the bearing keeps turning
    local significance: the survivor knows where the Underrail approach converges — "Certainty lightens the next miles", which is what the fatigue relief is.
    durable: **orphan: `underrail_bearing`** — no consumer anywhere. Recommendation: **retire it** and keep the knowledge as prose plus the `fatigue: -4` that already pays for it, the pattern the bible sets for the Salt Colossus ("Knowledge, not a flag, unless N02 names the consumer"). Region entry is not event-gated and no region-5 scene depends on how the survivor arrived. If batch D wants an arrival variant instead, it should claim the flag in its own card; it is not claimed here.
[1] Walk between the quiet rows — intention: cross without learning anything.
    known cost: none; agility risky (navigation) | uncertain risk: `pressures {health: -10, radiation: 10}`
    success: no fields — "its hidden destination neither learned nor needed" | failure: the fields above
    local significance: the field closes behind the survivor, still singing.
    durable: none.

Disposition: revise — retire the orphan; [1]'s unpaid success is correct because its intention is explicitly to learn nothing.
Findings:
P1: orphan `underrail_bearing` → retire it, or batch D names one region-5 consumer. Do not leave it written and unread.

### glass_carcass — Crawler Carcass   [events.json+overrides; Glass Wastes (r4); unique=y; weight=3; tags=none]
Scene: A cargo crawler lies fused belly-down in the glass, hold sealed under buckled plates, driver's hatch open above a glazed ladder.
Evidence on screen: "Its armored hold remains sealed beneath buckled plates" and metal "that still carries impossible strain" ([0]); "The driver's hatch hangs open above a ladder glazed sharp by the flash" ([1]).
Comparison: [0] healthy 40-55, depleted 25; [1] healthy 45-70, depleted 35. No dominance, no redundancy. Radiation stack (travel 3/leg): neither branch adds radiation, correct — both hazards are edges and strain and the crust is never broken.

[0] Cut into the cargo hold — intention: take the bigger prize out of the stressed hull.
    known cost: none; strength hard (salvage) | uncertain risk: `pressures {health: -20}`, `damage_type physical`, `add_conditions [sprain]` — the batch's heaviest single health field
    success: `items {riot_padding: 1, rifle_rounds: 4}` | failure: the fields above; the cargo stays shut
    local significance: the hold is opened plate by plate, or left pinned around its own strain.
    durable: none.
[1] Enter through the driver's hatch — intention: take the smaller, reachable prize.
    known cost: none; agility risky (evade) | uncertain risk: `pressures {health: -10}`, `damage_type physical`, `add_conditions [bleeding]`
    success: `items {clean_water: 2, signal_compass: 1}` | failure: the fields above; the cabin is left intact
    local significance: the cabin is stripped, or bound up and abandoned half-searched.
    durable: none.

Disposition: keep — the intro prices both routes honestly, and armor plus ammunition against water plus a navigation item splits cleanly between builds.
Findings:
P2: [0]'s failure names the mechanic — "above your fresh sprain" → show the limb.

### glass_spring — Warm Spring   [events.json+overrides; Glass Wastes (r4); unique=n; weight=3; tags=none]
Scene: Clear water steams out of a crack in the fused ground inside mineral rings, with no animal tracks near it.
Evidence on screen: white, green and warning-yellow rings and "an old test strip container lies open nearby with two strips remaining" ([0]); warmth "available to loosen exhausted muscles" ([1]).
Comparison: [0] healthy 45-70, depleted 35; [1] healthy 65-90, depleted 55. No dominance, no redundancy. Radiation stack (travel 3/leg): `radiation: 14` for drinking what tested clean between pulses and `radiation: 5` for lingering by exposed glass are proportioned correctly to each other and to the leg cost; the small dose is the right price for a repeatable safe route.

[0] Test and collect the water — intention: turn a hot spring into carried water.
    known cost: none; wits risky (radiation) | uncertain risk: `pressures {radiation: 14}`
    success: `items {clean_water: 2}`, `pressures {fatigue: -5}` | failure: the bottles are discarded, the dose is not
    local significance: two strips spent; the spring is a water source or a lesson.
    durable: none.
[1] Use the warmth without drinking — intention: take the rest and none of the risk.
    known cost: none; grit easy (survival) | uncertain risk: `pressures {radiation: 5}`
    success: `pressures {fatigue: -10}`, twice [0]'s relief | failure: the smaller dose above
    local significance: the survivor leaves standing and ready with empty bottles.
    durable: none.

Disposition: keep — restraint is rewarded with more relief than greed, greed adds water, and both failures are radiation the region has been teaching the player to read.
Findings: none.

### glass_ruins — City of Reflections   [events.json+overrides; Glass Wastes (r4); unique=n; weight=4; tags=none]
Scene: Fused building shells multiply the survivor into a crowd walking half a step out of time, and every straight street may be a returned reflection.
Evidence on screen: "The broken sun remains visible in fragments above the roofline, offering direction if you can distinguish sky from reflection" ([0]); shadowed passages whose "shelves of glass have cracked under decades of tension" ([1]).
Comparison: [0] healthy 45-70, depleted 35; [1] healthy 45-70, depleted 35. No dominance, no redundancy; the split is which stat the survivor invested in. Radiation stack (travel 3/leg): neither failure adds radiation, defensible because the survivor stays clothed, upright, and moving in both branches — the reading `glass_storm` fails.

[0] Navigate by the broken sun — intention: get out by reading the sky, not the streets.
    known cost: none; wits risky (navigation) | uncertain risk: `pressures {fatigue: 14, hunger: 6}` — the applier converts any positive `hunger` to satiety −1
    success: no fields; "the real road opens east" | failure: the fields above, after the same intersection three times
    local significance: the false streets are named and left, or the hours are gone.
    durable: none.
[1] Move only through shadow — intention: spend the crossing where the glass is cool.
    known cost: `pressures {fatigue: 3}` on success | uncertain risk: `pressures {health: -12}`, `damage_type physical`, `add_conditions [bleeding]`
    success: `pressures {fatigue: 3}` | failure: the fields above; the survivor finishes in the sunlight the route avoided
    local significance: the route bends but never doubles back, or a suspended shelf comes down behind you.
    durable: none.

Disposition: keep — a repeatable travel hazard where neither success is meant to pay in supplies and the two failures cost genuinely different things.
Findings:
P2: [1]'s success claims a benefit its fields spend — "preserving precious strength" while adding `pressures {fatigue: 3}` → word it as costing less than the bright avenues would have, or drop the fatigue.

## Batch summary

DISPOSITIONS:
industrial_drones | revise | evade route pays nothing on a repeatable scene while risking a permanent condition; stays sighting-only, no combat added
industrial_generator | keep | repair against theft, priced per kit and honestly paid
industrial_scavs | revise | choice 0's failure is item-loss only and can resolve empty
industrial_conveyor | keep | the harder route's premium is the game's highest-rated armor
industrial_office | revise | appended choices 2-3 have no evidence in the introduction and 0 and 2 solve the same puzzle
industrial_fire | revise | the promised preserved dock pays one scrap for the scene's worst failure
industrial_tank | revise | append choice 2 per §5 record 9 and the creature bible; retire rescued_engineer
industrial_crane | revise | the unpaid dash carries the scene's only injury risk
industrial_locker | revise | appended choices 2-3 have no evidence and borrow choice 0's action
industrial_alarm | keep | honest hazard crossing with differently priced failures and a hard route for Wits
glass_cult | revise | the hardest check in the batch is also the least rewarded
glass_storm | revise | the Grit route is worse on both branches at equal odds
glass_bunker | revise | the title claims Bunker Forty-One and the success borrows the Citadel gate's image
glass_shadow | revise | implement §5 record 10's rescue and put the Cinder Giant's evidence on screen
glass_meteor | keep | clean greed-against-discipline pair with a genuinely safe safe route
glass_pilgrim | revise | the disk the scene is built on is never delivered anywhere
glass_antenna | revise | underrail_bearing is written and never read
glass_carcass | keep | two honestly priced salvage routes split between builds
glass_spring | keep | restraint pays more relief than greed, and both doses read correctly
glass_ruins | keep | repeatable travel hazard with two genuinely different failures

FINDINGS:
P0 | glass_pilgrim | 0 | the introduction promises the disk will be carried to the Citadel and pilgrim_disk has no consumer anywhere → add a conditional success variant on bunker41_door_closes choice 2 (per §5 record 8) reading the scratched name among the refused, with no change to Witness availability; fallback is to retire the flag and make the ask local
P1 | industrial_drones | 1 | success writes no field while its failure matches choice 0's severity → add add_conditions ["steady_hands"] to choice 1 success
P1 | industrial_scavs | 0 | failure is items {medkit: -1, rad_tabs: -1} only and resolves empty for a survivor carrying neither → add pressures {fatigue: 8} to the failure
P1 | industrial_office | - | the introduction never shows the gun cabinet or the emergency kit, so appended choices 2 and 3 have no opening evidence → add one clause each to the body (67 words today)
P1 | industrial_fire | 0 | the intro promises a preserved dock and success pays items {scrap_parts: 1} for the scene's worst failure → proposed items {scrap_parts: 1, purifier_ampoule: 1}
P1 | industrial_tank | 0 | orphan flag rescued_engineer with no consumer, and the engineer leaves westward so rail_survivors would be false history → retire the flag, keep the rescue in the passage
P1 | industrial_tank | 2 | choice 1 already reaches both of the appended fight's rewards at 55-90 healthy → N05 must set enemy_kilnback's xp_reward high enough to pay for the death risk (adversary not yet defined in data/adversaries.json)
P1 | industrial_crane | 0 | success writes no field while risking health -18 and permanent concussed against choice 1's fatigue 8 → add add_conditions ["steady_hands"] to choice 0 success
P1 | industrial_locker | - | the introduction shows only the unmarked locker, so appended choices 2 and 3 have no evidence and narrate choice 0's action → name the security cabinet and the bolted rig in the body (74 words today) and let each passage open its own object
P1 | glass_cult | 0 | 35 healthy / 25 depleted, the hardest check in the batch, pays rad_tabs 2 while the fight pays 62 XP and two consumables → proposed items {rad_tabs: 2, glow_moss: 1}, difficulty unchanged
P1 | glass_storm | 1 | choice 1 pays nothing on success and adds no condition on failure while choice 0 costs fatigue 8 and adds bleeding, at tied odds → add pressures {fatigue: 4} to choice 1 success, the wait its own passage describes
P1 | glass_bunker | - | the title asserts Bunker 41, which STORY_CANON §6 and bunker41_rusted_hatch (same region, writes b41_contact) show inhabited and warm, while the body deliberately leaves the number buried → retitle and leave the number unread
P1 | glass_shadow | 0 | the Cinder Giant never appears in the introduction, so record 10's rescue has no visible hazard and the bible's warning sequence is unmet → add the fresh pale dust and the travelling shadow with nothing above it (74 words today)
P1 | glass_antenna | 0 | orphan flag underrail_bearing with no consumer; the fatigue -4 already pays for the knowledge → retire it, or batch D names one region-5 consumer
P2 | industrial_drones | - | event-level adversary_id drone_swarm is unreachable inert data with no combat choice → drop the field or record it as deliberate
P2 | industrial_generator | 1 | failure names the mechanic, "a sprain's bright warning" → describe the joint instead
P2 | industrial_office | 2 | choices 0 and 2 both solve by reading a date off the personnel board → give choice 2 its own evidence, not the worn dial industrial_locker already uses
P2 | industrial_fire | 1 | failure says "concussed and depleted", two status words in a row → show the symptoms
P2 | glass_storm | 0 | failure embeds irradiated glass dust in skin and lungs and adds radiation 0, less than the 3 the region charges to walk the leg → give the failure a small radiation value
P2 | glass_bunker | 0 | success reuses the Citadel gate's signature image, "releases a hand's width" (STORY_CANON §1, §8) → reword
P2 | glass_meteor | 0 | failure narrates "burns beneath your clothing" but applies no burned condition → add burned or stop naming burns
P2 | glass_pilgrim | 0 | the prayer disk is itemized as items {scrap_parts: 1}, so the interface reports the burden as salvage → name the scrap as the pilgrim's other kit, separately from the disk
P2 | glass_carcass | 0 | failure names the mechanic, "above your fresh sprain" → show the limb
P2 | glass_ruins | 1 | success claims "preserving precious strength" while adding pressures {fatigue: 3} → reword or drop the fatigue
