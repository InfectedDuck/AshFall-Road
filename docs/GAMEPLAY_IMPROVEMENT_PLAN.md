# Ashfall Road — gameplay improvement plan

Written 19 October 2026. Goal: make events quicker to read and easier to understand, and make combat reward reading the enemy instead of pressing Attack.

The plan is split into small tasks. Give a coding agent **one task per session**: paste the shared context block, then the task. Every task lists the files involved, what "done" means, and how to check it.

---

## 1. What is wrong today (measured, not guessed)

**Combat: attacking every turn is almost as good as playing well.**

- The project's own benchmark ([DIFFICULTY_TUNING.md](DIFFICULTY_TUNING.md)) reports standard-row win rates: **attack-only 75.7%**, **reading the enemy 84.6%**. Skill is worth about 9 points, so mashing Attack is a safe strategy.
- Why ([narrative_combat.gd](../scripts/domain/narrative_combat.gd), [combat_content.json](../data/combat_content.json)):
  - The enemy acts every exchange whatever the player does, so attacking simply trades blows.
  - Heavy hits only for ×1.5. Brace only halves your damage. Recover gives only +25%.
  - A successful Block or Dodge prevents damage but deals none; its reward (Riposte / Opening, +10–20 accuracy) is small.
  - The enemy's intention is shown as a line of small 12px text ("CommittedEnemyTell" in [combat_presentation.gd](../scripts/ui/combat_presentation.gd)). It is easy to ignore.

**Events: you cannot tell what a choice will get you.**

- Event text has a median of 75 words, with 8 events over 150 words (153 events total), and each result adds more prose.
- Each choice button shows its label, guaranteed cost and success chance ([main.gd `_show_event`](../scripts/ui/main.gd)), but **not what you can gain or lose**. Players pick blind, so the choice feels meaningless.
- Some events are weak because every option leads to a small or similar result.

---

## 2. Targets

| Area | Measure | Today | Target |
|---|---|---|---|
| Combat skill | Attack-only win rate (standard rows, `tools/combat_balance.gd`) | 75.7% | **≤ 55%** |
| Combat skill | Read-the-tells win rate | 84.6% | **≥ 80%** (keep it) |
| Combat length | Exchanges per normal fight | — | 4–8 |
| Events | Body text words | median 75 | **median ≤ 55, none > 110** |
| Events | Choices that show their stakes | 0% | **100%** |
| Feel | Playtesters who say fights need thought (5 testers) | — | **≥ 4 of 5** |

---

## 3. Shared context — paste this at the start of every coding session

```text
Project: Ashfall Road, a post-apocalyptic survival text RPG made in Godot 4.7.2 (GDScript), portrait mobile layout (393x852 logical), Windows and Android builds.
Key files:
- scripts/domain/game_engine.gd: run state, events, choices, previews
- scripts/domain/narrative_combat.gd: combat rules v3 (preview, prepare, resolve, enemy moves, traits)
- data/combat_content.json: enemy move numbers (strike, heavy, sweep, brace, recover, charge)
- data/adversaries.json: enemies, move sequences, tells
- data/events.json + data/narrative_overrides_v11.json (+ other *_events.json): event text and choices
- scripts/ui/main.gd: screens, event page (_show_event), choice buttons
- scripts/ui/combat_presentation.gd: combat screen
- tests/test_runner.gd: automated tests
- tools/combat_balance.gd: combat policy benchmark (attack_only, read_tells, ...)

Rules:
1. Saves must keep working. combat_state is saved mid-fight and fights already store "combat_rules_version". Never change v3 behaviour for an existing saved fight; put new combat rules behind a new version (v4) used only by new fights.
2. Content is data-driven. Prefer adding fields to JSON over hard-coding text.
3. Touch targets are at least 44 px. Everything must work with a mouse and with touch.
4. Every task adds or updates tests in tests/test_runner.gd.
5. Before finishing, run:
   C:\Users\ASUS\Applications\Godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe --headless --path . --script res://tests/test_runner.gd
   and report the final "Assertions: N | Failures: 0" line. Do not finish with failures.
6. Change only what the task asks. Explain what you changed in a short list at the end.
```

