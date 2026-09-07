# Ashfall Road portrait art bible and prompt pack

## Purpose and scope

**Ashfall Road** is an offline-first, portrait-mode post-apocalyptic D20 roguelike. A randomized survivor crosses six hostile regions while managing health, food, fatigue, radiation, equipment, and ammunition. Combat is tactical, risk is visible, and death permanently erases the active run.

This document is the production source of truth for four survivor portraits and thirteen combat-adversary portraits. It is compatible with Gemini and with a tool-directed image-generation workflow. Background replacement, UI icons, item illustrations, story-only characters, animation, store graphics, screenshots, logos, the code-drawn D20, and the existing app icon are deferred.

For enemy generation, `enemy-portrait-v4.2` in `docs/ENEMY_PORTRAIT_PROMPTS_V4.md` is authoritative and supersedes both the older concise adversary briefs below and the v3.0 standalone sheet. All thirteen v4.2 prompts are self-contained, with fixed adult casts and complete appearance, wardrobe, anatomy, and construction details. Do not paste this document's master rules or older enemy casts alongside them.

Prompt version: **portrait-v2.0**.

## Non-negotiable portrait contract

- Square composition designed as a true **64×64 logical pixel grid**.
- **16–20 colors** in the final sprite, using broad deliberate clusters and one apparent pixel size.
- Hard edges, selective colored outlines, stepped color ramps, and restrained dithering only where materially useful.
- Perfectly flat, opaque, near-black charcoal-slate background, normally `#20272B` or `#172124`.
- No scenery, gradient, fog, decorative square, halo, border, frame, geometric backplate, text, logo, signature, or watermark.
- No anti-aliasing, smooth curves, painterly texture, faux-pixel noise, isolated high-resolution details, film grain, or photographic lighting.
- Teen-rated and non-graphic: no gore, fresh wounds, exposed organs, or cruelty.
- Regional identity comes only from one restrained edge-light color, never from a background scene.
- Individual portraits are close head-and-shoulder crops; the face or central form occupies roughly 70–80% of the square.
- Group portraits have one dominant face or form and clearly separated secondary silhouettes in the upper 70%. Retain at most two iconic props.
- Every asset must read at 64×64, the 50×50 journey HUD, and the 96-pixel-square image area inside combat.

Final sprites use `assets/portraits/<portrait_id>.png`. Selected high-resolution sources use `art_sources/portraits/<portrait_id>_source.png`.

## Workflow

1. Generate one portrait per request. Never request a contact sheet.
2. Start a fresh Gemini chat or isolated generation context for every new ID. Continue in the same context only for targeted edits to that ID.
3. If an approved image is attached, label it **edit target** and state every invariant that must remain unchanged.
4. If an approved portrait guides a different ID, label it **style reference only**. Copy its pixel scale, palette discipline, outline treatment, and contrast—not its identity, pose, clothing, or composition.
5. Inspect the high-resolution source for anatomy, group count, unwanted objects, background shapes, text, and mixed pixel scale.
6. Normalize the selected source with:

   ```powershell
   C:\Users\ASUS\Applications\Godot-4.7.2\Godot_v4.7.2-stable_win64.exe --headless --path . --script tools/prepare_portrait.gd -- art_sources/portraits/<portrait_id>_source.png assets/portraits/<portrait_id>.png 20 '#20272B'
   ```

7. Inspect at native size and in the game. Do not judge only an enlarged preview.
8. Make one targeted correction at a time. After two unsuccessful edits, revise the brief instead of requesting uncontrolled variants.
9. Record source, generator, prompt version, edits, and approval in the ledger and provenance document.
10. Do not advance to the next ID until the current portrait is approved.

## Category templates

These rules are already included in every prompt below; asset prompts are self-contained and do not require a separate master prompt.

