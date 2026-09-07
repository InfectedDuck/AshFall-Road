# Ashfall Road: Cost-Efficient Improvement Plan by Model

Status: Saved implementation plan. Saving this document does not start any mini-plan.

## 1. Goal, scope, and model strategy

Improve the existing launch game so that players can discover useful builds, understand combat, enjoy consistent writing, and want another run.

Locked decisions:

- Quality gates take priority over the September 27 release target.
- Difficulty remains hardcore and skill-led; a universal 3–5% win rate is not a release requirement.
- Integrate the existing prose improvements and targeted equipment routes.
- Keep the fifteen Living Road callback events disabled until a separate post-launch expansion.
- Preserve offline play, strict permadeath, current combat rules, and the free launch without advertisements or purchases.
- Do not add shops, currency, skill trees, new enemies, or additional equipment.

### Model allocation

| Model | Recommended effort | Assigned role |
|---|---|---|
| **Luna** | Low | Inventories, structured checks, test execution, factual documentation, release checklists |
| **Terra** | Medium | Clearly specified UI, content integration, equipment routes, and regression tests |
| **Sol** | Medium; High for simulation work | Contextual onboarding, full-run testing tools, narrative consistency, integration review |
| **Astra** | High for the structural task | Save-safety changes crossing systems; difficult unresolved diagnosis and final balance interpretation when necessary |

