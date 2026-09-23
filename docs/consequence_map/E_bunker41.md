# Consequence cards — Batch E: Bunker Forty-One

Batch E of [NARRATIVE_CONSEQUENCE_MAP.md](../NARRATIVE_CONSEQUENCE_MAP.md) §4. Thirteen events, all authored in `data/bunker41_events.json` and loaded as written (no override file touches them). Canon is quoted by section from [STORY_CANON.md](../STORY_CANON.md); the eleven-line contracts are the map's §5 records 6, 7 and 8 and are referenced, never restated. Odds are quoted from `builds/choice_comparison.md`.

**Every choice in this batch is certain.** The comparison flags all of them mutually dominant and reports six redundant pairs at `bunker41_door_closes` and one at `bunker41_warden_remembers`; map §3 says that is expected here and that these scenes are judged by durable effect. Each card's Comparison line records the measurement anyway.

**Entry routes.** Five scenes are *scheduled* (a global with a region window and a `narrative_priority`, drawn by weight against everything else eligible): `bunker41_static` (region 1, priority 9), `bunker41_rusted_hatch` (region 4, priority 10), `bunker41_green_platform` (region 5, priority 10), `bunker41_ash_procession` (region 5, priority 9), `bunker41_fragment_calls` (region 5, priority 8). Six are *chained* by a `next_event` from the scene before them and additionally gated by the flag that chain writes. Two are *finale-chained*: `leave_checkpoint` sends region index 6 straight to `final_gate_1` (`game_engine.gd:524`) whose five outcomes all chain to `bunker41_warden_remembers`, which chains to `bunker41_door_closes`; `_select_next_event` never runs at region 6, so their `min_region_index: 6` windows are decoration.

**Passage budgets.** Every introduction is 69–76 words and every outcome 43–49 words; nothing in this batch is under budget or padded, so no card carries a length finding.

Two engine extensions from map §5 are assumed throughout: **conditional passages** (`variants: [{requires_any_flags, text}]`, first match wins) and **choice gating extensions** (`requires.forbids_flags`, `requires.reason`). Where a card proposes several variants on one passage it gives them in match order.

## Flag economy

Every `add_flags` entry written in this batch, its producers, and the consumer that reads it (`eligibility.requires_flags` / `requires_any_flags`, or a choice `requires`). Searched across `data/events.json`, `data/bunker41_events.json`, `data/rustsea_events.json`, `data/living_road_events.json` and `data/road_ledger.json`.

| Flag | Producers | Consumer today | Verdict |
|---|---|---|---|
| `b41_recording` | static 0 | `rustsea_green_line` eligibility | consumed |
| `b41_answered` | static 1 | none | **orphan** → `bunker41_warden_remembers` introduction variant |
| `b41_unprepared` | static 2, rusted_hatch 2 | `bunker41_ash_procession` eligibility | consumed |
| `b41_contact` | rusted_hatch 0/1/2, door_breathes 1 | `rustsea_green_line` eligibility | consumed |
| `b41_quiet_path` | rusted_hatch 0 | `bunker41_cartographer` eligibility | consumed |
| `b41_forced_entry` | rusted_hatch 1 | `bunker41_door_breathes`, `bunker41_last_evacuation` eligibility | consumed (see P0 on `last_evacuation`) |
| `b41_ash_invite` | rusted_hatch 2, cartographer 1/2, last_evacuation 1, fragment_calls 1/2, green_platform 2 | `bunker41_ash_procession` eligibility | consumed |
| `b41_mara_helped` | cartographer 0 | `green_platform` eligibility, `door_closes` 2, `rustsea_green_line` eligibility | consumed (§5 record 6) |
| `b41_mara_abandoned` | cartographer 1 | `rustsea_green_line` eligibility | consumed (§5 record 6) |
| `b41_choir_alerted` | cartographer 1, last_evacuation 1 | `bunker41_ash_procession` eligibility | consumed; see P1 on its two opposite producers |
| `b41_mercy_refused` | cartographer 2 | none | **orphan** → retire (§5 record 6 keys the neutral opening on absence) |
| `b41_green_invite` | cartographer 0, door_breathes 0, last_evacuation 0, fragment_calls 0, ash_procession 1 | `bunker41_green_platform` eligibility | consumed |
| `b41_relay_fragment` | door_breathes 0 | `bunker41_fragment_calls`, `green_platform` eligibility | consumed |
| `b41_mercy_key` | last_evacuation 0 | `green_platform` eligibility, `warden_remembers` 2, `door_closes` 1, `rustsea_cartographers_debt` 2 | consumed (§5 record 7) |
| `b41_abandoned_names` | last_evacuation 1 | `warden_remembers` 2, `door_closes` 2 | consumed (§5 record 8) |
| `b41_records_destroyed` | last_evacuation 2, false_welcome 2 | none | **orphan** → `warden_remembers` introduction variant |
| `b41_fragment_followed` | fragment_calls 0 | none | **orphan** → `door_closes` choice 0 outcome variant |
| `b41_choir_hostile` | fragment_calls 1, ash_procession 2 | none | **orphan** → `door_closes` introduction variant |
| `b41_fragment_discarded` | fragment_calls 2 | none | **orphan** → retire |
| `b41_choir_joined` | ash_procession 0 | `bunker41_chapel_car` eligibility, `door_closes` 3 | consumed by chapel_car; §5 record 8 removes it from `door_closes` 3 |
| `b41_choir_split` | ash_procession 1, chapel_car 2 | `door_closes` 3 only | **orphan under §5 record 8** → `door_closes` introduction variant |
| `b41_witness` | ash_procession 1, chapel_car 1/2, false_welcome 0, ledger_living 0/1 | `warden_remembers` 2, `door_closes` 2 | consumed (§5 record 8) |
| `b41_service_route` | green_platform 0 | `bunker41_false_welcome` eligibility | consumed |
| `b41_ledger_route` | green_platform 1 | `bunker41_ledger_living` eligibility | consumed |
| `b41_public_signal` | green_platform 2 | none | **orphan** → `warden_remembers` introduction variant (entry 1) |
| `b41_key_surrendered` | chapel_car 0 | none | orphan today; consumer contracted in §5 record 7 (`forbids_flags` at `door_closes` 1, `warden_remembers` 2, `cartographers_debt` 2) |
| `b41_choir_bound` | chapel_car 0 | `door_closes` 3 | consumed (§5 record 8) |
| `b41_choir_records` | chapel_car 1 | `warden_remembers` 2, `door_closes` 3 | consumed (§5 record 8) |
| `b41_archive_truth` | false_welcome 0 | none | **orphan** → evidence-naming success variants at `warden_remembers` 2 and `door_closes` 2 (§5 record 8, extended) |
| `b41_mercy` | false_welcome 1/2, ledger_living 2 | none | **orphan** → `door_closes` choice 0 outcome variant |
| `b41_rescued_survivors` | ledger_living 0 | `warden_remembers` 2, `door_closes` 2 | consumed (§5 record 8) |
| `b41_ledger_copy` | ledger_living 1 | none | orphan today; consumer contracted in §5 record 8 (evidence-naming variants) |
| `b41_ledger_burned` | ledger_living 2 | none | **orphan** → `warden_remembers` introduction variant, with `b41_records_destroyed` |
| `b41_warden_heard` | warden_remembers 2 | none | **orphan** → `door_closes` introduction variant (entry 2) |

