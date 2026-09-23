# Consequence cards — Batch F: The Rust-Sea and the Living Road

Cards for the 8 Rust-Sea events (`data/rustsea_events.json`, chain order) and the 15 Living Road callbacks (`data/living_road_events.json`, by thread). Template: [NARRATIVE_CONSEQUENCE_MAP.md](../NARRATIVE_CONSEQUENCE_MAP.md) §2. Odds are quoted from [builds/choice_comparison.md](../../builds/choice_comparison.md); none are estimated here. Canon is quoted by section from [STORY_CANON.md](../STORY_CANON.md); prose is judged against [LIVING_ROAD_NARRATIVE_BIBLE.md](../LIVING_ROAD_NARRATIVE_BIBLE.md).

Batch conventions:

- Both files load as authored; neither override file touches them.
- The five Living Road threads are §5 records 1–5; the Rust-Sea is records 6 and 7. **See §5 record N** means the card records only immediate effects plus what the record does not state.
- Every Living Road outcome also writes `lr_callback_region_N`; recorded once per event. Consumer: the `eligibility.forbids_flags` of that region's callback chapters, allowing one callback chapter per region per run.
- No choice in this batch is a combat choice, so no adversary, threat, XP, or flee field appears.
- Every Rust-Sea choice is certain, so each Rust-Sea scene reports as a mutual tie ("ties every sibling"). Map §3: expected, judged by durable effect.
- The Presence kit is unmeasured (map §3); Presence checks note the gap rather than guess.
- All 23 introductions are 62–89 words and all 89 outcomes 32–48 words, so nothing is under budget or padded: no length findings.

## Rust-Sea

### rustsea_green_line — A Voice on the Green Line   [rustsea_events.json; global, region 5 only; unique=y; weight=11; priority=11; tags=chain head; requires any of b41_mara_helped / b41_mara_abandoned / b41_recording / b41_contact]
Scene: A dead rail speaker wakes after midnight, dictates coordinates in a woman's voice, and warns against water that knows your name.
Evidence on screen: salt-crusted grille, wet click; the pencil-scratch pause saying the numbers are meant to be written down (0); the signal box and its wiring (1); a speaker that can be cut loose (2).
Comparison: three certain choices; all three flagged mutually dominant ("ties every sibling") — the expected Rust-Sea tie.

[0] Follow the coordinates — intention: walk the dictated route to whoever is sending it.
    known cost: none | uncertain risk: none (certain)
    outcome: add_flags [rustsea_green_line], next_event rustsea_quay_names
    local significance: the survivor leaves the mapped track for drowned platforms; a green thread is freshly tied to the signal post.
    durable: rustsea_green_line → rustsea_quay_names and rustsea_false_coordinates eligibility.
[1] Trace the signal first — intention: find the source before obeying it.
    known cost: none | uncertain risk: none
    outcome: add_flags [rustsea_green_line], next_event rustsea_false_coordinates
    local significance: the wire ends in older cable under the salt; the ground carries the first Salt Crown tell.
    durable: as [0].
[2] Silence the speaker — intention: refuse the summons.
    known cost: none | uncertain risk: none
    outcome: add_flags [rustsea_map_self_marked]; no next_event
    local significance: the survivor's own map acquires a pencil line ending at a drowned tower.
    durable: orphan: rustsea_map_self_marked → proposed consumer: rustsea_quay_names eligibility `requires_flags [rustsea_green_line]` → `requires_any_flags [rustsea_green_line, rustsea_map_self_marked]`, so refusal delays the chain instead of deleting it and the mark keeps its promise.

Disposition: revise — the introduction names Mara to survivors who never met her; choice 2's mark leads nowhere.
Findings:
P0: body says "Mara Venn's voice" although b41_recording (salt-flats tape) and b41_contact (hatch only) survivors never met her; STORY_CANON §5: "the prose must not say they do" → introduction variants: recognition for b41_mara_helped / b41_mara_abandoned, otherwise the message signs off with a name the survivor cannot place, which keeps downstream labels supported.
P1: orphan rustsea_map_self_marked → consumer above.

### rustsea_quay_names — The Quay of Names   [rustsea_events.json; global; unique=y; weight=1; tags=requires rustsea_green_line]
Scene: A tiled wall of scratched and charcoaled names stands out of the flooded concourse, several belonging to families the Citadel is said to have admitted.
Evidence on screen: nail-cut names beside fresh charcoal; the green-line trail (0); the length of the list (1); the water working at the letters (2 — see the P0).
Comparison: three certain choices, mutual tie.

[0] Search for Mara's name — intention: pick the cartographer's trail back up.
    known cost: none | uncertain risk: none
    outcome: add_flags [rustsea_mara_trace], next_event rustsea_station_arrivals
    local significance: a station key, an arrow reading green light, noon, and her note that she was wrong about the route east.
    durable: rustsea_mara_trace → rustsea_station_arrivals eligibility.
[1] Copy every name — intention: carry the wall away as a record.
    known cost: none | uncertain risk: none
    outcome: add_flags [rustsea_names_copied, rustsea_children_clue]; no next_event
    local significance: the survivor holds names that should have ended at the gate, plus the margin note living people below.
    durable: orphan: rustsea_names_copied, orphan: rustsea_children_clue → proposed consumers: a rustsea_voice_map introduction variant on children_clue (the child waiting for the evacuation bus is one of those names) and a rustsea_voice_map choice 2 success variant on names_copied (the attendance completes because the survivor carries the wall). STORY_CANON §6 calls the copied names a record, not testimony, so they must not gate a testimony ending.
[2] Deface the wall — intention: destroy the list before anyone uses it.
    known cost: none | uncertain risk: none
    outcome: add_flags [rustsea_ash_marks_damaged]; no next_event
    local significance: the names go under mud and salt; a lantern crossed by three strokes appears across the water.
    durable: orphan: rustsea_ash_marks_damaged → proposed consumer: bunker41_ash_procession introduction variant (also region 5; cross-batch E).

Disposition: revise — plan §6: the motive for choice 2 exists only after selection.
Findings:
P0 (unfair commitment, plan §6): choice 2's protective motive ("before any faction can make a banner of them") appears only in the outcome → replace the body's closing sentence ("The water taps beneath those names...") with observed motive: someone already copying the wall onto banner cloth in charcoal, a lantern-and-three-strokes mark drying on the far pillar. Body 79 → about 84 words, inside budget, and it gives choice 1 a rival.
P1: orphans rustsea_names_copied, rustsea_children_clue, rustsea_ash_marks_damaged → consumers above.

### rustsea_false_coordinates — The False Coordinates   [rustsea_events.json; global; unique=y; weight=1; tags=requires rustsea_green_line; lethal route]
Scene: The traced signal leads into a salt channel where a truck has been folded shut and the voice starts asking you to come closer.
Evidence on screen: vibration through the crust when the wind stops; the folded truck; the message degrading into "come closer, I cannot see you".
Comparison: three certain, mutual tie. Choices 0 and 1 write the same flag and differ only by next_event (station vs caravan) — the intended fork, not redundancy.
Lethal warnings, confirmed in the loaded prose: **scale** — steel "folded inward in long smooth bends, as if a hand enormous enough to close around it became impatient"; **ordinary protection failed** — that folded frame is the protection; **withdrawal** — choice 0 is present and ungated.

[0] Retreat to the embankment — intention: get off the crust without provoking it.
    known cost: none | uncertain risk: none
    outcome: add_flags [rustsea_salt_warning], next_event rustsea_station_arrivals
    local significance: the vibration fades; a raised service line leads to the drowned station.
    durable: rustsea_salt_warning → rustsea_station_arrivals and rustsea_salt_crown_wake eligibility.
[1] Cross before it rises — intention: beat the thing under the salt to the far side.
    known cost: none | uncertain risk: none
    outcome: add_flags [rustsea_salt_warning], next_event rustsea_salt_crown_wake
    local significance: the salt breaks in rings behind the survivor; something pale moves without surfacing.
    durable: as [0].
[2] Enter the hollow below — intention: answer the voice at its source.
    known cost: the three warnings | uncertain risk: death
    outcome: lethal: true; no items, no flags
    local significance: the run ends; STORY_CANON §5 is kept — the passage explains nothing.
    durable: none.

Disposition: keep — the lethal route carries its warnings and the survivable branches fork the chain.
Findings: none.

