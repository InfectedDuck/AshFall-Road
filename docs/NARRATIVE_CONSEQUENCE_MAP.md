# Narrative consequence map

Started 8 September 2026 for N02 of [NARRATIVE_REFINEMENT_PLAN.md](NARRATIVE_REFINEMENT_PLAN.md). Canon is quoted from [STORY_CANON.md](STORY_CANON.md) and [CREATURE_STORY_BIBLE.md](CREATURE_STORY_BIBLE.md), never re-derived. Prose rules are in [LIVING_ROAD_NARRATIVE_BIBLE.md](LIVING_ROAD_NARRATIVE_BIBLE.md).

This is a design document. It changes no content. Every reward, cost, flag, and requirement written here is a contract for N03–N06 to implement and N08 to verify; until then the loaded content is what [NARRATIVE_REFINEMENT_QUEUE.md](NARRATIVE_REFINEMENT_QUEUE.md) says it is.

## Structure

The map has three layers:

1. **Design cards** — one per event, one entry per indexed choice, for all 112 expanded-configuration events plus the four appended creature choices. They live in `docs/consequence_map/` by batch, linked from the index below, so a single card can be found and revised without moving forty thousand words.
2. **Return records** — the eleven-line record from plan §4 for every major commitment. They live in this file (§5) because they cross events and need one author.
3. **Dispositions and priorities** — every event's keep / revise / redesign verdict and every P0 / P1 / P2 finding, in this file (§6, §7), summarizing the cards.

Measured input: `tools/choice_comparison.gd` evaluates every checked choice with the real engine's `get_choice_preview` under the survivor states in §3 and writes `builds/choice_comparison.json` and `builds/choice_comparison.md`. Cards cite its numbers; nobody estimates a percentage by hand.

Second measured input: `builds/flag_index.md` lists every flag in the expanded configuration with its producers and consumers, derived from the four event files, the 22 source-flag patches, and the Chronicle's variant requirements. Current state: **179 flags, 179 produced, 130 consumed, 49 orphans, 0 dangling reads.** A card's orphan claim is checked against this index rather than trusted, because each batch sees only its own events and a consumer can live in another batch.

## 1. Definitions

**Intention.** What a player who picks this choice is trying to do, in one clause. Two choices with the same intention are the same choice and one must go.

**Evidence.** What the introduction shows the player so the intention is a decision, not a guess: the object, mark, sound, or person that makes this option visible. "Nothing" is a P1 finding.

**Known cost.** What the player is told they will spend or risk before committing: an item consumed, a check with visible odds, fatigue, time. Costs that are only discovered afterward are P0 false costs.

**Uncertain risk.** What could go wrong that the player cannot price exactly: the failure outcome's damage, condition, or loss. Written as the failure outcome's actual mechanical fields.

**Success reward.** The exact `items`, `pressures`, `add_conditions`, `add_flags`, and `next_event` of the success (or `outcome`, or `victory`) branch. Never "some supplies."

**Failure aftermath.** The same for the failure branch, plus what the prose says the survivor now knows or lacks.

**Local significance.** What is different in the world after this scene regardless of any later callback: a door open, a person alive, a line dark, a debt refused.

**Durable effect.** The run-state fact written (a flag, an item that persists as evidence, a `next_event` chain) *and its consumer*. A flag with no consumer is recorded as **orphan** and is a P1 finding unless the card retires it.

**Scales** (plan §4): *immediate* (every choice has one), *later in this run* (major commitments), *ending or Chronicle* (where a thread ends).

**Major commitment.** A choice whose durable effect must be read later in the same run. The list is fixed in §5; a card may propose an addition, not assume one.

## 2. Card template

Cards use this exact shape so N08 can lint them. Copy the block per event.

```text
### <event_id> — <Title>   [<source file>; <region or global>; unique=<y/n>; weight=<n>; tags=<...>]
Scene: <one sentence: the disturbance and the decision it forces>
Evidence on screen: <what the introduction shows for each choice's intention>
Comparison: <one line from builds/choice_comparison.md: healthy vs depleted chance per checked choice; any dominance flag>

[0] <label> — intention: <clause>
    known cost: <...> | uncertain risk: <failure fields>
    success: <exact reward fields> | failure: <exact fields>
    local significance: <...>
    durable: <flag/chain → consumer, or "none", or "orphan: <flag>">
[1] ...
[2] ... (appended creature choice where applicable; mark APPENDED)

Disposition: keep | revise | redesign — <one sentence why>
Findings: <P0/P1/P2 lines, each "Pn: <problem> → <required change>", or "none">
```

Rules for filling it:

- Read the prose that actually loads. Baseline events load with both override files applied; Bunker, Rust-Sea, and Living Road events load as authored. `tools/content_dossier.gd` output in `builds/` gives every mechanical field; the text comes from the data files.
- Quote canon by section number rather than paraphrasing it: `STORY_CANON §6` for Key possession, `§5` for observation/belief, `§8` for endings; `CREATURE_STORY_BIBLE` entry name for a creature.
- Reward and cost fields are the JSON fields, exactly, including quantities. If the card proposes a change, write `now: <current>` and `proposed: <new>` on the same line so the allowlist can be generated from the cards.
- A **redesign** disposition must say what the new intention set is. A **revise** must say which field or passage changes. **Keep** needs no defence beyond the sentence.
- Do not propose new events, items, stats, shops, or currencies. Do not propose `remove_flags`; it does not exist. New flags need a named consumer in the same card or in §5.
- Combat choices: record the adversary, threat, XP, and whether flee is allowed. Flee resolves no outcome and writes no flag; a card that needs a victory-only flag must say so.

## 3. Survivor states for comparison

Six states, evaluated for each of the four starting kits (highest stat Strength, Agility, Wits, or Grit/Presence, which decide the starting weapon and armor) at level 1 base stats, and again at a progressed 21-point allocation. `tools/choice_comparison.gd` builds each state on a real run and calls `get_choice_preview`, so item modifiers, condition penalties, and the survival-strain penalty are the engine's own.

| State | Definition | Engine effect on checks |
|---|---|---|
| **healthy** | Full HP, satiety 4, pressures 0, no conditions, starting kit | none |
| **hungry** | satiety 0, fatigue 40 | −3 satiety, −1 fatigue band |
| **injured** | HP ≤ 25% of max, `bleeding` | −2 low-health, Str −1, Grit −1 |
| **irradiated** | radiation 60, `irradiated` | −2 radiation band, Str −1, Grit −2 |
| **supplied** | healthy plus best regional gear equipped and full ammunition | item stat/approach bonuses |
| **depleted** | hungry, HP ≤ 25%, radiation 60, `exhausted`, no ammunition, weapon unloaded | all of the above; ranged weapon reads unloaded |

The tool reports, per checked choice: chance under each state and kit, the required roll, and two flags:

- **Dominant** — among a scene's choices, one has chance ≥ every sibling in every state *and* a success reward at least as good by the item/pressure totals *and* no greater known cost. A dominant choice makes its siblings decoration.
- **Redundant** — two choices whose success and failure fields are identical, or whose intentions read the same. Redundancy is P1; dominance is P1 unless the dominated choice preserves useful expertise (a stat the player invested in), in which case the card says so and keeps it.

Certain choices (no check) are compared by reward only. Combat choices are compared by threat, XP, and flee availability.

As built and measured (`tools/choice_comparison.gd`, 13,968 previews, RNG proven unchanged in every block):

- Kits are Strength, Agility, Wits, and Grit. The Presence kit (revolver, trader token) is not measured; cards for Presence checks note the gap rather than guess.
- Early = kit stat 5, the other four 3/3/2/2 in STATS order (15 points). Progressed = +3 to the kit stat and +1 to the first three others (21 points).
- **Supplied is combat-best gear**, not check-best: the highest-damage weapon and highest-rated armor. In 74 of 704 early checked cells that *lowers* the chance (a shotgun loses the pistol's Agility bonus; the rifle loses the probe's technical bonus). Cards read supplied as "what a fighter carries", not as a bonus state.
- **Beneficial conditions score as nothing** in the reward rule, so a choice whose only reward is Focused, Inspired, Steady Hands, or Momentum reads as unrewarded. The one false positive today is `global_clear`; cards treat a beneficial condition as a real reward and say so.
- Every Bunker and Rust-Sea event reports as a mutual tie because their choices are all certain and differ only in flags and prose. That is expected: those scenes are judged by durable effect, never by odds.
- Strictly dominant today: `final_gate_1` 0, `global_clear` 0, `lr_cup_passed_east` 2, `lr_pharmacy_witness` 2, `rail_hunters` 1. Redundant by identical mechanics: `bunker41_door_closes` 0–3 (four `victory` outcomes distinguished only by requirements and prose, which is by design), `bunker41_warden_remembers` 0/1, `final_gate_3` 0/2.

## 4. Index of card batches

| Batch | Events | File |
|---|---|---|
| A | Shattered Outskirts pool (10), the 12 baseline globals, and `fallback_dust` | `consequence_map/A_outskirts_globals.md` |
| B | Salt Flats pool (10) and Drowned Marches pool (10) | `consequence_map/B_flats_marches.md` |
| C | Hollow Industrial pool (10) and Glass Wastes pool (10) | `consequence_map/C_industrial_glass.md` |
| D | Underrail pool (10) and the three gate events | `consequence_map/D_underrail_gate.md` |
| E | Bunker Forty-One (13) | `consequence_map/E_bunker41.md` |
| F | Rust-Sea (8) and Living Road (15) | `consequence_map/F_rustsea_livingroad.md` |

Total: 23 + 20 + 20 + 13 + 13 + 23 = 112. The four appended creature choices are inside A (`outskirts_apartment`), B (`marsh_lights`), C (`industrial_tank`), and D (`rail_signal`).

## 5. Return records for major commitments

Each record is the eleven-line contract from plan §4. Flags marked `proposed` do not exist yet. Two narrow engine extensions are assumed throughout and are N04's to build and test: **conditional passages** (an introduction or outcome may carry `variants: [{requires_any_flags, text}]`, first match wins, default text otherwise) and **choice gating extensions** (`requires.forbids_flags`; a `requires.reason` string for the lock label; `requires.hidden_when_locked: true` for gates whose flag a player could not yet know about). Everything else uses fields the applier already supports: `requires.flags` / `any_flags` / `items`, `costs.items`, `add_flags`, `next_event`, eligibility windows, and eligibility `forbids_flags`.

