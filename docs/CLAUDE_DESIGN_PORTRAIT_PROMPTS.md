# Ashfall Road — Claude Design prompts for the nine unfinished enemy portraits

Prompt-pack revision: **claude-design-v1** (18 October 2026). Based on `enemy-portrait-v4.2` casting in [ENEMY_PORTRAIT_PROMPTS_V4.md](ENEMY_PORTRAIT_PROMPTS_V4.md), with one deliberate change to the content register:

> **Register change.** v4.2 banned all blood and wounds. This pack allows dirt, dried blood, bruises, scabs, stitched or bandaged wounds, and frightening creatures. It still forbids gore: no open flesh, exposed bone or organs, severed parts, spraying or pooling blood, corpses, or violence in progress. Update §1 of `ENEMY_DESIGN_BIBLE.md` if this becomes the permanent rule.

| Status | IDs |
| --- | --- |
| Finished — use as style anchors | `enemy_dogs`, `enemy_stalker`, `enemy_toll`, `enemy_leeches` |
| Script-drawn placeholders — replace | `enemy_crows`, `enemy_bandits`, `enemy_warden`, `enemy_drones` |
| Missing — create | `enemy_raiders`, `enemy_scavs`, `enemy_hunters`, `enemy_cult`, `enemy_guard` |

## How to use this pack

1. Start one Claude Design project for the whole set.
2. Attach the four anchors as the style reference: `assets/portraits/enemy_dogs.png`, `enemy_stalker.png`, `enemy_toll.png`, `enemy_leeches.png`. Attach the larger sources from `art_library/sources_hires/` too, if you have them.
3. Paste the **master brief** once.
4. Then paste one enemy block at a time, in the order below. Approve each portrait before you start the next.
5. Export the 64×64 PNG to `assets/portraits/<id>.png`. If you export a larger image instead, normalise it with `tools/prepare_portrait.gd` (the command is in the v4.2 pack).
6. Record the portrait in `docs/ASSET_PROVENANCE.md`.

The four placeholders look like coloured blocks because a script placed their pixels without a shading pass. Claude Design also draws with code, so the master brief makes it work like a pixel artist, in passes, and compare its work against the anchors before it shows you anything. If a portrait still looks flat after two correction rounds, take that enemy's block to an image model instead. The casting is identical either way.

---

## Master brief — paste once at the start