- **Individual human:** intimate close crop, asymmetric expression, broad facial planes, readable eyes, and one identity-defining accessory. Keep weapons and role-specific gear out of survivor portraits.
- **Human group:** one dominant head at roughly 35–45% of image height plus unobstructed secondary heads. Use a compact triangular silhouette and no more than two simple props.
- **Animal or mutant group:** one dominant animal plus clearly separated supporting forms. Preserve species anatomy and group readability; avoid a tangled crowd.
- **Individual creature:** combine head, shoulders, posture, and one signature limb or feature into one unmistakable silhouette. Suggest mutation without gore.
- **Machine or drone group:** chunky utilitarian shapes, limited lights, and one visible mechanical function. Avoid sleek science-fiction design and dense machinery.

## Survivor prompts

The survivor portraits are reusable visual identities. Names, callsigns, stats, weapons, and equipment are randomized, so none may imply a fixed profession, faction, or character class.

### `survivor_1` — Hooded watcher

> Use case: stylized-concept. Asset type: 64×64 mobile RPG survivor portrait. Edit target: the attached approved hooded survivor portrait, if supplied. Preserve the same pale olive oval face, dark hair, gray-green eyes, guarded direct gaze, calm closed mouth, weathered gray-green hood, wrapped collar, facial proportions, expression, and existing muted colors. Change only the background to one perfectly flat near-black charcoal slate and simplify any remaining sub-pixel noise. Close head-and-shoulder crop; face about 74% of image height; hood forms a strong arch. True 64×64 logical pixel construction, 16–20 colors, large consistent clusters, hard edges, selective dark-plum outlines, no anti-aliasing or gradients. No weapon, role-specific gear, scenery, squares, backplate, text, logo, border, or watermark.

### `survivor_2` — Skeptical mechanic

> Use case: stylized-concept. Asset type: 64×64 mobile RPG survivor portrait. Edit target: the attached approved dark-skinned survivor with goggles, if supplied. Preserve the broad square face, deep-brown complexion, short textured hair, goggles above the brow, small metal ear stud, leftward skeptical gaze, restrained half-smile, and high practical collar. Close head-and-shoulder crop; face about 72% of image height. Use a perfectly flat near-black charcoal background with only a restrained rust edge light on one side. True 64×64 logical pixel construction, 16–20 colors, broad facial planes, large consistent clusters, hard edges, and selective outlines. No weapon, tool, profession badge, scenery, gradient, square, backplate, text, logo, border, or watermark.

### `survivor_3` — Weathered elder

> Use case: stylized-concept. Asset type: 64×64 mobile RPG survivor portrait. Edit target: the attached approved older survivor in a head wrap, if supplied. Preserve the long angular olive-tan face, gray hair at the temples, beige head wrap, prominent nose, deep eye lines, rightward wary gaze, stern exhausted expression, and narrow neck-and-shoulder silhouette. Three-quarter profile facing right; face about 76% of image height. Use a perfectly flat near-black charcoal background and one restrained steel-blue edge light. True 64×64 logical pixel construction, 16–20 colors, large consistent clusters, hard edges, and no smooth shading. No weapon, fixed profession, scenery, gradient, square, text, logo, border, or watermark.

### `survivor_4` — Defiant veteran

> Use case: stylized-concept. Asset type: 64×64 mobile RPG survivor portrait. Edit target: the attached approved older white male survivor, if supplied. Preserve the wide rectangular face, close salt-and-pepper hair, short gray beard, pale blue-gray eyes, vertical temple-to-cheek scar, direct intimidating stare, crooked confident half-smile, tan coat, and dark rust scarf. Close frontal head-and-shoulder crop; face about 72% of image height. Replace any decorative rectangles with a perfectly flat near-black charcoal background and retain one restrained rust edge light. True 64×64 logical pixel construction, 16–20 colors, broad asymmetrical facial planes, hard edges, and consistent clusters. No weapon, uniform, scenery, gradient, square, backplate, text, logo, border, or watermark.

