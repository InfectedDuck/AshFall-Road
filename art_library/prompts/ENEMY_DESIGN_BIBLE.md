# Ashfall Road — Enemy Design Bible

Design revision: **enemy-design-v1.2**. Companion to `enemy-portrait-v4.2` in `docs/ENEMY_PORTRAIT_PROMPTS_V4.md`.

That prompt pack provides complete generation instructions. This document records each faction's design thesis and signature detail. The v4.2 prompt pack is authoritative for exact casting, ages, facial features, hair, wardrobe, anatomy, mechanical construction, and the technical contract (64×64 logical grid, 16–20 colors, flat `#20272B` background, opaque, no scenery). The cast summaries below match that revision; do not restore older faces from the v3.0, v4.0, or v4.1 packs.

All human characters are adults, ages 23–64. Several women are deliberately beautiful in different ways, and every one still shows the apocalypse on her face and hair. Attractive bone structure and expressive eyes remain recognizable through assigned dirt, old healed scars, rough skin, fatigue, greasy roots, and uneven self-cut or repeatedly tied hair. Preserve natural asymmetry, age, complexion, and fully covered practical clothing. The prompt pack pairs every CAST line with a numbered WEAR AND EXPRESSION line; both are part of the identity. Use one dominant wear mark and a smaller secondary cue in broad pixel clusters, not a layer of random spots.

Expressions vary through brows, lids, mouth tension, cheek lift, and shoulders, with fixed gaze targets. They include defiance, concealed alarm, impatient resignation, skeptical disapproval, curiosity, wry amusement, private grief, and controlled fear. A mask stays on while the eyes and posture do the work. Maintained Citadel equipment coexists with sweaty, pressure-marked faces and mussed hair; it does not imply fresh skin.

Read this before writing or revising any enemy prompt.

---

## 1. The register

Ashfall Road enemies are **bold and adult**. That means:

- **Adult** = consequence, competence, and fatigue. These are people and animals who have survived something and are now doing the arithmetic on you. It does not mean edgy, and it does not mean gore.
- **Bold** = one idea per portrait, executed at a size you can read at 50 pixels. A portrait that needs a paragraph to explain itself has failed.
- **Not cartoonish** = no exaggerated proportions, no expression pushed past what a real face does, no comic-book scowl, no mascot readability. The approved `enemy_dogs` and `enemy_stalker` sources are the calibration: heavy painterly clusters, believable anatomy, restrained value range.
- **Not AI-ish** = see §3. This is the failure mode that will actually happen, so it gets its own section.

### The no-gore rule is a design constraint, not a censorship note

Nothing in this game shows blood in motion, open wounds, exposed organs, corpses, or cruelty in progress. This is not a limit on how frightening the roster can be — it is the reason the roster has to be frightening in more interesting ways. Fear here comes from five levers, in rough order of usefulness:

1. **Misdirected attention.** The thing is not looking at you, or is looking at the wrong part of you. A creature studying your hands is worse than a creature roaring at your face.
2. **Wrong stillness.** Everything in a group is moving except one — or nothing is moving at all, in a shape that should be.
3. **Implication.** One object in frame proves an event you never see. A leech that has already fed. A collar with no dog left in it.
4. **Crop and scale.** Something too close, too wide for the frame, or cut off in a way that says the frame is the problem, not the subject.
5. **Coherent wrongness.** The anatomy holds together perfectly and is still wrong. Sealed eyes on an otherwise credible skull beat an extra mouth every time.

Note what is *not* on that list: teeth, blood, screaming, spikes, skulls.

---

## 2. The roster's unique axis

The thirteen portraits must not blur together in the gallery. Each owns exactly one idea that no other portrait may use as its primary read.

| ID | Faction | Owns this idea | Emotional read |
| --- | --- | --- | --- |
| `enemy_bandits` | Road Bandits | Salvaged civilian life worn as gear | Recognition — they used to be you |
| `enemy_dogs` | Feral Dogs | Human structure surviving inside animals | Betrayal |
| `enemy_toll` | Toll Gang | Procedure as violence | Boredom, which is worse than malice |
| `enemy_leeches` | Marsh Leeches | Directed mass; one already fed | Arithmetic |
| `enemy_raiders` | Bog Raiders | Faces built out of the landscape | Camouflage that watched you first |
| `enemy_drones` | Security Drones | Obedience outliving the institution | Pity, then alarm |
| `enemy_scavs` | Vault Scavengers | Calm competence, weapons at rest | Being outclassed |
| `enemy_cult` | Glass Cult | Injury reframed as rank | Uncanny |
| `enemy_hunters` | Tunnel Hunters | Sound discipline, total wrapping | Being processed |
| `enemy_stalker` | Ash Stalker | Copying a human, caught mid-word | Dread |
| `enemy_guard` | Citadel Guard | Maintained equipment; clean is frightening | Class fury |
| `enemy_warden` | Warden Machine | A door that grew armor | Insignificance |
| `enemy_crows` | Mutant Crows | They collect what shines | Personal theft |

No two portraits may share a dominant silhouette or head arrangement. Cast sizes may repeat, but the composition and identities must distinguish those groups. The prompt pack's fixed casting and composition lines are authoritative.

---

## 3. Anti-AI checklist

Generated images fail in recognizable ways. Reject any candidate showing these, and write against them in every prompt.

