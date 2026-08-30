# Ashfall Road

Ashfall Road is an offline-first, portrait-oriented post-apocalyptic D20 roguelike built with Godot 4.7.2 and GDScript.

## Current gameplay

- Choose one of three equal-budget randomly generated survivors.
- Travel through six regions in a fixed order.
- Resolve data-driven events using visible D20 odds and modifiers.
- Manage Health, Hunger, Fatigue, Radiation, equipment, ammunition, consumables, and carrying weight.
- Rest only at checkpoints after every five regional events.
- Reach the final three-stage encounter or lose the active run permanently.
- Keep only settings, cosmetic entitlements, and run-history summaries after death.
- Resume an interrupted roll from its persisted D20 result without duplicating an outcome.
- Play through seven generated portrait environments with accessible text and motion settings.

## Implemented content

- 6 sequential regions, 60 region events, 12 global events, 1 safe fallback, and a 3-stage finale.
- 48 items, 12 adversary archetypes, and 12 conditions/injuries.
- Equipment slots, weight capacity, ammunition, consumables, armor mitigation, survival thresholds, checkpoints, and run history.
- Offline JSON saves with temporary-file replacement, active-run backup, schema hooks, and a death marker.
- Offline-safe ad and billing facades plus a TypeScript purchase-verification backend.
- 7 original portrait region backgrounds and a scalable vector application icon.

## Run locally

1. Open this directory with Godot 4.7.2 Standard.
2. Run the project with F6/F5.
3. For automated checks, run the headless test entrypoint described in `docs/TESTING.md`.

The core game has no network dependency. Android ads and purchases are isolated behind adapters and remain disabled until their platform plugins and store credentials are configured.

## Project guides

- [Current implementation status](docs/PROJECT_STATUS.md)
- [Windows and Android setup](docs/ANDROID_SETUP.md)
- [Content authoring](docs/CONTENT_AUTHORING.md)
- [Monetization integration](docs/MONETIZATION.md)
- [Testing](docs/TESTING.md)
- [Google Play release roadmap](docs/RELEASE_ROADMAP.md)
- [Asset provenance](docs/ASSET_PROVENANCE.md)
