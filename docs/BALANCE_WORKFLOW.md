# Balance workflow

Use four layers in this order: content validation, deterministic mathematical diagnostics, whole-run robustness evidence, then human play. Encounter, robustness, and human results are recorded separately in [RUN_VERIFICATION.md](RUN_VERIFICATION.md) and must never be quoted as one another. Human feedback cannot repair invalid math, and simulation cannot prove that a choice feels understandable.

Current combat tuning and matched random-play measurements: [DIFFICULTY_TUNING.md](DIFFICULTY_TUNING.md). The September 8 encounter tables predate this tuning.

## Commands

From the project root:

`C:\Users\ASUS\Applications\Godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tools/balance_report.gd`

The report prints:

- Success chances across representative effective stats and every difficulty.
- Every weapon's stat-5 displayed range and mean damage.
- Every armor piece against the same incoming hit.
- Every adversary's HP, raw mean damage, armor-3 mean damage, and flee tier.
- Every adversary's authored combat XP and mean incoming damage.
- Cautious, selective-fighter, and aggressive-survivor XP/level projections.
- Regional supply-event counts and best authored satiety route.

## Tuning sequence

1. Validate that displayed percentages and D20 faces agree exactly.
2. Compare weapon mean damage, ammunition dependence, weight, and non-combat modifiers.
3. Compare enemy turns-to-kill against 200, 300, and 400 HP with armor ratings 0, 3, and 5.
4. Check Block and Dodge mitigation after armor, not before it, and keep final damage at least one. Guard applies only to legacy rules-version-1 fights still in flight.
5. Compare each regional expected drain in HP, satiety, Fatigue, Radiation, and ammunition with its supply opportunities.
6. Inspect choices where one path has both a higher chance and a better consequence without a meaningful cost.
7. Confirm cautious survival reaches 3–4 points, selective combat 5–6, and an exceptional aggressive survivor 6–7.
8. Compare XP against expected HP, ammunition, Fatigue, and condition costs; moderate threats should have the best practical return.
9. Change one subsystem at a time, rerun the automated suite/report, then verify on the phone.

## Provisional launch targets

- The first event is non-combat and the first two events expose both resource and equipment learning.
- Good supply play can avoid starvation; poor supply play eventually costs hearts.
- Strong gear defeats weak enemies in roughly two to three attacks.
- High threats defeat an unarmored four-heart survivor in roughly two to three hits.
- Armor and well-timed defenses extend survival, but ongoing rules-2 exchanges add 3 Fatigue; aimless defense should accumulate strain and eventually lose. The original 20–30-round Guard target applies to legacy rules-1 fights.
- Approximately 50-70% of new testers reach Region 2.
- Target roughly one victory per 20–30 attempts (about 3–5%) for new but system-aware players. Measure this through real complete attempts; do not manufacture it with hidden odds or inaccurate D20 targets.
- Repeated informed play should improve completion without permanent power upgrades.
- Fleeing remains rational against severe/apex threats, while manageable fights provide meaningful XP acceleration.
- At least 80% of tester deaths can be explained as a consequence of decisions.

Treat cohort percentages as directional until the sample is much larger than the required closed-test group.