**Face failures**
- Every person facing camera at the same head tilt.
- Cloned facial geometry with a swapped hairstyle. Test: cover the hair. If two people become the same person, reject.
- Interchangeable glamour-template faces. Attractive people still have individual bone structure, natural asymmetry, age lines, healed marks, and dirt in the exact places assigned by their work and environment. Do not clean or rejuvenate a face to make it beautiful.
- Identical cheek scars, identical mud spots, or hair that has been professionally groomed. Hair should keep its identity while looking self-maintained, sweat-clumped, frayed, or roughly cut. Covered hair stays covered; hunters trap short broken tufts inside their wraps.
- The same scowl or vacant stare on everyone. Apply each character's specific brow, lid, lip, and shoulder cues without changing the assigned gaze target.
- Expressions at maximum. Nobody in this roster snarls at full intensity except the animals ranked to.
- Immaculate teeth — or human teeth showing at all.

**Gear failures**
- Wear applied as random scratches and smudges. Wear has causes: chafe where a strap crosses a shoulder, polish where a hand grips, dirt in the seam and not on the face of the panel, one repair patch in a different material because that is what was available.
- Everyone in matching outfits. Exactly one faction may match (`enemy_guard`), and that is its entire point.
- Weapon clutter. Two separate weapon/tool props maximum per portrait; attached masks, straps, lenses, collars, repair patches, and machine components are worn or built-in details.
- Fantasy-armory language: spikes, ornamental chains, skull motifs, pauldrons, tribal warpaint, tattered heroic capes. Banned outright.
- Gas masks as shorthand for "post-apocalyptic". The raiders' sculptural heron mask is hand-built reed and tar-cloth, never military surplus. Other factions may use the practical cloth coverings assigned in their prompts without copying that mask silhouette.

**Rendering failures**
- Smooth gradients, glow bloom, vignette, ambient haze, lens effects.
- Mixed apparent pixel size — a face drawn at one resolution and a buckle at four times finer.
- Faux pixel noise: scattered single pixels standing in for texture instead of deliberate clusters.
- Anti-aliased edges, background halos, cast shadows on the flat field.

**Composition failures**
- The three-person centered triangle. It will keep coming back. Kill it every time.
- Everything equally sharp, equally sized, equally spaced.
- A subject centered with symmetric negative space on both sides.

---

## 4. Shared material language

Everything in this world was made for another purpose. Nothing was manufactured for war after the collapse.

- **Cloth**: canvas, oilskin, quilted moving blanket, upholstery, tarp. Colors faded three steps past original.
- **Metal**: sheet steel, road sign, tire rubber, rebar, conduit. Fasteners are bolts and wire, not welds.
- **Repair**: visible, asymmetric, in a different material than the thing it repairs. One good repair per figure tells more story than ten scratches.
- **Palette discipline**: three large value groups — near-black structure, mid-tone mass, one light. Regional identity enters only as a single rim-light color on one side.

---

## 5. The thirteen

Each entry gives the design thesis, the silhouette, the one memorable detail, cast notes, materials, palette, how it frightens without gore, its specific bans, and its thumbnail read.

---

### `enemy_bandits` — Road Bandits
**Shattered Outskirts · Threat 12 · 4 people**

**Thesis.** They wear the wardrobe of an ordinary town. Not raider gear — the salvage of civilian life, worn because it fits and holds heat. The threat is recognition: six months ago these were neighbors, and the formation is practiced because they have done this often enough to get good at it.

**Silhouette.** Broken diagonal. One large close leader low-center; three unequal heads stepping back and up. Ragged outline from mismatched collars, no two shoulder heights alike.

**The one detail.** The leader wears a child's backpack straps over her shoulders — narrow, padded, patterned. She uses them because they are the right size and do not slip. Nobody in frame reacts to them. That is the whole faction in one object.

**Cast.** Four adults. Beautiful 27-year-old fair woman leader: copper-red wavy bob, green eyes, diamond face, high cheekbones, slightly crooked nose bridge, mustard marching-band jacket, charcoal knit collar, patterned cream backpack straps. A 41-year-old olive-skinned woman in strict profile: square jaw, dark short waves under a plum-brown flat cap, slate delivery coat, dull reflective sash. A 23-year-old deep-brown-skinned man: round face, cropped black coils, frightened sideward eyes, burgundy mouth cloth, blue-gray quilted vest. A 36-year-old East Asian man: long oblong face, hollow cheeks, broad straight nose, blunt black fringe and short ponytail, roughly clipped black chin goatee, olive vest, tan neck scarf, calm archer's gaze toward your supplies. Only the leader looks at you.

**Wear and expression.** Red-haired leader: healed mouth-corner split, dusty cheek with a wiped track, chapped lip, greasy wind-tangled bob, weary defiance. Cap-wearing spotter: dusty cap line, temple finger smear, crushed waves, irritated doubt. Recruit: faded cheek abrasion mark, sweat-cleared temple stripe, flattened coils, concealed alarm. Archer: cookfire soot in cheek and rough goatee, crooked fringe and frayed tie, absorbed calculation. Keep eyes and individual facial structure visible through broad marks.

**Materials.** A crossing guard's reflective sash worn as a bandolier, its reflectivity long dead. A marching-band jacket with the braid cut off. A quilted moving-blanket vest. Warm clothing first, armor second.