Proposed new flag: **`b41_warden_destroyed`** (`warden_remembers` 1 victory) → `door_closes` introduction variant. It is the only new flag in this batch and the only way the batch's single fight leaves a trace. No new choices are proposed: no §5 record asks for one here, and no P0 blocked action exists, because the ungated choice in every scene survives the gating this batch adds.

Proposed variant order, stated once so the cards can stay short:

- `bunker41_warden_remembers` introduction: (1) `b41_public_signal`; (2) `b41_records_destroyed` / `b41_ledger_burned`; (3) `b41_answered`; (4) `b41_recording` / `b41_quiet_path` / `b41_forced_entry`; (5) default, which claims no recognition.
- `bunker41_door_closes` introduction: (1) `b41_warden_destroyed`; (2) `b41_warden_heard`; (3) `b41_choir_hostile`; (4) `b41_choir_split`; (5) default, naming only what this survivor passed.
- `bunker41_door_closes` choice 0 outcome: (1) `b41_fragment_followed`; (2) `b41_mercy`; (3) default.

---

### bunker41_static — Static Beneath the Salt   [data/bunker41_events.json; global, region 1 only; unique=y; weight=9; tags=none]
Scene: A salt-crusted receiver wakes with the SOTERIA duty voice repeating Bunker Forty-One and one sentence about mercy, and the survivor decides what to do with a warning addressed to nobody.
Evidence on screen: the receiver breathing static under its crust; the woman's repeated sentence; the patient click between repetitions "as if waiting for an answer" (the evidence for [1]); the speaker itself, breakable underfoot (for [2]).
Comparison: certain in all six states and all four kits; all three flagged dominant as a mutual tie, expected per map §3.
Entry: scheduled global, priority 9, region window 1–1, no flag requirement.

[0] Preserve the recording — intention: keep proof that someone warned strangers away.
    known cost: none | uncertain risk: none (certain)
    success: `add_flags [b41_recording]` | failure: n/a
    local significance: the duty voice travels east in the survivor's pack.
    durable: `b41_recording` → `rustsea_green_line` eligibility; it is also the honest key for the Warden's recognition variant (STORY_CANON §5).
[1] Answer the voice — intention: find out whether anything living is listening.
    known cost: none | uncertain risk: none
    success: `add_flags [b41_answered]` | failure: n/a
    local significance: a second voice repeats the survivor's name from the east; the survivor is now a name inside the system.
    durable: orphan: `b41_answered` → proposed consumer: `bunker41_warden_remembers` introduction variant (entry 3), where the machine asks for authorization using the callsign given to the flats. Second consumer worth taking: add it beside `b41_recording` in `rustsea_green_line` eligibility, which today admits the survivor who only copied the tape and refuses the one who spoke.
[2] Break the receiver — intention: refuse a warning rather than carry it.
    known cost: the receiver | uncertain risk: none
    success: `add_flags [b41_unprepared]` | failure: n/a
    local significance: every gust through the wrecked mast now sounds like the signal the survivor chose not to understand.
    durable: `b41_unprepared` → `bunker41_ash_procession` eligibility.

Disposition: revise — the prose stands; `b41_answered` needs the Warden variant its own outcome promises.
Findings: P1: `b41_answered` is written and never read → give it the `warden_remembers` introduction variant and add it to `rustsea_green_line` eligibility (coordinate with batch F).

### bunker41_rusted_hatch — The Rusted Hatch   [data/bunker41_events.json; global, region 4 only; unique=y; weight=10; tags=none]
Scene: The bunker's blast hatch is warm, fresh drag marks go under its rim, something enormous breathes behind it, and the survivor chooses quiet entry, loud entry, or a warning painted for whoever follows.
Evidence on screen: warm steel under the palm; drag marks crossing fused ground; a child's handprint in old soot through the inspection pane; the breath that shakes loose bolts.
Comparison: certain in all six states and kits; mutual tie, dominance flag expected (map §3).
Entry: scheduled global, priority 10, region window 4–4, no flag requirement; no baseline event carries a `narrative_priority`, so this takes the first Glass Wastes slot in practice.

[0] Take the maintenance shaft — intention: get inside without being announced.
    known cost: none | uncertain risk: none
    success: `add_flags [b41_contact, b41_quiet_path]`, `next_event: bunker41_cartographer` | failure: n/a
    local significance: the breathing below stops, which reads as attention rather than safety.
    durable: `b41_quiet_path` → `bunker41_cartographer` eligibility; `b41_contact` → `rustsea_green_line` eligibility; chain → the Mara branch.
[1] Force the main hatch — intention: open the bunker on the survivor's own terms.
    known cost: none | uncertain risk: none
    success: `add_flags [b41_contact, b41_forced_entry]`, `next_event: bunker41_door_breathes` | failure: n/a
    local significance: emergency lamps wake and metal answers metal; the bunker knows where the survivor is.
    durable: `b41_forced_entry` → `bunker41_door_breathes` and `bunker41_last_evacuation` eligibility; chain → the Cinder Wives branch.
[2] Mark it and leave — intention: warn the next traveler and keep walking.
    known cost: none | uncertain risk: none
    success: `add_flags [b41_contact, b41_ash_invite, b41_unprepared]` | failure: n/a
    local significance: someone reads the warning, presses ash into the letters, and follows anyway; their lantern marks lead east.
    durable: `b41_ash_invite` and `b41_unprepared` → `bunker41_ash_procession` eligibility; `b41_contact` → `rustsea_green_line` eligibility.

Disposition: keep — three genuinely different entries, every flag consumed, and refusal keeps the arc alive through the Choir.
Findings: none. Note for the Warden card: this event writes `b41_contact` even on [2], so `b41_contact` alone cannot key "recognizes the duty voice".