**Implemented in N04, and measured.** What shipped differs from the design below in one way worth reading before relying on it, so the shipped behaviour is stated first.

A thread becomes **focused** when one of its chapters actually resolves, and focus is *derived*, never stored: it is the `callback_thread` of the earliest callback event in `event_history`, so the save schema stays 5 and a run saved before N04 enrolls itself. The focused thread's next eligible chapter takes the first ordinary slot of its region, after the forced-combat and forced-supply guarantees and ahead of any competitor, including `bunker41_rusted_hatch` at priority 10 and `rustsea_green_line` at 11. It never bypasses eligibility, uniqueness, recency, or the one-callback-per-region flag, and it consumes no RNG.

Measured over 200 seeded journeys with all five sources live and the Bunker competing: **focused-thread completion rose from 0.670 to 1.000**, independently reproduced at 100/100. Pacing is unchanged: exactly five events drawn per region before and after, the supply guarantee holds 200/200 in every region, and combat opportunities stay in the same 1–2 band (a 0.55% shift in raw count, five times smaller than the pre-existing launch/expanded gap). The launch configuration is bit-identical, because no callback loads there.

**Two limitations, recorded rather than hidden.**

*The window widening is inert.* Every chapter's `max_region_index` was widened by one region and the loader now enforces that slack as a contract, but across 800 seeded journeys **no chapter has ever resolved in its widened region**. That is not a defect: the reservation means a due chapter no longer loses its slot, so the fallback it was meant to provide is never needed. It stays as a safety net. If it must actually engage, `lr_callback_region_N` would have to become a per-region-visit gate instead of a run-permanent flag, which would change the one-callback-per-region contract; that is not authorized here.

*Only three of the five threads can hold focus in a run that resolved a region-0 source.* Focus goes to the first chapter that resolves, and `family_on_nine`, `quiet_column` and `road_debt` all open in region 1, while `nightfire_caravan` opens in region 2 and `water_commons` in region 3. In 200 competing runs, focus was one of those three every time. All five threads still complete 1.000 **in isolation**, so every arc is provable across different recorded histories, which is what plan §4 asks for and consistent with its own "Do not promise all five complete arcs in one run". A run that never resolves an Outskirts source can still focus water or fire. N06 owns the decision of whether that is good enough or whether focus should follow the most recent engagement instead.

The original design, retained because the rest of it is what shipped:

The scheduling guarantee for records 1–5 is one design, stated once. **Once a source flag for a thread exists, its next chapter is due.** N04 reserves the first ordinary slot in the chapter's region for the due chapter, after the region's forced combat and supply guarantees and before any unrelated global. If the region window closes without the chapter, the chapter's `max_region_index` becomes one region wider than today and its introduction carries a *later than expected* variant. One thread is focused per run: the first thread whose chapter actually resolves becomes the focus; other threads' due chapters keep today's priority rather than a reserved slot. A thread is never lost to random selection; it ends only by refusal, death, or its own final chapter.

### 1. Channel Nine — the Vale family

```text
Source: outskirts_child_radio / 0 (answer, Presence favorable) success → lr_channel_helped; failure → lr_channel_misled. / 1 (triangulate, Wits risky) success → lr_channel_traced + signal_compass, scrap_parts; failure → lr_channel_lost.
Known: helped — Talia heard the survivor's voice and one set of landmarks. misled — a recording played; nobody living answered. traced — the survivor found the relay kit and a bearing but never spoke to the family. lost — an hour wasted.
Cost / reward: 0 risks Shaken on failure, grants Inspired on success; 1 costs Fatigue on failure, grants compass and parts on success. No item cost. helped_family is an orphan → retire.
Durable: the four lr_channel_* flags (existing).
Consumers: lr_blue_van (region 1, eligibility any of the four) → lr_voice_in_reeds (2) → lr_last_battery (3).
Changes there: today all four histories meet the same van. Proposed: (a) blue_van introduction variants — helped: Talia repeats the survivor's own landmark back; misled: she asks why a stranger answered a recording; traced/lost: nobody in the van has heard this voice. (b) choice 0 "Repeat what you told them" gains requires.any_flags [lr_channel_helped, lr_channel_misled], reason "You never spoke to them", hidden_when_locked. (c) new choice 3 "Show them the relay bearing" requires lr_channel_traced, costs signal_compass 1, certain → lr_family_linked: the survivor gives up a navigation item for the thread. Reeds and battery keep their mechanics; each introduction gains one variant citing the van's last state.
Timing: blue_van region 1 priority 7, due on any source flag under the guarantee above.
Failure / refusal / missed / death: failed help continues (distrusts, silenced still lead to reeds). "Leave them your bearing" keeps the thread open at a distance. Missed → widened window and late variant. Death → Chronicle keeps reached chapters only.
Fallback: no echo is invented. N07 may add one checkpoint variant after region 1, "Channel Nine has not answered since the flats", keyed on the source flag.
Ending / Chronicle: ledger_family_1..3 as authored; no gate consequence.
Replay fixture: child_radio resolved each of four ways, same region-1 order; expected difference: blue_van introduction and availability of choices 0 and 3.
```

### 2. Tower Six — Dena's Quiet Column

```text
Source: outskirts_siren / 0 (climb, Wits risky) success → lr_siren_silenced + scrap_parts 2; failure → lr_siren_burned, −10 HP, Shaken. / 1 (outwalk, Grit favorable) success → lr_siren_endured, fatigue 6; failure → lr_siren_followed, fatigue 12, Shaken.
Known: silenced — the survivor pulled the cutoff and carries the charge pack. burned — thrown from the ladder while it screamed. endured/followed — walked away while the tower called every listener.
Cost / reward: as authored. silenced_siren is an orphan → retire.
Durable: the four lr_siren_* flags.
Consumers: lr_quiet_column (1) → lr_bellkeepers_son (2) → lr_siren_in_glass (4).
Changes there: Dena reads the rotor. Proposed: (a) quiet_column introduction variants — silenced: the burn matches a pulled cutoff and she says so; burned: she asks who was on the ladder; endured/followed: she asks why nobody climbed. (b) new choice 3 "Hand over the charge pack" requires lr_siren_silenced, costs scrap_parts 1, certain → lr_column_sheltered: the column powers the service shelter with what the survivor took from the tower. (c) siren_in_glass choice 1 gets an introduction variant for lr_siren_silenced: Perrin asks whether they will silence this one too.
Timing: quiet_column region 1 priority 7, due on any source flag.
Failure / refusal / missed / death: doubts continues; "Refuse the tower's burden" ends the obligation but keeps eligibility (Dena wary). Missed → late variant. Death → Chronicle.
Fallback: none; the column is never asserted in scenes that did not meet it.
Ending / Chronicle: ledger_column_1..3; flare gun and rebar spear stand.
Replay fixture: four source resolutions; expected difference: quiet_column introduction and choice 3.
```

### 3. The pharmacy — Lio's Road Debt

```text
Source: outskirts_bandits / 0 combat: victory → lr_bandit_leader_killed (canned_meat, scrap_parts); critical victory → lr_bandit_leader_disarmed (pipe_pistol, pistol_rounds 4). / 1 (alley, Agility favorable) success → lr_bandits_escaped, fatigue 4; failure → lr_bandits_wounded_escape, −12 HP. / 2 (plague bluff, Presence risky) success → lr_bandits_bluffed; failure → lr_bandits_paid.
Known: killed — the leader died by the survivor's hand. disarmed — the leader lived and lost a pistol. escaped/wounded — nobody died. bluffed/paid — the gang believed a lie or was paid.
Cost / reward: as authored. Flee from combat writes no flag: a survivor who fled is not eligible for the witness, which is intended — Lio has no account of them.
Durable: the six lr_bandit* flags.
Consumers: lr_pharmacy_witness (1) → lr_bandit_ledger (3) → lr_last_toll (5).
Changes there: today Lio "moves one bottle from the dead to the uncertain" even when the survivor killed the leader (P0 false history). Proposed: (a) pharmacy_witness choice 0 success variants — killed: Lio moves the bottle to the dead and asks how; disarmed: to the living; escaped/bluffed/paid: to the uncertain. (b) new choice 3 "Return the leader's pistol" requires lr_bandit_leader_disarmed, costs pipe_pistol 1, certain → lr_lio_believes + lr_ledger_clue: both witness lines at once, for a weapon. (c) last_toll choice 1 gets an introduction variant when lr_ledger_verified: the survivor has already handled Lio's cache marks.
Timing: pharmacy_witness region 1 priority 7, due on any source flag.
Failure / refusal / missed / death: accuses/misread continue; "Refuse to be judged" continues wary. Missed → late variant. Death → Chronicle.
Fallback: none; Lio never appears outside his chapters.
Ending / Chronicle: ledger_debt_1..3; nail bat and rifle stand.
Replay fixture: victory, critical victory, escape; expected difference: choice 0 success text and choice 3.
```

### 4. The filter — Iven's Water Commons

```text
Source: marsh_filter / 0 (restart, Wits risky) success → lr_filter_repaired + clean_water 3; failure → lr_filter_poisoned, radiation 10, −5 HP. / 1 (strip, Strength favorable) success → lr_filter_stripped + scrap_parts 3, filter_mask; failure → lr_filter_broken, −9 HP.
Known: repaired — pressure flows east. poisoned — a coupling parted; the line is closed. stripped — the survivor carries the pump's gears and the mask; the mount is empty. broken — blood on a component; nothing recovered.
Cost / reward: as authored. restarted_filter is an orphan → retire.
Durable: the four lr_filter_* flags.
Consumers: lr_cup_passed_east (3) → lr_thirst_court (4) → lr_valve_below (5). Plan §4's example applies.
Changes there: Iven recognizes the part. Proposed: (a) cup_passed_east introduction variants — repaired: clear drops and Iven names the stage that was reset; stripped: an intermittent drip and the missing housing named; poisoned/broken: a closed line someone reopened badly. (b) new choice 3 "Fit the stripped housing back" requires lr_filter_stripped, costs scrap_parts 2, Wits favorable; success → lr_water_shared + clean_water 1; failure → lr_water_line_damaged (choice 1's failure). The survivor returns what they took. (c) valve_below introduction variant for lr_filter_repaired AND lr_underrail_water_reserved: the dry valve is the first thing the reservation ever reached. No mechanical change there.
Timing: cup_passed_east region 3 priority 7, due on any source flag.
Failure / refusal / missed / death: claimed/damaged/taken continue; "Take water and leave" keeps eligibility. Missed → late variant. Death → Chronicle.
Fallback: none; this thread puts water in no unrelated scene.
Ending / Chronicle: ledger_water_1..3; tire armor and scavenger rig stand.
Replay fixture: repaired vs stripped; expected difference: cup_passed_east introduction, choice 3, and the scrap_parts cost.
```