## Combat-adversary prompts

### `enemy_bandits` — Road Bandits

> Use case: stylized-concept. Asset type: 64×64 mobile RPG combat portrait. Edit target: the attached approved three-bandit portrait, if supplied. Preserve exactly three characters: a dominant messy-haired central leader with an asymmetric snarl and dusty-ochre scarf, a cap-wearing lookout in left profile, and a younger masked knife carrier on the right. Keep the compact triangular overlap, short bow/string diagonal, single simple knife, clothing colors, faces, and expressions. Crop to heads, shoulders, and upper chests; all three faces occupy the upper 70% and remain unobstructed. Use a perfectly flat near-black charcoal background with restrained Outskirts ochre/rust edge light. Rebuild for a true 64×64 logical grid, 16–20 colors, large clusters, hard edges, no anti-aliasing. No extra people, extra weapons, scenery, shapes, gradient, lettering, gore, border, or watermark.

### `enemy_dogs` — Feral Dogs

> Use case: stylized-concept. Asset type: 64×64 mobile RPG combat portrait. Edit target: the attached approved three-dog portrait, if supplied. Preserve exactly three natural feral dogs: one large tan dog above-left with lowered wary head, one dominant gray scarred dog snarling in the center, and one pale lean dog at right with a simple collar. Enlarge the three heads and shoulders so the pack remains obvious at 50×50; keep each muzzle and ear silhouette separate. Perfectly flat near-black charcoal background with restrained dusty-ochre Outskirts edge light. True 64×64 logical grid, 16–20 colors, broad fur clusters, hard edges, no fine hair or anti-aliasing. Old non-graphic scars only. No additional dogs, blood, supernatural anatomy, scenery, shapes, gradient, text, border, or watermark.

### `enemy_stalker` — Ash Stalker

> Use case: stylized-concept. Asset type: 64×64 mobile RPG combat portrait. Edit target: the attached approved pale Ash Stalker, if supplied. Preserve the single hairless vibration-hunting predator, sealed vestigial eyes, narrow skull-like face, small listening mouth, ribbed throat, hunched shoulder, and one raised long-fingered hooked hand. Enlarge the head and raised claw into one readable diagonal silhouette; keep it original and biologically coherent. Perfectly flat near-black teal-charcoal background with restrained Underrail steel-blue edge light. True 64×64 logical grid, 16–20 pale ash and violet-gray colors, large consistent clusters, hard edges. No extra creature, exposed organs, gore, scenery, gradient, text, border, or watermark.

### `enemy_toll` — Toll Gang

> Use case: stylized-concept. Asset type: 64×64 mobile RPG combat portrait. Edit target: the approved Toll Gang source. Preserve exactly three extortionists: a dominant gray-haired leader in a faded rust-orange road coat holding one revolver downward, a bald broad enforcer at left holding one vertical club, and a tired younger lookout at right with goggles and a wrapped lower face. Crop to heads, shoulders, and upper chests; keep every face unobstructed and the leader largest. Perfectly flat near-black charcoal background with bone-and-rust Salt Flats edge light. True 64×64 logical grid, 16–20 colors, large clusters and hard edges. No lower torsos, extra weapons, badge text, scenery, squares, gradient, gore, border, or watermark.

### `enemy_leeches` — Marsh Leeches

> Use case: stylized-concept. Asset type: 64×64 mobile RPG combat portrait. Show exactly six oversized hand-long marsh leeches forming one bold spiral mass, with one dominant open sucker silhouette and five clearly separated curved bodies. Use a few blocky wet highlights and one dark base shape so they read as leeches rather than snakes or tentacles. Perfectly flat near-black charcoal background with restrained contaminated-moss edge light. True 64×64 logical grid, 16–20 deep teal, mud, moss, and parchment colors, hard edges and consistent clusters. No victim, blood, gore, water scene, bubbles, gradient, text, border, or watermark.

