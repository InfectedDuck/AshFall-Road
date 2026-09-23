extends RefCounted
## Shared save-aware action boundary. The historical filename/API stays valid for
## combat callers. One instance must own ALL gameplay mutations in a UI session.
const Discovery = preload("res://scripts/domain/story_discovery.gd")

var pending_result: Dictionary = {}
var pending_operation := ""
var run_committed := false
var receipt: Dictionary = {}
var receipt_staged := false
var recovering_startup := false


func is_locked() -> bool:
	return recovering_startup or not pending_result.is_empty()


func prepare(game, store, action: String, item_id: String = "") -> Dictionary:
	return _prepare(game, store, game.prepare_combat_action.bind(action, item_id))


func prepare_event(game, store, choice_index: int) -> Dictionary:
	return _prepare(game, store, game.prepare_choice.bind(choice_index))


func _prepare(game, store, operation: Callable) -> Dictionary:
	if is_locked():
		return _locked_error()
	var before: Dictionary = game.run_state.duplicate(true)
	var result: Dictionary = operation.call()
	if result.has("error") or not store.save_run(game.run_state):
		game.restore_run(before)
		return result if result.has("error") else {"error": "Could not save the prepared action. Nothing was spent; free some storage and try again."}
	return result


func resolve(game, store, profile: Dictionary = {}) -> Dictionary:
	if is_locked():
		return retry(game, store, profile) if pending_operation == "combat" else _locked_error()
	return _resolve_once(game, store, profile, "combat", game.resolve_prepared_combat_round)


func resolve_event(game, store, profile: Dictionary) -> Dictionary:
	if is_locked():
		return _locked_error()
	return _resolve_once(game, store, profile, "event", game.resolve_prepared_choice)


## Immediate actions first save a small intent in RunState. A restart before the
## resulting commit replays this intent from its exact pre-action state and RNG.
func execute(game, store, profile: Dictionary, operation: String, args: Array = []) -> Dictionary:
	if is_locked():
		return _locked_error()
	var reason := _availability(game, operation)
	if not _valid_arguments(operation, args):
		return {"error": "Invalid gameplay operation arguments."}
	if not reason.is_empty():
		return {"error": reason}
	var before: Dictionary = game.run_state.duplicate(true)
	game.run_state["pending_action"] = {"operation": operation, "args": args.duplicate(true)}
	if not store.save_run(game.run_state):
		game.restore_run(before)
		return {"error": "Could not save the action. Nothing was changed; free some storage and try again."}
	return _resolve_intent(game, store, profile)


func _availability(game, operation: String) -> String:
	var phase := str(game.run_state.get("phase", ""))
	match operation:
		"equip", "unequip", "drop", "use_item":
			if phase not in ["event", "result", "checkpoint"] or not game.run_state.get("combat_state", {}).is_empty():
				return "Resolve the current roll or combat turn first."
		"rest", "press_on", "allocate", "select_talent", "trade", "leave_checkpoint":
			if phase != "checkpoint":
				return "This action requires a checkpoint."
			if operation == "leave_checkpoint" and str(game.run_state.get("checkpoint_action", "")) not in ["rest", "barter"]:
				return "Choose Rest, Barter, or Press On before leaving."
		"continue":
			if phase != "result":
				return "No event result is waiting."
		_: return "Unknown gameplay operation."
	return ""


func _resolve_intent(game, store, profile: Dictionary) -> Dictionary:
	var intent: Dictionary = game.run_state.get("pending_action", {}).duplicate(true)
	var operation := str(intent.get("operation", ""))
	var args: Array = intent.get("args", [])
	if not _valid_arguments(operation, args):
		recovering_startup = true
		return _retry_error("The pending action could not be read. Keep the save files for recovery.")
	return _resolve_once(game, store, profile, operation, func() -> Dictionary:
		game.run_state.erase("pending_action")
		var reason := _availability(game, operation)
		if not reason.is_empty():
			return {"success": false, "text": reason}
		match operation:
			"equip": return game.equip_item(str(args[0]))
			"unequip": return game.unequip_item(str(args[0]))
			"drop": return game.drop_item(str(args[0]), int(args[1]))
			"use_item": return game.use_item(str(args[0]))
			"rest": return game.rest_at_checkpoint(str(args[0]))
			"press_on": return game.press_on_from_checkpoint()
			"allocate": return game.confirm_stat_allocation(args[0])
			"select_talent": return game.select_talent(str(args[0]))
			"trade": return game.accept_trade(int(args[0]))
			"continue":
				game.continue_after_result()
				var notice := str(game.run_state.get("last_survival_notice", ""))
				# Consume the transient toast inside the same commit, not in UI.
				# Fatal starvation retains its cause for the terminal receipt.
				if str(game.run_state.get("status", "")) != "dead":
					game.run_state.erase("last_survival_notice")
				return {"success": true, "survival_notice": notice}
			"leave_checkpoint": game.leave_checkpoint()
		return {"success": true}
	)


func _resolve_once(game, store, profile: Dictionary, operation: String, resolver: Callable) -> Dictionary:
	# Older combat call sites may omit the profile. Real stores still secure its
	# receipt; lightweight domain-test stores can remain profile-free.
	if profile.is_empty() and store is SaveService:
		profile.merge(store.load_profile(), true)
	var before: Dictionary = game.run_state.duplicate(true)
	var result: Dictionary = resolver.call()
	if result.has("error"):
		# Legacy recovery errors may occur after costs were touched.
		game.restore_run(before)
		return result
	pending_result = result if not result.is_empty() else {"success": true}
	pending_operation = operation
	run_committed = false
	receipt_staged = false
	receipt = _profile_receipt(game, profile)
	return retry(game, store, profile)