### bunker41_cartographer — The Cartographer Under Glass   [data/bunker41_events.json; global, no window; unique=y; weight=1; tags=none]
Scene: Mara Venn sits inside the map she has made of the bunker's rhythms, hungry, with a knife across her knees, and the survivor decides what her survival is worth. See §5 record 6.
Evidence on screen: chalk lines, string and carefully stacked cans; one missing boot; maps that mark warm floors and the thing below instead of supplies; the knife.
Comparison: certain in all six states and kits; mutual tie (map §3), judged on durable effect.
Entry: chained from `rusted_hatch` 0; eligibility `requires_flags [b41_quiet_path]`.

[0] Share a ration with Mara — see §5 record 6. intention: buy a true route with food.
    known cost: now: none | proposed: `costs.items canned_meat 1` with `requires.reason "You have no food to share"` (record 6) | uncertain risk: none
    success: `add_flags [b41_mara_helped, b41_green_invite]` | failure: n/a
    local significance: Mara eats, gives the folded Underrail route, and asks to be remembered by name.
    durable: per record 6. Not stated there: when [0] locks for an empty pack, [1] and [2] stay ungated, so no state is left without a legal action, and the lock must stay visible rather than `hidden_when_locked`, because the price is the point.
[1] Take her map and leave — see §5 record 6. intention: take the route without paying for it.
    known cost: none now, the Choir later | uncertain risk: none
    success: `add_flags [b41_mara_abandoned, b41_ash_invite, b41_choir_alerted]` | failure: n/a
    local significance: a rail signal begins repeating the survivor's callsign and the word thief.
    durable: per record 6; `b41_ash_invite` and `b41_choir_alerted` → `ash_procession` eligibility.
[2] Heed her warning and withdraw — intention: decline a debt too large to pay.
    known cost: the deeper bunker, the Key, the platform | uncertain risk: none
    success: `add_flags [b41_mercy_refused, b41_ash_invite]` | failure: n/a
    local significance: the hatch closes on an untouched bunker; Mara nods once and says nothing.
    durable: `b41_ash_invite` → `ash_procession` eligibility. orphan: `b41_mercy_refused` → retire: record 6 keys the `cartographers_debt` neutral opening on the absence of helped/abandoned, so nothing reads this flag, and withdrawal's real durable is the Ash invite plus the missing map.

Disposition: revise — record 6's cost and lock, and one flag retired.
Findings:
P0: [0] shares a ration and spends no food (plan §6; STORY_CANON §10) → implement §5 record 6: `costs.items canned_meat 1`, `requires.reason "You have no food to share"`.
P1: `b41_mercy_refused` orphan → retire.

### bunker41_door_breathes — The Door That Breathes   [data/bunker41_events.json; global, no window; unique=y; weight=1; tags=none]
Scene: Past the forced hatch the Cinder Wives recite evacuation orders in front of a pressure door bent outward from the inside, and the survivor robs the wall, follows them, or opens it.
Evidence on screen: ash-coated figures in evacuation uniform speaking in unison (STORY_CANON §5 keeps what they are unstated); the exposed black relay; the bent door exhaling furnace-warm air; drag scars, crushed rifles, and a handprint too broad to belong to any human.
Comparison: certain in all six states and kits; mutual tie. [2] previews as `certain` and resolves `lethal: true`.
Entry: chained from `rusted_hatch` 1; eligibility `requires_flags [b41_forced_entry]`.

[0] Flee with the exposed relay — intention: take the one portable thing and get out.
    known cost: none | uncertain risk: none
    success: `add_flags [b41_relay_fragment, b41_green_invite]` | failure: n/a
    local significance: the Wives' voices become one evacuation alarm; the fragment starts clicking in time with distant rail signals.
    durable: `b41_relay_fragment` → `bunker41_fragment_calls` and `green_platform` eligibility; `b41_green_invite` → `green_platform` eligibility.
[1] Follow the Cinder Wives — intention: be led to whatever they are still processing.
    known cost: none | uncertain risk: none
    success: `add_flags [b41_contact]`, `next_event: bunker41_last_evacuation` | failure: n/a
    local significance: rooms of tagged belongings and sealed nursery doors, then the painted word SOTERIA.
    durable: the chain is the durable; `add_flags [b41_contact]` is a no-op here because all three `rusted_hatch` outcomes already wrote it.
[2] Enter the breathing chamber — intention: see the thing the bunker is built around.
    known cost: the run | uncertain risk: none — `lethal: true`, no items, no flags
    success: n/a | failure: n/a (death)
    local significance: the Hush Sovereign rises and the bunker closes around the survivor's last sound.
    durable: none. STORY_CANON §5 standing mystery: never explained, never fought, never looted; the outcome honours all three.
    Warnings (LIVING_ROAD_NARRATIVE_BIBLE requires three): scale — a pressure door bent outward from the other side, its seams exhaling furnace heat; ordinary protection already failed — drag scars, crushed rifles, and a handprint too broad for a human; final chance to withdraw — both siblings leave the corridor, and the outcome's own first clause names the crushed steel, the heat and the rhythm the survivor stepped past. Present and escalating.

Disposition: keep — the lethal route is fairly signposted and the mystery is preserved.
Findings: P2: [1]'s `add_flags [b41_contact]` is a no-op (every `rusted_hatch` outcome sets it) → drop the field; the chain is the real durable.

### bunker41_last_evacuation — The Last Evacuation   [data/bunker41_events.json; global, no window; unique=y; weight=1; tags=none]
Scene: In the command room a prewar commander still reads admission names while refused families beat on the door, the Mercy Key lies under the console, and the Cinder Wives wait to learn whether history is carried, exposed, or erased again. See §5 records 7 and 8.
Evidence on screen: the single amber monitor and the lengthening pauses between names; the smooth black core, warm as skin; the Wives gathered behind.
Comparison: certain in all six states and kits; mutual tie (map §3).
Entry: chained from `door_breathes` 1; eligibility `requires_flags [b41_forced_entry]` only, which is also the P0 below.

[0] Take the Mercy Key — see §5 record 7. intention: hold the authorization the system answers to.
    known cost: none | uncertain risk: none
    success: `add_flags [b41_mercy_key, b41_green_invite]` | failure: n/a
    local significance: the monitor stops naming the admitted and begins naming the refused; a platform answers green.
    durable: per record 7 (possession, and the transfers its consumers must forbid). Not stated there: `b41_green_invite` is written here too, so taking the Key is also the ticket into `green_platform` eligibility.
