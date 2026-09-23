# Ashfall Road 0.2.0 public-playtest packet

Prepared 15 September 2026 for the free itch.io playtest. This packet is ready for an upload; it does not publish a page or make claims about unrun device checks.

## Build and page details

- **Build label:** `0.2.0-playtest`
- **Package:** `builds/android/ashfall-road-debug.apk`
- **Format:** downloadable Android portrait game
- **Price:** free public playtest / in development
- **Short description:** A survival text RPG about dangerous choices, scarce supplies, and the people you meet on the road to safety.
- **Tags:** text-based, interactive fiction, survival, post-apocalyptic, choices matter
- **Cover:** [ashfall_road_itch_cover_v1.png](../art_sources/marketing/ashfall_road_itch_cover_v1.png). It is generated promotional key art, not a gameplay screenshot.

Use the opening copy and three real screenshots specified in [ITCH_LAUNCH_KIT.md](ITCH_LAUNCH_KIT.md). The page must state that the game is an Android download and must not promise romance, a browser build, or save reliability beyond the checks that have actually passed.

## Player invitation

> Ashfall Road is a post-apocalyptic survival text RPG about hard choices, scarce supplies, and the people you meet on the way to safety. Try the first ten minutes of this free playtest and tell me where you felt invested, confused, or ready to stop.

Players can reveal text instantly by double-tapping the narrative. Choices show guaranteed costs before selection; uncertain rolls and combat results remain separate. Death ends the active run, while settings and Chronicle memories remain.

## Feedback request

Ask every tester these five questions:

1. Which first decision made you care, if any?
2. Did a later scene acknowledge a decision you remember making?
3. Was any cost, condition, reward, or locked choice unclear?
4. Where did you stop playing, and why?
5. What one change would make you want another run?

For a complete-run report, also ask which ending they reached, whether its evidence felt earned, whether a death or result receipt was understandable, and whether text or controls failed at their device's font size.

Use this report template:

```text
Device / Android version:
Build: 0.2.0-playtest
Minutes played:
Last event or screen reached:
Choice or person remembered:
Confusing cost, result, or control:
Bug steps (if any):
One change I would make:
```

## Release checks and limits

- The default content configuration is the expanded release: 112 events, 26 Chronicle chapters, and 17 adversaries. `ContentRepository.new(false)` is retained only for compatibility regression checks.
- Before uploading, run the current regression suite, data-package audit, layout smoke test, and a clean-device launch/save/resume/playthrough check. Record the APK SHA-256 and device result with the feedback reports.
- Automated headless checks cannot verify disk-save and UI paths in the restricted workspace session. Treat physical-device save/resume and full-journey testing as a required pre-upload check, not a known-passing claim.
- Do not publish the itch.io page, send promotion, or collect personal information as part of this packet. The project owner performs those external actions after reviewing the built APK and device evidence.
