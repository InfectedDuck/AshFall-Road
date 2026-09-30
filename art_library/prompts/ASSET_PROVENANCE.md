# Asset provenance

## Generated environment art

The seven PNG backgrounds under `assets/backgrounds/` were generated for this project with OpenAI's image-generation tool on 30 August 2026. They are original project assets; no external reference images were supplied. All prompts requested portrait mobile-game environment art, quiet dark areas for overlaid UI, teen-rated non-graphic content, and no text, logos, or watermark.

- `region_1_outskirts.png`: cracked highway, ruined suburbs, abandoned vehicles, storm haze; muted ochre and slate.
- `region_2_salt_flats.png`: bleached salt basin, broken elevated road, utility towers, heat haze; ivory, rust, and pale cyan.
- `region_3_marshes.png`: flooded rural road, reeds, drowned structures, contaminated green light; teal, moss, and charcoal.
- `region_4_industrial.png`: abandoned factories, pipe bridges, smokestacks, freight tracks; charcoal and rust orange.
- `region_5_glass_wastes.png`: fused glass desert, damaged solar arrays, distant observatory, violet storm.
- `region_6_underrail.png`: flooded underground rail interchange, cables, tunnel lights; steel blue and restrained red.
- `region_7_citadel.png`: fortified research tower, ruined crater city, broken causeway, warm beacon.

## Code-native art and audio

- `assets/ui/icon.svg` is a project-created vector icon.
- UI tones are synthesized at runtime by `scripts/services/sound_service.gd`; no third-party audio sample is bundled.
- Equipment and inventory category silhouettes are drawn at runtime by `scripts/ui/item_icon.gd`; no third-party icon artwork is bundled.

## Generated and edited portrait art

Portrait production uses prompt version `portrait-v2.0` from `docs/GEMINI_PIXEL_ART_PROMPTS.md`. High-resolution selected sources are retained under the Godot-ignored `art_sources/portraits/` directory; runtime files are normalized to opaque 64×64 PNGs with nearest-neighbor sampling and a maximum twenty-color palette.

- `enemy_toll.png`: generated for this project with OpenAI's image-generation tool in August 2026, then cropped and rebuilt as a close three-person Toll Gang portrait. The selected source is `art_sources/portraits/enemy_toll_source.png`. Final visual approval remains pending.
- `survivor_1.png`: edited from the user-supplied hooded survivor reference with OpenAI's built-in image-generation tool on 1 September 2026 using prompt version `portrait-v2.0`. The second targeted edit was selected after rejecting the first for identity drift and a strong vignette. It was reduced from 1254×1254 to 64×64 with nearest-neighbor sampling and a twenty-color median-cut palette. Source: `art_sources/portraits/survivor_1_source.png`. Approved to proceed on 1 September 2026.
- `survivor_2.png`: edited from the user-supplied dark-skinned survivor-with-goggles reference with OpenAI's built-in image-generation tool on 1 September 2026 using prompt version `portrait-v2.0`. The face, leftward gaze, half-smile, goggles, ear stud, and high collar were retained while the background was darkened; the selected result was reduced from 1254×1254 to 64×64 with nearest-neighbor sampling and a twenty-color median-cut palette. Source: `art_sources/portraits/survivor_2_source.png`. Approved to proceed on 1 September 2026.
- `survivor_3.png`: curated from the user-supplied older head-wrapped survivor source on 1 September 2026 using prompt version `portrait-v2.0`. Two background-only edits made with OpenAI's built-in image-generation tool were rejected because they introduced vignette shading. The approved source identity was therefore preserved, its two flat background colors were deterministically replaced during sprite cleanup with opaque `#20272B`, and it was reduced from 1024×1024 to 64×64 with nearest-neighbor sampling and a twenty-color median-cut palette. Source: `art_sources/portraits/survivor_3_source.png`. Final visual approval remains pending.
- `survivor_4.svg`: temporary 64×64 vector placeholder authored directly in the project on 4 September 2026 from simple geometric shapes and the documented Defiant Veteran brief. It contains no third-party material. A future `survivor_4.png` will automatically take priority without changing the stable portrait ID.
- `enemy_stalker.png`: edited from the user-supplied Ash Stalker portrait with OpenAI's built-in image-generation tool on 1 September 2026 using prompt pack `enemy-portrait-v3.0`. The selected identity-preserving pass enlarged the sealed-eyed head, listening mouth, ribbed throat, and five-fingered hooked hand into an asymmetric horror-focused crop while remaining non-graphic. It was reduced from 1254×1254 to 64×64 with nearest-neighbor sampling, a flat charcoal background cleanup, and a twenty-color median-cut palette. Source: `art_sources/portraits/enemy_stalker_source.png`. Approved to proceed on 1 September 2026.
- `enemy_dogs.png`: edited from the user-supplied three-dog portrait with OpenAI's built-in image-generation tool on 1 September 2026 using prompt pack `enemy-portrait-v3.0`. The original tan mastiff, scarred gray shepherd, and pale sighthound identities were retained and a smaller black-and-rust cattle-dog mix was added. A subsequent targeted pass made all four dogs attack-ready and added restrained dark dried blood, asymmetrical hair loss, radiation discoloration, cracked skin, and contaminated moss-green accents without open wounds or gore. The selected source was reduced from 1254×1254 to 64×64 with nearest-neighbor sampling, flat charcoal background cleanup, and a twenty-color median-cut palette. Source: `art_sources/portraits/enemy_dogs_source.png`. Final visual approval remains pending.
- Remaining survivor and adversary entries must be appended here when each portrait is approved. Record the generator, date, whether a chat attachment was used as an edit target or style reference, the final prompt version, and any manual or automated normalization.

## Bundled fonts

- `assets/fonts/Literata.ttf` is Literata, downloaded from the official Google Fonts repository and used for narrative prose. It is licensed under the SIL Open Font License 1.1; the bundled licence is `assets/fonts/OFL-Literata.txt`.
- `assets/fonts/Inter.ttf` is Inter, downloaded from the official Google Fonts repository and used for interface controls, HUD labels, numbers, and combat logs. It is licensed under the SIL Open Font License 1.1; the bundled licence is `assets/fonts/OFL-Inter.txt`.
- The font binaries and licence files are packaged locally; neither font requires a runtime network request.

## Before release

Record the source, license, creator, purchase receipt, and modification notes for every future font, sound, icon, screenshot overlay, plugin asset, or store graphic. Do not add an asset whose commercial mobile-game rights cannot be demonstrated.