[1] Broadcast the abandoned names — see §5 record 8. intention: make the refusal public.
    known cost: none | uncertain risk: none
    success: `add_flags [b41_abandoned_names, b41_ash_invite, b41_choir_alerted]` | failure: n/a
    local significance: the Wives answer with their own names; a distant choir calls the broadcast blasphemy.
    durable: per record 8; `b41_ash_invite` and `b41_choir_alerted` → `ash_procession` eligibility.
[2] Destroy the records — intention: make sure the sorting cannot be repeated from these files.
    known cost: the evidence | uncertain risk: none
    success: `add_flags [b41_records_destroyed]` | failure: n/a
    local significance: the room goes dark except for the Key's patient pulse; the Wives do not stop it.
    durable: orphan: `b41_records_destroyed` → proposed consumer: `warden_remembers` introduction variant (entry 2), where RECORD INCOMPLETE is partly this survivor's own doing and STORY_CANON §6's "memory to argue against power and nothing else" is finally read.

Disposition: revise — the eligibility must be closed and the burn flag must be read once.
Findings:
P0: eligibility is `requires_flags [b41_forced_entry]` with no region window and weight 1, so a survivor who forced the hatch and then took `door_breathes` 0 keeps the flag and can be dealt this scene later as an ordinary global (no baseline event carries `narrative_priority`, so the priority filter does not exclude it), narrating them as still inside the bunker they fled → add `eligibility.forbids_flags [b41_relay_fragment]`, which covers the only surviving alternative.
P1: `b41_records_destroyed` orphan → `warden_remembers` introduction variant, shared with `b41_ledger_burned`.
P1: `b41_choir_alerted` has two opposite producers — the broadcast here is blasphemy, while record 6's proposed `ash_procession` variant reads the flag as Mara's theft → key record 6's variant on `b41_mara_abandoned` and give `b41_abandoned_names` its own variant, or the Choir accuses the wrong survivor.

### bunker41_fragment_calls — The Fragment That Calls   [data/bunker41_events.json; global, region 5 only; unique=y; weight=8; tags=none]
Scene: The stolen relay fragment wakes a dead evacuation line in the Underrail, and the survivor decides whether to be led by it, to use its signal as bait, or to end it.
Evidence on screen: green lamps igniting along an abandoned platform; the fragment clicking against the ribs; a train speaker announcing a line dead for generations and offering no destination; shadows gathering at the edge of the light.
Comparison: certain in all six states and kits; mutual tie (map §3).
Entry: scheduled global, priority 8, region window 5–5, `requires_flags [b41_relay_fragment]`.

[0] Follow the signal — intention: let the fragment lead somewhere usable.
    known cost: none | uncertain risk: none
    success: `add_flags [b41_green_invite, b41_fragment_followed]` | failure: n/a
    local significance: the lamps resolve into a service diagram toward the Citadel's sealed side, memorized.
    durable: `b41_green_invite` → `green_platform` eligibility (but see the scheduling finding). orphan: `b41_fragment_followed` → proposed consumer: `door_closes` choice 0 outcome variant (entry 1) — the survivor who forces the gate forces the service door this diagram showed them, not the public one.
[1] Use it to mislead pursuers — intention: buy distance with someone else's danger.
    known cost: the fragment | uncertain risk: none
    success: `add_flags [b41_choir_hostile, b41_ash_invite]` | failure: n/a
    local significance: one distant scream cut short; an escape that is clean and unaccounted for.
    durable: `b41_ash_invite` → `ash_procession` eligibility. orphan: `b41_choir_hostile` → proposed consumer: `door_closes` introduction variant (entry 3).
[2] Throw it onto the tracks — intention: stop being findable through the thing you carried.
    known cost: the fragment | uncertain risk: none
    success: `add_flags [b41_fragment_discarded, b41_ash_invite]` | failure: n/a
    local significance: the green lamps die in sequence; fresh ash prints appear beside the rails.
    durable: `b41_ash_invite` → `ash_procession` eligibility. orphan: `b41_fragment_discarded` → retire; no later scene can read a destroyed fragment and the sibling invite already carries the Choir consequence.

Disposition: revise — scheduled behind the doors it is meant to open, plus one orphan consumed and one retired.
Findings:
P1: priority 8 places this scene below `green_platform` (10) and `ash_procession` (9) in the only region all three share, so its `b41_green_invite` and `b41_ash_invite` normally arrive after their consumers have been spent → N04 scheduling: run `fragment_calls` before `green_platform` (priority above 10, or a reserved slot under the map §5 scheduling guarantee).
P1: `b41_fragment_followed` orphan → `door_closes` choice 0 outcome variant.
P1: `b41_fragment_discarded` orphan → retire.

### bunker41_ash_procession — The Ash Choir's Procession   [data/bunker41_events.json; global, region 5 only; unique=y; weight=9; tags=none]
Scene: A disciplined lantern line led by a masked child speaking evacuation orders in the duty voice welcomes the survivor as though their arrival were on a maintenance schedule, and asks what they think of the Choir's right to sort strangers.
Evidence on screen: technician coats patched with ash-coloured cloth and old radio cords; the porcelain mask and the borrowed voice; no weapons raised; the leader's welcome; the bearers' packs (the evidence for [2]).
Comparison: certain in all six states and kits; mutual tie (map §3).
Entry: scheduled global, priority 9, region window 5–5, `requires_any_flags [b41_ash_invite, b41_choir_alerted, b41_unprepared]`.

[0] Join the procession — intention: accept food and warmth and hear the offer out.
    known cost: none | uncertain risk: none
    success: `add_flags [b41_choir_joined]`, `next_event: bunker41_chapel_car` | failure: n/a
    local significance: several minutes of ordinary kindness, then the question of which strangers the survivor would deny.
    durable: `b41_choir_joined` → `chapel_car` eligibility. §5 record 8 removes it from `door_closes` 3, which is right: joining is not the record (STORY_CANON §8).
[1] Speak the bunker's truth — see §5 record 8. intention: put the sealed families in front of the people who preach discipline.
    known cost: none | uncertain risk: none
    success: `add_flags [b41_choir_split, b41_witness, b41_green_invite]` | failure: n/a
    local significance: lanterns lower, the masked child cries, and the Choir divides between warning and declaration of war.
    durable: `b41_witness` per record 8; `b41_green_invite` → `green_platform` eligibility. orphan under record 8: `b41_choir_split` → proposed consumer: `door_closes` introduction variant (entry 4) — lanterns in two groups at the edge of the gate lights, neither speaking to the other.