**Palette.** Charcoal slate, dusty mustard ochre, cream parchment, worn brown, muted blue-gray, plum-burgundy, olive, copper-red hair, restrained rust-red Outskirts rim light. Share ramps while retaining the four complexions.

**Fear without gore.** Split attention — four people, three focal points, none of them dramatic. They are calm because this is a job.

**Never.** Skull paint. Mohawks. Spiked shoulders. Matching bandanas. Anyone grinning. More than two weapons in frame.

**Thumbnail read.** One close leader plus three unequal supporting heads on a broken diagonal.

---

### `enemy_dogs` — Feral Dogs
**Shattered Outskirts · Threat 11 · 4 dogs**

**Thesis.** Human structure survived inside the pack. They still wear a collar, they still know what a raised hand means, and they kept the parts of domestication that make them efficient at hunting people. The only enemy whose horror is betrayal.

**Silhouette.** Forward wedge, heads at four heights, muzzles and ears never touching. Shoulders only — never full bodies or tangled legs.

**The one detail.** The lead dog is not snarling. The three behind her are, at three different intensities, and she watches with her mouth closed. In a portrait where everything is displaying, the calm one is the one making the decision.

**Cast.** Lean gray shepherd-mix leader, old muzzle scars. Heavy tan mastiff-mix, one folded ear. Pale narrow sighthound-mix, cracked collar, ears pinned flat. Small black-and-rust cattle-dog mix, mismatched ears, head low.

**Materials.** One collar only — cracked leather, the tag worn blank by years of chewing. Do not collar all four; the single collar is what makes this an abandoned pack rather than a wolf pack.

**Palette.** Charcoal, weathered gray, dry tan, bone highlights, muted brown, rust coat markings, contaminated moss green and yellow-olive corruption, dusty-ochre rim light. In the v4.2 regeneration brief, rust belongs to fur and leather; no blood coloration. Limited edits preserve the existing approved image unless a change is requested.

**Fear without gore.** Coordination — four different builds moving as one shape, and the leader's stillness inside all that noise.

**Never.** Wolf proportions or fantasy scale. Glowing eyes. Fresh or dripping blood. Open wounds. Collars on every dog. Friendly or comic expressions.

**Thumbnail read.** Four distinct dog silhouettes; the gray leader unmistakable at the front.

---

### `enemy_toll` — Toll Gang
**Salt Flats · Threat 13 · 3 people**

**Thesis.** Procedure as violence. They wear faded road-maintenance clothing and have decided it is a uniform, which has convinced them that what they do is administration. They are not angry with you. They will do this again tomorrow, to someone else, in the same order.

**Silhouette.** Asymmetrical stepped lineup — tallest at left, dominant at center-right, smallest low at far right. Deliberately unbalanced, never a triangle.

**The one detail.** The spring clip from a clipboard is pinned to the leader's coat like a decoration. It holds nothing. It is a rank insignia she invented.

**Cast.** A 56-year-old olive-skinned woman leader: long severe face, aquiline nose, gray-green eyes, silver-gray low knot, rust-orange road coat, bone wool collar. A 42-year-old pale bald man: broad square head, flattened nose, thick neck, impatient expression, ochre work overcoat over a brown quilted jacket, resting vertical club. A beautiful 25-year-old medium-brown-skinned woman lookout: small heart-shaped face, hazel eyes, short mahogany curls, goggles pushed up, bone-and-brown face scarf, brown hooded jacket, rust-orange shoulder cape, visibly exhausted. These specifics apply to regeneration; a limited edit retains the actual identities in the attached existing portrait.

**Wear and expression.** Leader: leathery sun-spotted skin, old chin scar, salt in nose creases, uneven greasy silver knot, dismissive authority. Enforcer: sunburned scalp plane, dusty sweat band, rough nose, skewed mouth and bunched cheek showing impatience. Lookout: healed outer-brow notch, dusty cheek, cleaner crescent under lifted goggles, tangled strap-flattened mahogany curls, exhausted resignation. Her beauty remains in her heart-shaped face and hazel eyes, not a fresh complexion.

**Expression note.** The work is routine, but the reactions differ: the leader's lowered eyelid and raised chin convey dismissive assessment; the enforcer's bunched cheek and skewed mouth show impatient irritation; the lookout's heavy lids and worried inner brow show exhausted resignation. Nobody enjoys this. Do not give all three identical bored eyes.

**Palette.** Near-black charcoal, bone parchment, faded safety-orange, ochre, worn brown, Salt Flats rust-and-bone rim light.

**Fear without gore.** The revolver in the leader's hand points at the ground. Nothing has been raised. The transaction has already started and you are the only person in it who is not calm.

**Never.** Military uniforms or insignia. Legible lettering. Crazed or gleeful expressions. Weapons raised. A fourth person.

**Thumbnail read.** Three unequal identities; the leader's authority instant.

---

### `enemy_leeches` — Marsh Leeches
**Drowned Marches · Threat 12 · 8–12 creatures**

**Thesis.** Not a swarm — a **directed mass**. Every body is oriented toward the same source of warmth, the way iron filings orient in a field. It should feel less like chaos and more like a decision being made by something with no head.