---

## 4. Tasks

Sizes: **S** = under an hour of agent work, **M** = a few hours. Do them in order inside each phase. Phases A and B are independent and can run in parallel.

### Phase 0 — Baseline (do first)

**T0.1 · S · Record the combat baseline**
- Run `tools/combat_balance.gd` and save its summary table to `docs/baselines/combat_baseline_2026-10.md`.
- Done when the file lists, per enemy, the win rate for `attack_only`, `random_actions` and `read_tells`, and a "skill gap" column (`read_tells − attack_only`).

**T0.2 · S · Add a "skill gap" line to the benchmark**
- In `tools/combat_balance.gd`, print one summary line: average attack-only win rate, average read-tells win rate and the gap.
- Done when the tool prints the line and the existing tests still pass. Every later combat task uses this number.

### Phase A — Make choices understandable

**A1 · M · Show the stakes on every choice**
- In `game_engine.gd` `get_choice_preview`, build a `stakes` summary from the choice data:
  - "Could gain": items or positive changes in `success` (or `outcome`)
  - "Could lose": negative items, damage, pressures or conditions in `failure`
- In `main.gd` `_show_event`, add one short line under each choice, e.g. `Could gain: Bandages, Rad Tabs · Risk: lose Scrap`. Use item names; keep it to about 60 characters and end with "…" if longer.
- Combat choices show `Fight: <enemy name>`.
- Done when every choice row on the event screen shows a stakes line, and a test checks the stakes for `outskirts_market` choice 0 (gain Cloth Bandage and Rad Tabs, risk Scrap Parts).

**A2 · S · Put the result first, prose second**
- After a choice resolves, the receipt of what changed (items gained or lost, HP, pressures, conditions) appears at the **top** of the result screen as icon rows. The story text sits below it.
- Done when a screenshot of a result screen shows the receipt above the prose, and a test checks the node order.

**A3 · S · Add a text-budget audit tool**
- New tool `tools/text_budget_audit.gd` lists, for the default release content, every event body over 70 words and every outcome text over 40 words, sorted longest first, with event ids.
- Done when it runs headless and writes `docs/baselines/text_budget.md`.

**A4 · M (repeatable) · Trim 10 events per session**
- Take the next 10 events from `text_budget.md` and rewrite their body and outcome text in `narrative_overrides_v11.json` (the file the default release loads):
  - Body: 35–60 words. The first sentence states the situation and the danger.
  - Outcome: at most 30 words. Say what concretely happened.
  - Keep the tone, the names and every mechanical field unchanged.
- Done when those 10 events meet the budget and `tools/data_package_audit.gd` still passes. Repeat until the audit list is empty.

**A5 · S · One-line situation summary**
- Add an optional `summary` field to events (at most 12 words, e.g. *"Traders, a working scanner, and too little scrap."*). Show it in bold above the body.
- Fill it in for the first 15 events a new run can meet (tags `opening_*`).
- Done when the summary renders, is optional (events without one look unchanged), and a test checks one event.

**A6 · S · Faster reading**
- Check that one tap finishes the typewriter animation and a second tap reveals the choices. Add a "Story text speed: Instant" option if it is missing, and make "Fast" the default for new profiles.
- Done when a test confirms the default and the instant option.

**A7 · M · Find and fix dull events**
- New tool `tools/dull_event_audit.gd` flags events where:
  - all choices give rewards of similar small value, or
  - a choice has no item, pressure, condition or flag change at all, or
  - success and failure produce the same rewards.
- Write the list to `docs/baselines/dull_events.md`. For the top 10, give every event at least one choice with a clear, different consequence: a better item, a companion flag or a real risk.
- Done when the top 10 are fixed and the audit list is shorter.

### Phase B — Make reading the enemy matter (combat rules v4)