[2] Rob the lantern bearers — intention: take supplies from people who will not fight back.
    known cost: none | uncertain risk: none — the outcome guarantees "nothing worth the theft"
    success: now: no items, `add_flags [b41_choir_hostile]` | proposed: `items canned_meat 1` plus the same flag | failure: n/a
    local significance: the Choir's radios unify on one shared frequency and repeat the survivor's callsign (STORY_CANON §7).
    durable: orphan: `b41_choir_hostile` → proposed consumer: `door_closes` introduction variant (entry 3).

Disposition: revise — [2] must be a real trade, and both Choir flags need the gate variants.
Findings:
P1: [2] is a certain choice whose stated intention cannot succeed (plan §3: fulfil the intention on success) → now: no items | proposed: `canned_meat 1`, with the outcome naming rations and lantern oil, so the theft buys food and costs an enemy.
P1: `b41_choir_hostile` orphan → `door_closes` introduction variant.
P1: `b41_choir_split` becomes an orphan when record 8 tightens `door_closes` 3 → `door_closes` introduction variant.

### bunker41_green_platform — The Green Platform   [data/bunker41_events.json; global, region 5 only; unique=y; weight=10; tags=none]
Scene: A station absent from every public map lights green under EAST CITADEL SERVICE signs, and the survivor takes the route the chosen were meant to use, the route Mara marked, or the lever that tells everyone where they are.
Evidence on screen: evacuation arrows covered and uncovered by dust; the Mercy Key warming for whoever carries it; Mara's map ending here in a shaking line; hundreds of names scratched into the paint behind a locked office door; the public emergency lever.
Comparison: certain in all six states and kits; mutual tie (map §3).
Entry: scheduled global, priority 10, region window 5–5, `requires_any_flags [b41_green_invite, b41_mercy_key, b41_mara_helped, b41_relay_fragment]`.

[0] Take the service route — intention: walk in the way the admitted were meant to.
    known cost: none | uncertain risk: none
    success: `add_flags [b41_service_route]`, `next_event: bunker41_false_welcome` | failure: n/a
    local significance: rows of evacuation tags, each carrying a number where a person's future should have been.
    durable: `b41_service_route` → `false_welcome` eligibility.
[1] Search for Mara's trail — intention: follow the person rather than the system.
    known cost: none | uncertain risk: none
    success: `add_flags [b41_ledger_route]`, `next_event: bunker41_ledger_living` | failure: n/a
    local significance: LIVING PEOPLE BELOW under the platform lip, and water cups left outside sealed doors.
    durable: `b41_ledger_route` → `ledger_living` eligibility.
[2] Activate the station openly — intention: refuse to move through a hidden system quietly.
    known cost: exposure | uncertain risk: none
    success: `add_flags [b41_public_signal, b41_ash_invite]` | failure: n/a
    local significance: both tunnels lit at once; a Citadel security response announced; Choir radios answering from the dark.
    durable: `b41_ash_invite` → `ash_procession` eligibility, but only if that scene has not already run (see the `fragment_calls` scheduling finding). orphan: `b41_public_signal` → proposed consumer: `warden_remembers` introduction variant (entry 1) — the Warden's display already carries the station this survivor woke.
Key line: the introduction's "The Mercy Key warms if you carry it" needs the post-transfer variant contracted in §5 record 7.

Disposition: revise — the announced response must arrive somewhere.
Findings: P0: [2] promises that whatever reaches the survivor next will know exactly where they chose to stand, and nothing reads `b41_public_signal`; the Citadel response never comes → give the flag the `warden_remembers` introduction variant (entry 1), so the promise is paid by the machine running the same protocol.

### bunker41_chapel_car — The Chapel Car   [data/bunker41_events.json; global, no window; unique=y; weight=1; tags=none]
Scene: In a subway carriage turned chapel the Choir's founder confesses on a damaged monitor while the living Choir offers shelter, food and a place in exchange for the survivor accepting their right to judge strangers. See §5 records 7 and 8.
Evidence on screen: emergency maps used as altar cloths; names scratched inside the windows and crossed out in ash; the founder's monitor; the offer itself.
Comparison: certain in all six states and kits; mutual tie (map §3).
Entry: chained from `ash_procession` 0; eligibility `requires_flags [b41_choir_joined]`.

[0] Give them the Mercy Key — see §5 record 7. intention: hand the old authority to people who believe they can use it well.
    known cost: the Key | uncertain risk: none
    success: `add_flags [b41_key_surrendered, b41_choir_bound]` | failure: n/a
    local significance: the Choir receives the core as if it were a newborn child, then learns their founder helped seal the outer door.
    durable: per record 7 (transfer) and record 8 (`b41_choir_bound` gates the Ash ending). Not stated in either record: this choice carries no `requires` block at all, so a survivor who never took the Key can surrender it. See P0.
[1] Steal the founder's records — see §5 record 8. intention: take the confession that makes the Choir answerable.
    known cost: the Choir's goodwill | uncertain risk: none
    success: `add_flags [b41_choir_records, b41_witness]` | failure: n/a
    local significance: proof in a pocket, aboard a car full of believers who would kill to bury it.
    durable: per record 8 — `b41_choir_records` → `warden_remembers` 2 and `door_closes` 3.
[2] Refuse their judgement — intention: deny anyone the right to sort the next line of desperate people.
    known cost: shelter and food | uncertain risk: none
    success: `add_flags [b41_choir_split, b41_witness]` | failure: n/a
    local significance: the masked child is unmasked and ordinary; three bearers step away from the altar, everyone else reaches for a weapon.
    durable: `b41_witness` per record 8; `b41_choir_split` is orphan under record 8 and takes the `door_closes` introduction variant proposed at `ash_procession` [1].

Disposition: revise — the Key transfer must require the Key.
Findings: P0: [0] has no `requires`, so a survivor who never held the Mercy Key can still surrender it, writing `b41_key_surrendered` and `b41_choir_bound` — and under §5 record 8 `b41_choir_bound` is one of the two keys to the Ash ending, so an ending is unlocked by giving away an object the survivor never had → add `requires.flags [b41_mercy_key]` beside record 7's `forbids_flags [rustsea_key_with_mara]`, `reason "You do not hold the Key"`; [1] and [2] stay ungated.