This allocation follows the broad roles in the [official model guidance](https://learn.chatgpt.com/docs/models). It is a recommended workflow, not a claim that only Astra can perform architectural work.

Actual Codex allowance consumption depends on context, effort, tool use, and retries. API prices should not be treated as exact subscription-limit multipliers.

### Cost-control rules

- Execute one mini-plan per task.
- Give the model the relevant mini-plan and previous handoff—not the entire conversation.
- Start with the assigned model. Escalate only after two unsuccessful, evidence-backed repair attempts or a newly discovered cross-system problem.
- Run long simulations as local programs; do not ask a model to narrate every iteration.
- Use targeted tests during development and the full suite at integration gates.
- Do not have every model review every change.
- Work sequentially in the shared project. Parallel editing is unnecessary for this plan.

### Selecting models

Manually select the assigned model and effort before requesting each mini-plan. The model labels in this document do not automatically switch the main chat's model. Model-specific subagents require an explicit delegation request; this plan defaults to manual selection, not automatic delegation.

## 2. Shared implementation boundaries

All mini-plans must follow these rules:

- Preserve existing unrelated changes.
- Preserve event IDs, existing choice indices, inventory ownership, purchase ownership, and prepared-roll compatibility.
- Keep existing encounters under their saved combat-rules version.
- Never calculate gameplay outcomes in UI code.
- Keep generated artwork outside this implementation batch. Use existing art and deliberate placeholders.
- Do not silently update mechanical snapshots to make tests pass. Every intentional mechanical change must have a documented allowlist.
- Do not claim phone acceptance from desktop screenshots or simulations.

### Important interface changes

The implementation will introduce or extend these narrow capabilities:

- **Save-aware action boundary:** prepare, commit, retry, and input-lock state shared by gameplay actions.
- **Equipment comparison:** a read-only domain operation returning current-versus-proposed loadout effects.
- **Contextual tutorial controller:** cosmetic prompts driven by authoritative game events.
- **Chronicle presentation:** existing run history plus discoveries from currently enabled story content.
- **Simulation results:** recorded build definitions, seeds, decisions, resource expenditure, and outcomes.

Keep active-run schema 5 unless implementation proves an unavoidable incompatibility. Add profile schema 5 for contextual tutorial progress; preserve all existing settings, history, and discovery collections.

## 3. Ordered mini-plans

### M00 — Establish the implementation baseline

**Model: Luna · Prerequisites: none**

Create `docs/IMPLEMENTATION_QUEUE.md` containing these task IDs, dependencies, status, and completion evidence.

- Record the current test result; the latest verified baseline is 2,037 passing assertions.
- Record active release flags and current schemas.
- Inventory obtainable equipment, loaded prose layers, portrait coverage, and release blockers.
- Distinguish implemented content from content actually enabled in the launch build.
- Record the current dirty worktree without reverting or committing anything.

**Done when:** another model can identify the next task and relevant evidence without rereading project history.

---

### M01 — Correct the combat benchmark

**Model: Terra · Prerequisites: M00**

Repair the misleading `master_rifle` fixture in `tools/combat_balance.gd`.

- Replace positional stat arrays with named stat dictionaries.
- Preserve the old rifle fixture as an explicitly named **agile rifle** build.
- Add a genuine mastered rifle fixture: Strength 3, Agility 3, Wits 8, Grit 5, Presence 2.
- Assert every fixture's stat total, weapon attack stat, mastery status, equipment compatibility, ammunition, and starting HP.
- Include fixture metadata in exported results.
- Rerun affected comparisons and correct the report's mastered-rifle claims.
- Do not change game balance in this task.

**Done when:** reported mastery and progression budgets match actual engine state, with reproducible updated results.

---

### M02 — Make save failure handling consistent

**Model: Astra · Prerequisites: M00**

This is the principal cross-system task.

Combat already has transactional handling, but other paths do not consistently check save failures. For example, ordinary event resolution currently proceeds to presentation after calling the save operation without checking its result.

Extend the existing transaction approach rather than replacing the save system.

- Cover event preparation/resolution, equipment actions, consumables, checkpoint decisions, and stat allocation.
- Failed preparation must restore the complete prior state, including RNG.
- After resolution, failed saving must retain the resolved state and offer Retry without applying the operation again.
- Block further gameplay until the pending commit succeeds; Android Back must not bypass this.
- Make inventory and allocation screens refresh only after successful commitment.
- Add a recoverable, atomic profile-update receipt for discoveries and completed-run summaries before terminal run cleanup.
- Replay outstanding profile updates idempotently on startup.
- Receipts must contain profile updates, not a restorable living run.
- Preserve death-marker precedence and legacy prepared actions.

Profile schema 5 adds contextual tutorial progress. Existing profiles with the old tutorial marked seen migrate with the current tips dismissed; other profiles start with no tips seen.

**Done when:** injected save failures cannot reroll, duplicate rewards, lose confirmed allocation, resurrect a survivor, or silently discard a completed-run summary.

**Handoff:** document the transaction interface and precisely how later UI tasks must call it.

---

### M03 — Activate the completed prose polish

**Model: Terra · Prerequisites: M00**

Decouple prose quality from expansion activation.

- Always load the reviewed remaining baseline overrides from `data/narrative_overrides_v11.json`.
- Continue to gate callback events and their source-flag patches behind the existing Living Road setting.
- Preserve the current 97-event launch boundary.
- Preserve all mechanics and existing choice order during this task.
- Verify mechanical equality before any equipment-route changes begin.

**Done when:** all 76 baseline introductions and their outcomes use the polished prose, while the fifteen callback events remain unavailable.

---

### M04 — Review narrative consistency

**Model: Sol · Prerequisites: M03**

Review in small regional batches rather than rewriting everything again.

- Remove claims contradicted by multi-round combat, such as a victory implying the survivor took no wounds during the whole encounter.
- Ensure new conditions appear through observable symptoms.
- Ensure acquired or lost supplies match actual outcomes.
- Preserve second-person present tense, teen-rated tension, and existing word-count targets.
- Keep repeatable events independent of unrecorded previous encounters.
- Edit prose only.

**Done when:** word-count and duplicate-sentence checks pass, with no known contradiction between prose and authoritative consequences.

---

### M05 — Make the ten unavailable equipment items obtainable

**Model: Terra · Prerequisites: M02–M04**

Append two mutually exclusive choices to each of these existing, unique events. Their original choices remain unchanged and keep their indices.

| Existing event | New alternatives | Resolution |
|---|---|---|
| `outskirts_market` | Earn the Rusted Hatchet / Earn the Nail Bat | Certain; one selected weapon; +6 Fatigue |
| `flats_convoy` | Repair the awning for a Dust Cloak / Trade a useful warning for the Lucky Die | Wits Favorable / Presence Favorable |
| `marsh_body` | Recover the Rebar Spear / Recover the Tire Armor | Strength Risky for either |
| `industrial_locker` | Open the security locker for the Stun Baton / Salvage the Scavenger Rig | Wits Risky / Strength Risky |
| `industrial_office` | Unlock the Hunting Rifle cabinet / Recover the Flare Gun | Wits Hard / Agility Risky |

Rules for the checked alternatives:

- Success grants exactly one selected equipment item.
- Hunting Rifle includes four Rifle Rounds.
- Flare Gun includes three Shotgun Shells, retaining its current ammunition contract.
- Failure grants no equipment and adds 6 Fatigue in the Flats/Marshes or 8 Fatigue in Industrial events.
- Critical outcomes use the same equipment reward; no additional reward multiplier.
- No extra health damage, conditions, currency, or food changes.
- Narration must explain the effort, risk, and opportunity cost.
- Each event remains at four choices maximum.
- Preserve supply guarantees and event weights.
- Keep these routes when the later expansion is enabled; callback rewards remain mutually exclusive within their own encounters.

Update prose overrides and the mechanical-change allowlist together.

**Done when:** all fifty defined items have valid launch acquisition or starting routes, and the ten new routes pass deterministic resolution and recovery tests.

---

### M06 — Add equipment comparisons

**Model: Terra · Prerequisites: M02, M05**

Add a read-only comparison operation using the same domain calculations as gameplay.

The item detail sheet should show:

- Current item → proposed item.
- Neutral-encounter damage range and attack stat for weapons.
- Signature and mastery state.
- Armor protection and neutral Block/Dodge differences.
- Relevant non-combat modifiers.
- Capacity and overweight changes.
- Ammunition requirements and available ammunition.
- Shield removal or incompatibility caused by two-handed weapons.

Comparisons must evaluate a hypothetical loadout without changing the run or consuming RNG. Label neutral encounter values so they cannot be mistaken for a current enemy-specific prediction.

**Done when:** players can understand the principal tradeoff without equipping and unequipping items experimentally.

---

### M07 — Fix compact-screen readability

**Model: Terra · Prerequisites: M02, M06**

Keep the existing visual identity.

- Make item descriptions and detailed modifiers scroll inside the sheet.
- Keep Close and available item actions outside that scroll area.
- Give death/victory summaries scrollable content with reachable restart/navigation controls.
- Preserve the permanently visible stat-allocation actions.
- Replace isolated dice targets with `ROLL N+`.
- Group the enemy clue, attack-window status, and latest consequence more closely.
- Retain player-left/enemy-right alignment and the fixed six-action grid.
- Remove excessive empty spacing without shrinking touch targets.
- Preserve inventory filter and scroll position when returning from item details.

**Done when:** all affected screens remain operable at 360×640, 540×960, tall portrait, and the largest font setting.

---

### M08 — Replace the tutorial wall with contextual guidance

**Model: Sol · Prerequisites: M02, M07**

Introduce brief, non-blocking tips at these moments:

1. First checked choice: percentage and required roll.
2. First completed event: preparation through Inventory.
3. First Heavy or Sweep: the corresponding defensive tradeoff.
4. First successful defense: spend Riposte or Opening on the next action.
5. First weapon inspection: signature and mastery.
6. First ready Opportunity: powerful, optional, and untimed.
7. First checkpoint with points: allocation is separate from Rest/Press On.

Requirements:

- Maximum two short sentences per tip.
- Dismiss individually or disable all tips.
- Do not open tips during dice animation.
- Never alter enemy commitment, RNG, choice availability, or combat results.
- Preserve a full reference under How to Play.
- Settings can reset contextual tips.
- Existing experienced profiles must not receive a new mandatory tutorial.

**Done when:** tutorial progress persists, prompts do not repeat incorrectly, and every action remains usable while guidance is visible.

---

### M09 — Expose run history and existing-lore discoveries

**Model: Terra · Prerequisites: M02, M07**

Add one title-menu entry: **ROAD CHRONICLE**, containing two tabs.

**Runs**

- Display the existing latest twenty summaries.
- Show survivor, region reached, level, equipment, strongest defeated enemy, and cause of death.
- Do not invent missing information in older summaries.

**Discoveries**

- Enable the ten existing Bunker Forty-One, Rust-Sea, and ending entries.
- Hide all fifteen disabled callback chapters, including their progress denominator.
- Record discoveries only after authoritative resolution.
- Preserve all discovered variant tokens instead of replacing earlier variants.
- Present conflicting outcomes as accounts from different runs—not simultaneous facts about one living character.
- Count unique discovered chapters separately from their variants.
- Preserve existing discoveries without retroactively inventing unrecorded outcomes.

Add a dismissible resume recap only when the player selects Continue Run. Derive it from saved location, phase, recent choice, and current conditions.

**Done when:** death preserves history and discoveries, replaying an outcome does not duplicate entries, and disabled expansion content is not advertised.

---

### M10 — Verify the integrated data package

**Model: Luna · Prerequisites: M03–M09**

Run the prescribed checks and produce a concise discrepancy report.

- Polished prose is loaded in the actual launch configuration.
- No prohibited repeated narrative sentences.
- All fifty items have acquisition routes.
- Added choices are legal and limited to four per event.
- Original choice indices and unrelated mechanics remain unchanged.
- Callback events remain disabled.
- Existing-lore discoveries are reachable.
- No unknown icon, item, condition, or outcome reference.
- Documentation reflects current schemas and combat terminology.

Do not repair mechanics or regenerate snapshots independently. Return failures to the owning mini-plan.

**Done when:** every discrepancy is fixed or explicitly listed as a release blocker.

---

### M11 — Extend balance and full-run verification

**Model: Sol for tooling; Luna for repeat execution · Prerequisites: M01, M05, M10**

Extend the encounter benchmark to all thirteen adversaries.

- Use validated named-stat fixtures for each weapon family.
- Test early and progressed loadouts at equal point budgets within each comparison.
- Include appropriate ammunition, hungry/injured states, and unarmed fallback.
- Run at least 1,000 seeds per standard enemy/build/policy comparison.
- Retain attack-only, behavior-aware, and behavior-aware-without-Opportunity controls.
- Report win rate, HP expenditure, ammunition, conditions, exchange count, and stalled fights.

Add a full-run replay harness:

- Accept a seed and recorded decisions, including inventory, allocation, and checkpoint actions.
- Produce a trace of regional resources, equipment acquisition, XP, encounters, and death.
- Replay tester decision records deterministically.
- Add at least 1,000 seeded legal-action soak runs for progression and recovery testing.
- Label random-policy results as robustness evidence, not human completion or retention estimates.
- Do not force healing, victory, or successful rolls during these runs.

**Done when:** the game has reproducible whole-journey evidence and clearly separated encounter, robustness, and human results.

No speculative global rebalance is authorized here. Numeric tuning proposals must identify the measured problem, affected matchups, and expected tradeoff before implementation.

---

### M12 — Conduct the human acceptance pass

**Owner: you and testers · Model support: Luna for organization, Sol for analysis**

First observe five new players without coaching. Then recruit the larger closed-test group.

Record:

- Time to first meaningful choice.
- Whether a Heavy/Sweep clue is understood.
- Whether equipment comparisons affect a decision.
- First death time and understood cause.
- Whether the player voluntarily begins another run.
- Whether returning later feels confusing.
- Any clipped, inaccessible, or misleading control.

Initial directional gates:

- At least four of five observed players explain their main combat decision and most important consequence.
- At least three of five voluntarily begin another run.
- No repeated inability to allocate points, equip items, consume supplies, or leave an overlay.
- No known unexplained lethal outcome.

These are small-sample usability gates, not statistical proof of commercial success.

Assign reproduced implementation defects to Terra. Escalate systemic combat or save failures to Sol, then Astra if necessary.

---

### M13 — Finish presentation and launch materials

**Model: Luna for inventories and drafts; Terra for integration; owner for assets and approvals**

- Prioritize Bandits, Crows, and the Warden among missing portraits; retain existing Dogs, Toll Gang, and Stalker art.
- Replace missing enemy assets with deliberate, distinct silhouettes until approved art is available.
- Preserve stable asset IDs and record provenance.
- Do not generate a complete item-art set during this sprint.
- Prepare the store icon, feature graphic, and six truthful screenshots.
- Draft store copy around offline play, readable enemy behavior, equipment tradeoffs, and permadeath.
- Do not promote the disabled callback expansion.
- Keep paid acquisition deferred until testers voluntarily replay.

Owner-supplied requirements remain explicit gates: permanent package identifier, developer/support details, signing key, hosted privacy policy, Play Console declarations, and tester enrollment. Models must not guess these or publish on the owner's behalf without authorization.

---

### M14 — Final integration and release qualification

**Model: Sol; Astra only for unresolved cross-system findings · Prerequisites: M00–M13**

- Review changes against the approved boundaries.
- Run the complete regression suite and release-readiness audit.
- Build a fresh debug APK and signed release AAB through the established pipeline.
- Install the Play-delivered test build on the Samsung and one lower-end device.
- Confirm clean install, upgrade with an active run, legacy combat continuation, airplane-mode play, and interruption recovery.
- Ensure development tools and test artifacts are excluded.
- Update the project status from verified evidence, not intended completion.

**Done when:** all code, device, tester, signing, listing, and policy gates pass. Public release remains dependent on Google approval.

### Later mini-plan — Full Living Road activation

Keep this separate from launch acceptance.

- Terra enables the fifteen callbacks in a closed-track expansion build.
- Sol verifies continuity, callback selection, supply/combat guarantees, and the additional equipment distribution.
- Terra exposes the remaining Chronicle entries.
- Luna runs data, reachability, and regression checks.
- Owner gathers player feedback before production activation.

Do not remove the new launch equipment choices when activating the expansion; that could invalidate existing prepared choices.

## 4. Acceptance and release gates

### Automated

Preserve all existing coverage and add:

- Correct mastery fixtures and equal-budget comparisons.
- Save failure before and after every mutation category.
- Exactly-once profile receipt recovery and terminal cleanup.
- Prose-only mechanical equality.
- All new acquisition paths and unchanged supply guarantees.
- Equipment comparison purity and preview/resolution consistency.
- Tutorial dismissal, persistence, reset, and animation safety.
- Chronicle variant persistence, chapter counting, old-profile migration, and duplicate rejection.
- Small-screen overlay scrolling and fixed action reachability.
- Full-run replay equivalence.

### Physical devices

Test all fonts, high contrast, reduced motion, Manual/Quick Roll, Android Back, and airplane mode.

Force-close around:

- Prepared event and combat rolls.
- Damage and victory.
- Item use and equipment changes.
- Stat confirmation and checkpoint departure.
- Death and Chronicle updates.

### Publishing

Require zero known save-loss, resurrection, duplicated reward, progression-blocking, or inaccessible-control defects.

For applicable new personal accounts, complete twelve continuously opted-in testers for fourteen days before applying for production access. This and Google's review are external schedule gates. [Google Play testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en-GB)

## 5. How to hand each task to its model

Use a fresh task for each mini-plan:

> Implement mini-plan **MXX** from the approved Ashfall Road improvement plan in `docs/IMPLEMENTATION_PLAN.md`.
> Complete only this mini-plan and its required regression tests.
> Read its prerequisites and relevant handoff notes first.
> Preserve unrelated changes and the locked release boundaries.
> Do not redesign adjacent systems or change balance without authorization.
> If a prerequisite is missing, report the exact blocker rather than improvising.
> Finish with changed files, tests and results, remaining risks, and the next ready task.

Each handoff should contain:

- What changed.
- Relevant interfaces or data changes.
- Exact verification commands and outcomes.
- Any unresolved issue with reproduction details.
- The next task ID.

**Recommended starting sequence: Luna M00 → Terra M01 → Astra M02 → Terra M03.** After the save boundary is established, most remaining work stays with Terra, Luna, and Sol.
