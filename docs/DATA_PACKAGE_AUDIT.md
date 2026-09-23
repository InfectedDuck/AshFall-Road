# Integrated data-package audit

Date: 7 September 2026. Scope: the launch configuration produced by M03–M09.

Command:

`C:\Users\ASUS\Applications\Godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/data_package_audit.gd`

The tool is read-only. It repairs nothing and regenerates no snapshot; it exits 1 if any check fails so it can gate a build.

Result at M10: 8 automated checks, 8 passed, 0 discrepancies. M11 added check 9 and found a stranding event. **Current result: 9 checks, 9 passed, 0 discrepancies** — N04 gave `global_stranger` an ungated third choice, closing the last one. Supporting suites at the same commit: regression **2,444 assertions, 0 failures**; compact-screen layout **624 assertions, 0 failures**; combat UI **0 layout/input failures**; save-recovery UI **201 assertions, 0 failures**.

## Checks

| # | Check | Verified | Result |
|---|---|---|---|
| 1 | Polished prose is loaded | All 76 baseline events; every override body and outcome string equals the live text in the default release | Pass |
| 2 | No prohibited repeated sentences | Prohibited filler and any reused sentence of six or more words across all 112 default-release events | Pass |
| 3 | All fifty items have routes | 16 starting IDs plus every positive reward in the default package; 50 items defined, 0 unreachable | Pass |
| 4 | Added choices are legal | Every event at four choices or fewer; labels present and unique per event; named difficulties only, no numeric target; every choice resolves to an outcome or combat | Pass |
| 5 | Original indices and mechanics | Live mechanics equal `data/events.json` for every event once prose is stripped, and every choice keeps its authored index and label | Pass |
| 6 | Default callbacks and explicit compatibility | `living_road_enabled=true`; default repository has 112 events and 15 callbacks; `new(false)` retains 97 events and 11 chapters | Pass |
| 7 | Lore discoveries reachable | 26 default-release chapters each have a loaded event and producible flags; compatibility retains 11 chapters | Pass |
| 8 | No unknown references | Item, condition, adversary, follow-up event, and icon IDs across every choice, cost, requirement, and outcome; icons unique per item | Pass |
| 9 | Every event is resolvable | No event gates all of its choices behind an item, which would strand a run on disabled buttons | Pass (added by M11, failing until N04 repaired it) |
| 10 | Documentation matches | Schema numbers, combat terminology, and player-facing naming against the code | 7 discrepancies, all fixed |

## Discrepancies found and fixed

M10 found nine discrepancies and all were documentation-only, so nothing was returned to an owning mini-plan. The content defect in check 9 was found later, by M11's whole-run soak, and is recorded under Release blockers below.

| Document | Discrepancy | Fix |
|---|---|---|
| `NARRATIVE_COMBAT_REPORT.md` | Header stated profile schema 4; the code has been 5 since M02 | Corrected, and D20 rules 3 and experience rules 1 added |
| `LAUNCH_SPRINT.md` | Locked v1 scope said "preserve schema 4" | Now names the current schemas: active run 5, profile 5, entitlements 1 |
| `TESTING.md` | Coverage line claimed "schema-4 profile migration" | Corrected to schema-5 run and profile migration |
| `TESTING.md` | Manual step 26 referred to the Road Ledger screen and treated Bunker/Rust-Sea discoveries as callback-only | Rewritten for ROAD CHRONICLE and the ten chapters that ship in v1, plus a check that accounts accumulate |
| `TESTING.md` | "Road Ledger idempotency" in the coverage list | Renamed to Road Chronicle |
| `IMPLEMENTATION_QUEUE.md` | Configuration list said the whole Road Ledger is unavailable in v1 | Now says the fifteen callback chapters are unavailable and the other ten ship |
| `CONTENT_AUTHORING.md` | Section named for the old screen | Renamed to Road Chronicle discoveries, keeping `road_ledger.json` as the authoring file name |
| `BALANCE_WORKFLOW.md` | Tuning step 4 and a launch target used Guard as current combat terminology | Now Block and Dodge, noting Guard applies only to legacy rules-version-1 fights still in flight |

Dated milestone records in `PROJECT_STATUS.md` were left as written. They describe what was true on the day of that milestone and are not current-state claims.

## Open items carried forward

These are known, recorded, and not release blockers. They belong to content work rather than this audit.

- `bunker41_cartographer` choice 0, "Share a ration with Mara", deducts no item. Found by M04, deliberately left out of M05 because that plan named the five events it could change. Fixing it needs a `costs` entry, which this audit may not add.

## Release blockers

`tools/release_readiness.gd` reports **7 blockers**, all owner or publishing tasks. M11's eighth, the `global_stranger` stranding defect, was repaired by N04: the scene now offers an ungated third choice, "Press the wound with your own coat", so a survivor carrying neither supply always has a legal action. This audit passes on it.

1. Choose the permanent reverse-domain package identifier.
2. Configure the release upload keystore.
3. Configure the release upload-key alias.
4. Create and host the completed privacy policy.
5. Add `assets/store/icon_512.png`.
6. Add `assets/store/feature_graphic_1024x500.png`.
7. Add at least two real-device screenshots under `assets/store/screenshots`.

## Limits of this audit

- Check 5 proves that loading changes no mechanics and that every authored choice keeps its index and label. It compares the live package against `data/events.json`, not against a version-control baseline, because the working tree already carried uncommitted work before this sequence began. The exact appended M05 routes are recorded separately in the mechanical-change allowlist in `CONTENT_AUTHORING.md`.
- The audit reads the data package. It does not measure balance, and it is not evidence of physical-device acceptance; both remain their own gates.
