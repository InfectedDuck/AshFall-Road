# Ashfall Road — copy-and-paste enemy portrait prompts

> **Historical v3.0 pack; all thirteen generation prompts are superseded.** Use `enemy-portrait-v4.2` in
> `docs/ENEMY_PORTRAIT_PROMPTS_V4.md` for the current fixed casts, complete appearance and clothing descriptions,
> creature anatomy, machine construction, and signature details. Do not reuse the older casts below.
> Prefer the v4.2 correction prompts where this file's instructions conflict with current identities or gaze assignments.

Prompt-pack revision: **enemy-portrait-v3.0** — varied cast sizes, silhouettes, faces, equipment, and horror intensity.

## How to use this document

These prompts create the thirteen combat portraits used by **Ashfall Road**. Each prompt is self-contained: **do not add the master prompt from the larger art bible**.

1. Start a fresh Gemini image-generation chat for each new enemy ID.
2. Copy one complete prompt block and request one image, not a contact sheet.
3. Optionally attach one approved Ashfall Road portrait as a **style reference only**. Gemini should copy its pixel scale, palette discipline, contrast, and outline treatment—not its people, pose, clothing, or composition.
4. Keep targeted revisions for the same asset in the same chat. Do not ask for uncontrolled variants.
5. Save the selected large source as `art_sources/portraits/<id>_source.png`.
6. Normalize the approved source to the runtime sprite with:

   ```powershell
   C:\Users\ASUS\Applications\Godot-4.7.2\Godot_v4.7.2-stable_win64.exe --headless --path . --script tools/prepare_portrait.gd -- art_sources/portraits/<id>_source.png assets/portraits/<id>.png 20 '#20272B'
   ```

The generated image may be larger than 64×64, but it must look as though it was deliberately designed on a **64×64 logical grid**. Final approval happens only after viewing the normalized sprite at 64×64 and 50×50.

## Cast and silhouette diversity map

The portrait is a visual symbol for an encounter, not a literal census of every combatant. Use the following deliberately varied cast sizes and layouts so the gallery never becomes thirteen versions of the same three-person triangle.

| ID | Visible cast | Composition language |
| --- | ---: | --- |
| `enemy_bandits` | 4 people | Broken diagonal ambush; one close leader, three unequal supporting heads |
| `enemy_dogs` | 4 dogs | Forward-moving wedge with four different canine silhouettes |
| `enemy_toll` | 3 people | Asymmetrical stepped lineup; retained as the approved three-person anchor |
| `enemy_leeches` | 8–12 creatures | Grotesque spiral swarm with one dominant sucker |
| `enemy_raiders` | 2 people | Back-to-back hunting duo with opposing head angles |
| `enemy_drones` | 5 machines | Loose orbit around one large failing security unit |
| `enemy_scavs` | 4 people | Uneven horizontal work crew, not a centered pyramid |
| `enemy_cult` | 5 people | Disturbing crescent of veiled faces at different heights |
| `enemy_hunters` | 2 people | Tight vertical hunter duo, one high and one low |
| `enemy_stalker` | 1 creature | Unbalanced close-up dominated by head and hooked hand |
| `enemy_guard` | 3 people | Disciplined echelon with intentionally non-identical faces |
| `enemy_warden` | 1 machine | Low, wide boss silhouette |
| `enemy_crows` | 7 creatures | Broken circular flock around one large diving bird |

Human encounter IDs must remain human because their gameplay descriptions and equipment refer to people. Do not turn bandits, raiders, scavengers, cultists, hunters, or guards into unrelated monsters. Horror-forward imagery belongs primarily to the Leeches, Ash Stalker, Mutant Crows, failing machines, and the unsettling human behavior of the Glass Cult. Make horror through silhouette, posture, negative space, unnatural stillness, and restrained lighting—not gore.

### Horror-first production rhythm

If the current contact sheet feels too human, pause human generation and use this order: `enemy_stalker` → `enemy_leeches` → `enemy_crows` → `enemy_warden` → `enemy_drones` → `enemy_dogs`. During the full campaign, generate at least one creature, animal, or machine after every two human factions. This keeps the roster visually surprising without contradicting the game’s existing enemy names and combat descriptions.

---

## Shattered Outskirts

### `enemy_bandits` — Road Bandits