### bunker41_false_welcome — The False Welcome   [data/bunker41_events.json; global, no window; unique=y; weight=1; tags=none]
Scene: The service corridor ends in a waiting room built for evacuees who never arrived, with the Citadel's archive glowing behind a reinforced door and a warning strip about containment systems that names no contents.
Evidence on screen: children's shoes under benches; thousands of numbered tags in drawers beside the promise of clean air, medical care and onward transport; the glowing servers; the warning strip.
Comparison: certain in all six states and kits; mutual tie (map §3).
Entry: chained from `green_platform` 0; eligibility `requires_flags [b41_service_route]`.

[0] Open the archive — intention: read what the promise was actually built on.
    known cost: none | uncertain risk: none — the containment warning never resolves into a mechanical risk
    success: `add_flags [b41_archive_truth, b41_witness]` | failure: n/a
    local significance: selected families, rejected families, quotas in serene administrative language, and Bunker Forty-One's final order preserved in full.
    durable: `b41_witness` per §5 record 8. orphan: `b41_archive_truth` → proposed consumer: add it as a key to record 8's evidence-naming success variants at `warden_remembers` 2 and `door_closes` 2, so this survivor is described reading the Citadel's own order back to it rather than generic testimony.
[1] Leave hope untouched — intention: keep the clean lights meaning something uncomplicated.
    known cost: the evidence | uncertain risk: none
    success: `add_flags [b41_mercy]` | failure: n/a
    local significance: hope carried on as deliberate blindness.
    durable: orphan: `b41_mercy` → proposed consumer: `door_closes` choice 0 outcome variant (entry 2) — the survivor enters clean air without ever having read its price.
[2] Burn the access files — intention: deny a future official the sorting index.
    known cost: the evidence | uncertain risk: none
    success: `add_flags [b41_records_destroyed, b41_mercy]` | failure: n/a
    local significance: smoke in the waiting room while the server lights keep glowing behind sealed glass.
    durable: both orphans — `b41_records_destroyed` → `warden_remembers` introduction variant (entry 2, with `b41_ledger_burned`); `b41_mercy` → as [1]. STORY_CANON §6 keeps burning a real loss that nothing rewards and nothing punishes beyond absence.

Disposition: revise — three flags written here are read nowhere; two variants fix all three.
Findings:
P1: `b41_archive_truth` orphan → add as a key to record 8's evidence-naming variants at `warden_remembers` 2 and `door_closes` 2.
P1: `b41_mercy` orphan (also `false_welcome` 2 and `ledger_living` 2) → `door_closes` choice 0 outcome variant.

### bunker41_ledger_living — The Ledger of the Living   [data/bunker41_events.json; global, no window; unique=y; weight=1; tags=none]
Scene: Behind the platform, sealed maintenance rooms and a ledger of water deliveries mark people STILL BREATHING in the margins of a service line that refuses to acknowledge them. See §5 record 8.
Evidence on screen: the wheeled cart and its ledger; entries weeks old; Mara Venn's hand, if she ever escaped; a child's drawing of a green gate; the locks themselves.
Comparison: certain in all six states and kits; mutual tie (map §3).
Entry: chained from `green_platform` 1; eligibility `requires_flags [b41_ledger_route]`.

[0] Open the sealed rooms — see §5 record 8. intention: get the living out.
    known cost: now: none, though the prose says "you spend precious time" | proposed: `costs.pressures fatigue 8` (record 8) | uncertain risk: none
    success: `add_flags [b41_rescued_survivors, b41_witness]` | failure: n/a
    local significance: frightened people guided into the platform light, giving names and testimony; the bunker becomes an accusation that still breathes.
    durable: per record 8. Not stated there: STORY_CANON §6 forbids turning the rescued into allies, items or advantages, so the fatigue is the whole cost and the flag is the whole reward.
[1] Copy the ledger and continue — intention: take the names without opening doors you cannot protect.
    known cost: none | uncertain risk: none
    success: `add_flags [b41_ledger_copy, b41_witness]` | failure: n/a
    local significance: the people behind the metal call out softly and are left there.
    durable: `b41_witness` per record 8. `b41_ledger_copy` is orphan today; its consumer is already contracted in record 8 as "a copied ledger" among the evidence-naming variants.
[2] Destroy the ledger — intention: stop living names from becoming a new quota.
    known cost: the names | uncertain risk: none
    success: `add_flags [b41_ledger_burned, b41_mercy]` | failure: n/a
    local significance: one brief warmth in a sealed corridor; someone behind the doors begins singing an evacuation song.
    durable: orphans — `b41_ledger_burned` → `warden_remembers` introduction variant (entry 2, with `b41_records_destroyed`); `b41_mercy` → `door_closes` choice 0 outcome variant (entry 2).

Disposition: revise — record 8's cost, and the burn flags read once at the gate.
Findings:
P0: [0] narrates "precious time" and charges nothing → implement §5 record 8: `costs.pressures fatigue 8`.
P1: `b41_ledger_burned` orphan → `warden_remembers` introduction variant.

### bunker41_warden_remembers — The Warden Remembers   [data/bunker41_events.json; global, region 6+; unique=y; weight=1; tags=none]
Scene: The Warden rolls out of the Citadel shadow with BUNKER 41 / SOTERIA / RECORD INCOMPLETE across its armour and asks for authorization in the duty voice; the survivor refuses it, fights it, or answers it with evidence.
Evidence on screen: the lowered but ready weapon; the scanner pausing longer than it should; the damaged display; the request for authorization. What the survivor is carrying is the evidence for [2].
Comparison: [0] and [2] certain in all six states and kits; [1] `fight T20 +100xp flee:n` in every state; the tool reports redundant [0,1] plus the usual dominance ties (map §3).
Entry: finale-chained — all five `final_gate_1` outcomes set `next_event: bunker41_warden_remembers`, and region 6 never runs `_select_next_event`.

[0] Refuse its authority — intention: deny any machine the right to price a life.
    known cost: none | uncertain risk: none
    success: `next_event: bunker41_door_closes`, no flags | failure: n/a
    local significance: the gate is reduced to one survivor and one machine — except that the outcome ends with the Warden raising its weapon and then nothing happens.
    durable: chain only.