### 5. The fire — Noma's Nightfire Caravan

```text
Source: flats_nightfire / 0 (share, Presence favorable) success → lr_nightfire_shared + ration_bar 2, fatigue −12; failure → lr_nightfire_robbed, canned_meat −1, fatigue −5. / 1 (pass, Agility easy) success → lr_nightfire_passed; failure → lr_nightfire_spooked, fatigue 5, Shaken.
Known: shared — Noma walked east beside the survivor for miles. robbed — a can is missing and the embers were left. passed — the bedroll was seen and declined. spooked — both fled a misunderstanding.
Cost / reward: as authored. flats_nightfire is repeatable (unique=false, supply_opportunity): a source flag may be written more than once; consumers read presence only and never count.
Durable: the four lr_nightfire_* flags.
Consumers: lr_embers_in_rain (2) → lr_names_on_smoke (3) → lr_warm_windows (5).
Changes there: Noma "remembers exactly where you stood." Proposed: (a) embers introduction variants per source. (b) new choice 3 "Ask about the missing can" requires lr_nightfire_robbed, certain → canned_meat 1 + lr_caravan_debt_owed: Noma returns it and says why she took it; the debt reverses direction. (c) warm_windows introduction variant for lr_nightfire_passed: Noma notes the survivor once declined a fire and is now deciding one.
Timing: embers region 2 priority 7, due on any source flag.
Failure / refusal / missed / death: delayed/worse continue; "Decline the empty bedroll" continues at distance. Missed → late variant. Death → Chronicle.
Fallback: none.
Ending / Chronicle: ledger_fire_1..3; hatchet and baton stand.
Replay fixture: shared vs robbed; expected difference: embers introduction, choice 3, and the returned can.
```

### 6. Mara's treatment

```text
Source: bunker41_cartographer / 0 share a ration → b41_mara_helped, b41_green_invite (P0: costs nothing today; proposed costs canned_meat 1, locked with reason "You have no food to share" when the survivor has none). / 1 take her map → b41_mara_abandoned, b41_ash_invite, b41_choir_alerted. / 2 withdraw → b41_mercy_refused, b41_ash_invite.
Known: helped — Mara ate and gave the green-platform route; the survivor has her map. abandoned — the survivor took it at knifepoint. refused — the survivor declined the debt; no map.
Cost / reward: 0 proposed canned_meat 1 for the map and green_invite; 1 free now, paid later; 2 nothing.
Durable: the three flags (existing).
Consumers: bunker41_green_platform eligibility (mara_helped); rustsea_green_line eligibility, which actually reads FOUR flags — requires_any_flags [b41_mara_helped, b41_mara_abandoned, b41_recording, b41_contact] — so it admits survivors who never met Mara at all (corrected from "helped/abandoned" by N02 batch F; this is exactly why that scene can name her to a stranger, its own P0); rustsea_cartographers_debt (reads the history in prose); bunker41_door_closes 2 (mara_helped is testimony, STORY_CANON §8).
Changes there: today cartographers_debt says Mara "knows whether you fed her" and plays identically. Proposed: (a) introduction variants — helped: she has kept the survivor's name; abandoned: the rail speaker's "thief" was hers and she says so; refused or never met: neutral opening (STORY_CANON §5). (b) new choice 3 "Return what you took" requires b41_mara_abandoned, certain → rustsea_mara_allied + rustsea_spire_route: restoring the alliance costs only the admission. (c) ash_procession introduction variant for b41_choir_alerted naming the thief broadcast.
Timing: green_line region 5 priority 11; cartographers_debt chained.
Failure / refusal / missed / death: refusal ends Mara's thread coherently (no map, no green platform through her; other routes remain). Missed cannot occur: chained.
Fallback: none.
Ending / Chronicle: mara_helped feeds Witness; ledger_b41_mara, ledger_rustsea_debt.
Replay fixture: helped vs abandoned; expected difference: cartographers_debt introduction, choice 3, canned_meat −1 at the cartographer.
```

### 7. Key possession

```text
Source: bunker41_last_evacuation / 0 → b41_mercy_key, b41_green_invite.
Known: the survivor holds a SOTERIA authorization core (STORY_CANON §6). Holding is distinct from knowing.
Cost / reward: none to take; the monitor names the refused.
Durable: b41_mercy_key (possession, existing). Transfers are the existing b41_key_surrendered (chapel_car 0) and rustsea_key_with_mara (cartographers_debt 2).
Consumers: green_platform eligibility; chapel_car 0; cartographers_debt 2; warden_remembers 2; door_closes 1.
Changes there (P0: the Key could be given away and still offered at the gate). **Corrected during N04, because this record over-applied the forbid.** `door_closes` 1 is entirely about the Key, so it gains `requires.forbids_flags [b41_key_surrendered, rustsea_key_with_mara]` with the label "You do not hold the Key", which is true both of a survivor who never took it and of one who gave it away; the original "You no longer hold the Key" was false for the first. `warden_remembers` 2 does **not** take the forbid: it accepts five kinds of evidence and the Key is only one, so forbidding on a transfer locked a survivor still carrying testimony out of a legitimate route and labelled it with a Key they may never have held. Its passage instead gains an outcome variant for the transferred case, so a survivor whose Key is in Mara's hands answers with what they still carry. Residual, recorded: a survivor whose only evidence was the Key can still invoke it after transferring, because a flag cannot be cleared; closing that needs a per-flag clearing contract that does not exist. The other gates stand: chapel_car 0 forbids rustsea_key_with_mara and cartographers_debt 2 forbids b41_key_surrendered, so it cannot be given twice. green_platform's "the Mercy Key warms if you carry it" gets a variant after transfer.
Timing: possession from region 4 to the gate.
Failure / refusal / missed / death: broadcasting or destroying instead of taking is a full path; Mercy is honestly unavailable.
Fallback: a survivor who gave the Key away keeps Witness or Silence.
Ending / Chronicle: Mercy requires possession; ledger_b41_key records that the Key was seen.
Replay fixture: take → give to Mara → gate; expected difference: door_closes 1 locked, reason shown.
```

### 8. Records and testimony

```text
Source: b41_witness ← ash_procession 1, chapel_car 1, chapel_car 2, false_welcome 0, ledger_living 0, ledger_living 1, voice_map 2. b41_abandoned_names ← last_evacuation 1. b41_choir_records ← chapel_car 1. b41_rescued_survivors ← ledger_living 0. b41_choir_bound ← chapel_car 0.
Known: each producer names what the survivor now carries: a spoken truth, copied testimony, an archive order, released people.
Cost / reward: ledger_living 0 "spends precious time" — proposed costs.pressures fatigue 8 (the applier supports it; N04 adds loader validation). Others as authored.
Durable: the flags above.
Consumers: warden_remembers 2 (any of key / witness / abandoned_names / choir_records / rescued_survivors); door_closes 2 (witness / abandoned_names / mara_helped / rescued_survivors); door_closes 3 (today choir_joined / records / split / bound).
Changes there (STORY_CANON §8): door_closes 3 requires any [b41_choir_records, b41_choir_bound] only; joined and split are removed. warden_remembers 2 and door_closes 2 gain success variants naming the evidence used: rescued people present, a copied ledger, a broadcast.
Timing: region 5 producers, region 6 consumers.
Failure / refusal / missed / death: burning records (b41_records_destroyed, b41_ledger_burned) stays a real loss; nothing rewards it and nothing punishes it beyond absence.
Fallback: Silence is always available.
Ending / Chronicle: Witness and Ash; ledger_b41_warden, ledger_ending_witness.
Replay fixture: chapel_car 0 vs 1 vs ash_procession 1 alone; expected difference: door_closes 3 availability.
```

### 9. Kilnback rhythm

```text
Source: industrial_tank / 1 (listen, Wits favorable) success → proposed kilnback_rhythm_known + clean_water 2 (existing reward). / 2 APPENDED clear the cooling jacket, combat: victory → kilnback_rhythm_known + the water; per CREATURE_STORY_BIBLE.
Known: the knocks follow heat and pressure; a burner can be timed to them.
Cost / reward: 1 as authored; 2 a heavy fight (threat high; XP set with the adversary in N05).
Durable: kilnback_rhythm_known. rescued_engineer (choice 0) is an orphan → batch C gives it a rail_survivors variant line or retires it.
Consumers: lr_warm_windows.
Changes there: new choice 3 "Tune the heater to the Kilnback's cycle" requires kilnback_rhythm_known, hidden_when_locked, certain → lr_caravan_two_fires + lr_caravan_thread_complete + stun_baton (choice 1's success reward without the check). Earned expertise: allowed to dominate choice 1.
Timing: industrial_tank region 3 unique; warm_windows region 5.
Failure / refusal / missed / death: choice 0 or leaving writes nothing; warm_windows plays as today.
Fallback: none needed; the water was the immediate reward.
Ending / Chronicle: none.
Replay fixture: tank 1 success then warm_windows; expected difference: choice 3 available.
```

### 10. Cinder Giant rescue

