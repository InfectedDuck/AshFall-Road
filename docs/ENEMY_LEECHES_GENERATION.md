# Marsh Leeches generation record

- Asset: `enemy_leeches`
- Date: 2026-09-07
- Generator: OpenAI built-in image-generation tool
- Selected source: `art_sources/portraits/enemy_leeches_source.png`
- Inputs: No external references. The refinement edited the first generated portrait.
- State: Generated source; no runtime normalization or technical palette/background certification performed.

## Initial prompt

Use case: stylized-concept.
Create ONE square combat portrait for a portrait-mode post-apocalyptic mobile RPG. Asset ID enemy_leeches — Marsh Leeches (metadata only, never write it on the image).

BACKGROUND: One perfectly flat, fully opaque #20272B (RGB 32,39,43) field. Identical RGB in every corner and throughout all negative space. No ripples, bubbles, glow, texture, environment, water surface, or ground shadow.

SUBJECT: A horrifying mass of roughly eight to twelve hand-long marsh parasites disturbed by body heat. This is not a random swarm — it is a directed mass. Every unfed body is oriented toward the same unseen source of warmth, the way iron filings orient in a magnetic field, so the image reads as a decision being made by something with no head. One dominant parasite curves through the frame with a clearly readable circular sucker mouth shown at an angle. It is a natural blunt leech sucker, dark-centered, toothless, without eyes. Surrounding bodies vary in thickness, length, curl, highlight, and direction within that overall common pull; several disappear behind the main mass so the creature count reads as more than can be counted. Every visible body must read as a real parasite — segmented with visible annulations, blunt, wet — never a snake, finger, eel, or generic tentacle.

SIGNATURE DETAIL: One leech near the frame edge has already fed. It is distended, noticeably paler, slower, and curling AWAY from the mass while every other body strains toward the warmth. Make this pale, fat, blunt segmented leech large enough to read clearly on a 64x64 logical grid and at a 50x50 thumbnail. It proves a victim that is never shown. It contains no blood, no wound, and no anatomy that is not a leech.

COMPOSITION: Lopsided vortex filling about 85% of the square. Dominant sucker off-center near the upper-left; supporting bodies spiral clockwise toward the lower-right; the fed one sits apart at an edge. Cut three or four sharp negative-space pockets through the mass — these background-colored gaps must prevent an unreadable knot. A few thin silhouettes curl along the edges while heavier bodies overlap at the center. Irregular, asymmetric, overlapping and partly occluded bodies, not an evenly arranged ring. No victim, hands, water surface, or environment.

STYLE: Handmade cinematic 16-bit pixel art designed on a TRUE 64x64 logical grid; display enlarged using crisp integer nearest-neighbor pixels only. Each logical pixel is a flat square color. 16–20 colors total, chunky curved clusters, hard stepped edges, only TWO OR THREE blocky wet highlights in the ENTIRE image, selective dark outlines, restrained dithering, no smooth tubular gradients. Avoid miniature high-resolution details: keep all segmentation and sucker shapes chunky and readable in the 64x64 source design.

PALETTE: Near-black charcoal, deep teal, mud brown, contaminated moss green, gray-violet shadow, muted parchment highlights. The fed leech is the noticeably paler accent, muted gray-parchment rather than flesh-pink.

THUMBNAIL TEST: At 50x50 it must read as an overwhelming parasite mass with ONE dominant sucker and ONE pale distended body — never a single knot, a hand, or a snake.

AVOID: A neat ring or evenly spaced arrangement, identical repeated bodies, snakes, fingers, eels, octopus tentacles, teeth-filled fantasy mouths, eyes, blood, wounds, gore, any victim anatomy, water scenery, bubbles, frame, vignette, gradient, glow, smooth shading, anti-aliasing, text, logo, or watermark.

OUTPUT: One square portrait only, without captions or borders.

## Selected refinement prompt

Edit this Marsh Leeches combat portrait by correcting its pixel-art rendering. Preserve the subject, square crop, asymmetric overlapping leech mass, dominant angled toothless sucker at upper left, and separate pale distended fed leech along lower-right edge curling away. Keep approximately eight to twelve real blunt, annulated leeches with sharp negative-space pockets; all unfed bodies share a directed clockwise pull toward one unseen warmth source.

CRITICAL CHANGE: Radically simplify to an authentic 64 by 64 pixel sprite, with exactly 64 logical pixel columns and 64 rows, displayed using nearest-neighbor enlargement. Current image has far too many small pixels, specular dots, and smooth shading. Every logical pixel is ONE solid flat square; no subpixel details, anti-aliasing or texture. Restrict to 16–20 flat colors TOTAL. Use large chunky curved clusters and coarse stepped contours. Segmentation is broad simple dark stepped bands, not dozens of fine ridges. Only TWO OR THREE blocky wet highlight clusters across the ENTIRE image. Remove all other reflective dots and highlight trails. The pale fed leech is a broad muted parchment shape with simple shadow bands, not shiny.

Replace the background with a single perfectly uniform fully opaque #20272B, exact RGB (32,39,43), including all gaps, every corner, and outer edges. No vignette, subtle gradients, shadows outside bodies, texture or illumination variation on background.

Palette stays near-black charcoal, deep teal, mud brown, contaminated moss green, gray-violet shadow, muted parchment highlights. The pale fed leech and dominant natural toothless sucker must remain instantly legible at 50x50. No eyes, teeth, blood, wounds, victims, hands, fingers, snakes, eels, octopus tentacles, scenery, water, bubbles, glow, text, logos, frames or borders. Output only ONE square portrait.

