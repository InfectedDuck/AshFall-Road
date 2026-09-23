# Ashfall Road: Narrative Expansion and Consequence Plan

Updated 14 September 2026. **Planning document only: no content, release flag, or save format is changed by updating this file.** Keep the filename `NARRATIVE_REFINEMENT_PLAN.md` so existing links and handoffs continue to work.

This is the authoritative narrative work package for Claude Code and the owner's chosen coding workflow. It now covers a substantial story expansion: richer reading, compelling choices, satisfying rewards, recurring consequences, creatures, and endings. It supersedes earlier restrictions limiting the work to prose refinement, 97 active events, disabled Living Road callbacks, uniformly short passages, and no new enemies. Unrelated offline, permadeath, save-safety, and monetization boundaries remain.

## Resume here — preserve N00–N05

**N00–N05 are complete. Start with N06a below, then finish the remaining N06–N10 work.** The earlier package descriptions remain as reference contracts, not instructions to repeat their implementation. Retain the completed Channel Nine pilot, ordinary-scene revisions, and N05b Kilnback retune. Reopen a completed scene only for a specific continuity, consequence, or regression defect.

The 14 September review compared this plan with the queue, canon, consequence map, JSON, loader, scheduler, and relevant UI code. It was a document/code inspection, **not a fresh gameplay or regression run**. The queue's completion evidence remains historical. In particular, its “N06 next” handoff is behind some work already present:

| Inspected state | Remaining owner/action |
| --- | --- |
| `final_gate_1` already has conditional routes to the standard screening or Bunker finale; the loader supports outcome-variant routing. | N06a verifies the effective routes and existing tests; do not implement the extension again or keep calling these finales unreachable without current evidence. |
| Consequence map §5b already chooses first-resolved-chapter focus; `_focused_callback_thread()` follows that rule. | N06a retains the decision; N08 checks completion under competition. Do not reopen focus switching as a fresh design exercise. |
| `pilgrim_disk` already has a Witness passage consumer in `bunker41_door_closes`. | N06c checks availability, first-match masking, and a payoff for holders who take another ending or the standard gate route. A single conditional paragraph does not prove coverage. |
| `data/adversaries.json` has **15 definitions**: Reed Widow and Kilnback exist; Shutter Skitters and Cable Eater do not. Their host events still have two choices. | N06d explicitly owns the two remaining profiles/fights and connected consequences. Keep the original 17-adversary target; do not mark it delivered from the N04 heading alone. |
| Reading UI has already changed, including choice-row and accessibility work. | N07 checks the current presentation with real costs and long passages before making further changes. |
| `release/living_road_enabled=false` remains in `project.godot`. | N10 activates only after N08 evidence. N09 human acceptance remains separately recorded. |

**Priority for the remaining work:** truthful consequences and satisfying resolutions → character development and distinct choices → readable delivery → sentence polish. Added length is useful only when it improves one of those. Section 9 assigns agent roles and models to each remaining refinement; section 10 is the continuation prompt.

## 1. The experience to build

The player should want to keep reading to discover what happens to people they know, understand strange creatures, earn something worth the risk, and see earlier decisions return in a changed situation.

Build scenes around this progression:

**Something specific catches your attention → you understand competing needs → you commit to an approach → the outcome changes something → later play remembers what happened.**

Every selectable choice must have a distinct intention and meaningful immediate or delayed significance. That may be survival resources, equipment, usable information, a person's observable response, access, a relationship, or an ending. Two labels followed by equivalent outcomes and no distinct significance need redesign.

Not every small choice needs a multi-region quest. Use local consequences for ordinary decisions and durable callbacks for major commitments. Branches can converge while retaining relevant differences. Refusal can preserve resources and close an obligation; failed help can change the relationship and the next problem. Neither should automatically erase a story.

Preserve relief, discovery, useful expertise, humor in character, and uncomplicated kindness. **Success can feel good.** Do not undermine every reward with a final punishment or make every stranger a betrayer. Hard dilemmas matter more when the world contains things worth protecting.

Recommended central question: **What are you willing to carry into safety, and whom does your survival leave outside?** Develop this from existing Citadel, admission, testimony, and survival material without imposing a protagonist personality or universal morality score.

People enjoying the game for its reading and choices is the acceptance goal. Word count, model scores, and automated tests cannot guarantee affection; observe it through reader feedback.

## 2. Original baseline and expansion boundaries

The following table records the **8 September starting point**, before N00–N05. It is not the current roster, prose, or test count. Use the resume table above and the latest queue evidence for current work; retain the independent baseline for mechanical comparisons.

| Area | Inspected starting point | Planned destination |
| --- | --- | --- |
| Main configuration | 97 events: 76 baseline, 13 Bunker, 8 Rust-Sea | Integrate the existing 15 Living Road callbacks: 112 events initially |
| Choices / authored outcomes | 236 / 390 without callbacks; 281 / 465 with the existing pack | Review all expanded content and added creature/branch outcomes; record final counts |
| Adversary definitions | 13: 7 human factions, 4 animal/mutant types, 2 machines | Keep original IDs and add four combat creatures: 17 definitions |
| Discoveries | 10 without callbacks, 25 with callbacks | Activate and review the existing 25 definitions |
| Baseline prose | Both override files load; M03/M04 are recorded complete | Redesign decisions and scenes where needed; allow longer and conditional passages |
| Callback pack | 15 events, five three-chapter threads, 22 source-outcome patches; disabled | Make these playable, memorable, and reliably scheduled when followed |
| Test evidence | Queue records 2,444 regression assertions | Re-establish current results and deliberately revise changed content contracts |

These were inspected data/loader facts, not a new test run. Loaded does not mean reachable on a new run. Trace actual finale routing and compatibility-only content. The worktree contains substantial ongoing work; reuse `tools/full_run_harness.gd` and its existing evidence instead of restarting M11.

Implementation boundaries:

- The 112-event configuration is the first complete expansion target. Add further nodes only when the consequence map identifies a specific missing setup/payoff; prefer existing scenes and variants first. Record additions explicitly.
- **Living Road activation is now included.** Develop with `ContentRepository.new(true)` and make the expanded configuration the intended default after integration checks. Editing this plan leaves the actual flag unchanged.
- Retain the explicit 97-event configuration as a compatibility/test mode where needed. Do not silently apply new history, costs, or adversary identities to an already committed action.
- Preserve stable event IDs, choice indices and intentions, original adversary IDs, discovery IDs, offline play, strict permadeath, authoritative domain resolution, and save transactions.
- Keep combat rules, existing item definitions/acquisition routes, central XP, and checkpoint progression. Reward quantities, flags, requirements, routing, and scheduling can change when documented and tested for this expansion.
- Preserve first-event safety, regional supply guarantees, and the combat-opportunity cap. Extra prose and cosmetic echoes must not silently add food, fatigue, XP, or RNG ticks.
- No new shops, currency, skill trees, companion combat system, general dialogue framework, or monetization. Use existing equipment, consumables, conditions, and combat moves.
- No new portraits required. Creature names, behavior, descriptions, tells, and deliberate missing-image presentation must work now. Preserve approved human portrait prompts.
- Retain second-person present tense, concrete detail, distinct voices, and teen-rated tension.