**B1 · S · Combat rules version 4 switch**
- Add `VERSION := 4` in `narrative_combat.gd`. New fights start on v4; saved v3 fights keep v3 behaviour. Add a helper `is_v4(game)`.
- Done when a test shows that a new fight is v4, a loaded v3 fight stays v3, and nothing else changes yet.

**B2 · M · Stronger telegraphs (v4 only)**
- **Heavy:** ×2.0 damage. If you attack into it, it also applies the enemy's `critical_condition` on a hit. A successful Dodge fully negates it and grants Opening.
- **Sweep:** a successful Block fully negates it and grants Riposte.
- **Brace:** attacking deals 30% damage and the enemy answers with a quick counter (about 60% of a strike). Blocking or dodging during Brace instead recovers 6 Fatigue ("you catch your breath"). *(Tuned in B6; see `combat_v4_balance.md`. Was 35% / ~50%.)*
- **Recover:** the enemy deals **no damage**; attacks get +50% damage.
- Put the numbers in `combat_content.json` under a `v4` block, not in code.
- Done when tests cover each of the four moves × attack/defend, and v3 tests still pass.

**B3 · M · Momentum and Finisher**
- Each correct read adds 1 Momentum (maximum 3). Correct reads are: a successful defend against Heavy or Sweep, attacking during Recover, or defending during Brace. A wrong read resets Momentum to 0.
- At 3 Momentum, a **Finisher** button appears: a guaranteed hit at ×3.0 damage that spends the Momentum. *(Tuned in B6; see `combat_v4_balance.md`. Was ×2.5.)*
- Show Momentum as 3 pips next to the enemy intent.
- Save Momentum in `combat_state` so a restart mid-fight keeps it.
- Done when tests cover gaining, resetting, saving/loading and the Finisher.

**B4 · M · Readable enemy intent**
- Replace the small tell text with a large intent chip above the action buttons, showing an icon, the move name, a colour and the expected damage:
  - **HEAVY** (red, "Big hit • ~40")
  - **SWEEP** (orange, "Wide hit • ~20")
  - **BRACE** (blue, "Guarding")
  - **RECOVER** (green, "Open!")
  - **CHARGE** (yellow, "Building up")
- Keep the full tell text available by tapping the chip.
- On each action button, show the expected result for this turn, e.g. `Attack • you take ~40` / `Dodge 70% • take 0`.
- Done when the chip renders for every move id, and a layout test confirms nothing overflows at 393 px width.

**B5 · S · Show the next move**
- The enemy sequence is fixed and known to the game, so show the *next* move as a small grey icon after the current one ("then: SWEEP"). Survivors with Wits ≥ 6 see two moves ahead.
- Done when tests cover both cases.

**B6 · M · Rebalance with the benchmark**
- Update the `read_tells` policy in `tools/combat_balance.gd` to use the v4 rules: defend Heavy/Sweep, attack Recover, defend Brace, use the Finisher.
- Tune only the `v4` numbers in `combat_content.json` and, if needed, enemy HP, until:
  - attack-only is **≤ 55%** on average
  - read-tells is **≥ 80%**
  - no standard fight averages more than 9 exchanges
- Record before/after in `docs/baselines/combat_v4_balance.md`.
- Done when the targets are met and recorded.

**B7 · S · First-fight lesson**
- The first combat of a new profile (usually Feral Dogs) shows three short prompts at the right moments: "It is winding up a HEAVY — Dodge!", "It is RECOVERING — attack now!", "Momentum full — use your Finisher!". Each shows once per profile and can be turned off with the existing contextual tips setting.
- Done when a test confirms the prompts appear once and respect the setting.

### Phase C — Short interactive moments (optional skill layer)

Rules for every mini-game:
- At most 3 seconds and tap-only.
- Stats still matter: a higher stat gives a bigger target zone.
- It **modifies** the dice roll instead of replacing it.
- It can be turned off in Settings ("Reaction prompts: On / Off"). When off, or during automated tests and the balance tool, it resolves as a normal "Good" result so results stay deterministic.

