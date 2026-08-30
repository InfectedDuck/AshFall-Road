# Content authoring guide

Gameplay content lives in `data/*.json`; UI scripts do not contain individual event outcomes. Restart the project after editing data, then run the headless tests before playing.

## Content budgets

- `regions.json`: 6 ordered regions, each with 10 regional event IDs.
- `events.json`: 60 regional events, 12 global events, 1 fallback, and 3 finale stages.
- `items.json`: 48 items across weapons, armor, accessories, backpacks, consumables, ammunition, and utility.
- `conditions.json`: 12 injuries/conditions.
- `adversaries.json`: 12 reusable threat definitions.

## Event rules

Every normal event needs an ID, title, body, positive integer weight, repeat policy, and 2–4 choices. A choice may contain item/stat/condition requirements, costs, an approach, and either a D20 check or a certain outcome.

D20 outcomes may define `success`, `failure`, `critical_success`, and `critical_failure`. If a critical-specific outcome is absent, the engine falls back to the ordinary success or failure. Consequences can change pressures and items, add/remove conditions, add flags, or name a follow-up event. Chains must stop within three stages.

Use `unique: true` for once-per-run events. Repeatable events automatically respect the engine's three-event cooldown. Eligibility can require/forbid flags or require items. Never manually add the fallback event to a regional pool; the selector supplies it only when nothing else is eligible.

## Item rules

- Equipment slots are exactly `weapon`, `armor`, `accessory`, and `backpack`.
- Ranged weapons declare `ammo_type`. Their modifiers are ignored when unloaded, and a combat approach consumes one compatible round.
- Armor uses `damage_reduction` against outcomes marked `damage_type: physical`.
- Backpacks use `capacity_bonus`.
- Modifiers may target a stat or named approach.
- Consumables may change pressures, remove conditions, or add a temporary condition.
- Positive temporary conditions use `duration_checks`; they tick after contributing to a check.

All referenced IDs must exist. The repository validator rejects missing event, item, condition, and outcome references before the main menu becomes playable.

## Balance review for each event

1. The body establishes enough information to choose without guessing.
2. Each choice communicates its cost, modifier, DC, and exact odds.
3. Failure is painful but not an unexplained instant death.
4. Different stat/equipment strategies receive meaningful opportunities.
5. The easiest choice is not automatically the best expected value.
6. Rewards match the region and do not invalidate survival pressure.
7. Eligibility cannot create a dead end.
8. Unique/repeat behavior is intentional.
9. Follow-up depth is three or less.
10. Teen-rated language and imagery remain non-graphic.

## Validation loop

Run the command in `docs/TESTING.md`. Then play at least one fixed seed twice with the same candidate and decisions. Both event order and rolls must match. When adding content, extend the assertions for counts and any new rule rather than relying only on manual play.