Maintain a mechanical-change allowlist by event/choice/field and changed domain contract. Flags and eligibility are mechanics. Capture an independent before-change snapshot: comparing baseline JSON to its own override does not detect a change made to both.

## 3. Richer scenes and worthwhile rewards

### Passage depth

The current 60–90-word introductions and 30–50-word outcomes are a contract to revise, not the creative ceiling.

| Scene role | Suggested setup | Suggested outcome |
| --- | --- | --- |
| Quiet or compact encounter | 60–100 words | 30–65 words |
| Substantial ordinary encounter | 110–180 words | 60–110 words |
| Character chapter / major dilemma | 180–280 words | 100–180 words |
| Finale / major resolution | 180–280 words | 150–260 words |

These are writing targets, not padding quotas. Keep compact scenes that work. Implement a shared scene-role budget contract, including retained legacy passages, before loading longer text. Update `content_repository.gd`, any affected override handling, audits, tests, and authoring guidance together. Do not paste longer data into a validator that rejects it, or remove validation entirely.

A substantial setup establishes a specific place and disturbance, an actor with an understandable need, competing interests, and enough visible evidence to choose. Use short paragraphs, purposeful dialogue, physical action, and memorable objects. Each detail should illuminate place, character, danger, or the decision. Avoid lore lectures and stock ominous closers.

An outcome shows how the attempt unfolded, what changed, the reward/loss being handled, and the immediate aftermath. A later hook needs an implemented destination. Resolve the current moment before introducing another mystery.

Keep essential costs and warnings in the main passage. Optional inspection can deepen atmosphere but must not hide information needed for a fair commitment. Reading, skipping animation, or opening cosmetic detail consumes no travel, food, XP, or RNG.

### Success should be worth pursuing

Fulfill the chosen intention on success. A successful rescue saves the person; promised supplies become usable supplies. Do not narrate a cure, cache, route, ally, or admission benefit that never affects authoritative state or subsequent play.

Use several reward types:

- Useful food, medicine, ammunition, pressure relief, and supported treatment.
- Existing equipment and meaningful alternatives for different builds.
- Knowledge that unlocks a later option, identifies danger, or supports testimony.
- Help, shelter, passage, trust, or bargaining opportunities that actually become available.
- Seeing someone safe, answering an established mystery, or reaching a distinct resolution.

Hard checked successes need a clear premium over safer alternatives: materially better immediate value or a specific useful story opportunity. Audit odds, upfront costs, failure severity, reward utility, and delayed value together. Let high stats and equipment sometimes solve problems cleanly.

Specify exact item quantities, pressure changes, eligibility, and narrative state during design. “Good reward” is not an implementation specification. Exceptional story XP must not duplicate central journey/check/checkpoint/combat XP.

Do not shower every success with equipment or always make generosity the best-value choice. Avoid the reverse pattern of kindness always being punished. Give survival-minded and generous options credible benefits and costs that depend on circumstances.

Check rewards at full health, with already-owned equipment, and at carrying capacity. Explain actual gains through narration and UI; do not silently discard promised rewards. Show guaranteed costs and intended benefit types before selection without spoiling every future surprise.

## 4. Every major commitment returns

Maintain the existing `docs/NARRATIVE_CONSEQUENCE_MAP.md` and its linked event cards. For each choice, record its distinct immediate effect or local resolution. For each major commitment, additionally record:

```text
Source event / choice index / resolved outcome:
What the survivor and other characters actually know:
Upfront cost and immediate reward:
Durable run-state fact written:
Later event / conditional passage / available choice that reads it:
What changes there beyond mentioning the earlier scene:
Timing, eligibility, and scheduling priority:
Failed attempt / refusal / missed return / survivor-death behavior:
Fallback payoff if the main return cannot occur:
Ending or Chronicle consequence, where appropriate:
Replay fixture and expected state difference:
```

A flag without a consumer is not a callback. A changed greeting adds recognition, but major decisions also need changed opportunities, relationship behavior, resources, obstacles, routes, or resolutions.

Use three scales: immediate aftermath for every choice; later-in-this-run consequences for major commitments; and relevant endings/recorded accounts. The Chronicle preserves knowledge across runs, never an earlier survivor's allies, items, or advantages for the next survivor.

### Integrate the five existing threads

| Thread / source | Existing three return scenes | What the revised story should carry |
| --- | --- | --- |
| Vale family / `outskirts_child_radio` | `lr_blue_van` → `lr_voice_in_reeds` → `lr_last_battery` | Trust in directions; help, uncertainty, and distance; a concrete rescue or separation |
| Dena's Quiet Column / `outskirts_siren` | `lr_quiet_column` → `lr_bellkeepers_son` → `lr_siren_in_glass` | Warning-system consequences, responsibility for Perrin, and protection of the column |
| Lio's Road Debt / `outskirts_bandits` | `lr_pharmacy_witness` → `lr_bandit_ledger` → `lr_last_toll` | Witnesses to violence/deception, usable evidence, and a later judgment the player influences |
| Iven's Water Commons / `marsh_filter` | `lr_cup_passed_east` → `lr_thirst_court` → `lr_valve_below` | Repair, salvage, contamination, ownership, and who receives water downstream |
| Noma's Nightfire Caravan / `flats_nightfire` | `lr_embers_in_rain` → `lr_names_on_smoke` → `lr_warm_windows` | Hospitality and accepted/refused debt; whose warmth or safety it later secures |

Review all 22 source patches against current success, failure, combat, critical, and avoidance outcomes. Their old interpretations may not survive a rewrite unchanged.

The current one-callback-per-region rule permits at most five callback slots across regions 1–5. These three-chapter stories overlap those slots, and Bunker/Rust-Sea priorities compete. **Do not promise all five complete arcs in one run under those rules.**

Default scheduling design:

- Focus on one three-chapter Living Road story per run, with smaller echoes from other decisions in existing scenes, checkpoints, or endings.
- Keep the implemented rule: focus is derived from the first resolved callback in `event_history`; it does not need another saved field. Reserve an eligible ordinary slot for its due continuation ahead of unrelated openings, preserving combat/supply guarantees and valid Bunker/Rust-Sea progression.
- Failed help can continue the focused story. Deliberate refusal can resolve or end it coherently; normal progression must not require accepting the obligation.
- A promised return must not silently expire because random selection chose another scene. Where a return can actually become unavailable, name and test a reachable later scene/checkpoint fallback. Widened eligibility alone is not proof that a fallback runs. Non-focused threads may remain partial: distinguish a possible reunion from a guaranteed delivery, and settle concrete reward obligations without inventing an offscreen rescue.
- Death can leave stories unfinished. Missing a source must not create false memories. An NPC does not die just because their callback lost priority.
- Do not add travel slots by default. Any unavoidable change to hunger, fatigue, combat density, or XP requires separate documented validation.