```text
Create one square combat portrait for a portrait-mode post-apocalyptic mobile RPG.

ASSET ID: enemy_bandits — Road Bandits.
SUBJECT: Exactly four hungry but practiced road bandits with no repeated face template. Closest to camera is a weathered dark-skinned woman leader with a long angular face, shaved sides, short uneven twists, a broken nose, tired asymmetric eyes, and a quiet hostile stare. High behind her at left is a pale older man in strict profile with a hooked nose, sunken cheeks, gray stubble, and a patched cap. Low at right is a tan young adult with a broad round face, cropped curls, a cloth over the mouth, and frightened sideward eyes. Farthest back is a narrow-faced archer with short straight hair, one raised eyebrow, and a calm calculating gaze. Vary age, complexion, jaw, nose, hairline, expression, gaze direction, and shoulder height. They are desperate individuals, not matching henchmen.
COMPOSITION: Broken diagonal ambush rather than a triangle. The leader’s head is largest at lower-center; the cap-wearing profile rises behind the left shoulder; the masked face sits lower-right; the archer’s smaller head appears high-right with clear negative space. All four faces remain countable in the upper 75%. Retain only two readable weapon shapes: one short hunting bow curving along the upper-right edge and one chipped machete hilt at the lower-left. Differentiate equipment through a scarf, cap, patched shoulder pad, and rope harness rather than extra weapons. No lower torsos.
STYLE: Handmade cinematic 16-bit pixel art designed on a true 64×64 logical grid. 16–20 colors. Large deliberate clusters, broad facial planes, hard edges, selective dark-plum outlines, restrained dithering, one consistent apparent pixel size. Include subtle facial asymmetry, uneven clothing repairs, and purposeful hand-placed shapes so it does not look generic or AI-smoothed.
PALETTE: Charcoal slate, dusty ochre, muted parchment, worn brown, and restrained rust-red Outskirts rim light.
BACKGROUND: One perfectly flat, fully opaque #20272B field. Every background pixel, including all corners, must be the exact same color.
THUMBNAIL TEST: At 50×50, the viewer must instantly read one close leader plus three unequal supporting heads in a broken diagonal.
AVOID: More or fewer than four people, duplicated faces, centered symmetry, matching outfits, extra weapons, guns, scenery, road signs, backplates, rectangles, frames, halos, vignette, gradient, glow, fog, smooth shading, anti-aliasing, micro-detail, embedded text, logos, watermarks, gore, or resemblance to a named franchise.
OUTPUT: One square portrait only, without captions or borders.
```

### `enemy_dogs` — Feral Dogs

```text
Create one square combat portrait for a portrait-mode post-apocalyptic mobile RPG.

ASSET ID: enemy_dogs — Feral Dogs.
SUBJECT: Exactly four radiation-corrupted feral dogs forming a coordinated territorial pack, each with a different build. Closest is a lean gray shepherd-mix with old muzzle scars, lowered brows, fully raised lips, visible teeth, and a dark dried-blood smear. Behind-left is a heavy tan mastiff-mix with a broad wrinkled muzzle, one folded ear, both eyes fixed forward, and one lifted lip showing several teeth. High-right is a pale narrow sighthound-mix with a cracked worn collar, long muzzle, ears pinned flat, narrowed eyes, and a thin line of bared teeth. Low-right is a smaller black-and-rust cattle-dog mix with mismatched ears angled forward, lowered head, focused eyes, and curled upper lip. Add restrained contaminated moss-green discoloration, asymmetrical hair loss, and dry skin around old scars while preserving believable canine anatomy and distinct skull, ear, and muzzle shapes.
COMPOSITION: Forward-moving wedge, not a triangle of floating heads. The snarling shepherd head and shoulders push toward the lower-left; the mastiff looms high-left; the sighthound stretches high-right; the smaller cattle dog cuts across the lower-right. Use clear gaps between every muzzle and ear. Show only the front edge of shoulders, never full bodies or tangled legs.
STYLE: Handmade cinematic 16-bit pixel art designed on a true 64×64 logical grid. 16–20 colors, broad fur masses, large deliberate clusters, hard edges, selective dark outlines, almost no single-pixel fur marks, no anti-aliasing. Use irregular old scars and ear shapes for character instead of excessive texture.
PALETTE: Charcoal, weathered gray, dry tan, bone highlights, muted brown, restrained dark rust-red dried blood, contaminated moss green, yellow-olive corruption, and dusty-ochre Outskirts rim light.
BACKGROUND: One perfectly flat, fully opaque #20272B field; identical color in every corner and around every silhouette.
THUMBNAIL TEST: At 50×50, four different dog silhouettes and the lunging gray leader must remain unmistakable.
AVOID: More or fewer than four dogs, passive or friendly expressions, repeated heads, wolves with fantasy proportions, collars on every dog, glowing fantasy eyes, horns, fresh dripping blood, open wounds, exposed flesh, gore, victims, scenery, grass, shadows on the background, shapes, frames, vignette, gradient, glow, smooth fur, text, logos, or watermark.
OUTPUT: One square portrait only, without captions or borders.
```

---

## Salt Flats

### `enemy_toll` — Toll Gang