### rustsea_station_arrivals — The Station Without Arrivals   [rustsea_events.json; global; unique=y; weight=1; tags=requires any of rustsea_mara_trace / rustsea_salt_warning]
Scene: A terminus ending in open water holds Mara's shelter and a wall of routes, each crossed out by a different hand.
Evidence on screen: string maps, medicine tins, a broken compass; the newest uncrossed line (0); the compass to wedge an answer behind (1); dry paper in a wet room (2).
Comparison: three certain, mutual tie.

[0] Take Mara's newest route — intention: follow her last correction.
    known cost: none | uncertain risk: none
    outcome: add_flags [rustsea_mara_route], next_event rustsea_cartographers_debt
    local significance: the line ends at a lit signal hut on stilts with no boat tied.
    durable: rustsea_mara_route → rustsea_cartographers_debt eligibility.
[1] Leave Mara a message — intention: answer her note instead of following it.
    known cost: none | uncertain risk: none
    outcome: add_flags [rustsea_message_left], next_event rustsea_voice_map
    local significance: new pencil marks join voices to places the survivor has never visited.
    durable: rustsea_message_left → rustsea_voice_map eligibility.
[2] Burn the maps — intention: stop anyone else being led here.
    known cost: none | uncertain risk: none
    outcome: add_flags [rustsea_maps_burned]; no next_event
    local significance: the routes are gone; lantern reflections move where no boats were. STORY_CANON §6: a real loss nothing rewards or punishes.
    durable: orphan: rustsea_maps_burned → proposed consumer: a rustsea_cartographers_debt introduction variant (reachable via rustsea_salt_crown_wake 1 → rustsea_mara_route) in which Mara's walls hold no station copies and she asks about the smoke that came east — evidence, not state (§5).

Disposition: revise — only to give the burn a reader.
Findings:
P1: orphan rustsea_maps_burned → consumer above.

### rustsea_salt_crown_wake — The Salt Crown's Wake   [rustsea_events.json; global; unique=y; weight=1; tags=requires rustsea_salt_warning; lethal route]
Scene: A caravan lies arranged around a breathing hole in the salt, unwounded, while one survivor knocks under canvas and something scrapes stone below.
Evidence on screen: the faint knocking (0); the wagons' packs (1); the warm hole and the scrape (2); three words in brown salt: do not make noise.
Comparison: three certain, mutual tie.
Lethal warnings, confirmed: **protection failed** — wagons, animals and people dead without wounds, mouths packed with crystals; **scale** — a hole that breathes and something scraping beneath it; **withdrawal** — the written warning plus two options that leave. STORY_CANON §5 is kept: never explained, fought, or looted.

[0] Free the trapped survivor — intention: get the person out without making noise.
    known cost: none | uncertain risk: none
    outcome: add_flags [rustsea_survivor_saved, rustsea_mara_trace], next_event rustsea_voice_map
    local significance: a person lives and gives a folded map; Mara passed yesterday toward the drowned tower.
    durable: rustsea_survivor_saved → rustsea_voice_map eligibility; rustsea_mara_trace → rustsea_station_arrivals eligibility.
[1] Take supplies and leave — intention: strip the caravan and go.
    known cost: none stated | uncertain risk: none
    outcome: items none, add_flags [rustsea_caravan_taken, rustsea_mara_route], next_event rustsea_cartographers_debt
    local significance: every tin is salt-split; the survivor leaves empty-handed while the knocking continues.
    durable: rustsea_mara_route → rustsea_cartographers_debt; orphan: rustsea_caravan_taken → retire (routing is carried by rustsea_mara_route).
    plan §6 fix — honest uncertain search: label unchanged, add `approach: "salvage"`, `check: {stat: "agility", difficulty: "risky"}` (that pairing already exists in loaded content). now: certain, items none | proposed success: items {canned_meat: 1, clean_water: 1}, same add_flags, same next_event | proposed failure: pressures {fatigue: 6}, same add_flags, same next_event, current text becoming the failure text. Failure must not be lethal or show the Crown (§5); identical routing keeps the chain.
[2] Climb into the hollow — intention: reach what is breathing below.
    known cost: the three warnings | uncertain risk: death
    outcome: lethal: true; no items, no flags
    local significance: the knocking stops. The run ends.
    durable: none.

Disposition: revise — deliver choice 1 as an honestly uncertain search.
Findings:
P0 (false reward, plan §6): "Take supplies and leave" is certain and grants no items → the checked search above.
P1: orphan rustsea_caravan_taken → retire.

### rustsea_cartographers_debt — The Cartographer's Debt   [rustsea_events.json; global; unique=y; weight=1; tags=requires rustsea_mara_route; see §5 records 6 and 7]
Scene: Mara spreads a route to the Sunken Spire in a stilt hut and says it only works if two people carry it.
Evidence on screen: maps on walls, ceiling and coat; the unmatched second boot; the halved route on the table (0, 1); the Key in the survivor's pack (2).
Comparison: three certain, mutual tie; [2] gated by flag b41_mercy_key, measured with the gate satisfied.

[0] Help Mara reach the Spire — intention: carry half a route with the person who drew it. See §5 record 6.
    known cost: none | uncertain risk: none
    outcome: add_flags [rustsea_mara_allied, rustsea_spire_route], next_event rustsea_last_coordinate
    local significance: the route is halved; both halves point at the same drowned tower waiting for noon.
    durable: rustsea_spire_route → rustsea_last_coordinate eligibility; orphan: rustsea_mara_allied → proposed rustsea_last_coordinate introduction variant.
[1] Keep the map and leave her — intention: take the whole route alone.
    known cost: none | uncertain risk: none
    outcome: add_flags [rustsea_mara_betrayed, rustsea_spire_route], next_event rustsea_last_coordinate
    local significance: a rail speaker begins repeating the survivor's callsign and the word thief.
    durable: as [0]; orphan: rustsea_mara_betrayed → same proposed variant.
[2] Give Mara the Mercy Key — intention: put SOTERIA's token in the hands of the person who can read the water. requires flags [b41_mercy_key]. See §5 record 7, which fixes possession and names every consumer.
    known cost: the Key leaves the survivor's hands | uncertain risk: none
    outcome: add_flags [rustsea_key_with_mara, rustsea_spire_route]; no next_event
    local significance: lamps answer from the water and she says the Key showed her a city under the sea — reported as belief (§5), never confirmed.
    durable: rustsea_key_with_mara → record 7's forbids on door_closes 1, warden_remembers 2, chapel_car 0; rustsea_spire_route → rustsea_last_coordinate.

Disposition: revise — record 7's transfer gate and record 6's variants; immediate mechanics otherwise stand.
Findings:
P0 (plan §6, STORY_CANON §6): the transfer leaves b41_mercy_key set, so Mercy is still offered at the gate → implement §5 record 7 exactly; this card asserts no different contract.
P1: [2] has no next_event while its siblings chain, so the Spire chapter it promises depends on a weight-1 draw in the final region → add `next_event: "rustsea_last_coordinate"`.
P1: orphans rustsea_mara_allied, rustsea_mara_betrayed → rustsea_last_coordinate introduction variants.

### rustsea_voice_map — The Map Made of Voices   [rustsea_events.json; global; unique=y; weight=1; tags=requires any of rustsea_message_left / rustsea_survivor_saved]
Scene: A map speaks names when unfolded, its voices marked as routes rather than people.
Evidence on screen: the named voices — a child waiting for the evacuation bus, a man whose name is on the drowned wall; the one route they all agree on (0); paper that can be closed (1 — the receiver is not on screen, see the P1); the empty station to speak into (2).
Comparison: three certain, mutual tie.

[0] Trust the shared route — intention: take the way every voice agrees on.
    known cost: none | uncertain risk: none
    outcome: add_flags [rustsea_voice_trusted, rustsea_spire_route], next_event rustsea_last_coordinate
    local significance: the drowned tunnels are avoided; the voices quiet at the green light with one instruction, reach it before noon.
    durable: rustsea_spire_route → rustsea_last_coordinate; orphan: rustsea_voice_trusted → proposed last_coordinate introduction variant.
[1] Silence the receiver — intention: keep the paper and stop the voices.
    known cost: none | uncertain risk: none
    outcome: add_flags [rustsea_voices_silenced]; no next_event
    local significance: something human is left behind in the dark, and the chain ends because no spire_route is written.
    durable: orphan: rustsea_voices_silenced.