Target: a survivor who follows an eligible thread and reaches its final region can experience a complete three-chapter story plus minor reminders from other choices. Prove all five arcs across different recorded histories and competing hooks, not one favorable seed.

Add durable consequences for Mara's treatment and Key possession, plus at least two creature decisions. Proposed connections: learning the Kilnback's heat rhythm helps with a later damaged heater; the traveler rescued from the Cinder Giant returns among `rail_survivors`. Name the actual consumer, supported reward, and fallback before writing those promises.

### Example: the filter choice comes back

At the filter station, show a useful filter mask and a pressure gauge feeding inhabited rooftops. Repair offers clean water and a continuing supply line; stripping the pump offers equipment now and reduces what can flow east. A failure leaves a specific broken component and limitation.

Later, Iven recognizes the working part, its absence, or the unsuccessful repair. Each history changes what he needs and what he can offer. In the Underrail, the earlier state changes solutions at the valve and who has water when the argument ends. Repair and salvage can both benefit the player, but their exclusive rewards cannot be obtained by reopening the scene.

This is a proposed design, not a claim that these exact effects already exist. Specify and test the real quantities and state changes during implementation.

## 5. Creatures participate in the story

Retain Feral Dogs, Marsh Leeches, Mutant Crows, and the Ash Stalker's distinct identities. Keep Drones and the Warden distinct from biological threats. Preserve all seven human-faction IDs and meaningful roles while reviewing repeated hostile-human draws.

Deepen Hush Sovereign and Salt Crown warnings and surrounding decisions without converting their lethal chambers into ordinary loot fights. Bellmother and Drowned Surveyor remain separate future-wave material.

Finalize these working concepts in `docs/CREATURE_STORY_BIBLE.md`:

| Creature / host | Identity and decision | Delivery |
| --- | --- | --- |
| **Shutter Skitters** / `outskirts_apartment` | Flat plated colonies move behind shutters and within walls. Search the occupied floor, respect its warning, or drive the colony away for an established supply opportunity. | Substantial named scene; optional pack combat |
| **Salt Colossus** / `flats_mirage` | An enormous low-bodied migrant fractures salt beneath its mineral ridges. Follow its shade/bearing or avoid its unstable wake; traces can appear in `flats_bones`. Distinct from Salt Crown. | Environmental giant; survival/navigation, no health bar |
| **Reed Widow** / `marsh_lights` | An amphibious predator carries reeds and luminous eggs. Apparent safe ground moves against the current. Learn its pattern, keep to the bank, or clear a nesting pool for a concrete purpose. | Substantial named scene; optional creature combat |
| **Kilnback** / `industrial_tank` | A massive heat-seeking mutant wedges insulating plates into cooling machinery. Its movement produces the knocks. Investigate, understand the pressure cycle, or clear the machinery. | Substantial scene; optional heavy combat; later knowledge payoff |
| **Cinder Giant** / `glass_shadow` | A towering vaguely humanoid irradiated being sheds pale dust. Its shadow precedes its body. Search for a traveler along its passage or withdraw from clearly described exposure. | Environmental giant; rescue/survival; later survivor payoff |
| **Cable Eater** / `rail_signal` | A segmented creature coils among powered cables. Falling insulation and changing lights reveal it. Follow the line, cut power with an established cost, or clear the cable run. | Substantial named scene; optional creature combat |

Each requires unmistakable presence, understandable behavior and risk, a real decision, and a worthwhile result. A name in a document or a rumor alone is incomplete.

Append four combat alternatives to suitable existing two-choice events, preserving original indices, intentions, and non-combat routes. Add separate adversary IDs for Skitters, Widow, Kilnback, and Cable Eater. Reuse Strike, Sweep, Brace, Heavy, Charge, and Recover with species-specific sequences and honest tells. Never relabel a saved human adversary as a creature.

Differentiate scale, movement, warning, habitat, and need. Not everything glows, mimics voices, is malicious, or used to be human. Any radiation, infection, armor, weak point, or electrical effect must match implemented mechanics.

Introduce names in the actual passage or combat display: event titles are not reliably shown. Combat profiles require stable `portrait_id` values, but missing images should use deliberate presentation without raw `PORTRAIT / ID` text. Giants need neither portrait IDs nor combat profiles. Generate no artwork.

Offer creature-led encounters in every region. Review a rough target of 50–65% creature-led selections among hostile ordinary events across representative runs, counting machines separately and actual combat separately from sightings. Treat this as an editorial target, not a per-seed guarantee or grounds to break pacing. Measure with callbacks enabled; human interaction is not automatically hostility.

## 6. Original defects and residual follow-through

This is the original repair inventory. N03–N05 already closed several entries; verify the changed paths and residual consumers under N06a, rather than reapplying the repairs. In particular, a fixed Key-only gate does not prove that every mixed-evidence choice handles transferred ownership correctly.

| Location | Inspected problem | Required repair |
| --- | --- | --- |
| `outskirts_bus` | Different opening methods give food versus medicine without clearly signaling that distinction. | Make intended benefits/opportunity costs legible while preserving supply value. |
| `bunker41_cartographer`, choice 0 | Sharing a ration costs no food. | Implement a supported explicit cost and legal alternative, or change the assistance honestly. |
| `rustsea_cartographers_debt`, choice 2 | Key transfer leaves the flag that unlocks offering it at the gate. | Distinguish historical knowledge from possession; check all consumers and old saves. |
| `bunker41_warden_remembers`, choice 0 | Refusal describes an imminent attack but advances directly to the door. | Implement a believable passage or intentional confrontation; do not add a mandatory fight just to justify a sentence. |
| `rustsea_salt_crown_wake`, choice 1 | “Take supplies and leave” grants no supplies. | Make it an honestly uncertain search or deliver the promised reward. |
| `rustsea_quay_names`, choice 2 | Defacing the wall gains a protective motive only after selection. | Establish the motive and risk before commitment. |
| Bunker/Rust-Sea/gate prose | Some entrance histories do not support claims of prior meetings/knowledge. | Use supported variants or neutral introductions. |
| `rustsea_last_coordinate` | Entry-like outcomes return to travel; the next Spire chapter is not playable. | Resolve the local chapter and explain return toward the Citadel before future hooks. |
| `global_stranger` and depleted states | Both inspected options require specific supplies. | Verify actual availability and preserve a legal action; reuse current audit work. |

The inspected outcome applier supports `add_flags`, not an implemented `remove_flags` contract. Do not invent fields and assume they work. Use supported state or a narrow tested extension.

## 7. Ordered implementation packages

