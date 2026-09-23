# Consequence cards — Batch A: Shattered Outskirts and globals

Batch A of the card set indexed in [NARRATIVE_CONSEQUENCE_MAP.md](../NARRATIVE_CONSEQUENCE_MAP.md) §4: the ten
`shattered_outskirts` pool events, the twelve baseline globals, and `fallback_dust`. Cards use the §2 template.

Sources. Prose is the text that actually loads: `data/events.json` with `data/narrative_overrides_v1.json` and
`data/narrative_overrides_v11.json` applied in that order. Mechanical fields are quoted from the JSON exactly. The
outcomes patched by `data/living_road_events.json` `source_flag_patches` (`outskirts_child_radio`,
`outskirts_siren`, `outskirts_bandits`) are treated as present, because this batch is written for the expanded
configuration. `Comparison:` lines quote `builds/choice_comparison.md` and never estimate. Canon is quoted by
section number from [STORY_CANON.md](../STORY_CANON.md); the creature entry is
[CREATURE_STORY_BIBLE.md](../CREATURE_STORY_BIBLE.md) "Shutter Skitters".

Two measurement caveats apply throughout and are not repeated in every card. The Presence kit is not measured
(§3), so cards on Presence checks note the gap instead of guessing. And the tool lists an item gate only when no
measured state holds the item: `outskirts_dogs` 1, `global_stranger` 0 and 1 read as ungated in
`builds/choice_comparison.json` (`gated_by: []`) purely because every kit starts with `canned_meat`,
`clean_water`, and `cloth_bandage`. The comparison header's "0 are blocked in at least one state" must be read
that way.

---

### outskirts_bandits — Ambush at the Pharmacy   [data/events.json; Shattered Outskirts; unique=n; weight=5; tags=none; adversary_id=road_bandits]
Scene: three survivors of a robbed pharmacy spread across a doorway and watch the survivor's pack, not their face.
Evidence on screen: the archer settling at the broken window (fight); the alley the limping man guards (evade); the boy trying to look steady and the empty cure cartons (the plague bluff).
Comparison: [0] fight T12 +24xp flee:y; [1] 55–80 healthy / 45 depleted (Agility kit 80); [2] 45 / 35, identical across all four measured kits, Presence kit unmeasured; no dominance flag.