```text
Source: glass_shadow / 0 (search, Wits risky) success → proposed cinder_traveler_rescued + scout_leathers, clean_water 1 (existing reward, now what the rescued traveler gives); failure as authored.
Known: a traveler survived the Giant's passage because the survivor walked them clear.
Cost / reward: the wits gamble against radiation, as today.
Durable: cinder_traveler_rescued.
Consumers: rail_survivors.
Changes there: introduction variant (the traveler sits at the council); new choice 2 "Let the traveler speak for you" requires cinder_traveler_rescued, hidden_when_locked, certain → medkit 1 + Inspired (choice 0's success reward; earned).
Timing: glass_shadow region 4, rail_survivors region 5; both unique.
Failure / refusal / missed / death: leaving writes nothing; rail_survivors plays as today.
Fallback: the rescue was its own reward.
Ending / Chronicle: none.
Replay fixture: shadow success then survivors; expected difference: choice 2 available.
```

### 11. Reed Widow pool

```text
Source: marsh_lights / 2 APPENDED clear the nesting pool, combat: victory → proposed widow_pool_cleared + the cache (purifier_ampoule, clean_water 2; choice 0's success reward).
Known: the drainage cut is empty.
Cost / reward: a creature fight in water; flee risky.
Durable: widow_pool_cleared.
Consumers: lr_voice_in_reeds.
Changes there: new choice 3 "Cross the cleared cut" requires widow_pool_cleared, hidden_when_locked (both scenes are region 2 and may occur in either order; a locked hint would be a false promise), certain → lr_family_reunited + climbing_rope (choice 0's success reward; earned).
Timing: region 2 both; order-independent by hiding.
Failure / refusal / missed / death: reeds before lights changes nothing and no prose implies the Widow was met.
Fallback: none.
Ending / Chronicle: ledger_family_2 only.
Replay fixture: lights-then-reeds and reeds-then-lights; expected difference: choice 3 present only in the first.
```

### 12. Cable Eater run

```text
Source: rail_signal / 2 APPENDED clear the cable run, combat: victory → proposed cable_run_cleared + scrap_parts (N05 sets the quantity). / 0 success → citadel_signal (orphan today).
Known: the powered run is dead; the door's challenge display no longer shifts with the load.
Cost / reward: a fight in a wet tunnel; flee risky.
Durable: cable_run_cleared. citadel_signal → batch D retires it or folds it into the same consumer as a weaker variant.
Consumers: rail_door, then final_gate_1.
Changes there: rail_door gains choice 2 "Read the code from the steady display" requires cable_run_cleared, hidden_when_locked, certain → gate_code. Today rail_door writes gate_code and access_core, both orphans, and final_gate_1 choice 0 "Answer with the recovered gate code" is available to everyone (P0 false history). Proposed: final_gate_1 choice 0 requires any [gate_code, access_core], reason "You recovered no gate code"; final_gate_1's introduction gets a variant for a survivor without either.
Timing: rail_signal and rail_door region 5 unique, order random: the door's choice 2 hides unless the run is cleared; signal after door writes a flag nobody reads, which is honest.
Failure / refusal / missed / death: cutting power (choice 1) is a full path; the door's display keeps shifting and choices 0/1 play as today.
Fallback: Silence at the gate; final_gate_1 choice 1 (intelligence) stays ungated.
Ending / Chronicle: none.
Replay fixture: signal cleared → door → gate; expected difference: door choice 2 and gate choice 0 availability.
```

## 5b. N06 design decisions

Three decisions were left open by earlier packages and are settled here, before N06's content was written, so the writers implement rather than guess.

**1. The dead finale is re-routed, not retired.** `final_gate_2` (the Warden screening: blind it, fight it, slip its arc) and `final_gate_3` ("One Person Through": force the gate, complete the override, order the guard) hold the game's only `victory: true` outcomes in `data/events.json` and the Chronicle's `ledger_ending_citadel`, and nothing routes to them because every `final_gate_1` outcome chains to `bunker41_warden_remembers`. Batch D recommended re-routing them as the path for a survivor with no Bunker history, and that is what ships: **a survivor who never touched Bunker Forty-One gets the standard screening and a survival ending; a survivor with `b41_contact` gets the Bunker finale and its four moral endings.** Mechanism: `final_gate_1`'s five outcomes default their `next_event` to `final_gate_2`, and each carries an outcome variant keyed on `b41_contact` whose `next_event` is `bunker41_warden_remembers` — a small extension (a variant may carry `next_event`) that reuses the existing pure, pre-outcome, first-match resolution and adds no run state. `b41_contact` is the threshold because it means *entered or marked the bunker* (STORY_CANON §5); a survivor who only heard the salt-flats voice (`b41_voice_heard`) gets the standard screening with a recognition line, since they carry nothing the Warden's record could concern. This also makes `warden_machine` fightable in a second scene and `citadel_guard` a threat in prose at both gates, and it makes `ledger_ending_citadel` reachable for N07's denominator.

**2. Focus stays with the first chapter that resolves.** N04 recorded that only three of five threads can hold focus in a run that resolved an Outskirts source, because three threads open in region 1. The alternative — focus follows the most recent engagement, or the most chapters resolved — was weighed and rejected: under competition a region-1 thread's reserved chapters always resolve before a region-2 or region-3 thread can accumulate more, so the alternative changes nothing in practice while adding a rule players cannot see; and it would let a thread the player engaged first be silently dropped, which is the exact failure the reservation exists to prevent. The plan asks that all five arcs be provable across different histories, not that all five be focusable in one, and all five complete 1.000 in isolation. N06 therefore leaves the rule alone and instead makes each thread's local resolution satisfying where it lands.

**3. Deferred consumers are delivered as conditional passages, and the thread-complete flags are decided by their writer.** `pilgrim_disk` (batch C) is read by a `bunker41_door_closes` choice 2 success variant; every orphan batches E and F named gets the consumer they proposed, in the scene they proposed, or is retired as they proposed. The five `*_thread_complete` flags remain orphans because the scheduler derives focus from `event_history` and never reads them; the Living Road writer either names a consumer a Chronicle variant cannot already supply, or retires all five.

## 6. Dispositions

Every event in the expanded configuration, from the batch cards. **112 events: 37 keep, 72 revise, 3 redesign.** The verdict is the card's; the reason is quoted from it. Batch letters index `consequence_map/`.