**N00–N05 below are completed reference packages. N06–N10 are the remaining work.** Apply the resume status above when an older “create” or “implement” instruction describes something already present.

### N00 — Establish both configurations and the baseline

- Read the current queue, content authoring guide, narrative bible, Bunker/Rust-Sea guides, loader, and `SAVE_TRANSACTIONS.md`.
- Create `docs/NARRATIVE_REFINEMENT_QUEUE.md`; retain completed M-series history.
- Export readable effective-content dossiers for `ContentRepository.new(false)` and `.new(true)`: labels, costs, requirements, all outcomes, sources, and flag consumers.
- Record current tests, dirty worktree, save/configuration contracts, and independent mechanical snapshots. Reuse existing full-run tooling.
- Inventory the complete 112-event target, 25 discoveries, adversary availability, and compatibility-only nodes.

**Done when:** the next session can identify what actually loads and the next ready task without overwriting ongoing work.

### N01 — Establish story canon and creature identities

Depends on N00.

- Create concise `docs/STORY_CANON.md`: why people travel east, Citadel promises, regional progression, timeline, and observation versus belief/mystery.
- Give Mara, the five thread leads, Cinder Wives, Ash Choir, Warden, and Citadel distinct wants, knowledge, limits, bargaining positions, and voices.
- Define Key possession, records, testimony, rescued people, and Silence/Mercy/Witness/Ash ending meanings.
- Create the creature bible with the six proposals, primary scenes, warnings, rewards, and consequences.
- Add a scoped story/creature addendum to `ENEMY_DESIGN_BIBLE.md` during implementation, preserving approved casting and portrait instructions.

**Done when:** major actors and creatures have distinct roles and compatible histories.

### N02 — Design every choice, reward, and return

Depends on N01; inventory work can begin earlier.

- Create the consequence map and a design card for every target event. Add cards for any justified new nodes.
- Specify each indexed choice's intention, evidence, known cost, uncertain risk, exact success reward, failure aftermath, local significance, and durable effect.
- Compare healthy, hungry, injured, irradiated, supplied, and depleted survivors across builds. Identify redundant/dominant options while preserving useful expertise.
- Map critical fallback, combat victory/flee, refusal, delayed eligibility, and ending variants. Flee must not produce a victory-source flag.
- Distinguish major gameplay-changing callbacks, minor recognition, and local resolution. Give promises consumers and fallback policies.
- Prioritize P0 false costs/rewards/history, blocked actions, unfair commitments, and lost promised returns; P1 weak opening/reward/callback/finale; P2 style and pacing.

**Done when:** every event has a keep/revise/redesign disposition and concrete reward/state contracts.

### N03 — Deliver a complete sample arc and varied scenes

Depends on relevant N01–N02 work. Implement needed N04 support alongside it.

Pilot these ten scenes:

1. `outskirts_child_radio`.
2. `lr_blue_van`.
3. `lr_voice_in_reeds`.
4. `lr_last_battery`.
5. `outskirts_bus`.
6. `global_quiet`.
7. `bunker41_cartographer`.
8. `marsh_lights` with Reed Widow.
9. `industrial_tank` with Kilnback.
10. `glass_shadow` with Cinder Giant.

The first four prove a complete source-to-payoff story. Demonstrate two different histories, including an unsuccessful attempt. The other six prove practical rewards, relief, a real sacrifice, creature behavior/scale, and rescue.

Write introductions, choices, and every outcome together using the new budgets and supported variants. Do not claim completion for prose drafts alone. Keep the Warden repair a P0 task outside this reading sample.

**Done when:** ten playable scenes include a complete returning story, distinct later effects, useful rewards, and creatures without portraits. Provide an easy-to-skim review packet and continue independent work while feedback is pending.

### N04 — Implement richer text, memory, and reliable returns

Depends on N02; build incrementally with N03 and finish before bulk integration.

- Implement shared length budgets and any narrow conditional body/outcome support. Validate every variant, fallback, and precedence. Reopening a passage must not change its text or consume RNG.
- Reuse flags and add only run state needed for consumed commitments, ownership, knowledge, and focused-thread progress. Distinguish attempted help, actual rescue, trust, and transfer.
- Implement focused scheduling/fallback from section 4. Test competition with Bunker/Rust-Sea, guarantees, and region transitions.
- Reuse existing history, recap, and Chronicle. If needed, show unresolved commitments within existing UI rather than adding an unrelated quest system.
- Record source facts and rewards atomically through current transactions. Apply callbacks, discoveries, and terminal receipts once. UI narration owns no gameplay mutations.
- Define enrollment of old runs into expanded content. Use per-run content compatibility where required; never reconstruct unrecorded source outcomes from absent flags. Preserve prepared/pending actions and existing fights.
- Repair ration cost, Key transfer/access, depleted-action legality, and Warden passage. Add unsupported contracts only with consumers and tests.
- Add the four combat creatures/choices through existing rules, conditions, items, and XP. Use new IDs, update roster registries deliberately, and test missing-image display.

**Done when:** richer passages, durable consequences, reliable callbacks, creature fights, and core repairs work and survive interruption correctly.

### N05 — Expand ordinary scenes by region

Depends on pilot and required N04 support. Edit 5–8 complete scenes per batch.

Review all 73 ordinary records: ten per region, twelve globals, and fallback.

| Group | Emphasis |
| --- | --- |
| Outskirts | Inviting opening, recognizable lives, useful supplies, three early human-thread hooks, Shutter Skitters |
| Flats | Water, hospitality, exposed travel, Salt Colossus, and Nightfire setup |
| Marches | Water ownership, identification, rescue, Reed Widow and Leeches, consequences recognized downstream |
| Industrial | Repair/salvage, power and procedures, Kilnback, earned tools and equipment |
| Glass | Faith, evidence, radiation warnings, Cinder Giant, rescue, and approaching Bunker stakes |
| Underrail | Access, concealed communities, Cable Eater/Ash Stalker, and returns on earlier help/knowledge |
| Globals/fallback | Relief, small obligations, discoveries, repeat-safe context, depleted-inventory legality |

Preserve 2–4 choices unless a separately justified UI/content change is necessary. Do not add options reflexively. Put essential information in passages/labels, not titles. Preserve supply value and all fifty existing item acquisition routes.

Outcomes must match tools, resources, conditions, bodies, and history. Repeatable scenes must not replay a named first meeting as new. Recurring motifs are welcome; repeated filler is not. Keep strong completed pilot passages unless integration requires changes.

**Done when:** all ordinary scenes have distinct choices, worthwhile success, appropriate depth, and required sources/consumers.

### N06 — Expand returning stories and major arcs

Depends on completed N00–N05. **Some N06 work is present; verify and finish it.** Coverage is 39 records: 15 Living Road, 13 Bunker, 8 Rust-Sea, and 3 base finales. Give each a `keep / targeted revision / redesign` disposition and a separate verification status; this is not a quota to rewrite all 39. N06d also closes the two creature fights left outside that count, in existing ordinary events.