```text
You are the pixel artist for ASHFALL ROAD, a grim post-apocalyptic survival text RPG. I need combat portraits for enemies that match four finished portraits I have attached (enemy_dogs, enemy_stalker, enemy_toll, enemy_leeches). Those four are the style bible. Every new portrait must sit beside them in a gallery and look like the same artist painted it on the same day.

WHAT THE ATTACHED PORTRAITS DO — COPY THIS, NOT THEIR SUBJECTS
- True 64x64 pixel grid, one apparent pixel size everywhere. Faces, cloth, metal and fur all use the same pixel scale.
- 16–20 colours in total. Three big value groups: near-black structure, a mid-tone mass and one light. The light comes from one side as a single restrained coloured rim light.
- Painterly pixel clusters. Forms are built from broad stepped planes (cheekbone plane, brow plane, jaw plane, fur mass), not from outlines filled with flat colour. Each plane shades in 2–4 stepped tones.
- Selective dark outlines only where a form turns away from the light. No black outline around everything.
- Very restrained dithering. No single stray pixels standing in for texture. Every pixel cluster has a purpose.
- Believable anatomy and real proportions. Nothing cartoonish, no chibi heads, no comic scowls.
- Tight, off-balance crop at head-and-shoulders. Subjects fill 80–90% of the square, overlap each other and are cut by the frame edges.
- Background: one perfectly flat, opaque #20272B field, identical in all four corners. No vignette, glow, gradient, halo, cast shadow, scenery or border.

TONE
Adult, grim and lived-in. These are hungry, tired, competent adults and dangerous creatures who are already doing the arithmetic on the player. Attractive adults are allowed and wanted, but their beauty shows through bone structure and eyes, beneath dirt, sweat, old scars, chapped skin and self-cut, greasy, tangled hair. Never airbrushed, made-up or groomed. Everyone is fully clothed in practical layered gear. No sexualised poses, cleavage, bare skin or pin-up framing. The adult feel comes from consequence, fatigue and menace.

ALLOWED: road dust, grease, soot, sweat tracks, bruises, split lips with scabs, stitched cuts, old scars, burns that have healed, bandages with dried brown-red blood seeping through, dried blood on gear, knuckles or a blade, rust-and-blood stains you can't tell apart, frightening mutated anatomy.
FORBIDDEN (no gore): open flesh, exposed bone or organs, severed body parts, spraying, dripping or pooling bright blood, corpses or victims in frame, violence in progress, torture. Dried blood is dark brown-red (about #5A2A24 to #7A3328), matte and small, never bright red paint.

ANTI-AI-SLOP RULES — I will reject any image that breaks these
- No two faces with the same skull. Cover the hair: each face must still be a different person (jaw, nose, brow, cheek, age).
- No centred three-head triangle. No symmetric composition. Not everyone looks at the camera.
- Expressions are specific and subtle: brow tension, eyelid opening, lip pressure, shoulders. No maximum-intensity snarls on humans, no grins, no visible human teeth.
- Wear has a cause: chafe under a strap, polish where a hand grips, dirt in seams, one repair patch in a different material. No random scratch noise.
- No fantasy armory: no spikes, skulls, ornamental chains, pauldrons, warpaint, heroic capes or gas masks as post-apocalyptic shorthand.
- At most two weapon or tool props per portrait.
- No text, letters, numbers, logos or insignia anywhere.

HOW TO BUILD EACH PORTRAIT (work in passes, like a human pixel artist)
1. Silhouette pass: block out every subject in 3 values only. Check the thumbnail read at 50x50 before you continue.
2. Plane pass: break faces, cloth and machines into broad lit and shadow planes using the light direction from the brief.
3. Colour pass: assign the palette ramps. Count colours and stay at 20 or fewer.
4. Detail pass: eyes, the signature detail, assigned scars, dirt and blood, hair clumps. Each one is a deliberate cluster of 2+ pixels.
5. Cleanup pass: remove orphan pixels, fix jaggies on curves and check that the corners are exactly #20272B.

OUTPUT FOR EVERY PORTRAIT
- Draw it as an explicit 64x64 indexed pixel array (a palette list plus a 64x64 grid of palette indices), rendered to canvas with nearest-neighbour scaling. No vectors, filters or anti-aliasing.
- Show a review strip on a #20272B page: the new portrait at 1x (64px), at 50px and at 8x (512px), next to the four attached reference portraits at 8x for comparison.
- Provide download buttons for the 64x64 PNG and the 512x512 PNG, named with the asset ID (for example enemy_raiders.png).
- Underneath, list the palette (hex), the colour count and one line confirming that the signature detail is visible at 64x64.
- Before showing me the result, compare it against the references yourself. If it looks flatter, blockier or more cartoonish than enemy_toll or enemy_dogs, do another plane and colour pass first.

Do not start drawing yet. Reply "Ready" and wait for the first enemy brief.
```

---

## Enemy briefs — paste one at a time, in this order

### 1 · `enemy_crows` — Mutant Crows (replace placeholder)

```text
ENEMY: enemy_crows — Mutant Crows. Roaming threat. Rim light: small dusty-ochre, upper-left.

IDEA: They collect what shines, and you are wearing some.

SUBJECTS: Exactly seven featherless mutant crows hunting as a practised flock. Real corvid skulls, beaks, bird wings and scaled legs. Bare, wrinkled slate-brown skin with sparse broken feather shafts. The mutation is feather loss and uneven growth: no bat wings, no extra eyes.
- LEAD CROW (about half the image, diving from upper-left toward lower-right): long charcoal beak hooked slightly sideways, one opaque milky left eye and one small black right eye, wrinkled gray-brown throat, heavy storm-slate breast, angular wings with skin-covered arm planes and a few stiff broken shafts on the trailing edge, talons tucked.
- SIX SMALLER CROWS in a broken clockwise arc, each a different pose: thin dusty-brown diver high-left (wings swept back); broad violet-gray banker upper-centre, edge-on; narrow charcoal dropper high-right, wings folded; small pale-slate climber mid-right, uneven V wings; distant dark bird low-right with one wing raised; distant brown-gray glider low-left. Crop one wing tip against the frame edge.

SIGNATURE DETAIL: the lead crow grips one dull brass key (square bow, short shaft) across its nearly closed beak. It is a stolen object, not food. It must read at 64x64 as a clear angular glint.
BLOOD / WEAR (allowed, no gore): the lead crow's beak tip and the edge of its lower mandible are stained matte dried brown-red, as if it has pecked at something living before. The key itself is clean.

FEAR: intent. A swarm that wants something specific is worse than one that wants meat.
PALETTE: near-black charcoal, storm slate, dusty brown-gray skin, muted parchment highlights, violet shadow, dusty-ochre rim, brass for the key, one dried-blood brown-red.
AVOID: a neat ring, duplicated poses, feathers drawn as noise, bats, horns, glowing eyes, sky, clouds, moon, motion blur, corpses or carrion.
THUMBNAIL TEST at 50px: one large diving crow carrying something bright, plus six unequal flock silhouettes. Never one monster with many wings.
```