[1] Attack the Warden — intention: remove the thing that decides.
    combat: `adversary_id warden_machine`, threat 20, `xp_reward` 100, `can_flee: false`, so defeat is death under permadeath. `data/adversaries.json` lists `loot: [signal_compass]`, but no script reads that field, so victory pays XP only.
    victory: `next_event: bunker41_door_closes`, no flags; no `critical_victory` and no `defeat` fields
    local significance: the dying screen repeats the admission list and clears; STORY_CANON §7's gate "without a machine left to tell you whether you deserve it".
    durable: none today → proposed `add_flags [b41_warden_destroyed]` on victory, consumer: `door_closes` introduction variant (entry 1).
    On the comparison's redundant [0,1]: keeping both is acceptable. The outcome fields are identical, but this is the only reachable `warden_machine` fight (queue N00 finding 2), it costs a 550-HP threat-20 exchange with no flee, it pays 100 XP, and the intentions differ (refuse versus destroy). What is not acceptable is that the gate cannot tell the two apart afterwards; the proposed victory flag removes exactly that.
[2] Invoke the Bunker record — see §5 record 8. intention: answer the protocol with what the road produced.
    known cost: none | uncertain risk: none
    requires: now `any_flags [b41_mercy_key, b41_witness, b41_abandoned_names, b41_choir_records, b41_rescued_survivors]` | proposed: add record 7's `forbids_flags [b41_key_surrendered, rustsea_key_with_mara]`
    success: `add_flags [b41_warden_heard]`, `next_event: bunker41_door_closes` | failure: n/a
    local significance: the weapon lowers by a fraction; the protocol can call neither the dead mistaken nor the living unauthorized, and the machine hesitates.
    durable: orphan: `b41_warden_heard` → proposed consumer: `door_closes` introduction variant (entry 2). Success variants per record 8, extended with `b41_archive_truth`.

Disposition: revise — the introduction must stop claiming recognition, the refusal must stop raising a weapon it never uses, and the only Warden fight must leave a trace.
Findings:
P0: the introduction says the machine asks "in the voice of the woman from the salt flats" for every survivor (STORY_CANON §10 row 1) → introduction variants in the order given above, default claiming no recognition. Keying note: §5's rule names `b41_contact`, but in loaded data `bunker41_static` writes `b41_recording`/`b41_answered`/`b41_unprepared` and `b41_contact` is written by all three `rusted_hatch` outcomes including "Mark it and leave", so recognition must key on `any [b41_recording, b41_answered, b41_quiet_path, b41_forced_entry]` to keep §5's intent true.
P0: [0]'s outcome ends "Then it raises the weapon" and chains straight to the door (plan §6; STORY_CANON §10) → rewrite the closing sentences so the weapon stays tracked and unfired and the gate mechanism takes over; index 1 already carries the fight, so do not add a mandatory one.
P1: [1] writes nothing and reads identically to the refusal → `add_flags [b41_warden_destroyed]` on victory, consumed by the `door_closes` introduction variant.
P1: `b41_warden_heard` orphan → `door_closes` introduction variant.

### bunker41_door_closes — The Door That Closes   [data/bunker41_events.json; global, region 6+; unique=y; weight=1; tags=none]
Scene: The Citadel gate opens a hand's width, clean air comes through it, the mechanism starts to close, and the survivor decides which story enters with them. Four endings, STORY_CANON §8.
Evidence on screen: the gap and the clean air; the white lights and the people who may still believe their walls were built without sacrifice; the closing mechanism; whatever the survivor carries — Key, names, or the founder's confession.
Comparison: all four certain in all six states and kits; redundant [0,1], [0,2], [0,3], [1,2], [1,3], [2,3]; gated: [1] flag `b41_mercy_key`, [2] any_flag (1 of 4), [3] any_flag (1 of 4). Four `victory: true` outcomes distinguished only by requirement and prose is the endings design (§8), not a defect.
Entry: chained from all three `bunker41_warden_remembers` outcomes.

[0] Force your way through — Silence. intention: survive, and leave the road's voices outside.
    requires: now: none | proposed: none — §8's one ending always available
    known cost: none | uncertain risk: none
    success: `victory: true`, no flags | failure: n/a
    local significance: the locks engage behind the survivor; the unanswered voices stay outside the wall.
    durable: the ending. Proposed outcome variants: (1) `b41_fragment_followed` — the door forced is the service door the fragment mapped; (2) `b41_mercy` — the survivor enters clean air without ever having read its price; (3) default as authored.
[1] Offer the Mercy Key — Mercy. intention: use the old authority's own token.
    requires: now: `flags [b41_mercy_key]` | proposed: add `forbids_flags [b41_key_surrendered, rustsea_key_with_mara]`, `reason "You no longer hold the Key"` (§5 record 7; STORY_CANON §6)
    known cost: the Key | uncertain risk: none
    success: `victory: true`, no flags | failure: n/a
    local significance: the staff recognize the old authority and recoil from its history; admission under emergency protocol.
    durable: the ending; `ledger_b41_key` records that the Key was seen.
[2] Read the names aloud — Witness. intention: make silence impossible.
    requires: now: `any_flags [b41_witness, b41_abandoned_names, b41_mara_helped, b41_rescued_survivors]` | proposed: unchanged (§5 record 8), plus success variants naming the evidence actually used — rescued people present (`b41_rescued_survivors`), a copied ledger (`b41_ledger_copy`), a broadcast (`b41_abandoned_names`), and the Citadel's own archive order (`b41_archive_truth`, this batch's addition to record 8).
    known cost: none | uncertain risk: none
    success: `victory: true`, no flags | failure: n/a
    local significance: the gate opens not because the Citadel becomes innocent but because silence becomes impossible.
    durable: the ending; `ledger_ending_witness` in `data/road_ledger.json`.
[3] Play the Ash Choir record — Ash. intention: break the Choir's faith in public.
    requires: now: `any_flags [b41_choir_joined, b41_choir_records, b41_choir_split, b41_choir_bound]` | proposed: `any_flags [b41_choir_records, b41_choir_bound]` only (§5 record 8; STORY_CANON §8)
    known cost: none | uncertain risk: none
    success: `victory: true`, no flags | failure: n/a
    local significance: the founder's confession fills the gate speakers; the survivor enters amid argument, grief and living doubt.
    durable: the ending. Addition record 8 omits: the two remaining keys are not the same act — `b41_choir_records` is a confession the survivor copied and plays, `b41_choir_bound` is a Choir that holds the Key and the founder's monitor and plays it themselves — so the outcome needs one variant each, or the prose gives the bound survivor a recording they never took.
Proposed introduction variants, in match order: (1) `b41_warden_destroyed`; (2) `b41_warden_heard`; (3) `b41_choir_hostile`; (4) `b41_choir_split`; (5) default naming only what this survivor actually passed.