[2] Name the dead aloud — intention: make the voices an attendance instead of a route.
    known cost: none | uncertain risk: none
    outcome: add_flags [rustsea_named_dead, rustsea_spire_route, b41_witness]; no next_event
    local significance: the echoes become a roll call; a new line appears beside two words, bring witnesses.
    durable: b41_witness → bunker41_warden_remembers 2 and bunker41_door_closes 2 (§5 record 8; STORY_CANON §8 Witness) — the batch's strongest durable effect, a Rust-Sea act that reaches an ending; rustsea_spire_route → last_coordinate; orphan: rustsea_named_dead → proposed last_coordinate variant.

Disposition: revise — one unpaid promise, one absent object, one broken chain link.
Findings:
P0 (lost promised return): choice 1 states "A later signal will carry the names you chose not to hear" and rustsea_voices_silenced is read nowhere in the four data files or road_ledger.json → deliver it as a bunker41_warden_remembers introduction variant on the flag (permitted by §5's rule that SOTERIA recognizes everyone; cross-batch E), or cut the promise sentence.
P1: the "receiver" never appears in the introduction, which establishes only a speaking map → name it in the body or silence the map itself.
P1: [2] writes spire_route with no next_event while [0] chains → add `next_event: "rustsea_last_coordinate"`.
P1: orphans rustsea_voice_trusted, rustsea_named_dead → last_coordinate introduction variants.

### rustsea_last_coordinate — The Last Coordinate   [rustsea_events.json; global; unique=y; weight=1; tags=requires rustsea_spire_route; thread finale]
Scene: At noon the flooded horizon opens and the Sunken Spire rises, unrowed boats drifting at its base, each holding a lantern and a paper name.
Evidence on screen: green windows behind rain; Mara's route trembling in hand (0); the pulse of the light (1); the lanterns and their names (2).
Comparison: three certain, mutual tie.

[0] Take Mara's mapped route — intention: reach the Spire on the marked shallows.
    known cost: none | uncertain risk: none
    outcome: add_flags [rustsea_spire_reached, rustsea_mapped_entry]; no next_event
    local significance: the water stays knee-deep but feels deep enough to hold a city; the windows answer one by one.
    durable: orphan: rustsea_mapped_entry; orphan: rustsea_spire_reached — see the shared proposal.
[1] Wait for the signal to change — intention: read the light's rhythm before committing.
    known cost: none | uncertain risk: none
    outcome: add_flags [rustsea_spire_reached, rustsea_late_entry]; no next_event
    local significance: shapes move around the base between pulses; one boat drifts close enough to board.
    durable: orphan: rustsea_late_entry.
[2] Leave proof for another traveler — intention: make the route survive the survivor.
    known cost: none | uncertain risk: none
    outcome: add_flags [rustsea_spire_reached, rustsea_route_shared]; no next_event
    local significance: a copy floats toward the old rail road; the survivor turns east with the original.
    durable: orphan: rustsea_route_shared.

Local resolution (plan §6; STORY_CANON §10 assigns N06 to "resolve locally, turn east, keep the Spire a mystery (§5)"). Text only, fields unchanged: **[0]** the marked shallows end at the lantern ring, which is where Mara drew them to end — the survivor lifts one paper name from a boat, takes the noon bearing, and walks the raised rail east before the light fails; **[1]** waiting past the pulse closes the shallows, so the drifted boat can be boarded but the crossing cannot — the name is read at the shore in the dark and the survivor turns east having seen the Spire without approaching it; **[2]** already turns east and is the model, keep as authored.
Proposed consumers: ledger_rustsea_spire gains three variants requiring rustsea_mapped_entry / rustsea_late_entry / rustsea_route_shared (it has none today; every Living Road ledger entry uses them). rustsea_spire_reached is the Rust-Sea's thread-complete marker → §5 scheduling termination test, or retire as redundant with the ledger entry's event trigger. Also proposed: introduction variants keyed to how the route was obtained — rustsea_mara_allied (Mara at the shore with the other half), rustsea_mara_betrayed (the thief broadcast reaches the water), rustsea_key_with_mara (the lamps answer her), rustsea_voice_trusted (the agreeing voices go quiet), rustsea_named_dead (the boats carry names already read aloud). One change, five orphans consumed.

Disposition: redesign — the three intentions stay, but each outcome must resolve locally and turn east instead of reading like entry to an unwritten chapter.
Findings:
P0 (lost promised return, STORY_CANON §10): [0] and [1] read as entering a Spire that has no chapter → rewrite as above.
P1: orphans rustsea_mapped_entry, rustsea_late_entry, rustsea_route_shared, rustsea_spire_reached → ledger variants and the scheduling test above.

## The Living Road

### Thread 1 — Channel Nine, the Vale family (§5 record 1)

### lr_blue_van — The Blue Van   [living_road_events.json; global, region 1 only; unique=y; weight=3; priority=7; thread=family_on_nine; forbids lr_callback_region_1; see §5 record 1]
Scene: The Vale family's van waits where the salt road divides, a woman holding a radio overhead while two children watch from under the chassis.
Evidence on screen: the painted nine and blanket curtains; the callsign repeated aloud (0); the raised radio (1); their paper map (2).
Comparison: [0] presence risky 45 healthy / 35 depleted (Presence kit unmeasured); [1] wits hard 35–70 / 25–35; [2] certain. No dominance.

[0] Repeat what you told them — intention: prove by cadence that the voice on Channel Nine was yours. Record 1 gates this on lr_channel_helped / lr_channel_misled.
    known cost: risky Presence check | uncertain risk: add_conditions [shaken]
    success: add_flags [lr_family_trusted, lr_callback_region_1] | failure: add_conditions [shaken], add_flags [lr_family_distrusts, lr_callback_region_1]
    local significance: Talia names herself and the children come out, or the doors close and the callsign is written beside a warning.
    durable: see §5 record 1.
[1] Repair their receiver — intention: give them a working line east.
    known cost: hard Wits check | uncertain risk: pressures {fatigue: 5}; Channel Nine dies
    success: items {scrap_parts: 1}, add_flags [lr_family_linked, lr_callback_region_1] | failure: pressures {fatigue: 5}, add_flags [lr_family_silenced, lr_callback_region_1]
    local significance: they answer once each sunset while the battery lasts, or they travel with no voice ahead and leave the survivor the dead set.
    durable: see §5 record 1.
[2] Leave them your bearing — intention: hand over information and no company.
    known cost: none | uncertain risk: none
    outcome: add_flags [lr_family_directed, lr_callback_region_1]
    local significance: the family keeps the route and none of the survivor's presence — distance paid in absence, not resources.
    durable: see §5 record 1.

Disposition: keep — three distinct intentions; record 1 owns the variants and choice 3.
Findings: none beyond §5 record 1.

### lr_voice_in_reeds — A Voice in the Reeds   [living_road_events.json; global, region 2 only; unique=y; weight=3; priority=9; forbids lr_callback_region_2; see §5 record 1]
Scene: Elian's voice comes out of the marsh: the van is buried, Talia went for timber and has not returned, and a second trail cuts toward the van from the water.
Evidence on screen: the blue roof and the second trail; Talia's tracks (0); the buried wheels (1); the radio already in hand (2).
Comparison: [0] wits hard 35–60 / 25; [1] strength risky 50–65 / 35; [2] certain. No dominance.

[0] Follow Talia's tracks — intention: find the mother before the second trail does.
    known cost: hard Wits check | uncertain risk: pressures {fatigue: 8}, add_conditions [shaken]
    success: items {climbing_rope: 1}, add_flags [lr_family_reunited, lr_callback_region_2] | failure: pressures {fatigue: 8}, add_conditions [shaken], add_flags [lr_family_wounded, lr_callback_region_2]
    local significance: Talia is guided out of a drainage cut, or drags herself back with a boot missing and fever starting.
    durable: see §5 record 1; §5 record 11's proposed choice 3 lands here.
[1] Free the van first — intention: get the vehicle out while there is light.
    known cost: risky Strength check | uncertain risk: pressures {radiation: 5, fatigue: 5}
    success: items {scrap_parts: 1}, add_flags [lr_family_mobile, lr_callback_region_2] | failure: pressures {radiation: 5, fatigue: 5}, add_flags [lr_family_abandoned_van, lr_callback_region_2]
    local significance: the van reaches the raised road, or the noise carries and the family leaves with what small hands can carry.
    durable: see §5 record 1.
[2] Guide them out by radio — intention: solve it without being seen.
    known cost: none | uncertain risk: none
    outcome: add_flags [lr_family_remote_help, lr_callback_region_2]
    local significance: they escape without meeting the survivor and ask that the distance be kept.
    durable: see §5 record 1.

Disposition: revise — the opening contradicts one of its own source states.
Findings:
P0 (false history): the introduction opens on Channel Nine transmitting, but after lr_family_silenced (blue_van 1 failure) the set is dead and was left with the survivor → record 1's promised "variant citing the van's last state" must resolve this case concretely (a scavenged handset, or a voice shouted across water), not merely change tone.

### lr_last_battery — The Last Battery   [living_road_events.json; global, region 3 only; unique=y; weight=3; priority=9; forbids lr_callback_region_3; thread finale; see §5 record 1]
Scene: A radio speaks the survivor's callsign across a factory yard; the family is behind a failing security door, their last battery feeding the transmitter, while a broker bids for the children's frequency.
Evidence on screen: the scorched controller (0); the broker arguing with Talia (1); Elian counting minutes aloud (2).
Comparison: [0] wits desperate 20–55 / 10–20; [1] presence hard 35 / 25 (Presence unmeasured); [2] certain. No dominance.

[0] Open the security door — intention: get the door up before the battery dies.
    known cost: desperate Wits check | uncertain risk: pressures {health: -15, fatigue: 8}, add_conditions [shaken]
    success: items {dust_cloak: 1}, add_flags [lr_family_saved, lr_family_thread_complete, lr_callback_region_3] | failure: pressures {health: -15, fatigue: 8}, add_conditions [shaken], add_flags [lr_family_separated, lr_family_thread_complete, lr_callback_region_3]
    local significance: the door lifts on the family and three strangers they refused to abandon, or it welds shut and the radio dies mid-callsign.
    durable: see §5 record 1; ledger_family_3 variants read saved / allied / separated / hunted / unknown.
[1] Negotiate with the broker — intention: price his bargain aloud so it collapses.
    known cost: hard Presence check | uncertain risk: pressures {fatigue: 6}
    success: items {lucky_die: 1}, add_flags [lr_family_allied, lr_family_thread_complete, lr_callback_region_3] | failure: pressures {fatigue: 6}, add_flags [lr_family_hunted, lr_family_thread_complete, lr_callback_region_3]
    local significance: the strangers open their side of the door, or the offer is rebroadcast as proof the family has valuable friends.
    durable: see §5 record 1.
[2] Tell them to save the battery — intention: give the bearing and end contact deliberately.
    known cost: none | uncertain risk: none
    outcome: add_flags [lr_family_unknown, lr_family_thread_complete, lr_callback_region_3]
    local significance: hours of power preserved and no way for either side to learn what followed.
    durable: see §5 record 1.

Disposition: revise — the silenced-set contradiction reaches region 3 and the completion flag is unread.
Findings:
P0 (false history): "Their final battery is feeding the transmitter" assumes a working set after lr_family_silenced → extend record 1's variant contract to this introduction.
P1 (orphan): lr_family_thread_complete is written by all five outcomes and read nowhere in the four data files or road_ledger.json → name its consumer as the §5 scheduling guarantee's termination test (a thread whose *_thread_complete flag is set stops being due a reserved slot), or retire it.

### Thread 2 — Tower Six, Dena's Quiet Column (§5 record 2)

### lr_quiet_column — The Quiet Column   [living_road_events.json; global, region 1 only; unique=y; weight=3; priority=7; forbids lr_callback_region_1; see §5 record 2]
Scene: A column crosses the flats at noon without speaking, every buckle wrapped, behind a woman carrying a burned siren rotor like a shield.
Evidence on screen: the wrapped metal; Dena's question about Tower Six (0); the blackened rotor (1); families glancing west whenever the wind resembles an alarm (2).
Comparison: [0] presence risky 45 / 35 (Presence unmeasured); [1] wits favorable 55–90 / 45–55; [2] certain. No dominance.

[0] Tell Dena what happened — intention: give the tower's account to the person who maintained towers.
    known cost: risky Presence check | uncertain risk: add_conditions [shaken]
    success: items {clean_water: 1}, add_flags [lr_column_trusts, lr_callback_region_1] | failure: add_conditions [shaken], add_flags [lr_column_doubts, lr_callback_region_1]
    local significance: room at the shade cloth and the names of the column's missing, or marching orders repeated to everyone but the survivor.
    durable: see §5 record 2.
[1] Inspect the burned rotor — intention: read the machine instead of testifying about it.
    known cost: favorable Wits check | uncertain risk: pressures {health: -10}
    success: items {scrap_parts: 1}, add_flags [lr_column_sheltered, lr_callback_region_1] | failure: pressures {health: -10}, add_flags [lr_column_guarded, lr_callback_region_1]
    local significance: a final maintenance pulse opened a service shelter and Dena copies the bearing, or a warped spring opens the survivor's fingers and she takes the evidence back.
    durable: see §5 record 2; record 2's proposed choice 3 lands here.
[2] Refuse the tower's burden — intention: decline responsibility for everyone who heard it.
    known cost: none | uncertain risk: none
    outcome: add_flags [lr_column_refused, lr_callback_region_1]
    local significance: Dena accepts the boundary without agreeing; the column passes showing the work the refusal leaves them.
    durable: see §5 record 2.

Disposition: keep — distinct intentions and a real favorable-check reward.
Findings: none beyond §5 record 2.

### lr_bellkeepers_son — The Bell-Keeper's Son   [living_road_events.json; global, region 2 only; unique=y; weight=3; priority=9; forbids lr_callback_region_2; see §5 record 2]
Scene: Dena's son rings a muffled bell on a drowned chapel roof to hold searchers' attention while the water begins moving against the wind.
Evidence on screen: the bell under its blanket and the moving water (0); figures searching the far bank (1); Dena naming the boy as hers (2).
Comparison: [0] grit hard 35–60 / 25; [1] agility risky 45–70 / 35; [2] certain. No dominance.

[0] Cross to Perrin — intention: take the boy off the roof yourself.
    known cost: pressures {fatigue: 8} even on success | uncertain risk: pressures {health: -15, fatigue: 10}
    success: pressures {fatigue: 8}, add_flags [lr_perrin_rescued, lr_callback_region_2] | failure: pressures {health: -15, fatigue: 10}, add_flags [lr_perrin_saved_column_scattered, lr_callback_region_2]
    local significance: the boy returns either way; what changes is whether the column stays one group.
    durable: see §5 record 2.
[1] Draw the searchers away — intention: buy the crossing with your own visibility.
    known cost: risky Agility check | uncertain risk: pressures {fatigue: 6}
    success: items {ration_bar: 2}, add_flags [lr_column_escaped, lr_callback_region_2] | failure: pressures {fatigue: 6}, add_flags [lr_column_stripped, lr_callback_region_2]
    local significance: Perrin crosses by rope and a wrapped ration waits where paths divide, or medicine, blankets and family records go into black water as deliberate noise.
    durable: see §5 record 2.
[2] Tell Dena to leave him — intention: save the column by naming the cost aloud.
    known cost: none | uncertain risk: none
    outcome: add_flags [lr_dena_stayed, lr_callback_region_2]
    local significance: Dena stays behind alone; two muffled bells answer hours later and the survivor never learns what they mean.
    durable: see §5 record 2.

Disposition: revise — the hardest option pays nothing material and the unresolved ending is contradicted later.
Findings:
P1 (weak reward): [0] is the most exposed option (grit hard; failure -15 HP and fatigue 10) and its success moves no item, while the easier evade pays ration_bar 2; plan §3 requires a premium for hard checks → now: success pressures {fatigue: 8}, items none | proposed: success pressures {fatigue: 8}, items {bitter_tonic: 1} (the column treats the man who went into black water; §7: her kindness is procedural).
P1 (weak callback): lr_dena_stayed leaves Dena and Perrin unresolved and lr_siren_in_glass then puts both on screen unacknowledged → lr_siren_in_glass gains an introduction variant for lr_dena_stayed citing the two bells; record 2's change list covers only the lr_siren_silenced variant.

### lr_siren_in_glass — A Siren in the Glass   [living_road_events.json; global, region 4 only; unique=y; weight=3; priority=9; forbids lr_callback_region_4; thread finale; see §5 record 2]
Scene: A civil-defense siren lies half fused into the black plain while a pilgrim patrol follows the column's footprints and Perrin waits with a hand on the switch.
Evidence on screen: the buried rotor and switch (1); the patrol tracking through reflections; bright metal that can be buried (2); Dena's flare is not on screen (0 — see the P1).
Comparison: [0] agility hard 35–60 / 25; [1] wits desperate 20–55 / 10–20; [2] certain. No dominance.

[0] Carry the flare east — intention: put a false signal where the column is not.
    known cost: hard Agility check | uncertain risk: pressures {health: -20, fatigue: 8}
    success: items {flare_gun: 1, shotgun_shells: 3} — flare_gun's ammo_type is shotgun_shells, so the shells are usable — add_flags [lr_column_saved, lr_column_thread_complete, lr_callback_region_4] | failure: pressures {health: -20, fatigue: 8}, add_flags [lr_column_dispossessed, lr_column_thread_complete, lr_callback_region_4]
    local significance: the column crosses behind the patrol's backs and Dena gives up the alarm she owns, or both routes are lit and the carts are abandoned.
    durable: see §5 record 2; ledger_column_3 variants.
[1] Sound the buried siren — intention: use the alarm as a weapon once, openly.
    known cost: desperate Wits check | uncertain risk: pressures {health: -15, radiation: 6}, add_conditions [shaken]
    success: items {rebar_spear: 1}, add_flags [lr_column_warned_wastes, lr_column_thread_complete, lr_callback_region_4] | failure: pressures {health: -15, radiation: 6}, add_conditions [shaken], add_flags [lr_column_broken, lr_column_thread_complete, lr_callback_region_4]
    local significance: one note splits the patrol after phantom columns, or the surge travels through fused ground and everyone feels where it came from.
    durable: see §5 record 2.
[2] Keep the wastes quiet — intention: end the warning system rather than aim it.
    known cost: none | uncertain risk: none
    outcome: add_flags [lr_column_hidden, lr_column_thread_complete, lr_callback_region_4]
    local significance: the metal goes under glass dust; no alarm betrays the column and no warning reaches the travelers behind.
    durable: see §5 record 2.

Disposition: revise — a missing object in the introduction and an unread completion flag.
Findings:
P1 (weak opening evidence): [0]'s flare exists only in the outcome; the body shows only the rotor and switch → name Dena's flare gun in the introduction (§7: "alarms belong to whoever chooses when they scream").
P1 (orphan): lr_column_thread_complete written by all five outcomes, read nowhere → §5 scheduling termination test, or retire.

### Thread 3 — The pharmacy, Lio's Road Debt (§5 record 3)

### lr_pharmacy_witness — The Pharmacy Witness   [living_road_events.json; global, region 1 only; unique=y; weight=3; priority=7; forbids lr_callback_region_1; see §5 record 3]
Scene: Lio Marr has arranged medicine bottles on a car hood, each labelled with a traveler's name; one carries the bandit leader's, one the survivor's callsign in fresh charcoal.
Evidence on screen: the two named bottles and his deliberately empty hands (0); the labels working as a filing system (1); the survivor's own bottle within reach (2).
Comparison: [0] presence hard 35 / 25 (Presence unmeasured); [1] wits risky 45–70 / 35; [2] certain — the comparison's strict dominance, "dominant: [2] Refuse to be judged", because no choice in the scene moves an item.

[0] Give Lio the whole account — intention: put the true version beside the others.
    known cost: hard Presence check | uncertain risk: add_conditions [shaken]
    success: add_flags [lr_lio_believes, lr_callback_region_1] | failure: add_conditions [shaken], add_flags [lr_lio_accuses, lr_callback_region_1]
    local significance: the account is allowed to stay beside the others, or the survivor's label is turned outward as a warning.
    durable: see §5 record 3, which also fixes the false history in this success text and adds choice 3.
[1] Ask what the gang recorded — intention: get at the ledger rather than defend yourself.
    known cost: risky Wits check | uncertain risk: pressures {fatigue: 4}
    success: add_flags [lr_ledger_clue, lr_callback_region_1] | failure: pressures {fatigue: 4}, add_flags [lr_ledger_misread, lr_callback_region_1]
    local significance: copied pages with a symbol pointing at the industrial yards, or a living traveler named as murdered.
    durable: see §5 record 3.
[2] Refuse to be judged — intention: deny the court its jurisdiction.
    known cost: none | uncertain risk: none
    outcome: add_flags [lr_lio_refused, lr_callback_region_1]
    local significance: an empty place in the arrangement, available to whoever reaches Lio next.
    durable: see §5 record 3.

Disposition: revise — the dominance is real and its cause is that the scene pays nobody.
Findings:
P1 (dominant, weak reward): [2] is certain, costs nothing, and ties both checks because neither moves an item → now: [0] success items none | proposed: [0] success items {painkillers: 1} — Lio pushes across the bottle of a traveler he has confirmed dead once the account completes the entry (§7: he returns supplies when testimony agrees; painkillers is "three tablets in a cracked orange bottle", and [2]'s broken bottle is the survivor's own undecided one, so that line stays true). Refusal keeps its cost later, per the bible's distance rule: an lr_bandit_ledger introduction variant for lr_lio_refused (the empty place is now a labelled space on the archive wall the room reads first), with ledger_debt_1's "refused" variant already in place.
Note (not a finding): [1] stays dominated on the item rule and is kept per map §3 — it preserves Wits/investigate expertise and its flag feeds lr_bandit_ledger, ledger_debt_1, and record 3's choice 3.

### lr_bandit_ledger — The Ledger Room   [living_road_events.json; global, region 3 only; unique=y; weight=3; priority=9; forbids lr_callback_region_3; see §5 record 3]
Scene: A payroll office has become an archive of roadside theft; Lio holds the gang's original ledger while victims argue over publishing, burning, or using it.
Evidence on screen: names in many hands on the walls; the arguing victims (0); entries describing caches that may still be occupied (1); the pages themselves (2).
Comparison: [0] presence hard 35 / 25 (Presence unmeasured); [1] wits risky 45–70 / 35; [2] certain. No dominance.

[0] Read the ledger aloud — intention: make the record public before anyone owns it.
    known cost: hard Presence check | uncertain risk: add_conditions [shaken]
    success: add_flags [lr_ledger_shared, lr_callback_region_3] | failure: add_conditions [shaken], add_flags [lr_ledger_disputed, lr_callback_region_3]
    local significance: copies reach separate witnesses, making the truth harder to own and harder to erase; or a named woman contradicts the book and Lio closes it before argument becomes punishment.
    durable: see §5 record 3.
[1] Follow the cache marks — intention: turn the ledger into supplies without robbing anyone.
    known cost: risky Wits check | uncertain risk: pressures {fatigue: 5}
    success: items {canned_meat: 1, clean_water: 1}, add_flags [lr_ledger_verified, lr_callback_region_3] | failure: pressures {fatigue: 5}, add_flags [lr_cache_family_displaced, lr_callback_region_3]
    local significance: an empty compartment emptied with the occupied doors left shut, both recorded; or a family that trusts written promises less.
    durable: see §5 record 3.
[2] Burn the pages — intention: end the gang's map even at the cost of the record.
    known cost: none | uncertain risk: none
    outcome: add_flags [lr_ledger_burned, lr_callback_region_3]
    local significance: routes burn first and names last; Lio keeps one blackened corner with the survivor's callsign. STORY_CANON §6: a real loss nothing rewards or punishes.
    durable: see §5 record 3.

Disposition: revise — the hard social success is the only one with neither goods nor a later distinction.
Findings:
P1 (weak reward): [0] moves no item, and record 3 already gives lr_ledger_verified a later payoff at lr_last_toll while lr_ledger_shared has none → give the same kind of premium rather than goods: an lr_last_toll introduction variant for lr_ledger_shared in which three separate hands already hold copies, so the court cannot quietly revise its own record.

### lr_last_toll — The Last Toll   [living_road_events.json; global, region 5 only; unique=y; weight=3; priority=9; forbids lr_callback_region_5; thread finale; see §5 record 3]
Scene: A barrier of pharmacy shutters and factory desks spans the Underrail, where survivors named in the ledger weigh travelers' goods against recorded thefts.
Evidence on screen: the rack of confiscated weapons; the court in operation (0); the covered bundle holding a rifle (1); the survivor's own unprovable record (2).
Comparison: [0] presence desperate 20 / 10 (Presence unmeasured); [1] wits hard 35–60 / 25; [2] certain. No dominance.

[0] Make the court name its limits — intention: force the judges to state what evidence frees a stranger.
    known cost: desperate Presence check | uncertain risk: pressures {fatigue: 7}
    success: items {nail_bat: 1}, add_flags [lr_road_court_limited, lr_road_debt_complete, lr_callback_region_5] | failure: pressures {fatigue: 7}, add_flags [lr_road_court_hardened, lr_road_debt_complete, lr_callback_region_5]
    local significance: the permanent barrier comes down and its gavel changes hands, or the survivor is searched under raised weapons and written into the next page.
    durable: see §5 record 3; ledger_debt_3 variants.
[1] Verify the rifle's owner — intention: settle one ownership question by evidence.
    known cost: hard Wits check | uncertain risk: add_conditions [shaken]
    success: items {hunting_rifle: 1, rifle_rounds: 3}, add_flags [lr_road_record_preserved, lr_road_debt_complete, lr_callback_region_5] | failure: add_conditions [shaken], add_flags [lr_road_record_failed, lr_road_debt_complete, lr_callback_region_5]
    local significance: a dead hunter's rifle goes to whoever proved its history, or ownership stays unresolved and a quiet woman's judgement outweighs the survivor's.
    durable: see §5 record 3; record 3's lr_ledger_verified variant and this batch's proposed lr_ledger_shared variant both land here.
[2] Pass without testimony — intention: give nothing and take nothing.
    known cost: none | uncertain risk: none
    outcome: add_flags [lr_road_court_continues, lr_road_debt_complete, lr_callback_region_5]
    local significance: the barrier lifts for want of a provable debt; the court continues, useful, dangerous, and beyond influence.
    durable: see §5 record 3.

Disposition: keep — distinct intentions and real rewards on both checks.
Findings:
P1 (orphan): lr_road_debt_complete written by all five outcomes, read nowhere → §5 scheduling termination test, or retire.

### Thread 4 — The filter, Iven's Water Commons (§5 record 4)

### lr_cup_passed_east — The Cup Passed East   [living_road_events.json; global, region 3 only; unique=y; weight=3; priority=7; forbids lr_callback_region_3; see §5 record 4]
Scene: Clear water falls in patient drops from a pipe that should carry only steam, into chipped cups, while armed scavengers mark the valve with their colours.
Evidence on screen: the drops, the cups, the scavengers' marks; Iven's three-way question (0); the line running east (1); bottles a traveler could simply fill (2).
Comparison: [0] presence hard 35 / 25 (Presence unmeasured); [1] wits risky 45–80 / 35–45; [2] certain — the comparison's strict dominance, "dominant: [2] Take water and leave", since it grants the same clean_water 2 as the hard check's success with no check.

[0] Keep the line public — intention: settle the water as shared obligation before weapons decide it.
    known cost: hard Presence check | uncertain risk: the scavengers take the valve; one bottle still filled
    success: items {clean_water: 2}, add_flags [lr_water_shared, lr_callback_region_3] | failure: items {clean_water: 1}, add_flags [lr_water_claimed, lr_callback_region_3]
    local significance: a schedule scratched where anyone can challenge it, or self-appointed keepers and one bottle filled before that counts as theft.
    durable: see §5 record 4; record 4's introduction variants and proposed choice 3 belong to this scene.
[1] Trace the eastern pipe — intention: learn where the water goes before deciding who owns it.
    known cost: risky Wits check | uncertain risk: pressures {health: -10, radiation: 6}
    success: add_flags [lr_water_route_known, lr_callback_region_3] | failure: pressures {health: -10, radiation: 6}, add_flags [lr_water_line_damaged, lr_callback_region_3]
    local significance: an emergency reservoir found and named, with a warning that opening the distant valves may empty every cup here; or a pressure seam and contaminated scale.
    durable: see §5 record 4.
[2] Take water and leave — intention: be gone with what you can carry.
    known cost: none | uncertain risk: none
    outcome: items {clean_water: 2}, add_flags [lr_water_taken, lr_callback_region_3]
    local significance: Iven watches every bottle and says nothing; the first weapon comes up behind the survivor.
    durable: see §5 record 4.

Disposition: revise — the certain option matches the hard check's reward.
Findings:
P1 (dominant): [2] equals [0]'s success with certainty → now: [0] success items {clean_water: 2} | proposed: [0] success items {clean_water: 3}; [2] unchanged at clean_water 2. The hard check gains plan §3's premium, [0]'s failure floor (clean_water 1) still sits under the certain option, and distance keeps its resources as the bible intends. The refusal's cost lands later, not immediately: an lr_thirst_court introduction variant for lr_water_taken in which the delegates cite the bottles a stranger carried off while the argument was still words; ledger_water_1's "taken" variant already reads the flag.

### lr_thirst_court — The Thirst Court   [living_road_events.json; global, region 4 only; unique=y; weight=3; priority=9; forbids lr_callback_region_4; see §5 record 4]
Scene: Three guarded cistern carts form a triangle on the glass while delegates accuse each other of overdrawing and the emergency reservoir ticks as it cools beneath them.
Evidence on screen: identical blue valve marks; the gauges and sealed carts (0); the reservoir wheel (1); the stated trade-off between everyone today and the Underrail tomorrow (2).
Comparison: [0] wits hard 35–60 / 25; [1] strength risky 50–65 / 35; [2] certain. No dominance.

[0] Audit every cistern — intention: replace suspicion with measurement.
    known cost: hard Wits check | uncertain risk: pressures {fatigue: 6}, add_conditions [shaken]
    success: items {clean_water: 1}, add_flags [lr_water_theft_exposed, lr_callback_region_4] | failure: pressures {fatigue: 6}, add_conditions [shaken], add_flags [lr_water_audit_failed, lr_callback_region_4]
    local significance: hidden compartments opened before every delegate and a fragile agreement built on evidence; or a wrong accusation and water spilled on glass too hot to recover it.
    durable: see §5 record 4.
[1] Open the reservoir fully — intention: end the court by removing the scarcity.
    known cost: risky Strength check | uncertain risk: pressures {fatigue: 8}
    success: items {clean_water: 2}, add_flags [lr_water_released, lr_callback_region_4] | failure: pressures {fatigue: 8}, add_flags [lr_reservoir_broken, lr_callback_region_4]
    local significance: all three carts fill while Iven marks how fast the level drops; or the stem shears and the future leaks into fused soil.
    durable: see §5 record 4.
[2] Reserve water for the Underrail — intention: back the least popular calculation for people nobody here can see.
    known cost: none | uncertain risk: none
    outcome: add_flags [lr_underrail_water_reserved, lr_callback_region_4]
    local significance: strict surface portions and a closed eastern valve, called prudence, theft, and faith in equal measure.
    durable: see §5 record 4; record 4's lr_valve_below variant reads this flag with lr_filter_repaired.

Disposition: revise — the harder check returns less than the easier one.
Findings:
P1 (weak reward): [0] is hard (35–60) and pays clean_water 1 while [1] is risky (50–65) and pays 2, inverting plan §3's premium rule → now: [0] success items {clean_water: 1} | proposed: [0] success items {clean_water: 1, purifier_ampoule: 1} — the guards' own crossing supplies come out of the compartments the audit opens.

### lr_valve_below — The Valve Below   [living_road_events.json; global, region 5 only; unique=y; weight=3; priority=9; forbids lr_callback_region_5; thread finale; see §5 record 4]
Scene: The Underrail pipe ends dry above a tarp settlement; Iven has arrived ahead of the survivor with the last technicians, pursued by guards still claiming the blue mark as authority.
Evidence on screen: families holding cups under a dead outlet; the guards' marks (0); the technicians and the maintenance lines (1); the survivor's own empty cup (2).
Comparison: [0] presence desperate 20 / 10 (Presence unmeasured); [1] wits hard 35–70 / 25–35; [2] certain. No dominance.

[0] Defend the common valve — intention: make the water a commons before it becomes a throne.
    known cost: desperate Presence check | uncertain risk: authority stays with the guards
    success: items {tire_armor: 1}, add_flags [lr_water_common_founded, lr_water_thread_complete, lr_callback_region_5] | failure: add_flags [lr_water_guarded_state, lr_water_thread_complete, lr_callback_region_5]
    local significance: nobody gets a second cup until everyone has a first; or water returns portioned by names the guards recognise, with Iven contesting each measure.
    durable: see §5 record 4; ledger_water_3 variants.
[1] Rebuild the pressure bypass — intention: make any single valve useless as leverage.
    known cost: hard Wits check | uncertain risk: pressures {health: -15, fatigue: 8}
    success: items {scavenger_rig: 1}, add_flags [lr_water_decentralized, lr_water_thread_complete, lr_callback_region_5] | failure: pressures {health: -15, fatigue: 8}, add_flags [lr_water_single_valve, lr_water_thread_complete, lr_callback_region_5]
    local significance: three outlets begin dripping; or the last seals are spent and one valve controls the future again.
    durable: see §5 record 4.
[2] Leave them the argument — intention: decline to arbitrate other people's water.
    known cost: none | uncertain risk: none
    outcome: add_flags [lr_water_abandoned, lr_water_thread_complete, lr_callback_region_5]
    local significance: an empty cup set under a dry outlet; the settlement starts deciding who stays to repair what everyone needs.
    durable: see §5 record 4.

Disposition: keep — distinct intentions and equipment rewards on both checks.
Findings:
P1 (orphan): lr_water_thread_complete written by all five outcomes, read nowhere → §5 scheduling termination test, or retire.

### Thread 5 — The fire, Noma's Nightfire Caravan (§5 record 5)

### lr_embers_in_rain — Embers in Rain   [living_road_events.json; global, region 2 only; unique=y; weight=3; priority=7; forbids lr_callback_region_2; see §5 record 5]
Scene: A covered fire on a marsh platform, six people, one empty bedroll, and a sick passenger asking to be carried to a clinic that may already be flooded.
Evidence on screen: the empty bedroll and black rain; bedroll and poles as a stretcher (0); the clinic across the water (1); rain that will eventually soften (2).
Comparison: [0] strength hard 40–55 / 25; [1] wits risky 45–70 / 35; [2] certain. No dominance.

[0] Carry the sick traveler — intention: get the patient to the clinic in person.
    known cost: pressures {fatigue: 8} on success | uncertain risk: pressures {health: -10, fatigue: 10}, add_conditions [sprain]
    success: items {bitter_tonic: 1}, pressures {fatigue: 8}, add_flags [lr_caravan_patient_helped, lr_callback_region_2] | failure: pressures {health: -10, fatigue: 10}, add_conditions [sprain], add_flags [lr_caravan_patient_delayed, lr_callback_region_2]
    local significance: the ruined clinic still holds tonic, divided before the thanks are; or a pole splits and the group turns back to keep fever from becoming panic.
    durable: see §5 record 5.
[1] Search for medicine alone — intention: solve the illness without risking the caravan.
    known cost: risky Wits check | uncertain risk: add_conditions [shaken]
    success: items {painkillers: 1}, add_flags [lr_caravan_debt_owed, lr_callback_region_2] | failure: add_conditions [shaken], add_flags [lr_caravan_patient_worse, lr_callback_region_2]
    local significance: sealed tablets and the survivor's name added to the spoken list of people entitled to a fire; or nothing safe to administer and a silence Noma refuses to make into blame.
    durable: see §5 record 5; record 5's proposed choice 3 belongs to this scene.
[2] Decline the empty bedroll — intention: take shelter from the rain and no obligation.
    known cost: none | uncertain risk: none
    outcome: pressures {fatigue: -4}, add_flags [lr_caravan_distance_kept, lr_callback_region_2]
    local significance: no food offered and no favour asked; the unused bedroll is folded away, preserving a place the survivor declined. Distance correctly pays in rest rather than nothing.
    durable: see §5 record 5.

Disposition: keep — three intentions and three reward shapes (medicine, standing, rest); record 5 owns the "remembers exactly where you stood" false history.
Findings: none beyond §5 record 5.

### lr_names_on_smoke — Names Written in Smoke   [living_road_events.json; global, region 3 only; unique=y; weight=3; priority=9; forbids lr_callback_region_3; see §5 record 5]
Scene: The caravan burns the names of its lost in a canteen stove while a salvage crew offers safe passage in exchange for a teenage mechanic accused of stealing a battery.
Evidence on screen: the stove and the spoken names; the heater the mechanic says she kept alive (0); the crew's offer and the girl (2); nothing about a price the survivor could be made to pay (1 — see the P0).
Comparison: [0] wits hard 35–70 / 25–35; [1] presence desperate 20 / 10 (Presence unmeasured); [2] certain. No dominance.

[0] Prove where the charge went — intention: settle the accusation with physical evidence.
    known cost: hard Wits check | uncertain risk: pressures {fatigue: 6}
    success: items {scrap_parts: 1}, add_flags [lr_caravan_mechanic_cleared, lr_callback_region_3] | failure: pressures {fatigue: 6}, add_flags [lr_caravan_heat_lost, lr_callback_region_3]
    local significance: solder and a serial mark give the crew a dignified way out and Noma repays them from the caravan's tools; or the only working contact dies under inspection.
    durable: see §5 record 5.
[1] Offer yourself as guarantor — intention: put your own standing between the girl and the crew.
    known cost: not stated before commitment — see the P0 | uncertain risk: items {canned_meat: -1}
    success: add_flags [lr_caravan_guaranteed, lr_callback_region_3] | failure: items {canned_meat: -1}, add_flags [lr_caravan_paid_debt, lr_callback_region_3]
    local significance: the pledge holds because the survivor's gear makes it costly; or the crew asks what authority makes it collectible and takes food instead.
    durable: see §5 record 5.
[2] Let the crew take her — intention: buy the caravan's passage with the accused.
    known cost: none | uncertain risk: none
    outcome: add_flags [lr_caravan_mechanic_surrendered, lr_callback_region_3]
    local significance: the girl agrees before fear can alter her voice; her name is not burned because nobody agrees whether she is lost.
    durable: see §5 record 5.

Disposition: revise — an unsignalled cost and a desperate check that moves nothing.
Findings:
P0 (false cost): [1]'s failure removes items {canned_meat: -1} from the survivor's pack; the 65-word introduction never puts food at stake, and the failure text attributes the loss elsewhere ("The crew takes half the caravan's food instead"). `GameEngine._change_item` also clamps at zero while the result line still prints "Canned Meat -1", so a survivor with none is told they paid → name the crew's price in the introduction (a guarantee is collectible in food, out of the guarantor's own pack) and rewrite the failure text so the can leaves the survivor's pack.
P1 (weak reward): a desperate Presence check (20 / 10) whose success moves nothing → now: [1] success items none | proposed: items {ration_bar: 2} — Noma pays the guarantor from the caravan's stores (§7: she trades "rations and turns at watch").