**Silhouette.** Lopsided vortex filling ~85% of the square; dominant sucker off-center upper-left; bodies spiralling clockwise toward lower-right. Three or four sharp negative-space pockets — the gaps are what stop it becoming a knot.

**The one detail.** One leech at the frame edge has already fed: distended, paler, slower, curling away from the mass. It proves a victim you never see. That single body does more horror work than the other eleven combined, and it contains no blood, no wound, and no anatomy that is not a leech.

**Cast.** Vary thickness, length, curl, highlight, direction. Several disappear behind the mass so the count reads as *more than you can count*. Every visible body must read as a real parasite — segmented, blunt, wet — not a snake, finger, or tentacle.

**Palette.** Near-black charcoal, deep teal, mud brown, contaminated moss green, gray-violet shadow, muted parchment highlights. Two or three blocky wet highlights total; no smooth tubular shading.

**Fear without gore.** Arithmetic. The fed one tells you the count was higher before you arrived.

**Never.** A neat ring. Identical repeated bodies. Snakes, fingers, tentacles. Eyes. Teeth-filled fantasy mouths. Any victim anatomy, water, bubbles, or scenery.

**Thumbnail read.** An overwhelming parasite mass with one dominant sucker — never a single knot or a hand.

---

### `enemy_raiders` — Bog Raiders
**Drowned Marches · Threat 15 · 2 people**

**Thesis.** Their faces are built out of the landscape. Reed, cloth, and tar shaped into long triangular forms so that at distance, across the water, they read as wading birds. By the time the silhouette resolves as a person, they have been watching you for some time.

**Silhouette.** Back-to-back diagonal duo, heads pointing opposite directions, forming one hooked shape. No pyramid, no third person.

**The one detail.** The unmasked raider's face is completely ordinary — a tired 32-year-old man with a broad rounded-square face and a skeptical sideways glance. One plain human face beside one heron-shaped mask is the entire design. Neither half works alone.

**Cast.** Lower-left: stocky 32-year-old warm-brown-skinned man, short chestnut curls, short uneven beard, broad ordinary face, cracked cork ear guard, waterlogged teal coat over a tan sweater, brown oilskin collar, cream shoulder repair, facing left. Upper-right: taller 29-year-old light-olive-skinned woman, long oval face, gray-green eye, dark-auburn braid, brown oilskin capelet over a charcoal high-necked jacket, tan rope harness, long ochre reed-and-tar heron mask facing right. Her striking features stay mostly covered; the eye, braid, and mask provide the read.

**Wear and expression.** Boatman: dried silt beneath the jaw, a gray-green splash in his beard, flattened damp curls, rough wind-worn cheeks, a deadpan skeptical glance. Scout: small healed temple scrape at the mask binding, moss-green silt on the exposed cheek edge, dirty sweat track, uneven damp auburn braid with short stuck-down temple locks; one tense lifted brow and narrowed eye show sudden attention. Her graceful features remain partly hidden and visibly worn.

**Materials.** The mask is a *built object* — hand-lashed reed and tar-stiffened cloth with visible binding at the joints. It must never look like military surplus.

**Palette.** Charcoal slate, wet brown, tan canvas, bone, deep teal, chestnut and dark-auburn hair, distinct brown and light-olive skin, contaminated-moss Marches rim light. Damp shown as a few block shapes, never gloss.

**Fear without gore.** Asymmetry of intent — one looks at you, one looks at the far bank. They have already agreed on the plan.

**Never.** Gas masks. Military insignia. A third raider. Boats, environmental reeds, rain, or marsh scenery. Matching faces. A centered heroic pose. Reed in the constructed mask is required.

**Thumbnail read.** One broad unmasked face and one tall triangular mask, back to back.

---

### `enemy_drones` — Security Drones
**Hollow Industrial Zone · Threat 16 · 5 machines**

**Thesis.** Obedience outliving the institution that issued it. These machines are still executing a courtesy escort pattern from a corporate manual — a formation designed to politely walk visitors off the property. The manual is forty years dead. The formation is not.

**Silhouette.** Loose mechanical orbit, never a triangle. Large dented patrol drone below-center; four smaller machines at unequal distances high-left, high-right, mid-right, low-left, each tilted differently, one cropping into an edge.

**The one detail.** The flat alarm disk is a burnt dead shell, still carried in its formation slot on the utility drone's broad attached fork. Its sensor and beacon are dark. Nobody explains why the dead unit still has a place. The formation is simply still the right shape.

**Cast.** Soot-gray rectangular patrol unit below-center, one dull red sensor, twin lift fans, cream top repair. Narrow oxidized-steel inspection drone high-left, vertical lens looking past the viewer, rust band. Round ochre utility drone high-right, three cage ribs and an attached carrying fork. Dead charcoal alarm disk mid-right, broken beacon and dark sensor, supported by that fork; hazard banding on this disk only. Dirty-cream three-pronged emitter low-left, one shortened prong. Four working machines and one dead hull, all bolted in the same obsolete manufacturing language.

**Materials.** A cracked speaker grille on the patrol unit. A small brass plaque scraped deliberately blank — someone removed the name. Abstract two-color hazard banding on exactly one panel: no letters, no symbols.

**Palette.** Charcoal, soot gray, oxidized steel, dirty parchment, rust orange, one muted warning-red sensor, Industrial rust rim light.