### 2 · `enemy_bandits` — Road Bandits (replace placeholder)

```text
ENEMY: enemy_bandits — Road Bandits. Shattered Outskirts. Rim light: restrained rust-red, from the right.

IDEA: salvaged civilian life worn as gear. Six months ago they were your neighbours, and they have done this often enough to be good at it.

SUBJECTS: exactly four adults in salvaged civilian winter clothing. Only the leader looks at the viewer.
1. LEADER, largest, lower-centre: a beautiful 27-year-old woman with fair warm skin, broad muted freckle clusters across the nose, a diamond face, high cheekbones, a slightly crooked nose bridge, full closed lips and green eyes under one higher auburn brow. Copper-red side-parted jaw-length wavy bob, greasy at the roots and wind-tangled into two clumps. Faded mustard marching-band jacket with the braid cut off, high charcoal knit collar, brown canvas repair on the left shoulder. Wear: a healed split scar pulls her left mouth corner slightly down, a tan dust smear across the right cheek with a finger-wiped track, chapped lower lip, wind-red nose. Expression: weary defiance, lids lowered, one brow drawn in, mouth firm, no snarl.
2. SPOTTER, high-left, strict left profile: 41-year-old olive-skinned woman, broad square jaw, blunt upturned nose, thin pursed lips, heavy uneven brows, short dark espresso waves under a patched plum-brown flat cap. Slate canvas delivery coat with a dull ochre crossing-guard sash worn as a bandolier. Gray dust under the cap band, irritated doubt.
3. RECRUIT, low-right: 23-year-old deep-brown-skinned man with a broad round face, soft cheeks and close-cropped black coils flattened from sleeping. A dusty burgundy cloth covers his mouth and chin. Blue-gray quilted moving-blanket vest with a cream patch on the right shoulder seam. Wide frightened eyes look sharply right and his shoulders are hunched. A fresh bruise, yellow-purple and matte, sits on his right cheekbone above the cloth.
4. ARCHER, smaller, high-right: 36-year-old East Asian man with golden-beige skin, a long oblong face, hollow cheeks, a broad straight nose, a blunt crooked black fringe, a short low ponytail tied with frayed cloth and a roughly clipped black goatee. Olive upholstery-fabric vest, tan neck scarf, brown leather bow strap. Cookfire soot in one cheek hollow. Absorbed calculation, gazing down-left at the viewer's supplies.

SIGNATURE DETAIL: the leader wears a CHILD'S backpack straps over her shoulders: narrow, padded and cream with faded blue block patterns, obviously not adult gear. Nobody reacts to them. They must be clearly visible at 64x64.
BLOOD / WEAR (allowed, no gore): the leader's right knuckles, visible at the lower crop, are wrapped in a dirty cloth bandage with a dried brown-red stain soaking through. Someone hit back last time.
PROPS (exactly two): a short hunting bow curving along the upper-right edge and a chipped machete hilt at the lower-left.
COMPOSITION: broken diagonal ambush, never a triangle. All four faces sit in the upper 75%, with clear gaps between heads.
PALETTE: charcoal slate, dusty mustard ochre, cream, worn brown, blue-gray, plum-burgundy shadows, olive, copper-red hair, four distinct skin tones, dried-blood brown-red, rust-red rim.
AVOID: grins, skull paint, mohawks, spikes, matching bandanas, guns, extra weapons, scenery.
THUMBNAIL TEST: a copper bob over a mustard collar and two pale straps; a plum cap, a burgundy face cloth and a black fringe on three smaller heads. With the hair covered, the diamond, square, round and oblong faces must still differ.
```

