extends SceneTree

var failures := 0
var assertions := 0


func _init() -> void:
	call_deferred("_run_all")


func _run_all() -> void:
	print("Ashfall Road headless tests")
	var content := ContentRepository.new()
	_test_content(content)
	_test_d20()
	_test_candidates(content)
	_test_inventory_and_pressures(content)
	_test_ammunition_and_temporary_conditions(content)
	_test_determinism(content)
	_test_prepared_resolution_recovery(content)
	_test_complete_run(content)
	_test_save_and_death_marker(content)
	print("Assertions: %d | Failures: %d" % [assertions, failures])
	quit(1 if failures > 0 else 0)


func _test_content(content: ContentRepository) -> void:
	_check(content.validate_all().is_empty(), "All content references and choice counts are valid")
	_check(content.regions.size() == 6, "Six regions are defined")
	_check(content.items.size() == 48, "Forty-eight items are defined")
	_check(content.conditions.size() == 12, "Twelve conditions are defined")
	_check(content.adversaries.size() == 12, "Twelve adversaries are defined")
	_check(content.events.size() == 76, "Sixty regional, twelve global, one fallback, and three final events are defined")
	var pooled: Array = []
	for region: Dictionary in content.ordered_regions():
		_check(region.get("event_pool", []).size() == 10, "%s has ten regional events" % region.get("name", "Region"))
		for event_id: Variant in region.get("event_pool", []):
			_check(str(event_id) not in pooled, "Regional event id is not reused: %s" % event_id)
			pooled.append(str(event_id))
	_check(pooled.size() == 60, "Sixty unique regional events are pooled")


func _test_d20() -> void:
	var natural_one := D20Resolver.resolve(1, 5, 2, [])
	_check(natural_one["outcome"] == "critical_failure", "Natural 1 always critically fails")
	var natural_twenty := D20Resolver.resolve(20, 0, 99, [])
	_check(natural_twenty["outcome"] == "critical_success", "Natural 20 always critically succeeds")
	var exact_success := D20Resolver.resolve(12, 3, 15, [])
	_check(exact_success["outcome"] == "success", "A total equal to the DC succeeds")
	var exact_failure := D20Resolver.resolve(11, 3, 15, [])
	_check(exact_failure["outcome"] == "failure", "A total below the DC fails")
	_check(D20Resolver.calculate_success_chance(0, 11) == 50, "Visible D20 chance accounts for natural 1 and 20")


func _test_candidates(content: ContentRepository) -> void:
	var game := GameEngine.new(content)
	var first := game.create_candidates(123456)
	var second := game.create_candidates(123456)
	_check(first == second, "Candidate generation is deterministic for a seed")
	_check(first.size() == 3, "Exactly three candidates are generated")
	var names: Array = []
	for candidate: Dictionary in first:
		var total := 0
		for stat: String in GameEngine.STATS:
			total += int(candidate["stats"][stat])
			_check(int(candidate["stats"][stat]) >= 1 and int(candidate["stats"][stat]) <= 5, "Candidate stat remains within 1–5")
		_check(total == 15, "Every candidate receives the same fifteen-point budget")
		_check(str(candidate["name"]) not in names, "Candidates have distinct names")
		names.append(str(candidate["name"]))


func _test_inventory_and_pressures(content: ContentRepository) -> void:
	var game := GameEngine.new(content)
	var candidate: Dictionary = game.create_candidates(81)[0]
	game.start_run(candidate, 81)
	_check(game.get_carry_capacity() == 10.0 + int(candidate["stats"]["strength"]) * 3.0, "Strength determines base carry capacity")
	var initial_weight := game.get_total_weight()
	game.run_state["survivor"]["inventory"]["scrap_parts"] = 5
	_check(game.get_total_weight() > initial_weight, "Stack quantities affect carrying weight")
	game.run_state["survivor"]["pressures"]["health"] = 95
	game.run_state["survivor"]["inventory"]["medkit"] = 1
	game.use_item("medkit")
	_check(int(game.run_state["survivor"]["pressures"]["health"]) == 100, "Pressure changes clamp at 100")
	_check(game.get_item_quantity("medkit") == 0, "Consumables are removed after use")


func _test_ammunition_and_temporary_conditions(content: ContentRepository) -> void:
	var game := GameEngine.new(content)
	game.start_run(game.create_candidates(901)[0], 901)
	game.run_state["survivor"]["inventory"]["pipe_pistol"] = 1
	game.run_state["survivor"]["inventory"]["pistol_rounds"] = 1
	game.run_state["survivor"]["equipment"]["weapon"] = "pipe_pistol"
	var loaded_modifiers := game._collect_modifiers("agility", "combat", 0)
	var loaded_total := _modifier_total(loaded_modifiers)
	var ammo_changes: Array = []
	game._consume_ranged_ammunition("combat", ammo_changes)
	_check(game.get_item_quantity("pistol_rounds") == 0, "A ranged combat approach consumes compatible ammunition")
	var unloaded_modifiers := game._collect_modifiers("agility", "combat", 0)
	_check(_modifier_total(unloaded_modifiers) < loaded_total, "An unloaded ranged weapon grants no weapon modifiers")
	game.run_state["survivor"]["inventory"]["stimulant"] = 1
	game.use_item("stimulant")
	_check("steady_hands" in game.run_state["survivor"]["conditions"], "A stimulant grants its temporary condition")
	game._tick_temporary_conditions()
	_check("steady_hands" in game.run_state["survivor"]["conditions"], "Temporary conditions remain for their advertised duration")
	game._tick_temporary_conditions()
	_check("steady_hands" not in game.run_state["survivor"]["conditions"], "Temporary conditions expire after two checks")