### lr_warm_windows — Warm Windows Again   [living_road_events.json; global, region 5 only; unique=y; weight=3; priority=9; forbids lr_callback_region_5; thread finale; see §5 records 5 and 9]
Scene: A train with blankets over its windows and a drum fire inside; the doors are barred against another group carrying an injured child, and the fuel will heat one carriage, not two.
Evidence on screen: the barred doors and covered windows (2); the stated one-carriage fuel limit (0); the second heater and its baton cell are not on screen (1 — see the P1).
Comparison: [0] presence hard 35 / 25 (Presence unmeasured); [1] wits desperate 20–55 / 10–20; [2] certain. No dominance.

[0] Open the warm carriage — intention: make hospitality survive its own rules.
    known cost: hard Presence check | uncertain risk: add_conditions [shaken]
    success: items {rusted_hatchet: 1}, add_flags [lr_caravan_fire_shared, lr_caravan_thread_complete, lr_callback_region_5] | failure: add_conditions [shaken], add_flags [lr_caravan_divided, lr_caravan_thread_complete, lr_callback_region_5]
    local significance: every passenger names one possession that can burn and pride becomes kindling; or accusations enter first and coals scatter under the seats.
    durable: see §5 record 5; ledger_fire_3 variants.
[1] Restore the second heater — intention: solve the shortage instead of arbitrating it.
    known cost: desperate Wits check | uncertain risk: pressures {health: -15, fatigue: 10}, add_conditions [burned]
    success: items {stun_baton: 1}, add_flags [lr_caravan_two_fires, lr_caravan_thread_complete, lr_callback_region_5] | failure: pressures {health: -15, fatigue: 10}, add_conditions [burned], add_flags [lr_caravan_fire_damaged, lr_caravan_thread_complete, lr_callback_region_5]
    local significance: the second carriage floor finally turns warm; or the burner flashes and a damaged heater must be watched by hand until morning.
    durable: see §5 record 5; §5 record 9's proposed choice 3 lands here and grants this success without the check.
