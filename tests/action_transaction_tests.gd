extends RefCounted
const Transactions = preload("res://scripts/services/combat_transaction.gd")
const Fixtures = preload("res://tests/narrative_combat_tests.gd")
var check: Callable
var content: ContentRepository

class FaultStore extends SaveService:
	var writes := 0
	var fail_run_at := -1
	var fail_run := false
	var fail_receipt := false
	var fail_profile := false
	var fail_marker := false
	var fail_clear := false
	var fail_cleanup := false
	func _init() -> void:
		prefix = "m02_%s_%s_" % [Time.get_ticks_usec(), get_instance_id()]
	func _path(file_name: String) -> String:
		return "res://builds/" + prefix + file_name
	func _atomic_write(path: String, value: Dictionary) -> bool:
		if path.ends_with("active_run.json"):
			writes += 1
			if fail_run or writes == fail_run_at: return false
		if fail_receipt and path.ends_with("profile_update.json"): return false
		if fail_profile and path.ends_with("profile.json"): return false
		if fail_marker and path.ends_with("death_marker.json"): return false
		return super._atomic_write(path, value)
	func _remove_if_exists(path: String) -> bool:
		if fail_clear and path.ends_with("profile_update.json"): return false
		if fail_cleanup and path.ends_with("active_run.json"): return false
		return super._remove_if_exists(path)
	func cleanup() -> void:
		fail_clear = false
		fail_cleanup = false
		for file_name: String in ["active_run.json", "active_run.backup.json", "profile.json", "profile_update.json", "death_marker.json"]:
			for suffix: String in ["", ".bak", ".tmp"]:
				_remove_if_exists(_path(file_name + suffix))


func run(repository: ContentRepository, assertion: Callable) -> void:
	content = repository
	check = assertion
	_prepared_events()
	_combat_entry()
	_immediate_actions()
	_terminal_receipts()
	_terminal_action_paths()
	_discovery_receipts()
	_startup_receipt_lock()
	_profile_migration()


func fixture() -> GameEngine:
	var factory := Fixtures.new()
	factory.content = content
	var game: GameEngine = factory.fixture()
	game.run_state["combat_state"] = {}
	game.run_state["pending_combat_round"] = {}
	game.run_state["phase"] = "event"
	game.run_state["current_event_id"] = "outskirts_bus"
	game.run_state["survivor"]["inventory"].merge({"runner_jacket": 1, "cloth_bandage": 3, "canned_meat": 2}, true)
	return game


func _prepared_events() -> void:
	for legacy: bool in [false, true]:
		var store := FaultStore.new()
		var profile := store.default_profile()
		var tx := Transactions.new()
		var game := fixture()
		var before := game.run_state.duplicate(true)
		store.fail_run = true
		check.call(tx.prepare_event(game, store, 0).has("error") and before == game.run_state, "Event prepare failure restores full state and RNG")
		store.fail_run = false
		check.call(not tx.prepare_event(game, store, 0).has("error"), "Event preparation commits concealed roll")
		if legacy:
			game.run_state["pending_resolution"]["rules_version"] = 2
			store.save_run(game.run_state)
		var prepared := store.load_run()
		var expected_game := GameEngine.new(content)
		expected_game.restore_run(prepared)
		var expected := expected_game.resolve_prepared_choice()
		store.fail_run = true
		check.call(tx.resolve_event(game, store, profile).get("retry_save", false), "Failed event commit withholds presentation, including legacy checks")
		var resolved := game.run_state.duplicate(true)
		tx.retry(game, store, profile)
		check.call(game.run_state == resolved and tx.is_locked(), "Event retry never rerolls or reapplies costs/rewards")
		check.call(tx.prepare_event(game, store, 1).has("error") and tx.execute(game, store, profile, "use_item", ["medkit"]).has("error"), "Event recovery locks every mutation category")
		store.fail_run = false
		var restarted := GameEngine.new(content)
		var restart_tx := Transactions.new()
		restart_tx.recover(restarted, store, profile)
		check.call(restarted.run_state["pending_resolution"] == prepared["pending_resolution"], "Startup preserves legacy/prepared event snapshot exactly")
		var replayed := restart_tx.resolve_event(restarted, store, profile)
		check.call(replayed == expected, "Restart resolves the same legacy or current event once")
		var retried := tx.retry(game, store, profile)
		check.call(_disk_equal(retried, expected) and game.run_state == resolved and not tx.is_locked(), "Successful event Retry releases only the retained result")
		store.cleanup()


