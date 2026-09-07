# Save transactions: M02 handoff

Implemented and verified on 7 September 2026. This extends the existing combat transaction and JSON save service; it does not replace the save system or change combat, XP, item, or journey rules.

## Ownership and invariant

`scripts/services/combat_transaction.gd` is now the shared action boundary. Its historical filename and combat API remain compatible. **Use one transaction instance for the whole UI session**, including event, inventory, checkpoint, allocation, and combat screens. `main.gd` calls this instance `combat_transaction`.

The invariant is: prepare durably, resolve once, commit durably, then refresh or animate. A save error is not a successful action. UI must never call the domain mutation again to retry its save.

`GameEngine` remains authoritative for rules and deterministic RNG. `SaveService` retains temporary writes, flush/readback verification, primary/backup replacement, migrations, and the death marker. Transactions use deep RunState snapshots, not selected-field rollback.

## Transaction API

Production callers pass the current `game`, `saves`, and loaded `profile` dictionary. The same profile object is updated in place only after its profile write succeeds.

| API | Use | Success behavior |
|---|---|---|
| `prepare_event(game, saves, choice_index)` | Commit a concealed checked/certain event choice or enter a combat choice | Return the existing preparation result after saving |
| `resolve_event(game, saves, profile)` | Resolve the saved event choice | Return the authoritative event result after all required commits |
| `prepare(game, saves, action, item_id = "")` | Commit a combat action and concealed rolls | Preserve the existing combat preparation result |
| `resolve(game, saves, profile)` | Resolve the saved combat round | Return the existing presentation payload only after commit |
| `execute(game, saves, profile, operation, args = [])` | Immediate gameplay mutations listed below | Save an intent, apply it once, commit, then return domain output |
| `retry(game, saves, profile)` | Retry a retained action commit | Write retained state/receipt only; never reapply an in-memory operation |
| `recover(game, saves, profile)` | Startup, before showing Continue or New Run | Replay receipts, load the run, finish any immediate-action intent, then unlock |
| `flush(game, saves, profile)` | Background/exit or terminal finalization | Commit current state without applying an action; never consume another pending transaction |
| `is_locked()` | Gate gameplay/navigation | True during pending commit or incomplete startup recovery |

The legacy combat `resolve` convenience can retry an already-pending combat commit. New UI code must nevertheless use the explicit Retry API. Empty-profile compatibility loads the profile for real SaveService instances; do not rely on that compatibility path in production UI.

### Immediate operations

| Operation | Arguments | Allowed context |
|---|---|---|
| `equip` | `[item_id]` | Event, result, or checkpoint, outside combat |
| `unequip` | `[slot]` | Same |
| `drop` | `[item_id, quantity]` | Same; domain validates ownership/equipped protection |
| `use_item` | `[item_id]` | Same; includes treatment from the Status sheet |
| `rest` | `[food_item_id]` | Checkpoint; domain validates food and previous decision |
| `press_on` | `[]` | Checkpoint |
| `allocate` | `[proposed_stat_dictionary]` | Checkpoint; proposed values are final totals, not increments |
| `continue` | `[]` | Event result; includes travel, hunger, checkpoint XP, and next-event selection |
| `leave_checkpoint` | `[]` | Checkpoint after choosing Rest |

Combat item use and fleeing remain combat actions, not immediate inventory operations. Equipment remains unavailable during combat. Draft plus/minus allocation is presentation-only; only Confirm calls `allocate`.

`continue` also returns `survival_notice` for its toast. The transaction consumes nonfatal transient notices inside the commit. Fatal starvation retains its cause until the terminal summary is recorded; UI must not edit RunState to clear a toast.

## Failure semantics and crash recovery

### Preparation

Event/combat preparation snapshots the entire run before asking the domain to prepare. A domain error or unsuccessful save restores that snapshot, including RNG, costs, encounter identity, committed enemy move, and pending-roll data. No result is revealed. The user may attempt preparation again after fixing storage; it begins from the same prior state.

Immediate operations add an optional `pending_action` dictionary to the existing schema-5 RunState before mutation. It contains the whitelisted operation and a deep copy of its arguments. The saved run otherwise contains the exact pre-action state and RNG. If this intent cannot be written, the entire in-memory snapshot is restored and the operation is not applied.

### Resolution

After a prepared action or immediate intent resolves, the transaction holds its output in `pending_result` and retains the **resolved** in-memory RunState. Failure to save returns an error with `retry_save: true`. Nothing is animated or refreshed yet.