```text
Create one square combat portrait for a portrait-mode post-apocalyptic mobile RPG.

ASSET ID: enemy_toll — Toll Gang.
SUBJECT: Exactly three extortionists who wear faded road-maintenance clothing and mistake it for authority. Keep this approved three-person encounter, but make the identities strongly unequal. The dominant center-right leader is an older olive-skinned gray-haired woman with a long severe face, thin lips, narrowed judging eyes, and a faded rust-orange road coat. High at left is a tall pale bald broad-necked male enforcer with a flattened nose, heavy brow, blunt suspicious expression, fingerless work glove, and one vertical club. Low at right is a younger brown-skinned exhausted lookout with a small heart-shaped face, short dark hair, goggles pushed onto the forehead, one ear stud, and a scarf covering the lower face. Their ages, complexions, skulls, heights, gazes, and expressions must never resemble one another.
COMPOSITION: Asymmetrical stepped lineup, not a centered triangle. The bald enforcer rises highest on the left; the gray-haired leader occupies the largest center-right area; the lookout sits smaller and lower at the far right. Faces fill the upper 70% and never overlap the eyes. Retain only two weapon props: the leader’s hand with one revolver pointing downward along the bottom edge and the enforcer’s vertical club along the left edge. Let goggles, glove, scarf, and mismatched road coats provide equipment variety. Remove lower torsos and extended arms.
STYLE: Handmade cinematic 16-bit pixel art built on a true 64×64 logical grid, 16–20 colors, large clusters, hard edges, broad asymmetric facial planes, selective colored outlines, restrained dithering, one pixel scale.
PALETTE: Near-black charcoal, bone parchment, faded safety-orange, ochre, worn brown, and restrained Salt Flats rust-and-bone rim light.
BACKGROUND: Perfectly flat opaque #20272B. No tonal variation anywhere.
THUMBNAIL TEST: At 50×50, all three identities and the leader’s authority must read immediately.
AVOID: Extra people, cloned facial structure, centered symmetry, extra weapons, matching military uniforms, badges with lettering, scenery, road signs, squares, backplates, border, vignette, gradient, halo, smooth shading, text, gore, logo, or watermark.
OUTPUT: One square portrait only, without captions or borders.
```

---

## Drowned Marches

### `enemy_leeches` — Marsh Leeches

```text
Create one square combat portrait for a portrait-mode post-apocalyptic mobile RPG.

ASSET ID: enemy_leeches — Marsh Leeches.
SUBJECT: A horrifying swarm of roughly eight to twelve hand-long marsh leeches disturbed by body heat. One dominant parasite curves through the center with a clearly readable circular sucker mouth shown at an angle. The surrounding leeches vary in thickness, length, curl, highlight, and direction; several disappear behind the main mass so the image suggests more creatures than can be individually counted. Each visible body must still read as a real parasite rather than a snake, finger, or generic tentacle. Horror comes from crowded feeding motion and slick segmented shapes, not blood.
COMPOSITION: A lopsided vortex filling roughly 85% of the square, with the dominant sucker off-center near the upper-left. Supporting bodies spiral clockwise toward the lower-right, creating three or four sharp negative-space pockets. A few thin silhouettes curl along the edges while heavier bodies overlap in the center. No victim, hands, water surface, or environment.
STYLE: Handmade cinematic 16-bit pixel art designed on a true 64×64 logical grid. 16–20 colors, chunky curved clusters, hard stepped edges, two or three blocky wet highlights only, selective dark outlines, restrained dithering, no smooth tubular gradients.
PALETTE: Near-black charcoal, deep teal, mud brown, contaminated moss green, gray-violet shadow, and muted parchment highlights.
BACKGROUND: One perfectly flat opaque #20272B field with no ripples, bubbles, glow, or texture.
THUMBNAIL TEST: At 50×50, the image must read as an overwhelming parasite swarm with one dominant sucker—not a single knot, hand, or snake.
AVOID: A neat exact ring, identical repeated bodies, snakes, fingers, octopus tentacles, teeth-filled fantasy mouths, eyes, blood, gore, victim anatomy, water scenery, bubbles, frame, vignette, gradient, text, logo, or watermark.
OUTPUT: One square portrait only, without captions or borders.
```

### `enemy_raiders` — Bog Raiders