Disposition: revise — two requirement contracts from §5 records 7 and 8, plus the variant sets that finally read nine late flags.
Findings:
P0: [1] is offered after the Key was given to the Choir or to Mara → record 7's `forbids_flags` and reason.
P0: [3] is unlocked by affiliation without the founder's record → record 8's tightened `any_flags`.
P1: the introduction names the sleeping bunker and the Ash Choir for survivors who met neither → default introduction variant naming only what this survivor passed.
P1: [3] needs a `b41_choir_bound` outcome variant, or it narrates a record that survivor never took.

## Batch summary

DISPOSITIONS:
bunker41_static | revise | orphan b41_answered needs the Warden variant its own outcome promises
bunker41_rusted_hatch | keep | three distinct entries, every flag consumed, refusal still reaches the Choir
bunker41_cartographer | revise | §5 record 6 cost and lock, and b41_mercy_refused retired
bunker41_door_breathes | keep | the lethal route carries all three warnings and the Hush Sovereign stays a mystery
bunker41_last_evacuation | revise | eligibility must forbid b41_relay_fragment and the burn flag needs a reader
bunker41_fragment_calls | revise | scheduled behind the doors it opens; one orphan consumed, one retired
bunker41_ash_procession | revise | the robbery must yield something and both Choir flags need gate variants
bunker41_green_platform | revise | the announced Citadel response must arrive as the Warden's record
bunker41_chapel_car | revise | the Key transfer must require holding the Key
bunker41_false_welcome | revise | b41_archive_truth and b41_mercy need the named variants
bunker41_ledger_living | revise | §5 record 8's fatigue 8 for the "precious time" the prose already spends
bunker41_warden_remembers | revise | recognition variants, the unfired weapon, and a victory flag for the only Warden fight
bunker41_door_closes | revise | records 7 and 8 requirements plus the variant sets that read nine late flags

FINDINGS:
P0 | bunker41_cartographer | 0 | sharing a ration spends no food → §5 record 6: costs.items canned_meat 1, requires.reason "You have no food to share"; choices 1 and 2 stay ungated
P0 | bunker41_last_evacuation | - | eligibility requires_flags [b41_forced_entry] with no window and weight 1, so the command room can be dealt after the survivor fled with the relay → add eligibility.forbids_flags [b41_relay_fragment]
P0 | bunker41_green_platform | 2 | prose promises that whatever comes next will know where the survivor stood, but b41_public_signal has no consumer → warden_remembers introduction variant, entry 1
P0 | bunker41_chapel_car | 0 | no requires block, so a survivor who never took the Key can surrender it and write b41_choir_bound, which record 8 makes an Ash key → add requires.flags [b41_mercy_key] with record 7's forbids_flags [rustsea_key_with_mara], reason "You do not hold the Key"
P0 | bunker41_ledger_living | 0 | "you spend precious time" charges nothing → §5 record 8: costs.pressures fatigue 8
P0 | bunker41_warden_remembers | - | the introduction claims recognition of the duty voice for every survivor → introduction variants, default without recognition; key recognition on any [b41_recording, b41_answered, b41_quiet_path, b41_forced_entry], because b41_contact is written even by "Mark it and leave"
P0 | bunker41_warden_remembers | 0 | the refusal ends with the weapon raised and chains straight to the door → rewrite the closing sentences so the weapon stays tracked and unfired; index 1 already carries the fight
P0 | bunker41_door_closes | 1 | Mercy offered after the Key was transferred → §5 record 7: forbids_flags [b41_key_surrendered, rustsea_key_with_mara], reason "You no longer hold the Key"
P0 | bunker41_door_closes | 3 | Ash unlocked by affiliation without the record → §5 record 8: requires.any_flags [b41_choir_records, b41_choir_bound] only
P1 | bunker41_static | 1 | orphan b41_answered → warden_remembers introduction variant, and add the flag to rustsea_green_line eligibility beside b41_recording (batch F coordination)
P1 | bunker41_cartographer | 2 | orphan b41_mercy_refused, and record 6 keys the neutral opening on absence → retire the flag
P1 | bunker41_last_evacuation | 1 | b41_choir_alerted has two opposite producers (Mara's theft, the names broadcast) → key record 6's ash_procession variant on b41_mara_abandoned and give b41_abandoned_names its own variant
P1 | bunker41_last_evacuation | 2 | orphan b41_records_destroyed → warden_remembers introduction variant, entry 2, shared with b41_ledger_burned
P1 | bunker41_fragment_calls | - | priority 8 schedules it after green_platform (10) and ash_procession (9) in region 5, so its invites arrive after their consumers are spent → N04: schedule it before green_platform, or reserve its slot under map §5
P1 | bunker41_fragment_calls | 0 | orphan b41_fragment_followed → door_closes choice 0 outcome variant, entry 1
P1 | bunker41_fragment_calls | 2 | orphan b41_fragment_discarded, with nothing left that can read a destroyed fragment → retire
P1 | bunker41_ash_procession | 2 | the theft guarantees "nothing worth the theft" → now: no items | proposed: canned_meat 1, with the outcome naming rations and lantern oil
P1 | bunker41_ash_procession | 2 | orphan b41_choir_hostile (also fragment_calls 1) → door_closes introduction variant, entry 3
P1 | bunker41_ash_procession | 1 | b41_choir_split loses its only consumer under record 8 → door_closes introduction variant, entry 4
P1 | bunker41_false_welcome | 0 | orphan b41_archive_truth → add as a key to record 8's evidence-naming variants at warden_remembers 2 and door_closes 2
P1 | bunker41_false_welcome | 1 | orphan b41_mercy (also false_welcome 2 and ledger_living 2) → door_closes choice 0 outcome variant, entry 2
P1 | bunker41_ledger_living | 2 | orphan b41_ledger_burned → warden_remembers introduction variant, entry 2
P1 | bunker41_warden_remembers | 1 | the only reachable warden_machine fight writes nothing and reads identically to the refusal → add victory add_flags [b41_warden_destroyed], consumed by the door_closes introduction variant
P1 | bunker41_warden_remembers | 2 | orphan b41_warden_heard → door_closes introduction variant, entry 2
P1 | bunker41_door_closes | - | the introduction names the sleeping bunker and the Ash Choir for survivors who met neither → default introduction variant naming only what this survivor passed
P1 | bunker41_door_closes | 3 | b41_choir_records and b41_choir_bound are different acts → one outcome variant each, or the prose gives the bound survivor a record they never took
P2 | bunker41_door_breathes | 1 | add_flags [b41_contact] is a no-op because every rusted_hatch outcome already writes it → drop the field; the chain is the durable