[2] Keep the doors barred — intention: hold the rule the caravan made before the child arrived.
    known cost: none | uncertain risk: none
    outcome: add_flags [lr_caravan_closed, lr_caravan_thread_complete, lr_callback_region_5]
    local significance: the other group settles against the warm exterior; at dawn one small handprint remains on the window cloth.
    durable: see §5 record 5.

Disposition: revise — one success asserts a person the survivor may have handed over.
Findings:
P0 (false history): [1]'s success says "the teenage mechanic shows how to wake its remaining charge" although lr_caravan_mechanic_surrendered is in this event's own eligibility → add a success variant for that flag in which Noma or the caravan's remaining hands wake the baton and the absent name is noted.
P1 (weak opening evidence): the second heater and the security baton appear only in the outcome → one introduction clause showing the dead heater with a baton wired into its cell.
P1 (orphan): lr_caravan_thread_complete written by all five outcomes, read nowhere → §5 scheduling termination test, or retire.

## Batch summary

DISPOSITIONS:
rustsea_green_line | revise | introduction names Mara to survivors who never met her; choice 2's mark needs a reader
rustsea_quay_names | revise | choice 2's protective motive must be established before commitment
rustsea_false_coordinates | keep | lethal route carries its three warnings and the survivable branches fork the chain
rustsea_station_arrivals | revise | burning the maps writes a flag nobody reads
rustsea_salt_crown_wake | revise | "Take supplies and leave" must become an honest uncertain search
rustsea_cartographers_debt | revise | record 7's possession fix, record 6's variants, and a missing next_event
rustsea_voice_map | revise | an unpaid promise, a receiver absent from the introduction, and a missing next_event
rustsea_last_coordinate | redesign | the three intentions stay but each outcome must resolve locally and turn east
lr_blue_van | keep | three distinct intentions; record 1 owns the variants and choice 3
lr_voice_in_reeds | revise | the opening assumes a radio the silenced branch destroyed
lr_last_battery | revise | same silenced-set contradiction plus an unread thread-complete flag
lr_quiet_column | keep | distinct intentions and a real favorable-check reward
lr_bellkeepers_son | revise | the hardest option pays nothing and the unresolved ending is contradicted later
lr_siren_in_glass | revise | the flare is missing from the introduction; thread-complete flag unread
lr_pharmacy_witness | revise | certain refusal dominates because no choice in the scene moves an item
lr_bandit_ledger | revise | the hard social success has neither goods nor a later distinction
lr_last_toll | keep | strong rewards on both checks; only the thread-complete flag needs a consumer
lr_cup_passed_east | revise | the certain option matches the hard check's reward
lr_thirst_court | revise | the hard check returns less water than the easier one
lr_valve_below | keep | equipment rewards on both checks; thread-complete flag needs a consumer
lr_embers_in_rain | keep | three reward shapes including rest for distance; record 5 owns the variants
lr_names_on_smoke | revise | unsignalled food cost and a desperate check that moves nothing
lr_warm_windows | revise | the success names a person the survivor may have surrendered