```text
Create one square combat portrait for a portrait-mode post-apocalyptic mobile RPG.

ASSET ID: enemy_raiders — Bog Raiders.
SUBJECT: Exactly two veteran skiff raiders who hunt as a practiced duo. The dominant left figure is a stocky dark-skinned woman with a wide jaw, shaved head, one broken ear guard, a skeptical sideways gaze, and a waterlogged patched coat. The taller right figure is a pale older man with a long triangular reed-and-cloth mask, one visible alert eye, gray hair tied behind the mask, and a rope harness over an oilskin shoulder. Their body types, complexions, faces, ages, gaze directions, masks, and equipment must be unmistakably different.
COMPOSITION: Tight back-to-back diagonal duo rather than a group pyramid. The unmasked woman faces left and occupies the lower-left; the masked older raider rises behind her and faces right. Their heads point in opposite directions and create one hooked silhouette. Retain one patched shotgun low across the masked figure’s shoulder and one short marsh pole-hook along the far-left edge. No lower torsos or extra people.
STYLE: Handmade cinematic 16-bit pixel art on a true 64×64 logical grid. 16–20 colors, large deliberate clusters, broad asymmetric faces, hard edges, selective dark-plum outlines, restrained dithering, one consistent pixel size. Show damp wear using a few block shapes, not glossy gradients or surface noise.
PALETTE: Charcoal slate, wet brown, faded canvas, bone, deep teal, and restrained contaminated-moss Marches rim light.
BACKGROUND: One perfectly flat, fully opaque #20272B color across the entire canvas.
THUMBNAIL TEST: At 50×50, the viewer must read a dangerous back-to-back duo: one broad unmasked face and one tall triangular mask.
AVOID: More or fewer than two people, matching faces, a centered heroic pose, boats, reeds, rain, marsh scenery, extra weapons, gas masks, military insignia, decorative shapes, vignette, gradient, fog, smooth shading, text, gore, logo, or watermark.
OUTPUT: One square portrait only, without captions or borders.
```

---

## Hollow Industrial Zone

### `enemy_drones` — Security Drones

```text
Create one square combat portrait for a portrait-mode post-apocalyptic mobile RPG.

ASSET ID: enemy_drones — Security Drones.
SUBJECT: Exactly five failing old industrial security drones still obeying an evacuation order, each built for a different obsolete task. The dominant unit is a large dented rectangular patrol drone with one dull red circular sensor, a heavy front housing, and twin battered lift fans. Around it are four smaller machines: a narrow inspection drone with a vertical lens, a round caged utility drone, a flat disk-shaped alarm drone with a broken beacon, and a compact three-pronged emitter drone. Make every silhouette, sensor placement, damage pattern, and hovering angle different while keeping the same old industrial manufacturing language.
COMPOSITION: Loose mechanical orbit instead of a triangle. Place the large patrol unit below-center. Arrange the four smaller drones at unequal distances around it—high-left, high-right, mid-right, and low-left—with clear negative-space channels. Tilt each machine differently and let one enter partially from an edge. Use abstract two-color hazard bands on only one panel without letters or symbols.
STYLE: Handmade cinematic 16-bit pixel art designed on a true 64×64 logical grid. 16–20 colors, chunky mechanical clusters, hard edges, square dents, selective colored outlines, no thin cables or dense machinery, one apparent pixel size.
PALETTE: Charcoal, soot gray, oxidized steel, dirty parchment, rust orange, one muted warning-red sensor, and restrained Industrial rust rim light.
BACKGROUND: Perfectly flat opaque #20272B, identical in all corners.
THUMBNAIL TEST: At 50×50, one large failing patrol unit plus four smaller orbiting machine shapes and the central red sensor must read clearly.
AVOID: More or fewer than five drones, duplicated shells, a tidy triangular formation, humanoid robots, sleek science-fiction design, readable warning text, logos, factory scenery, smoke, sparks, glow bloom, decorative shapes, vignette, gradient, anti-aliasing, or watermark.
OUTPUT: One square portrait only, without captions or borders.
```

### `enemy_scavs` — Vault Scavengers

```text
Create one square combat portrait for a portrait-mode post-apocalyptic mobile RPG.

ASSET ID: enemy_scavs — Vault Scavengers.
SUBJECT: Exactly four disciplined scavengers defending a warehouse claim, with four unrelated faces. At center-left is a middle-aged brown-skinned claimant with a heavy square face, broken nose, calm calculating stare, and reinforced gray work jacket. High-left is an older pale lean worker with deep cheek lines, a close gray beard, and cloth ear protection. High-right is a young East Asian lookout with a narrow face, cropped undercut, skeptical raised eyebrow, and one magnifying work lens pushed above the eye. Low-right is a broad dark-skinned mechanic with a round face, short coils, tired half-smile, insulated gloves, and a patched canvas collar. Their threat comes from coordination and competence, not madness.
COMPOSITION: Uneven horizontal work crew, not a pyramid. The claimant and mechanic are the two largest heads at different heights; the older worker leans inward from the far left; the lookout appears smaller and higher at the far right. Leave visible gaps between jaws and shoulders. Retain two weapons at most: one simplified rifle lying low across the bottom and one short work-axe head at the far-left edge. Let the work lens, ear protection, gloves, repair patches, and distinct collars provide equipment variety.
STYLE: Handmade cinematic 16-bit pixel art built on a true 64×64 logical grid. 16–20 colors, broad facial planes, intentional asymmetry, large clusters, hard edges, selective outlines, restrained dithering, visibly hand-placed wear patches.
PALETTE: Charcoal, soot gray, faded canvas, steel, dusty ochre, muted parchment, and restrained Industrial rust rim light.
BACKGROUND: One perfectly flat fully opaque #20272B field.
THUMBNAIL TEST: At 50×50, four different heads in an uneven work-crew line and the square-faced claimant must remain readable.
AVOID: More or fewer than four people, identical facial templates, centered symmetry, crazed expressions, matching uniforms, military insignia, extra guns, warehouse scenery, crates, decorative shapes, gradient, vignette, text, gore, logo, or watermark.
OUTPUT: One square portrait only, without captions or borders.
```

