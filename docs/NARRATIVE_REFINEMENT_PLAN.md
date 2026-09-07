# Ashfall Road: Narrative Expansion and Consequence Plan

Updated 8 September 2026. **Planning document only: no content, release flag, or save format is changed by updating this file.** Keep the filename `NARRATIVE_REFINEMENT_PLAN.md` so existing links and handoffs continue to work.

This is the authoritative narrative work package for Claude Code and the owner's chosen coding workflow. It now covers a substantial story expansion: richer reading, compelling choices, satisfying rewards, recurring consequences, creatures, and endings. It supersedes earlier restrictions limiting the work to prose refinement, 97 active events, disabled Living Road callbacks, uniformly short passages, and no new enemies. Unrelated offline, permadeath, save-safety, and monetization boundaries remain.

## 1. The experience to build

The player should want to keep reading to discover what happens to people they know, understand strange creatures, earn something worth the risk, and see earlier decisions return in a changed situation.

Build scenes around this progression:

**Something specific catches your attention → you understand competing needs → you commit to an approach → the outcome changes something → later play remembers what happened.**

Every selectable choice must have a distinct intention and meaningful immediate or delayed significance. That may be survival resources, equipment, usable information, a person's observable response, access, a relationship, or an ending. Two labels followed by equivalent outcomes and no distinct significance need redesign.

Not every small choice needs a multi-region quest. Use local consequences for ordinary decisions and durable callbacks for major commitments. Branches can converge while retaining relevant differences. Refusal can preserve resources and close an obligation; failed help can change the relationship and the next problem. Neither should automatically erase a story.

Preserve relief, discovery, useful expertise, humor in character, and uncomplicated kindness. **Success can feel good.** Do not undermine every reward with a final punishment or make every stranger a betrayer. Hard dilemmas matter more when the world contains things worth protecting.

Recommended central question: **What are you willing to carry into safety, and whom does your survival leave outside?** Develop this from existing Citadel, admission, testimony, and survival material without imposing a protagonist personality or universal morality score.

People enjoying the game for its reading and choices is the acceptance goal. Word count, model scores, and automated tests cannot guarantee affection; observe it through reader feedback.

## 2. Starting evidence and revised scope

| Area | Inspected starting point | Planned destination |
| --- | --- | --- |
| Main configuration | 97 events: 76 baseline, 13 Bunker, 8 Rust-Sea | Integrate the existing 15 Living Road callbacks: 112 events initially |
| Choices / authored outcomes | 236 / 390 without callbacks; 281 / 465 with the existing pack | Review all expanded content and added creature/branch outcomes; record final counts |
| Adversary definitions | 13: 7 human factions, 4 animal/mutant types, 2 machines | Keep original IDs and add four combat creatures: 17 definitions |
| Discoveries | 10 without callbacks, 25 with callbacks | Activate and review the existing 25 definitions |
| Baseline prose | Both override files load; M03/M04 are recorded complete | Redesign decisions and scenes where needed; allow longer and conditional passages |
| Callback pack | 15 events, five three-chapter threads, 22 source-outcome patches; disabled | Make these playable, memorable, and reliably scheduled when followed |
| Test evidence | Queue records 2,444 regression assertions | Re-establish current results and deliberately revise changed content contracts |

These are inspected data/loader facts, not a new test run. Loaded does not mean reachable on a new run. Trace actual finale routing and compatibility-only content. The worktree contains substantial ongoing work; `tools/full_run_harness.gd` already exists although the queue lists M11 as next. Inspect and reuse it.

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

Create `docs/NARRATIVE_CONSEQUENCE_MAP.md`. For each choice, record its distinct immediate effect or local resolution. For each major commitment, additionally record:

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
- Once the player engages with a returning thread, persist its focus and due continuation. Reserve an eligible ordinary slot ahead of unrelated openings, preserving combat/supply guarantees and valid Bunker/Rust-Sea progression.
- Failed help can continue the focused story. Deliberate refusal can resolve or end it coherently; normal progression must not require accepting the obligation.
- A promised return must not silently expire because random selection chose another scene. Provide a documented later scene/checkpoint fallback when exact timing cannot be retained. Describe only known facts and fulfill guaranteed reward obligations without inventing an offscreen rescue.
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

## 6. Starting defects to repair

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

Depends on N01–N04 and affected sources; can run alongside independent N05 work in sequential batches.

Coverage: all 15 Living Road scenes, 13 Bunker scenes, 8 Rust-Sea scenes, and 3 base finale records. With N05 this covers the initial 112-event target.