[0] Rush their leader — intention: end the ambush by taking the archer before she settles her aim.
    known cost: combat with `road_bandits`, threat 12, enemy damage 35–55, flee favorable | uncertain risk: no `defeat` branch exists; losing the fight is death, critical condition `bleeding`
    success: `victory` items {canned_meat 1, scrap_parts 1} + add_flags [lr_bandit_leader_killed]; `critical_victory` items {pipe_pistol 1, pistol_rounds 4} + add_flags [lr_bandit_leader_disarmed] | failure: none authored; fleeing resolves nothing and writes no flag
    local significance: the leader is dead or disarmed and the pharmacy corner is passable; the other two scatter.
    durable: see §5 record 3 (Lio Marr's Road Debt) → `lr_pharmacy_witness` eligibility, region 1.
[1] Break through the alley — intention: leave without a fight, on foot speed.
    known cost: Agility favorable (evade) | uncertain risk: failure damage_type physical, pressures {health −12, fatigue 8}, add_flags [lr_bandits_wounded_escape]
    success: pressures {fatigue 4} + add_flags [lr_bandits_escaped] | failure: as above
    local significance: nobody dies; the gang keeps the pharmacy and its account of the stranger.
    durable: see §5 record 3.
[2] Convince them you carry plague — intention: buy passage with fear instead of blood or speed.
    known cost: Presence risky (social) | uncertain risk: failure items {canned_meat −1}, pressures {fatigue 3}, add_flags [lr_bandits_paid]
    success: no items and no pressures; add_flags [lr_bandits_bluffed] | failure: as above
    local significance: the gang believes a lie and remembers it; the boy repeats the symptoms as a joke.
    durable: see §5 record 3.
Note on [2]: worse odds than [1], but no fatigue on success and a far softer failure (a can, not 12 HP). That is a real trade, not a dominated sibling, and the tool flags no dominance here. §5 record 3 fixes "cost / reward: as authored", so no reward change is proposed.

Disposition: keep — three distinct intentions, all six histories feed record 3, and the fight is a region-0 forced-combat candidate.
Findings:
P1: `unique=false` lets one run resolve this scene twice and write two contradicting `lr_bandit*` flags; §5 record 3's `pharmacy_witness` introduction variants state no precedence → N04 fixes first-match order killed > disarmed > wounded_escape > paid > bluffed > escaped.
P1: [2] failure's `canned_meat −1` silently no-ops for a survivor holding no can (`_change_item`, game_engine.gd:1409) while the outcome text and the result line both assert the payment → N04 suppresses the result line for a no-op item delta; the field stands.

---

### outskirts_bus — The Sealed Bus   [data/events.json; Shattered Outskirts; unique=y; weight=4; tags=supply_opportunity, opening_safe, opening_resource]
Scene: an evacuation bus wired shut from inside, family photographs pressed into the door seal, one circle wiped clean at a child's height.
Evidence on screen: melted tires and wire-crossed rear doors (force); torn wall panels over the release cable (technical); rainwater under the chassis carrying the smell of sealed food (either route).
Comparison: [0] 60–75 healthy / 45 depleted (Strength kit 75); [1] 55–90 / 45–55 (Wits kit 90); no dominance flag — each kit's own stat wins its route.

[0] Pry the door apart — intention: open the bus with body weight before anything else reaches it.
    known cost: Strength favorable (force) | uncertain risk: failure damage_type physical, pressures {health −10, fatigue 6}, add_conditions [sprain]
    success: items {ration_bar 2, clean_water 1} | failure: as above; the doors stay crossed by wire
    local significance: the seal is broken and the photographs go with it.
    durable: none.
[1] Trace the emergency release — intention: open it the way the bus was built to open.
    known cost: Wits favorable (technical) | uncertain risk: failure pressures {radiation 6, health −5}
    success: items {cloth_bandage 2, scrap_parts 1} | failure: as above; the battery vents and the doors stay shut
    local significance: the doors fold inward without disturbing the photographs.
    durable: none.

Disposition: revise — the plan §6 defect stands: food versus medicine is decided before the player can see which door does which.
Findings:
P1: the introduction gives no evidence tying either method to its reward, so the food/medicine split is invisible at commitment (plan §6) → the body names what the wiped circle shows (ration shapes under the driver's seat) and the first-aid bracket beside the release cable; items, checks, tags, and weight unchanged.

---

### outskirts_dogs — The Concrete Pack   [data/events.json; Shattered Outskirts; unique=n; weight=5; tags=none; adversary_id=feral_dogs]
Scene: six silent dogs hold a hunting line across the lane, two still trailing blue leashes.
Evidence on screen: the concrete divider the largest dog tests from (climb); the blanket nest and their visible hunger (food); the formation itself (fight).
Comparison: [0] fight T11 +22xp flee:y; [1] certain; [2] 55–80 healthy / 45 depleted (Agility kit 80); no dominance flag.

[0] Stand and fight — intention: break the pack rather than yield the lane.
    known cost: combat with `feral_dogs`, threat 11, enemy damage 22–36, flee favorable | uncertain risk: no `defeat` branch; losing is death, critical condition `bleeding`
    success: `victory` items {scrap_parts 1} | failure: none authored; fleeing writes nothing
    local significance: the pack retrieves its wounded and abandons the lane.
    durable: none.
[1] Throw them food — intention: spend food so neither side has to test the other.
    known cost: declared and previewed — `requires.items {canned_meat 1}` and `costs.items {canned_meat 1}` | uncertain risk: none; certain outcome
    success: `outcome` text only; no items, pressures, conditions, or flags | failure: n/a
    local significance: the survivor passes close enough to read old names on the collars; the pack keeps the nest.
    durable: none.
[2] Climb the divider — intention: put concrete between the teeth and the ankles.
    known cost: Agility favorable (evade) | uncertain risk: failure pressures {health −6, fatigue 8}, add_conditions [sprain]
    success: no fields; the crossing is the reward | failure: as above
    local significance: the lane stays theirs; the survivor is past it.
    durable: none.

Disposition: keep — three intentions, an honestly declared item price on [1], and no dominance.
Findings: none. ([1] is the model this batch's other item costs should follow: the price sits in `requires`/`costs`, so the preview shows it and a survivor without a can sees one locked choice beside two ungated ones.)

---

### outskirts_market — Market Under Tarps   [data/events.json; Shattered Outskirts; unique=y; weight=3; tags=opening_safe, opening_equipment]
Scene: twelve traders under advertising tarps price what the survivor knows as carefully as what they carry.
Evidence on screen: the mask-maker listening while she stitches (social); cracked toys and a pulsing indicator on a salvage table (salvage); the woodpile and the water hauling behind two stalls (the two work routes).
Comparison: [0] 55 healthy / 45 depleted, flat across the measured kits, Presence kit unmeasured; [1] 45–70 / 35; [2] and [3] certain; no dominance flag.

[0] Trade stories for medicine — intention: convert road knowledge into treatment.
    known cost: Presence favorable (social) | uncertain risk: failure items {clean_water 1, scrap_parts −1}
    success: items {cloth_bandage 2, rad_tabs 1} | failure: as above; merchants move their best stock away from the road just described
    local significance: the market's picture of the eastern underpass is now the survivor's account.
    durable: none.
[1] Spot the undervalued salvage — intention: buy a working instrument from someone who thinks it is a toy.
    known cost: Wits risky (salvage) | uncertain risk: failure items {scrap_parts −1}
    success: items {field_scanner 1} | failure: as above; the casing collapses and the seller has moved on
    local significance: a diagnostic tool leaves the market, or the survivor's scrap does.
    durable: none.
[2] Earn the Rusted Hatchet — APPENDED by M05 (`docs/CONTENT_AUTHORING.md` allowlist). Intention: pay for a weapon with an afternoon instead of salvage.
    known cost: certain; `pressures {fatigue 6}` and the unsold scrap | uncertain risk: none
    success: `outcome` items {rusted_hatchet 1}, pressures {fatigue 6} | failure: n/a
    local significance: the mask-maker gets her firewood and keeps a customer instead of a story.
    durable: none.
[3] Earn the Nail Bat — APPENDED by M05. Intention: the same trade with the boy on the scale, for a different weapon.
    known cost: certain; `pressures {fatigue 6}` | uncertain risk: none
    success: `outcome` items {nail_bat 1}, pressures {fatigue 6} | failure: n/a
    local significance: a bat kept behind a stall for a night nobody wants changes hands.
    durable: none.

Disposition: keep — the event is at the four-choice maximum, the two appended equipment routes are allowlisted and mutually exclusive within a unique event, and the checked pair keeps distinct intentions.
Findings:
P1: [0] failure's `scrap_parts −1` and [1] failure's `scrap_parts −1` no-op for a survivor with no scrap while both outcome texts assert the payment and the result line prints the loss (game_engine.gd:1409 and 1329) → N04 suppresses the result line for a no-op item delta; fields unchanged.

---

### outskirts_overpass — Broken Overpass   [data/events.json; Shattered Outskirts; unique=n; weight=4; tags=none]
Scene: the overpass has lost a span above a rail cutting; a school bus hangs from the far edge and a drainage channel runs east below it.
Evidence on screen: reinforcement bars polished by wind and the hanging bus (the beams); the channel curving east and the smell of stagnant runoff (the detour).
Comparison: [0] 45–70 healthy / 35 depleted; [1] 65–90 / 55 (Grit kit 90); no dominance flag.

[0] Cross the exposed beams — intention: keep the hours the detour would cost.
    known cost: Agility risky (evade) | uncertain risk: failure damage_type physical, pressures {health −12, fatigue 10}, add_conditions [sprain]
    success: no fields; the crossing costs nothing | failure: as above
    local significance: the survivor is across with daylight left; the bus settles and stays.
    durable: none.
[1] Take the drainage detour — intention: trade height for enclosure.
    known cost: Grit easy (survival); success itself charges pressures {fatigue 7, hunger 4} | uncertain risk: failure pressures {fatigue 15, hunger 7}
    success: pressures {fatigue 7, hunger 4} | failure: as above
    local significance: the survivor emerges beyond the cutting carrying the channel's smell.
    durable: none.

Disposition: revise — the introduction promises something in the channel that neither branch delivers.
Findings:
P1: "whatever has collected where the city once sent its rain" sets up a find and both branches are pure fatigue and hunger → cut the promise from the body (preferred; no mechanical change), or pay it: `now: [1] success pressures {fatigue 7, hunger 4} | proposed: [1] success pressures {fatigue 7, hunger 4} + items {scrap_parts 1}`.

---

### outskirts_apartment — Curtain in the Window   [data/events.json; Shattered Outskirts; unique=y; weight=3; tags=none]
Scene: a curtain still breathes behind the only intact glass on a burned third floor, and a cupboard above taps twice, pauses, then taps again.
Evidence on screen: the intact lower glass and the folded towels the search reaches (salvage); fresh chalk beside the entrance warning against the stairs (leave); the tapping whose rhythm changes when the survivor moves, shed plates on the landing like broken roofing slate, and the street still audible behind the stairwell door (the colony — CREATURE_STORY_BIBLE "Shutter Skitters", warnings in threes).
Comparison: [0] 45–70 healthy / 35 depleted; [1] certain; no dominance flag. [2] is unmeasured: it does not exist yet.

[0] Search the occupied floor — intention: reach the household's provisions past a rotten stair.
    known cost: Wits risky (salvage) | uncertain risk: failure damage_type physical, pressures {health −14}, add_conditions [concussed]
    success: items {medkit 1, canned_meat 1} | failure: as above; the stair is gone and the floor is not searched
    local significance: the cache is taken or the building keeps it; the curtain is explained as a latch, not a person.
    durable: none.
[1] Respect the warning and leave — intention: accept that someone who knew the building wrote the chalk.
    known cost: certain; the cache is left | uncertain risk: none
    success: `outcome` text only; no items, pressures, conditions, or flags | failure: n/a
    local significance: the warning stands for the next traveler; the tapping continues.
    durable: none.
[2] Drive the colony out of the stairwell — APPENDED, per CREATURE_STORY_BIBLE "Shutter Skitters". Intention: make the building safe instead of gambling on it.
    known cost: combat with `enemy_skitters`, choice field `can_flee: true`; the bible's "flee easy" is the adversary's `combat.flee_difficulty: "easy"`. Threat and `xp_reward` are N05's to set with the profile (bible: threat low, HP near Feral Dogs' 120, damage lowest of the four creatures, critical condition `infection`) | uncertain risk: no `defeat` branch; losing is death
    success: proposed `victory` items {medkit 1, canned_meat 1}, pressures {fatigue 8}; no `add_flags`, no `next_event`, no `lethal`, no `victory: true` | failure: none authored; fleeing writes nothing
    local significance: the colony goes back into the wall cavities and the cache is reached without the stair; the building reads as a place a survivor could re-enter.
    durable: none — the bible allows a `marsh_hut` echo only "if no consumer is named, no flag is written", and no card in this batch names one, so choice 2 writes nothing.
    non-dominance: the items equal [0]'s success exactly, but the fight adds `pressures {fatigue 8}` on top of combat damage and the `infection` critical, so the reward rule's pressure clause fails; [0] stays the no-fight route and [1] stays the free exit.
    `enemy_skitters` is **not** in `data/adversaries.json` today (13 ids: road_bandits, feral_dogs, ash_stalkers, toll_gang, marsh_leeches, bog_raiders, drone_swarm, vault_scavs, glass_cult, tunnel_hunters, citadel_guard, warden_machine, mutant_crows). `ContentRepository.validate_all` rejects a combat choice whose adversary is missing (content_repository.gd:446–448) and requires `xp_reward` 1–100, a `portrait_id`, a displayed weapon, a `flee_difficulty`, and a defined critical condition, so N05's profile must land before N03 appends this choice.

Disposition: revise — append choice 2 as specified; choices 0 and 1 keep their indices, labels, checks, and outcomes.
Findings:
P2: appending a combat choice makes `outskirts_apartment` combat-carrying, so it joins `outskirts_bandits` and `outskirts_dogs` in region 0's forced-combat slot and the two-per-region combat cap (`_select_next_event`, game_engine.gd:1097–1130) → N05 re-checks region 0 pacing with three combat events in a ten-event pool.

---

### outskirts_siren — The Siren Tower   [data/events.json; Shattered Outskirts; unique=y; weight=3; tags=none]
Scene: a civil-defense siren coughs half a warning across the district with every turn, telling every listener that movement has returned.
Evidence on screen: an exposed but intact ladder and faded instructions naming the motor cutoff (climb); doors opening down the avenue where no wind reaches them (walk).
Comparison: [0] 45–80 healthy / 35–45 depleted (Wits kit 80); [1] 55–80 / 45 (Grit kit 80); no dominance flag.

[0] Climb and disable it — intention: take the sound away from whoever is coming.
    known cost: Wits risky (technical) | uncertain risk: failure pressures {health −10, fatigue 8}, add_conditions [shaken], add_flags [lr_siren_burned]
    success: items {scrap_parts 2}, add_flags [silenced_siren, lr_siren_silenced] | failure: as above
    local significance: the rotor stops while the shapes are still streets away, and the charge pack leaves with the survivor.
    durable: see §5 record 2 (Dena Orr's Quiet Column) → `lr_quiet_column` eligibility, region 1. `silenced_siren` has no consumer in any data file (single occurrence, data/events.json:390) — **orphan**, retired by record 2.
[1] Outwalk the noise — intention: refuse the tower's problem and spend distance instead.
    known cost: Grit favorable (survival); success still charges pressures {fatigue 6} | uncertain risk: failure pressures {fatigue 12}, add_conditions [shaken], add_flags [lr_siren_followed]
    success: pressures {fatigue 6}, add_flags [lr_siren_endured] | failure: as above
    local significance: the tower keeps calling and the gathering shapes choose it instead of the survivor's trail.
    durable: see §5 record 2.

Disposition: revise — drop the orphan `silenced_siren` from [0] success per §5 record 2; the four `lr_siren_*` flags carry the thread and nothing else changes.
Findings:
P1: `silenced_siren` is written and never read → retire it (§5 record 2 already assigns this).
Hand-off, not a finding here: record 2's proposed `lr_quiet_column` choice 3 costs `scrap_parts 1`, which a survivor who silenced the tower may already have spent, so that choice needs a `requires.reason` lock label rather than reading as a promise the run cannot keep. Batch F owns the card.

---

### outskirts_cache — Municipal Cache   [data/events.json; Shattered Outskirts; unique=y; weight=3; tags=opening_safe, opening_resource]
Scene: a bolted civil-defense locker under courthouse stairs, its four-language instructions burned unevenly, smelling of dry paper rather than rot.
Evidence on screen: a thick lock old enough to break unpredictably (force); the four versions whose missing lines survive in each other (technical); a buckler hanging on an outside hook (certain).
Comparison: [0] 50–65 healthy / 35 depleted (Strength kit 65); [1] 45–80 / 35–45 (Wits kit 80); [2] certain; no dominance flag.

[0] Break the lock — intention: take the supplies now and accept the bracket.
    known cost: Strength risky (force) | uncertain risk: failure damage_type physical, pressures {health −8}, add_conditions [bleeding]
    success: items {clean_water 2, ration_bar 2} | failure: as above; the locker stays sealed
    local significance: the door is scarred open, or the survivor is cut and it is not.
    durable: none.
[1] Decode the faded instructions — intention: open it without damaging it.
    known cost: Wits risky (technical) | uncertain risk: failure has no mechanical fields; an internal bolt crosses the mechanism and the locker can never be opened
    success: items {rad_tabs 2, cloth_bandage 1} | failure: nothing lost but the contents
    local significance: medicine either travels east or stays sealed for good.
    durable: none.
[2] Take the hanging buckler — intention: take the guaranteed guard and leave the food and medicine for someone else.
    known cost: certain; the locker is left unopened | uncertain risk: none
    success: `outcome` items {scrap_buckler 1} | failure: n/a
    local significance: the cache survives the survivor's visit intact.
    durable: none.

Disposition: keep — force pays food and water, technical pays medicine, the certain route buys equipment against both, and each kit's own stat wins its route (Strength 65 on [0], Wits 80 on [1]).
Findings: none. (The Grit kit already starts with a `scrap_buckler`, so [2] can hand it a second one; harmless duplication, no change proposed.)

---

### outskirts_child_radio — Voice on Channel Nine   [data/events.json; Shattered Outskirts; unique=y; weight=2; tags=opening_safe, opening_equipment]
Scene: a handheld radio on a traffic-light cable repeats a child's message asking for Talia, with faint breathing between repetitions.
Evidence on screen: the live carrier under the recording (answer); rooftops, power lines, and several possible origins for the signal (triangulate).
Comparison: [0] 55 healthy / 45 depleted, flat across the measured kits, Presence kit unmeasured; [1] 45–70 / 35; no dominance flag.

[0] Answer with calm instructions — intention: guide the family with landmarks they can confirm.
    known cost: Presence favorable (social); answering also tells every receiver nearby that someone useful is listening | uncertain risk: failure add_conditions [shaken], add_flags [lr_channel_misled]
    success: add_conditions [inspired], add_flags [helped_family, lr_channel_helped] | failure: as above; only the recording completes
    local significance: Talia Vale has heard a living voice and one set of landmarks, or nobody answered a recording. Inspired (Presence +2) is a real reward; the tool scores beneficial conditions as nothing (§3).
    durable: see §5 record 1 (Channel Nine) → `lr_blue_van` eligibility, region 1. `helped_family` has no consumer in any data file (single occurrence, data/events.json:518) — **orphan**, retired by record 1.
[1] Triangulate the signal — intention: find the transmitter rather than talk to it.
    known cost: Wits risky (navigation) | uncertain risk: failure pressures {fatigue 8}, add_flags [lr_channel_lost]
    success: items {signal_compass 1, scrap_parts 1}, add_flags [lr_channel_traced] | failure: as above; the bearing cannot be isolated here
    local significance: the survivor holds the relay kit and the bearing the message was meant to follow, and has never spoken to the family.
    durable: see §5 record 1.

Disposition: revise — drop the orphan `helped_family` from [0] success per §5 record 1; the four `lr_channel_*` flags carry the thread and nothing else changes.
Findings:
P1: `helped_family` is written and never read → retire it (§5 record 1 already assigns this).

---

### outskirts_sinkhole — Street Without a Bottom   [data/events.json; Shattered Outskirts; unique=n; weight=3; tags=none]
Scene: an intersection has folded into the utility tunnels, leaving a narrow lip east and a maintenance shelf visible below.
Evidence on screen: the narrow lip where roots still bind the asphalt (leap); a bolted ladder and the shelf under broken pipe (rope).
Comparison: [0] 45–70 healthy / 35 depleted (str 45, agi 70, wit 50, gri 45 healthy); [1] 65–90 / 55 (str 70, agi 70, wit 90, gri 65 healthy). Gated: [1] `requires.items {climbing_rope 1}`. The tool reports no dominance only because it counts that requirement as a greater known cost.

[0] Leap the narrow edge — intention: cross now, without equipment.
    known cost: Agility risky (evade) | uncertain risk: failure damage_type physical, pressures {health −15, fatigue 8}, add_conditions [sprain]
    success: no fields | failure: as above
    local significance: the street is crossed and nothing below is disturbed.
    durable: none.
[1] Descend with rope — intention: reach the maintenance shelf the ladder no longer serves.
    known cost: `requires.items {climbing_rope 1}` — a gate, not a cost: there is no `costs` block, so the rope is kept; Wits easy (salvage) | uncertain risk: failure pressures {fatigue 6}
    success: items {scrap_parts 2, clean_water 1} | failure: as above; the tools scatter into black water
    local significance: the shelf is emptied or lost; either way nothing below learns more than the rhythm of the survivor's breathing.
    durable: none. `climbing_rope`'s only baseline source is `global_drop` 1 success (M05 note, `docs/CONTENT_AUTHORING.md`), so this route is an earlier success being spent.

Disposition: revise — the leap needs the premium it actually earns so the rope route reads as preparation rather than a better button.
Findings:
P1: with the rope in the pack, [1] equals or beats [0] in every measured cell (70/45, 70/70, 90/50, 65/45 healthy; 55/35 depleted), pays items where [0] pays nothing, and fails for fatigue 6 against 15 HP and a sprain → `now: [0] success (no fields) | proposed: [0] success pressures {fatigue −4}`, with one clause of success prose for the descent and climb not made. Keep the gate; keep the rope uncosted.

---

### global_trader — Wandering Trader   [data/events.json; global; unique=n; weight=2; tags=none]
Scene: a trader stops beyond grabbing distance behind a one-wheeled cart and sets a stone on the road to mark neutral ground.
Evidence on screen: modest but real stock and a scale with a counterweight (trade); the trader's route and practiced patience (news).
Comparison: [0] 55 healthy / 45 depleted; [1] 65 / 55; flat across the measured kits, Presence kit unmeasured; no dominance flag.

[0] Trade salvage for supplies — intention: convert scrap into food and dressings on the trader's own terms.
    known cost: Presence favorable (social). The scrap price is **not** declared: it sits inside both outcome branches as `items {scrap_parts −1}`, so the preview shows no cost | uncertain risk: failure items {scrap_parts −1, ration_bar 1}
    success: items {scrap_parts −1, canned_meat 1, cloth_bandage 1} | failure: as above; the parts buy one ration bar
    local significance: both packs close; the trader has weighed what the survivor knows as well as what they carry.
    durable: none.
[1] Ask only for road news — intention: take information and keep the salvage.
    known cost: Presence easy (social) | uncertain risk: failure pressures {fatigue 3}
    success: add_conditions [focused] | failure: as above; every correction contradicts the last
    local significance: the survivor carries a pattern (birds lifting before armed travelers arrive) instead of an object. Focused (Wits +2) is a real reward (§3).
    durable: none.

Disposition: revise — the trade's price must be shown before commitment and must actually be paid.
Findings:
P0: [0] charges `scrap_parts −1` inside the outcome, so the price is invisible in the preview and silently free for a survivor holding no scrap, while the result line still prints "Scrap Parts -1" (game_engine.gd:1409 and 1329) → `now: success items {scrap_parts −1, canned_meat 1, cloth_bandage 1}; failure items {scrap_parts −1, ration_bar 1} | proposed: choice 0 gains requires.items {scrap_parts 1} and costs.items {scrap_parts 1}; success items {canned_meat 1, cloth_bandage 1}; failure items {ration_bar 1}`. [1] stays ungated, so no blocked action is created, and the engine's own "Requires Scrap Parts" lock label carries the refusal.
P1: `trader_token` is granted exactly once in all content (`global_stranger` 0 success) and by the Presence starting kit, and no event, eligibility, or ledger entry reads it — searched `data/events.json`, `data/bunker41_events.json`, `data/rustsea_events.json`, `data/living_road_events.json`, `data/road_ledger.json`. The trader who would recognize a market seal never asks for one. This is an orphan-shaped **item**, not a flag → record it as equipment-only (an accessory worth social +2 / presence +1, which does raise both of this event's checks when equipped) and expect no scene to read it, or give it a reader in the batch that owns a market or toll scene. No new choice is proposed here: §2 allows a new index only for a §5 record, the creature bible, or a P0 blocked action, and none applies.

---

### global_acid_rain — Acid Rain   [data/events.json; global; unique=n; weight=3; tags=none]
Scene: a yellow-edged cloud opens over the road and the first drops pit a sign; broken panels nearby could be a roof.
Evidence on screen: the panels and the way their seams would drain (shelter); the open eastern road and a short, fast-moving shower (keep moving).
Comparison: [0] 55–80 healthy / 45 depleted (Wits kit 80); [1] 45–70 / 35 (Grit kit 70); no dominance flag — the Grit kit's own route beats the shelter for that kit.

[0] Build a quick shelter — intention: let the shower pass over a roof.
    known cost: Wits favorable (survival); success still charges pressures {fatigue 4} | uncertain risk: failure pressures {health −10, fatigue 8}, add_conditions [burned]
    success: pressures {fatigue 4} | failure: as above; the shelter collapses behind the survivor
    local significance: skin and gear survive the shower, or the lowest seam ran inward.
    durable: none.
[1] Keep moving — intention: outpace a small cloud instead of building against it.
    known cost: Grit risky (survival); success still charges pressures {fatigue 8} | uncertain risk: failure pressures {health −12, fatigue 12}
    success: pressures {fatigue 8} | failure: as above
    local significance: distance is gained and the rain either reached skin or did not.
    durable: none.

Disposition: keep — a weather scene whose branches are honestly all cost, split by which stat pays and how badly failure lands (`burned` on the shelter route, none on the road).
Findings: none.

---

### global_pack — Abandoned Pack   [data/events.json; global; unique=y; weight=2; tags=none]
Scene: a clean canvas backpack sits upright and buckled in the middle of the road, with no footprints and one narrow dust line running to a drainage pipe.
Evidence on screen: the dust line and the too-careful display (inspect); the pipe it leads to (leave).
Comparison: [0] 45–70 healthy / 35 depleted; [1] certain; no dominance flag.

[0] Inspect for traps — intention: take the bait after finding the hook.
    known cost: Wits risky (salvage) | uncertain risk: failure damage_type physical, pressures {health −14}, add_conditions [bleeding]
    success: items {canvas_pack 1, canned_meat 1, pistol_rounds 2} | failure: as above; the pack is left behind
    local significance: the display is disarmed and emptied, or it takes a hand and stays.
    durable: none.
[1] Leave it untouched — intention: refuse a set piece and keep the pipe in view.
    known cost: certain; the pack and its contents are left | uncertain risk: none
    success: `outcome` text only; no fields | failure: n/a
    local significance: the pack stays upright behind the survivor, complete with whatever made it so carefully visible.
    durable: none.

Disposition: keep — strong opening evidence and a real trade between a trapped reward and an untouched exit.
Findings: none.

---

### global_stranger — Injured Stranger   [data/events.json; global; unique=y; weight=2; tags=none]
Scene: a stranger holds a cut-open coat closed over a wound beside a kilometer stone, watching the cloth markers for whoever is coming back.
Evidence on screen: the wound and the coat cut rather than torn (treat); a stamped route token and a dry mouth (water); the markers and the survivor's own coat lining (the proposed third route).
Comparison: [0] 55–80 healthy / 45 depleted; [1] certain. Both read as ungated in `builds/choice_comparison.json` (`gated_by: []`) only because every measured state starts with `cloth_bandage` and `clean_water`; both carry `requires.items`, so the header's "0 are blocked in at least one state" does not cover this scene.

[0] Treat the wound — intention: keep the stranger alive with proper dressing.
    known cost: `requires.items {cloth_bandage 1}` and `costs.items {cloth_bandage 1}`, declared and previewed; Wits favorable (medical) | uncertain risk: failure add_conditions [shaken]
    success: items {trader_token 1}, add_conditions [inspired] | failure: as above; the survivor stays while the grip weakens and learns the name on the token without taking it
    local significance: the stranger lives to be found by the people behind the markers, or dies with company.
    durable: none written; the `trader_token` is the only carried evidence and nothing reads it (see the `global_trader` findings).
[1] Offer water and move on — intention: give what can be spared and stop before treatment.
    known cost: `requires.items {clean_water 1}` and `costs.items {clean_water 1}`; certain | uncertain risk: none
    success: `outcome` pressures {fatigue −4} | failure: n/a
    local significance: the stranger points out a trail hidden behind the marker stone; what happens after the survivor leaves is unanswered.
    durable: none.
[2] Press the wound with your own coat — PROPOSED; the ungated action STORY_CANON §10 assigns to N02 and plan §6 requires. Intention: keep them alive with nothing but hands and time.
    known cost: no `requires` and no `costs`; Grit risky (medical); the work itself charges fatigue | uncertain risk: failure pressures {fatigue 4}, add_conditions [shaken]
    success: proposed `success` pressures {fatigue 4}, add_conditions [inspired]; no items, no add_flags, no next_event | failure: proposed `failure` pressures {fatigue 4}, add_conditions [shaken]
    local significance: the bleeding slows enough for the markers to answer, or it does not and the survivor was there for it.
    durable: none.
    non-dominance: it is a check, so it can never dominate the certain [1], and it charges fatigue 4 where [1] returns fatigue −4; against [0] it grants no `trader_token` and rolls at risky rather than favorable. It is the worst of the three whenever the survivor has supplies, which is the point: it exists so the scene always has a legal action.

Disposition: revise — append choice 2; choices 0 and 1 keep their indices, labels, requirements, checks, and outcomes. The event then holds three of a maximum four choices.
Findings:
P0: a survivor carrying no `cloth_bandage` and no `clean_water` sees both buttons rendered LOCKED and disabled (`_choice_availability`, game_engine.gd:1217-1242; main.gd:788-797) and has no legal action → append choice 2 exactly as specified above.

---

### global_map — Map Under Glass   [data/events.json; global; unique=y; weight=2; tags=none]
Scene: a route map under cracked glass carries years of contradicting amendments, and one eastern route is marked safe, flooded, and occupied at once.
Evidence on screen: ink of different ages, flood lines, and the direction each warning was scratched from (reconcile); the space left at the bottom (add).
Comparison: [0] 55–80 healthy / 45 depleted; [1] 65 / 55, Presence kit unmeasured; no dominance flag.

[0] Reconcile the conflicting marks — intention: get a usable route out of the argument.
    known cost: Wits favorable (navigation) | uncertain risk: failure pressures {fatigue 7}
    success: add_conditions [focused], pressures {fatigue −5} | failure: as above; the map keeps its confidence and its poor evidence
    local significance: the survivor leaves with a consistent route; the glass is unchanged.
    durable: none.
[1] Add your own warning — intention: put something true where the next traveler will read it.
    known cost: Presence easy (social) | uncertain risk: failure has no mechanical fields; the scratch is indistinguishable from vandalism two steps away
    success: add_conditions [inspired] | failure: nothing lost
    local significance: a collapsed culvert is named beside the landmark that reveals it, or it is not.
    durable: none — no content reads this map again, so the card claims no callback rather than inventing one.

Disposition: keep — two distinct intentions (take knowledge, leave knowledge), both rewards real under §3's beneficial-condition caveat, no dominance.
Findings: none.

---

### global_quiet — A Quiet Mile   [data/events.json; global; unique=n; weight=3; tags=none]
Scene: a mile with no smoke, voices, tracks, or movement in the weeds, and an undisturbed drainage grate beside a shallow ditch.
Evidence on screen: the lowered wind and the absence itself (walk); the intact grate nobody has lifted (search).
Comparison: [0] certain; [1] 55–80 healthy / 45 depleted; no dominance flag — [0] is certain but carries no items, so it does not dominate.

[0] Walk at an easy pace — intention: spend the safety on recovery.
    known cost: certain; the grate is left | uncertain risk: none
    success: `outcome` pressures {fatigue −8} | failure: n/a
    local significance: the mile ends as rest rather than unfinished evidence.
    durable: none.
[1] Use the calm to search — intention: find out why nothing else stopped here.
    known cost: Wits favorable (salvage) | uncertain risk: failure pressures {fatigue 3}
    success: items {scrap_parts 2} | failure: as above; nothing reveals itself
    local significance: the grate is opened and the quiet stays unexplained either way.
    durable: none.

Disposition: keep — rest against salvage, priced honestly in both directions.
Findings: none.

---

### global_grave — Roadside Grave   [data/events.json; global; unique=y; weight=2; tags=none]
Scene: a cairn built from red brick, marsh slate, salt, and fused glass, inscribed with a name, two dates, and THEY KEPT WALKING.
Evidence on screen: the plural inscription and stones carried from four regions (add); the narrow gap beneath the inscription (check).
Comparison: [0] certain; [1] 55–80 healthy / 45 depleted; no dominance flag.

[0] Add a stone — intention: join the marker rather than open it.
    known cost: certain; the gap is left unexamined | uncertain risk: none
    success: `outcome` add_conditions [inspired] | failure: n/a
    local significance: the inscription stops belonging only to the buried person. Inspired is a real reward (§3).
    durable: none.
[1] Check beneath the cairn — intention: take what the gap was built to hold.
    known cost: Wits favorable (risk) | uncertain risk: failure add_conditions [shaken]
    success: items {ration_bar 1} | failure: as above; the search reaches burial cloth and every stone is replaced
    local significance: a ration marked FOR THE NEXT ONE is claimed, or a grave was opened for nothing.
    durable: none.

Disposition: keep — the cleanest small dilemma in the global set: a certain moral reward against an uncertain material one, with a real cost for being wrong.
Findings: none.

---

### global_drop — Fallen Supply Pod   [data/events.json; global; unique=y; weight=2; tags=none]
Scene: a pod is embedded nose-first in the roadside under a parachute caught on power lines, its casing ticking through an unknown interval.
Evidence on screen: the service keypad and the recovery signal the pod keeps repeating (open); the parachute lines and a concrete awning (drag).
Comparison: [0] 45–80 healthy / 35–45 depleted (Wits kit 80); [1] 50–65 / 35 (Strength kit 65); no dominance flag.

[0] Open it before anyone arrives — intention: beat the claimants to the contents.
    known cost: Wits risky (technical) | uncertain risk: failure pressures {fatigue 8}, add_conditions [shaken]
    success: items {medkit 1, rad_tabs 1, ration_bar 1} | failure: as above; a recovery alarm wakes and the pod is abandoned sealed
    local significance: the road is cleared while the parachute still advertises the spot.
    durable: none.
[1] Drag it into cover first — intention: pay in strength for opening it unobserved.
    known cost: Strength risky (force) | uncertain risk: failure pressures {health −8}, add_conditions [sprain]
    success: items {clean_water 2, canned_meat 1, climbing_rope 1} | failure: as above; the pod stays visible, ticking and sealed
    local significance: nobody sees the hatch release.
    durable: the rope is the durable effect — an item that persists as the key to `outskirts_sinkhole` 1 and `marsh_bridge` 1, and this success is its only baseline source (M05 note, `docs/CONTENT_AUTHORING.md`).

Disposition: keep — speed against concealment, distinct payoffs, and the item that unlocks two later gated routes.
Findings:
P2: "Fresh arrival means intact supplies and nearby claimants" states an inference flatly and implies an active aerial resupply that STORY_CANON §2 does not establish; §5 requires belief to be reported as belief → attribute the reading to the survivor rather than the narrator. Mechanics unchanged.

---

### global_bike — Broken Courier Bike   [data/events.json; global; unique=y; weight=2; tags=none]
Scene: a courier bicycle with a snapped chain leans against a route marker, its locked cargo box freshly scratched around the keyway.
Evidence on screen: the snapped chain and wire the survivor can lace it with (repair); the scratched keyway and a manifest of medical deliveries (open).
Comparison: [0] 45–80 healthy / 35–45 depleted (Wits kit 80); [1] 60–75 / 45 (Strength kit 75); no dominance flag.

[0] Repair the chain long enough to ride — intention: turn salvage into distance.
    known cost: Wits risky (technical) | uncertain risk: failure items {scrap_parts −1}, pressures {fatigue 4}
    success: pressures {fatigue −12} | failure: as above; the bicycle stays exactly where patience found it
    local significance: several clean kilometers are ridden and the bike is left under another marker.
    durable: none.
[1] Open the cargo box — intention: recover cargo that can still reach a living recipient.
    known cost: Strength favorable (force) | uncertain risk: failure items {scrap_parts −1}; the pick snaps below the pins and blocks the keyway for good
    success: items {pistol_rounds 3, ration_bar 1} | failure: as above
    local significance: the courier's last delivery is opened, or sealed permanently against everyone.
    durable: none.

Disposition: revise — the box's contents contradict its own manifest and are inert for three of the four kits.
Findings:
P1: [1] success pays `pistol_rounds 3` from a box whose manifest "lists medical deliveries", and only the Agility kit starts with a pistol → `now: success items {pistol_rounds 3, ration_bar 1} | proposed: success items {cloth_bandage 2, ration_bar 1}`, or keep the rounds and name the courier's own sidearm in the body so manifest and reward agree.
P1: [0] and [1] failures charge `scrap_parts −1`, which no-ops for a survivor with no scrap while the result line prints the loss → same repair as `outskirts_market`.

---

### global_crows — Mutant Crows   [data/events.json; global; unique=n; weight=3; tags=none; adversary_id=mutant_crows]
Scene: hairless crows line a guardrail in order of size and repeat scraps of human speech, one of them wearing bandage cloth around a leg.
Evidence on screen: TURN LEFT in three voices and the bird that learned a phrase most recently (follow); the flock's hunger and the cloth it has already collected (fight).
Comparison: [0] 45–70 healthy / 35 depleted; [1] fight T10 +18xp flee:y; no dominance flag.

[0] Follow the words they repeat — intention: use stolen language as directions.
    known cost: Wits risky (risk) | uncertain risk: failure pressures {radiation 9}
    success: items {canned_meat 1, cloth_bandage 1} | failure: as above; the voices lead into a glowing basin and the flock lifts out of range
    local significance: an abandoned camp is found, or a dose of the basin leaves with the survivor.
    durable: none.
[1] Drive them off — intention: stop being an audience.
    known cost: combat with `mutant_crows`, threat 10, enemy damage 7–10, flee easy | uncertain risk: no `defeat` branch; losing is death, critical condition `shaken`
    success: `victory` no items, no pressures, no flags | failure: none authored; fleeing writes nothing
    local significance: the borrowed phrases scatter over the ruins with the survivors of the flock.
    durable: none.

Disposition: revise — the fight is the only branch in this batch that pays nothing at all, in a scene that shows the flock carrying salvage on screen.
Findings:
P1: [1] `victory` grants no items although the introduction shows a crow wearing bandage cloth and ENEMY_DESIGN_BIBLE gives crows the axis "collecting what shines" → `now: victory (no items) | proposed: victory items {cloth_bandage 1, scrap_parts 1}`, and the victory text stops asserting "No useful loot remains". Not dominant over [0]: it costs a fight and its own damage where [0] costs a risky roll, and combat is excluded from the tool's dominance rule by construction.

---

### global_clear — Clear Sky   [data/events.json; global; unique=n; weight=2; tags=none]
Scene: the cloud breaks for a few minutes, sharpening far landmarks and revealing movement on two separate ridges at the same time.
Evidence on screen: sunlight reaching the road (stop); comparable landmarks, the road's bend, and a distant column of smoke (scout).
Comparison: [0] certain; [1] 65–90 healthy / 55 depleted (Wits kit 90). The tool flags **dominant: [0] Stop and breathe** — the one false positive §3 names: [1]'s only reward is `focused`, and beneficial conditions score as nothing in the tool's reward rule. Read as a real reward, neither choice dominates.

[0] Stop and breathe — intention: spend the light on recovery instead of information.
    known cost: certain; the ridges go unread | uncertain risk: none
    success: `outcome` pressures {fatigue −6}, `remove_conditions [shaken]` | failure: n/a
    local significance: the survivor stops flinching before the cloud closes. This is the only `remove_conditions` in `data/events.json` (line 3975), applied by `_apply_outcome` (game_engine.gd:1337) — the sole content cure for `shaken`, which makes it a distinct reward rather than a rest button.
    durable: none.
[1] Use the visibility to scout — intention: convert the interval into a route that avoids the movement.
    known cost: Wits easy (navigation) | uncertain risk: failure pressures {fatigue 3}
    success: add_conditions [focused] | failure: as above; the interval is spent on a glint that may never have moved
    local significance: the next hours become choices instead of surprises, or they do not.
    durable: none.

Disposition: keep — the dominance flag is the measurement artifact §3 documents, and nothing else is wrong: the certain branch cures a condition, the checked branch grants one.
Findings: none.

---

### global_snare — Wire at Ankle Height   [data/events.json; global; unique=n; weight=3; tags=none]
Scene: a clean wire crosses the trail at ankle height between a bent sapling and a drainage post, and no voices answer the wind.
Evidence on screen: the visible trigger and the tension held in the sapling (disarm); the ground a cautious traveler would step onto instead, where a second line may lie (step over).
Comparison: [0] 55–90 healthy / 45–55 depleted (Wits kit 90); [1] 65–90 / 55; no dominance flag.

[0] Disarm and salvage it — intention: take the mechanism and remove it from the trail.
    known cost: Wits favorable (technical) | uncertain risk: failure damage_type physical, pressures {health −10}, add_conditions [sprain]
    success: items {scrap_parts 2} | failure: as above; a slack loop under the leaves takes the legs
    local significance: the trap becomes weight in the pack, or it keeps working and the survivor is its first catch.
    durable: none.
[1] Step over and leave quickly — intention: pass without touching someone else's mechanism.
    known cost: Agility easy (evade) | uncertain risk: failure items {clean_water −1}, pressures {fatigue 4}
    success: no fields | failure: as above; a second line catches the pack and a bottle spills
    local significance: the wire stays armed behind the survivor at the next traveler's expense — stated in the success text and deliberately left unresolved.
    durable: none.

Disposition: keep — distinct intentions, a legible moral residue, and each kit's own stat winning its route.
Findings:
P1: [1] failure's `clean_water −1` no-ops for a survivor carrying none while the text describes the bottle tearing free and the result line prints the loss → same repair as `outskirts_market` and `global_bike`.

---

### fallback_dust — Dust and Distance   [data/events.json; engine fallback, in no region pool and not `global`; unique=n; weight=1; tags=none]
Scene: wind has erased the road; a line of old marker posts still holds a bearing east through dust that keeps rearranging the ruins.
Evidence on screen: the posts and the bearing between them (pace); debris gathered around their bases (search).
Comparison: [0] 65–90 healthy / 55 depleted (Grit kit 90); [1] 55–80 / 45; no dominance flag.

[0] Keep a steady pace — intention: hold the bearing rather than investigate anything.
    known cost: Grit easy (survival) | uncertain risk: failure pressures {fatigue 7}
    success: no fields; the stretch costs nothing | failure: as above; two fallen posts turn the line into a slow correction
    local significance: a recognizable road cut appears where the old line promised.
    durable: none.
[1] Search the roadside — intention: get something out of an empty stretch.
    known cost: Wits favorable (salvage) | uncertain risk: failure pressures {fatigue 5, hunger 3}
    success: items {ration_bar 1} | failure: as above; every hollow has already been emptied by animals
    local significance: one survey tube is opened; dust restores each disturbed place behind the survivor.
    durable: none.

Disposition: keep — this is `_select_next_event`'s empty-pool filler (game_engine.gd:1152) and reaches the player only when no pooled or global event is eligible. The prose is region-neutral, uses no prohibited closer, and both branches price the same decision honestly, so there is nothing to repair even though it is rarely seen.
Findings: none.

---

## Batch summary

DISPOSITIONS:
outskirts_bandits | keep | three distinct intentions and six histories that all feed §5 record 3
outskirts_bus | revise | the body must signal which opening yields food and which yields medicine (plan §6)
outskirts_dogs | keep | fight, declared food price, and climb are three intentions with no dominance
outskirts_market | keep | four choices at the maximum, M05 equipment routes allowlisted and distinct
outskirts_overpass | revise | the introduction promises a find in the channel that neither branch delivers
outskirts_apartment | revise | append creature choice 2 per CREATURE_STORY_BIBLE; choices 0 and 1 unchanged
outskirts_siren | revise | retire the orphan silenced_siren per §5 record 2; everything else stands
outskirts_cache | keep | force, technical, and certain routes pay different things and each kit wins its own
outskirts_child_radio | revise | retire the orphan helped_family per §5 record 1; everything else stands
outskirts_sinkhole | revise | give the leap the time it saves so the rope route is preparation, not a better button
global_trader | revise | declare the salvage price in requires and costs so it is previewed and actually paid
global_acid_rain | keep | a weather scene honestly all cost, split by stat and failure severity
global_pack | keep | strong evidence, a trapped reward against an untouched exit
global_stranger | revise | append the ungated choice 2 required by STORY_CANON §10 and plan §6
global_map | keep | take knowledge or leave knowledge, both rewards real under §3
global_quiet | keep | rest against salvage, priced honestly in both directions
global_grave | keep | a certain moral reward against an uncertain material one
global_drop | keep | speed against concealment, and the only baseline source of climbing_rope
global_bike | revise | the cargo contradicts its own manifest and is inert for three kits
global_crows | revise | the fight pays nothing in a scene that shows the flock carrying salvage
global_clear | keep | the dominance flag is the false positive §3 documents; the shaken cure is a real reward
global_snare | keep | distinct intentions, legible residue, each kit's stat wins its route
fallback_dust | keep | region-neutral empty-pool filler with honest pricing and no stock closer

FINDINGS:
P0 | global_stranger | - | both choices carry requires.items, so a survivor with no cloth_bandage and no clean_water has every button locked and no legal action (game_engine.gd:1217-1242, main.gd:788-797) → append ungated choice 2 "Press the wound with your own coat", Grit risky (medical), success pressures {fatigue 4} + add_conditions [inspired], failure pressures {fatigue 4} + add_conditions [shaken], no items and no flags
P0 | global_trader | 0 | the scrap price sits inside both outcome branches, so it is never previewed and silently no-ops for a survivor with no scrap while the result line still prints "Scrap Parts -1" → add requires.items {scrap_parts 1} and costs.items {scrap_parts 1}; success items {canned_meat 1, cloth_bandage 1}; failure items {ration_bar 1}
P1 | outskirts_bandits | - | unique=false lets one run write two contradicting lr_bandit* flags and §5 record 3 states no variant precedence → N04 fixes first-match order killed > disarmed > wounded_escape > paid > bluffed > escaped
P1 | outskirts_bandits | 2 | failure's canned_meat -1 no-ops when the survivor holds no can while text and result line assert the payment → N04 suppresses the result line for a no-op item delta
P1 | outskirts_bus | - | the introduction ties neither opening method to its reward, so the food/medicine split is invisible at commitment (plan §6) → the body names the ration shapes seen through the wiped circle and the first-aid bracket beside the release cable; mechanics unchanged
P1 | outskirts_overpass | 1 | "whatever has collected" promises a find and both branches are pure fatigue and hunger → cut the promise from the body, or now success pressures {fatigue 7, hunger 4} | proposed success pressures {fatigue 7, hunger 4} + items {scrap_parts 1}
P1 | outskirts_market | 0 | failure's scrap_parts -1 no-ops for a survivor with no scrap while the text asserts the payment → N04 suppresses the result line for a no-op item delta
P1 | outskirts_market | 1 | failure's scrap_parts -1 has the same defect → same repair
P1 | outskirts_siren | 0 | silenced_siren is written and never read (orphan) → retire it per §5 record 2; lr_siren_silenced carries the thread
P1 | outskirts_child_radio | 0 | helped_family is written and never read (orphan) → retire it per §5 record 1; lr_channel_helped carries the thread
P1 | outskirts_sinkhole | 0 | the rope route equals or beats the leap in every measured cell (70/45, 70/70, 90/50, 65/45 healthy; 55/35 depleted), pays items where the leap pays nothing, and fails for fatigue 6 against 15 HP and a sprain → now success (no fields) | proposed success pressures {fatigue -4}
P1 | global_trader | - | trader_token is granted once (global_stranger 0 success) and by the Presence kit and is required or read by no event, eligibility, or ledger entry in any data file → record it as equipment-only (social +2 / presence +1) with no expected reader, or give it one in the batch that owns a market or toll scene
P1 | global_bike | 0 | failure's scrap_parts -1 no-ops for a survivor with no scrap → same repair as outskirts_market
P1 | global_bike | 1 | success pays pistol_rounds 3 from a box whose manifest lists only medical deliveries, and the rounds are inert for three of four kits → now success items {pistol_rounds 3, ration_bar 1} | proposed success items {cloth_bandage 2, ration_bar 1}, or name the courier's sidearm in the body
P1 | global_crows | 1 | victory grants no items although the introduction shows a crow wearing bandage cloth and crows own "collecting what shines" → now victory (no items) | proposed victory items {cloth_bandage 1, scrap_parts 1}; drop "No useful loot remains" from the victory text
P1 | global_snare | 1 | failure's clean_water -1 no-ops for a survivor carrying none → same repair as outskirts_market
P2 | outskirts_apartment | 2 | the appended combat choice makes the event combat-carrying and changes region 0's forced-combat slot and two-per-region combat cap (game_engine.gd:1097-1130) → N05 re-checks region 0 pacing with three combat events in the pool
P2 | global_drop | - | "Fresh arrival means intact supplies and nearby claimants" states an inference flatly and implies an aerial resupply STORY_CANON §2 does not establish (§5 registers) → attribute the reading to the survivor; mechanics unchanged
