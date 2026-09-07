# Mutant Crows generation record

- Asset: `enemy_crows`
- Date: 2026-09-08
- Generator: OpenAI built-in image-generation tool
- Selected source: `art_sources/portraits/enemy_crows_source.png`
- Inputs: No external references. The refinement edited the first generated portrait.
- Visual review: Seven separate birds retained: one dominant crow with a bright ring pull, four smaller posed birds, and two distant silhouettes.
- State: Generated source; no runtime normalization or technical palette/background certification performed. Final visual approval pending.

## Initial prompt

Use case: stylized-concept.
Create ONE square combat portrait for a portrait-mode post-apocalyptic mobile RPG.

ASSET ID: enemy_crows — Mutant Crows. This is metadata only; do not put any text in the image.

SUBJECT: Exactly SEVEN separate hairless mutant crows attacking as one shrieking cloud: ONE large foreground crow plus EXACTLY SIX smaller supporting birds. Crows have always taken what shines, and these have kept that instinct while losing their feathers, their fear, and their sense of scale. The flock is not chaotic — it is a practiced hunting pattern flown by birds that have done this before. The large foreground crow has a hooked beak bending slightly sideways, a sealed milky LEFT eye, wrinkled bare non-graphic skin, angular spread wings with uneven finger-like feather shafts, and talons tucked beneath the body. These wing spars are avian feather shafts, not bat membrane or literal human fingers. Behind it, the six smaller crows hold six different readable poses:
1. One diving beak-first.
2. One banking edge-on.
3. One with wings folded.
4. One climbing vertically.
5. One distant crooked corvid silhouette.
6. A second distant crooked corvid silhouette, a different pose from the first.
Every supporting bird keeps readable corvid anatomy with its own beak, head, body, and wings. They are mutant crows, never bats, insects, demons, or repeated copies. Keep all seven birds individually countable.

SIGNATURE DETAIL: The lead crow carries one small bright metal ring pull in its beak, plainly not food. It came for what shines, and the viewer is wearing some. Keep this object small but high-contrast: a simple distinct parchment-bright metal shape at the beak that survives at 64x64.

COMPOSITION: Broken circular attack pattern, never a neat ring. The dominant crow dives diagonally from upper-left toward lower-right and occupies about half the image. The six smaller birds form an irregular clockwise arc with unequal spacing, scale, and wing angle. Leave sharp negative-space gaps between all birds and crop one wing tip against an edge to raise panic without creating a tangled mass. One large bird plus six separate unequal smaller birds, not a fused creature.

STYLE: Handmade cinematic 16-bit pixel art designed on a TRUE 64x64 logical grid, shown enlarged with nearest-neighbor scaling. The complete square composition has only 64 logical pixel columns and 64 logical pixel rows; each logical pixel is one flat-color square, with no subpixel detail. Use 16–20 colors TOTAL, broad wing planes, large deliberate clusters, hard stepped edges, selective dark outlines, restrained dithering, ONE consistent apparent pixel size. Keep wrinkles and wing shafts broad and minimal enough for that grid. Asymmetrical poses and spacing so the flock reads as hand-composed rather than duplicated. No fine noisy detailing and no smooth tonal transitions.

PALETTE: Near-black charcoal, storm slate, dusty brown-gray skin, muted parchment highlights, restrained violet shadow, small dusty-ochre rim light.

BACKGROUND: One perfectly flat, fully opaque #20272B field — exact RGB (32,39,43), identical in every corner and in all gaps. No background texture, lighting variation, cast shadows, or gradient.

THUMBNAIL TEST: At 50x50 the viewer must read one large diving mutant crow carrying something bright, plus EXACTLY SIX unequal flock silhouettes — never one monster with many wings.

AVOID: More or fewer than seven birds, duplicated poses, a tidy ring, feathers rendered as pixel noise, bats, insects, horns, extra eyes, glowing eyes, blood, gore, carrion, sky scenery, clouds, moon, motion blur, glow, frame, vignette, gradient, smooth shading, anti-aliasing, text, logo, or watermark.

OUTPUT: One square portrait only, without captions or borders.

## Selected refinement prompt

Edit the attached Mutant Crows portrait. Make ONE targeted change: radically simplify its rendering into actual coarse 64x64-grid pixel art. Keep the current composition and EXACTLY SEVEN birds: the large foreground crow, the four separate smaller posed crows around the upper and right edges, and the two distant silhouettes below. Preserve their positions, unequal scale, distinct poses, negative-space separation, cropped lead wingtip, bare corvid anatomy, lead crow's milky sealed left eye, and small bright metal ring pull gripped in its beak. Do not add or remove birds.

The reference has much too much fine detail. Redraw it as a 64-pixel-wide by 64-pixel-high sprite, shown at a crisp integer enlargement. Think sixty-four columns, sixty-four rows only, NOT hundreds of tiny pixels. One logical square pixel is approximately 1/64 of the whole image width. Use large flat square color clusters and hard stepped edges, no marks smaller than a logical pixel. Reduce to 16–20 flat palette colors TOTAL. Broad simple wing planes with a few chunky uneven avian feather shafts; simple angular hooked beaks; two or three skin value groups; minimal broad wrinkle marks. The smaller birds should be economical readable corvid silhouettes with just a few large color clusters. All seven remain individually countable at thumbnail size. Avoid bat membranes, feathers rendered as noise, smooth shading, detailed stippling, and anti-aliasing.

Color palette: near-black charcoal, storm slate, dusty brown-gray skin, muted parchment highlights, restrained violet shadow, small dusty-ochre rim light. Make the metal ring pull a small high-contrast pixel shape. The milky eye is dull and sealed, not glowing.

BACKGROUND MUST BE SOLID #20272B: RGB 32,39,43 exactly in all gaps and every corner. Flat opaque digital fill, absolutely no gradient or vignette, no texture and no background lighting. No sky, scenery, clouds, moon, blood, gore, carrion, horns, extra eyes, motion blur, glow, text, logo, watermark, captions, borders or frame. Output one square portrait only.