func _combat_entry() -> void:
	var store := FaultStore.new()
	var tx := Transactions.new()
	var game := fixture()
	game.run_state["current_event_id"] = "outskirts_dogs"
	var before := game.run_state.duplicate(true)
	store.fail_run = true
	check.call(tx.prepare_event(game, store, 0).has("error") and before == game.run_state, "Combat-entry preparation rolls back encounter state, costs and RNG together")
	store.fail_run = false
	check.call(tx.prepare_event(game, store, 0).get("combat_started", false), "Combat-entry preparation succeeds through the shared event boundary")
	var committed: Dictionary = game.run_state["combat_state"].duplicate(true)
	var restarted := GameEngine.new(content)
	check.call(not Transactions.new().recover(restarted, store, {}).has("error") and _disk_equal(restarted.run_state["combat_state"], committed), "Restart preserves enemy commitment and encounter identity from event entry")
	store.cleanup()


func _immediate_actions() -> void:
	for operation: String in ["equip", "unequip", "drop", "use_item", "rest", "press_on", "allocate", "continue", "leave_checkpoint"]:
		var store := FaultStore.new()
		var profile := store.default_profile()
		var tx := Transactions.new()
		var game := fixture()
		game.run_state["survivor"]["vitals"]["health"] = 150
		game.run_state["survivor"]["vitals"]["satiety"] = 0
		game.run_state["survivor"]["pressures"]["fatigue"] = 60
		game.run_state["unspent_stat_points"] = 5
		var args: Array = []
		match operation:
			"equip": args = ["runner_jacket"]
			"unequip": args = ["weapon"]
			"drop": args = ["cloth_bandage", 3]
			"use_item": args = ["medkit"]
			"rest": args = ["canned_meat"]
			"allocate":
				var draft: Dictionary = game.run_state["survivor"]["stats"].duplicate()
				draft["grit"] = 10
				args = [draft]
		if operation in ["rest", "press_on", "allocate", "leave_checkpoint"]:
			game.run_state["phase"] = "checkpoint"
		if operation == "leave_checkpoint":
			game.run_state["checkpoint_action"] = "rest"
		if operation == "continue":
			game.run_state["phase"] = "result"
			game.run_state["events_in_region"] = 4
			game.run_state["hunger_clock"] = 1
		var before := game.run_state.duplicate(true)
		store.fail_run = true
		check.call(tx.execute(game, store, profile, operation, args).has("error") and before == game.run_state, operation + ": intent write failure rolls back all state")
		store.fail_run = false
		store.fail_run_at = store.writes + 2
		var result := tx.execute(game, store, profile, operation, args)
		check.call(result.get("retry_save", false) and tx.is_locked(), operation + ": resolved state waits for commit")
		var resolved := game.run_state.duplicate(true)
		check.call(not resolved.has("pending_action") and store.load_run().has("pending_action"), operation + ": disk retains replayable intent while memory retains resolved state")
		store.fail_run = true
		tx.retry(game, store, profile)
		check.call(resolved == game.run_state, operation + ": repeated failure never applies twice")
		check.call(tx.execute(game, store, profile, operation, args).has("error") and tx.prepare_event(game, store, 0).has("error"), operation + ": no other operation bypasses pending commit")
		store.fail_run = false
		var restarted := GameEngine.new(content)
		var fresh_tx := Transactions.new()
		check.call(not fresh_tx.recover(restarted, store, profile).has("error"), operation + ": startup completes the saved intent")
		var restored_state := restarted.run_state.duplicate(true)
		restored_state.erase("saved_at")
		check.call(_disk_equal(restored_state, resolved), operation + ": restart equals exactly-once state including RNG, XP, items and HP")
		check.call(not tx.retry(game, store, profile).has("error") and resolved == game.run_state, operation + ": original Retry releases unchanged outcome")
		if operation == "allocate":
			check.call(game.run_state["survivor"]["stats"]["grit"] == 10 and game.run_state["unspent_stat_points"] == 0 and game.run_state["survivor"]["vitals"]["health"] == 200, "Confirmed allocation and new Grit heart survive failure/restart once")
		if operation == "continue":
			check.call(not game.run_state.has("last_survival_notice"), "Nonfatal starvation toast clears inside the commit, not through a later unsaved UI mutation")
		store.cleanup()