| Event | Batch | Verdict | Why |
|---|---|---|---|
| `outskirts_bandits` | A | **keep** | three distinct intentions and six histories that all feed §5 record 3 |
| `outskirts_bus` | A | **revise** | the body must signal which opening yields food and which yields medicine (plan §6) |
| `outskirts_dogs` | A | **keep** | fight, declared food price, and climb are three intentions with no dominance |
| `outskirts_market` | A | **keep** | four choices at the maximum, M05 equipment routes allowlisted and distinct |
| `outskirts_overpass` | A | **revise** | the introduction promises a find in the channel that neither branch delivers |
| `outskirts_apartment` | A | **revise** | append creature choice 2 per CREATURE_STORY_BIBLE; choices 0 and 1 unchanged |
| `outskirts_siren` | A | **revise** | retire the orphan silenced_siren per §5 record 2; everything else stands |
| `outskirts_cache` | A | **keep** | force, technical, and certain routes pay different things and each kit wins its own |
| `outskirts_child_radio` | A | **revise** | retire the orphan helped_family per §5 record 1; everything else stands |
| `outskirts_sinkhole` | A | **revise** | give the leap the time it saves so the rope route is preparation, not a better button |
| `global_trader` | A | **revise** | declare the salvage price in requires and costs so it is previewed and actually paid |
| `global_acid_rain` | A | **keep** | a weather scene honestly all cost, split by stat and failure severity |
| `global_pack` | A | **keep** | strong evidence, a trapped reward against an untouched exit |
| `global_stranger` | A | **revise** | append the ungated choice 2 required by STORY_CANON §10 and plan §6 |
| `global_map` | A | **keep** | take knowledge or leave knowledge, both rewards real under §3 |
| `global_quiet` | A | **keep** | rest against salvage, priced honestly in both directions |
| `global_grave` | A | **keep** | a certain moral reward against an uncertain material one |
| `global_drop` | A | **keep** | speed against concealment, and the only baseline source of climbing_rope |
| `global_bike` | A | **revise** | the cargo contradicts its own manifest and is inert for three kits |
| `global_crows` | A | **revise** | the fight pays nothing in a scene that shows the flock carrying salvage |
| `global_clear` | A | **keep** | the dominance flag is the false positive §3 documents; the shaken cure is a real reward |
| `global_snare` | A | **keep** | distinct intentions, legible residue, each kit's stat wins its route |
| `fallback_dust` | A | **keep** | region-neutral empty-pool filler with honest pricing and no stock closer |
| `flats_toll` | B | **revise** | victory pays unusable ammunition and the negotiated toll can be narrated without being charged |
| `flats_mirage` | B | **revise** | prose only: name the Salt Colossus, make choice 0 its bearing and choice 1 its wake, and never remember an earlier sighting |
| `flats_tanker` | B | **keep** | force against procedure, distinct rewards, failures that match their routes |
| `flats_dustwall` | B | **keep** | same odds band, genuinely different costs and conditions |
| `flats_bones` | B | **revise** | read_bone_warning takes the consumer proposed here and the wake needs naming |
| `flats_convoy` | B | **revise** | choice 3 claims knowledge of the toll barricade the survivor may never have seen |
| `flats_solar` | B | **keep** | rest against parts, priced against a concussion |
| `flats_crater` | B | **revise** | takes the crater_warning consumer as an introduction variant |
| `flats_signal` | B | **revise** | decoded_numbers is retired |
| `flats_nightfire` | B | **revise** | repeat visits need flag precedence and the theft can charge nothing |
| `marsh_leeches` | B | **keep** | sighting-only per STORY_CANON §4; the kit inversion is the scene |
| `marsh_ferryman` | B | **revise** | takes the marsh_map consumer and needs an empty-bottle variant |
| `marsh_raiders` | B | **revise** | the smoke bomb cannot be obtained before this region |
| `marsh_clinic` | B | **keep** | two medicine routes with matching failures |
| `marsh_bridge` | B | **revise** | the unspent rope makes choice 0 decoration once acquired |
| `marsh_lights` | B | **revise** | append the Reed Widow fight per §5 record 11 and put its warnings on screen |
| `marsh_hut` | B | **keep** | guest against intruder, with rewards and failures that follow the approach |
| `marsh_filter` | B | **revise** | per §5 record 4, plus the compatibility note on retiring restarted_filter |
| `marsh_body` | B | **revise** | the two equipment routes need opening evidence and marsh_map needs its consumer |
| `marsh_storm` | B | **keep** | honest exposure trade with no free success |
| `industrial_drones` | C | **revise** | evade route pays nothing on a repeatable scene while risking a permanent condition; stays sighting-only, no combat added |
| `industrial_generator` | C | **keep** | repair against theft, priced per kit and honestly paid |
| `industrial_scavs` | C | **revise** | choice 0's failure is item-loss only and can resolve empty |
| `industrial_conveyor` | C | **keep** | the harder route's premium is the game's highest-rated armor |
| `industrial_office` | C | **revise** | appended choices 2-3 have no evidence in the introduction and 0 and 2 solve the same puzzle |
| `industrial_fire` | C | **revise** | the promised preserved dock pays one scrap for the scene's worst failure |
| `industrial_tank` | C | **revise** | append choice 2 per §5 record 9 and the creature bible; retire rescued_engineer |
| `industrial_crane` | C | **revise** | the unpaid dash carries the scene's only injury risk |
| `industrial_locker` | C | **revise** | appended choices 2-3 have no evidence and borrow choice 0's action |
| `industrial_alarm` | C | **keep** | honest hazard crossing with differently priced failures and a hard route for Wits |
| `glass_cult` | C | **revise** | the hardest check in the batch is also the least rewarded |
| `glass_storm` | C | **revise** | the Grit route is worse on both branches at equal odds |
| `glass_bunker` | C | **revise** | the title claims Bunker Forty-One and the success borrows the Citadel gate's image |
| `glass_shadow` | C | **revise** | implement §5 record 10's rescue and put the Cinder Giant's evidence on screen |
| `glass_meteor` | C | **keep** | clean greed-against-discipline pair with a genuinely safe safe route |
| `glass_pilgrim` | C | **revise** | the disk the scene is built on is never delivered anywhere |
| `glass_antenna` | C | **revise** | underrail_bearing is written and never read |
| `glass_carcass` | C | **keep** | two honestly priced salvage routes split between builds |
| `glass_spring` | C | **keep** | restraint pays more relief than greed, and both doses read correctly |
| `glass_ruins` | C | **keep** | repeatable travel hazard with two genuinely different failures |
| `rail_hunters` | D | **revise** | choice 2's ammunition price is neither charged nor gated and its success pays nothing |
| `rail_train` | D | **revise** | good scene, but met_train_family has no reader |
| `rail_flood` | D | **revise** | the hard route pays exactly what the safer route pays |
| `rail_survivors` | D | **revise** | append record 10's choice 2, give fixed_platform_pump a reader, carry the record 9 and met_train_family variants |
| `rail_switch` | D | **revise** | the hard ungated route pays less than the favorable gated one |
| `rail_nest` | D | **keep** | two clean intentions and the game's only Ash Stalker fight, honestly priced |
| `rail_platform` | D | **keep** | distinct methods and distinct rewards at symmetric risk |
| `rail_collapse` | D | **revise** | the hard route with the far worse failure pays no premium |
| `rail_signal` | D | **revise** | append record 12's choice 2, write the bible's three warnings, fold citadel_signal into rail_door |
| `rail_door` | D | **revise** | append record 12's choice 2 and add the citadel_signal introduction variant |
| `final_gate_1` | D | **revise** | gate choice 0 on recovered evidence and write the two introduction variants |
| `final_gate_2` | D | **redesign** | unreachable compatibility content; re-route as the Bunker-less survivor's path rather than retire |
| `final_gate_3` | D | **redesign** | unreachable, and [0,2] are field-identical; differentiate by requirement |
| `bunker41_static` | E | **revise** | orphan b41_answered needs the Warden variant its own outcome promises |
| `bunker41_rusted_hatch` | E | **keep** | three distinct entries, every flag consumed, refusal still reaches the Choir |
| `bunker41_cartographer` | E | **revise** | §5 record 6 cost and lock, and b41_mercy_refused retired |
| `bunker41_door_breathes` | E | **keep** | the lethal route carries all three warnings and the Hush Sovereign stays a mystery |
| `bunker41_last_evacuation` | E | **revise** | eligibility must forbid b41_relay_fragment and the burn flag needs a reader |
| `bunker41_fragment_calls` | E | **revise** | scheduled behind the doors it opens; one orphan consumed, one retired |
| `bunker41_ash_procession` | E | **revise** | the robbery must yield something and both Choir flags need gate variants |
| `bunker41_green_platform` | E | **revise** | the announced Citadel response must arrive as the Warden's record |
| `bunker41_chapel_car` | E | **revise** | the Key transfer must require holding the Key |
| `bunker41_false_welcome` | E | **revise** | b41_archive_truth and b41_mercy need the named variants |
| `bunker41_ledger_living` | E | **revise** | §5 record 8's fatigue 8 for the "precious time" the prose already spends |
| `bunker41_warden_remembers` | E | **revise** | recognition variants, the unfired weapon, and a victory flag for the only Warden fight |
| `bunker41_door_closes` | E | **revise** | records 7 and 8 requirements plus the variant sets that read nine late flags |
| `rustsea_green_line` | F | **revise** | introduction names Mara to survivors who never met her; choice 2's mark needs a reader |
| `rustsea_quay_names` | F | **revise** | choice 2's protective motive must be established before commitment |
| `rustsea_false_coordinates` | F | **keep** | lethal route carries its three warnings and the survivable branches fork the chain |
| `rustsea_station_arrivals` | F | **revise** | burning the maps writes a flag nobody reads |
| `rustsea_salt_crown_wake` | F | **revise** | "Take supplies and leave" must become an honest uncertain search |
| `rustsea_cartographers_debt` | F | **revise** | record 7's possession fix, record 6's variants, and a missing next_event |
| `rustsea_voice_map` | F | **revise** | an unpaid promise, a receiver absent from the introduction, and a missing next_event |
| `rustsea_last_coordinate` | F | **redesign** | the three intentions stay but each outcome must resolve locally and turn east |
| `lr_blue_van` | F | **keep** | three distinct intentions; record 1 owns the variants and choice 3 |
| `lr_voice_in_reeds` | F | **revise** | the opening assumes a radio the silenced branch destroyed |
| `lr_last_battery` | F | **revise** | same silenced-set contradiction plus an unread thread-complete flag |
| `lr_quiet_column` | F | **keep** | distinct intentions and a real favorable-check reward |
| `lr_bellkeepers_son` | F | **revise** | the hardest option pays nothing and the unresolved ending is contradicted later |
| `lr_siren_in_glass` | F | **revise** | the flare is missing from the introduction; thread-complete flag unread |
| `lr_pharmacy_witness` | F | **revise** | certain refusal dominates because no choice in the scene moves an item |
| `lr_bandit_ledger` | F | **revise** | the hard social success has neither goods nor a later distinction |
| `lr_last_toll` | F | **keep** | strong rewards on both checks; only the thread-complete flag needs a consumer |
| `lr_cup_passed_east` | F | **revise** | the certain option matches the hard check's reward |
| `lr_thirst_court` | F | **revise** | the hard check returns less water than the easier one |
| `lr_valve_below` | F | **keep** | equipment rewards on both checks; thread-complete flag needs a consumer |
| `lr_embers_in_rain` | F | **keep** | three reward shapes including rest for distance; record 5 owns the variants |
| `lr_names_on_smoke` | F | **revise** | unsignalled food cost and a desperate check that moves nothing |
| `lr_warm_windows` | F | **revise** | the success names a person the survivor may have surrendered |

## 7. Findings by priority

### Cross-cutting engine findings

These are not one event's problem. They were found while carding and they change how every card's costs must be read; N04 owns the repairs.

**X1 (P0). A negative item entry is a false cost whenever the survivor lacks the item.** `GameEngine._change_item` (game_engine.gd:1409-1416) erases the entry when the new quantity is at or below zero, so removing two rounds from a survivor holding none removes nothing. `_apply_outcome` (:1328-1331) then appends the change line unconditionally, so the result panel reports a loss that did not happen. **25 outcomes across the four content files carry a negative item entry**, so every one is a potential false cost. Repairs, in order of preference: move the price to `costs.items`, which `_choice_availability` already gates on, so the choice locks honestly when the survivor cannot pay; or, where the loss must stay in the outcome, have `_apply_outcome` report what was actually removed. Cards state which they need.

**X2 (P0). No loaded flag means "heard the duty voice".** See STORY_CANON §5, corrected. `b41_voice_heard` must be added to all three `bunker41_static` outcomes before any recognition variant can read it.

**X3 (documentation, not a defect). An authored `pressures` number is not what the player feels.** `_apply_legacy_pressure` (game_engine.gd:1347-1357) scales health by `roundi(delta * 2.5 / 5.0) * 5`, so an authored `health: -12` costs **30 HP**, then armor mitigates it when the outcome sets `damage_type: "physical"`. A positive `hunger` of any size removes **exactly one** satiety, so `hunger: 6` and `hunger: 3` are identical; only a negative value scales, at one satiety per 10 points. Every card in §7 quotes the authored JSON, which is correct for the allowlist but must be multiplied before anyone reasons about difficulty. Fatigue and radiation pass through unscaled. N04 records this in `CONTENT_AUTHORING.md` so authors stop reading `-12` as twelve hearts.

**X5 (corrected during N03). Cards name the portrait id where they mean the adversary id.** Batch B and C cards say `enemy_widow` / `enemy_kilnback` "is not defined in `data/adversaries.json`". No adversary id in that file is `enemy_`-prefixed: the ids are unprefixed and `portrait_id` carries the prefix. The creatures shipped as `reed_widow` and `kilnback`; content references those.

**X4 (P1). `marsh_raiders` choice 2 cannot be taken in its own region.** It requires a `smoke_bomb`, whose only authored source is `rail_hunters` choice 0 victory in region 5, while `marsh_raiders` is region 2. Every survivor meets that choice locked unless they carry a starting bomb. Repair: give `smoke_bomb` one pre-marsh source in an existing reward, or retire the choice. This spans batches, so it belongs here rather than in B's card.

### Reconciliation across batches

Each batch saw only its own events, so its claims were checked centrally before being accepted.