---

## Glass Wastes

### `enemy_cult` — Glass Cult

```text
Create one square combat portrait for a portrait-mode post-apocalyptic mobile RPG.

ASSET ID: enemy_cult — Glass Cult.
SUBJECT: Exactly five austere Glass Cult pilgrims whose collective stillness is more frightening than aggression. The dominant off-center figure wears a plain asymmetrical reflective face veil with only tired human eyes visible. Around that leader are four different followers: a broad elderly dark-skinned pilgrim in a low wrapped hood with a downcast gaze; a pale gaunt young adult with a shaved brow and eyes lifted too high; a round-faced middle-aged pilgrim wearing a cracked translucent cheek guard; and a narrow-faced follower almost entirely wrapped except for one sideways-looking eye. Vary height, complexion, skull shape, visible age, eye direction, veil material, and wrap pattern. Road cloth is practical and mismatched—not ornate fantasy robes.
COMPOSITION: Disturbing crescent, not a triangle. Place the veiled leader slightly left of center and largest. Arrange two followers higher behind and two lower at the outer edges, producing a curved wall of faces with uneven spacing. Some faces may be partly covered, but every person must have a separate eye region and silhouette. Retain one broad fused-glass blade as a simple horizontal shape along the bottom; no other weapons.
STYLE: Handmade cinematic 16-bit pixel art designed on a true 64×64 logical grid. 16–20 colors, large clusters, hard edges, broad asymmetric faces, selective dark outlines, a few stepped glass highlights, restrained dithering, no smooth reflections.
PALETTE: Near-black charcoal, ash cloth, muted parchment, dusty brown, restrained violet, and one cold pale highlight.
BACKGROUND: Perfectly flat opaque #20272B with no aura or tonal variation.
THUMBNAIL TEST: At 50×50, the image must read as an uncanny five-person crescent with one reflective-veiled leader—not a generic three-person squad.
AVOID: More or fewer than five people, duplicated eyes or faces, centered heroic symmetry, runes, glowing magic, crowns, ornate fantasy robes, mirrored scenery, glass desert, radiation symbols, bright aura, backplate, vignette, gradient, embedded text, gore, logo, or watermark.
OUTPUT: One square portrait only, without captions or borders.
```

---

## The Underrail

### `enemy_hunters` — Tunnel Hunters

```text
Create one square combat portrait for a portrait-mode post-apocalyptic mobile RPG.

ASSET ID: enemy_hunters — Tunnel Hunters.
SUBJECT: Exactly two silent tunnel hunters who work as a complementary pair. The upper figure is an older dark-skinned woman with a broad face, shaved temples, one clouded eye, a severe profile, and a heavy patched hood pushed back. The lower figure is a younger pale man with a narrow sharp chin, straight black hair falling across one eye, a cloth mask over the mouth, and an intense upward gaze. Their faces, ages, complexions, eye lines, silhouettes, and clothing layers must be completely different. Their patched civilian tunnel gear is practical and improvised, not matching tactical uniforms.
COMPOSITION: Tight vertical duo rather than a horizontal group. The older hunter appears high-left in three-quarter profile and watches out of frame; the younger masked hunter sits lower-right and looks upward beneath the other shoulder. Together they make one hooked column with a deep negative-space notch between the faces. Retain one concealed knife as a short muted-steel shape along the bottom and one shuttered hand lamp clipped high on the older hood; no guns.
STYLE: Handmade cinematic 16-bit pixel art on a true 64×64 logical grid. 16–20 colors, broad shadow masses, deliberate facial asymmetry, large clusters, hard edges, selective deep-teal outlines, restrained dithering, no loss of faces into blackness.
PALETTE: Near-black charcoal, deep teal, steel blue, worn gray cloth, muted parchment skin highlights, and one tiny restrained red reflection.
BACKGROUND: A single perfectly flat opaque #20272B color, not a tunnel scene.
THUMBNAIL TEST: At 50×50, two opposing faces—one broad and high, one narrow and low—must remain readable as a coordinated hunter pair.
AVOID: More or fewer than two people, cloned faces, a triangular squad, night-vision goggles, glowing eyes, supernatural anatomy, guns, tunnel scenery, rails, fog, backlights, shapes, vignette, gradient, text, gore, logo, or watermark.
OUTPUT: One square portrait only, without captions or borders.
```

