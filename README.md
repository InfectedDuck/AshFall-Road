# Ashfall Road

Ashfall Road is an offline-first, portrait-oriented post-apocalyptic systems roguelike built with Godot 4.7.2 and GDScript.

## Current gameplay

- Choose one of three equal-budget randomly generated survivors.
- Travel through six regions in a fixed order, with one guaranteed supply opportunity per region.
- Read simple stat-based success percentages, then reveal a concealed, persisted D20 roll.
- Earn run-only XP from survival, difficult successes, checkpoints, and defeated enemies. Each level banks an uncapped stat point that can be allocated at a checkpoint; death erases all progression.
- Fight authored adversaries in deterministic multi-round portrait combat using Attack, Block, Dodge, Item, Flee, and a once-per-fight Opportunity; see the prepared D20, real HP changes, armor blocks, status effects, and damage feedback on one cinematic battle screen.
- Manage a Grit-based threshold heart pool, four meal icons, Fatigue, Radiation, equipment, ammunition, consumables, and carrying weight.
- Read event and outcome prose through a configurable typewriter reveal; double-tap the narrative to reveal it immediately.
- Use a responsive, reference-style icon inventory with four equipment slots, five vertical filter icons, a fixed capacity footer, item detail sheets, equipping, unequipping, consumption, and confirmed dropping.
- Lose one meal after every two normal journey events; starvation removes one 50-HP heart at subsequent hunger ticks.
- Rest only at checkpoints after choosing which food to consume.
- Reach the final three-stage encounter or lose the active run permanently.
- Keep only settings, cosmetic entitlements, and run-history summaries after death.
- Resume interrupted event and combat rolls without duplicating damage, ammunition, loot, or outcomes.
- Review finished runs and recovered lore in the Road Chronicle, including five cross-region human stories that return ordinary choices as consequential later chapters.

## Implemented content

- 6 sequential regions, 60 base region events, 12 base global events, a 13-scene Bunker Forty-One narrative arc, an 8-scene Mara Venn/Rust-Sea expansion, 1 safe fallback, a Bunker-aware 3-stage finale, 15 Living Road callbacks, and a 12-scene betrayal arc (Vex, Slate, Anselm): 124 events in the default release.
- Bespoke prose overrides are active for all 76 baseline events. The Road Chronicle exposes 29 reachable lore chapters alongside the latest twenty run summaries; the Living Road callbacks provide five recurring-human threads and ten mutually exclusive equipment rewards.
- 50 items (including two shields), 17 adversary archetypes, and 13 conditions/injuries, including checkpoint Momentum.
- Layered Dossier survivor HUD with heart/meal vitals, a tappable five-stat symbol capsule, persistent pressure strip, placeholder portraits/item runes, drawn D20, and tactical combat screen.
- Locally bundled Literata narrative and Inter interface fonts, with their OFL licences, for complete offline presentation.
- Data-driven weapons and adversaries, armor mitigation, ammunition fallback, critical effects, combat log, and flee rules.
- Offline schema-5 JSON saves with atomic replacement, backup recovery, idempotent run-only XP rewards, versioned prepared-roll recovery, and a death marker.
- Explicitly disabled launch-v1 ad and billing facades plus a deferred TypeScript purchase-verification backend.
- 7 original portrait region backgrounds and a scalable vector application icon.

## Run locally

1. Open this directory with Godot 4.7.2 Standard.
2. Run the project with F6/F5.
3. For automated checks, run the headless test entrypoint described in `docs/TESTING.md`.

The launch-v1 game has no network dependency, advertising, or purchases. Deferred Android monetization remains isolated behind disabled adapters until a tested post-launch release deliberately enables it and updates the store declarations.

## Project guides

- [Current implementation status](docs/PROJECT_STATUS.md)
- [Windows and Android setup](docs/ANDROID_SETUP.md)
- [Content authoring](docs/CONTENT_AUTHORING.md)
- [Monetization integration](docs/MONETIZATION.md)
- [Testing](docs/TESTING.md)
- [Four-week launch sprint](docs/LAUNCH_SPRINT.md)
- [Closed-test guide and feedback form](docs/CLOSED_TESTING.md)
- [Itch.io public-playtest packet](docs/E05_PLAYTEST_PACKET.md)
- [Release checklist](docs/RELEASE_CHECKLIST.md)
- [Balance workflow](docs/BALANCE_WORKFLOW.md)
- [Visual style guide](docs/UI_STYLE_GUIDE.md)
- [Google Play release roadmap](docs/RELEASE_ROADMAP.md)
- [Asset provenance](docs/ASSET_PROVENANCE.md)
- [Bunker Forty-One narrative map](docs/BUNKER41_NARRATIVE.md)
- [Story map: micro scenes, chains, and loot routes](docs/STORY_MAP.md)
- [Mega-Chain expansion progress](docs/MEGA_CHAIN_EXPANSION.md)
- [Living Road narrative bible](docs/LIVING_ROAD_NARRATIVE_BIBLE.md)

Combat rules 2 adds committed enemy tells, weapon signatures/mastery, shield builds and Manual/Quick Roll. Existing saved fights keep their legacy rules until they end. See [the implementation and measured balance report](docs/NARRATIVE_COMBAT_REPORT.md); Samsung testing remains required before release.