#### N06a — Reconcile the current implementation once

**Agent:** implementation integrator; Sonnet or GPT-5.6 Terra, medium effort where available. Escalate only a demonstrated routing/save defect.

- Read the latest queue handoff and consequence map §5b before older event cards. Check existing effective content and tests for conditional finale routing, first-chapter focus, and the pilgrim consumer. Record `present and verified / present but unverified / missing`, with event IDs and evidence.
- Retain the current split: `b41_contact` sends the survivor to the Bunker finale; otherwise use `final_gate_2` → `final_gate_3`. Hearing `b41_voice_heard` alone gives recognition, not invented Bunker experience. Verify prepared/pending legacy routes as well as new journeys.
- Retain first-resolved-chapter focus. Late water/fire threads must still complete across appropriate source histories; their existence does not promise that every run can follow them. Change the scheduler only if a reproducible case violates the chosen rule.
- Export only the relevant effective scene cards and current validation failures. Keep the original mechanical baseline intact and record deliberate changes against it. Do not regenerate the canon, all cards, or the original audit.
- Assign every residual to N06b/c/d or N07. In particular, keep the two missing fights visible even though N04 and N05 are complete.

**Deliverable:** a short delta checklist in the queue and the next unfinished story batch. Verification of work already present counts as progress.

#### N06b — Give each returning story a different emotional progression

**Agent:** narrative writer/integrator; Sonnet or GPT-5.6 Terra for each complete arc. Use one bounded Opus or GPT-5.6 Sol consultation when the arc's dilemma or resolution needs substantial redesign, then integrate with the main agent.

Use the existing source and three chapters as a unit. The first return should reveal a consequence, the second should complicate the relationship or force a new decision, and the last should settle the thread's central question. Avoid three repetitions of “pay supplies, roll, receive thanks.” These are editorial directions to realize through supported state, not claims that every proposed beat is already implemented:

| Thread | Story improvement to pursue | Payoff that must be visible |
| --- | --- | --- |
| Channel Nine / the Vales | Preserve the completed pilot. Check that Talia's trust distinguishes speaking to her, tracing a signal without contact, and giving bad directions. Let the family make decisions of their own. | A concrete reunion, changed arrangement, or honest separation; never a generic rescue paragraph for every history. Revise only a demonstrated gap. |
| Quiet Column / Dena and Perrin | Move from controlling warning signals to accepting another person's judgment. Perrin needs an understandable action or preference, not only a rescue objective. Let one chapter offer cooperation instead of another payment. | The final use of the warning system reflects earlier decisions and who accepts responsibility. Protection can succeed without a last-line punishment. |
| Road Debt / Lio | Build around evidence, grief, and the limits of judgment. Distinguish a truthful confession, corroboration, evasion, and refusal; do not reveal facts no witness could know. | The ledger or final toll changes whose account is accepted or what settlement is possible. Belief need not mean forgiveness, and a fair result can remain emotionally difficult. |
| Water Commons / Iven | Escalate from a broken pump to disagreement over access. Give people on both sides a practical need; avoid making one spokesperson explain the entire moral. | Repair, salvage, contamination, and failed repair change the workable solutions and who receives water. Preserve exclusive rewards and earned technical competence. |
| Nightfire / Noma | Test hospitality through an actual shortage and disagreement within the caravan. Make warmth, work, humor, and ordinary companionship part of what the player wants to preserve. | Show which shelter or arrangement survives. An accepted debt, a refused obligation, and useful Kilnback knowledge should produce distinct responses or opportunities. |

For each arc, write a compact card: **opening need → changed relationship → final decision → concrete resolution**, plus the affected flags, exact rewards, and fallback. Use one recurring object or habit whose meaning changes; avoid giving every character the same clipped, cryptic voice. Include action, disagreement, and moments without a check. Keep worthwhile expertise and kindness where they fit the character.

Review every authored outcome together with its choice, including failure, refusal, combat/flee, and conditional text. A failed roll may leave someone distrustful or require a different solution; it must not silently become successful help. A refusal may end an obligation clearly. Characters may disagree with the survivor without the narration assigning a universal moral verdict.

Verify at least a helpful history and a failed/refused/self-interested history for each arc, plus a no-source control for false memories. Record the **later option, behavior, resource, or resolution that differs**, not merely the flag or greeting. In deterministic comparisons, preserve the same seed and unrelated decisions where practical; record intended branch divergence.

**Deliverable:** all five arcs have verified dispositions and satisfying local endings across appropriate runs. A completed pilot is reviewed for continuity, not rewritten for novelty.

#### N06c — Make the major arcs and endings pay off the journey

**Agent:** same writer/integrator. Reserve Opus or GPT-5.6 Sol for one review of conflicting histories, finale requirements, and the most important ending passages; routine integration stays on Sonnet or Terra.

- **Bunker:** structure revelations around what the survivor must do with the evidence. Each major revelation should change the next decision. Keep recorded orders, a spoken account, rescued people, and possession of the Key distinct. Preserve mystery about the Cinder Wives rather than supplying an explanatory monologue.
- **Mara and Rust-Sea:** distinguish meeting Mara, treating her, refusing her, and receiving information without meeting her. Show her goals and limits through her actions. Resolve the lantern/quay/crossing chapter and the survivor's turn east before the Spire tease. Close the current promise before introducing the next one.
- **Key ownership:** exercise the Warden's mixed-evidence choice with (1) Key held, (2) transferred Key and no other evidence, (3) transferred Key plus valid testimony, and (4) no Key history. A transfer must remove permission to present the object without erasing a legitimate independent testimony route. Use supported gates or a narrowly tested contract, not a global ban on all evidence and not an invented `remove_flags` field.
- **Pilgrim and creature promises:** inspect the existing `pilgrim_disk` Witness variant for first-match masking by other evidence. Name a reachable payoff for a disk carrier who receives another ending or the standard screening. Carrying a disk does not itself grant Bunker history or Witness access. Check the real consumers/fallbacks for Kilnback knowledge and the Cinder Giant rescue; recognition alone cannot replace an already-promised useful opportunity.
- **Ending design:** preserve Silence, Mercy, Witness, Ash, and the standard survival route's distinct meanings. Each successful ending should show the immediate admission action, one concrete result for the survivor, and a bounded reflection of relevant road commitments. Use only outcomes the run establishes. Survival itself can be a satisfying achievement; do not scold a player for taking the available route.
- **Bound variants:** design a small priority table covering ending route, major evidence/ownership, and the followed thread's resolved or unresolved state. Do not author every flag combination. If first-match text would hide two important payoffs, move one to a guaranteed preceding scene or the existing factual recap/Chronicle, or justify a narrow deterministic composition change. A promise cannot disappear just because another variant matched first.
- **Death and uncertainty:** use the existing death recap to acknowledge a commitment where useful, without claiming its offscreen resolution. A living ending may honestly leave someone unlocated; an unexplained scheduling omission is not an authored bittersweet ending.
- Audit the nine original `lethal` records and any current changes to that count. Warnings must describe concrete escalating danger and permit withdrawal before the lethal commitment. Do not add instant death to strengthen a scene's tone.