- Make every return a present conflict, not a recap plus roll. Cite a concrete prior action and show what it changes now.
- Give help, control, distance, failed attempts, and exploitation credible interpretations and the promised distinct opportunities/rewards. Preserve differences at convergence.
- Give each followed thread a satisfying local resolution. Hopeful, costly, and deliberately unresolved endings can coexist; do not make them all losses.
- Integrate Mara, Key possession, testimony, and creature consequences into real consumers. A lore flag is not automatically an item or living companion.
- Audit all nine starting `lethal` outcome records. Preserve concrete escalating warnings and withdrawal; add no instant deaths for dramatic effect.
- Trace the actual finale and legacy pending routes before removing unused-looking nodes.
- Make the final commitment select a distinct ending with bounded authored epilogue variants for relevant histories. Avoid requiring a separate ending for every flag combination.
- Resolve the local Rust-Sea chapter before teasing further Spire waves.

**Done when:** all five returning stories complete across appropriate runs, earlier choices alter later play, and major arcs/endings agree with recorded history.

### N07 — Make reading and reward delivery pleasant

Depends on integrated N05/N06 batches.

- Support paragraphs, longest validated passages, readable labels, and independent scrolling at compact sizes/Large text. Keep choices/navigation reachable.
- Preserve instant reveal, skip, reduced motion, and interrupted typewriter position. More words must not force longer waits or replay already-read text.
- Keep full text available; do not replace the richer story with generated summaries. Brief recaps must use recorded facts.
- Show actual costs, gains, condition changes, and new opportunities through existing result/inventory UI. Do not rely on subtle prose to reveal consumed food.
- Review all 25 Chronicle definitions/variants, preserving multiple accounts and spoiler-safe hints. Record triggers and revised counts for any justified additional entry.
- Align survivor framing, transitions, Rest/Press On, recap/commitments, treatment, combat, escape, death, and victory copy.
- Check species-appropriate shared narration and machine/organic effects. A Cable Eater cannot wield a rifle; victory cannot imply an unwounded fight without evidence.
- Verify names and descriptions without portraits, raw IDs, or missing-art notices.

**Done when:** reading is navigable, rewards are visible, and memories reflect real decisions without cross-run gameplay advantages.

### N08 — Verify the expanded story

Check each batch and run final integration after N07. Reuse tools; avoid tests that only assert favorite sentences.

Required evidence:

- Both explicit configurations load. The expanded default initially has 112 events, 25 discoveries, and 17 adversaries; record justified departures and final choice/outcome counts.
- JSON/references, consumed fields, shared length budgets, all variants, duplicate/prohibited prose, and legal choice counts pass.
- Independent mechanical comparison permits only listed changes. Update tests assuming disabled callbacks as a documented scope change, not unexplained deletion.
- Source facts have consumers; overlapping flags select correct variants; possession cannot unlock incompatible rewards.
- Due chapters, fallback, refusal, failure, and completion work for all five threads with competing hooks and Bunker/Rust-Sea, not only isolated flag fixtures.
- At least two same-seed/different-choice transcripts show later differences in options, resources, relationships, and appropriate endings. Same-seed/same-decision replay remains deterministic; intentional scheduler changes need not preserve the old version's order.
- Rewards/costs/discoveries apply once through critical fallback, reopen, retry, force-close, and terminal cleanup. Old prepared actions, legacy fights, and true permadeath remain safe.
- Old runs and untouched sources gain no fabricated history. No unintended cross-run relationship/item/XP/access inheritance occurs.
- Depleted survivors retain legal actions. Supply/combat guarantees, travel/hunger/fatigue, checkpoint progression, and acquisition routes work.
- Affected combat balance/full-run checks report fight length, resource costs, reward inflation, build utility, encounter mix, and fallback frequency. Longer chains cannot farm XP or loot.
- Worst-case prose, variants, Large text, scroll/reveal/reopen, and no-portrait combat preserve reachable controls.

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

Reuse the M12 uncoached-playtest program. Test the complete Channel Nine pilot and contrasting complete or naturally ending runs. Include a reader-focused player and a survival/build-focused player.

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

**Done when:** readers understand commitments, value rewards, recognize consequences, and name moments they want to revisit. If unavailable, mark this gate pending.

### N10 — Activate the expanded default and reconcile documentation

Depends on N08; N09 remains a separate human acceptance gate.

- Make the tested expanded narrative the intended default. Activation is within this plan; publishing/store submission is not.
- Update `IMPLEMENTATION_PLAN.md`, `IMPLEMENTATION_QUEUE.md`, `PROJECT_STATUS.md`, `CONTENT_AUTHORING.md`, `TESTING.md`, and release guidance so old disabled-callback/short-prose restrictions cannot return accidentally.
- Update the Living Road bible and Bunker/Rust-Sea guides to match final passages, rewards, ownership, scheduling, and endings.
- Record exact content boundaries, migration, completed/partial threads, creature delivery, changes, tests, and remaining human/phone work.
- Keep further Bunker/Rust-Sea Waves B/C/Convergence and portrait production separate. The existing fifteen Living Road callbacks are no longer deferred.

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