Retry first finishes the run write, then any profile receipt work. Stage booleans prevent repeating completed writes unnecessarily. Retrying cannot spend ammunition, consume food, award XP, increase a stat, add a Grit heart, deal damage, or distribute loot again.

After a process restart:

- A saved immediate-action intent resolves from its saved pre-action state exactly once. The next successful commit replaces the intent with the resulting state.
- A saved concealed event/combat roll remains concealed and uses its existing authoritative snapshot and rules version. It is not rerolled or silently resolved by startup.
- A saved resolved result resumes as that result, never as an unresolved choice.
- A saved terminal run or discovery-producing `last_result` can reconstruct its profile receipt if the process stopped between the run write and receipt creation.

No storage design can durably record a new user action when its first write fails. In that case this implementation explicitly rejects preparation and retains the previous state. If resolution saving fails and the process is killed, the previously committed preparation/intent is the deterministic recovery point; no uncommitted result was presented.

## Profile receipt protocol

`profile_update.json` uses the existing atomic writer and a `.bak` recovery file. One receipt may be outstanding at a time. A different receipt cannot overwrite it.

The receipt has its own schema version **1**, a stable `receipt_id`, and `updates`. The strict allowlist permits only:

- `discovered_story_nodes`, `discovered_characters`, `discovered_endings`: strings describing discoveries.
- `run_summary`: the existing terminal summary fields, including display names, result, progress, death cause, XP, equipment/condition names, and timestamp.

It rejects RunState, inventory stacks, survivor stat dictionaries, RNG, combat state, and other unknown fields. **It cannot be loaded as a living run.** Summary equipment is a list of names, not recoverable ownership.

Commit order:

1. Save the resolved active/terminal run.
2. Atomically write its profile-update receipt.
3. For death, atomically write the matching death marker without deleting the run yet.
4. Apply updates to a profile copy and atomically save that copy, including its applied receipt IDs.
5. Publish the saved profile copy in memory.
6. For death/victory, delete the active-run primary, backup, and temporary files; failures keep recovery locked.
7. Remove the receipt backup/temporary/primary; failures also keep recovery locked.
8. Mark the in-memory terminal run finalized and release its UI result.

Startup calls `replay_profile_updates` **before `load_run`**, so death-marker cleanup cannot silently discard a pending summary. Marker backup recovery also preserves death precedence if primary replacement was interrupted. A marker applies only to its matching run ID; starting a new run no longer clears the preceding death marker.

Receipt IDs are recorded in `applied_profile_update_ids` in the same profile write as the updates. Discovery chapters retain the existing chapter-variant replacement semantics; characters/endings remain unique. Completed runs also record a `completed:<run_id>` ID, so retries cannot increment deaths/victories again even after the corresponding summary ages out of the 20-entry history. Existing history run IDs prevent duplication during upgrade recovery.

An unreadable/invalid outstanding receipt is not silently discarded. Startup remains locked and asks the player to preserve the save files for recovery. Retry may succeed after a storage problem is fixed; it does not claim to repair arbitrary corruption.

## Required UI integration pattern

The reusable hooks in `scripts/ui/main.gd` are:

- `_run_gameplay_action(operation, args, on_committed)` for immediate mutations.
- `_accept_action_result(result, on_committed)` for transaction results, including event/combat resolution and startup.
- `_retry_pending_save()` for the recovery button only.
- `_gameplay_locked()` combines pending commits with event/combat animation locks.

Later UI tasks must follow these rules:

1. Keep the current inventory/detail/allocation screen and its draft visible while calling the transaction. Do not close, refresh, play a hit, or publish new stats in advance.
2. Supply an `on_committed` callback that **only presents** the supplied result and refreshes affected controls. It must never call the original gameplay operation or write another unsaved RunState change.
3. If the result contains `error` without `retry_save`, show the error and retain the current view. Domain results can also contain `success: false`; present their explanation rather than claiming the action succeeded.
4. If `retry_save` is true, retain that callback and show the shared exclusive recovery sheet. Its fixed 44-pixel-minimum Retry button remains reachable at compact/large-text sizes. There is no dismiss control.
5. Gate all actions, deferred callbacks, menu transitions, and overlay close/open operations with `_gameplay_locked()`. The shared `_button` helper does this by default; only the Retry button opts out. Guard direct signal handlers too.
6. Route Android Back through `_handle_back`; `quit_on_go_back` is disabled and `ui_cancel` is consumed while locked. Back must check the lock before closing any overlay. Do not create a second transaction to bypass a pending one.
7. Background/exit calls `flush`; if an action already awaits recovery it must leave that action and its UI callback alone. An OS force-close is handled on next startup, not prevented.
8. Once Retry succeeds, close the recovery sheet and invoke the retained callback once. Inventory and allocation then refresh from committed state. Draft Cancel/Keep for Later remain UI-only and unavailable during recovery.
9. Single-file preferences/tutorial dismissals use `_commit_profile_changes(changes)`: copy, attempt save, then publish. A failure keeps the previous profile and reports an error. This helper must not be used for authoritative discoveries or completed-run counters; those require receipts.