### 3 · `enemy_warden` — Warden Machine (replace placeholder, boss)

```text
ENEMY: enemy_warden — Warden Machine. East Citadel boss. Rim light: restrained pale cold Citadel light from the upper-left.

IDEA: a door that grew armour. It began as a checkpoint barrier and spent decades accreting plate. It is not hunting you. It is still closed, and you are on the wrong side.

SUBJECT: exactly one non-humanoid tracked machine, about twice as wide as it is tall, seen from a low threatening viewpoint and filling about 90% of the square. Tracks press into both lower corners.
- Viewer-left track: newer blue-black rubber with intact tread blocks. Viewer-right track: faded brown-gray with three chipped blocks.
- Low cold-slate gate-like hull with three overlapping horizontal maintenance hatches. They imply compression but must not form a mouth or face.
- A short armoured neck rises high-left, carrying a horizontal steel sensor hood with exactly one muted red circular lens. Below it, a narrow dark gap reads like an empty socket.
- Exactly three replacement plates: a dirty cream OCTAGONAL road-sign plate bolted to the front-left, a rust-brown trapezoid in the centre and a blue-gray rectangle on the right shoulder. Use broad bolts and one bent corner each.
- One rotary cannon low-right: a thick shroud with three dark barrel holes, angled down-right.

SIGNATURE DETAIL: the octagon plate is a flattened road sign, blank-painted, with its eight-sided outline unmistakable at 64x64. Every repair was made by human hands, and those people are long dead.
MISDIRECTED ATTENTION: the red lens points slightly away from the cannon, watching the road behind the viewer. You are incidental.
BLOOD / WEAR (allowed, no gore): the lower edge of the viewer-right track and the cannon shroud are streaked with dark matte stains where rust and old dried blood are indistinguishable. Don't explain it.
PALETTE: near-black charcoal, blue-black rubber, cold steel, slate blue, brown-gray tread, rust-brown, dirty cream, one muted red lens, one dark brown-red stain tone.
AVOID: legs, a humanoid body, a face, a conventional tank turret, a sleek sci-fi look, missiles, a second gun, thin cables, sparks, glow, text or numbers, scenery.
THUMBNAIL TEST: an isolated red eye, crushing wide tracks, mismatched plates and a downward cannon. It should feel immediately oppressive.
```

### 4 · `enemy_raiders` — Bog Raiders (new)

```text
ENEMY: enemy_raiders — Bog Raiders. Drowned Marches. Rim light: contaminated moss green, from the right.

IDEA: faces built out of the landscape. Their reed-and-tar equipment imitates a wading bird. By the time you realise it is a person, they have been watching you for a while.

SUBJECTS: exactly two adults, back to back on a diagonal, heads pointing in opposite directions so together they form one hooked silhouette.
1. BOATMAN, lower-left, unmasked, facing left: 32-year-old man with warm medium-brown skin, a broad rounded-square ordinary face, a wide flat-tipped nose, thick level brows, tired lower lids, a short uneven chestnut beard and short dense chestnut curls clumped flat and damp. Waterlogged dark-teal canvas coat over a tan sweater, brown oilskin collar, cream sailcloth patch where a strap rubs, cracked cork ear guard over the far ear. Wear: dried silt under the jaw and a gray-green splash in the beard. Expression: deadpan skepticism, one lid half-lowered, a sideways glance at the viewer.
2. SCOUT, upper-right, taller, masked, facing right: 29-year-old woman with light olive skin, a long oval face and a gray-green eye. Only her right eye, temple and a small cheek plane show through the mask's side opening. A thick dark-auburn rope braid hangs down her back, frayed and damp, with short wet locks stuck to her temple. Brown oilskin capelet, charcoal high-necked jacket, crossed tan rope harness with a moss-green repair. Her HERON MASK is hand-lashed ochre marsh reed and tar-stiffened black cloth: a long forward-and-down triangle with visible bindings at the joints. It must never resemble a gas mask. Expression: one lifted, tense brow and a narrowed eye, sudden attention to something far right.

SIGNATURE DETAIL: one completely ordinary, tired human face beside one constructed bird face. Both must read at 64x64.
BLOOD / WEAR (allowed, no gore): the boatman has a stitched cut through his left eyebrow, dark with a dried scab and three crude black stitch marks. The marsh pole-hook's tip is stained dark brown-red.
PROPS (exactly two): a patched shotgun low across the scout's shoulder and a short marsh pole-hook along the far-left edge.
PALETTE: charcoal slate, wet brown, tan canvas, bone, deep teal, moss green, chestnut and dark-auburn hair, warm brown and light olive skin, dried-blood brown-red, moss rim. Show damp with a few blocky highlights, never gloss.
AVOID: a third person, gas masks or respirators, military insignia, boats, reeds or water in the background, a centred heroic pose, matching faces.
THUMBNAIL TEST: a broad brown curly-haired face with a teal collar, back to back with a tall ochre heron mask and an auburn braid.
```