FINDINGS:
P0 | rustsea_green_line | - | body names "Mara Venn's voice" to b41_recording / b41_contact survivors who never met her (STORY_CANON §5) → introduction variants: recognition for b41_mara_helped / b41_mara_abandoned, otherwise the message signs off with a name the survivor cannot place
P1 | rustsea_green_line | 2 | orphan rustsea_map_self_marked and a drowned-tower mark with no destination → rustsea_quay_names eligibility becomes requires_any_flags [rustsea_green_line, rustsea_map_self_marked]
P0 | rustsea_quay_names | 2 | protective motive appears only after selection (plan §6) → replace the body's closing sentence with charcoal copying onto banner cloth and a drying lantern-and-three-strokes mark
P1 | rustsea_quay_names | 1 | orphans rustsea_names_copied, rustsea_children_clue → rustsea_voice_map introduction variant (children_clue) and choice 2 success variant (names_copied)
P1 | rustsea_quay_names | 2 | orphan rustsea_ash_marks_damaged → bunker41_ash_procession introduction variant (cross-batch E)
P1 | rustsea_station_arrivals | 2 | orphan rustsea_maps_burned → rustsea_cartographers_debt introduction variant about the smoke that came east
P0 | rustsea_salt_crown_wake | 1 | "Take supplies and leave" is certain and grants no items (plan §6) → agility risky (salvage): success items {canned_meat: 1, clean_water: 1}; failure pressures {fatigue: 6}; both keep add_flags [rustsea_caravan_taken, rustsea_mara_route] and next_event rustsea_cartographers_debt
P1 | rustsea_salt_crown_wake | 1 | orphan rustsea_caravan_taken → retire; routing is carried by rustsea_mara_route
P0 | rustsea_cartographers_debt | 2 | Key transfer leaves b41_mercy_key set so Mercy is still offered at the gate (plan §6, STORY_CANON §6) → implement §5 record 7 exactly
P1 | rustsea_cartographers_debt | 2 | no next_event while siblings chain, so the promised Spire chapter depends on a weight-1 draw → add next_event rustsea_last_coordinate
P1 | rustsea_cartographers_debt | 0,1 | orphans rustsea_mara_allied, rustsea_mara_betrayed → rustsea_last_coordinate introduction variants
P0 | rustsea_voice_map | 1 | "A later signal will carry the names you chose not to hear" has no destination and rustsea_voices_silenced is read nowhere → bunker41_warden_remembers introduction variant on the flag (cross-batch E), or cut the promise sentence
P1 | rustsea_voice_map | 1 | the receiver is not in the introduction, which establishes only a speaking map → name it in the body or silence the map itself
P1 | rustsea_voice_map | 2 | writes rustsea_spire_route but no next_event while choice 0 chains → add next_event rustsea_last_coordinate
P1 | rustsea_voice_map | 0,2 | orphans rustsea_voice_trusted, rustsea_named_dead → rustsea_last_coordinate introduction variants
P0 | rustsea_last_coordinate | 0,1 | outcomes read as entering a Spire that has no chapter (STORY_CANON §10, §5 mystery) → rewrite both as local resolutions that turn east, with choice 2 as the model; fields unchanged
P1 | rustsea_last_coordinate | 0,1,2 | orphans rustsea_mapped_entry, rustsea_late_entry, rustsea_route_shared, rustsea_spire_reached → ledger_rustsea_spire gains three variants; spire_reached goes to the §5 scheduling termination test or retires
P0 | lr_voice_in_reeds | - | introduction opens on Channel Nine transmitting although lr_family_silenced destroyed the set → record 1's van-state variant must cover the silenced case concretely
P0 | lr_last_battery | - | "Their final battery is feeding the transmitter" assumes a working set after lr_family_silenced → extend the same variant contract to region 3
P1 | lr_last_battery | - | orphan lr_family_thread_complete → §5 scheduling termination test, or retire
P1 | lr_bellkeepers_son | 0 | hardest option pays no item while the easier evade pays ration_bar 2 → success gains items {bitter_tonic: 1} alongside pressures {fatigue: 8}
P1 | lr_bellkeepers_son | 2 | lr_dena_stayed leaves Dena and Perrin unresolved and the next chapter puts both on screen → lr_siren_in_glass introduction variant for lr_dena_stayed citing the two bells
P1 | lr_siren_in_glass | 0 | Dena's flare exists only in the outcome → name the flare gun in the introduction
P1 | lr_siren_in_glass | - | orphan lr_column_thread_complete → §5 scheduling termination test, or retire
P1 | lr_pharmacy_witness | 2 | strictly dominant certain refusal in a scene where no choice moves an item → [0] success gains items {painkillers: 1}; refusal's cost stays later, as an lr_bandit_ledger introduction variant for lr_lio_refused
P1 | lr_bandit_ledger | 0 | hard Presence success has no item and no later distinction while lr_ledger_verified already has one → lr_last_toll introduction variant for lr_ledger_shared
P1 | lr_last_toll | - | orphan lr_road_debt_complete → §5 scheduling termination test, or retire
P1 | lr_cup_passed_east | 2 | strictly dominant: certain clean_water 2 equals the hard check's success → [0] success becomes items {clean_water: 3}, [2] unchanged, and lr_thirst_court gains an introduction variant for lr_water_taken
P1 | lr_thirst_court | 0 | the hard Wits audit returns less water than the easier Strength option → [0] success becomes items {clean_water: 1, purifier_ampoule: 1}
P1 | lr_valve_below | - | orphan lr_water_thread_complete → §5 scheduling termination test, or retire
P0 | lr_names_on_smoke | 1 | failure removes the survivor's canned_meat with no signal before commitment, attributes it to the caravan, and prints "Canned Meat -1" even at zero → name the crew's price in the introduction and attribute the loss to the guarantor's pack
P1 | lr_names_on_smoke | 1 | desperate Presence success moves nothing → success gains items {ration_bar: 2}
P0 | lr_warm_windows | 1 | success names the teenage mechanic although lr_caravan_mechanic_surrendered is in this event's eligibility → success variant for that flag
P1 | lr_warm_windows | 1 | second heater and security baton appear only in the outcome → one introduction clause
P1 | lr_warm_windows | - | orphan lr_caravan_thread_complete → §5 scheduling termination test, or retire