The noncritical `runs_started` display counter uses the same checked single-profile helper after the new run is saved. It is not a cross-file exactly-once receipt; a failed profile write is reported and does not invalidate the playable saved run. Completed-run history/death/victory counters have the stronger receipt guarantee described above.

## Schema and later-task boundaries

- Active-run schema remains **5**. `pending_action` is optional; absent means no immediate intent. Existing event/combat pending fields and legacy combat migration remain unchanged.
- Profile schema is **5**; entitlement schema remains **1**.
- New profile arrays: `contextual_tips_seen` and `applied_profile_update_ids`.
- Migrating a profile older than schema 5 with `tutorial_seen=true` dismisses the seven current tips. Otherwise tips start empty. Already-schema-5 partial progress is preserved.
- Current stable tip IDs: `checked_choice`, `event_preparation`, `enemy_heavy_sweep`, `defense_window`, `weapon_mastery`, `opportunity`, `checkpoint_allocation`.
- M08 still implements contextual prompt presentation. Use these IDs and checked profile updates; do not rerun legacy migration when recording a dismissal. Reading tips must not use gameplay RNG.
- M09 reads committed profile discoveries/history only; discoveries are never awarded from UI render callbacks, and the Chronicle shows only the content repository's enabled discovery entries.
- Receipt application appends discovery tokens and never removes an older variant of the same chapter. Two runs that ended a thread differently leave two tokens, and replay stays idempotent per token.
- Living Road and monetization remain disabled for launch. M02 does not enable staged content or introduce new balance changes.

## Verification evidence

Using the installed Godot 4.7.2 console executable, from the project directory:

| Command arguments | Result | Log |
|---|---|---|
| `--headless --path . --log-file builds/m02-tests.log --script tests/test_runner.gd` | **2,259 assertions, 0 failures**, exit 0 | `builds/m02-tests.log` |
| `--headless --path . --log-file builds/m02-action-ui.log --script tests/action_ui_smoke.gd` | **201 assertions, 0 failures**, exit 0 | `builds/m02-action-ui.log` |
| `--headless --path . --log-file builds/m02-combat-ui.log --script tests/combat_ui_smoke.gd` | **0 layout/input failures**, exit 0 | `builds/m02-combat-ui.log` |
| `--headless --path . --log-file builds/m02-combined-tests.log --script tests/test_runner.gd` | **2,262 assertions, 0 failures**, exit 0; final M02 plus concurrently completed M03 | `builds/m02-combined-tests.log` |

The original 2,037-assertion coverage remains included; three profile-version expectations were deliberately updated from 4 to 5. New fault-injection coverage is in `tests/action_transaction_tests.gd`, using isolated real atomic JSON files, and `tests/action_ui_smoke.gd`. M03 added three assertions while M02 was finishing; those concurrent edits were preserved, and the final shared-state rerun passes 2,262 assertions.

Coverage includes preparation rollback, all nine immediate operations, current/legacy event recovery, combat entry and existing combat transactions, Grit allocation, XP/food/item exactly-once recovery, discovery receipt replay, terminal run/receipt/profile/marker/cleanup failures, fatal event/medicine/travel/current-and-legacy-combat paths, death-marker/receipt backup recovery, startup locks, schema migration, and invalid receipt rejection.

UI checks cover allocation, inventory, drop confirmation, rest, event resolution, and combat resolution at 360x640, 540x960, and 540x1200 with Large text and Reduced Motion. They verify reachable shared Retry, unchanged originating sheets, blocked Back/background/other actions/profile changes, presentation only after commitment, and no duplicate callback. Combat's former in-screen Retry expectation was updated to the same modal recovery boundary, avoiding a stranded retry behind another overlay. The sandboxed UI runs emit a Windows root-certificate-store warning; offline tests still complete with the results above. The full suite runs with permission for isolated `user://` test saves.

**Not claimed:** a fresh Android export, Samsung physical-device interruption tests, real low-storage-device testing, or production certification. These remain release/device acceptance work; the automated failures simulate unsuccessful writes and process recreation.