### 5 · `enemy_scavs` — Vault Scavengers (new)

```text
ENEMY: enemy_scavs — Vault Scavengers. Hollow Industrial Zone. Rim light: restrained industrial rust-orange, from the left.

IDEA: calm competence. A shift crew defending a claim, with roles assigned and weapons at rest. You should feel outclassed, not threatened.

SUBJECTS: exactly four adults in an uneven horizontal work line, with visible gaps between every jaw and shoulder.
1. CLAIMANT, centre-left, one of the two largest heads: 44-year-old man with medium-brown skin, a heavy square face, a flattened crooked nose, low straight brows, coarse black stubble and short black hair receding at the temples, with a small gray streak on the right only. Reinforced soot-gray high-collared work jacket, steel-gray patch on the left shoulder, ochre tape band on the sleeve. Grime where the stubble meets the jaw, a wiped track on the cheek. Patient, calculating eye contact with the viewer.
2. ELECTRICIAN, far high-left, leaning in: striking 55-year-old fair woman with cool pink undertones, a broad hexagonal face, a sturdy jaw, a short nose bent left, narrow pale-blue eyes, heavy dark brows, deep crow's feet and sun spots. Rough hand-clipped charcoal-brown crop with one thick silver forelock over the left temple. NO braid. Plum high-collared coverall, tan rubber bib apron, steel-blue tarp shoulder cover, cream hearing protectors around her neck, pale-blue sleeve tape. A broad matte healed burn scar runs along her left jaw, with a soot thumbprint on the other cheek. Skeptical disapproval, looking down at the resting rifle.
3. LOOKOUT, smaller, high-right: 24-year-old East Asian man with light golden skin, an inverted-triangle face, a pointed chin and a forward-swept black top with clipped sides, sweat-clumped. Olive zip-neck pullover, rust tape band, a round magnifier lens strapped ABOVE his left brow. Raised left brow, alert curiosity, looking off-frame right.
4. MECHANIC, low-right, the other large head: beautiful 29-year-old woman with deep brown skin, a full round face, broad cheekbones, a short broad nose, warm amber-brown eyes and a lopsided high black coiled bun with two loose temple tufts. Blue-gray insulated jacket with a cream shearling collar rubbed gray, plum sleeve tape, one brown glove at the bottom crop. A diagonal grease wipe across her left cheek and a small old heat scar under the right cheekbone. A tired, closed-lip, wry half-smile aimed at the claimant: someone here finds you slightly funny.

SIGNATURE DETAIL: nothing in the frame is aimed at anything. The rifle lies flat across the bottom edge and a work-axe head rests at the far-left edge. They have already decided how this goes.
BLOOD / WEAR (allowed, no gore): the axe head carries a dull dried brown-red film along its edge, and the electrician's left palm is wrapped in a fresh gauze bandage with a small dried blood bloom. Nobody seems bothered by either.
PROPS (exactly two): the rifle and the axe.
PALETTE: charcoal, soot gray, tan canvas, steel blue-gray, dusty ochre, cream, faded plum, olive, muted rust, silver, four distinct skin tones, dried-blood brown-red, rust rim.
AVOID: a fifth person, matching uniforms, anything raised or aimed, crazed faces, a neat white braid or frail-elder stereotype for the electrician, crates or warehouse scenery.
THUMBNAIL TEST: a square gray-collared claimant, a rough crop with a silver forelock, a clipped black top with a lens and a lopsided bun with a cream collar. Four different heads.
```

### 6 · `enemy_drones` — Security Drones (replace placeholder)