### `enemy_raiders` — Bog Raiders

> Use case: stylized-concept. Asset type: 64×64 mobile RPG combat portrait. Show exactly three drowned-marsh raiders in a compact triangular head-and-shoulder group. The dominant center figure wears a crude reed-and-cloth mask and holds one patched shotgun low across the bottom; the two secondary figures have distinct hood and shaved-head silhouettes. Clothing is waterlogged civilian salvage, never a matching uniform. Perfectly flat near-black charcoal background with restrained moss-green Marches edge light. True 64×64 logical grid, 16–20 colors, large clusters, hard edges. No boat, reeds, scenery, extra people, extra weapons, lettering, gradient, gore, border, or watermark.

### `enemy_drones` — Security Drones

> Use case: stylized-concept. Asset type: 64×64 mobile RPG combat portrait. Show exactly three failing old industrial security drones as one compact formation: one dominant dented boxy unit with a single dull-red sensor and two smaller overlapping units at different heights. Give them chunky housings, exposed brackets, short rotors or lift fans, and abstract two-color hazard bands without letters. Perfectly flat near-black charcoal background with restrained rust-orange Industrial edge light. True 64×64 logical grid, 16–20 colors, hard edges and large mechanical clusters. No sleek futuristic shells, scenery, smoke, gradient, logos, text, border, or watermark.

### `enemy_scavs` — Vault Scavengers

> Use case: stylized-concept. Asset type: 64×64 mobile RPG combat portrait. Show exactly three disciplined warehouse scavengers as a close triangular group. The dominant central claimant has a heavy square face, reinforced work jacket, and one rifle held low; a compact lookout overlaps one shoulder and an older worker with a short axe overlaps the other. Give each a different face, age, head angle, and accessory; their threat is coordination, not madness. Perfectly flat near-black charcoal background with restrained rust Industrial edge light. True 64×64 logical grid, 16–20 colors, hard edges and broad clusters. No warehouse scene, extra people, extra guns, military insignia, gradient, text, gore, border, or watermark.

### `enemy_cult` — Glass Cult

> Use case: stylized-concept. Asset type: 64×64 mobile RPG combat portrait. Show exactly three Glass Cult pilgrims in a compact head-and-shoulder formation. The dominant central figure wears a plain reflective face veil and holds one broad fused-glass blade along the bottom edge; two asymmetrical wrapped followers overlap behind at different heights. Their clothing is austere road cloth, not ornate fantasy robes. Perfectly flat near-black charcoal background with one restrained violet Glass Wastes edge light. True 64×64 logical grid, 16–20 colors, hard edges, large clusters, and simple glass highlights. No runes, radiant magic, scenery, extra people, gradient, text, gore, border, or watermark.

### `enemy_hunters` — Tunnel Hunters

> Use case: stylized-concept. Asset type: 64×64 mobile RPG combat portrait. Show exactly three silent human tunnel raiders emerging as distinct overlapping head-and-shoulder silhouettes. The dominant hooded center hunter has a masked lower face and one concealed knife at the bottom edge; the secondary faces look in opposite directions and remain partly shadowed but readable. Their equipment is patched civilian tunnel gear, not military kit. Perfectly flat near-black teal-charcoal background with restrained steel-blue Underrail edge light and one tiny muted-red reflection. True 64×64 logical grid, 16–20 colors, hard edges and large clusters. No night-vision goggles, supernatural eyes, scenery, extra people, gradient, text, gore, border, or watermark.

### `enemy_guard` — Citadel Guard

> Use case: stylized-concept. Asset type: 64×64 mobile RPG combat portrait. Show exactly two well-fed East Citadel guards in a close overlapping bust composition. The dominant foreground guard has a clean practical helmet, maintained body armor, disciplined neutral expression, and one service rifle across the lower edge; the second guard watches over one shoulder. Their standardized equipment is cleaner than wasteland gear but remains grounded old-world hardware. Perfectly flat near-black charcoal background with restrained clean parchment and cold-steel Citadel edge light. True 64×64 logical grid, 16–20 colors, hard edges and broad clusters. No flags, lettering, extra guards, power armor, scenery, gradient, gore, border, or watermark.