func _terminal_receipts() -> void:
	for terminal: String in ["dead", "victory"]:
		for failure: String in ["run", "receipt", "profile", "marker", "clear", "cleanup"]:
			var store := FaultStore.new()
			var profile := store.default_profile()
			store.save_profile(profile)
			var game := fixture()
			game.run_state["phase"] = "death" if terminal == "dead" else "victory"
			game.run_state["status"] = terminal
			if terminal == "dead": game.run_state["survivor"]["vitals"]["health"] = 0
			store.save_run(game.run_state)
			store.set("fail_" + failure, true)
			var tx := Transactions.new()
			var result := tx.flush(game, store, profile)
			var should_fail := failure != "marker" or terminal == "dead"
			check.call(bool(result.get("retry_save", false)) == should_fail, terminal + ": " + failure + " failure is surfaced")
			if should_fail:
				check.call(tx.is_locked() and not game.run_state.get("finalized", false), "Terminal presentation remains locked until its records commit")
			var receipt: Dictionary = store._read_receipt()
			if not receipt.is_empty():
				check.call(store._valid_profile_receipt(receipt) and not receipt.has("run_state") and not receipt["updates"].has("rng_state") and receipt["updates"]["run_summary"]["survivor"] is String, "Terminal receipt contains only profile data; cannot restore a living survivor")
			store.set("fail_" + failure, false)
			# Simulate losing the transaction and profile objects at every boundary.
			var loaded_profile := store.load_profile()
			var restarted := GameEngine.new(content)
			var fresh_tx := Transactions.new()
			check.call(not fresh_tx.recover(restarted, store, loaded_profile).has("error"), terminal + ": startup recovers " + failure + " interruption")
			var counter := "deaths" if terminal == "dead" else "victories"
			check.call(int(loaded_profile[counter]) == 1 and loaded_profile["run_history"].size() == 1, "Terminal summary/counter survive exactly once after " + failure)
			check.call(store.load_run().is_empty() and store._read_receipt().is_empty(), "Terminal cleanup follows recoverable summary commit")
			fresh_tx.recover(restarted, store, loaded_profile)
			check.call(int(loaded_profile[counter]) == 1 and loaded_profile["run_history"].size() == 1, "Repeated startup never duplicates completed-run summary")
			if terminal == "dead":
				var living := fixture().run_state.duplicate(true)
				living["run_id"] = game.run_state["run_id"]
				store.save_run(living)
				check.call(store.load_run().is_empty(), "Death marker overrides a reappearing living primary/backup")
			store.cleanup()