```text
ENEMY: enemy_drones — Security Drones. Hollow Industrial Zone. Rim light: industrial rust-orange, from the left.

IDEA: obedience outliving the institution. They still fly a corporate courtesy-escort formation from a manual forty years dead.

SUBJECTS: exactly five obsolete machines (four working, one dead) with bolted construction, faded safety paint and boxy repairs. Each has a different chassis and its own tilt, arranged in a loose orbit, never a triangle.
1. PATROL, large, below-centre: wide rectangular soot-gray housing with a heavy blunt front, one dull red circular sensor offset left, a cracked horizontal speaker grille on the right, two battered square-shrouded lift fans, a crushed viewer-left corner, a dirty cream replacement top panel and a small brass plaque scraped blank. Tilted slightly counter-clockwise, sensor on the viewer.
2. INSPECTION, high-left: thin upright oxidised-steel body with a tall vertical dark-glass lens and a rusty repair band. Tilted left. Its lens looks PAST the viewer, the only working unit whose attention wanders.
3. UTILITY, high-right: round faded-ochre housing inside three charcoal cage ribs (one rib replaced in pale steel) and a small recessed sensor. A broad attached carrying fork extends below it.
4. DEAD ALARM DISK, mid-right: a flat charcoal-black disk with a broken beacon stump, a warped rust rim and a completely dark sensor slot, supported by the utility unit's fork. The only hazard banding in the image, ochre and charcoal, sits on this disk.
5. EMITTER, low-left: compact dirty-cream triangular hub with three blunt prongs (one shorter from an old break) and a small dark sensor. Tilted clockwise, rear corner cropped by the edge.

SIGNATURE DETAIL: the dead disk is still carried in its formation slot. Nobody explains why. It must look clearly dead and different from the other four at 64x64.
BLOOD / WEAR (allowed, no gore): one partial dried brown-red handprint smeared across the patrol unit's crushed corner, as if someone pushed it away. It is matte, old and unexplained.
PALETTE: charcoal, soot gray, oxidised steel, dirty parchment, faded ochre, dull brass, rust orange, one muted warning-red sensor (patrol only), one dried-blood brown-red, rust rim.
AVOID: a sixth drone, humanoid robots, sleek sci-fi, text, numbers, logos, sparks, smoke, glow bloom, thin cables, factory scenery.
THUMBNAIL TEST: one large failing patrol unit with a red sensor, four smaller orbiting shapes and one visibly dead dark hull.
```

### 7 · `enemy_hunters` — Tunnel Hunters (new)

```text
ENEMY: enemy_hunters — Tunnel Hunters. The Underrail. Rim light: restrained steel-blue, from the upper-right.

IDEA: sound discipline. Buckles taped, sleeves bound, hair bound, pockets stitched shut. No metal shows except one knife edge. You are being processed.

SUBJECTS: exactly two adults in a tight vertical, hooked column with a deep negative-space notch between their faces.
1. SIGNALER, high-left, severe three-quarter profile: 43-year-old man with deep brown skin, a broad diamond face, prominent cheekbones, a firm jaw, a wide straight nose and a broken heavy left eyebrow. His left eye is matte and clouded; his right is dark brown and watches off-frame left. Black locs are drawn back from shaved temples into a short bundle bound with charcoal cloth. Heavy faded teal canvas hood pushed back, gray quilted high-necked jacket, every fastening taped dark, and a cloth-wrapped shuttered lamp clipped high on the hood. A dull moss-green tunnel-wall smear runs along his right jaw. His bare right hand is raised between their faces in a FLAT STOP SIGNAL aimed at his partner, not the viewer. Contained alarm.
2. LISTENER, low-right, looking UP at his hand: beautiful 26-year-old woman with light beige skin and cool rosy undertones, a long oblong face, high sloping cheekbones, a straight narrow nose and wide gray-blue eyes. Dirty ash-blonde hair roughly braided close to her head under two charcoal cloth bands, with greasy dark roots and short broken tufts trapped inside, showing as a pale crescent above the ear. A worn gray cloth mask covers her lower face. Steel-blue wool shoulder cape over a charcoal high collar. Two dull olive-green residue streaks cross her left cheekbone (glove grime, not makeup or fungus) and a healed notch cuts her outer right brow. Pinched inner brows: reluctant determination.

SIGNATURE DETAIL: the flat stop hand, five fingers together, readable against dark cloth at 64x64. She watches it. Two people communicating in front of you as if you cannot see.
BLOOD / WEAR (allowed, no gore): the single exposed knife edge along the bottom is filmed with dried brown-red. A thin dried blood trickle runs from the signaler's nostril to his lip, old and ignored. Her gray mask carries a small brown-red stain near the mouth edge.
PROPS: one knife (the only visible metal) along the bottom and the shuttered lamp. No guns.
PALETTE: near-black charcoal, deep teal, steel blue, worn gray, dull olive and moss residue, dirty cool-parchment blonde, deep-brown and light-beige skin, dried-blood brown-red, steel-blue rim. Faces must never sink into black.
AVOID: night-vision goggles, glowing eyes, neon green, a third person, a horizontal group, tunnel scenery, fog or backlight.
THUMBNAIL TEST: a broad brown face with a green jaw mark over a teal hood, a narrow pale masked face with green cheek streaks under dirty pale hair, and one raised flat hand.
```