**Deliverable:** a route/ending matrix with Bunker contact versus no contact; heard-voice-only; Key held/transferred; independent evidence present/absent; disk plus competing evidence; and followed-thread completed/unresolved. Pair ending excerpts with the state that actually supports them.

#### N06d — Close the remaining creature delivery gaps

**Agent:** gameplay/content integrator; Sonnet or GPT-5.6 Terra. Use existing deterministic balance tools; escalate only unresolved regional balance or save compatibility defects.

The inspected roster is 15, not the planned 17. Add **Shutter Skitters at `outskirts_apartment`** and **Cable Eater at `rail_signal`**, appending the combat alternative at index 2 while retaining both original routes and strong N05 prose. Define stable adversary IDs separately from `portrait_id`; verify that neither already exists at implementation time.

Give each creature a practical reason to occupy the place, a readable warning, and a worthwhile fight result compared with searching/leaving or following/cutting power. Anchor threat, HP, damage, and rewards to builds that actually reach its region. Do not copy the obsolete cross-creature HP sketches or inflate XP to compensate for an irrational fight. Preserve the completed Widow/Kilnback work unless evidence requires a targeted correction.

Complete Cable Eater's promised access/knowledge consumer and its ordering fallback: a randomly selected `rail_door` may already have been visited when `rail_signal` occurs. The plan must name a still-reachable gate or other supported payoff for that history. Keep local colony clearance a sufficient Skitters consequence unless an existing card promises more; avoid adding another three-chapter quest.

Verify all six creature scenes, both new combat choices, missing-image presentation, flee/victory outcomes, resource/XP accounting, acquisition routes, and the combat-opportunity cap. Keep the environmental giants outside the combat roster.

**N06 done when:** all 39 arc/finale records have evidence-backed dispositions; all five threads resolve across appropriate histories; promises have functioning consumers/fallbacks; finales reflect knowledge and ownership; and the two residual fights bring the roster to the planned 17 or a separately agreed scope change is recorded. Prose present in JSON is not by itself verification.

### N07 — Make reading and reward delivery pleasant

Depends on integrated N06 batches; N05 and existing UI improvements are preserved. **Agent:** UI/content integrator, Sonnet or GPT-5.6 Terra. A small model can inventory strings and entries after the expected behavior is specified.

- Support paragraphs, longest validated passages, readable labels, and independent scrolling at compact sizes/Large text. Keep choices/navigation reachable.
- Preserve instant reveal, skip, reduced motion, and interrupted typewriter position. More words must not force longer waits or replay already-read text.
- Keep full text available; do not replace the richer story with generated summaries. Brief recaps must use recorded facts.
- Show actual costs, gains, condition changes, and new opportunities through existing result/inventory UI. Do not rely on subtle prose to reveal consumed food.
- Review all 25 Chronicle definitions/variants, preserving multiple accounts and spoiler-safe hints. Record triggers and revised counts for any justified additional entry.
- Align survivor framing, transitions, Rest/Press On, recap/commitments, treatment, combat, escape, death, and victory copy.
- Check species-appropriate shared narration and machine/organic effects. A Cable Eater cannot wield a rifle; victory cannot imply an unwounded fight without evidence.
- Verify names and descriptions without portraits, raw IDs, or missing-art notices.

Prioritize three observable experiences over a visual redesign:

1. **Before choosing:** the intention, guaranteed item/pressure cost, and lock reason are readable on the current choice row. Show cost information for affordable choices as well as locked ones, including its accessibility text. Keep uncertain outcomes distinct from guaranteed costs.
2. **While reading:** short paragraphs, dialogue, and occasional quiet passages create rhythm. Test a complete arc at normal and Large text sizes; fix confusing or repetitive paragraphs selectively. Optional recall should identify the person and the last known situation without revealing future branches.
3. **After choosing:** the result makes the actual gain/loss and immediate story change clear, including capacity/full-health cases. Any factual receipt or recap comes from committed results; opening it grants nothing and rolls nothing.

For the 25 Chronicle definitions, check loaded versus reachable entries under the current finale split, ending denominators, source triggers, overlapping variants, and spoiler-safe hints. Preserve different accounts across runs without importing an earlier survivor's relationships. A restored route may make an old entry reachable; do not remove it because an N00 card called it dead.

**Done when:** reading is navigable, rewards are visible, and memories reflect real decisions without cross-run gameplay advantages.

### N08 — Verify the expanded story

Check each batch and run final integration after N07. **Agent:** main integrator plus existing scripts; Haiku or GPT-5.6 Luna can extract failures and evidence, while Sonnet/Terra diagnoses ordinary failures. Use one bounded Opus/Sol review for unresolved save/routing/ownership risks. Reuse tools; avoid tests that only assert favorite sentences.

Run narrow checks during each batch and the full applicable suite once the integrated changes are ready. Do not repeat a passing full soak after a punctuation edit. Reuse recent evidence only when the relevant files/contracts are unchanged, and label what was reused. Changes to routing, costs, rewards, scheduling, or transactions require their affected regression checks.

Required evidence:

- Both explicit configurations load. The expanded default initially has 112 events, 25 discoveries, and 17 adversaries; record justified departures and final choice/outcome counts.
- JSON/references, consumed fields, shared length budgets, all variants, duplicate/prohibited prose, and legal choice counts pass.
- Independent mechanical comparison permits only listed changes. Update tests assuming disabled callbacks as a documented scope change, not unexplained deletion.
- Source facts have consumers; overlapping flags select correct variants; possession cannot unlock incompatible rewards.
- Due chapters, fallback, refusal, failure, and completion work for all five threads with competing hooks and Bunker/Rust-Sea, not only isolated flag fixtures.
- At least one contrasting-history pair per thread demonstrates its consequential return; reuse verified Channel Nine fixtures. Add the N06c ending matrix and the N06d late-consumer ordering case. Include same-seed/different-choice transcripts, and keep same-seed/same-decision replay deterministic; intentional scheduler changes need not preserve the old version's order. Two favorable examples cannot establish all five threads.
- Rewards/costs/discoveries apply once through critical fallback, reopen, retry, force-close, and terminal cleanup. Old prepared actions, legacy fights, and true permadeath remain safe.
- Old runs and untouched sources gain no fabricated history. No unintended cross-run relationship/item/XP/access inheritance occurs.
- Depleted survivors retain legal actions. Supply/combat guarantees, travel/hunger/fatigue, checkpoint progression, and acquisition routes work.
- Affected combat balance/full-run checks report fight length, resource costs, reward inflation, build utility, encounter mix, and fallback frequency. Longer chains cannot farm XP or loot.
- Worst-case prose, variants, Large text, scroll/reveal/reopen, and no-portrait combat preserve reachable controls.