**C1 · M · Reusable timing bar**
- New widget `scripts/ui/minigames/timing_bar.gd`: a marker sweeps across a bar and the player taps. Returns `perfect`, `good` or `miss`. Zone width and speed are parameters.
- The logic is a pure function of elapsed time and tap time, so it can be tested without real time.
- Done when tests cover all three results and the zone sizes.

**C2 · M · Parry and dodge timing**
- When the player chooses Block or Dodge against Heavy or Sweep (v4), show the timing bar for about 1.2 seconds:
  - **Perfect:** automatic success, plus Riposte/Opening, plus 1 extra Momentum.
  - **Good:** the normal roll.
  - **Miss:** the normal roll at −15 percentage points.
- Zone width scales with Agility (Dodge) or Strength (Block).
- Done when it works on touch and mouse, respects the Settings switch, and the balance tool runs with it off.

**C3 · S · Weak-point taps**
- When attacking during Recover, or with Opening, 1–3 marks flash on the enemy portrait for 1.2 seconds. Each tapped mark adds +15% damage to this attack. Wits adds a mark.
- Done when the bonus applies, the marks never cover the action buttons, and it respects the Settings switch.

**C4 · M · Lockpick moment for events**
- Add an optional choice field `"minigame": "lockpick"`. Before the d20 roll, show a dial: rotate (drag or tap arrows) to the sweet spot within 3 seconds.
  - Success gives advantage: roll twice and keep the higher.
  - Failure gives the normal roll.
  - Wits sets the sweet-spot size.
- Add the field to 5 existing locked-cache or door choices.
- Done when those 5 choices use it and the Settings switch bypasses it.

**C5 · M · Radio tuning moment**
- Add `"minigame": "radio"`: drag a slider until the static clears (a waveform shows the signal), then confirm. The effect works like C4. Use it on radio and signal events (search the event text for "radio" and "signal"; pick up to 5).
- Done when those events use it and the Settings switch bypasses it.

**C6 · S · Settings and accessibility**
- Settings: Reaction prompts On/Off, plus a "Slower prompts" option (+50% time, +30% zone width).
- Done when both options are saved in the profile and applied by C2–C5.

### Phase D — Playtest loop

**D1 · S · Local play log**
- Record, per run, into a JSON file in the user data folder:
  - per fight: the share of each action used, exchanges, win/lose, and whether Momentum/Finisher was used
  - per event: time from showing the choices to choosing
- No network. Add a Settings button "Export play log" that copies the file path.
- Done when a test run writes the log.

**D2 · S · End-of-run questions**
- After death or victory, ask 3 optional one-tap questions: *"Did fights need thought?"* (Yes/Somewhat/No), *"Were choices clear?"*, *"Which event do you remember?"* (free text, optional). Save the answers in the play log.
- Done when the answers are saved and the screen can be skipped.

**D3 · Human playtest**
- Send the build to 5 testers. Collect play logs. Check the targets in section 2: the attack share per fight should drop and the "needed thought" answers should rise. Fix the most common complaint first.

---

## 5. Suggested order

1. T0.1, T0.2: measure.
2. A1, A2: biggest clarity win, small work.
3. B1, B2, B4, B6: biggest combat win.
4. B3, B5, B7: make good play feel rewarding.
5. A3–A7: text cleanup in batches.
6. C1, C2, C6: the first mini-game, in combat, where it matters most.
7. D1, D2, then the playtest.
8. C3–C5: more mini-games, only if testers like C2.

Rebuild the itch.io playtest zips after steps 3 and 6, so testers can compare.

## 6. Ideas parked for later

- Enemy "weak point" items: specific consumables that are strong against specific traits (some already exist, e.g. spark lance against the Cable Eater). Show the hint in the intent chip when the player carries one.
- Stamina for attacking: attacks cost Fatigue and defending restores it. Only if B2/B3 are not enough.
- Short combat "stances" chosen before a fight (aggressive, careful, evasive) that change the timing-bar zones.
- Companion assists: a companion flag unlocks one once-per-fight special action.
