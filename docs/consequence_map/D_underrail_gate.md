# Consequence cards — Batch D: The Underrail and the gate

Batch D of [NARRATIVE_CONSEQUENCE_MAP.md](../NARRATIVE_CONSEQUENCE_MAP.md) §4. Thirteen events: the ten `underrail` pool events (`data/regions.json`, region order 5) and the three gate events. Cards use the §2 template. Canon is quoted by section from [STORY_CANON.md](../STORY_CANON.md); the creature host scene follows [CREATURE_STORY_BIBLE.md](../CREATURE_STORY_BIBLE.md). Every percentage is copied from `builds/choice_comparison.md`; none is estimated here.

Prose is the loaded text: `data/events.json` with `data/narrative_overrides_v1.json` and `data/narrative_overrides_v11.json` applied. Mechanical fields are the JSON as it loads.

Two batch-wide facts the cards reference rather than repeat:

- **Region 5 order is random.** All ten pool events sit in one `event_pool`; six are `unique`. Any consumer inside the region must read its flag only when present (`hidden_when_locked` for a gated choice, a default passage for a variant), exactly as §5 record 11 reasons for the Reed Widow.
- **Negative `items` in an outcome are not a gate.** `GameEngine._change_item` clamps at zero and `_apply_outcome` still appends the change line, so an outcome that removes an item the survivor does not carry costs nothing and still reports the loss. Where a passage asserts the loss as fiction, the card says so.

---

### rail_hunters — Breathing in the Dark   [data/events.json + overrides_v11; underrail (region 5); unique=n; weight=5; tags=none; adversary_id=tunnel_hunters]
Scene: three sets of breathing keep station just outside the lamp, and the survivor must decide whether to pick the ground, remove everyone's sight, or buy the tunnel.
Evidence on screen: breathing that stops when the survivor stops and resumes one step later; service alcoves counted while the light lasts; the intro's own warning that "announcing that you carry rounds also gives strangers a reason to stop negotiating."
Comparison: [0] `fight T16 +52xp flee:y`; [1] agility hard 35–60 healthy / 25 depleted; [2] presence hard 35 healthy / 25 depleted — **dominant: [1] Extinguish your light and move**. The Presence kit is the one §3 says the tool does not measure.

[0] Turn and attack the sound — intention: choose the ground before hidden hunters choose it.
    known cost: a fight with Tunnel Hunters — threat 16, xp_reward 52, 300 HP, 65–95 damage, critical condition `bleeding`, `can_flee` unset so flee is allowed at `flee_difficulty` hard | uncertain risk: defeat is death under strict permadeath; fleeing resolves no outcome and writes no flag
    success: `victory` `items {pistol_rounds: 4, smoke_bomb: 1}` | failure: no failure branch exists
    local significance: three hunters dead and the stretch behind the survivor unclaimed; the smoke bomb is the evidence of how patiently they worked.
    durable: none.

[1] Extinguish your light and move — intention: refuse the ambush by taking sight away from both sides.
    known cost: none | uncertain risk: `pressures {health: -13, fatigue: 10}`, `add_conditions [concussed]`, `damage_type physical`
    success: text only — no items, no pressures, no flags | failure: as above
    local significance: the alcoves the survivor counted while the lamp burned are what saves them; the hunters pass close enough to warm the air.
    durable: none.

[2] Offer ammunition for peace — intention: pay for passage in the only currency the dark respects.
    known cost: none charged before commitment; the intro promises the offer will expose the pack | uncertain risk: `pressures {health: -18}`, `items {pistol_rounds: -2}`
    success: `items {pistol_rounds: -2}` and nothing else | failure: as above
    local significance: a hunter whispers a safe route, or the offer becomes an inventory the enemy now has.
    durable: none.

