# Creature story bible

Written 8 September 2026 for N01. Companion to [STORY_CANON.md](STORY_CANON.md); register and no-gore rules are inherited from [ENEMY_DESIGN_BIBLE.md](ENEMY_DESIGN_BIBLE.md) §1 and §4 and are not repeated. This file defines the six creatures the plan proposes: what each one is, where it lives, how a survivor learns it is there, what decision it forces, what it pays, and what it changes later.

Nothing here is playable yet. Each entry names its host scene, the choices that already exist there (their indices and intentions are preserved), the appended alternative, and the consumer of any durable consequence. A consequence without a named consumer is not promised.

## Shared rules

- **One idea each.** The roster's unique-axis rule extends to creatures. No two may share a primary read, and none may reuse an idea a human faction or existing animal already owns (see the axis table in the enemy bible: dogs own *human structure inside animals*, leeches own *directed mass*, the Stalker owns *copying a human*, crows own *collecting what shines*).
- **Not everything glows, mimics voices, is malicious, or used to be human.** Of the six, exactly one glows (Widow's eggs), none mimics voices (the Stalker owns that), two are indifferent rather than hostile (Colossus, Giant), and none was ever human.
- **Warnings escalate in threes.** Evidence of presence, evidence that ordinary caution has already failed someone, then a last chance to withdraw. Giants add a fourth: the survivor can always see the way back.
- **Mechanics must exist.** Radiation is the `radiation` pressure. Electrical contact and heat are the `burned` condition. Bites are `infection`. Being dragged or thrown is `sprain` or `concussed`. There is no venom, paralysis, or armor-piercing; do not write them.
- **Names arrive in the passage.** Titles are not reliably shown. A creature is named by the survivor's own reckoning, a chalk warning, a note, or a character, inside the scene's prose, before or during its decision.
- **No portrait required.** The four combat creatures get stable `portrait_id` values (`enemy_skitters`, `enemy_widow`, `enemy_kilnback`, `enemy_cable_eater`) and a `field_note` string. When no image loads, the portrait frame shows the creature's name over the field note in the interface face, never `PORTRAIT / ID`. This is a deliberate presentation N04 implements in `portrait_art.gd`; it must not affect layout tests. The two giants have no portrait ID and no combat profile.
- **Combat vocabulary is fixed.** Sequences use only Strike, Heavy, Sweep, Brace, Charge, Recover with species tells that describe the move honestly: Heavy is easier to dodge, Sweep easier to block, Brace halves incoming damage, Recover exposes the creature. Organic is true for all four; none is a machine.
- **Appended combat alternatives are index 2** on four existing two-choice events. Choices 0 and 1 keep their labels, checks, and outcomes. The combat route must never be the only way to the scene's reward.

## Regional presence, at a glance

| Region | Creature | Host scene | Kind |
|---|---|---|---|
| Shattered Outskirts | Shutter Skitters | `outskirts_apartment` | Named scene, optional pack combat |
| Salt Flats | Salt Colossus | `flats_mirage` (traces in `flats_bones`) | Environmental giant, no health bar |
| Drowned Marches | Reed Widow | `marsh_lights` | Named scene, optional creature combat |
| Hollow Industrial Zone | Kilnback | `industrial_tank` | Named scene, optional heavy combat, later knowledge payoff |
| Glass Wastes | Cinder Giant | `glass_shadow` | Environmental giant, rescue, later payoff |
| The Underrail | Cable Eater | `rail_signal` | Named scene, optional creature combat |

Today only two regions have creature combat: Feral Dogs in the Outskirts and Ash Stalkers in the Underrail's `rail_nest`, with Mutant Crows as a global. Marsh Leeches and Security Drones are sighted but never fought, and the Salt Flats and Glass Wastes have no creature at all. The six proposals give every region at least one creature-led encounter, which is the precondition for N05's 50–65% editorial target.

---

## Shutter Skitters — `outskirts_apartment`

**Owns:** *the building's own sounds are the creature.* A colony that taps, slides, and settles inside walls, so the survivor cannot tell the house from what lives in it.

**What it is.** Flat, plated animals the size of a spread hand, in colonies of dozens. They move behind shutters and inside wall cavities, sliding plate over plate with a sound like a cupboard door tapping. They nest in insulation, bedding, and paper for warmth, which is why a household's provisions in this building are found wrapped against smoke: the family was already sealing food away from them. They avoid light and cold, and they do not pursue past a doorway.

**Habitat and need.** Third floor of a burned apartment block. Warmth and fibre. They took the building when the heating died.

**Warnings, in order.** The cupboard taps twice, pauses, taps again, and the rhythm *changes when the survivor moves*. Fresh chalk beside the entrance warns against the stairs; on the landing, shed plates lie like broken roofing slate. At the stairwell door the survivor can still hear the street behind them.

**The decision.** Choice 0 *Search the occupied floor* and choice 1 *Respect the warning and leave* stay as they are: search is the wits gamble that reaches the family's cache past a rotten stair; leaving accepts someone else's warning. **Appended choice 2: *Drive the colony out of the stairwell.*** Pack combat. The intention is to make the building safe rather than to gamble on it, at the cost of a fight. Victory reaches the same cache without the stair (`medkit`, `canned_meat`) and establishes the building as a supply opportunity in the fiction; N02 sets the exact reward so the combat route is not strictly dominant.

**Combat sketch.** Threat low; HP near Feral Dogs' 120; damage lowest of the four. Sequence Sweep, Strike, Brace, Recover: the colony spreads across the floor, the nearest plates snap at ankles, the mass locks plate-to-plate, then loosens to reposition. Tells: "Plates fan out across the landing, closing off the stair on both sides" (Sweep, block it); "The nearest bodies rear toward the warmth of your shins" (Strike); "The colony locks together into one armored sheet" (Brace); "The sheet comes apart into scattered bodies looking for the wall" (Recover). Critical condition `infection` from bites. Flee easy: they do not follow into light.

**Consequence.** Local. The scene resolves what it opened. No durable flag is promised. Optional recognition echo: if N02 wants one, `marsh_hut`'s wall can tap in a conditional line for a survivor who cleared the stairwell; if no consumer is named, no flag is written.

**Field note.** *Plated colony; roof-slate bodies; the tapping in the wall.*

---

## Salt Colossus — `flats_mirage`, traces in `flats_bones`

**Owns:** *scale without hostility.* The only thing on the flats large enough to be mistaken for a hill, and it is walking.

**What it is.** An enormous, low-bodied migrant that crosses the salt in a straight line for days. Its back carries mineral ridges that crest above the crust like a dark reef, and it is seen only at a distance, in glare, as a shape that moves when the horizon should not. It is not looking for anyone. Its weight fractures the crust behind it into a wake of thin plates over brine and chemical slurry, and moisture condenses where it rests, so its shade and its bearing lead toward real water more often than the horizon does.

**Habitat and need.** The Salt Flats, migrating. Water. It is never fought, never has a health bar, and never comes closer than the horizon in any scene.

**Warnings, in order.** The blue line on the horizon moves *against* the survivor's own movement rather than with it. Cloth strips on the marker stakes are damp in air too dry to allow it. The crust ahead shows long, parallel fractures too regular for weather. And in `flats_bones`: the wired circle of bones around one boot print marks where its wake left thin crust over a pit — the darker, smoother salt inside the ring is the wake itself.

**The decision.** `flats_mirage` is repeatable, so every sighting is a different point on the migration and the prose must not remember an earlier one. Choice 0 *Trust the apparent landmark* becomes following the Colossus's bearing to the water it leads to (existing reward `clean_water`, existing fatigue on the gamble); choice 1 *Check the sun and your tracks* becomes reading its wake and keeping off it. No third choice: a giant offers navigation, not combat.

**Consequence.** Knowledge, not a flag, unless N02 names the consumer: a survivor who has read the wake could receive a conditional line in `flats_bones` choice 0 that recognizes the darker crust before the check. `read_bone_warning` already exists there with no consumer; N02 may retire it or give it one.

**Distinct from** the Salt Crown, which is a lethal predator of the Rust-Sea with pale limbs and a warm hollow. The Colossus is never lethal by intent; only its wake is.

---

## Reed Widow — `marsh_lights`

**Owns:** *the ground you trust is carrying you somewhere.* Apparent safe footing that moves against the current.

**What it is.** An amphibious predator that carries a raft of living reeds on its back and a clutch of luminous eggs beneath it. Seen from the bank, the raft reads as firm ground. The eggs pulse in a repeating sequence — three close, one apart, then dark — which is the "lights beneath the water" the scene already describes. It drifts its raft across the drowned road to the deeper reeds and waits for weight.

**Habitat and need.** Flooded service roads and drainage cuts. Warmth and stillness for the clutch; it strikes anything that steps onto the raft.

**Warnings, in order.** The lights are too regular for animals and too mobile for lamps. The "bank" ahead moves *against* the current while the reeds around it move with it. A single boot, laces still tied, rests on the raft's edge.

**The decision.** Choice 0 *Follow the pattern* keeps its intention and outcomes: the civil-defense cache is real and the Widow hunts the beacon route, so the wits gamble still reaches `purifier_ampoule` and `clean_water` between pulses or wanders into contaminated silt. Choice 1 *Stay on visible ground* keeps to roots. **Appended choice 2: *Clear the nesting pool.*** Creature combat, for a concrete purpose: the pool sits across the drainage cut. Victory reaches the cache dry and leaves the cut passable; N02 sets the reward so it is not strictly better than choice 0.

**Combat sketch.** Threat mid; HP near Feral Dogs; damage between Leeches and Dogs. Sequence Brace, Strike, Heavy, Recover: the raft sinks and goes still, then the body lunges from beneath it, then it drags, then it surfaces to reposition. Tells: "The raft settles lower and the lights go out under it" (Brace); "Reeds part where nothing showed a moment ago" (Strike); "It takes hold and pulls toward deep water; the whole raft tilts" (Heavy, dodge it); "It surfaces to breathe, eggs exposed along its back" (Recover). Critical condition `sprain`, from the drag. Flee risky: it is faster in water than a person on roots.

**Consequence.** Durable, with a named consumer candidate: `widow_pool_cleared`. In `lr_voice_in_reeds` choice 0, Talia is waist-deep in a drainage cut while "something noses the mud below." If the pool was cleared, a conditional passage notes the cut is empty and the rescue's check is one step easier; if not, the passage stands as written. Both scenes are region 2 and can occur in either order, so the consumer must read the flag only when present and never imply the Widow was met if it was not. N02 confirms the check delta; N04 implements the conditional passage.

**Field note.** *Reed raft over water; pale eggs in sequence; one laced boot.*

---

## Kilnback — `industrial_tank`

**Owns:** *the machine's rhythm is a body's.* Knocking that follows pressure because something is living on the pressure.

**What it is.** A massive heat-seeking mutant that wedges itself into the cooling jackets of industrial machinery and stacks insulating plates around its body to hold the warmth. It moves with the pressure cycle: as the tank heats, it shifts and its plates knock the wall; as pressure bleeds, it settles. The three knocks and the exact pause are its breathing.

**Habitat and need.** The processing floor's sealed tank. Heat. It leaves machinery only when the heat does.

**Warnings, in order.** The knocks repeat with an *exact* pause, matching the pressure needle, not any human rhythm. Condensation on the hatch is warm, not cold. Scorch-rings on the tank's outer plates show where something hotter than water has been resting against them.

**The decision.** Choice 0 *Open the inspection hatch* keeps its intention: the dehydrated engineer is real and trapped in the tank's dry chamber because the Kilnback holds the service side; success still yields the `field_scanner`. Choice 1 *Listen for a pattern* keeps its intention and becomes the knowledge route: the survivor works out that the knocks follow heat and pressure, drains the line, and takes the water — and now knows the Kilnback's rhythm. **Appended choice 2: *Clear the cooling jacket.*** Heavy combat. Intention: reach both the engineer and the water without the pressure gamble, at the cost of fighting the largest thing in the region. N02 sets the reward.

**Combat sketch.** Threat high; HP the largest of the four, below the Warden; damage high, slow. Sequence Brace, Heavy, Strike, Recover: plates close, then the body slams, then a plate edge strikes, then it sags to re-seat the plates. Tells: "It draws the plates in until nothing shows but scorched metal" (Brace); "The whole mass rocks back against the tank wall, gathering" (Heavy, dodge it); "One plate edge sweeps out at knee height" (Strike); "It sags, plates loosening, heat pouring off it" (Recover). Critical condition `burned`, from contact with the plates. Flee favorable: it will not leave the heat.

**Consequence.** Durable, with the consumer the plan names: `kilnback_rhythm_known`, written by choice 1 success and by choice 2 victory. Consumer: `lr_warm_windows` choice 1 *Restore the second heater* gets a conditional passage and an easier check for a survivor who learned the heat cycle; `lr_names_on_smoke` choice 0 may echo it. The existing `rescued_engineer` flag from choice 0 has no consumer; N02 gives it one (the engineer among `rail_survivors` is the obvious candidate) or retires it.

**Field note.** *Stacked plates around a heat; scorch-rings on the tank; three knocks and a pause.*

---

## Cinder Giant — `glass_shadow`

**Owns:** *the shadow precedes the body.* A shape seen on the glass before anything can be seen casting it.

**What it is.** A towering, vaguely humanoid, irradiated being that walks the ravines of the Glass Wastes shedding pale dust. The dust cloud drifts ahead of it in the glare and lays a moving shadow across the ground long before the figure is visible. It is indifferent. It does not notice people; its exposure is what kills, and its passage is marked by boot prints that simply stop.

**Habitat and need.** The shallow ravines where reflected heat hides the ground. Nothing the survivor can offer or take. No combat, no portrait, no health bar.

**Warnings, in order.** The burned silhouette on the wall is old; the pale dust on the survivor's sleeve is fresh. The meter climbs faster than footsteps. A shadow crosses the glass ahead with nothing above it to cast it. And the way back is always visible: the survivor can withdraw at any point before the ravine.

**The decision.** Choice 0 *Search for the missing traveler* keeps its intention but changes its truth: the traveler is alive, sheltering dust-sick under the mirrored shelf where the glare hid their tracks, and success is a rescue — walking them clear of the Giant's passage — rather than only taking a pack. The existing `scout_leathers` and water become what they give in return. Choice 1 *Leave the shadow behind* stays as written. No third choice.

**Consequence.** Durable, with the consumer the plan names: `cinder_traveler_rescued`. Consumer: `rail_survivors`. The rescued traveler sits on the platform council. A conditional passage recognizes the survivor, and choice 0 *Explain why the Citadel matters* gets an easier check or a small extra reward because someone at the table can vouch for them. Fallback if the run never reaches `rail_survivors`: none is needed; the rescue is already its own reward, and the Chronicle can record it.

---

## Cable Eater — `rail_signal`

**Owns:** *the power is alive.* A severed cable that still lights a signal because something is bridging the cut.

**What it is.** A segmented creature that coils through the powered cable runs of the Underrail and feeds on current. Its body bridges gaps in cut cable, which is why a signal turns green with every visible cable severed. It sheds insulation as it moves, and the lights along a run dim and change as its body shifts the load.

**Habitat and need.** Cable trays and signal boxes of the powered lines. Current. It will defend a live run and abandon a dead one.

**Warnings, in order.** Fresh insulation on the standing water, curled like bark. Lights along the run dim in a *travelling* sequence, one after another, as something moves the load. A cable tray bowed downward under weight.

**The decision.** Choice 0 *Follow the powered line* keeps its intention: the Citadel's maintenance marks are real and recently cleaned, and the power that lights them is the creature's, so following still earns the shortest tunnel or wakes the restraint frame. Choice 1 *Cut power before passing* keeps its intention and its established cost: grounding the charge blinds the creature and the survivor passes in honest darkness; the capacitor shock on failure is the creature's stored current. **Appended choice 2: *Clear the cable run.*** Creature combat. Intention: pass with the line dark and take what it was carrying; N02 sets the reward (`scrap_parts` is the honest one — copper and connectors).

**Combat sketch.** Threat mid-high; HP between the Widow and the Kilnback; damage high on Heavy. Sequence Charge, Strike, Sweep, Brace, Recover: it gathers current, strikes with a segment, lashes across the tray, coils tight around a live line, then loosens to move. Tells: "The lights along the run brighten all at once; it is drawing the load" (Charge, no damage); "A segment snaps out of the tray toward your hands" (Strike); "It lashes the length of the tray at knee height" (Sweep, block it); "It coils around the live cable and goes still" (Brace); "It uncoils to find the next span, segments dragging" (Recover). Critical condition `burned`, from electrical contact. Flee risky: it is faster along the run than a person on wet tile.

**Consequence.** Durable, with a consumer candidate: `cable_run_cleared` or the existing `citadel_signal` from choice 0, which today has no consumer. Consumer candidates in region 5: `rail_switch` or `rail_door` (a powered obstacle behaves differently on a dead run), or `bunker41_green_platform` (the green platform lamps). N02 names exactly one; if none fits, the consequence is local and no flag is written.

**Field note.** *Segmented body in the cable tray; shed insulation on the water; the lights dimming in sequence.*

---

## What N02 owes each creature

For every entry above, the consequence map records the immediate reward of each choice, the exact reward of the appended combat route and why it is not strictly dominant, the flag written and its single named consumer, the fallback when the consumer scene is never reached, and a replay fixture that reaches the creature and its consumer in both orders where the region allows either. Creature combat profiles are added to `data/adversaries.json` with new IDs only; no saved human adversary is ever relabelled.