Keep one concise evidence index in the queue: task/event IDs, configuration, history or seed, expected difference, command, result, and artifact path. Store full logs/transcripts in artifacts rather than pasting them into every handoff. Separate automated correctness, editorial review, human enjoyment, and real-phone evidence.

Existing PowerShell entry points from the project root:

```powershell
$narrativeGodot = 'C:\Users\ASUS\Applications\Godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe'
& $narrativeGodot --headless --path . --script res://tests/test_runner.gd
& $narrativeGodot --headless --path . --script res://tools/data_package_audit.gd
& $narrativeGodot --headless --path . --script res://tests/layout_ui_smoke.gd
```

Use existing action-recovery/combat UI suites for affected contracts and `tools/full_run_harness.gd` for recorded branches, scheduling, and journeys. Isolate test saves and preserve real saves. Record commands/results/seeds and distinguish desktop from phone evidence.

**Done when:** consequences, rewards, scheduling, saves, content, and presentation pass applicable checks. Reader enjoyment remains N09.

### N09 — Verify reading and investment with people

**Owner: human players; assistant support: Sonnet/Terra for feedback synthesis, Haiku/Luna for organizing notes.** Reuse the M12 uncoached-playtest program. Prepare the packet once integrated arcs are stable; perform acceptance on the tested N08 candidate. Include at least a reader-focused player and a survival/build-focused player. Two readers are an initial discovery round, not proof that all audiences enjoy the game.

Provide a brief premise and controls, the exact build/configuration, and a simple feedback sheet. Do not teach the intended theme or tell players what emotion a scene should produce. Observe a complete followed thread and contrasting complete or naturally ending runs; include failed help where practical. Keep developer transcripts separate from the uncoached experience. No automatic invitations or messages to other people are part of this package.

Ask or observe:

- Can they explain commitments before choosing? Is hesitation caring or confusion?
- Does success feel worthwhile and match its promise?
- Can they recall a character and creature without rereading?
- Do they recognize a returning action and explain what changed because of it?
- Does failed help leave curiosity about the next chapter?
- Where does longer writing absorb them, and where does it become repetitive?
- Which alternative do they want to try next run?
- Does the ending reflect the journey they remember?

Test short and long scenes in context before stretching all passages. Repair recurring comprehension/payoff failures. Do not infer enjoyment from pauses, text volume, or model self-review.

Record where the problem happened, what the player believed, and what the game actually did. Prioritize confusion about a commitment or a missing payoff, then repeated loss of interest, then isolated wording preferences. Make one focused revision and replay the affected passage/branch; seek a fresh read when the intended understanding has materially changed. Avoid an endless “make it more literary” cycle.

**Done when:** readers understand commitments, value rewards, recognize consequences, and name moments they want to revisit. If unavailable, mark this gate pending.

### N10 — Activate the expanded default and reconcile documentation

Depends on N08; N09 remains a separate human acceptance gate. **Agent:** Sonnet/Terra for the runtime/configuration change; Haiku/Luna for factual documentation reconciliation against the verified evidence index.

- Make the tested expanded narrative the intended default. Activation is within this plan; publishing/store submission is not.
- After changing the default, smoke-test a fresh run through the no-argument loader and confirm a callback is actually reachable. Keep explicit `new(false)` compatibility evidence and test old/prepared saves against the chosen enrollment contract. A passing `new(true)` test alone does not prove the shipping default changed.
- Update `IMPLEMENTATION_PLAN.md`, `IMPLEMENTATION_QUEUE.md`, `PROJECT_STATUS.md`, `CONTENT_AUTHORING.md`, `TESTING.md`, and release guidance so old disabled-callback/short-prose restrictions cannot return accidentally.
- Update the Living Road bible and Bunker/Rust-Sea guides to match final passages, rewards, ownership, scheduling, and endings.
- Record exact content boundaries, migration, completed/partial threads, creature delivery, changes, tests, and remaining human/phone work.
- Keep further Bunker/Rust-Sea Waves B/C/Convergence and portrait production separate. The existing fifteen Living Road callbacks are no longer deferred.
- Record automated completion, reader acceptance, and phone acceptance separately. N10 may finish with N09 pending; describe the build as awaiting reader acceptance instead of declaring the story proven enjoyable. If feedback later changes a validated contract, rerun the affected N08 checks.

**Done when:** the implemented expanded configuration and docs describe the same experience, with unfinished acceptance clearly identified.

## 8. File ownership and editing rules

| Work | Primary location |
| --- | --- |
| Baseline prose | Existing `data/narrative_overrides_v1.json` / `data/narrative_overrides_v11.json`; avoid another layer |
| Labels, costs, rewards, flags, routing | `data/events.json`, corresponding overrides, and allowlist |
| Returning threads/source patches | `data/living_road_events.json` |
| Major arcs | `data/bunker41_events.json`, `data/rustsea_events.json` |
| Discoveries | `data/road_ledger.json`; `story_discovery.gd` only for necessary selection fixes |
| Creature combat | `data/adversaries.json`, `data/combat_content.json`, associated events |
| Loading, budgets, variants | `scripts/domain/content_repository.gd` and matching tests/audits |
| State, routing, rewards | `scripts/domain/game_engine.gd` and existing save/transaction contracts |
| Reading, recap, image fallback | Existing UI modules, especially `main.gd`, `story_typewriter.gd`, `portrait_art.gd` |
| Authoring reference | New story canon, creature bible, consequence map, and narrative queue under `docs/` |

Do not run `tools/rewrite_literary_content.js` as a bulk polish command. It is an old one-time baseline expansion script with generic regional/filler templates.

Use one writer/integrator in the shared checkout unless the owner separately asks for delegation. If parallel writers are requested later, use isolated drafts/checkouts and explicit ownership, especially for shared override arrays.

## 9. Agent choices and token discipline

**Default: one main writer/integrator, working sequentially.** “Agent” below means a role and model recommendation; it does not require creating custom agents or launching a team. Choose the Claude Code **or** Codex column, not both for the same task. These recommendations do not authorize automatic delegation. Use a separate reviewer only for a bounded defect or important completed arc when the owner asks for delegated work; otherwise switch roles/models within the main workflow.

The model assignments are editorial recommendations for this project, not measured rankings of fiction quality. Claude Code documents Sonnet as its economical coding choice, Opus for complex reasoning, and Haiku for simple work; aliases resolve through the account's configuration. [Claude Code cost guidance](https://code.claude.com/docs/en/costs), [model configuration](https://code.claude.com/docs/en/model-config). Codex documents Terra as balanced, Luna as the economical option, and Sol/Astra for more complex work; availability depends on the account/client. [Official Codex model guidance](https://learn.chatgpt.com/docs/models). Guidance checked 14 September 2026; confirm the selected model in the client when starting work.