## 9. Use the coding window for complete stories

This is larger than a polish pass. A reset window is not a reliable estimate of throughput. Prioritize validated playable stories over a large untested rewrite:

1. Establish both dossiers, concise canon, consequence map, and exact rewards.
2. Implement minimum text/memory/scheduling support and finish Channel Nine with different histories and a real payoff.
3. Finish the rest of the pilot, P0 repairs, and six named creature scenes.
4. Integrate the other four threads, major arcs/endings, regional batches, and four creature fights.
5. Complete reading UI, expanded-default activation, regression/balance checks, and the reader packet.

Do not spend the first session rewriting every opening before proving a complete story returns. If the window ends, save a tested slice and list exact incomplete scenes/contracts and the next task. Draft prose, integrated scenes, functioning callbacks, combat-ready creatures, automated verification, and human acceptance are distinct statuses.

Carry only current canon, consequence map, queue, relevant event cards, and the last handoff into a new context. Use tools to export/count/diff/replay; reserve model attention for choice, character, description, reward, and continuity.

## 10. Paste-ready Claude Code handoff

Use this when ready to implement:

```text
Execute docs/NARRATIVE_REFINEMENT_PLAN.md as the updated narrative expansion
plan for Ashfall Road. This is implementation, not another review.

The owner wants richer absorbing scenes, understandable dilemmas, worthwhile
success rewards, strange creatures and giant mutants, and earlier decisions
that visibly change later play and endings. Every choice needs distinct
significance. Major commitments need durable implemented consequences.
Preserve relief and genuinely successful moments as well as hard choices.

This plan supersedes restrictions on 97 active events, disabled Living Road
callbacks, uniform 60–90/30–50 word passages, and no new enemies. Integrate
the fifteen callbacks and five returning stories, targeting initially 112
events and 25 discoveries. Add six creature identities/scenes and four
combat profiles, targeting 17 adversaries. No portraits are required.

Start from current repository facts and preserve ongoing changes. Read the
plan, queue, content authoring guide, narrative bible, loader, and save
transaction contract. Export both explicit content configurations, establish
tests, and create canon, creature bible, consequence map, and narrative queue.
Keep before-change mechanical records independent of files being edited.

Work through N00–N10, developing required N04 support alongside N03. First
deliver the complete Channel Nine source-to-resolution pilot and different
histories, then the remaining sample scenes. Continue through every target
scene, outcome/variant, reward, callback, creature, arc, ending, and UI copy.
Do not stop at documents, names, or rewritten openings when implementation
can continue within the authorized scope.

Implement budgets and conditional-text contracts before relying on longer
or state-dependent prose. Give major choices consumers and a scheduling/
fallback policy. A followed thread must not silently lose its payoff to
random selection. Do not promise all five complete threads in one run under
the one-callback-per-region limit.

Specify supported rewards/costs exactly and make success fulfill intention.
Do not invent JSON fields, fake transfers, invisible benefits, or unused
flags. Document and test intentional changes to rewards, availability,
flags, routing, scheduling, and content contracts.

Preserve IDs and choice indices/intentions, prepared actions, old encounters,
save/RNG safety, offline play, permadeath, item routes, combat rules, supply/
combat guarantees, and central XP/travel accounting. Keep this survivor's
relationships separate from cross-run Chronicle knowledge. No new economy,
items, shops, companion combat system, artwork, monetization, or general
dialogue framework is required.

Integrate and validate 5–8 complete scenes at a time. Record IDs, branch and
reward evidence, contract changes, tests, and exact next task in the queue.
Reuse existing audit/full-run tools; never run the generic rewrite script.
Work sequentially unless I ask for agents.

After implementation checks, make the expanded configuration the intended
default and update stale planning/status/authoring/testing docs. Publishing
is outside scope. Prepare the reader packet; never claim player enjoyment,
phone acceptance, or unperformed tests as verified.

Resolve routine choices from the plan and canon. Ask only about material
ambiguity that changes scope, continuing independent work while pending.
If the session ends, leave a resumable handoff with unfinished branches,
fights, and acceptance gates explicit.
```

Continuation prompt:

```text
Continue the next ready task in docs/NARRATIVE_REFINEMENT_QUEUE.md under the
updated docs/NARRATIVE_REFINEMENT_PLAN.md. Read the current canon, creature
bible, consequence map, and last handoff if present. Preserve finished work;
do not restart the audit. Complete and validate the next playable branch or
batch, then record exact coverage and remaining work.
```

Implementation is complete when all expanded content has a disposition; all outcomes/variants are reviewed; successful choices deliver their rewards; all five arcs are reachable across appropriate runs; major commitments have consumers/fallbacks; six creature scenes and four fights work without portraits; endings/memories agree with run state; and applicable checks pass. Full narrative acceptance also requires N09 reader evidence. More words and flags alone are not completion criteria.