- **Orphan coverage: complete.** `builds/flag_index.md` lists 49 flags that are written and never read. **All 49 are addressed by a card** — none was missed, and no card called a flag orphaned that the index shows consumed. Two look like disagreements and are not: `b41_choir_split` is consumed today by `bunker41_door_closes` choice 3, but §5 record 8 removes it from that requirement, so batch E correctly records it as *newly orphaned by the record* and gives it a new consumer; `lr_filter_repaired` is consumed by `lr_cup_passed_east` eligibility and was never claimed orphaned.
- **Cross-batch consumers proposed**, each needing the owning batch to accept it: `pilgrim_disk` (batch C) → `bunker41_door_closes` success variant (batch E); `fixed_platform_pump` (batch D) → `lr_valve_below` variant (batch F); `citadel_signal` (batch D) → `rail_door` introduction variant (batch D itself); `met_train_family` (batch D) → `rail_survivors` variant (batch D).
- **One bible suggestion was correctly refused.** `CREATURE_STORY_BIBLE` offered `rail_survivors` as the consumer for `rescued_engineer`; the loaded outcome sends the engineer *west* while `rail_survivors` is region 5, east, so seating them there would be false history under STORY_CANON §5. Batch C retired the flag instead and the bible now records the resolution.
- **The comparison tool's states have a blind spot.** All six states start carrying `cloth_bandage` and `clean_water`, so `global_stranger`'s blocked state — the P0 that N00 and M11 both found — never appears in `builds/choice_comparison.md`, which reports `gated_by: []` for both its choices. The same applies to `outskirts_dogs` choice 1. The tool is right about what it measured; the states do not model a depleted pack. N08 should add a seventh state with the consumables spent.

### By event

**151 findings: 30 P0, 102 P1, 19 P2.** Each line is the owning card's; "→" separates the problem from the required change.

#### P0 — false costs and rewards, false history, blocked actions, lost returns (30)

| Event | Ch | Batch | Problem → required change |
|---|---|---|---|
| `global_stranger` | — | A | both choices carry requires.items, so a survivor with no cloth_bandage and no clean_water has every button locked and no legal action (game_engine.gd:1217-1242, main.gd:788-797) → append ungated choice 2 "Press the wound with your own coat", Grit risky (medical), success pressures {fatigue 4} + add_conditions [inspired], failure pressures {fatigue 4} + add_conditions [shaken], no items and no flags |
| `global_trader` | 0 | A | the scrap price sits inside both outcome branches, so it is never previewed and silently no-ops for a survivor with no scrap while the result line still prints "Scrap Parts -1" → add requires.items {scrap_parts 1} and costs.items {scrap_parts 1}; success items {canned_meat 1, cloth_bandage 1}; failure items {ration_bar 1} |
| `flats_toll` | 1 | B | success and failure narrate food and water handed over that _change_item clamps to zero → conditional outcome variant for a survivor who cannot pay; fields unchanged |
| `flats_convoy` | 3 | B | success asserts detailed knowledge of the toll barricade that many runs never acquire (STORY_CANON §5) → variant keyed on crater_warning with a neutral default, or rewrite the traded warning; M05 fields unchanged |
| `glass_pilgrim` | 0 | C | the introduction promises the disk will be carried to the Citadel and pilgrim_disk has no consumer anywhere → add a conditional success variant on bunker41_door_closes choice 2 (per §5 record 8) reading the scratched name among the refused, with no change to Witness availability; fallback is to retire the flag and make the ask local |
| `rail_hunters` | 2 | D | ammunition price sits in the outcome as items {pistol_rounds: -2}, so a survivor with none pays nothing while the passage says the payment was collected → move it to costs.items {pistol_rounds: 2} and drop the item line from both branches |
| `final_gate_1` | 0 | D | introduction and choice assert a recovered gate code to every survivor → §5 record 12's requires.any_flags [gate_code, access_core], reason "You recovered no gate code", plus the codeless introduction variant |
| `final_gate_1` | — | D | the chained bunker41_warden_remembers claims recognition of the salt-flats voice, but STORY_CANON §5 keys it to b41_contact, which is written by bunker41_rusted_hatch and bunker41_door_breathes rather than by bunker41_static → add flag b41_voice_heard on all three bunker41_static outcomes, consumed by the warden_remembers and final_gate_1 introduction variants |
| `final_gate_2` | — | D | nothing routes here, so three choices and the whole final_gate_3 chain are unreachable while still loading → N06 re-routes (recommended) or retires; N07 fixes the denominator |
| `final_gate_3` | 1 | D | success claims the survivor rebuilt the sequence "from every relay lesson gathered below" with no evidence they read one → requires.any_flags [gate_code, access_core, citadel_signal], reason "You never read a Citadel controller" |
| `final_gate_3` | — | D | unreachable finale still defined and counted, including ledger_ending_citadel → as final_gate_2 |
| `bunker41_cartographer` | 0 | E | sharing a ration spends no food → §5 record 6: costs.items canned_meat 1, requires.reason "You have no food to share"; choices 1 and 2 stay ungated |
| `bunker41_last_evacuation` | — | E | eligibility requires_flags [b41_forced_entry] with no window and weight 1, so the command room can be dealt after the survivor fled with the relay → add eligibility.forbids_flags [b41_relay_fragment] |
| `bunker41_green_platform` | 2 | E | prose promises that whatever comes next will know where the survivor stood, but b41_public_signal has no consumer → warden_remembers introduction variant, entry 1 |
| `bunker41_chapel_car` | 0 | E | no requires block, so a survivor who never took the Key can surrender it and write b41_choir_bound, which record 8 makes an Ash key → add requires.flags [b41_mercy_key] with record 7's forbids_flags [rustsea_key_with_mara], reason "You do not hold the Key" |
| `bunker41_ledger_living` | 0 | E | "you spend precious time" charges nothing → §5 record 8: costs.pressures fatigue 8 |
| `bunker41_warden_remembers` | — | E | the introduction claims recognition of the duty voice for every survivor → introduction variants, default without recognition; key recognition on any [b41_recording, b41_answered, b41_quiet_path, b41_forced_entry], because b41_contact is written even by "Mark it and leave" |
| `bunker41_warden_remembers` | 0 | E | the refusal ends with the weapon raised and chains straight to the door → rewrite the closing sentences so the weapon stays tracked and unfired; index 1 already carries the fight |
| `bunker41_door_closes` | 1 | E | Mercy offered after the Key was transferred → §5 record 7: forbids_flags [b41_key_surrendered, rustsea_key_with_mara], reason "You no longer hold the Key" |
| `bunker41_door_closes` | 3 | E | Ash unlocked by affiliation without the record → §5 record 8: requires.any_flags [b41_choir_records, b41_choir_bound] only |
| `rustsea_green_line` | — | F | body names "Mara Venn's voice" to b41_recording / b41_contact survivors who never met her (STORY_CANON §5) → introduction variants: recognition for b41_mara_helped / b41_mara_abandoned, otherwise the message signs off with a name the survivor cannot place |
| `rustsea_quay_names` | 2 | F | protective motive appears only after selection (plan §6) → replace the body's closing sentence with charcoal copying onto banner cloth and a drying lantern-and-three-strokes mark |
| `rustsea_salt_crown_wake` | 1 | F | "Take supplies and leave" is certain and grants no items (plan §6) → agility risky (salvage): success items {canned_meat: 1, clean_water: 1}; failure pressures {fatigue: 6}; both keep add_flags [rustsea_caravan_taken, rustsea_mara_route] and next_event rustsea_cartographers_debt |
| `rustsea_cartographers_debt` | 2 | F | Key transfer leaves b41_mercy_key set so Mercy is still offered at the gate (plan §6, STORY_CANON §6) → implement §5 record 7 exactly |
| `rustsea_voice_map` | 1 | F | "A later signal will carry the names you chose not to hear" has no destination and rustsea_voices_silenced is read nowhere → bunker41_warden_remembers introduction variant on the flag (cross-batch E), or cut the promise sentence |
| `rustsea_last_coordinate` | 0,1 | F | outcomes read as entering a Spire that has no chapter (STORY_CANON §10, §5 mystery) → rewrite both as local resolutions that turn east, with choice 2 as the model; fields unchanged |
| `lr_voice_in_reeds` | — | F | introduction opens on Channel Nine transmitting although lr_family_silenced destroyed the set → record 1's van-state variant must cover the silenced case concretely |
| `lr_last_battery` | — | F | "Their final battery is feeding the transmitter" assumes a working set after lr_family_silenced → extend the same variant contract to region 3 |
| `lr_names_on_smoke` | 1 | F | failure removes the survivor's canned_meat with no signal before commitment, attributes it to the caravan, and prints "Canned Meat -1" even at zero → name the crew's price in the introduction and attribute the loss to the guarantor's pack |
| `lr_warm_windows` | 1 | F | success names the teenage mechanic although lr_caravan_mechanic_surrendered is in this event's eligibility → success variant for that flag |

#### P1 — weak openings, weak rewards, orphan flags, dominant or redundant choices (102)