func _terminal_action_paths() -> void:
	for mode: String in ["event_death", "event_victory", "medicine_death", "travel_death", "combat_death", "legacy_combat_death"]:
		var store := FaultStore.new()
		var profile := store.default_profile()
		var game := fixture()
		var tx := Transactions.new()
		if "combat" in mode:
			var factory := Fixtures.new()
			factory.content = content
			game = factory.fixture("road_bandits", "pipe_pistol")
			game.run_state["survivor"]["vitals"]["health"] = 1
			if mode == "legacy_combat_death":
				game.run_state["combat_state"]["combat_rules_version"] = 1
			tx.prepare(game, store, "attack")
			game.run_state["pending_combat_round"]["player_roll"] = 1
			game.run_state["pending_combat_round"]["enemy_roll"] = 20
			store.save_run(game.run_state)
		elif mode.begins_with("event"):
			var repository := ContentRepository.new()
			var terminal_outcome := {"text": "A terminal fixture.", "lethal": mode == "event_death", "victory": mode == "event_victory"}
			repository.events["m02_terminal"] = {"id": "m02_terminal", "choices": [{"label": "Continue", "outcome": terminal_outcome}]}
			game.content = repository
			game.run_state["current_event_id"] = "m02_terminal"
			tx.prepare_event(game, store, 0)
		elif mode == "medicine_death":
			game.run_state["survivor"]["vitals"]["health"] = 5
			game.run_state["survivor"]["inventory"]["stimulant"] = 1
		else:
			game.run_state["phase"] = "result"
			game.run_state["survivor"]["vitals"]["health"] = 50
			game.run_state["survivor"]["vitals"]["satiety"] = 0
			game.run_state["hunger_clock"] = 1
		store.save_profile(profile)
		store.fail_receipt = true
		var result: Dictionary
		if "combat" in mode: result = tx.resolve(game, store, profile)
		elif mode.begins_with("event"): result = tx.resolve_event(game, store, profile)
		else: result = tx.execute(game, store, profile, "use_item" if mode == "medicine_death" else "continue", ["stimulant"] if mode == "medicine_death" else [])
		check.call(result.get("retry_save", false) and not store.load_run().is_empty(), mode + ": terminal run retained until a profile receipt exists")
		var terminal_state := game.run_state.duplicate(true)
		tx.retry(game, store, profile)
		check.call(game.run_state == terminal_state, mode + ": failed terminal Retry cannot repeat damage, XP, food, or medicine")
		store.fail_receipt = false
		var restarted := GameEngine.new(game.content)
		var loaded_profile := store.load_profile()
		var recovered: Dictionary = Transactions.new().recover(restarted, store, loaded_profile)
		check.call(not recovered.has("error") and store.load_run().is_empty() and loaded_profile["run_history"].size() == 1, mode + ": terminal result reconstructs summary after a process restart")
		check.call(loaded_profile["run_history"][0]["result"] == ("victory" if mode == "event_victory" else "dead"), mode + ": correct terminal outcome recorded")

		# A death marker whose primary rename was interrupted still wins via backup.
		if mode == "medicine_death":
			var marker_path := store._path("death_marker.json")
			store._remove_if_exists(marker_path + ".bak")
			DirAccess.rename_absolute(ProjectSettings.globalize_path(marker_path), ProjectSettings.globalize_path(marker_path + ".bak"))
			var living := fixture().run_state
			living["run_id"] = terminal_state["run_id"]
			store.save_run(living)
			check.call(store.load_run().is_empty(), "Death marker backup prevents resurrection during marker replacement")
		store.cleanup()



func _discovery_receipts() -> void:
	var store := FaultStore.new()
	var profile := store.default_profile()
	var game := fixture()
	# Test synthetic definitions without enabling staged launch content.
	var repository := ContentRepository.new()
	repository.discovery_entries = {
		"test_chapter": {"event_id": "outskirts_bus", "characters": ["test_witness"]},
		"test_ending": {"event_id": "outskirts_bus", "category": "ending", "requires_flags": ["test_end"]},
	}
	game.content = repository
	game.run_state["last_result"] = {"event_id": "outskirts_bus"}
	game.run_state["flags"].append("test_end")
	game.run_state["phase"] = "result"
	store.save_run(game.run_state)
	store.save_profile(profile)
	store.fail_profile = true
	var tx := Transactions.new()
	check.call(tx.flush(game, store, profile).get("retry_save", false) and profile["discovered_story_nodes"].is_empty(), "Discovery failure does not publish uncommitted profile data")
	var receipt := store._read_receipt()
	check.call(not receipt.is_empty() and not receipt["updates"].has("run_summary"), "Living discovery receipt has no run snapshot")
	store.fail_profile = false
	store.fail_clear = true
	check.call(tx.retry(game, store, profile).get("retry_save", false), "Receipt cleanup failure still locks gameplay after profile write")
	var persisted_profile := store.load_profile()
	check.call(persisted_profile["discovered_story_nodes"].size() == 2 and persisted_profile["discovered_characters"] == ["test_witness"], "Discovery collections and completion receipt ID commit atomically")
	# Kill after profile write, before receipt removal; replay cannot duplicate.
	store.fail_clear = false
	var restarted := GameEngine.new(repository)
	check.call(not Transactions.new().recover(restarted, store, persisted_profile).has("error"), "Outstanding discovery receipt replays on startup")
	check.call(persisted_profile["discovered_story_nodes"].size() == 2 and persisted_profile["discovered_endings"].size() == 1, "Discovery replay remains idempotent")
	check.call(not store.write_profile_update_receipt({"schema_version": 1, "receipt_id": "invalid", "updates": {"run_state": game.run_state}}), "Receipt writer rejects a restorable run")
	# Recover receipt from the backup when primary rotation was interrupted.
	check.call(store.write_profile_update_receipt(receipt), "Known receipt can be staged again")
	DirAccess.rename_absolute(ProjectSettings.globalize_path(store._path("profile_update.json")), ProjectSettings.globalize_path(store._path("profile_update.json.bak")))
	check.call(store.replay_profile_updates(persisted_profile)["success"] and persisted_profile["discovered_story_nodes"].size() == 2, "Receipt backup survives interrupted file replacement without duplicate discoveries")
	store.cleanup()