### 8 · `enemy_cult` — Glass Cult (new)

```text
ENEMY: enemy_cult — Glass Cult. Glass Wastes. Rim light: one cold pale highlight, from the upper-left.

IDEA: injury reframed as rank. Old radiation and glass scarring on the cheeks is left uncovered like a medal. Everything else is wrapped. The longer the pilgrimage, the more scarring shows.

SUBJECTS: exactly five adults in a curved crescent wall of faces at uneven spacing, never a triangle. NOBODY LOOKS AT THE VIEWER.
1. VEILED GUIDE, largest, slightly left of centre: 31-year-old woman with warm umber skin, a slender oval skull and tired amber-brown almond eyes, visible only through a horizontal eye opening. Her hair is hidden under an ash-gray linen headwrap. An asymmetrical veil cut from scratched mirrored solar-panel film slants lower over her right cheek. Dusty-violet neck wrap, ash mantle, tan shoulder repair. Ash along the eye opening. Inward certainty, gaze upper-left.
2. ELDER, low far-left: 64-year-old man with deep brown skin, a broad round skull, a heavy jaw, deep-set eyes and sparse clumped silver temple hair under a low ochre hood. He shows the most face: two broad matte gray-brown healed scar planes across both cheeks and his chin. Brown blanket coat. Private grief, eyes down-left.
3. ASCETIC, high-left behind the guide: pale 25-year-old man with a long gaunt face, hollow cheeks, a hooked nose, SHAVED brows, wide light-gray eyes looking sharply up-right and a small strawberry-blond crop wedge under a tight bone-coloured hood. A dry pale scar across his left cheekbone and a wind-reddened nose. Feverish conviction, thin pressed lips.
4. CHEEK-GUARD PILGRIM, high-right: 38-year-old tan woman with a round face, a button nose, rounded dark eyes and one chestnut curl escaping a loose violet hood. A cracked translucent gray cheek guard covers her right cheek. Ash-beige quilted wrap. Worried doubt, gazing horizontally right.
5. WRAPPED FOLLOWER, low far-right: 47-year-old olive-skinned woman with a narrow rectangular skull. Ash-brown cloth is wound diagonally over her face and forehead, leaving only her hazel left eye and a thin temple wedge. Ochre collar, charcoal shawl. Guarded suspicion, eye down-left toward the elder's hands.

SIGNATURE DETAIL: five people, five eye lines, and not one aimed at you. Collective refusal reads as uncanny, not hostile.
BLOOD / WEAR (allowed, no gore): the elder's fingertips, visible holding the blade, are wrapped in cloth strips spotted with dried brown-red from handling glass. Dried brown blood also stains the edge of the guide's veil where the film has cut her cheek and scabbed. All scars elsewhere are old, matte and healed.
PROP (exactly one): a broad fused-glass blade lying flat along the bottom with a few stepped pale highlights. Held, not raised.
PALETTE: near-black charcoal, ash-gray cloth, muted parchment, dusty brown and ochre, restrained violet, one cold pale glass highlight, a small shared warm skin ramp plus the pale ascetic, ochre-rust for his hair, dried-blood brown-red.
AVOID: a sixth person, anyone looking at the viewer, runes, glowing magic, ornate robes, crowns, radiation symbols, wet or open sores, auras, mirrored scenery.
THUMBNAIL TEST: count five eye regions in a crescent: a slanted silver veil, an ochre hood around a broad dark face, a narrow pale face, a violet hood with a cheek guard and a diagonal wrap around one eye.
```