### `enemy_warden` — Warden Machine

> Use case: stylized-concept. Asset type: 64×64 mobile RPG boss portrait. Show one low heavy checkpoint machine with a tracked base, compact armored hull, elevated single scanner eye, thick battered plates, and one readable rotary cannon angled across the lower corner. Use a slight low viewpoint and combine eye, armor, tracks, and weapon into one dense silhouette. Perfectly flat near-black charcoal background with cold-steel edge light, one muted-red sensor, and a tiny parchment Citadel highlight. True 64×64 logical grid, 16–20 colors, hard edges and chunky mechanical clusters. No humanoid robot shape, sleek science fiction, gate scenery, extra weapons, gradient, text, logo, border, or watermark.

### `enemy_crows` — Mutant Crows

> Use case: stylized-concept. Asset type: 64×64 mobile RPG combat portrait. Show exactly six hairless mutant crows moving as one hostile flock. One large foreground crow has angular spread wings and a hooked beak; five smaller separated bird silhouettes form a broken ring behind it. Preserve recognizable bird anatomy and make the group count readable without tiny detail. Perfectly flat near-black charcoal background with restrained storm-slate and dusty-ochre edge light. True 64×64 logical grid, 16–20 colors, hard edges and broad clusters. Non-graphic wrinkled skin only. No feathers-as-noise, bats, insects, demons, scenery, gradient, text, gore, border, or watermark.

## Targeted revision blocks

### Preserve identity; fix background only

> Change only the background to one perfectly flat near-black charcoal-slate color. Preserve the subject count, identities, faces, expressions, poses, clothing, accessories, crop, palette, outlines, and pixel construction exactly. Do not add shapes, scenery, texture, lighting effects, text, or a border.

### Correct fake pixel art

> Preserve the identities and composition. Rebuild the image as a true 64×64 logical pixel design using 16–20 colors, large consistent rectangular clusters, hard edges, and stepped ramps. Remove anti-aliasing, smooth gradients, isolated one-pixel noise, painterly texture, and mixed apparent pixel sizes.

### Improve thumbnail readability

> Preserve identity and subject count. Enlarge the faces or central forms, simplify clothing and props into three or four value groups, separate overlapping silhouettes, and retain only the single most important accessory or weapon. Keep the flat background unchanged.

### Repair a cluttered group

> Preserve the exact group members. Use one dominant face or form plus clearly separated secondary heads in a compact triangular silhouette. Keep all faces in the upper 70%, remove lower torsos and loose props, and retain no more than two simple weapons.

## Asset ledger