| Event | Ch | Batch | Problem → required change |
|---|---|---|---|
| `outskirts_bandits` | — | A | unique=false lets one run write two contradicting lr_bandit* flags and §5 record 3 states no variant precedence → N04 fixes first-match order killed > disarmed > wounded_escape > paid > bluffed > escaped |
| `outskirts_bandits` | 2 | A | failure's canned_meat -1 no-ops when the survivor holds no can while text and result line assert the payment → N04 suppresses the result line for a no-op item delta |
| `outskirts_bus` | — | A | the introduction ties neither opening method to its reward, so the food/medicine split is invisible at commitment (plan §6) → the body names the ration shapes seen through the wiped circle and the first-aid bracket beside the release cable; mechanics unchanged |
| `outskirts_overpass` | 1 | A | "whatever has collected" promises a find and both branches are pure fatigue and hunger → cut the promise from the body, or now success pressures {fatigue 7, hunger 4} / proposed success pressures {fatigue 7, hunger 4} + items {scrap_parts 1} |
| `outskirts_market` | 0 | A | failure's scrap_parts -1 no-ops for a survivor with no scrap while the text asserts the payment → N04 suppresses the result line for a no-op item delta |
| `outskirts_market` | 1 | A | failure's scrap_parts -1 has the same defect → same repair |
| `outskirts_siren` | 0 | A | silenced_siren is written and never read (orphan) → retire it per §5 record 2; lr_siren_silenced carries the thread |
| `outskirts_child_radio` | 0 | A | helped_family is written and never read (orphan) → retire it per §5 record 1; lr_channel_helped carries the thread |
| `outskirts_sinkhole` | 0 | A | the rope route equals or beats the leap in every measured cell (70/45, 70/70, 90/50, 65/45 healthy; 55/35 depleted), pays items where the leap pays nothing, and fails for fatigue 6 against 15 HP and a sprain → now success (no fields) / proposed success pressures {fatigue -4} |
| `global_trader` | — | A | trader_token is granted once (global_stranger 0 success) and by the Presence kit and is required or read by no event, eligibility, or ledger entry in any data file → record it as equipment-only (social +2 / presence +1) with no expected reader, or give it one in the batch that owns a market or toll scene |
| `global_bike` | 0 | A | failure's scrap_parts -1 no-ops for a survivor with no scrap → same repair as outskirts_market |
| `global_bike` | 1 | A | success pays pistol_rounds 3 from a box whose manifest lists only medical deliveries, and the rounds are inert for three of four kits → now success items {pistol_rounds 3, ration_bar 1} / proposed success items {cloth_bandage 2, ration_bar 1}, or name the courier's sidearm in the body |
| `global_crows` | 1 | A | victory grants no items although the introduction shows a crow wearing bandage cloth and crows own "collecting what shines" → now victory (no items) / proposed victory items {cloth_bandage 1, scrap_parts 1}; drop "No useful loot remains" from the victory text |
| `global_snare` | 1 | A | failure's clean_water -1 no-ops for a survivor carrying none → same repair as outskirts_market |
| `flats_toll` | 0 | B | threat-13 victory pays revolver_rounds 3 (usable only by the unmeasured Presence kit's holdout_revolver) plus scrap_parts 1 → now: revolver_rounds 3, scrap_parts 1 / proposed: revolver_rounds 3, scrap_parts 1, canned_meat 1 |
| `flats_toll` | 1 | B | crater_warning orphan → consumer: flats_crater introduction variant, or retire |
| `flats_mirage` | — | B | no durable effect; the bible permits a flag → keep local, because a flag on a repeatable scene cannot distinguish sightings |
| `flats_bones` | 0 | B | read_bone_warning orphan → consumer: flats_mirage introduction variant keyed on requires_any_flags [read_bone_warning]; retiring it would leave choice 0 with no reward |
| `flats_convoy` | 2 | B | the sun awning appears only in the label and success text → add it to the body |
| `flats_crater` | — | B | consumes flats_toll's crater_warning as an introduction variant; the default text must stand when the flag is absent |
| `flats_signal` | 0 | B | decoded_numbers orphan and not the SOTERIA signal (that is global bunker41_static) → retire; choice 0 keeps medkit 1 and rifle_rounds 3 as its premium |
| `flats_nightfire` | — | B | repeat visits can write two contradictory lr_nightfire_* flags → N04 fixes precedence (shared > robbed > passed > spooked) in §5 record 5 |
| `flats_nightfire` | 0 | B | failure narrates a stolen can, clamped to nothing when the survivor has none → conditional outcome variant; the flag still writes |
| `marsh_ferryman` | 0 | B | no way to offer the account the marsh gave → success variant keyed on marsh_map naming Lysa Dorn; mechanics unchanged |
| `marsh_ferryman` | 1 | B | failure narrates a lost bottle, clamped to nothing when dry → conditional outcome line |
| `marsh_raiders` | 2 | B | smoke_bomb exists only from rail_hunters [0] victory in region 5, so this choice is unreachable in region 2 → give smoke_bomb one pre-marsh source in an existing reward, or retire the choice |
| `marsh_raiders` | 1 | B | failure narrates medicine taken, clamped to nothing when absent → conditional outcome line |
| `marsh_bridge` | 1 | B | the rope is required but never consumed, so after acquisition this choice equals or beats choice 0 in every measured cell with a milder failure → now: requires climbing_rope 1, no costs / proposed: add costs.items climbing_rope 1 (the failure text already leaves the rope on the bridge), or record the dominance in the allowlist as a deliberate equipment payoff |
| `marsh_lights` | 2 | B | the appended fight has no on-screen evidence: the raft that reads as firm ground and the laced boot are missing → add both to the body |
| `marsh_filter` | 0 | B | restarted_filter orphan → retire per §5 record 4, paired with the expanded configuration becoming the default, or the compatibility build loses this scene's only mark |
| `marsh_body` | 2 | B | the ground-down rebar has no opening evidence → one clause in the body; M05 fields unchanged |
| `marsh_body` | 3 | B | the tire plates have no opening evidence → one clause in the body; M05 fields unchanged |
| `marsh_body` | 0 | B | marsh_map orphan → consumer: marsh_ferryman [0] success variant, or retire |
| `industrial_drones` | 1 | C | success writes no field while its failure matches choice 0's severity → add add_conditions ["steady_hands"] to choice 1 success |
| `industrial_scavs` | 0 | C | failure is items {medkit: -1, rad_tabs: -1} only and resolves empty for a survivor carrying neither → add pressures {fatigue: 8} to the failure |
| `industrial_office` | — | C | the introduction never shows the gun cabinet or the emergency kit, so appended choices 2 and 3 have no opening evidence → add one clause each to the body (67 words today) |
| `industrial_fire` | 0 | C | the intro promises a preserved dock and success pays items {scrap_parts: 1} for the scene's worst failure → proposed items {scrap_parts: 1, purifier_ampoule: 1} |
| `industrial_tank` | 0 | C | orphan flag rescued_engineer with no consumer, and the engineer leaves westward so rail_survivors would be false history → retire the flag, keep the rescue in the passage |
| `industrial_tank` | 2 | C | choice 1 already reaches both of the appended fight's rewards at 55-90 healthy → N05 must set enemy_kilnback's xp_reward high enough to pay for the death risk (adversary not yet defined in data/adversaries.json) |
| `industrial_crane` | 0 | C | success writes no field while risking health -18 and permanent concussed against choice 1's fatigue 8 → add add_conditions ["steady_hands"] to choice 0 success |
| `industrial_locker` | — | C | the introduction shows only the unmarked locker, so appended choices 2 and 3 have no evidence and narrate choice 0's action → name the security cabinet and the bolted rig in the body (74 words today) and let each passage open its own object |
| `glass_cult` | 0 | C | 35 healthy / 25 depleted, the hardest check in the batch, pays rad_tabs 2 while the fight pays 62 XP and two consumables → proposed items {rad_tabs: 2, glow_moss: 1}, difficulty unchanged |
| `glass_storm` | 1 | C | choice 1 pays nothing on success and adds no condition on failure while choice 0 costs fatigue 8 and adds bleeding, at tied odds → add pressures {fatigue: 4} to choice 1 success, the wait its own passage describes |
| `glass_bunker` | — | C | the title asserts Bunker 41, which STORY_CANON §6 and bunker41_rusted_hatch (same region, writes b41_contact) show inhabited and warm, while the body deliberately leaves the number buried → retitle and leave the number unread |
| `glass_shadow` | 0 | C | the Cinder Giant never appears in the introduction, so record 10's rescue has no visible hazard and the bible's warning sequence is unmet → add the fresh pale dust and the travelling shadow with nothing above it (74 words today) |
| `glass_antenna` | 0 | C | orphan flag underrail_bearing with no consumer; the fatigue -4 already pays for the knowledge → retire it, or batch D names one region-5 consumer |
| `rail_hunters` | 2 | D | success grants nothing while the comparison flags [1] strictly dominant → add pressures {fatigue: -5} to the success; keep the choice for its Presence expertise |
| `rail_train` | 0 | D | met_train_family is an orphan → consume it as a rail_survivors introduction variant recognizing the junction marks, or retire it |
| `rail_flood` | 0 | D | agility hard [1] risks health -22 / fatigue 15 / concussed for the same empty success strength risky [0] buys → add pressures {fatigue: 6} to [0] success; no item reward, the event is repeatable |
| `rail_survivors` | 1 | D | fixed_platform_pump is an orphan → consume it as an lr_valve_below introduction variant (batch F, N04) |
| `rail_survivors` | — | D | failure branches assert ration_bar -1 and scrap_parts -2 the survivor may not hold, and the result panel prints the loss anyway → clamp the reported change to what was removed and add a variant for an empty pack |
| `rail_switch` | 1 | D | wits hard [1] with the worse failure has an empty success while wits favorable [0] pays fatigue -5 → add pressures {fatigue: -8} to [1] success |
| `rail_collapse` | 1 | D | strength hard [0] risks health -20 / fatigue 12 / concussed for the same empty success wits risky [1] buys → add pressures {fatigue: 6} to [1] success for the long crawl |
| `rail_signal` | 0 | D | citadel_signal is an orphan → fold it into a rail_door introduction variant; do not retire |
| `rail_signal` | 2 | D | the appended combat choice names enemy_cable_eater, which data/adversaries.json does not define and the loader rejects → N05 authors the profile (threat mid-high, HP between Widow and Kilnback, Charge/Strike/Sweep/Brace/Recover, critical burned, flee risky) |
| `rail_door` | — | D | gate_code and access_core are orphans in loaded content → consumed by final_gate_1 choice 0 under §5 record 12 |
| `rail_door` | 0 | D | failure removes scrap_parts 1 the survivor may not hold and still reports it → same clamp and variant as rail_survivors |
| `final_gate_1` | 1 | D | with choice 0 gated, a codeless survivor faces one desperate Presence check at 10-25% and near-certain health -22 / shaken before the Warden → N05 reviews difficulty desperate against hard; legacy_v2_checks pins final_gate_1:1 at 17 |
| `final_gate_1` | — | D | the finale is 79 introduction words and 35-word outcomes and acknowledges nothing the survivor did → N04's scene-role budget contract first, then the rewrite toward plan §3's 180-280 / 150-260 |
| `final_gate_3` | 2 | D | [0] and [2] are field-identical and a victory ending leaves no post-success field to differentiate → requires.any_flags [warden_broken], a new flag written by final_gate_2 choice 1 victory and read only here; [0] stays ungated |
| `bunker41_static` | 1 | E | orphan b41_answered → warden_remembers introduction variant, and add the flag to rustsea_green_line eligibility beside b41_recording (batch F coordination) |
| `bunker41_cartographer` | 2 | E | orphan b41_mercy_refused, and record 6 keys the neutral opening on absence → retire the flag |
| `bunker41_last_evacuation` | 1 | E | b41_choir_alerted has two opposite producers (Mara's theft, the names broadcast) → key record 6's ash_procession variant on b41_mara_abandoned and give b41_abandoned_names its own variant |
| `bunker41_last_evacuation` | 2 | E | orphan b41_records_destroyed → warden_remembers introduction variant, entry 2, shared with b41_ledger_burned |
| `bunker41_fragment_calls` | — | E | priority 8 schedules it after green_platform (10) and ash_procession (9) in region 5, so its invites arrive after their consumers are spent → N04: schedule it before green_platform, or reserve its slot under map §5 |
| `bunker41_fragment_calls` | 0 | E | orphan b41_fragment_followed → door_closes choice 0 outcome variant, entry 1 |
| `bunker41_fragment_calls` | 2 | E | orphan b41_fragment_discarded, with nothing left that can read a destroyed fragment → retire |
| `bunker41_ash_procession` | 2 | E | the theft guarantees "nothing worth the theft" → now: no items / proposed: canned_meat 1, with the outcome naming rations and lantern oil |
| `bunker41_ash_procession` | 2 | E | orphan b41_choir_hostile (also fragment_calls 1) → door_closes introduction variant, entry 3 |
| `bunker41_ash_procession` | 1 | E | b41_choir_split loses its only consumer under record 8 → door_closes introduction variant, entry 4 |
| `bunker41_false_welcome` | 0 | E | orphan b41_archive_truth → add as a key to record 8's evidence-naming variants at warden_remembers 2 and door_closes 2 |
| `bunker41_false_welcome` | 1 | E | orphan b41_mercy (also false_welcome 2 and ledger_living 2) → door_closes choice 0 outcome variant, entry 2 |
| `bunker41_ledger_living` | 2 | E | orphan b41_ledger_burned → warden_remembers introduction variant, entry 2 |
| `bunker41_warden_remembers` | 1 | E | the only reachable warden_machine fight writes nothing and reads identically to the refusal → add victory add_flags [b41_warden_destroyed], consumed by the door_closes introduction variant |
| `bunker41_warden_remembers` | 2 | E | orphan b41_warden_heard → door_closes introduction variant, entry 2 |
| `bunker41_door_closes` | — | E | the introduction names the sleeping bunker and the Ash Choir for survivors who met neither → default introduction variant naming only what this survivor passed |
| `bunker41_door_closes` | 3 | E | b41_choir_records and b41_choir_bound are different acts → one outcome variant each, or the prose gives the bound survivor a record they never took |
| `rustsea_green_line` | 2 | F | orphan rustsea_map_self_marked and a drowned-tower mark with no destination → rustsea_quay_names eligibility becomes requires_any_flags [rustsea_green_line, rustsea_map_self_marked] |
| `rustsea_quay_names` | 1 | F | orphans rustsea_names_copied, rustsea_children_clue → rustsea_voice_map introduction variant (children_clue) and choice 2 success variant (names_copied) |
| `rustsea_quay_names` | 2 | F | orphan rustsea_ash_marks_damaged → bunker41_ash_procession introduction variant (cross-batch E) |
| `rustsea_station_arrivals` | 2 | F | orphan rustsea_maps_burned → rustsea_cartographers_debt introduction variant about the smoke that came east |
| `rustsea_salt_crown_wake` | 1 | F | orphan rustsea_caravan_taken → retire; routing is carried by rustsea_mara_route |
| `rustsea_cartographers_debt` | 2 | F | no next_event while siblings chain, so the promised Spire chapter depends on a weight-1 draw → add next_event rustsea_last_coordinate |
| `rustsea_cartographers_debt` | 0,1 | F | orphans rustsea_mara_allied, rustsea_mara_betrayed → rustsea_last_coordinate introduction variants |
| `rustsea_voice_map` | 1 | F | the receiver is not in the introduction, which establishes only a speaking map → name it in the body or silence the map itself |
| `rustsea_voice_map` | 2 | F | writes rustsea_spire_route but no next_event while choice 0 chains → add next_event rustsea_last_coordinate |
| `rustsea_voice_map` | 0,2 | F | orphans rustsea_voice_trusted, rustsea_named_dead → rustsea_last_coordinate introduction variants |
| `rustsea_last_coordinate` | 0,1,2 | F | orphans rustsea_mapped_entry, rustsea_late_entry, rustsea_route_shared, rustsea_spire_reached → ledger_rustsea_spire gains three variants; spire_reached goes to the §5 scheduling termination test or retires |
| `lr_last_battery` | — | F | orphan lr_family_thread_complete → §5 scheduling termination test, or retire |
| `lr_bellkeepers_son` | 0 | F | hardest option pays no item while the easier evade pays ration_bar 2 → success gains items {bitter_tonic: 1} alongside pressures {fatigue: 8} |
| `lr_bellkeepers_son` | 2 | F | lr_dena_stayed leaves Dena and Perrin unresolved and the next chapter puts both on screen → lr_siren_in_glass introduction variant for lr_dena_stayed citing the two bells |
| `lr_siren_in_glass` | 0 | F | Dena's flare exists only in the outcome → name the flare gun in the introduction |
| `lr_siren_in_glass` | — | F | orphan lr_column_thread_complete → §5 scheduling termination test, or retire |
| `lr_pharmacy_witness` | 2 | F | strictly dominant certain refusal in a scene where no choice moves an item → [0] success gains items {painkillers: 1}; refusal's cost stays later, as an lr_bandit_ledger introduction variant for lr_lio_refused |
| `lr_bandit_ledger` | 0 | F | hard Presence success has no item and no later distinction while lr_ledger_verified already has one → lr_last_toll introduction variant for lr_ledger_shared |
| `lr_last_toll` | — | F | orphan lr_road_debt_complete → §5 scheduling termination test, or retire |
| `lr_cup_passed_east` | 2 | F | strictly dominant: certain clean_water 2 equals the hard check's success → [0] success becomes items {clean_water: 3}, [2] unchanged, and lr_thirst_court gains an introduction variant for lr_water_taken |
| `lr_thirst_court` | 0 | F | the hard Wits audit returns less water than the easier Strength option → [0] success becomes items {clean_water: 1, purifier_ampoule: 1} |
| `lr_valve_below` | — | F | orphan lr_water_thread_complete → §5 scheduling termination test, or retire |
| `lr_names_on_smoke` | 1 | F | desperate Presence success moves nothing → success gains items {ration_bar: 2} |
| `lr_warm_windows` | 1 | F | second heater and security baton appear only in the outcome → one introduction clause |
| `lr_warm_windows` | — | F | orphan lr_caravan_thread_complete → §5 scheduling termination test, or retire |

#### P2 — style and pacing (19)

| Event | Ch | Batch | Problem → required change |
|---|---|---|---|
| `outskirts_apartment` | 2 | A | the appended combat choice makes the event combat-carrying and changes region 0's forced-combat slot and two-per-region combat cap (game_engine.gd:1097-1130) → N05 re-checks region 0 pacing with three combat events in the pool |
| `global_drop` | — | A | "Fresh arrival means intact supplies and nearby claimants" states an inference flatly and implies an aerial resupply STORY_CANON §2 does not establish (§5 registers) → attribute the reading to the survivor; mechanics unchanged |
| `flats_mirage` | 1 | B | success describes the mirage but not the wake → rewrite around the parallel crust fractures |
| `flats_bones` | — | B | the darker crust inside the ring is never tied to what made it → name the wake |
| `marsh_leeches` | — | B | the full marsh_leeches adversary profile and the event-level adversary_id are unreachable (no combat choice anywhere) → keep sighting-only per STORY_CANON §4 and record the profile as deliberate reserve; loot arrays are never granted |
| `marsh_lights` | 2 | B | the Reed Widow is never named in any passage → name it in the body or in choice 2's prose |
| `industrial_drones` | — | C | event-level adversary_id drone_swarm is unreachable inert data with no combat choice → drop the field or record it as deliberate |
| `industrial_generator` | 1 | C | failure names the mechanic, "a sprain's bright warning" → describe the joint instead |
| `industrial_office` | 2 | C | choices 0 and 2 both solve by reading a date off the personnel board → give choice 2 its own evidence, not the worn dial industrial_locker already uses |
| `industrial_fire` | 1 | C | failure says "concussed and depleted", two status words in a row → show the symptoms |
| `glass_storm` | 0 | C | failure embeds irradiated glass dust in skin and lungs and adds radiation 0, less than the 3 the region charges to walk the leg → give the failure a small radiation value |
| `glass_bunker` | 0 | C | success reuses the Citadel gate's signature image, "releases a hand's width" (STORY_CANON §1, §8) → reword |
| `glass_meteor` | 0 | C | failure narrates "burns beneath your clothing" but applies no burned condition → add burned or stop naming burns |
| `glass_pilgrim` | 0 | C | the prayer disk is itemized as items {scrap_parts: 1}, so the interface reports the burden as salvage → name the scrap as the pilgrim's other kit, separately from the disk |
| `glass_carcass` | 0 | C | failure names the mechanic, "above your fresh sprain" → show the limb |
| `glass_ruins` | 1 | C | success claims "preserving precious strength" while adding pressures {fatigue: 3} → reword or drop the fatigue |
| `rail_nest` | — | D | the Ash Stalker is named only after victory, against the creature bible's rule that names arrive before or during the decision → name it in the introduction |
| `rail_signal` | — | D | the introduction carries none of the bible's three Cable Eater warnings, so choice 2 would be committed to blind → rewrite within the 60-90 word budget |
| `bunker41_door_breathes` | 1 | E | add_flags [b41_contact] is a no-op because every rusted_hatch outcome already writes it → drop the field; the chain is the durable |