### `enemy_stalker` — Ash Stalker

```text
Create one square combat portrait for a portrait-mode post-apocalyptic mobile RPG.

ASSET ID: enemy_stalker — Ash Stalker.
SUBJECT: One deeply unsettling hairless vibration-hunting predator adapted to the Underrail. It has a narrow pale skull-like face with sealed vestigial eye ridges and no visible eyeballs, a tiny listening mouth held slightly open as if copying a human whisper, shallow vibration pits along the cheek, a long ribbed flexible throat, one shoulder carried much higher than the other, and one raised long-fingered hooked hand frozen mid-listen. Its anatomy must feel biologically coherent and almost human enough to be disturbing: stretched mammalian skin, compact jaw, credible tendons, believable shoulder joint, and exactly five readable fingers. It is frightening through posture and absence of eyes, never gore.
COMPOSITION: Claustrophobic off-balance close-up. Push the oversized head into the upper-right so part of the skull nearly touches the edge. Let the long neck enter from the lower-left and the raised hooked hand curl inward from the lower-right, creating a trapped crescent of negative space around the listening mouth. Head, throat, shoulder, and hand fill about 88% of the square. Avoid centered portrait symmetry and show no full body.
STYLE: Handmade cinematic 16-bit pixel art designed on a true 64×64 logical grid. 16–20 colors, large pale ash and violet-gray clusters, hard stepped edges, selective deep-plum outlines, restrained dithering, no skin pores or smooth airbrushing.
PALETTE: Near-black teal-charcoal, bone ash, violet-gray shadow, muted parchment, and restrained steel-blue Underrail rim light.
BACKGROUND: One perfectly flat opaque #20272B field.
THUMBNAIL TEST: At 50×50, the sealed eyes, whispering mouth, long ribbed throat, and inward-curling hooked hand must create one frightening off-balance silhouette.
AVOID: Additional creatures, ordinary visible eyeballs, alien-gray stereotypes, zombie decay, vampire teeth, horns, exposed ribs or organs, wounds, gore, scenery, gradient, halo, vignette, text, logo, or watermark.
OUTPUT: One square portrait only, without captions or borders.
```

---

## East Citadel

### `enemy_guard` — Citadel Guard

```text
Create one square combat portrait for a portrait-mode post-apocalyptic mobile RPG.

ASSET ID: enemy_guard — Citadel Guard.
SUBJECT: Exactly three well-fed East Citadel guards defending the last clean walls, with standardized equipment but clearly non-identical people. The dominant foreground guard is a broad-faced middle-aged East Asian woman with a clean practical helmet, maintained layered body armor, and a disciplined unreadable expression. Higher behind at left is a pale older man with a long lined face, clipped gray mustache, exposed close-cropped hair, and a cold forward gaze. Farther back at right is a young dark-skinned guard with a narrow jaw, short coils, one visible ear protector, and anxious eyes looking toward the edge. Their helmets, armor fit, age, complexion, facial geometry, and emotional control must differ even though they belong to the same force.
COMPOSITION: Disciplined diagonal echelon rather than a triangle. The woman occupies the large lower-left foreground; the older guard rises above her left shoulder; the youngest appears smaller and farther right. Keep all three eye lines unobstructed and aimed in different directions. Retain one simplified service rifle as a dark diagonal along the lower edge and the side of one compact riot shield at the far-right edge. No full torsos.
STYLE: Handmade cinematic 16-bit pixel art on a true 64×64 logical grid. 16–20 colors, broad facial planes, hard edges, large clusters, selective navy-charcoal outlines, restrained dithering, controlled clean shapes without sterile vector smoothness.
PALETTE: Charcoal, cold steel blue, clean muted parchment, dull olive armor, and one restrained pale Citadel rim light.
BACKGROUND: Perfectly flat fully opaque #20272B.
THUMBNAIL TEST: At 50×50, exactly three guards at three depths must remain clear, with one broad foreground commander and two distinct supporting faces.
AVOID: More or fewer than three guards, cloned faces, centered symmetry, flags, emblems, lettering, sunglasses, power armor, futuristic rifles, wall scenery, spotlights, decorative shapes, vignette, gradient, gore, logo, or watermark.
OUTPUT: One square portrait only, without captions or borders.
```