**Fear without gore.** One small drone rotates slowly, sensor sweeping, never quite finding you. Everything else has locked on. Broken attention inside a working system.

**Never.** Humanoid robots. Sleek science fiction. Readable text, logos, or numbers. Sparks, smoke, glow bloom. A tidy formation. A sixth drone.

**Thumbnail read.** One large failing patrol unit, four smaller orbiting shapes, the red sensor unmistakable.

---

### `enemy_scavs` — Vault Scavengers
**Hollow Industrial Zone · Threat 15 · 4 people**

**Thesis.** The most dangerous humans in the roster because they are the calmest. A shift crew defending a claim: roles assigned, sightlines covered, tools held at rest. Their threat is competence, and the portrait must make you feel outclassed rather than threatened.

**Silhouette.** Uneven horizontal work crew. Two largest heads at different heights, one leaning in from the far left, one smaller and higher at the far right. Visible gaps between every jaw and shoulder — the only crowded human portrait that must feel *organized*.

**The one detail.** Nothing in frame is aimed at anything. The rifle lies low across the bottom; the axe head sits at the far-left edge. They have already decided how this goes and are waiting for you to catch up.

**Cast.** A 44-year-old medium-brown-skinned man claimant: square face, crooked nose, receding short black hair, black stubble, gray reinforced high-collared jacket. A striking 55-year-old fair woman electrician: broad hexagonal face, sturdy jaw, short bent nose, heavy dark brows, pale-blue eyes, deep age lines and sun spots, rough charcoal-brown crop with a thick silver forelock, plum high-collared coverall, tan rubberized apron, steel-blue tarp shoulder cover, hearing protectors around the neck. A 24-year-old East Asian man lookout: inverted-triangle face, clipped sides and forward-swept black top, raised work lens, olive zip-neck pullover. A beautiful 29-year-old deep-brown-skinned woman mechanic: round full face, warm amber-brown eyes, lopsided high black coiled bun with escaped temple tufts, closed-lip wry half-smile, blue-gray jacket, rubbed cream shearling-lined collar, brown glove. Distinct muted sleeve-tape colors identify roles. The full prompts assign each repair and gaze.

**Wear and expression.** Claimant: stubble grime and wiped cheek track, greasy cap-flattened hair, patient calculation. Electrician: broad old matte burn scar along the left jaw, opposite-cheek soot thumbprint, dirty rough silver forelock, deep age lines, skeptical disapproval in mismatched brow and mouth tension. Lookout: old lens pressure mark, dusty hairline, clumped short top, alert curiosity. Mechanic: diagonal cheek grease wipe, a small old heat scar on the opposite cheek, lopsided bun and dusty escaped coils, wry private amusement beneath heavy lids. Competence survives alongside grime.

**Materials.** Colored tape on sleeves marking roles — the only organizational marking in the roster that is not a uniform. Hearing protection worn around a neck, not on ears. Repair patches placed exactly where a strap wears through.

**Palette.** Charcoal, soot gray, tan canvas, steel blue-gray, dusty ochre, cream, faded plum, olive, silver hair, Industrial rust rim light. Reuse ramps for tape and four distinct skin values.

**Fear without gore.** The mechanic's tired half-smile. Someone in this group finds you slightly funny.

**Never.** Crazed expressions. Matching uniforms or military insignia. Extra guns. A fifth person. Anything raised or aimed. Warehouse scenery or crates.

**Thumbnail read.** Four different heads in an uneven crew line; the square-faced claimant dominant.

---

### `enemy_cult` — Glass Cult
**Glass Wastes · Threat 17 · 5 people**

**Thesis.** They have reframed injury as rank. Healed radiation scarring on the cheekbones is deliberately left uncovered, the way a soldier leaves a medal on the outside of a coat — the more damage visible, the further along the pilgrimage. Everything else about them is wrapped. The elder has traveled longest and shows the most cheek skin; the dominant veiled guide directs the group but is not its most scarred member.

**Silhouette.** A crescent, not a triangle. Veiled leader slightly left of centre and largest; two followers higher behind, two lower at the outer edges; a curved wall of faces at uneven spacing.

**The one detail.** Five people, five eye lines, none of them aimed at you. Nobody acknowledges the viewer or visibly coordinates with a partner. All five sustain this collective refusal, making them read as uncanny rather than openly hostile.

**Cast.** Five adults. The 31-year-old warm-umber-skinned woman guide has an oval head, amber-brown eyes, hidden black curls, a slanted mirrored-film veil, ash headwrap, and dusty-violet neck wrap; gaze upper-left. The 64-year-old deep-brown-skinned male elder has a broad round skull, sparse silver temple hair, exposed healed cheeks, low ochre hood, and brown blanket coat; gaze down-left. A pale 25-year-old gaunt man has shaved brows, a strawberry-blond crop wedge, bone hood, and sand shoulder wrap; gaze upward-right. A tan 38-year-old round-faced woman has chestnut waves, a violet hood, ash quilted wrap, and a cracked right-cheek guard; gaze right. An olive-skinned 47-year-old narrow-rectangular-faced woman has fully hidden black hair, diagonal brown face wraps, an ochre collar, and one hazel eye; gaze down-left toward the elder. Hidden hair and facial features must remain concealed.