| ID | Source | Final | State | Revision notes | Approval |
| --- | --- | --- | --- | --- | --- |
| `survivor_1` | `art_sources/portraits/survivor_1_source.png` | `assets/portraits/survivor_1.png` | Approved to proceed | Second background-only ImageGen edit; normalized to 20 colors | Approved 2026-09-01 |
| `survivor_2` | `art_sources/portraits/survivor_2_source.png` | `assets/portraits/survivor_2.png` | Approved to proceed | Identity-preserving background edit; normalized to 20 colors | Approved 2026-09-01 |
| `survivor_3` | `art_sources/portraits/survivor_3_source.png` | `assets/portraits/survivor_3.png` | 64×64 candidate saved | Preserved original identity; deterministically flattened the two-tone background; normalized to 20 colors after two rejected vignette edits | Awaiting user approval |
| `survivor_4` | `art_sources/portraits/survivor_4_source.png` | `assets/portraits/survivor_4.png` | Temporary `survivor_4.svg` runtime placeholder installed | Replace the placeholder with the approved source and remove decorative rectangles | Pending |
| `enemy_toll` | `art_sources/portraits/enemy_toll_source.png` | `assets/portraits/enemy_toll.png` | Existing local anchor | Validate after survivors | Pending |
| `enemy_bandits` | `art_sources/portraits/enemy_bandits_source.png` | `assets/portraits/enemy_bandits.png` | Source supplied in chat | Ingest after Toll validation | Pending |
| `enemy_dogs` | `art_sources/portraits/enemy_dogs_source.png` | `assets/portraits/enemy_dogs.png` | 64×64 candidate saved | Four distinct attack-ready dogs with varied skulls, ears, coats, and depth; added restrained dried blood, hair loss, radiation discoloration, and contaminated-green accents; normalized to 20 colors | Awaiting user approval |
| `enemy_stalker` | `art_sources/portraits/enemy_stalker_source.png` | `assets/portraits/enemy_stalker.png` | Approved to proceed | Identity-preserving horror recrop; enlarged sealed-eyed head, ribbed throat, and hooked hand; normalized to 20 colors | Approved 2026-09-01 |
| `enemy_leeches` | `art_sources/portraits/enemy_leeches_source.png` | `assets/portraits/enemy_leeches.png` (not installed) | Generated source saved | Built-in ImageGen generation and pixel-simplification edit on 2026-09-07; prompts in `docs/ENEMY_LEECHES_GENERATION.md`; runtime normalization pending | Pending |
| `enemy_raiders` | `art_sources/portraits/enemy_raiders_source_v2.png` | `assets/portraits/enemy_raiders.png` (not installed) | Weathered source saved | Red-haired woman and long-black-haired man with visible red eye; user-requested scars, dirty hair and aged gear; built-in ImageGen, 2026-09-08; prompts in `docs/ENEMY_RAIDERS_GENERATION.md`; runtime normalization pending | Pending |
| `enemy_drones` | `art_sources/portraits/enemy_drones_source.png` | `assets/portraits/enemy_drones.png` | Not generated | — | Pending |
| `enemy_scavs` | `art_sources/portraits/enemy_scavs_source.png` | `assets/portraits/enemy_scavs.png` | Not generated | — | Pending |
| `enemy_cult` | `art_sources/portraits/enemy_cult_source.png` | `assets/portraits/enemy_cult.png` | Not generated | — | Pending |
| `enemy_hunters` | `art_sources/portraits/enemy_hunters_source.png` | `assets/portraits/enemy_hunters.png` | Not generated | — | Pending |
| `enemy_guard` | `art_sources/portraits/enemy_guard_source.png` | `assets/portraits/enemy_guard.png` | Not generated | — | Pending |
| `enemy_warden` | `art_sources/portraits/enemy_warden_source.png` | `assets/portraits/enemy_warden.png` | Not generated | — | Pending |
| `enemy_crows` | `art_sources/portraits/enemy_crows_source.png` | `assets/portraits/enemy_crows.png` (not installed) | Generated source saved | Built-in ImageGen generation and pixel-simplification edit on 2026-09-08; prompts in `docs/ENEMY_CROWS_GENERATION.md`; runtime normalization pending | Pending |

## Final acceptance checklist

- Correct ID, subject count, identity, crop, and iconic prop.
- Recognizable at 64×64 and 50×50 without enlarged inspection.
- Exactly one apparent pixel scale and no anti-aliased edge pixels.
- Between 16 and 20 final colors, including the background.
- Background is one flat near-black color without shapes or texture.
- Regional accent is restrained and follows one lighting direction.
- No malformed hands, faces, muzzles, wings, machinery, or overlapping anatomy.
- No text, letters, numbers, symbols mistaken for lettering, logos, signatures, borders, or watermarks.
- No gore and no resemblance-dependent reference to another named game or franchise.
- Source, prompt version, generator, edits, and approval are recorded before release.
