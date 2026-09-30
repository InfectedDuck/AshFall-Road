# Ashfall Road: make combat surprising and relationships worth risking survival for

## 1. What needs to change

**The next expansion should give players new decisions during fights, a stronger late-game transformation, and someone they genuinely want to survive with.**

The current code explains some of the repetition:

- **21 enemies share six basic combat moves.** Their descriptions differ more than their tactics.
- **Attack-stat growth diminishes sharply:** going from 5 to 10 currently adds approximately 13% weapon damage.
- **Mastery unlocks at stat 6, and both talent selections arrive by the third checkpoint.** There are fewer significant build changes afterward.
- The existing betrayal stories introduce people suspiciously. They establish danger before players have much reason to feel affection.

Keep the target at **45–75 minutes per successful run**. Make additional length come from optional expeditions and relationships.

Plan for **eight weeks at the previously chosen 15–25 hours per week**, with a playable improvement after the first two.

## 2. First priority: monsters that change your decisions

Rework four existing monsters and add two new ones. Each needs a distinctive silhouette, behavior, counterplay, and reward.

| Monster | What makes its fight different |
|---|---|
| **Reed Widow — rework** | Prepares a brood that strengthens subsequent attacks. Interrupt its preparation, destroy the nest with a consumable, or race to kill it. |
| **Kilnback — rework** | Attacking heats its shell, increasing danger until the shell opens. Players decide when to build heat, defend, and spend their strongest attack. |
| **Cable Eater — rework** | Electrical attacks charge its retaliation. Ground the cable through an environmental interaction or fight with physical equipment. |
| **Ash Stalker — rework** | Learns repeated actions. Using the same action three times provokes a clearly announced counter; changing tactics breaks its prediction. |
| **Ossuary Hound — new** | A scavenger with bone plates embedded in scarred hide. It becomes more aggressive against bleeding survivors, making treatment a tactical decision. |
| **Reservoir Maw — new boss** | A filtration-station mutant fights while its chamber floods. Win by killing it or operating two drainage controls and escaping. |

Implementation rules:

- Add enemy traits, encounter objectives, and phase transitions to the combat definitions.
- Keep the six main combat buttons. Extend **Item** into a sheet containing consumables, carried-weapon switching, and available environmental interactions.
- Switching weapons or operating machinery consumes a combat action; its preview shows the enemy response.
- Show the committed enemy intention and relevant counters. A phase change affects the next round rather than silently replacing an already-previewed attack.
- Give every special mechanic at least two responses. A missing rare item must not make an otherwise ordinary encounter unwinnable.

**Build the Reed Widow and Kilnback prototypes first.** If testers still solve both with essentially the same sequence, revise them before expanding the roster.

### Make late-game investment noticeable

Preserve existing damage scaling through stat 5. Initially test **an additional 0.10 damage multiplier per effective stat point above 5**. This makes stat 5 → 10 approximately a 38% increase.

Keep existing stat-6 mastery and add an automatic specialization at **base stat 8**:

- **Strength:** once per fight, a successful attack breaks Brace or an armored shell through the following player action.
- **Agility:** once per fight, an attack preserves the Opening it would normally consume.
- **Wits:** once per fight, disable an environmental hazard or suppress a displayed enemy trait for two rounds.
- **Grit:** once per run, survive a lethal combat hit at 1 HP. This does not prevent starvation or scripted environmental death.
- **Presence:** Opportunity is available from the opening round, retaining its once-per-fight limit.

Show the next milestone during allocation. Temporary equipment bonuses improve ordinary calculations but do not unlock these specializations.

Keep enemy strength tied to authored encounters rather than automatically scaling it to the player. Earlier enemies should visibly become easier.

## 3. The emotional center: affection, betrayal, and learning to trust again

### First companion: Rhea Sorn

Introduce a new adult companion rather than turning the already-suspicious Vex into the surprise romance.

Rhea is practical, funny in small ways, and quietly attentive. She wants a room whose door she can lock from the inside. Her affection becomes real, but she ultimately accepts passage from a Citadel intermediary in exchange for handing you over.

Write **nine core chapters across the journey**, with short reactions between them:

1. **Meeting:** she helps with a problem before asking for anything.
2. **Shared competence:** the two of you survive something through cooperation.
3. **A quiet pleasure:** a warm drink, an absurd discovery, or an old song.
4. **Disagreement:** she has values and boundaries that do not simply mirror yours.
5. **Vulnerability:** she reveals a true fear and allows you to help.
6. **Closeness:** the player can initiate romance or retain friendship.
7. **A future together:** make a small, concrete promise.
8. **Betrayal:** she chooses her own escape despite caring about you.
9. **Aftermath:** surviving players confront the consequences; the ending acknowledges what happened.

Her kindness should sometimes cost her something. Avoid narration that labels her smile false or repeatedly points to a concealed weapon.

Romance develops through conversations and choices, not a Presence roll or purchasing enough gifts.

### Three betrayal variants

The route previously chosen together determines the attack:

| Shared route | Betrayal | Survival decisions |
|---|---|---|
| **Shelter** | She poisons a shared drink. | Identify treatment, spend appropriate medicine, or endure a dangerous escape with a lasting injury. |
| **Smuggler passage** | She wounds you and signals the collectors. | Defend, escape, fight, or negotiate away valuable equipment. |
| **Filtration station** | She locks you inside the Reservoir Maw’s chamber. | Kill the monster, operate the drainage controls, or spend equipment to force an exit. |

The betrayal is surprising; **the response is playable**. Reveal it before applying unavoidable lethal damage. Failed responses can worsen the crisis and eventually kill the survivor, but survival must not depend on one mandatory stat or a single death roll.

A high-investment build should offer an immediately recognizable advantage here.

If the player survives, Rhea does not automatically rejoin. The aftermath supports demanding answers, restitution, refusing contact, or accepting her explanation without forgiving her.

### Later runs: two different relationships

After the betrayal has been witnessed, introduce two alternative adult companions, each with **five core chapters and an ending**:

- **Tess Arlen, a guarded salvage engineer:** appears less welcoming than Rhea but proves reliable. Her secret concerns her past, not a plan to harm the player.
- **Mina Holt, a former checkpoint medic:** genuinely cares, but will leave if the player abandons the people she has promised to protect. Her boundaries are established before that conflict.

Their loyalties remain authored and consistent. Do not randomly turn a trustworthy character into a traitor.

The player should eventually realize that distrust also has a cost: missed intimacy, lost cooperation, and a lonelier ending.

Record witnessed chapters through the existing Chronicle and profile receipts. New survivors do not magically remember previous lives. Declining companionship remains a valid route.

A useful reference is [Overboard!](https://www.inklestudios.com/overboard/), whose characters remember actions and whose replay structure encourages discovering additional secrets.

## 4. More worthwhile journeys and loot

### Add optional hunts

Offer one optional three-scene expedition after the second checkpoint and another after the fourth:

**Evidence of a creature → preparation decision → confrontation and reward.**

Players can decline either expedition. Hunts consume normal travel resources, occur once per run, and advertise their likely reward category before commitment.

Retain six regions and five ordinary travel slots per region. Companion chapters replace appropriate ordinary events. Schedule one primary long story per run—companion or the existing Bunker/Rust-Sea arc—so multiple long chains do not accumulate into an oversized session.

### Add ten items initially

Use **two signature weapons, four pieces of equipment, and four tactical consumables**. Each must enable a behavior supported by the new combat mechanics.

Examples of the required functions:

- Grounding equipment protects against electrical retaliation.
- Coolant forces a heat-based enemy into its exposed phase.
- Incendiary supplies destroy a nest.
- A specialist counter weapon prevents regeneration after a successful Riposte.
- Heat-resistant armor turns the first prevented burn into an Opening.

Give signature gear discoverable acquisition routes through hunts, negotiations, and exploration. Players should be able to pursue a build without already knowing a loot table.

Extend equipment comparison to explain these interactions. Balance each benefit against ammunition, weight, equipment-slot competition, or a clearly stated drawback.

## 5. Delivery order and proof that it is better

| Stage | Deliverable |
|---|---|
| **Weeks 1–2** | Two distinctive monster fights, initial stat-scaling changes, interaction UI, and two supporting items. Playtest immediately. |
| **Weeks 3–4** | Rhea’s complete relationship, betrayal variants, and aftermath. Implement the Reservoir Maw needed by her route. |
| **Weeks 5–6** | Remaining monster changes, alternative companions, ten-item package, optional hunts, and stat specializations. |
| **Weeks 7–8** | Pacing and balance revisions, portraits and feedback, save compatibility, and Windows/Android release testing. |

Extend the existing data-driven interfaces with companion chapter state, campaign selection, enemy traits/objectives, item effects, and specialization usage. Keep previews read-only and commit new actions through the existing transaction system.

Version campaign and combat rules. Existing active runs finish under their existing rules; new runs receive the expansion. Persist betrayal discovery before terminal cleanup so dying cannot erase the unlock for later stories.

**Technical acceptance**

- Prepared actions, phase transitions, objective progress, and once-per-fight effects survive restart without duplication.
- Every monster has verified counterplay for several builds.
- Weapon switching cannot reset enemy intentions or talent limits.
- Every relationship branch reaches a coherent exit or ending.
- Skipped hunts and declined relationships cannot block completion.

**Player acceptance**

Test with unfamiliar players in at least two rounds, recording:

- Whether different monsters actually change their decisions.
- Whether late-game upgrades change their preferred tactics.
- Whether they name specific moments that made them care about Rhea.
- Whether betrayal feels emotionally credible and survival remains understandable.
- Where they stop reading, lose interest, or choose to quit.
- Whether they voluntarily start another run—and what they want to discover.

Treat another run as an observed behavior, not something established by a positive survey answer. If the first combat prototypes remain repetitive, spend the next iteration fixing those decisions before adding more content.