**Wear and expression.** Guide: ash and rubbed pressure skin around the eye opening, salt-stiff wrap over concealed matted curls, inward certainty. Elder: dusty healed cheek scars, sun spots, clumped sparse silver hair, private grief. Ascetic: wind-reddened nose, hood-rim dust, uneven salty crop, wide-eyed conviction. Cheek-guard woman: sand beneath strap, existing healed cheek mark, tangled ash-streaked temple curl, worried doubt. Wrapped follower: dirty exposed temple and sweat-darkened bindings, hidden untidy hair, guarded suspicion in her single visible eye. All remain still and refuse the viewer's gaze.

**Materials.** Road cloth — practical, mismatched, layered against sun rather than ceremony. The veil film is salvaged panel material, dulled and scratched, reflecting nothing readable. Never ornate robes.

**Palette.** Near-black charcoal, ash cloth, muted parchment, dusty brown, restrained violet, one cold pale highlight. A few stepped glass highlights, no smooth reflections.

**Fear without gore.** Stillness plus refusal. One broad fused-glass blade lies flat along the bottom, held rather than raised. Nobody is threatening; everybody has already agreed.

**Never.** Runes, glowing magic, crowns, ornate fantasy robes. Radiation symbols. Open sores or wet burns — the scarring is old, matte, and healed. Bright aura. A sixth pilgrim.

**Thumbnail read.** An uncanny five-person crescent with one reflective-veiled leader — never a generic three-person squad.

---

### `enemy_hunters` — Tunnel Hunters
**The Underrail · Threat 16 · 2 people**

**Thesis.** Built entirely around sound discipline. Buckles taped, sleeves bound, hair bound, pockets stitched shut. No metal shows anywhere in the portrait except one knife edge. They have organized their whole appearance around not being heard, which tells you exactly how they hunt.

**Silhouette.** Tight vertical duo — one hooked column with a deep negative-space notch between the two faces. Never horizontal, never a squad.

**The one detail.** The male signaler's hand is raised in a flat stop signal — a silent order aimed at his female partner, not at you. She looks up toward his hand. You are being *processed*.

**Cast.** High-left: a 43-year-old deep-brown-skinned man, broad diamond face, clean-shaven, shaved temples, frayed black locs bound at the nape, clouded left eye, dark-brown right eye watching left, green residue at the right jaw, heavy teal hood pushed back, gray quilted high-necked jacket, raised flat hand. Low-right: a beautiful 26-year-old light-beige-skinned woman, long oblong face with a softly squared jaw, gray-blue eyes, dirty roughly bound ash-blonde braid forming a pale crescent over the ear, two dull olive-green streaks across the exposed left cheekbone, a healed outer-right-brow notch, gray lower-face mask, steel-blue wool shoulder cape over a charcoal high collar, gaze up toward his hand. Both wear completely covered, silent civilian layers; short frayed hair stays trapped inside the bindings.

**Wear and expression.** His right jaw has a broken dull moss-green stain from brushing a damp tunnel wall; hood-edge charcoal dust and frayed bound locs reinforce wear. He holds sudden alarm tightly in a lowered brow, narrowed working eye, and rigid stop hand. Her two matte olive-green left-cheek streaks were transferred by a dirty glove after contact with an algae-stained wall; add the small healed outer-right-brow notch, dusty mask edge, sweaty nose track, greasy braid roots, and trapped broken tufts. Her pinched inner brows and forward shoulders show reluctant determination toward his hand. Green is required surface grime, never glowing fungus, makeup, green skin, or a growth.

**Materials.** Patched improvised civilian tunnel gear, never matching tactical kit. Tape over every hard fastening. One closed shuttered lamp clipped high on the man's hood; cloth covers its housing and clip so only the knife edge exposes metal.

**Palette.** Near-black charcoal, deep teal, steel blue, worn gray cloth, dull olive/moss-green facial residue, dirty cool-parchment ash-blonde hair, and distinct deep-brown and light-beige skin values. Green sits on the skin as grime rather than replacing the complexion. Faces stay readable; residue, eyes, and lamp emit no light. Share ramps within 16–20 colors.

**Fear without gore.** Two people communicating with each other in front of you as if you cannot see them doing it.

**Never.** Night-vision goggles. Glowing eyes. Guns. Cloned faces. A triangular squad. Tunnel scenery, rails, fog, or backlights.

**Thumbnail read.** Broad high face with a green jaw mark; narrow low face with broken green cheek streaks beneath dirty bound pale hair; one raised stop hand. His contained alarm and her reluctant determination distinguish the pair.

---

### `enemy_stalker` — Ash Stalker
**The Underrail · Threat 14 · 1 creature**

**Thesis.** It copies. The small open mouth is not gasping or feeding — it is held in the shape a human mouth makes in the middle of a word, and it is holding that shape while it listens for the rest. The strongest asset in the roster; everything else calibrates to it.

**Silhouette.** Claustrophobic and off-balance. Oversized head pushed into the upper-right, nearly touching the edge; long ribbed throat entering from the lower-left; hooked hand curling inward from the lower-right, trapping a crescent of negative space around the mouth. Roughly 88% of the square. No full body, no centered symmetry.

**The one detail.** Fine radial creasing in the skin over the sealed eye ridges — the pattern skin makes where it has been opened and healed shut many times. It reads at a glance as *an eye that was closed on purpose*.