### `enemy_warden` — Warden Machine

```text
Create one square boss portrait for a portrait-mode post-apocalyptic mobile RPG.

ASSET ID: enemy_warden — Warden Machine.
SUBJECT: One oppressive armored checkpoint intelligence with no surrender protocol. It is a low heavy machine with a very wide tracked base, compact battered armored hull, one elevated red scanner eye on a short protected neck, layered maintenance hatches resembling a clenched jaw without becoming a literal face, and one readable rotary cannon. One track is newer than the other, three armor plates come from mismatched repairs, and the scanner points slightly away from the cannon as though it is watching two targets at once. The machine should feel like old civil-defense hardware that has continued operating alone for decades—not a humanoid robot, real-world tank, or sleek futuristic AI.
COMPOSITION: Threatening low viewpoint and strongly asymmetric silhouette. Let the wide tracks press against both lower corners, place the scanner eye high-left, and aim the rotary cannon downward-right. Create a narrow dark gap beneath the eye like an empty socket while keeping the machine non-humanoid. Fill about 90% of the square and show no environment.
STYLE: Handmade cinematic 16-bit pixel art designed on a true 64×64 logical grid. 16–20 colors, chunky mechanical clusters, hard edges, selective cold-blue outlines, large readable plates, restrained dithering, purposeful asymmetry from dents and repairs, no dense machinery noise.
PALETTE: Near-black charcoal, cold steel, slate blue, dirty parchment highlights, one muted red scanner, and a restrained clean Citadel rim light.
BACKGROUND: One perfectly flat opaque #20272B field with no cast shadow or glow.
THUMBNAIL TEST: At 50×50, the isolated red eye, crushing wide tracks, mismatched armor, and downward rotary cannon must feel immediately oppressive and unmistakable.
AVOID: Additional machines, legs, humanoid body, face, sleek science fiction, missiles, extra guns, gate scenery, flags, text, numbers, logos, bright bloom, vignette, gradient, border, or watermark.
OUTPUT: One square portrait only, without captions or borders.
```

---

## Roaming threat

### `enemy_crows` — Mutant Crows

```text
Create one square combat portrait for a portrait-mode post-apocalyptic mobile RPG.

ASSET ID: enemy_crows — Mutant Crows.
SUBJECT: Exactly seven hairless mutant crows attacking as one shrieking cloud. One large foreground crow has a recognizable hooked beak that bends slightly sideways, a sealed milky left eye, wrinkled non-graphic bare skin, angular spread wings with uneven finger-like feather shafts, and talons tucked beneath the body. Behind it, six smaller crows have different poses: one diving beak-first, one banking edge-on, one with wings folded, one climbing vertically, and two distant crooked silhouettes. Each supporting bird must still have readable bird anatomy; they are mutant crows, not bats, insects, demons, or repeated copies.
COMPOSITION: Broken circular attack pattern rather than a neat ring. The dominant crow dives diagonally from upper-left toward lower-right and occupies about half the image. Six smaller birds form an irregular clockwise arc with unequal spacing, scale, and wing angles. Leave sharp negative-space gaps between birds and let one wing tip crop against an edge to increase panic without creating a tangled mass.
STYLE: Handmade cinematic 16-bit pixel art designed on a true 64×64 logical grid. 16–20 colors, broad wing planes, large deliberate clusters, hard edges, selective dark outlines, restrained dithering, one consistent apparent pixel size. Use asymmetrical poses and spacing so the flock feels hand-composed rather than repeated.
PALETTE: Near-black charcoal, storm slate, dusty brown-gray skin, muted parchment highlights, restrained violet shadow, and a small dusty-ochre rim light.
BACKGROUND: One perfectly flat fully opaque #20272B field.
THUMBNAIL TEST: At 50×50, the viewer must read one large diving mutant crow plus six unequal flock silhouettes—not one monster with many wings.
AVOID: More or fewer than seven birds, duplicated poses, a tidy ring, feathers rendered as noise, bats, insects, horns, extra eyes, blood, gore, sky scenery, clouds, moon, motion blur, glow, frame, vignette, gradient, text, logo, or watermark.
OUTPUT: One square portrait only, without captions or borders.
```

---

## Targeted correction prompts

Use only one correction at a time and keep it in the same Gemini chat as the source image.

### Remove an unwanted background treatment

```text
Edit the attached image. Change only the background. Replace every background pixel outside the subject silhouettes with one perfectly flat, fully opaque #20272B color. Every corner and edge must have identical RGB values. Remove all vignette, gradients, glow, shadows, scenery, texture, noise, decorative rectangles, backplates, frames, and halos. Preserve the exact subjects, subject count, faces, expressions, anatomy, poses, clothing, props, crop, palette, outlines, and pixel clusters. Do not redraw or beautify the subjects. No text, logo, or watermark.
```