func _test_determinism(content: ContentRepository) -> void:
	var game_a := GameEngine.new(content)
	var game_b := GameEngine.new(content)
	var candidate: Dictionary = game_a.create_candidates(2020)[0]
	game_a.start_run(candidate, 9001)
	game_b.start_run(candidate, 9001)
	for turn in range(12):
		_check(game_a.run_state.get("current_event_id") == game_b.run_state.get("current_event_id"), "Seeded event selections match at turn %d" % turn)
		if game_a.run_state["phase"] == "checkpoint":
			game_a.leave_checkpoint()
			game_b.leave_checkpoint()
			continue
		var choice_a := _first_available_choice(game_a)
		var choice_b := _first_available_choice(game_b)
		var result_a := game_a.resolve_choice(choice_a)
		var result_b := game_b.resolve_choice(choice_b)
		_check(result_a.get("resolution", {}).get("roll") == result_b.get("resolution", {}).get("roll"), "Seeded D20 rolls match at turn %d" % turn)
		if game_a.run_state["phase"] in ["death", "victory"]:
			break
		game_a.continue_after_result()
		game_b.continue_after_result()


func _test_prepared_resolution_recovery(content: ContentRepository) -> void:
	var original := GameEngine.new(content)
	var candidate: Dictionary = original.create_candidates(31337)[0]
	original.start_run(candidate, 31337)
	var choice_index := _first_available_choice(original)
	var control := GameEngine.new(content)
	control.restore_run(original.run_state)
	var prepared := original.prepare_choice(choice_index)
	_check(prepared.get("prepared", false), "A choice can be persisted before its outcome is applied")
	_check(original.run_state["phase"] == "resolving", "A prepared choice uses an explicit resolving phase")
	var resumed := GameEngine.new(content)
	resumed.restore_run(original.run_state)
	var resumed_result := resumed.resolve_prepared_choice()
	var control_result := control.resolve_choice(choice_index)
	_check(resumed_result.get("resolution", {}).get("roll") == control_result.get("resolution", {}).get("roll"), "An interrupted prepared roll resumes with the same D20 result")
	_check(resumed.run_state.get("last_result") == control.run_state.get("last_result"), "Resumed resolution applies exactly the same outcome once")


func _test_complete_run(content: ContentRepository) -> void:
	var game := GameEngine.new(content)
	var candidate: Dictionary = game.create_candidates(444)[0]
	game.start_run(candidate, 444)
	var steps := 0
	while game.run_state["phase"] not in ["death", "victory"] and steps < 100:
		steps += 1
		if game.run_state["phase"] == "checkpoint":
			game.leave_checkpoint()
			continue
		if game.run_state["phase"] == "result":
			game.continue_after_result()
			continue
		var choice := _first_available_choice(game)
		game.resolve_choice(choice, 20)
	_check(game.run_state["phase"] == "victory", "A valid critical-success route reaches victory")
	_check(int(game.run_state["region_index"]) == 6, "Victory occurs after all six regions")
	_check(steps < 100, "The complete journey cannot deadlock")


func _test_save_and_death_marker(content: ContentRepository) -> void:
	var saves := SaveService.new("ashfall_test_")
	saves.delete_run_files()
	saves.clear_death_marker()
	saves._remove_if_exists("user://ashfall_test_profile.json")
	saves._remove_if_exists("user://ashfall_test_profile.json.bak")
	saves._remove_if_exists("user://ashfall_test_entitlements.json")
	saves._remove_if_exists("user://ashfall_test_entitlements.json.bak")
	var game := GameEngine.new(content)
	game.start_run(game.create_candidates(77)[0], 77)
	_check(saves.save_run(game.run_state), "Active run writes successfully")
	var restored := saves.load_run()
	_check(str(restored.get("run_id", "")) == str(game.run_state["run_id"]), "Saved run restores with the same identity")
	_check(saves.write_death_marker_and_delete(str(game.run_state["run_id"])), "Death marker is persisted before deletion")
	_check(saves.load_run().is_empty(), "A dead run cannot be restored")
	var profile := saves.default_profile()
	profile["deaths"] = 7
	_check(saves.save_profile(profile), "Profile data writes independently from the active run")
	_check(int(saves.load_profile().get("deaths", 0)) == 7, "Profile history survives active-run deletion")
	var owned := {"remove_ads": true, "theme_rust": false, "theme_night": true, "supporter": false, "verified_at": 1234}
	_check(saves.save_entitlements(owned), "Verified entitlement cache writes independently")
	_check(bool(saves.load_entitlements().get("remove_ads", false)), "Verified ownership survives active-run deletion")
	saves.clear_death_marker()
	saves.delete_run_files()
	saves._remove_if_exists("user://ashfall_test_profile.json")
	saves._remove_if_exists("user://ashfall_test_profile.json.bak")
	saves._remove_if_exists("user://ashfall_test_entitlements.json")
	saves._remove_if_exists("user://ashfall_test_entitlements.json.bak")


func _first_available_choice(game: GameEngine) -> int:
	var choices: Array = game.current_event().get("choices", [])
	for index in range(choices.size()):
		if game.get_choice_preview(choices[index]).get("available", false):
			return index
	return 0


func _modifier_total(modifiers: Array) -> int:
	var total := 0
	for modifier: Dictionary in modifiers:
		total += int(modifier.get("value", 0))
	return total


func _check(condition: bool, description: String) -> void:
	assertions += 1
	if not condition:
		failures += 1
		push_error("FAIL: %s" % description)
	else:
		print("PASS: %s" % description)