**Cast.** One creature. Narrow pale hairless skull, sealed vestigial eye ridges and no eyeballs, shallow vibration pits along the cheek, compact jaw, long flexible ribbed throat, one shoulder carried much higher than the other, one raised long-fingered hooked hand with exactly five readable fingers. Anatomy must be biologically coherent: stretched mammalian skin, credible tendons, a believable shoulder joint. Almost human enough to be disturbing.

**Asymmetry of attention.** One hand hooked and frozen mid-listen, the other relaxed and out of frame. It has not decided about you yet. It is confirming.

**Palette.** Near-black teal-charcoal, bone ash, violet-gray shadow, muted parchment, restrained steel-blue Underrail rim light. No skin pores, no airbrushing.

**Fear without gore.** Sealed eyes plus a listening posture. It navigates by something you cannot turn off.

**Never.** A second creature. Ordinary visible eyeballs. Alien-gray stereotypes. Zombie decay, vampire fangs, horns. Exposed ribs or organs. Any wound.

**Thumbnail read.** Sealed eyes, whispering mouth, ribbed throat, and inward-curling hooked hand as one frightening off-balance silhouette.

---

### `enemy_guard` — Citadel Guard
**East Citadel · Threat 18 · 3 people**

**Thesis.** The horror of the well-fed. Their gear is *maintained* — stitching intact, straps replaced, boots kept. After four regions of patched canvas and wire repairs, clean is the most frightening material in the game. This is the only faction permitted to match, because matching is the point: somebody still runs a supply chain, and it is not for you.

**Silhouette.** Disciplined diagonal echelon at three depths, never a triangle. Broad commander in the large lower-left foreground, older guard rising above her left shoulder, youngest smaller and further right.

**The one detail.** Three short hand-painted cream tally strokes on the shield edge. These are abstract crowd-control counting marks, with no readable digits, words, insignia, or flag. You are a queue position.

**Cast.** Foreground commander: a beautiful 38-year-old East Asian woman with warm-beige skin, broad oval face, firm chin, dark-brown eyes, roughly maintained jet-black jaw-length bob with uneven helmet-flattened clumps beneath an open-face olive helmet, controlled impatience toward the viewer. High-left: a 46-year-old olive-skinned man with a long rectangular face, square jaw, short rough-edged dark-brown mustache, clipped side-parted dark hair graying only at the temples, bare head, skeptical vigilance left. Far-right: a 24-year-old deep-brown-skinned man with a narrow oval face, crushed short black coils, charcoal cap, one steel-blue ear protector, suppressed fear toward the right. All wear maintained olive armor, steel-blue high collars, charcoal underlayers, and cream-edged webbing, fitted to distinct shoulder widths. Their faces carry sweat, dirt, pressure marks, and the assigned old scars.

**Wear and expression.** Commander: old narrow vertical chin scar, dusty rubbed helmet line, sweat-dark flattened bob with uneven ends, controlled impatience. Line guard: faint healed crescent beside the nostril, dusty sweat track, rough side part and mustache edge, skeptical vigilance. Young guard: cheek dust wipe, ear-protector pressure mark, cap-crushed coils, suppressed fear in raised inner brows and shoulders. Maintain their armor and straps while keeping the people visibly marked by the current shift and past survival.

**The second detail.** The youngest guard is plainly frightened and nobody in the group has noticed or cares. Fear inside a disciplined line is more unsettling than three hard faces.

**Palette.** Charcoal, cold steel blue, clean muted parchment, dull olive armor, one restrained pale Citadel rim light. Controlled clean shapes — but never sterile vector smoothness.

**Fear without gore.** Three eye lines aimed in three different directions, all of them procedural. One simplified service rifle as a dark diagonal along the lower edge; nothing raised.

**Never.** Flags, emblems, lettering. Sunglasses. Power armor or futuristic rifles. Cloned faces. Centered symmetry. Wall scenery or spotlights. A fourth guard.

**Thumbnail read.** Exactly three guards at three depths, one broad foreground commander plus two distinct supporting faces.

---

### `enemy_warden` — Warden Machine
**East Citadel · Threat 20 · 1 machine**

**Thesis.** A door that grew armor. It began as a checkpoint barrier and has spent decades accreting plate, and its hull still reads as a closed gate — wide, low, and horizontal where a monster would be tall. It is not hunting. It is *still closed*, and you are on the wrong side.

**Silhouette.** Low viewpoint, strongly asymmetric, ~90% of the square. Wide tracks pressing into both lower corners, scanner eye high-left, rotary cannon angled down-right, a narrow dark gap beneath the eye like an empty socket — while staying entirely non-humanoid.

**The one detail.** A dirty cream octagonal road sign is hammered flat and bolted to the viewer-left front, its eight-sided outline still recognizable under blank paint. Every repair on this machine was made by human hands, and all of those people are long dead. It has outlived its maintenance crew and kept their work.

**Cast.** One very wide non-humanoid machine. Newer blue-black track at viewer-left; worn chipped brown-gray track at viewer-right. Low cold-slate gate-like hull; one elevated muted-red scanner high-left. Three horizontal maintenance hatches imply compression without becoming a face. One low-right rotary cannon has a thick shroud and three dark barrel holes. Three prominent repair plates: cream octagon front-left, rusty trapezoid center, blue-gray rectangle right. Broad bolts and dents, no machinery noise.