| Refinement / role | Claude Code | Codex | Scope and escalation |
| --- | --- | --- | --- |
| N00–N05 / completed | None | None | Reuse finished work and evidence; assign only a specific newly found defect. |
| N06a / reconcile existing changes | Sonnet (`sonnet`) | GPT-5.6 Terra (`gpt-5.6-terra`), medium | Check current implementation against the short residual list. Do not commission another full audit. |
| N06b / write returning arcs | Sonnet | Terra, medium | One arc at a time, all outcomes. Use Opus / Sol, high, for a bounded redesign of a weak dilemma or ending, then return to the main model. |
| N06c / major arcs and endings | Sonnet, with one Opus (`opus`) review of the ending matrix | Terra, with one GPT-5.6 Sol (`gpt-5.6-sol`), high, review | Spend stronger reasoning on ownership, conflicting histories, and major emotional payoffs. Avoid premium review of every sentence. |
| N06d / remaining creatures and consumers | Sonnet | Terra, medium | Implement two fights and test their regional utility. Scripts perform simulations; escalate only an unresolved design/compatibility issue. |
| N07 / reading UI, receipts, Chronicle | Sonnet | Terra, medium | Preserve existing UI work; verify real scenes and state. Haiku/Luna may inventory strings, not decide narrative continuity. |
| N08 / evidence extraction | Haiku (`haiku`) with existing scripts | GPT-5.6 Luna (`gpt-5.6-luna`), low, with scripts | Extract failures/counts/paths. Main model diagnoses defects; Opus/Sol reviews unresolved state or save risks. A small-model summary is not correctness signoff. |
| N09 / reader feedback | Human readers; Sonnet synthesizes | Human readers; Terra synthesizes | Haiku/Luna can format notes. No AI model replaces the uncoached playtest. |
| N10 / activation and documentation | Sonnet for activation; Haiku for factual doc edits | Terra for activation; Luna for factual doc edits | Verify the actual default and old-save behavior. Documentation follows measured results. |

GPT-6 Astra is an optional escalation for a difficult issue that remains unresolved after a focused reproduction and review; it is not required for every package. If a model is unavailable, use the available model in the same general role and record the substitution. Do not change models repeatedly during a straightforward batch.

### Keep the context small and the work complete

- **Start from a task packet, not the whole repository:** the resume block, current package, latest queue handoff, relevant canon entries, and the source/return/ending cards that task touches. Read shared safety/authoring contracts on first use or when they change. Export effective prose after overrides; do not judge obsolete base text as the player's passage.
- **Work by dependency:** for N06b keep one source plus its three return scenes together. For Bunker/Rust-Sea, use 3–5 connected scenes, with their immediate consumers. Keep a short arc outline across batches so local edits preserve the larger story.
- **Draft once, review once, fix specific findings.** Retain passages that work. Request a patch and short explanation, not multiple full alternative rewrites. After a failed correction, escalate the isolated cause rather than repeating the same broad instruction.
- **Use scripts for mechanical work:** counts, JSON paths, effective exports, diffs, replay, and balance. Return failures and artifact paths to the model; retain full logs on disk. Reject unknown patch keys and no-op edits, reflecting the N05 applier findings.
- **Do not repeat the N05 fourteen-agent pattern by default.** Small contexts and fewer duplicated reviews are the savings mechanism. Delegated parallel work, if later requested, needs exclusive file ownership or isolated patches and a single integrator.
- **Separate cheaper execution from fewer tokens:** a lower-priced model can still waste tokens through retries or oversized context. Record model, completed unit, input/output/cache usage when available, and rework. Compare cost per verified arc, not just the price of one response. Do not promise a fixed percentage saving or infer subscription quota from API prices.
- **Keep handoffs short:** aim for 250–400 words plus artifact links: task/scene IDs, what changed, state contracts, checks/results, exact remaining issue, and next action. Do not copy the plan, prose, or entire logs into the queue. This is a reporting target, not a limit on necessary story text or verification.

Recommended sequence: **N06a once → finish one remaining arc in N06b → address its N06c ending consumers → finish the other arcs/major-arc batches → N06d → N07 → N08 → N10**, with N09 preparation alongside stable content and human acceptance recorded when performed. Keep N06d explicit if story work is spread across sessions. A session limit should leave a tested slice and exact next action, not another broad expansion plan.

## 10. Paste-ready continuation handoff

Use this when ready to implement the remaining work. Select the model from section 9 in your client; this prompt is not an agent configuration.

```text
Continue Ashfall Road using docs/NARRATIVE_REFINEMENT_PLAN.md, updated
14 September 2026. N00–N05, including the Channel Nine pilot and N05b
Kilnback retune, are complete. Preserve them and all ongoing changes.

Read the plan's Resume block, the current remaining package, section 9,
and the latest queue handoff. Start with N06a only if its reconciliation
has not been recorded. The queue's old “N06 next” paragraph is behind
some implementation: conditional finale routing, fixed first-chapter
focus, and a pilgrim consumer already exist. Verify rather than rebuild.

Complete the next unfinished connected story batch, including choices,
all outcomes, exact rewards, later consumers, and relevant ending text.
Improve character development, understandable commitments, meaningful
returns, warmth, and satisfying resolutions. Longer prose is not a quota.
Check effective content after overrides and preserve known/unknown facts.

Use relevant canon and consequence cards, including consequence map §5b.
Keep ownership distinct from historical evidence. Check competing variants
and missed/earlier consumers. Carry the two remaining Skitters/Cable Eater
fights as N06d; the inspected roster is 15 and the target remains 17.

Use one main agent and the economical model assigned in section 9.
Use a stronger model only for a bounded unresolved story/state problem.
Do not launch subagents unless I explicitly ask. Use scripts for counts,
diffs, audits, and replay; preserve save/RNG/transaction and pacing contracts.

Validate the affected branch or batch, then record a short evidence-backed
handoff in docs/NARRATIVE_REFINEMENT_QUEUE.md. Link logs rather than copying
them. Do not rerun completed packages or rewrite sound scenes wholesale.
Continue through ready work within the session; at a session boundary leave
the exact next task and unfinished acceptance gates.

N10 enables the expanded default after N08 and verifies the real default
loader. N09 requires human readers and remains pending without them.
Publishing is outside scope. Never claim unperformed tests or enjoyment.
```

Implementation is complete when expanded content has verified dispositions; all outcomes/variants are reviewed; successful choices deliver their rewards; all five arcs are reachable across appropriate runs; major commitments have consumers/fallbacks; six creature scenes and four fights work without portraits; endings/memories agree with run state; and applicable checks pass. Full narrative acceptance also requires N09 reader evidence. More words and flags alone are not completion criteria.