### Make the subjects readable at thumbnail size

```text
Edit the attached image while preserving every identity and the exact subject count. Enlarge and recrop the existing heads or central forms so they occupy the upper 70–80% of the square. Separate overlapping silhouettes with clear negative-space gaps. Keep only the authored one or two iconic props along the edges; remove lower torsos, extended limbs, excess clothing, and empty space. Preserve the flat #20272B background, palette, expressions, and lighting. Do not add people, creatures, objects, scenery, text, borders, or watermarks.
```

### Correct fake or inconsistent pixel art

```text
Edit the attached image without changing its identities, subject count, composition, expressions, or props. Rebuild it as though deliberately drawn on a true 64×64 logical pixel grid using 16–20 colors, large consistent rectangular clusters, broad value groups, hard stepped edges, and selective colored outlines. Remove anti-aliasing, smooth gradients, painterly texture, irregular faux pixels, isolated micro-detail, and mixed apparent pixel sizes. Keep the background one perfectly flat opaque #20272B. No new details, text, logo, border, or watermark.
```

### Repair cloned human faces

```text
Edit only the secondary human faces while preserving the dominant character, exact group count, clothing, composition, props, palette, and flat #20272B background. Make every person immediately different through face width, jaw shape, nose, age, hairline, gaze direction, eyebrow angle, and expression. Keep the same authored roles and positions. Avoid beauty-model symmetry, identical eyes, duplicated noses, matching hairstyles, exaggerated caricature, new accessories, extra people, text, logo, or watermark.
```

### Correct a group-count mistake

```text
Edit the attached portrait to show exactly the authored number of subjects and no more. Preserve the existing dominant subject and the strongest secondary identities. Remove duplicates, partial extra heads, stray limbs, repeated eyes, and ambiguous silhouettes. Arrange the correct subjects as one compact readable group with clear separation at 50×50. Preserve the existing flat #20272B background, palette, pixel scale, props, and overall mood. Do not add scenery, text, a frame, logo, or watermark.
```

### Break the repeated three-person-triangle composition

```text
Edit the attached portrait while preserving the faction, strongest identities, palette, equipment logic, and flat #20272B background. Replace the centered three-head triangle with the authored composition for this ID: broken diagonal, forward wedge, stepped lineup, vortex, back-to-back duo, loose orbit, horizontal crew, crescent, vertical duo, echelon, or single off-balance silhouette. Use unequal head sizes, shoulder heights, gaze directions, overlaps, and negative-space gaps. Do not merely move three similar faces to slightly different positions. Preserve thumbnail readability and do not add scenery, text, borders, logos, or watermarks.
```

### Diversify faces and equipment without clutter

```text
Edit the attached human group without changing its faction, exact cast size, dominant identity, composition, palette, or flat #20272B background. Make every person visibly unrelated by changing face width, jaw, nose, age, complexion, hairline, gaze, eyebrow angle, mouth tension, and posture. Give each person one different non-weapon equipment cue such as a patched cap, rope harness, work lens, ear guard, scarf, hood shape, insulated glove, or mismatched shoulder plate. Keep no more than two weapon silhouettes in the whole portrait. Avoid cloned beauty-model faces, matching outfits, extra people, scenery, text, logo, or watermark.
```

### Increase creature horror without adding gore

```text
Edit the attached non-human portrait while preserving the creature species, count or authored swarm range, palette, pixel scale, and flat #20272B background. Make it more frightening through an off-balance silhouette, claustrophobic crop, unnatural stillness or coordinated motion, asymmetrical anatomy, sealed or misdirected eyes, hooked joints, negative-space traps, and one restrained rim light. Keep the anatomy readable and biologically or mechanically coherent. Do not add blood, wounds, exposed organs, corpses, victims, demonic symbols, scenery, smooth gradients, text, logo, or watermark.
```

## Approval checklist

- Confirm the authored number of people, dogs, drones, or birds, or the authored density range for a swarm.
- View at 64×64 and 50×50, not only enlarged.
- Confirm the dominant face or form remains recognizable.
- Confirm secondary silhouettes are separated and countable.
- Compare the contact sheet: no two human factions should share the same head arrangement or dominant silhouette.
- Confirm every human has a different face shape, age signal, gaze, expression, and one equipment cue.
- Confirm there are no more than two simple props.
- Confirm the background is flat `#20272B` with no vignette or decorative shapes.
- Confirm creature horror comes from silhouette and posture rather than gore or random mutation clutter.
- Reject smooth shading, faux-pixel noise, cloned faces, repeated poses, broken anatomy, scenery, text, logos, watermarks, or gore.
- Normalize to 64×64 and 20 colors before final approval.