**Misdirected attention.** The scanner points slightly away from the cannon, watching the road behind you. It is still guarding the checkpoint. You are incidental to its actual job, and it will kill you anyway.

**Palette.** Near-black charcoal, cold steel, slate blue, dirty parchment highlights, one muted red scanner, restrained clean Citadel rim light. Chunky mechanical clusters, large readable plates, no machinery noise.

**Fear without gore.** Scale and indifference. It fills the frame, it is not looking at you, and it is not a creature you could reason with even if it were.

**Never.** A second machine. Legs, a humanoid body, or a face. Sleek science fiction. Missiles or extra guns. Gate scenery, flags, text, numbers, bright bloom.

**Thumbnail read.** Isolated red eye, crushing wide tracks, mismatched armour, downward rotary cannon — immediately oppressive.

---

### `enemy_crows` — Mutant Crows
**Roaming threat · Threat 10 · 7 creatures**

**Thesis.** They collect. Crows have always taken what shines, and these ones have kept that instinct while losing their feathers, their fear, and their sense of scale. The flock is not chaotic — it is a practised hunting pattern flown by birds that have done this before and know which part of a person is worth taking.

**Silhouette.** Broken circular attack pattern, never a neat ring. Dominant crow diving diagonally from upper-left toward lower-right at about half the image; six smaller birds in an irregular clockwise arc with unequal spacing, scale, and wing angle; one wing tip cropped against an edge.

**The one detail.** The lead crow carries one dull brass key, with a square bow and short shaft, across its nearly closed beak. It came for what shines, and you are wearing some. No keyring or second object.

**Cast.** Large foreground crow: hooked charcoal beak bending slightly sideways, opaque milky left eye and dark right eye, gray-brown bare skin, storm-slate breast, angular wings with broken feather shafts, tucked talons. Six smaller crows: dusty-brown beak-first diver high-left, violet-gray edge-on banker upper-center, charcoal folded-wing dropper high-right, pale-slate vertical climber mid-right, dark raised-wing silhouette low-right, brown-gray low-spread silhouette low-left. Readable bird anatomy throughout, never bat membranes or extra fingers.

**Palette.** Near-black charcoal, storm slate, dusty brown-gray skin, muted parchment highlights, restrained violet shadow, small dusty-ochre rim light.

**Fear without gore.** Intent. A swarm that wants something specific is worse than a swarm that wants meat, and the object in the beak proves this is not the first time.

**Never.** Duplicated poses. A tidy ring. Feathers rendered as noise. Bats, insects, horns, extra eyes. Blood. Sky scenery, clouds, moon, motion blur.

**Thumbnail read.** One large diving mutant crow plus six unequal flock silhouettes — never one monster with many wings.

---

## 6. Review pass

Run this on every candidate before normalising to 64×64. It is stricter than the prompt pack's checklist because it tests design, not compliance.

**Identity**
- Can you name the faction from the silhouette alone, with the image blurred?
- Does it deliver the one idea from the §2 table, and only that idea?
- Is the §5 "one detail" actually visible at 64×64? If it disappears, it was drawn too small — enlarge it or replace it.

**Register**
- Cover the props. Do the faces still read as adults who have survived something?
- Is any expression pushed past what a real face does?
- Do distinctive hair, attractive faces, or confident posture still belong to working adults in practical, used equipment? Remove glamour staging or decorative gear that has no purpose.
- Does each attractive face still have its assigned scar or stain, skin fatigue, and hair disorder? Do not polish these away during corrections.
- Is the electrician unmistakably 55, with her strong face, rough dark crop, silver forelock, and healed jaw burn, rather than a generic white-braided elder?
- Are the hunters' green cheek/jaw marks readable, matte environmental residue, with their real skin colors visible around them?

**Anti-AI**
- Cover the hair on every human. Are any two people now the same person?
- Does every piece of wear have a cause you could name in one sentence?
- Do scars and dirt occupy different authored places on different people, with expressions that differ even when gaze direction is ignored?
- Count the weapons. More than two, cut.
- Count the eye lines. Are they all pointed at the camera? Fix at least one.

**Contract**
- Flat opaque `#20272B` in all four corners, no vignette, no halo, no cast shadow.
- One apparent pixel size across faces, cloth, and metal.
- 16–20 colors after normalisation; readable at 64×64 and 50×50, not only enlarged.
- No blood in motion, no open wounds, no exposed organs, no corpse, no victim.

**Gallery**
- Lay all approved portraits side by side. Any two sharing a dominant silhouette or head arrangement means one of them is wrong, not both.

---

## 7. Production order

Generate in this order so the roster never drifts human. After every two human factions, produce one creature or machine.

1. `enemy_stalker` — approved anchor for creature register
2. `enemy_leeches`
3. `enemy_crows`
4. `enemy_bandits`
5. `enemy_toll` — approved anchor for human register
6. `enemy_warden`
7. `enemy_raiders`
8. `enemy_scavs`
9. `enemy_drones`
10. `enemy_hunters`
11. `enemy_cult`
12. `enemy_dogs` — approved
13. `enemy_guard`

Record generator, date, prompt version, edits, and approval in `docs/ASSET_PROVENANCE.md` as each portrait lands.