func _startup_receipt_lock() -> void:
	var store := FaultStore.new()
	var game := fixture()
	game.run_state["status"] = "dead"
	game.run_state["phase"] = "death"
	game.run_state["survivor"]["vitals"]["health"] = 0
	store.fail_profile = true
	check.call(Transactions.new().flush(game, store, {}).get("retry_save", false), "Profile-free real-store flush still secures a terminal summary receipt")
	var restarted := GameEngine.new(content)
	var profile: Dictionary = {}
	var tx := Transactions.new()
	check.call(tx.recover(restarted, store, profile).get("retry_save", false) and tx.is_locked() and restarted.run_state.is_empty(), "Startup profile failure blocks run loading, including when a death marker exists")
	check.call(tx.prepare_event(restarted, store, 0).has("error") and tx.execute(restarted, store, profile, "continue").has("error"), "Startup receipt lock prevents every new gameplay operation")
	check.call(tx.retry(restarted, store, profile).get("retry_save", false) and profile["run_history"].is_empty(), "Failed startup Retry retains receipt without publishing an uncommitted summary")
	store.fail_profile = false
	check.call(not tx.retry(restarted, store, profile).has("error") and not tx.is_locked() and profile["deaths"] == 1 and profile["run_history"].size() == 1, "Successful startup Retry commits summary exactly once before releasing the menu")
	store.cleanup()


func _profile_migration() -> void:
	for tutorial_seen: bool in [false, true]:
		var store := FaultStore.new()
		var legacy := {"schema_version": 4, "tutorial_seen": tutorial_seen, "selected_theme": "night", "deaths": 3, "run_history": [{"run_id": "old"}], "discovered_story_nodes": ["old:chapter"], "combat_presentation": "quick"}
		store._atomic_write(store._path("profile.json"), legacy)
		var upgraded := store.load_profile()
		check.call(upgraded["schema_version"] == 5 and upgraded["contextual_tips_seen"] == (SaveService.CONTEXTUAL_TIP_IDS if tutorial_seen else []), "Schema five tutorial migration follows old tutorial-seen state")
		check.call(upgraded["selected_theme"] == "night" and upgraded["combat_presentation"] == "quick" and upgraded["deaths"] == 3 and upgraded["run_history"] == legacy["run_history"] and upgraded["discovered_story_nodes"] == ["old:chapter"], "Profile migration preserves settings/history/discoveries")
		upgraded["contextual_tips_seen"] = ["checked_choice"]
		store.save_profile(upgraded)
		check.call(store.load_profile()["contextual_tips_seen"] == ["checked_choice"], "Schema-five tips are not re-dismissed during later loads")
		store.cleanup()


func _disk_equal(a: Dictionary, b: Dictionary) -> bool:
	# JSON numbers load as floats; compare both states through that same boundary.
	return JSON.parse_string(JSON.stringify(a)) == JSON.parse_string(JSON.stringify(b))