## Retry ONLY commits retained state/receipts. Never call the domain mutation from
## a Retry button. Returned resolved output is released only after every commit.
func retry(game, store, profile: Dictionary = {}) -> Dictionary:
	if profile.is_empty() and store is SaveService:
		profile.merge(store.load_profile(), true)
	if recovering_startup:
		return recover(game, store, profile)
	if pending_result.is_empty():
		return {"error": "No save is waiting for retry."}
	if not run_committed:
		if not store.save_run(game.run_state):
			return _retry_error("Could not save the resolved action.")
		run_committed = true
	if not receipt.is_empty():
		if not receipt_staged:
			if not store.write_profile_update_receipt(receipt):
				return _retry_error("Could not secure the profile update.")
			receipt_staged = true
		var replay: Dictionary = store.replay_profile_updates(profile)
		if not bool(replay.get("success", false)):
			return _retry_error(str(replay.get("error", "Could not finish the profile update.")))
	elif str(game.run_state.get("status", "")) == "dead":
		# Compatibility for domain-only callers without a profile. Production UI
		# always supplies its loaded profile and uses the receipt path above.
		if not store.write_death_marker_and_delete(str(game.run_state["run_id"])):
			return _retry_error("Could not secure the death record.")
	elif str(game.run_state.get("status", "")) == "victory":
		if not store.delete_run_files():
			return _retry_error("Could not finish terminal run cleanup.")
	if not profile.is_empty() and str(game.run_state.get("status", "")) in ["dead", "victory"]:
		game.run_state["finalized"] = true
	var result := pending_result
	pending_result = {}
	pending_operation = ""
	receipt = {}
	receipt_staged = false
	run_committed = false
	return result


## Startup must finish receipts before loading a run. A committed terminal run or
## result can rebuild its receipt if the process stopped before receipt creation.
func recover(game, store, profile: Dictionary) -> Dictionary:
	recovering_startup = true
	if profile.is_empty():
		profile.merge(store.load_profile(), true)
	var replay: Dictionary = store.replay_profile_updates(profile)
	if not bool(replay.get("success", false)):
		return _retry_error(str(replay.get("error", "Could not recover the profile.")))
	var saved: Dictionary = store.load_run()
	game.restore_run(saved)
	recovering_startup = false
	if saved.is_empty():
		return {"success": true}
	if not saved.get("pending_action", {}).is_empty():
		return _resolve_intent(game, store, profile)
	var update := _profile_receipt(game, profile)
	if not update.is_empty() or str(saved.get("status", "")) in ["dead", "victory"]:
		pending_operation = "recovery"
		pending_result = {"success": true}
		run_committed = true
		receipt = update
		receipt_staged = false
		return retry(game, store, profile)
	return {"success": true}


## Allows background/exit flushing to join the SAME pending transaction.
func flush(game, store, profile: Dictionary) -> Dictionary:
	if is_locked():
		# Lifecycle events must not silently dismiss the Retry UI or its callback.
		return _locked_error()
	if game.run_state.is_empty() or bool(game.run_state.get("finalized", false)):
		return {"success": true}
	if profile.is_empty() and store is SaveService:
		profile.merge(store.load_profile(), true)
	pending_operation = "flush"
	pending_result = {"success": true}
	run_committed = false
	receipt = _profile_receipt(game, profile)
	receipt_staged = false
	return retry(game, store, profile)


func _profile_receipt(game, profile: Dictionary) -> Dictionary:
	if profile.is_empty() or game.run_state.is_empty():
		return {}
	var updates: Dictionary = {}
	var result: Dictionary = game.run_state.get("last_result", {})
	var next := profile.duplicate(true)
	if not result.is_empty():
		Discovery.apply_resolution(result, game.run_state.get("flags", []), game.content.get_discovery_entries(), next)
		for key: String in SaveService.DISCOVERY_COLLECTIONS:
			var added: Array = []
			for token: String in next.get(key, []):
				if token not in profile.get(key, []):
					added.append(token)
			if not added.is_empty():
				updates[key] = added
	var terminal := str(game.run_state.get("status", "")) in ["dead", "victory"]
	if terminal:
		updates["run_summary"] = game.summary()
	if updates.is_empty():
		return {}
	var receipt_id := str(game.run_state["run_id"]) + (":terminal" if terminal else ":discovery:" + JSON.stringify(updates).sha256_text())
	return {"schema_version": 1, "receipt_id": receipt_id, "updates": updates}


func _locked_error() -> Dictionary:
	return {"error": "Save recovery must finish before another action.", "retry_save": true}


func _valid_arguments(operation: String, args: Array) -> bool:
	match operation:
		"equip", "unequip", "use_item", "rest", "select_talent": return args.size() == 1 and args[0] is String
		"allocate": return args.size() == 1 and args[0] is Dictionary
		"trade": return args.size() == 1 and typeof(args[0]) in [TYPE_INT, TYPE_FLOAT]
		"drop": return args.size() == 2 and args[0] is String and typeof(args[1]) in [TYPE_INT, TYPE_FLOAT]
		"continue", "leave_checkpoint", "press_on": return args.is_empty()
	return false


func _retry_error(message: String) -> Dictionary:
	return {"error": message + " Free some storage, then RETRY SAVE. Your action will not be applied again.", "retry_save": true}