Disposition: revise — [2]'s cost must be charged before commitment and its success must pay the route it narrates; [0] and [1] stand.
Findings:
P0: [2] takes its price as `items {pistol_rounds: -2}` inside both outcomes, so a survivor with no rounds pays nothing while the passage says "A hand collects the payment" and the result panel still prints "Pistol Rounds -2" → move the price to `costs.items {pistol_rounds: 2}` (`_choice_available` already locks a choice whose `costs.items` cannot be paid) and drop the item line from both branches. The choice then reads blocked in the depleted state, which removes ammunition — honest, and choices 0 and 1 stay legal.
P1: [2] success grants no mechanical value while the comparison flags [1] strictly dominant → `now: success items {pistol_rounds: -2}` | `proposed: success pressures {fatigue: -5}` for the whispered route, matching `rail_signal` 0 and `rail_switch` 0. Keep [2] after the fix: per §3 it preserves useful expertise (the scene's only Presence check, in the unmeasured kit).

---

### rail_train — Train with Warm Windows   [data/events.json + overrides_v11; underrail; unique=y; weight=3; tags=none]
Scene: one lit carriage window on a dead train, everything around it deliberately covered, and a wire running from the roof hatch into the dark.
Evidence on screen: condensation clouding the glass from inside; route maps and blankets over the neighbouring windows leaving "only this deliberate square visible"; the thin wire on the hatch handle.
Comparison: [0] presence risky 45 healthy / 35 depleted (flat across all four measured kits, which all hold Presence 2); [1] agility risky 45–70 healthy / 35 depleted; no dominance, no redundancy.

[0] Knock before entering — intention: ask the people keeping the heat for hospitality.
    known cost: announcing yourself to whoever built the decoy | uncertain risk: `add_conditions [shaken]`, nothing else
    success: `pressures {hunger: -20, fatigue: -8}`, `add_flags [met_train_family]` | failure: `add_conditions [shaken]`
    local significance: a hidden family feeds the survivor and marks safe junctions on their map — or living people choose darkness while listening to a stranger knock.
    durable: `met_train_family` — **orphan today** (no reader in `data/events.json`, `bunker41_events.json`, `rustsea_events.json`, `living_road_events.json`, or `road_ledger.json`). Proposed consumer: a `rail_survivors` introduction variant in which the council recognizes the junction marks on the survivor's map as their own people's hand. Prose only, no mechanical change; the variant must default silently because either event may come first in region 5.

[1] Enter through the roof hatch — intention: take the shelter's supplies without owing anyone trust.
    known cost: the visible trip wire | uncertain risk: `pressures {health: -16}`, `add_conditions [sprain]`, `damage_type physical`
    success: `items {ration_bar: 2, clean_water: 1}` | failure: as above
    local significance: the carriage is a decoy arranged to look occupied; its builders are gone and the yellow light keeps shining into an empty room.
    durable: none.

Disposition: revise — the scene is well built and honestly signposted; only the orphan flag needs a reader.
Findings:
P1: `met_train_family` has no consumer → give it the `rail_survivors` introduction variant above, or retire it. Recommended: keep and consume, since it is the region's only record that the survivor was fed by strangers rather than by salvage.

---

### rail_flood — Rising Tunnel Water   [data/events.json + overrides_v11; underrail; unique=n; weight=4; tags=none]
Scene: a black surge rounds the bend carrying seats and signal lamps, and the survivor has one reach at a broken ladder or one run to a platform the water is already hiding.
Evidence on screen: water trembling between the rails before the roar; the ladder starting at shoulder height with its lower rungs missing; the platform "farther downline beyond a shallow curve".
Comparison: [0] strength risky 50–65 healthy / 35 depleted; [1] agility hard 35–60 healthy / 25 depleted; no dominance flagged — the Strength kit beats [1] in its own cells, so [0] preserves useful expertise under §3.

[0] Climb the maintenance ladder — intention: get above the water instead of ahead of it.
    known cost: one violent reach | uncertain risk: `pressures {health: -18, fatigue: 12}`, `add_conditions [sprain]`, `damage_type physical`
    success: text only | failure: as above
    local significance: the survivor rides it out on a bending ladder while debris hammers the wall below, then has to come down again into a flooded line.
    durable: none.

[1] Race it to the platform — intention: outrun the surge to standing ground downline.
    known cost: ground the water is covering | uncertain risk: `pressures {health: -22, fatigue: 15}`, `add_conditions [concussed]`, `damage_type physical`
    success: text only | failure: as above
    local significance: the survivor ends the scene on the platform, east of the flooded stretch, with the surge spending itself against concrete below.
    durable: none.

Disposition: revise — the hard check has the worse failure and the identical empty success, which plan §3 forbids ("Hard checked successes need a clear premium over safer alternatives").
Findings:
P1: [1] is agility **hard** with `health -22 / fatigue 15 / concussed` on failure and pays exactly what [0] pays at strength **risky** → give [0] the honest extra cost instead of giving [1] loot, because the event is `unique=false` and a repeatable item reward is farmable: `now: [0] success text only` | `proposed: [0] success pressures {fatigue: 6}` for climbing back down into the flooded line. [1]'s premium then is what the prose already gives it — it ends past the flood.

---

### rail_survivors — Platform Council   [data/events.json + overrides_v11; underrail; unique=y; weight=3; tags=none]
Scene: a settlement lights every visitor and stays in shadow itself, asking why the Citadel should outweigh the food and safety a traveller has already consumed, while its pump coughs under the platform.
Evidence on screen: shields made from station signs; lamps aimed so the survivor is the only lit thing; the pump coughing between questions.
Comparison: [0] presence risky 45 healthy / 35 depleted; [1] wits risky 45–80 healthy / 35–45 depleted; no dominance, no redundancy.

[0] Explain why the Citadel matters — intention: buy passage with an honest account of the road.
    known cost: none | uncertain risk: `items {ration_bar: -1}`
    success: `items {medkit: 1}`, `add_conditions [inspired]` — per §3's caveat a beneficial condition is a real reward and is read as one here | failure: `items {ration_bar: -1}`
    local significance: the barrier opens either way; the council either recognizes honesty or bills the survivor for the platform's protection.
    durable: none.

[1] Offer technical help — intention: answer the question with work rather than argument.
    known cost: none shown before commitment | uncertain risk: `items {scrap_parts: -2}`
    success: `items {purifier_ampoule: 1}`, `add_flags [fixed_platform_pump]`, and the eastern maintenance gate opens in prose | failure: `items {scrap_parts: -2}`
    local significance: clean water reaches the settlement taps, or useful salvage disappears inside the gears and the council watches in silence.
    durable: `fixed_platform_pump` — **orphan today**. Proposed consumer: an `lr_valve_below` introduction variant (region 5, Iven's water chapter) noting that the platform taps this argument is about are already running because of the survivor's hands. Prose only, alongside the variant §5 record 4 already proposes there; batch F and N04 own the passage.

[2] APPENDED — Let the traveler speak for you — see §5 record 10 (Cinder Giant rescue). `requires.flags [cinder_traveler_rescued]`, `hidden_when_locked: true`, certain → `items {medkit: 1}`, `add_conditions [inspired]`. Immediate effects beyond the record: none; the council grants the same passage, and the survivor spends no check because someone at the table can account for them. `cinder_traveler_rescued` is written by `glass_shadow` 0 success (batch C, region 4), so this choice always rests on earlier-region evidence and is never order-dependent inside region 5.

Record 9 (Kilnback rhythm) also lands here: if batch C keeps `rescued_engineer` rather than retiring it, this scene is its consumer as an **introduction variant only** — the engineer pulled from the cooling jacket sits on the council and the pump's age is already explained. No choice, no mechanical change; `rail_survivors` has room for one appended choice (index 2, taken by record 10) and index 3, which this card deliberately leaves empty.

Disposition: revise — add record 10's choice 2, give `fixed_platform_pump` a reader, and carry the record 9 and `met_train_family` variants.
Findings:
P1: `fixed_platform_pump` has no consumer → the `lr_valve_below` introduction variant above.
P1: both failure branches assert a confiscation the survivor may be unable to pay (`ration_bar -1`, `scrap_parts -2`); with an empty inventory nothing is removed and the result panel still prints the loss → N04 clamps the reported change to the quantity actually removed, and the passages gain a variant for the survivor who had nothing to take.

---

### rail_switch — The Wrong Track   [data/events.json + overrides_v11; underrail; unique=y; weight=3; tags=none]
Scene: a prewar route board says EAST and the survivor's signal compass says west at a welded door, and only one of the two is answering something built after the disaster.
Evidence on screen: rails "polished by dripping water" under the board's EAST arm; the compass needle nudged whenever a relay clicks overhead; dust hiding destination marks on the transfer diagram.
Comparison: [0] wits favorable 55–80 healthy / 45 depleted, **gated: item `signal_compass` x1**; [1] wits hard 35–70 healthy / 25–35 depleted; no dominance, no redundancy.

[0] Trust the signal compass — intention: follow the instrument to the live infrastructure.
    known cost: `requires.items {signal_compass: 1}`; the compass is an accessory with `modifiers.approaches.navigation: 3`, so holding it both unlocks and improves the check | uncertain risk: `pressures {fatigue: 12}`
    success: `pressures {fatigue: -5}` | failure: `pressures {fatigue: 12}`
    local significance: a service line behind the welded door runs straight at Citadel infrastructure, or an instrument is confidently wrong for hours.
    durable: none. The gate is fairly reachable — `signal_compass` comes from `outskirts_child_radio` 1 success (region 0) and `glass_carcass` (region 4) — and it is where §5 record 1's proposed `lr_blue_van` choice 3 is felt: a survivor who gave the Vale family the relay bearing spent the compass and arrives here without this option. Name that in record 1's replay fixture.

[1] Reconstruct the route board — intention: read the prewar document instead of the postwar signal.
    known cost: none | uncertain risk: `pressures {fatigue: 14, hunger: 5}`
    success: text only | failure: as above
    local significance: the survivor recovers how service trains bypassed the public line and keeps clear of the flooded sections the newer stains mark.
    durable: none.

Disposition: revise — the hard, ungated route pays less than the favorable, gated one.
Findings:
P1: [1] is wits **hard** with the worse failure (`fatigue 14, hunger 5`) and an empty success, while [0] is wits **favorable** and pays `fatigue -5` → `now: [1] success text only` | `proposed: [1] success pressures {fatigue: -8}`. Both routes remove wasted distance; the harder one should remove more. Note for N05: `data/legacy_v2_checks.json` pins `rail_switch:0` at 11 and `rail_switch:1` at 15, so no difficulty change is proposed here. Note also that both choices are Wits — the Underrail spends seven of its twenty pool choices on Wits — which is a regional balance question for N05, not a defect in this scene.

---

### rail_nest — Nest of Cable   [data/events.json + overrides_v11; underrail; unique=n; weight=4; tags=none; adversary_id=ash_stalkers]
Scene: a station office packed to the ceiling with stripped cable and other people's clothing, and something inside copying the survivor's footsteps with a delay too precise for echo.
Evidence on screen: ticket stubs and clothing woven into the nest; the copied footfall; cloth settling in imitation when the survivor shifts weight.
Comparison: [0] `fight T14 +36xp flee:y`; [1] agility risky 45–70 healthy / 35 depleted; no dominance (combat is excluded from the rule), no redundancy.

[0] Drive it out with noise — intention: force the creature into the open before it picks its angle.
    known cost: a fight with the Ash Stalker — threat 14, xp_reward 36, 220 HP, 45–70 damage, critical condition `bleeding`, `can_flee` unset so flee is allowed at `flee_difficulty` risky | uncertain risk: defeat is death; a flee resolves no outcome and writes no flag
    success: `victory` `items {scrap_parts: 2, rad_tabs: 1}` | failure: no failure branch exists
    local significance: this is the **only Ash Stalker fight in the game** (CREATURE_STORY_BIBLE, regional presence table), and the salvage comes out of possessions woven around its sleeping place.
    durable: none.

[1] Pass without changing rhythm — intention: deny it the hesitation that marks uncertain prey.
    known cost: none | uncertain risk: `pressures {health: -12, fatigue: 8}`, `add_conditions [shaken]`
    success: text only — the avoided damage is the reward | failure: as above
    local significance: the mimic keeps copying a walk that is no longer there.
    durable: none.

Disposition: keep — two clean intentions, an honest fight, and an evasion whose reward is the damage it avoids.
Findings:
P2: the creature is named only in the victory text ("the Ash Stalker from its cable nest"), after the decision. CREATURE_STORY_BIBLE, shared rules: "Names arrive in the passage… before or during its decision." → name it in the introduction by the survivor's own reckoning or a chalk warning, inside the 60–90 word budget the loader enforces.

---

### rail_platform — The Last Vending Machine   [data/events.json + overrides_v11; underrail; unique=y; weight=3; tags=supply_opportunity]
Scene: one lit machine at the end of a dead platform, still asking for a currency whose symbol no longer exists, with sealed food visible behind glass built to fragment inward.
Evidence on screen: the glow and the payment display; the narrow service slot carrying "a steady electrical hum"; safety glass "designed to fragment inward, toward the hands of anyone impatient enough to test it."
Comparison: [0] wits risky 45–80 healthy / 35–45 depleted; [1] strength risky 50–65 healthy / 35 depleted; no dominance, no redundancy.

[0] Bypass the payment board — intention: make the machine pay out as designed.
    known cost: none; the hum is the warning | uncertain risk: `pressures {health: -10}`, `add_conditions [concussed]`
    success: `items {ration_bar: 2, clean_water: 2}` | failure: as above
    local significance: the machine empties itself politely and its light dies; or the anti-tamper cell fires and the goods stay behind lit glass.
    durable: none.

[1] Break the front panel — intention: take it directly and accept the glass.
    known cost: none; the intro states exactly how the pane fails | uncertain risk: `pressures {health: -12}`, `add_conditions [bleeding]`
    success: `items {ration_bar: 1, stimulant: 1}` | failure: as above
    local significance: the shelves jam with food still visible, which is what makes restraint expensive.
    durable: none.

Disposition: keep — distinct methods, distinct rewards (food and water against food and a stimulant), symmetric and legible risk.
Findings: none. Note for N05, not a defect: this is the Underrail's only `supply_opportunity` (`ContentRepository` requires one per region) and both routes are checks, so a depleted survivor at 35–45% can leave the region's guaranteed supply with nothing.

---

### rail_collapse — Ceiling Dust   [data/events.json + overrides_v11; underrail; unique=n; weight=4; tags=none]
Scene: a ceiling bowed between two arches drops a pebble every few seconds, and the survivor can put a post under it or crawl a cable duct that may not come back out.
Evidence on screen: the interval between falling pebbles, "a countdown without a known final number"; a discarded steel post; a cable duct opening near the floor whose far end is not visible.
Comparison: [0] strength hard 40–55 healthy / 25 depleted; [1] wits risky 45–70 healthy / 35 depleted; no dominance flagged — the Strength kit wins its own cells, so [0] preserves useful expertise under §3.

[0] Brace the weak section — intention: hold the arch up long enough to walk under it.
    known cost: none | uncertain risk: `pressures {health: -20, fatigue: 12}`, `add_conditions [concussed]`, `damage_type physical`
    success: text only | failure: as above
    local significance: the ceiling comes down behind the survivor; the way west closes and the weight stays there.
    durable: none.

[1] Find a service bypass — intention: go around the damage rather than under it.
    known cost: none | uncertain risk: `pressures {fatigue: 16, hunger: 5}`
    success: text only | failure: as above
    local significance: a service panel opens east of the damage, untouched; or the crawl dead-ends at poured concrete and has to be reversed entirely.
    durable: none.

Disposition: revise — as at `rail_flood`, the harder check with the far worse failure pays exactly what the safer one pays.
Findings:
P1: [0] is strength **hard** risking `health -20 / fatigue 12 / concussed` for the same empty success [1] buys at wits **risky** for fatigue → the event is `unique=false`, so differentiate by cost rather than loot: `now: [1] success text only` | `proposed: [1] success pressures {fatigue: 6}` for the long crawl between dead lines. [0] then buys speed with force; [1] buys safety with time.

---

### rail_signal — Green Signal   [data/events.json + overrides_v11; underrail; unique=y; weight=3; tags=none]
Scene: a rail signal turns green with every visible cable cut, and the survivor must decide whether the light is a guide, a trap, or something feeding on the run behind it. Creature host scene: the **Cable Eater** (CREATURE_STORY_BIBLE; §5 record 12).
Evidence on screen: fresh maintenance marks down one powered line; standing water taking the spill of green light; the intro's own warning that "old security systems also used green to draw authorized movement into controlled ground." The bible's three warnings — shed insulation curled like bark on the water, lights dimming in a travelling sequence, a cable tray bowed downward under weight — are **not in the loaded introduction** and must be written in before choice 2 is a fair commitment.
Comparison: [0] wits risky 45–80 healthy / 35–45 depleted; [1] strength favorable 60–75 healthy / 45 depleted; no dominance, no redundancy. Choice 2 is not in the measured set.

[0] Follow the powered line — intention: take the guide the Citadel appears to have left.
    known cost: none | uncertain risk: `pressures {health: -12}`, `add_conditions [shaken]`
    success: `add_flags [citadel_signal]`, `pressures {fatigue: -5}` | failure: as above
    local significance: recently cleaned markers repeat at every junction and aim east — relief, and the dangerous fact of being expected; or a dormant restraint frame wakes on its sensor.
    durable: `citadel_signal` — orphan today. **Decision (§5 record 12 leaves this to batch D): fold, do not retire.** Consumer: a `rail_door` introduction variant in which the survivor who followed the cleaned markers recognizes the same maintenance hand in the challenge display's grouping. Prose only; no mechanical change and no second route to `gate_code`, so record 12's choice 2 stays the only new certainty. Because both events are region-5 unique in random order, the variant simply does not fire when the door comes first — the same honesty record 12 accepts for the reverse order.

[1] Cut power before passing — intention: pass without answering either invitation.
    known cost: none | uncertain risk: `pressures {health: -10}`
    success: text only | failure: `pressures {health: -10}`
    local significance: green fades to black and the survivor crosses in honest darkness, neither guided nor identified. The favorable check paying nothing is correct here: safety is the reward.
    durable: none. Per record 12 this stays a full path and the door plays as authored after it.

[2] APPENDED — Clear the cable run — see §5 record 12 and CREATURE_STORY_BIBLE, Cable Eater. Combat. Victory → `add_flags [cable_run_cleared]` plus `items {scrap_parts: N}`; recommended `scrap_parts: 2`, the region's standard salvage unit (`rail_door` 0 success, `rail_nest` 0 victory), with N05 confirming. Beyond the record: the adversary the bible names, **`enemy_cable_eater`, does not exist in `data/adversaries.json`**, and `ContentRepository._validate_choice` raises "combat choice references missing adversary" for a combat choice whose id is unknown, so this choice cannot load until N05 authors the profile — threat mid-high, HP between the Widow and the Kilnback, damage high on Heavy, sequence Charge / Strike / Sweep / Brace / Recover, critical condition `burned`, **flee risky** (it is faster along the run than a person on wet tile). Choices 0 and 1 keep their labels, checks, and outcomes; the fight is never the only way past the signal.

Disposition: revise — append record 12's choice 2, write the bible's three warnings into the introduction, and fold `citadel_signal` into `rail_door`.
Findings:
P1: `citadel_signal` has no consumer → the `rail_door` introduction variant above (fold, not retire).
P1: choice 2 names an adversary `data/adversaries.json` does not define → N05 adds `enemy_cable_eater` with the profile above before N04 loads the choice; adding it makes the Underrail a three-combat region, which N05 checks against the combat-opportunity cap.
P2: the introduction carries none of the bible's three escalating warnings, so a combat choice added to it would be committed to blind → rewrite within the loader's 60–90 word budget to show the shed insulation, the travelling dim, and the bowed tray.

---

### rail_door — Door Marked EAST CITADEL   [data/events.json + overrides_v11; underrail; unique=y; weight=3; tags=none]
Scene: the first intact EAST CITADEL seal on the road, with a cylinder that can be pulled and a challenge display that changes while it is being read.
Evidence on screen: warnings on the maintenance housing "about consumed tools and unauthorized extraction"; six symbols cycling to black; the sequence shifting "whenever distant relays click, as if the door is testing more than memory."
Comparison: [0] wits hard 35–60 healthy / 25 depleted; [1] wits risky 45–80 healthy / 35–45 depleted; no dominance, no redundancy.

[0] Recover the access cylinder — intention: take a physical token the door cannot re-randomize.
    known cost: the housing's stated appetite for tools | uncertain risk: `items {scrap_parts: -1}`, `pressures {fatigue: 7}`
    success: `items {scrap_parts: 2}`, `add_flags [access_core]` | failure: as above
    local significance: something beyond the door acknowledges the removal — the Citadel has already registered a survivor at this seal.
    durable: `access_core` — orphan today; §5 record 12 gives it `final_gate_1` choice 0 as consumer.

[1] Memorize its challenge code — intention: carry the answer instead of the hardware.
    known cost: none; the intro says it "risks nothing but error" and the failure honours that | uncertain risk: `pressures {fatigue: 6}`
    success: `add_flags [gate_code]` | failure: `pressures {fatigue: 6}`
    local significance: the survivor holds a repeatable sequence the display itself confirmed twice.
    durable: `gate_code` — orphan today; §5 record 12 gives it `final_gate_1` choice 0 as consumer.

[2] APPENDED — Read the code from the steady display — see §5 record 12. `requires.flags [cable_run_cleared]`, `hidden_when_locked: true`, certain → `add_flags [gate_code]`. Beyond the record: the immediate fiction is that the display stops shifting because the load moving it is dead, so the six symbols resolve on the first cycle; no items, no fatigue, no check. It does not make [0] pointless — [0] still pays `scrap_parts 2` and writes the other token — and it is hidden rather than locked because a survivor who never met the Cable Eater has no way to know a steady display was possible.

This scene is also where `citadel_signal` is spent, as an introduction variant only (see `rail_signal` [0]).

Disposition: revise — append record 12's choice 2, add the `citadel_signal` variant, and let record 12's `final_gate_1` gate turn both existing flags from orphans into the door's actual purpose.
Findings:
P1: `gate_code` and `access_core` are orphans in loaded content → consumed by `final_gate_1` choice 0 under §5 record 12; no separate change is proposed here.
P1: [0]'s failure removes `scrap_parts 1` the survivor may not carry and the result panel prints the loss regardless → same clamp-and-variant repair as `rail_survivors`.

---

### final_gate_1 — The East Citadel Gate   [data/events.json + overrides_v11; global finale, `GameEngine.FINAL_EVENT_ID`; unique=y; weight=1; tags=none; adversary_id=citadel_guard]
Scene: floodlights pin the survivor against the outer blast door while a loudspeaker asks for the current challenge response over a visible countdown.
Evidence on screen: rifle apertures opening above; machinery vibrating under the boots; the countdown itself. **Not legitimate evidence:** "The code recovered underground may satisfy a system older than its guards," which the introduction states to every survivor including one who never reached `rail_door` (STORY_CANON §10, "Prose assumes the survivor recognizes the duty voice and a 'recovered gate code' regardless of history").
Comparison: [0] wits hard, `modifier: 1`, 40–70 healthy / 25–40 depleted — **strictly dominant**; [1] presence desperate 20 healthy / 10 depleted (20–25 supplied).

[0] Answer with the recovered gate code — intention: satisfy the protocol rather than the people.
    known cost: none today | uncertain risk: `pressures {health: -20}`, `damage_type physical`, then `next_event bunker41_warden_remembers`
    success: `next_event bunker41_warden_remembers` | failure: as above | critical_success: `add_conditions [focused]`, `next_event bunker41_warden_remembers`
    local significance: locks withdraw one layer at a time, or warning fire drives the survivor into the screening channel; on a critical the route reads as expected civil-defence traffic and the apertures close.
    durable: chain only — see §5 record 12 for the `requires.any_flags [gate_code, access_core]` gate, its reason string "You recovered no gate code", and the introduction variant for a survivor with neither.

[1] Convince the guard you carry vital intelligence — intention: make a person interrupt the machine.
    known cost: none | uncertain risk: `pressures {health: -22}`, `add_conditions [shaken]`, `damage_type physical`, then `next_event bunker41_warden_remembers`
    success: `next_event bunker41_warden_remembers` | failure: as above
    local significance: a human voice interrupts the countdown, or a stun round lands while the speaker asks for supporting evidence. Ungated, and record 12 keeps it so.
    durable: chain only.

All five outcomes (0 success / failure / critical_success, 1 success / failure) set `next_event: bunker41_warden_remembers`, so the gate is a funnel: **it cannot be failed out of.** The durable difference between branches is HP and one condition. STORY_CANON §8 makes that correct — the canonical finale is `final_gate_1` → `bunker41_warden_remembers` → `bunker41_door_closes` — and it is why the dominance below is tolerable.

**On the dominance (asked of this batch).** [0] beats [1] in all 48 cells at no cost, which is textbook §3 dominance. **With record 12's gate it is acceptable**, for two reasons. First, the dominance becomes conditional on evidence earned at a unique region-5 event, which is the same allowance §5 record 9 grants the Kilnback ("Earned expertise: allowed to dominate choice 1"). Second, losing the contest is not exclusion: [1]'s failure still reaches the Warden, so the price of arriving without a code is HP and a condition, not a closed road. What the gate must not do is pretend the code exists when it does not, and today it does — see the P0 below.

**On `citadel_guard` (asked of this batch).** The Guard stays a **threat in prose**; no combat choice is justified here. The adversary is declared at scene level and fought nowhere in the loaded content, and it should stay that way: (a) the fight that belongs at the gate already exists one scene later, `bunker41_warden_remembers` choice 1 against `warden_machine` with `can_flee: false`, and stacking a 400-HP squad in front of a 550-HP machine at the end of a permadeath run is a difficulty wall, not a decision; (b) STORY_CANON §7 makes the guards' function social — "A living guard behind glass can still decide 'as a person before the machine decides for them'" — which choice 1 and `final_gate_3` [2] both depend on and which killing them destroys; (c) plan §6 explicitly forbids adding "a mandatory fight just to justify a sentence"; (d) the declaration already does work, framing the rifle apertures and the portrait. Keep the field, add no choice.

Disposition: revise — gate choice 0 per record 12 and write the two introduction variants; the structure and the funnel stand.
Findings:
P0: the introduction and choice 0 assert a "recovered gate code" for every survivor, including one who never met `rail_door` → §5 record 12's gate and introduction variant. False history, not merely a balance issue.
P0 (chain; batch E owns the passage, found here): `bunker41_warden_remembers`, which every branch of this event enters, says the machine "asks for authorization in the voice of the woman from the salt flats." STORY_CANON §5 keys recognition to `b41_contact` — but in loaded content `b41_contact` is written by `bunker41_rusted_hatch` (region 4, all three choices) and `bunker41_door_breathes`, **not** by the salt-flats signal `bunker41_static`, which writes `b41_recording`, `b41_answered`, or `b41_unprepared`. Keying the variant on `b41_contact` therefore recognizes the wrong survivors in both directions → proposed new flag `b41_voice_heard`, written by all three `bunker41_static` outcomes, consumed by the recognition variants in `bunker41_warden_remembers` and, if N06 wants one, `final_gate_1`. The obvious alternative, `any_flags [b41_recording, b41_answered, b41_unprepared]`, over-fires because `bunker41_rusted_hatch` choice 2 also writes `b41_unprepared`.
P1: once choice 0 is gated, a survivor holding neither token faces a single desperate Presence check at 10–25% and a near-certain `health -22 / shaken` immediately before the Warden. That is survivable but is the sharpest spike in the game → N05 reviews `[1] check.difficulty now: desperate` against a `hard` band (which would read 35 healthy / 25 depleted, per the `rail_hunters` [2] row); `data/legacy_v2_checks.json` pins `final_gate_1:1` at 17 and would have to move with it.
P1: the finale runs 79 introduction words and 35-word outcomes and acknowledges nothing the survivor did on the road. Plan §3 targets 180–280 / 150–260 for a finale → N04's shared scene-role budget contract first (`ContentRepository` currently errors outside 60–90 and 30–50), then the rewrite.

---

### final_gate_2 — Secondary Screening   [data/events.json + overrides_v11; global; unique=y; weight=1; tags=none; adversary_id=warden_machine]
Scene: a damaged Warden machine declares the survivor contaminated beyond admission limits and stands between them and the manual gate control.
Evidence on screen: the bright groove its damaged wheel assembly cuts across concrete; one sensor flickering whenever the turret turns; the manual control standing behind the patrol arc.
Comparison: [0] wits desperate 20–55 healthy / 10–20 depleted; [1] `fight T20 +100xp flee:n`; [2] agility desperate 20–45 healthy / 10 depleted; no dominance, no redundancy.
**Reachability: none.** No outcome in any loaded file sets `next_event: final_gate_2`; `final_gate_1` sends all five of its branches to `bunker41_warden_remembers`. STORY_CANON §8 and §10 record this as compatibility content for N06.

[0] Overload its damaged sensor — intention: blind the machine instead of beating it.
    known cost: none | uncertain risk: `pressures {health: -28}`, `add_conditions [burned]`, `damage_type physical`, `next_event final_gate_3`
    success: `next_event final_gate_3` | failure: as above
    local significance: the Warden rotates toward ghosts and keeps refusing entry to positions where nobody stands.
    durable: chain to `final_gate_3` only.

[1] Attack its wheel assembly — intention: end the machine rather than evade it.
    known cost: a fight with the Warden Machine — threat 20, xp_reward 100, 550 HP, 100–150 damage, critical condition `burned`, `can_flee: false` | uncertain risk: no retreat; defeat is death
    success: `victory` `next_event final_gate_3`, no items | failure: no failure branch
    local significance: the armour folds and the turret hits concrete, and the thing keeps speaking. One of only two `warden_machine` fights in loaded content; the other is `bunker41_warden_remembers` 1.
    durable: chain only. If N06 re-routes, this is where the proposed `warden_broken` flag would be written (see `final_gate_3`).

[2] Slip through its scanning arc — intention: cross the interval its calculations cannot cover.
    known cost: none | uncertain risk: `pressures {health: -26, fatigue: 10}`, `damage_type physical`, `next_event final_gate_3`
    success: `next_event final_gate_3` | failure: as above
    local significance: the survivor reaches the manual controls while the machine searches empty concrete.
    durable: chain only.

Disposition: redesign — **re-route rather than retire**; the intention set is already right (blind it, break it, cross it) and needs only a way in. See the recommendation under `final_gate_3`.
Findings:
P0: unreachable content counted as reachable — nothing routes here, so three choices and the whole `final_gate_3` chain behind them are dead while still loading → N06 decides re-route or retire; N07 removes the ending from the denominator either way (STORY_CANON §8).

---

### final_gate_3 — One Person Through   [data/events.json + overrides_v11; global; unique=y; weight=1; tags=none]
Scene: the inner gate opens a hand's width over a mechanism grinding toward permanent failure, with the Warden recovering behind and a guard watching through armoured glass.
Evidence on screen: clean air escaping the gap; warning lamps stating that forcing may trigger crushing closure; lethal voltage displayed around rejected commands; the guard behind the glass. That is three concrete warnings plus a visible operator, which satisfies the LIVING_ROAD_NARRATIVE_BIBLE rule for a lethal route.
Comparison: [0] strength desperate 25–40 healthy / 10 depleted; [1] wits desperate 20–55 healthy / 10–20 depleted; [2] presence desperate 20 healthy / 10 depleted — **redundant: [0,2]**.
Reachability: only from `final_gate_2`, which nothing reaches. Its five `victory: true` outcomes and `ledger_ending_citadel` (`data/road_ledger.json`, `event_id: final_gate_3`) are unreachable while still counted, because `ContentRepository._load_discovery_entries` keeps any entry whose event loads.

[0] Force the gate apart — intention: take the door with your body.
    known cost: none | uncertain risk: `failure {damage_type: physical, lethal: true}`; `critical_failure {damage_type: physical, lethal: true}`
    success: `victory: true` | critical_success: `victory: true` — "survival creates a door another person might use", the only outcome in the scene that leaves anything behind for anyone else
    local significance: old gears surrender teeth and the opening seals behind the survivor's last step.
    durable: run ends.

[1] Complete the emergency override — intention: finish the machine's own procedure.
    known cost: none | uncertain risk: `failure {lethal: true}` (no `damage_type`); `critical_failure {lethal: true}`
    success: `victory: true` | critical_success: `victory: true`
    local significance: the controller spends its last power opening the gate.
    durable: run ends.

[2] Order the guard to open it now — intention: make a person decide before the machine does.
    known cost: none | uncertain risk: `failure {damage_type: physical, lethal: true}`; `critical_failure {damage_type: physical, lethal: true}`
    success: `victory: true` | critical_success: `victory: true` — the guard calls the survivor's own name from the screening record
    local significance: STORY_CANON §7's Citadel line lands here: "A living guard behind glass can still decide 'as a person before the machine decides for them.'"
    durable: run ends.

Disposition: redesign — re-route with `final_gate_2`, and break the [0,2] identity by requirement, which is the only differentiator a victory ending leaves available.
Findings:
P1: [0] and [2] are field-identical (`victory: true`; `damage_type: physical` + `lethal: true` on both failure branches), differing only in stat and prose. §3 excuses `bunker41_door_closes` 0–3 because those four are distinguished **by requirements**; these three are not distinguished at all, and because the run ends on success no post-victory field can differentiate them → the required change is a requirement. Proposed: `[2] requires.any_flags [warden_broken]`, reason "The Warden is still tracking you", where `warden_broken` is a **new flag written by `final_gate_2` choice 1 victory** and read only here — a guard breaks protocol for someone standing over a disabled machine, not for someone it is reacquiring, which the introduction already says it is doing. [0] stays ungated as the always-available answer, mirroring Silence in §8.
P0: [1] success says "You rebuild the emergency sequence from every relay lesson gathered below" to a survivor who may have read no relay at all — the same false history record 12 repairs at `final_gate_1` → `[1] requires.any_flags [gate_code, access_core, citadel_signal]`, reason "You never read a Citadel controller". This is a second, mechanical consumer for `citadel_signal`, contingent on the re-route.
P0: unreachable finale still defined and counted (STORY_CANON §10) → as `final_gate_2`.

**Recommendation to N06: re-route, do not retire.** Reasons. (1) Retiring deletes five `victory: true` outcomes and `ledger_ending_citadel`, the only ending not routed through `bunker41_door_closes`; §8 already notes Witness is "the Chronicle's only reachable ending entry today", so the ending set is thin before any deletion. (2) There is a survivor the canon describes who has nothing to say to the Warden: the one who never touched Bunker Forty-One. `bunker41_warden_remembers` offers Refuse, an unfleeable 550-HP fight, or "Invoke the Bunker record" gated on five Bunker flags — so a Bunker-less survivor meets the canonical finale with two options, one of which is a wall. `final_gate_2` → `final_gate_3` is exactly the no-inherited-permission route: blind it, break it, or cross it, then force, knowledge, or authority. (3) It gives `warden_machine` a scene where it can be evaded rather than only fought, and makes `ledger_ending_citadel` reachable for N07's denominator. (4) It costs no new prose: three cards' worth of content already exists and is in budget. (5) It does **not** give `citadel_guard` a fight, and should not; see `final_gate_1`.

Implementation caveat this card may not settle: with supported fields the only ways in are a new gated choice on `final_gate_1` (`requires.forbids_flags [b41_contact]`, certain, `next_event: final_gate_2` — the event has room, holding two of four choices) or a conditional-`next_event` engine extension, a third extension beyond the two §5 assumes. No §5 record asks for a `final_gate_1` choice 2 and no P0 blocked action requires one, so this card records the shape and leaves the decision to N06 rather than proposing the choice. If N06 chooses the flag route, note the `b41_contact` defect recorded under `final_gate_1`: the flag does not mean what canon §5 says it means, and the gate should read whichever flag N06 settles on there.

---

## Batch summary

DISPOSITIONS:
rail_hunters | revise | choice 2's ammunition price is neither charged nor gated and its success pays nothing
rail_train | revise | good scene, but met_train_family has no reader
rail_flood | revise | the hard route pays exactly what the safer route pays
rail_survivors | revise | append record 10's choice 2, give fixed_platform_pump a reader, carry the record 9 and met_train_family variants
rail_switch | revise | the hard ungated route pays less than the favorable gated one
rail_nest | keep | two clean intentions and the game's only Ash Stalker fight, honestly priced
rail_platform | keep | distinct methods and distinct rewards at symmetric risk
rail_collapse | revise | the hard route with the far worse failure pays no premium
rail_signal | revise | append record 12's choice 2, write the bible's three warnings, fold citadel_signal into rail_door
rail_door | revise | append record 12's choice 2 and add the citadel_signal introduction variant
final_gate_1 | revise | gate choice 0 on recovered evidence and write the two introduction variants
final_gate_2 | redesign | unreachable compatibility content; re-route as the Bunker-less survivor's path rather than retire
final_gate_3 | redesign | unreachable, and [0,2] are field-identical; differentiate by requirement

FINDINGS:
P0 | rail_hunters | 2 | ammunition price sits in the outcome as items {pistol_rounds: -2}, so a survivor with none pays nothing while the passage says the payment was collected → move it to costs.items {pistol_rounds: 2} and drop the item line from both branches
P1 | rail_hunters | 2 | success grants nothing while the comparison flags [1] strictly dominant → add pressures {fatigue: -5} to the success; keep the choice for its Presence expertise
P1 | rail_train | 0 | met_train_family is an orphan → consume it as a rail_survivors introduction variant recognizing the junction marks, or retire it
P1 | rail_flood | 0 | agility hard [1] risks health -22 / fatigue 15 / concussed for the same empty success strength risky [0] buys → add pressures {fatigue: 6} to [0] success; no item reward, the event is repeatable
P1 | rail_survivors | 1 | fixed_platform_pump is an orphan → consume it as an lr_valve_below introduction variant (batch F, N04)
P1 | rail_survivors | - | failure branches assert ration_bar -1 and scrap_parts -2 the survivor may not hold, and the result panel prints the loss anyway → clamp the reported change to what was removed and add a variant for an empty pack
P1 | rail_switch | 1 | wits hard [1] with the worse failure has an empty success while wits favorable [0] pays fatigue -5 → add pressures {fatigue: -8} to [1] success
P2 | rail_nest | - | the Ash Stalker is named only after victory, against the creature bible's rule that names arrive before or during the decision → name it in the introduction
P1 | rail_collapse | 1 | strength hard [0] risks health -20 / fatigue 12 / concussed for the same empty success wits risky [1] buys → add pressures {fatigue: 6} to [1] success for the long crawl
P1 | rail_signal | 0 | citadel_signal is an orphan → fold it into a rail_door introduction variant; do not retire
P1 | rail_signal | 2 | the appended combat choice names enemy_cable_eater, which data/adversaries.json does not define and the loader rejects → N05 authors the profile (threat mid-high, HP between Widow and Kilnback, Charge/Strike/Sweep/Brace/Recover, critical burned, flee risky)
P2 | rail_signal | - | the introduction carries none of the bible's three Cable Eater warnings, so choice 2 would be committed to blind → rewrite within the 60-90 word budget
P1 | rail_door | - | gate_code and access_core are orphans in loaded content → consumed by final_gate_1 choice 0 under §5 record 12
P1 | rail_door | 0 | failure removes scrap_parts 1 the survivor may not hold and still reports it → same clamp and variant as rail_survivors
P0 | final_gate_1 | 0 | introduction and choice assert a recovered gate code to every survivor → §5 record 12's requires.any_flags [gate_code, access_core], reason "You recovered no gate code", plus the codeless introduction variant
P0 | final_gate_1 | - | the chained bunker41_warden_remembers claims recognition of the salt-flats voice, but STORY_CANON §5 keys it to b41_contact, which is written by bunker41_rusted_hatch and bunker41_door_breathes rather than by bunker41_static → add flag b41_voice_heard on all three bunker41_static outcomes, consumed by the warden_remembers and final_gate_1 introduction variants
P1 | final_gate_1 | 1 | with choice 0 gated, a codeless survivor faces one desperate Presence check at 10-25% and near-certain health -22 / shaken before the Warden → N05 reviews difficulty desperate against hard; legacy_v2_checks pins final_gate_1:1 at 17
P1 | final_gate_1 | - | the finale is 79 introduction words and 35-word outcomes and acknowledges nothing the survivor did → N04's scene-role budget contract first, then the rewrite toward plan §3's 180-280 / 150-260
P0 | final_gate_2 | - | nothing routes here, so three choices and the whole final_gate_3 chain are unreachable while still loading → N06 re-routes (recommended) or retires; N07 fixes the denominator
P1 | final_gate_3 | 2 | [0] and [2] are field-identical and a victory ending leaves no post-success field to differentiate → requires.any_flags [warden_broken], a new flag written by final_gate_2 choice 1 victory and read only here; [0] stays ungated
P0 | final_gate_3 | 1 | success claims the survivor rebuilt the sequence "from every relay lesson gathered below" with no evidence they read one → requires.any_flags [gate_code, access_core, citadel_signal], reason "You never read a Citadel controller"
P0 | final_gate_3 | - | unreachable finale still defined and counted, including ledger_ending_citadel → as final_gate_2