### 9 · `enemy_guard` — Citadel Guard (new)

```text
ENEMY: enemy_guard — Citadel Guard. East Citadel, final region. Rim light: one restrained pale cold Citadel light, from the right.

IDEA: the horror of the well-fed. After four regions of patched canvas and wire, CLEAN, MAINTAINED equipment is the most frightening material in the game. This is the only faction allowed to match, because someone still runs a supply chain and it is not for you.

SUBJECTS: exactly three guards in a disciplined diagonal echelon at three depths, never a triangle. They wear identical maintained dull-olive segmented armour, steel-blue padded high collars, charcoal underlayers and cream-edged webbing, fitted to three different shoulder widths.
1. COMMANDER, large, lower-left foreground: beautiful 38-year-old East Asian woman with light warm-beige skin, a broad oval face, high flat cheekbones, a firm rounded-square chin and dark almond eyes under strong level brows. Jet-black jaw-length blunt bob with uneven self-trimmed ends, sweat-flattened under a maintained open-face olive helmet. A narrow pale vertical scar runs from below her lip to her chin, with a dust smear and a helmet-pressure line at her temple. Three-quarter right, controlled impatience, assessing the viewer.
2. LINE GUARD, high-left above her shoulder, bareheaded: 46-year-old olive-skinned man with a long rectangular face, a heavy square jaw, deep cheek lines, a blunt bent nose, a short rough dark-brown mustache and clipped side-parted dark hair graying only at the temples. A faint healed crescent beside his nostril and a sweat track through dust. Skeptical vigilance, gaze off-frame left.
3. YOUNG GUARD, smaller, far-right: 24-year-old deep-brown-skinned man with a narrow oval face, a slim jaw, wide dark eyes under raised inner brows and short crushed black coils under a charcoal patrol cap with one steel-blue ear protector. His shoulders are pulled up into his collar and his eyes cut right. He is plainly frightened, and nobody in the group has noticed or cares.

SIGNATURE DETAIL: three short hand-painted cream tally strokes in a vertical series on the edge of a compact riot shield at the far-right edge. They are crowd-counting marks with no digits or insignia. You are a queue position.
BLOOD / WEAR (allowed, no gore): the gear is spotless EXCEPT a small spray of dried brown-red flecks across the young guard's steel-blue collar and cheek, which he has not wiped off. Clean armour plus one dirty memory. The shield's lower rim carries a faint dark brown-red smear that someone has half cleaned.
PROPS (exactly two): a simplified service rifle as a dark diagonal along the lower edge and the riot shield. Nothing aimed.
PALETTE: charcoal, cold steel blue, clean muted parchment, dull olive armour, jet-black and dark-brown hair, three distinct skin tones, dried-blood brown-red, pale cold rim. Use controlled clean shapes, never sterile vector smoothness.
AVOID: a fourth guard, flags, emblems, badges, lettering, sunglasses, power armour, futuristic rifles, cloned faces, centred symmetry, walls or spotlights.
THUMBNAIL TEST: an open-face helmet over a black bob, a bare rectangular head with a mustache and a small capped head with anxious eyes. Three cream tally blocks on the shield edge.
```

---

## Correction lines

Paste one per message, in the same chat as the portrait being fixed.

- **Too flat or blocky:** `This reads like flat colour blocks. Redo the plane pass: break every face and garment into 2–4 stepped tones lit from the rim-light side, as in enemy_toll's faces and enemy_dogs' fur. Keep the composition and cast.`
- **Too clean or AI-pretty:** `[Character] looks airbrushed. Apply her assigned scar, dirt and hair disorder as broad clusters. Keep her bone structure and eyes, and do not rejuvenate or groom her.`
- **Same faces:** `With the hair covered, [A] and [B] are the same face. Rebuild [B]'s skull, jaw, nose and brow from the brief.`
- **Too gory:** `Reduce the blood to small, matte, dried brown-red stains. No open wound, no bright red and no dripping.`
- **Not scary enough:** `Push the menace through posture and gaze, not snarls: tighten the brows, lower the lids and make the signature detail more prominent.`
- **Signature detail lost:** `The [detail] is not readable at 64px. Enlarge it into a clear 3–5 pixel cluster with higher contrast. Change nothing else.`
- **Background wrong:** `Make every background pixel exactly #20272B, with no halo, shadow or gradient.`
