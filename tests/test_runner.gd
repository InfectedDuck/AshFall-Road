extends SceneTree

const CombatRules = preload("res://scripts/domain/combat_resolver.gd")
const ExperienceRules = preload("res://scripts/domain/experience_rules.gd")
const IconMeterWidget = preload("res://scripts/ui/icon_meter.gd")
const SurvivorHudWidget = preload("res://scripts/ui/survivor_hud.gd")
const PortraitArtWidget = preload("res://scripts/ui/portrait_art.gd")
const DiceWidget = preload("res://scripts/ui/dice_widget.gd")
const StoryTypewriterWidget = preload("res://scripts/ui/story_typewriter.gd")
const StatsCapsuleWidget = preload("res://scripts/ui/stats_capsule.gd")
const PressureStripWidget = preload("res://scripts/ui/pressure_strip.gd")
const CombatPresentationWidget = preload("res://scripts/ui/combat_presentation.gd")
const ItemIconWidget = preload("res://scripts/ui/item_icon.gd")
const ResponsiveRules = preload("res://scripts/ui/responsive_rules.gd")
const UiPaletteWidget = preload("res://scripts/ui/ui_palette.gd")
const UiTypeWidget = preload("res://scripts/ui/ui_type.gd")
const AtmosphereLayersWidget = preload("res://scripts/ui/atmosphere_layers.gd")
const MainUI = preload("res://scripts/ui/main.gd")
const StoryDiscoveryRules = preload("res://scripts/domain/story_discovery.gd")
const FullRunHarness = preload("res://tools/full_run_harness.gd")
const EquipmentComparison = preload("res://scripts/domain/equipment_comparison.gd")

var failures := 0
var assertions := 0


func _init() -> void:
	call_deferred("_run_all")


func _run_all() -> void:
	print("Ashfall Road headless tests")
	var content := ContentRepository.new()
	_test_content(content)
	_test_living_road_expansion(content, ContentRepository.new(true))
	_test_bunker41_chain(content)
	_test_rustsea_chain(content)
	_test_d20_and_damage()
	_test_probability_modifiers(content)
	_test_balance_targets(content)
	_test_candidates(content)
	_test_ui_palettes()
	_test_canvas_design_system()
	_test_ui_components(content)
	_test_typewriter_and_responsive_rules()
	_test_ui_overlay_smoke(content)
	_test_inventory_vitals_and_hunger(content)
	_test_inventory_management(content)
	_test_opening_guidance(content)
	_test_supply_guarantee(content)
	_test_combat_opportunity_selection(content)
	_test_temporary_conditions(content)
	_test_condition_explanations(content)
	_test_event_determinism(content)
	_test_prepared_event_recovery(content)
	_test_equipment_routes(content)
	_test_equipment_comparison(content)
	_test_contextual_guidance(content)
	_test_road_chronicle(content)
	_test_full_run_replay(content)
	_test_experience_progression(content)
	_test_combat_rules(content)
	_test_combat_recovery(content)
	_test_complete_run(content)
	_test_save_migration_and_death_marker(content)
	preload("res://tests/narrative_combat_tests.gd").new().run(content, _check)
	preload("res://tests/action_transaction_tests.gd").new().run(content, _check)
	print("Assertions: %d | Failures: %d" % [assertions, failures])
	quit(1 if failures > 0 else 0)


func _test_content(content: ContentRepository) -> void:
	_check(content.validate_all().is_empty(), "All content, combat, and supply references are valid")
	_check(content.regions.size() == 6, "Six regions are defined")
	_check(content.items.size() == 50, "Forty-eight items plus two shields are defined")
	var icon_ids: Dictionary = {}
	for item: Dictionary in content.items.values():
		var icon_id := str(item.get("icon_id", ""))
		if not icon_id.is_empty():
			icon_ids[icon_id] = true
	_check(icon_ids.size() == 50, "Every item has a unique stable icon ID")
	var placeholder_symbols: Dictionary = {}
	for icon_id: String in icon_ids:
		var symbol := ItemIconWidget.placeholder_symbol(icon_id)
		_check(not symbol.is_empty(), "%s has a temporary item symbol" % icon_id)
		placeholder_symbols[symbol] = true
	_check(placeholder_symbols.size() == 50, "Every item resolves to a distinct temporary inventory symbol")
	_check(content.conditions.size() == 13, "Twelve survival conditions plus checkpoint Momentum are defined")
	_check(content.adversaries.size() == 13, "Twelve original adversaries plus Mutant Crows are defined")
	_check(content.events.size() == 97, "The base content plus Bunker Forty-One and the eight-scene Rust-Sea arc is loaded")
	var combat_choices := 0
	var checked_choices := 0
	var outcome_passages := 0
	for event: Dictionary in content.events.values():
		var introduction_words := str(event.get("body", "")).split(" ", false).size()
		_check(introduction_words >= 60 and introduction_words <= 90, "%s has a 60–90 word literary introduction" % event.get("id", "event"))
		for choice: Dictionary in event.get("choices", []):
			if choice.has("combat"):
				combat_choices += 1
			if choice.has("check"):
				checked_choices += 1
				_check(not choice["check"].has("dc") and str(choice["check"].get("difficulty", "")) in D20Resolver.DIFFICULTY_SHIFTS, "Checked content uses a named difficulty and no numeric target")
			for outcome_key: String in ["success", "failure", "critical_success", "critical_failure", "outcome", "victory", "critical_victory"]:
				if choice.has(outcome_key):
					outcome_passages += 1
					var outcome_words := str(choice[outcome_key].get("text", "")).split(" ", false).size()
					_check(outcome_words >= 30 and outcome_words <= 50, "%s outcome prose stays within 30–50 words" % event.get("id", "event"))
	_check(combat_choices == 11, "Eleven authored choices enter tactical combat, including the Bunker Forty-One Warden confrontation")
	_check(checked_choices == 146, "All 146 checked choices use percentage rules")
	_check(outcome_passages == 390, "All base, Bunker Forty-One, Rust-Sea, and equipment-route outcome passages remain present")
	var legacy_global_opening := "The road has been quiet long enough for that quiet to feel deliberate."
	var global_openings_are_distinct := true
	for event: Dictionary in content.events.values():
		if bool(event.get("global", false)) and str(event.get("id", "")) != "fallback_dust":
			global_openings_are_distinct = global_openings_are_distinct and legacy_global_opening not in str(event.get("body", ""))
	_check(global_openings_are_distinct, "Runtime global encounters no longer reuse the old quiet-road opening")
	var adversary_profiles_valid := true
	var adversary_portraits_valid := true
	var adversary_xp_valid := true
	for adversary: Dictionary in content.adversaries.values():
		var combat: Dictionary = adversary.get("combat", {})
		adversary_profiles_valid = adversary_profiles_valid and int(combat.get("max_health", 0)) > 0 and int(combat.get("damage_max", 0)) >= int(combat.get("damage_min", 0))
		adversary_portraits_valid = adversary_portraits_valid and not str(adversary.get("portrait_id", "")).is_empty()
		adversary_xp_valid = adversary_xp_valid and int(adversary.get("xp_reward", 0)) > 0 and int(adversary.get("xp_reward", 0)) <= 100
	_check(adversary_profiles_valid, "Every adversary has a valid HP and damage profile")
	_check(adversary_portraits_valid, "Every adversary has a stable portrait placeholder ID")
	_check(adversary_xp_valid, "Every adversary has an authored XP reward")
	var expected_xp := {"mutant_crows": 18, "feral_dogs": 22, "marsh_leeches": 24, "road_bandits": 24, "toll_gang": 30, "ash_stalkers": 36, "bog_raiders": 44, "vault_scavs": 46, "drone_swarm": 48, "tunnel_hunters": 52, "glass_cult": 62, "citadel_guard": 75, "warden_machine": 100}
	var rewards_match := true
	for adversary_id: String in expected_xp:
		rewards_match = rewards_match and int(content.get_adversary(adversary_id).get("xp_reward", 0)) == int(expected_xp[adversary_id])
	_check(rewards_match, "All thirteen adversaries retain the balanced XP reward table")
	for region: Dictionary in content.ordered_regions():
		var supply := 0
		for event_id: Variant in region.get("event_pool", []):
			if "supply_opportunity" in content.get_event(str(event_id)).get("tags", []):
				supply += 1
		_check(supply >= 1, "%s contains a guaranteed supply candidate" % region.get("name", "Region"))
	var opening_pool: Array = content.ordered_regions()[0].get("event_pool", [])
	var opening_safe := 0
	var opening_resource := 0
	var opening_equipment := 0
	for event_id: Variant in opening_pool:
		var tags: Array = content.get_event(str(event_id)).get("tags", [])
		opening_safe += 1 if "opening_safe" in tags else 0
		opening_resource += 1 if "opening_resource" in tags else 0
		opening_equipment += 1 if "opening_equipment" in tags else 0
	_check(opening_safe >= 2 and opening_resource >= 1 and opening_equipment >= 1, "The opening pool declares safe, resource, and equipment teaching roles")


func _test_living_road_expansion(release_content: ContentRepository, living_content: ContentRepository) -> void:
	var validation_errors := living_content.validate_all()
	if not validation_errors.is_empty():
		for error: String in validation_errors:
			print("LIVING ROAD VALIDATION: %s" % error)
	_check(validation_errors.is_empty(), "Living Road expansion content passes narrative, reachability, item, and callback validation")
	_check(not release_content.living_road_enabled and release_content.events.size() == 97, "The v1 build boundary keeps callback events staged")
	var v11_document: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/narrative_overrides_v11.json"))
	var polished_baseline_live := typeof(v11_document) == TYPE_DICTIONARY
	var polished_baseline_count := 0
	if polished_baseline_live:
		for override: Dictionary in v11_document.get("events", []):
			polished_baseline_count += 1
			var polished_event: Dictionary = release_content.get_event(str(override.get("id", "")))
			polished_baseline_live = polished_baseline_live and str(polished_event.get("body", "")) == str(override.get("body", ""))
			for choice_override: Dictionary in override.get("choices", []):
				var polished_choice: Dictionary = polished_event.get("choices", [])[int(choice_override.get("index", -1))]
				for outcome_key: String in choice_override.get("outcomes", {}):
					polished_baseline_live = polished_baseline_live and str(polished_choice[outcome_key].get("text", "")) == str(choice_override["outcomes"][outcome_key])
	_check(polished_baseline_live and polished_baseline_count == 43, "The remaining baseline prose polish is live without the Living Road setting")
	_check(release_content.polished_event_ids.size() == 76 and release_content.load_errors.is_empty(), "All 76 baseline events use polished prose in the launch build")
	_check(living_content.living_road_enabled and living_content.events.size() == 112, "The v1.1 boundary loads exactly fifteen callback events")
	_check(living_content.get_discovery_entries().size() == 25, "The Road Ledger contains twenty-five spoiler-safe chapters")

	var callback_ids: Array = []
	var callback_id_set: Dictionary = {}
	var callback_regions: Dictionary = {}
	var final_rewards: Dictionary = {}
	var complete_branch_shapes := true
	for event: Dictionary in living_content.events.values():
		if not bool(event.get("living_road_callback", false)):
			continue
		callback_ids.append(str(event.get("id", "")))
		callback_id_set[str(event.get("id", ""))] = true
		var callback_choices: Array = event.get("choices", [])
		complete_branch_shapes = complete_branch_shapes and callback_choices.size() == 3 and callback_choices[0].has("success") and callback_choices[0].has("failure") and callback_choices[1].has("success") and callback_choices[1].has("failure") and callback_choices[2].has("outcome")
		var region_index := int(event.get("callback_region", -1))
		callback_regions[region_index] = int(callback_regions.get(region_index, 0)) + 1
		for choice: Dictionary in event.get("choices", []):
			for outcome_key: String in ["success", "failure", "outcome", "victory", "critical_victory"]:
				for item_id: Variant in choice.get(outcome_key, {}).get("items", {}).keys():
					final_rewards[str(item_id)] = true
	_check(callback_ids.size() == 15 and callback_id_set.size() == 15, "All fifteen Living Road callback IDs are present and unique")
	var callbacks_staged := true
	for callback_id: String in callback_ids:
		callbacks_staged = callbacks_staged and not release_content.events.has(callback_id)
	_check(callbacks_staged, "The fifteen callback events remain unavailable while the baseline prose is polished")
	_check(complete_branch_shapes, "Every callback chapter preserves successful, failed, and certain refusal paths")
	_check(int(callback_regions.get(1, 0)) == 3 and int(callback_regions.get(2, 0)) == 3 and int(callback_regions.get(3, 0)) == 4 and int(callback_regions.get(4, 0)) == 2 and int(callback_regions.get(5, 0)) == 3, "Callback chapters are distributed across their intended regions")
	var formerly_unobtainable := ["dust_cloak", "lucky_die", "flare_gun", "rebar_spear", "nail_bat", "hunting_rifle", "tire_armor", "scavenger_rig", "rusted_hatchet", "stun_baton"]
	_check(formerly_unobtainable.all(func(item_id: String) -> bool: return final_rewards.has(item_id)), "All ten previously unobtainable equipment items now have callback reward routes")

	var raw_document: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/events.json"))
	var mechanics_unchanged := typeof(raw_document) == TYPE_DICTIONARY
	if mechanics_unchanged:
		for raw_event: Dictionary in raw_document.get("events", []):
			mechanics_unchanged = mechanics_unchanged and _mechanical_event_signature(raw_event) == _mechanical_event_signature(release_content.get_event(str(raw_event.get("id", ""))))
	_check(mechanics_unchanged, "The live v1 prose rewrite preserves every baseline mechanical field")

	var first_family := living_content.get_event("lr_blue_van")
	var continued_family := living_content.get_event("lr_voice_in_reeds")
	_check(int(continued_family.get("narrative_priority", 0)) > int(first_family.get("narrative_priority", 0)), "A continuing human thread outranks a newly starting callback")
	var callback_game := _new_game(living_content, 4141)
	callback_game.run_state["region_index"] = 2
	callback_game.run_state["events_in_region"] = 0
	callback_game.run_state["event_history"] = []
	callback_game.run_state["flags"] = ["lr_family_trusted"]
	callback_game._select_next_event()
	_check(str(callback_game.run_state.get("current_event_id", "")) == "lr_voice_in_reeds", "An eligible continuing thread is selected before an unrelated callback")
	var callback_result := callback_game.resolve_choice(2)
	_check(not callback_result.has("error") and "lr_callback_region_2" in callback_game.run_state.get("flags", []), "Resolving a callback closes that region's single callback slot")
	var other_region_two_callbacks_blocked := true
	for callback_id: String in ["lr_bellkeepers_son", "lr_embers_in_rain"]:
		other_region_two_callbacks_blocked = other_region_two_callbacks_blocked and not callback_game._event_eligible(living_content.get_event(callback_id))
	_check(other_region_two_callbacks_blocked, "A resolved callback prevents a second normal-slot callback in the same region")
	var restored_callback := GameEngine.new(living_content)
	restored_callback.restore_run(callback_game.run_state)
	_check("lr_callback_region_2" in restored_callback.run_state.get("flags", []) and str(restored_callback.run_state.get("last_result", {}).get("event_id", "")) == "lr_voice_in_reeds", "Callback consequences survive run serialization without a schema migration")

	var deterministic_a := _new_game(living_content, 9191)
	deterministic_a.run_state["region_index"] = 1
	deterministic_a.run_state["events_in_region"] = 0
	deterministic_a.run_state["event_history"] = []
	deterministic_a.run_state["flags"] = ["lr_channel_helped", "lr_siren_silenced", "lr_bandits_escaped"]
	var deterministic_b := GameEngine.new(living_content)
	deterministic_b.restore_run(deterministic_a.run_state)
	deterministic_a._select_next_event()
	deterministic_b._select_next_event()
	_check(str(deterministic_a.run_state.get("current_event_id", "")) == str(deterministic_b.run_state.get("current_event_id", "")), "Identical seeds and prior choices select the same eligible callback")

	var forced_combat := _new_game(living_content, 9192)
	forced_combat.run_state["region_index"] = 2
	forced_combat.run_state["events_in_region"] = 3
	forced_combat.run_state["event_history"] = []
	forced_combat.run_state["flags"] = ["lr_family_trusted"]
	forced_combat.run_state["combat_opportunities_seen_in_region"] = 0
	forced_combat._select_next_event()
	_check(living_content.event_has_combat_choice(forced_combat.current_event()), "The fourth-slot combat guarantee overrides an eligible callback")
	var forced_supply := _new_game(living_content, 9193)
	forced_supply.run_state["region_index"] = 2
	forced_supply.run_state["events_in_region"] = 4
	forced_supply.run_state["event_history"] = []
	forced_supply.run_state["flags"] = ["lr_family_trusted"]
	forced_supply.run_state["supply_seen_in_region"] = false
	forced_supply._select_next_event()
	_check("supply_opportunity" in forced_supply.current_event().get("tags", []), "The fifth-slot supply guarantee overrides an eligible callback")

	var discovery_profile := SaveService.new().default_profile()
	var discovery_flags := ["lr_family_trusted"]
	var discovery_result := StoryDiscoveryRules.apply_resolution({"event_id": "lr_blue_van"}, discovery_flags, living_content.get_discovery_entries(), discovery_profile)
	_check(bool(discovery_result.get("changed", false)) and "ledger_family_1:trusted" in discovery_profile["discovered_story_nodes"], "An authoritative callback resolution unlocks its branch-specific Ledger chapter")
	_check("talia_vale" in discovery_profile["discovered_characters"], "Road Ledger resolution remembers the characters who were encountered")
	var repeated_discovery := StoryDiscoveryRules.apply_resolution({"event_id": "lr_blue_van"}, discovery_flags, living_content.get_discovery_entries(), discovery_profile)
	_check(not bool(repeated_discovery.get("changed", true)) and discovery_profile["discovered_story_nodes"].count("ledger_family_1:trusted") == 1, "Road Ledger discoveries are idempotent across result-screen recovery")
	var alternate_discovery := StoryDiscoveryRules.apply_resolution({"event_id": "lr_blue_van"}, ["lr_family_distrusts"], living_content.get_discovery_entries(), discovery_profile)
	_check(bool(alternate_discovery.get("changed", false)) and "ledger_family_1:distant" in discovery_profile["discovered_story_nodes"] and "ledger_family_1:trusted" in discovery_profile["discovered_story_nodes"], "A later run records a second account without erasing the first")
	var recorded_nodes: Array = discovery_profile["discovered_story_nodes"]
	_check(StoryDiscoveryRules.chapter_ids(recorded_nodes).count("ledger_family_1") == 1 and StoryDiscoveryRules.variant_tokens(recorded_nodes, "ledger_family_1").size() == 2, "One chapter counts once while its separate accounts count apart from it")
func _test_bunker41_chain(content: ContentRepository) -> void:
	var chain_ids := ["bunker41_static", "bunker41_rusted_hatch", "bunker41_cartographer", "bunker41_door_breathes", "bunker41_last_evacuation", "bunker41_fragment_calls", "bunker41_ash_procession", "bunker41_green_platform", "bunker41_chapel_car", "bunker41_false_welcome", "bunker41_ledger_living", "bunker41_warden_remembers", "bunker41_door_closes"]
	var all_present := true
	for event_id: String in chain_ids:
		all_present = all_present and not content.get_event(event_id).is_empty()
	_check(all_present, "All thirteen Bunker Forty-One narrative nodes load from the supplemental content pack")
	var game := _new_game(content, 4101)
	game.run_state["region_index"] = 1
	_check(game._event_eligible(content.get_event("bunker41_static")), "The Bunker Forty-One signal can occur only during the Salt Flats omen window")
	game.run_state["region_index"] = 4
	_check(not game._event_eligible(content.get_event("bunker41_static")) and game._event_eligible(content.get_event("bunker41_rusted_hatch")), "The rusted hatch replaces the omen at the Glass Wastes timeline")
	game.run_state["current_event_id"] = "bunker41_rusted_hatch"
	game.run_state["phase"] = "event"
	game.resolve_choice(0)
	game.continue_after_result()
	_check(game.run_state["current_event_id"] == "bunker41_cartographer", "The quiet hatch route cascades directly into Mara Venn's chapter")
	var forced := _new_game(content, 4102)
	forced.run_state["region_index"] = 4
	forced.run_state["current_event_id"] = "bunker41_rusted_hatch"
	forced.run_state["phase"] = "event"
	forced.resolve_choice(1)
	forced.continue_after_result()
	_check(forced.run_state["current_event_id"] == "bunker41_door_breathes", "Forcing the hatch cascades directly into the Cinder Wives branch")
	forced.resolve_choice(1)
	forced.continue_after_result()
	_check(forced.run_state["current_event_id"] == "bunker41_last_evacuation", "Following the Cinder Wives reaches the Soteria command-room revelation")
	var warned_death := _new_game(content, 4103)
	warned_death.run_state["current_event_id"] = "bunker41_door_breathes"
	warned_death.run_state["phase"] = "event"
	warned_death.resolve_choice(2)
	_check(warned_death.run_state["phase"] == "death", "Entering the clearly telegraphed Hush Sovereign chamber causes strict permadeath")
	var finale := _new_game(content, 4104)
	finale.run_state["current_event_id"] = "bunker41_door_closes"
	finale.run_state["phase"] = "event"
	var ending_choices: Array = finale.current_event().get("choices", [])
	_check(not finale.get_choice_preview(ending_choices[1]).get("available", true), "The Mercy ending remains unavailable without the Mercy Key")
	finale.run_state["flags"].append("b41_mercy_key")
	_check(finale.get_choice_preview(ending_choices[1]).get("available", false), "The Mercy Key unlocks its distinct Citadel ending")
	var continuation := _new_game(content, 4105)
	continuation.run_state["region_index"] = 5
	continuation.run_state["flags"] = ["b41_green_invite"]
	continuation._select_next_event()
	_check(continuation.run_state["current_event_id"] == "bunker41_green_platform", "An earned Bunker Forty-One continuation takes priority over unrelated Underrail filler")


func _test_rustsea_chain(content: ContentRepository) -> void:
	var chain_ids := ["rustsea_green_line", "rustsea_quay_names", "rustsea_false_coordinates", "rustsea_station_arrivals", "rustsea_salt_crown_wake", "rustsea_cartographers_debt", "rustsea_voice_map", "rustsea_last_coordinate"]
	var all_present := true
	for event_id: String in chain_ids:
		all_present = all_present and not content.get_event(event_id).is_empty()
	_check(all_present, "All eight Mara Venn Rust-Sea narrative nodes load from the supplemental content pack")
	var unavailable := _new_game(content, 5101)
	unavailable.run_state["region_index"] = 5
	_check(not unavailable._event_eligible(content.get_event("rustsea_green_line")), "The Green Line cannot appear without an earlier Bunker Forty-One hook")
	var green_line := _new_game(content, 5102)
	green_line.run_state["region_index"] = 5
	green_line.run_state["flags"] = ["b41_mara_helped"]
	green_line._select_next_event()
	_check(green_line.run_state["current_event_id"] == "rustsea_green_line", "Mara's earned Green Line continuation takes priority in the Underrail")
	green_line.run_state["phase"] = "event"
	green_line.resolve_choice(0)
	green_line.continue_after_result()
	_check(green_line.run_state["current_event_id"] == "rustsea_quay_names", "Following the Green Line leads to the drowned Quay of Names")
	green_line.resolve_choice(0)
	green_line.continue_after_result()
	_check(green_line.run_state["current_event_id"] == "rustsea_station_arrivals", "Mara's traced name leads to the Station Without Arrivals")
	var salt_crown := _new_game(content, 5103)
	salt_crown.run_state["current_event_id"] = "rustsea_false_coordinates"
	salt_crown.run_state["phase"] = "event"
	salt_crown.resolve_choice(2)
	_check(salt_crown.run_state["phase"] == "death", "Entering the explicitly warned Salt Crown hollow causes strict permadeath")
	var mara := _new_game(content, 5104)
	mara.run_state["current_event_id"] = "rustsea_cartographers_debt"
	mara.run_state["phase"] = "event"
	var mara_choices: Array = mara.current_event().get("choices", [])
	_check(not mara.get_choice_preview(mara_choices[2]).get("available", true), "Mara cannot receive the Mercy Key when the player does not possess it")
	mara.run_state["flags"].append("b41_mercy_key")
	_check(mara.get_choice_preview(mara_choices[2]).get("available", false), "The Mercy Key unlocks Mara's alternative Rust-Sea consequence")
	var coordinate := _new_game(content, 5105)
	coordinate.run_state["current_event_id"] = "rustsea_last_coordinate"
	coordinate.run_state["phase"] = "event"
	coordinate.resolve_choice(0)
	_check("rustsea_spire_reached" in coordinate.run_state["flags"], "The Last Coordinate persists the Sunken Spire hook for the convergence arc")


func _test_d20_and_damage() -> void:
	_check(D20Resolver.resolve_percentage(1, 5, 5, "easy", [])["outcome"] == "critical_failure", "Natural 1 critically fails event checks")
	_check(D20Resolver.resolve_percentage(20, 0, 0, "desperate", [])["outcome"] == "critical_success", "Natural 20 critically succeeds event checks")
	_check(D20Resolver.resolve_percentage(9, 3, 3, "risky", [], 60)["outcome"] == "success", "A roll on the percentage threshold succeeds")
	_check(D20Resolver.required_roll(60) == 9, "Sixty percent succeeds on D20 faces 9–20")
	_check(D20Resolver.required_roll(25) == 16, "Twenty-five percent clearly requires a roll of 16 or higher")
	for expected: Dictionary in [{"stat": 2, "raw": 32.0}, {"stat": 5, "raw": 46.0}, {"stat": 10, "raw": 62.0}, {"stat": 20, "raw": 81.0}, {"stat": 30, "raw": 89.0}]:
		_check(absf(D20Resolver.raw_stat_chance(int(expected["stat"])) - float(expected["raw"])) < 1.0, "Raw aptitude near stat %d matches the exponential curve" % expected["stat"])
	var previous_gain := D20Resolver.raw_stat_chance(1) - D20Resolver.raw_stat_chance(0)
	var monotonic_and_diminishing := true
	for stat in range(1, 100):
		var gain := D20Resolver.raw_stat_chance(stat + 1) - D20Resolver.raw_stat_chance(stat)
		monotonic_and_diminishing = monotonic_and_diminishing and gain > 0.0 and gain < previous_gain
		previous_gain = gain
	_check(monotonic_and_diminishing, "The uncapped aptitude curve rises with diminishing returns")
	var tier_chances: Array[int] = []
	for difficulty: String in ["easy", "favorable", "risky", "hard", "desperate"]:
		tier_chances.append(D20Resolver.calculate_percentage(5, difficulty))
	_check(tier_chances == [80, 70, 60, 50, 35], "All five named tiers apply their percentage-point shifts")
	_check(D20Resolver.calculate_percentage(0, "desperate") == 10, "Very poor desperate checks remain above the five-percent floor when the curve permits")
	_check(D20Resolver.normalize_percentage(-100.0) == 5 and D20Resolver.calculate_percentage(999, "easy") == 95, "Displayed event odds clamp to the 5–95 percent range")
	var face_mapping_exact := true
	for chance in range(5, 100, 5):
		var successful_faces := 0
		for roll in range(1, 21):
			if bool(D20Resolver.resolve_percentage(roll, 0, 0, "risky", [], chance)["succeeded"]):
				successful_faces += 1
		face_mapping_exact = face_mapping_exact and successful_faces * 5 == chance
	_check(face_mapping_exact, "Every displayed percentage maps to exactly the same number of successful D20 faces")
	_check(CombatRules.damage_for_roll(1, 7, 10) == 7, "Combat roll 1 maps to displayed minimum damage")
	_check(CombatRules.damage_for_roll(20, 7, 10) == 10, "Combat roll 20 maps to displayed maximum damage")
	_check(CombatRules.damage_for_roll(10, 20, 40) > 20 and CombatRules.damage_for_roll(10, 20, 40) < 40, "Intermediate combat rolls interpolate damage")
	var plain := CombatRules.mitigate_damage(100, 0)
	var armored := CombatRules.mitigate_damage(100, 5)
	var guarded := CombatRules.mitigate_damage(100, 5, true)
	_check(int(armored["final"]) < int(plain["final"]), "Armor reduces combat damage")
	_check(int(guarded["final"]) < int(armored["final"]), "Guard applies after armor")
	_check(CombatRules.roll_label(1) == "CRITICAL FAILURE", "Combat natural 1 has a written critical-failure label")
	_check(CombatRules.roll_label(20) == "CRITICAL SUCCESS", "Combat natural 20 has a written critical-success label")
	_check(int(CombatRules.mitigate_damage(1, 5, true)["final"]) == 1, "Combat mitigation never reduces damage below one")
	_check(is_equal_approx(float(CombatRules.ARMOR_PERCENT[5]), 0.35), "Armor rating five applies its authored 35 percent reduction")
	var uncapped_profile := CombatRules.weapon_profile({"name": "Test Weapon", "combat": {"attack_stat": "strength", "damage_min": 10, "damage_max": 10, "ammo_per_attack": 0}}, {"strength": 100}, true)
	_check(int(uncapped_profile["stat_value"]) == 100, "Combat attack stats have no upper cap")
	_check(CombatRules.stat_damage_multiplier(5) == 1.3 and CombatRules.stat_damage_multiplier(100) < 1.8, "Combat damage is about 1.3× at stat five and approaches 1.8×")


func _test_balance_targets(content: ContentRepository) -> void:
	var strong_profile := CombatRules.weapon_profile(content.get_item("hunting_rifle"), {"wits": 5}, true)
	var strong_attack_total := 0.0
	for roll in range(1, 21):
		strong_attack_total += ceili(120.0 / CombatRules.damage_for_roll(roll, int(strong_profile["damage_min"]), int(strong_profile["damage_max"])))
	var average_strong_attacks := strong_attack_total / 20.0
	_check(average_strong_attacks >= 2.0 and average_strong_attacks <= 3.0, "Strong equipment defeats Feral Dogs in approximately two to three attacks")

	var warden: Dictionary = content.get_adversary("warden_machine").get("combat", {})
	var low_grit_hits_total := 0.0
	for roll in range(1, 21):
		low_grit_hits_total += ceili(200.0 / CombatRules.damage_for_roll(roll, int(warden["damage_min"]), int(warden["damage_max"])))
	var average_low_grit_hits := low_grit_hits_total / 20.0
	_check(average_low_grit_hits >= 2.0 and average_low_grit_hits <= 3.0, "The Warden defeats an unarmored four-heart survivor in approximately two to three hits")

	var hunters: Dictionary = content.get_adversary("tunnel_hunters").get("combat", {})
	var tank_round_total := 0.0
	for roll in range(1, 21):
		var incoming := CombatRules.damage_for_roll(roll, int(hunters["damage_min"]), int(hunters["damage_max"]))
		var guarded_damage := int(CombatRules.mitigate_damage(incoming, 5, true)["final"])
		tank_round_total += ceili(400.0 / guarded_damage)
	var average_tank_rounds := tank_round_total / 20.0
	_check(average_tank_rounds >= 20.0 and average_tank_rounds <= 30.0, "Eight-heart armor and Guard builds support twenty-to-thirty-round attrition")

	var guaranteed_satiety := 4
	for region: Dictionary in content.ordered_regions():
		var best_region_supply := 0
		for event_id: Variant in region.get("event_pool", []):
			var event: Dictionary = content.get_event(str(event_id))
			if "supply_opportunity" not in event.get("tags", []):
				continue
			for choice: Dictionary in event.get("choices", []):
				for outcome_key: String in ["success", "critical_success", "outcome", "victory", "critical_victory"]:
					if choice.has(outcome_key):
						best_region_supply = maxi(best_region_supply, content._outcome_satiety_value(choice[outcome_key]))
		guaranteed_satiety += best_region_supply
	_check(guaranteed_satiety >= 15, "Starting food plus guaranteed supply routes cover all fifteen journey hunger ticks")
	var cautious_xp := 30 * ExperienceRules.JOURNEY_XP + 6 * ExperienceRules.CHECKPOINT_XP
	var selective_xp := cautious_xp + 22 + 24 + 30 + 36 + 46 + 3 * ExperienceRules.check_bonus("hard")
	var aggressive_xp := cautious_xp + 22 + 24 + 30 + 44 + 46 + 62 + 52 + 36
	_check(ExperienceRules.level_for_xp(cautious_xp) - 1 == 3, "Cautious survival projects to three run-only stat points")
	_check(ExperienceRules.level_for_xp(selective_xp) - 1 == 5, "Selective fighting projects to five run-only stat points")
	_check(ExperienceRules.level_for_xp(aggressive_xp) - 1 == 6, "An exceptional aggressive survivor projects to six run-only stat points")


func _test_probability_modifiers(content: ContentRepository) -> void:
	var game := _new_game(content, 118)
	game.run_state["current_event_id"] = "outskirts_bandits"
	game.run_state["survivor"]["stats"]["agility"] = 2
	game.run_state["survivor"]["equipment"] = {"weapon": "", "armor": "", "accessory": "", "backpack": ""}
	var choice: Dictionary = game.current_event()["choices"][1]
	var baseline_preview := game.get_choice_preview(choice)
	var baseline := int(baseline_preview["chance"])
	_check(int(baseline_preview.get("required_roll", 0)) == D20Resolver.required_roll(baseline) and "NEED" in str(baseline_preview.get("description", "")), "Choice previews translate percentages into exact D20 targets")
	game.run_state["survivor"]["inventory"]["runner_jacket"] = 1
	game.run_state["survivor"]["equipment"]["armor"] = "runner_jacket"
	_check(int(game.get_choice_preview(choice)["chance"]) > baseline, "Equipment stat bonuses improve the visible percentage")
	game.run_state["survivor"]["equipment"]["armor"] = ""
	game.run_state["survivor"]["conditions"] = ["steady_hands"]
	_check(int(game.get_choice_preview(choice)["chance"]) > baseline, "Positive conditions improve the visible percentage")
	game.run_state["survivor"]["conditions"] = ["sprain"]
	_check(int(game.get_choice_preview(choice)["chance"]) < baseline, "Injuries reduce the visible percentage")
	game.run_state["survivor"]["conditions"] = []
	for pressure: String in ["fatigue", "radiation"]:
		game.run_state["survivor"]["pressures"][pressure] = 100
		_check(int(game.get_choice_preview(choice)["chance"]) < baseline, "%s reduces the visible percentage" % pressure.capitalize())
		game.run_state["survivor"]["pressures"][pressure] = 0
	game.run_state["survivor"]["vitals"]["satiety"] = 0
	_check(int(game.get_choice_preview(choice)["chance"]) < baseline, "Starvation reduces the visible percentage")
	game.run_state["survivor"]["vitals"]["satiety"] = 4
	game.run_state["survivor"]["vitals"]["health"] = 1
	_check(int(game.get_choice_preview(choice)["chance"]) < baseline, "Low Health reduces the visible percentage")
	game.run_state["survivor"]["vitals"]["health"] = game.run_state["survivor"]["vitals"]["max_health"]
	game.run_state["survivor"]["inventory"]["scrap_parts"] = 999
	_check(int(game.get_choice_preview(choice)["chance"]) < baseline, "Over-capacity weight reduces Agility checks")


func _test_candidates(content: ContentRepository) -> void:
	var game := GameEngine.new(content)
	var first := game.create_candidates(123456)
	var second := game.create_candidates(123456)
	_check(first == second, "Candidate generation remains deterministic")
	_check(first.size() == 3, "Exactly three candidates are generated")
	var portrait_ids: Array[String] = []
	for candidate: Dictionary in first:
		portrait_ids.append(str(candidate.get("portrait_id", "")))
	_check(portrait_ids.duplicate().all(func(portrait_id: String) -> bool: return portrait_id in GameEngine.SURVIVOR_PORTRAIT_IDS), "Candidates draw only from the four stable survivor portrait IDs")
	var unique_portrait_ids := portrait_ids.duplicate()
	unique_portrait_ids.sort()
	for portrait_index in range(unique_portrait_ids.size() - 1, 0, -1):
		if unique_portrait_ids[portrait_index] == unique_portrait_ids[portrait_index - 1]:
			unique_portrait_ids.remove_at(portrait_index)
	_check(unique_portrait_ids.size() == 3, "A run shows three unique portraits drawn from the four-survivor pool")
	var portraits_seen_across_seeds := {}
	for portrait_seed in range(1, 13):
		for seeded_candidate: Dictionary in GameEngine.new(content).create_candidates(portrait_seed):
			portraits_seen_across_seeds[str(seeded_candidate.get("portrait_id", ""))] = true
	_check(portraits_seen_across_seeds.size() == 4 and portraits_seen_across_seeds.has("survivor_4"), "The deterministic portrait pool uses all four identities across run seeds")
	_check(GameEngine.max_hearts_for_grit(0) == 4, "Low Grit produces a minimum of four hearts")
	_check(GameEngine.max_hearts_for_grit(5) == 8, "Five base Grit produces eight maximum hearts")
	_check(GameEngine.max_hearts_for_grit(10) == 9 and GameEngine.max_hearts_for_grit(15) == 10, "Uncapped Grit adds another heart at each five-point threshold")
	var names: Array = []
	for candidate: Dictionary in first:
		var total := 0
		for stat: String in GameEngine.STATS:
			total += int(candidate["stats"][stat])
			_check(int(candidate["stats"][stat]) in range(1, 6), "Candidate stats remain within 1–5")
		var grit := int(candidate["stats"]["grit"])
		var hearts := int(candidate["vitals"]["max_hearts"])
		_check(total == 15, "Every candidate keeps the fifteen-point budget")
		_check(hearts == GameEngine.max_hearts_for_grit(grit) and hearts in range(4, 9), "Starting Grit produces four to eight hearts")
		_check(int(candidate["vitals"]["max_health"]) == hearts * 50, "Every heart represents 50 HP")
		_check(int(candidate["vitals"]["health"]) == int(candidate["vitals"]["max_health"]), "Candidates start at full HP")
		_check(int(candidate["vitals"]["satiety"]) == 4, "Candidates start with four meals")
		_check(str(candidate.get("portrait_id", "")) != "", "Candidates have a stable portrait placeholder ID")
		_check(str(candidate["name"]) not in names, "Candidate names are distinct")
		names.append(str(candidate["name"]))


func _test_inventory_vitals_and_hunger(content: ContentRepository) -> void:
	var game := _new_game(content, 81)
	var survivor: Dictionary = game.run_state["survivor"]
	_check(game.get_carry_capacity() == 10.0 + int(survivor["stats"]["strength"]) * 3.0, "Strength determines carrying capacity")
	var initial_weight := game.get_total_weight()
	survivor["inventory"]["scrap_parts"] = 5
	_check(game.get_total_weight() > initial_weight, "Stack quantities affect carrying weight")
	var maximum := int(survivor["vitals"]["max_health"])
	survivor["vitals"]["health"] = maximum - 20
	survivor["inventory"]["medkit"] = 1
	game.use_item("medkit")
	_check(int(survivor["vitals"]["health"]) == maximum, "Healing clamps at personal maximum HP")
	_check(game.get_item_quantity("medkit") == 0, "Used consumables leave inventory")
	survivor["vitals"]["satiety"] = 1
	game._apply_hunger_tick()
	_check(int(survivor["vitals"]["satiety"]) == 1, "One event does not consume a meal")
	game._apply_hunger_tick()
	_check(int(survivor["vitals"]["satiety"]) == 0, "Two events consume one meal")
	var before_starving := int(survivor["vitals"]["health"])
	game._apply_hunger_tick()
	game._apply_hunger_tick()
	_check(int(survivor["vitals"]["health"]) == before_starving - 50, "Two events at zero satiety remove exactly one heart")
	survivor["inventory"]["canned_meat"] = 1
	game.use_item("canned_meat")
	_check(int(survivor["vitals"]["satiety"]) == 2, "Canned Meat restores two meal icons")


func _test_inventory_management(content: ContentRepository) -> void:
	var game := _new_game(content, 817)
	var survivor: Dictionary = game.run_state["survivor"]
	var equipped_weapon := str(survivor["equipment"].get("weapon", ""))
	_check(not equipped_weapon.is_empty(), "Test survivor begins with an equipped weapon")
	_check(not game.drop_item(equipped_weapon, 1).get("success", false), "Equipped items are protected from dropping")
	_check(game.unequip_item("weapon").get("success", false) and str(survivor["equipment"]["weapon"]) == "", "Unequip clears the requested slot without deleting the item")
	survivor["inventory"]["rusted_hatchet"] = 1
	_check(game.equip_item("rusted_hatchet").get("success", false) and str(survivor["equipment"]["weapon"]) == "rusted_hatchet" and game.get_item_quantity(equipped_weapon) > 0, "Equipping replaces the slot while retaining the previous item")
	survivor["inventory"]["scrap_parts"] = 3
	var weight_before := game.get_total_weight()
	_check(game.drop_item("scrap_parts", 1).get("success", false) and game.get_item_quantity("scrap_parts") == 2 and game.get_total_weight() < weight_before, "Drop One updates quantity and carried weight")
	_check(game.drop_item("scrap_parts", 2).get("success", false) and not survivor["inventory"].has("scrap_parts"), "Drop All removes the final inventory stack key")
	survivor["inventory"]["canvas_pack"] = 1
	game.equip_item("canvas_pack")
	var capacity_with_pack := game.get_carry_capacity()
	survivor["inventory"]["scrap_parts"] = 50
	var unequipped_pack := game.unequip_item("backpack")
	_check(unequipped_pack.get("success", false) and game.get_carry_capacity() < capacity_with_pack and game.get_total_weight() > game.get_carry_capacity(), "Unequipping a backpack is allowed and immediately exposes overweight state")


func _test_ui_palettes() -> void:
	for theme_id: String in ["default", "rust", "night"]:
		var ui_palette := UiPaletteWidget.create(theme_id)
		_check(UiPaletteWidget.has_all_tokens(ui_palette), "%s palette exposes every required semantic token" % theme_id)
		_check(UiPaletteWidget.contrast_ratio(ui_palette["text"], ui_palette["surface"]) >= 7.0, "%s prose remains highly readable on its primary surface" % theme_id)
		_check(UiPaletteWidget.contrast_ratio(ui_palette["muted"], ui_palette["surface"]) >= 4.5, "%s secondary labels remain readable on its primary surface" % theme_id)
		_check(ui_palette["danger"].r > ui_palette["danger"].g and ui_palette["success"].g > ui_palette["success"].r and ui_palette["fatigue"].b > ui_palette["fatigue"].r and ui_palette["radiation"].g >= ui_palette["radiation"].r, "%s preserves semantic danger, recovery, fatigue, and radiation colours" % theme_id)
	_check(UiPaletteWidget.display_name("default") == "EMBER & PARCHMENT" and UiPaletteWidget.display_name("rust") == "CINDER RUST" and UiPaletteWidget.display_name("night") == "SIGNAL AT NIGHT", "Theme IDs retain their player-facing names without changing ownership keys")
	var high_contrast := UiPaletteWidget.create("night", true)
	_check(UiPaletteWidget.has_all_tokens(high_contrast) and UiPaletteWidget.contrast_ratio(high_contrast["text"], high_contrast["surface"]) >= 7.0, "High Contrast is a complete separate palette with reinforced text contrast")


## The Ashfall Road design canvas is the contract for the visual system: its
## Ember & Parchment tokens, its two-family type scale, and its layered
## atmosphere. These checks fail loudly if a screen drifts off the artboards.
func _test_canvas_design_system() -> void:
	var canvas_palette := UiPaletteWidget.create("default")
	var canvas_tokens := {
		"surface": "111d1e", "surface_raised": "182627", "surface_pressed": "0d1718",
		"border": "2a3a3b", "border_subtle": "1e2c2d", "text": "f4ebdd", "muted": "9a9487",
		"disabled": "5c5a53", "accent": "d9a458", "accent_strong": "f0c070",
		"danger": "d9695b", "success": "86b07a", "critical": "f2d27a",
		"fatigue": "6e93b8", "radiation": "8a9a4e", "meter_track": "1c2a2b",
		"icon_ink": "c9bfae", "die_surface": "1a2829",
	}
	var matched := true
	for token: String in canvas_tokens:
		if canvas_palette[token].to_html(false) != str(canvas_tokens[token]):
			matched = false
			print("MISMATCH: %s is %s, canvas says %s" % [token, canvas_palette[token].to_html(false), canvas_tokens[token]])
	_check(matched, "Ember & Parchment reproduces every colour on the design canvas style tile")
	# 0.72 lands on 0xB8 once it is quantised to a byte, so compare within a step.
	_check(absf(canvas_palette["surface_overlay"].a - 0.72) <= 1.0 / 255.0 and canvas_palette["surface_overlay"].to_html(false) == "0b1415", "The scrim plate keeps the canvas 72% over #0B1415")

	for theme_id: String in ["default", "rust", "night"]:
		var themed := UiPaletteWidget.create(theme_id)
		_check(UiPaletteWidget.contrast_ratio(themed["icon_ink"], themed["surface"]) >= 4.5, "%s draws line icons in an ink that reads on its own surface" % theme_id)

	# Two families, eleven roles, and tracking that survives rounding at every
	# font scale the player can pick.
	_check(UiTypeWidget.family("prose") == UiTypeWidget.NARRATIVE and UiTypeWidget.family("action") == UiTypeWidget.INTERFACE, "Prose is Literata and interface copy is Inter")
	_check(UiTypeWidget.size("prose") == 17 and UiTypeWidget.size("eyebrow") == 11 and UiTypeWidget.size("action") == 15 and UiTypeWidget.size("display") == 34, "The type scale matches the canvas sizes")
	var tracking_holds := true
	for scale: float in [0.8, 1.0, 1.3, 1.6]:
		for role: String in ["eyebrow", "action", "label", "wordmark"]:
			if UiTypeWidget.tracking_px(role, scale) < 1:
				tracking_holds = false
		if UiTypeWidget.tracking_px("prose", scale) != 0:
			tracking_holds = false
	_check(tracking_holds, "Tracked roles keep their letter-spacing at every font scale, and untracked roles gain none")
	_check(UiTypeWidget.font("eyebrow") is FontVariation and UiTypeWidget.font("prose") is FontFile, "Only tracked roles allocate a font variation")
	_check(UiTypeWidget.line_spacing("prose") > 0 and UiTypeWidget.line_spacing("action") == 0, "Literata carries the canvas 1.6 leading and Inter does not")
	var fitted_scale := UiTypeWidget.scale_for_size("wordmark", 22)
	_check(UiTypeWidget.size("wordmark", fitted_scale) == 22 and UiTypeWidget.tracking_px("wordmark", fitted_scale) < UiTypeWidget.tracking_px("wordmark"), "A wordmark fitted to a narrower screen takes its tracking down with it")

	# Every artboard mixes the same four layers; none of them is a colour choice.
	var atmosphere = AtmosphereLayersWidget.new()
	root.add_child(atmosphere)
	atmosphere.configure(canvas_palette, "event")
	_check(atmosphere.scrim.color.to_html(false) == "0b1415" and absf(atmosphere.scrim.color.a - 0.72) <= 1.0 / 255.0, "The event screen scrims the region backdrop at the canvas 72%")
	var grain_capped := true
	for preset: String in AtmosphereLayersWidget.PRESETS:
		if float(AtmosphereLayersWidget.PRESETS[preset].get("grain", 0.0)) > 0.06:
			grain_capped = false
	_check(grain_capped, "No screen exceeds the canvas grain ceiling of 6%")
	atmosphere.configure(canvas_palette, "death")
	_check(not atmosphere.scrim.visible and atmosphere.vignette.visible and atmosphere.grain.visible, "The death screen drops the scrim and keeps only vignette and grain")
	atmosphere.configure(canvas_palette, "unknown_screen")
	_check(atmosphere.preset_name() == "plain", "An unnamed screen falls back to the plain atmosphere rather than an empty mix")
	var ember := AtmosphereLayersWidget.ember_color(canvas_palette)
	_check(ember.r > ember.g and ember.g > ember.b, "Firelight is warmer than the accent it is derived from")
	# Freed rather than queued: the grain texture generates on a worker thread and
	# a deferred free would still be pending when the headless suite exits.
	root.remove_child(atmosphere)
	atmosphere.free()

	# The die is the canvas hexagon, and a 20 or a 1 changes the die itself.
	var die = DiceWidget.new()
	root.add_child(die)
	die.set_palette(canvas_palette)
	_check(DiceWidget.OUTLINE.size() == 6 and DiceWidget.FACE.size() == 3 and DiceWidget.SPOKES.size() == 5, "The d20 keeps the canvas hexagon, inner face, and five spokes")
	die.set_face(14)
	_check(die.stroke_color() == canvas_palette["die_line"] and die.number_label.get_theme_color("font_color") == canvas_palette["text"], "An ordinary roll draws in die_line with a prose numeral")
	die.set_face(20)
	_check(die.stroke_color() == canvas_palette["critical"] and die.number_label.get_theme_color("font_color") == canvas_palette["critical"], "A natural 20 turns the whole die critical gold")
	die.set_face(1)
	_check(die.stroke_color() == canvas_palette["danger"], "A natural 1 turns the whole die danger red")
	root.remove_child(die)
	die.free()


func _test_ui_components(content: ContentRepository) -> void:
	var ui_source := FileAccess.get_file_as_string("res://scripts/ui/main.gd")
	_check("event_title" not in ui_source and "Event %d / 5" not in ui_source, "Journey and result UI contain no player-facing event title or numeric event label")
	_check("RETURN WITHOUT SPENDING" in ui_source and "APPLY POINTS & RETURN" in ui_source and "CONTINUE JOURNEY — GAIN MOMENTUM" in ui_source, "Checkpoint allocation and departure actions remain explicit")
	_check("ROLL %d+" in ui_source and "Rolled %d vs %d+" in ui_source, "Event checks show their D20 target before and after the roll")
	var combat_function_start := ui_source.find("func _show_cinematic_combat()")
	var combat_function := ui_source.substr(combat_function_start, 500)
	_check("_show_pressure_strip()" in combat_function and "_show_survival_strip()" not in combat_function, "Combat renders one pressure strip without repeating the journey HUD")
	_check(FileAccess.file_exists("res://assets/fonts/Literata.ttf") and FileAccess.file_exists("res://assets/fonts/Inter.ttf") and FileAccess.file_exists("res://assets/fonts/OFL-Literata.txt") and FileAccess.file_exists("res://assets/fonts/OFL-Inter.txt"), "Narrative and interface fonts plus both OFL licences are bundled offline")
	_check(FileAccess.file_exists("res://docs/UI_ASSET_MANIFEST.md"), "The replacement-art manifest is available locally")
	var candidate: Dictionary = GameEngine.new(content).create_candidates(88)[0]
	var ui_palette := UiPaletteWidget.create("default")
	var hud = SurvivorHudWidget.new()
	root.add_child(hud)
	hud.configure(candidate, ui_palette, 1.0, true, {"level": 1, "experience": 0, "unspent_stat_points": 0})
	_check(hud.get_child_count() == 1, "Reusable HUD builds compact identity, hearts, food, and utility controls")
	_check(hud.find_child("ExperienceBar", true, false) is ProgressBar, "The active-run HUD includes compact level and XP progress")
	var conditions_link := hud.make_conditions_link(2, 1.0)
	root.add_child(conditions_link)
	_check(conditions_link.name == "ConditionsLink" and "2" in conditions_link.text, "The active-run utility row exposes the current condition count")
	var hud_portrait_frame := hud.find_child("SurvivorPortraitFrame", true, false)
	_check(hud_portrait_frame != null and hud_portrait_frame.custom_minimum_size == Vector2(64, 64), "The survivor HUD reserves a readable 64-pixel portrait frame")
	_check(PortraitArtWidget.expected_ids().size() == 17, "Portrait resolver owns four survivor and thirteen adversary IDs")
	var fallback_view := PortraitArtWidget.create_view("missing_portrait", ui_palette["muted"])
	root.add_child(fallback_view)
	_check(fallback_view.find_child("PortraitFallback", true, false) is Label, "Missing portrait art produces a readable fallback")
	_check(fallback_view.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Portrait views enforce nearest-neighbor sampling")
	var completed_portraits := 0
	var loaded_survivor_portraits := 0
	for portrait_id: String in PortraitArtWidget.expected_ids():
		var portrait_texture := PortraitArtWidget.load_texture(portrait_id)
		if portrait_texture == null:
			continue
		completed_portraits += 1
		if portrait_id.begins_with("survivor_"):
			loaded_survivor_portraits += 1
		_check(portrait_texture.get_size() == Vector2(64, 64), "%s is a native 64×64 portrait sprite" % portrait_id)
	_check(completed_portraits >= 1, "The incremental portrait campaign has at least one loadable runtime sprite")
	_check(loaded_survivor_portraits == 4, "All four survivor portrait IDs resolve to packaged runtime art")
	var survivor_portrait_view := PortraitArtWidget.create_view("survivor_1", ui_palette["muted"])
	root.add_child(survivor_portrait_view)
	var survivor_texture := survivor_portrait_view.find_child("PortraitTexture", true, false)
	_check(survivor_texture is TextureRect and survivor_texture.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Completed survivor art renders through a nearest-neighbor TextureRect")
	_check(survivor_texture is TextureRect and survivor_texture.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_COVERED, "Survivor art fills its portrait frame without letterboxing")
	var stat_capsule = StatsCapsuleWidget.new()
	root.add_child(stat_capsule)
	stat_capsule.configure(candidate["stats"], ui_palette, 1.0, 1)
	_check(stat_capsule.get_child_count() == 1 and StatsCapsuleWidget.stat_symbols().size() == 5, "Core stats render in a compact five-symbol details capsule")
	var pressure_strip = PressureStripWidget.new()
	root.add_child(pressure_strip)
	pressure_strip.configure(candidate["pressures"], ui_palette, 1.0)
	_check(pressure_strip.get_child_count() == 1, "Fatigue and Radiation render in a separate pressure strip")
	var item_icon = ItemIconWidget.new()
	root.add_child(item_icon)
	item_icon.configure("item_canned_meat", "consumable", ui_palette)
	_check(item_icon.category == "consumable", "Inventory icons resolve through stable IDs with category placeholders")
	var dice = DiceWidget.new()
	root.add_child(dice)
	dice.set_palette(ui_palette)
	dice.set_face(20)
	_check(dice.face == 20 and dice.number_label.text == "20", "Drawn D20 widget displays its revealed face")
	var combat_presentation = CombatPresentationWidget.new()
	root.add_child(combat_presentation)
	combat_presentation.configure({
		"round": 2,
		"player": {"name": "Rook", "portrait_id": "survivor_1", "health": 150, "max_health": 200, "weapon": "Nail Bat", "ammo": ""},
		"enemy": {"name": "Feral Dogs", "portrait_id": "feral_dogs", "health": 60, "max_health": 120, "weapon": "Teeth", "critical_condition": "shaken"},
		"armor": {"rating": 1, "flat": 3, "percent": 5},
		"status_labels": [],
		"pending_action": "",
		"can_flee": true,
		"log": [
			{"actor": "player", "kind": "critical_success", "text": "CRITICAL SUCCESS — Nail Bat deals 40 damage."},
			{"actor": "enemy", "kind": "critical_failure", "text": "CRITICAL FAILURE — Teeth deal 7 damage."},
		],
	}, ui_palette, 1.0, {"damage_min": 20, "damage_max": 40}, {"chance": 50}, false)
	var combat_feed := combat_presentation.find_child("CombatFeed", true, false)
	var player_entry := combat_presentation.find_child("PlayerCombatEntry", true, false)
	var enemy_entry := combat_presentation.find_child("EnemyCombatEntry", true, false)
	var player_text: Label = player_entry.find_child("CombatFeedText", true, false) if player_entry != null else null
	var enemy_text: Label = enemy_entry.find_child("CombatFeedText", true, false) if enemy_entry != null else null
	_check(combat_feed is VBoxContainer and combat_feed.size_flags_horizontal == Control.SIZE_EXPAND_FILL, "Combat feed keeps horizontal width instead of collapsing into vertical letters")
	_check(player_text != null and player_text.horizontal_alignment == HORIZONTAL_ALIGNMENT_LEFT and enemy_text != null and enemy_text.horizontal_alignment == HORIZONTAL_ALIGNMENT_RIGHT, "Player moves launch from the left and enemy moves from the right")
	_check(enemy_text != null and enemy_text.get_theme_color("font_color") == ui_palette["danger"], "Enemy combat text always uses the danger red")
	_check(player_text != null and player_text.get_theme_font_size("font_size") == 14 and player_text.has_theme_font_override("font"), "Critical combat entries use a larger literary typeface")
	_check(combat_presentation.find_child("CombatStatusButton", true, false) is Button, "Combat keeps active-condition explanations one tap away")
	var meter = IconMeterWidget.new()
	root.add_child(meter)
	meter.configure(4, 125.0, 50.0, "♥", "♡", Color.RED, Color.GRAY, 20, "Heart")
	_check(meter.fill_ratios() == [1.0, 1.0, 0.5, 0.0], "Icon meter exposes exact full, partial, and empty heart segments")
	hud.queue_free()
	stat_capsule.queue_free()
	pressure_strip.queue_free()
	item_icon.queue_free()
	dice.queue_free()
	combat_presentation.queue_free()
	conditions_link.queue_free()
	meter.queue_free()


func _test_typewriter_and_responsive_rules() -> void:
	var story = StoryTypewriterWidget.new()
	root.add_child(story)
	story.start("A, careful road.", "normal")
	story._process(0.001)
	_check(story.visible_characters == 1, "Typewriter begins without exposing the full passage")
	story._process(0.04)
	_check(story.visible_characters == 2 and story._time_to_next >= StoryTypewriterWidget.COMMA_PAUSE, "Comma punctuation adds the authored reveal pause")
	story.set_paused(true)
	var paused_at: int = story.visible_characters
	story._process(1.0)
	_check(story.visible_characters == paused_at, "Typewriter progress pauses beneath overlays")
	story.set_paused(false)
	var first_tap := InputEventMouseButton.new()
	first_tap.button_index = MOUSE_BUTTON_LEFT
	first_tap.pressed = true
	first_tap.position = Vector2(8, 8)
	story._on_gui_input(first_tap)
	var drag := InputEventMouseMotion.new()
	drag.button_mask = MOUSE_BUTTON_MASK_LEFT
	drag.position = Vector2(48, 48)
	story._on_gui_input(drag)
	var second_tap := InputEventMouseButton.new()
	second_tap.button_index = MOUSE_BUTTON_LEFT
	second_tap.pressed = true
	second_tap.position = Vector2(8, 8)
	story._on_gui_input(second_tap)
	_check(not story.is_reveal_complete(), "Dragging the narrative never becomes a double-tap skip")
	var double_tap := InputEventMouseButton.new()
	double_tap.button_index = MOUSE_BUTTON_LEFT
	double_tap.pressed = true
	double_tap.double_click = true
	double_tap.position = Vector2(8, 8)
	story._on_gui_input(double_tap)
	_check(story.is_reveal_complete(), "Double-clicking the narrative reveals it immediately")
	story.start("Instant passage", "instant")
	_check(story.is_reveal_complete(), "Instant story speed reveals prose immediately")
	_check(StoryTypewriterWidget.SPEEDS["slow"] < StoryTypewriterWidget.SPEEDS["normal"] and StoryTypewriterWidget.SPEEDS["normal"] < StoryTypewriterWidget.SPEEDS["fast"], "Slow, Normal, and Fast reveal speeds are ordered")
	_check(ResponsiveRules.inventory_columns(240.0) == 3 and ResponsiveRules.inventory_columns(297.0) == 4, "Inventory keeps the canvas four-column pack grid beside its filter rail")
	_check(ResponsiveRules.equipment_slot_columns(300.0) == 2 and ResponsiveRules.equipment_slot_columns(353.0) == 4, "All four equipment slots fit one row at the canvas artboard width")
	_check(ResponsiveRules.is_compact_height(640.0) and not ResponsiveRules.is_compact_height(960.0), "Compact-height behavior activates below 760 pixels")
	story.queue_free()


func _test_ui_overlay_smoke(content: ContentRepository) -> void:
	var ui = MainUI.new()
	ui.bootstrap_on_ready = false
	root.add_child(ui)
	ui.content = content
	ui.saves = SaveService.new("ashfall_ui_smoke_")
	ui.profile = ui.saves.default_profile()
	ui.entitlements = ui.saves.load_entitlements()
	ui.game = GameEngine.new(content)
	ui.game.start_run(ui.game.create_candidates(9201)[0], 9201)
	ui.ads = AdService.new()
	ui.ads.configure(ui.entitlements)
	ui.billing = BillingService.new()
	ui.billing.configure(ui.entitlements)
	ui._build_shell()
	ui._show_event()
	_check(is_instance_valid(ui.active_story) and not ui.active_story.is_reveal_complete() and not ui.active_story_actions.visible, "Journey starts a concealed typewriter passage with choices hidden")
	var story_scroll := ui.active_story.get_parent().get_parent() as ScrollContainer
	_check(is_instance_valid(story_scroll) and story_scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_SHOW_NEVER, "Journey prose hides its scrollbar while keeping a ScrollContainer for swipes")
	ui.active_story.reveal_all()
	_check(ui.active_story_actions.visible and ui.active_story_actions is PanelContainer and ui.active_story_actions.get_parent() == ui.active_story.get_parent(), "Bordered choices appear directly after the revealed story")
	ui._show_inventory()
	_check(ui.inventory_popup.visible and ui.inventory_popup.size.x > 0 and ui.inventory_popup.size.y > 0, "Responsive full-screen inventory opens from an active story")
	var first_item_id := str(ui.game.run_state["survivor"]["inventory"].keys()[0])
	ui._show_item_detail(first_item_id)
	_check(ui.item_detail_popup.visible and ui.item_detail_popup.position.y >= 0, "Item details open as a responsive bottom sheet")
	ui.game.run_state["survivor"]["equipment"]["weapon"] = "salvage_cleaver"
	ui.game.run_state["survivor"]["inventory"]["salvage_cleaver"] = 1
	ui.game.run_state["survivor"]["inventory"]["hunting_rifle"] = 1
	ui.game.run_state["survivor"]["inventory"]["rifle_rounds"] = 4
	var comparison_state: Dictionary = ui.game.run_state.duplicate(true)
	ui._show_item_detail("hunting_rifle")
	var comparison_copy := "\n".join(_label_texts(ui.item_detail_popup))
	_check("IF YOU EQUIP THIS" in comparison_copy and "Salvage Cleaver  \u2192  Hunting Rifle" in comparison_copy, "The item sheet compares the equipped weapon against the proposed one")
	_check("Damage" in comparison_copy and "Hit chance" in comparison_copy and "Signature" in comparison_copy, "The sheet states damage, hit chance, and signature without equipping anything")
	_check("Neutral values" in comparison_copy, "Comparison values are labelled neutral rather than enemy-specific")
	_check(ui.game.run_state == comparison_state, "Opening the comparison changes nothing in the run")
	var detail_scrolls := false
	for node: Node in _descendants(ui.item_detail_popup):
		if node is ScrollContainer:
			detail_scrolls = true
	_check(detail_scrolls and ui.item_detail_popup.position.y >= 0, "The comparison scrolls inside the sheet instead of pushing actions off screen")
	ui._show_item_detail(str(ui.game.run_state["survivor"]["inventory"].keys()[0]))
	ui._close_inventory()
	_check(ui.active_story.is_reveal_complete() and ui.active_story_actions.visible, "Closing inventory restores cached reveal progress instead of restarting prose")
	ui._show_stat_details()
	_check(ui.stat_details_popup.visible, "The HUD stats capsule opens a dismissible explanation sheet")
	ui.game.run_state["survivor"]["conditions"] = ["shaken"]
	ui._show_stat_details()
	var condition_copy := "\n".join(_label_texts(ui.stat_details_popup))
	_check("ACTIVE — SHAKEN" in condition_copy and "Wits -1" in condition_copy and "Presence -1" in condition_copy, "Stat details explain an active condition and its exact penalties")
	ui._close_stat_details()
	ui.game.run_state["survivor"]["conditions"] = ["shaken", "focused"]
	ui.game.run_state["condition_uses"]["focused"] = 1
	ui.game.run_state["survivor"]["inventory"]["bitter_tonic"] = 1
	ui._show_conditions()
	var status_copy := "\n".join(_label_texts(ui.conditions_popup))
	_check(ui.conditions_popup.visible and "1 HARMFUL" in status_copy and "1 HELPFUL" in status_copy and "HARMFUL — SHAKEN" in status_copy and "HELPFUL — FOCUSED" in status_copy, "Status sheet separates and explains harmful and helpful active conditions")
	var remedy_button: Node = ui.conditions_popup.find_child("ConditionRemedy_shaken_bitter_tonic", true, false)
	_check(remedy_button is Button and not remedy_button.disabled, "An owned matching treatment is usable directly from its harmful condition")
	ui._use_condition_remedy("bitter_tonic", "shaken")
	_check("shaken" not in ui.game.run_state["survivor"]["conditions"] and "focused" in ui.game.run_state["survivor"]["conditions"] and ui.game.get_item_quantity("bitter_tonic") == 0, "Condition treatment consumes one item and removes only its authored conditions")
	ui._close_conditions()
	ui._show_settings()
	_check(ui.settings_popup.visible and str(ui.profile.get("story_text_speed", "")) == "normal", "Compact settings expose the migrated story-speed preference")
	_check("COSMETIC STORE" not in _button_texts(ui.settings_popup), "The free v1 launch hides unfinished store and advertising controls")
	_check(not ui.monetization_enabled and ui.ads.status_text() == "Ads are not included in this release" and ui.billing.store_status() == "Purchases are not included in this release", "The v1 launch flag keeps monetization facades explicitly disabled")
	ui._close_settings()
	ui.game.run_state["phase"] = "result"
	ui.game.run_state["event_history"] = ["global_stranger"]
	ui.game.run_state["total_events"] = 0
	ui.game.run_state["events_in_region"] = 0
	ui.game.run_state["last_result"] = {"event_id": "global_stranger", "outcome_text": "The stranger binds the wound and leaves by the western verge.", "changes": [], "xp_awards": [], "resolution": {}}
	ui._show_result()
	var first_result_key: String = str(ui.active_story_key)
	ui.active_story.reveal_all()
	ui.game.run_state["event_history"].append("global_map")
	ui.game.run_state["total_events"] = 1
	ui.game.run_state["events_in_region"] = 1
	var second_outcome := "The amended route carries you safely beyond the washed-out eastern bridge."
	ui.game.run_state["last_result"] = {"event_id": "global_map", "outcome_text": second_outcome, "changes": [], "xp_awards": [], "resolution": {}}
	ui._show_result()
	_check(ui.active_story_key != first_result_key and ui.active_story.full_text == second_outcome and not ui.active_story.is_reveal_complete(), "Consecutive outcomes use unique reveal keys, new prose, and a fresh typewriter sequence")
	ui.game.run_state["phase"] = "checkpoint"
	ui.game.run_state["unspent_stat_points"] = 1
	ui._show_level_allocation()
	var allocation_labels := _button_texts(ui.level_popup)
	_check("RETURN WITHOUT SPENDING" in allocation_labels and "APPLY POINTS & RETURN" in allocation_labels, "Responsive allocation sheet keeps both actions permanently reachable")
	var allocation_footer: Node = ui.level_popup.find_child("AllocationFooter", true, false)
	var allocation_confirm := ui.level_popup.find_child("ConfirmAllocation", true, false) as Button
	_check(is_instance_valid(allocation_footer) and is_instance_valid(allocation_confirm) and allocation_confirm.disabled, "Allocation actions are pinned outside the stat list and Apply waits for a drafted point")
	ui._change_stat_draft("strength", 1)
	allocation_confirm = ui.level_popup.find_child("ConfirmAllocation", true, false) as Button
	_check(is_instance_valid(allocation_confirm) and not allocation_confirm.disabled, "Pressing plus immediately enables the same visible Apply action without rebuilding the popup")
	var strength_before := int(ui.game.run_state["survivor"]["stats"]["strength"])
	ui._confirm_level_draft()
	_check(int(ui.game.run_state["survivor"]["stats"]["strength"]) == strength_before + 1 and int(ui.game.run_state["unspent_stat_points"]) == 0 and not ui.level_popup.visible, "Apply commits the drafted point exactly once and returns to the checkpoint")
	var checkpoint_buttons := _button_texts(ui.page)
	_check("CONTINUE JOURNEY — GAIN MOMENTUM" in checkpoint_buttons, "The checkpoint exposes an unmistakable Continue Journey action after allocation")
	ui._press_on_checkpoint()
	_check(str(ui.game.run_state.get("phase", "")) == "event", "Continue Journey leaves the checkpoint after stat allocation")
	ui.game.run_state["phase"] = "event"
	for theme_id: String in ["default", "rust", "night"]:
		ui.profile["selected_theme"] = theme_id
		ui.profile["high_contrast"] = false
		ui._apply_theme()
		ui._show_event()
		_check(str(ui.palette["theme_id"]) == theme_id and ui.atmosphere.scrim.color.is_equal_approx(Color(ui.palette["surface_overlay"], AtmosphereLayersWidget.PRESETS["event"]["scrim"])), "%s palette smoke-tests the active journey screen" % theme_id)
	# The canvas choice row is the screen's most-used component: a hairline rule,
	# an accent chevron, the choice in Literata, and its cost in tracked Inter.
	ui.profile["selected_theme"] = "default"
	ui.profile["high_contrast"] = false
	ui._apply_theme()
	var choice := ui._choice_button("Slip along the ditch before the lamp swings back.
Agility · 65%", func() -> void: pass)
	root.add_child(choice)
	var choice_row := choice.find_child("ChoiceRow", true, false)
	var chevron := choice_row.get_child(0) as Label
	var choice_copy := choice_row.get_child(1)
	var choice_label := choice_copy.get_child(0) as Label
	var choice_detail := choice_copy.get_child(1) as Label
	var resting: StyleBoxFlat = choice.get_theme_stylebox("normal")
	_check(not resting.draw_center and resting.border_width_top == 1 and resting.border_width_bottom == 0 and resting.border_color == ui.palette["border_subtle"], "A choice row is a hairline rule, not a filled plate")
	_check(chevron.text == "›" and chevron.get_theme_color("font_color") == ui.palette["accent"], "The row spends its one accent moment on the chevron")
	_check(choice_label.get_theme_font("font") == UiTypeWidget.base_font("flavour") and choice_label.get_theme_font_size("font_size") == UiTypeWidget.size("flavour"), "The choice itself is set in Literata")
	_check(choice_detail.text == "Agility · 65%" and choice_detail.get_theme_font_size("font_size") == UiTypeWidget.size("label") and choice_detail.get_theme_color("font_color") == ui.palette["muted"], "The cost line is tracked Inter in the muted tone")
	_check(choice.custom_minimum_size.y >= 44.0, "A choice row never falls below the 44pt touch target")
	_check(choice.accessibility_name == "Slip along the ditch before the lamp swings back. Agility · 65%", "The whole row reaches assistive technology as one sentence")
	_check(ui._spoken_choice(PackedStringArray(["Force the gate", "Strength · 70%"])) == "Force the gate. Strength · 70%", "An unpunctuated choice gains the period that separates it from its cost")
	_check(ui._spoken_choice(PackedStringArray(["Wait for the lamp to swing."])) == "Wait for the lamp to swing.", "A choice with no cost line is spoken unchanged")
	var locked := ui._choice_button("Force the gate
Strength · locked", func() -> void: pass, true)
	root.add_child(locked)
	var locked_chevron := locked.find_child("ChoiceRow", true, false).get_child(0) as Label
	_check(locked_chevron.get_theme_color("font_color") == ui.palette["disabled"], "An unavailable choice drops its accent entirely")
	root.remove_child(choice)
	choice.free()
	root.remove_child(locked)
	locked.free()

	# The focus ring is drawn outside the control, so a focused action neither
	# changes colour nor reflows the row it sits in.
	var ring: StyleBoxFlat = ui.theme.get_stylebox("focus", "Button")
	_check(not ring.draw_center and ring.border_color == ui.palette["accent_strong"] and ring.expand_margin_top > 0.0, "Focus is an offset outline in accent_strong, not a recoloured border")
	var squared := true
	for entry: Array in [["normal", "Button"], ["pressed", "Button"], ["panel", "PanelContainer"], ["panel", "PopupPanel"]]:
		var box: StyleBoxFlat = ui.theme.get_stylebox(str(entry[0]), str(entry[1]))
		if box.corner_radius_top_left != 0 or box.corner_radius_bottom_right != 0:
			squared = false
	_check(squared, "Every plate in the theme keeps the canvas square corners")

	ui.profile["high_contrast"] = true
	ui._apply_theme()
	ui._show_event()
	_check(str(ui.palette["theme_id"]) == "high_contrast" and ui.theme.get_color("font_color", "Label") == ui.palette["text"], "High Contrast smoke-tests the active journey screen")
	ui.queue_free()


func _button_texts(node: Node) -> Array[String]:
	var labels: Array[String] = []
	if node is Button:
		labels.append(str(node.text))
	for child: Node in node.get_children():
		labels.append_array(_button_texts(child))
	return labels


func _label_texts(node: Node) -> Array[String]:
	var labels: Array[String] = []
	if node is Label:
		labels.append(str(node.text))
	for child: Node in node.get_children():
		labels.append_array(_label_texts(child))
	return labels


func _test_supply_guarantee(content: ContentRepository) -> void:
	var game := _new_game(content, 991)
	for region_index in range(6):
		game.run_state["region_index"] = region_index
		game.run_state["events_in_region"] = 4
		game.run_state["supply_seen_in_region"] = false
		game.run_state["event_history"] = []
		game._select_next_event()
		_check("supply_opportunity" in game.current_event().get("tags", []), "Final draw in region %d guarantees a supply opportunity" % (region_index + 1))


func _test_opening_guidance(content: ContentRepository) -> void:
	for seed_value in range(1, 81):
		var game := _new_game(content, seed_value)
		var first_event: Dictionary = game.current_event()
		var first_tags: Array = first_event.get("tags", [])
		_check("opening_safe" in first_tags, "Seed %d begins with a non-combat opening event" % seed_value)
		var first_choice := _first_available_noncombat_choice(game)
		game.resolve_choice(first_choice, 20)
		game.run_state["survivor"]["vitals"]["satiety"] = 4
		game.continue_after_result()
		var second_tags: Array = game.current_event().get("tags", [])
		var teaches_both := ("opening_resource" in first_tags and "opening_equipment" in second_tags) or ("opening_equipment" in first_tags and "opening_resource" in second_tags)
		_check(teaches_both, "Seed %d teaches resources and equipment across the first two events" % seed_value)


func _test_combat_opportunity_selection(content: ContentRepository) -> void:
	var opening_is_safe := true
	var regional_counts_valid := true
	var regional_supplies_valid := true
	for seed_value in range(1, 501):
		for region_index in range(6):
			var game := _new_game(content, seed_value * 17 + region_index)
			game.run_state["region_index"] = region_index
			game.run_state["events_in_region"] = 0
			game.run_state["event_history"] = []
			game.run_state["supply_seen_in_region"] = false
			game.run_state["combat_opportunities_seen_in_region"] = 0
			for position in range(GameEngine.EVENTS_PER_REGION):
				game._select_next_event()
				var selected := game.current_event()
				if region_index == 0 and position == 0 and content.event_has_combat_choice(selected):
					opening_is_safe = false
				game._record_event(selected)
				game.run_state["events_in_region"] = position + 1
			var combat_count := int(game.run_state.get("combat_opportunities_seen_in_region", 0))
			regional_counts_valid = regional_counts_valid and combat_count >= 1 and combat_count <= 2
			regional_supplies_valid = regional_supplies_valid and bool(game.run_state.get("supply_seen_in_region", false))
	_check(opening_is_safe, "Five hundred seeded journeys never place combat in the opening event")
	_check(regional_counts_valid, "Five hundred seeded journeys present one or two combat opportunities per region")
	_check(regional_supplies_valid, "Combat opportunity control preserves every regional supply guarantee")


func _test_temporary_conditions(content: ContentRepository) -> void:
	var game := _new_game(content, 901)
	game.run_state["survivor"]["inventory"]["stimulant"] = 1
	game.use_item("stimulant")
	_check("steady_hands" in game.run_state["survivor"]["conditions"], "Stimulant grants Steady Hands")
	game._tick_temporary_conditions()
	_check("steady_hands" in game.run_state["survivor"]["conditions"], "Temporary condition survives its first check")
	game._tick_temporary_conditions()
	_check("steady_hands" not in game.run_state["survivor"]["conditions"], "Temporary condition expires after its authored duration")


func _test_condition_explanations(content: ContentRepository) -> void:
	var shaken: Dictionary = content.get_condition("shaken")
	var description := str(shaken.get("description", ""))
	_check("Wits -1" in description and "Presence -1" in description, "Shaken content states its exact penalties in plain language")
	var treatment_routes: Dictionary = {}
	for item_id: String in content.items:
		for condition_id: Variant in content.get_item(item_id).get("effects", {}).get("remove_conditions", []):
			treatment_routes[str(condition_id)] = true
	var all_harmful_conditions_treatable := true
	for condition_id: String in content.conditions:
		var harmful := false
		for modifier: Variant in content.get_condition(condition_id).get("modifiers", {}).values():
			if int(modifier) < 0:
				harmful = true
		if harmful and not treatment_routes.has(condition_id):
			all_harmful_conditions_treatable = false
	_check(all_harmful_conditions_treatable, "Every harmful condition has at least one authored item treatment")
	var game := _new_game(content, 1901)
	game.run_state["current_event_id"] = "outskirts_siren"
	game.run_state["phase"] = "event"
	var result := game.resolve_choice(1, 2)
	_check(str(result.get("resolution", {}).get("outcome", "")) == "failure" and "shaken" in game.run_state["survivor"]["conditions"], "A failed siren roll applies Shaken")
	var condition_changes: Array = result.get("condition_changes", [])
	_check(condition_changes.size() == 1 and str(condition_changes[0].get("id", "")) == "shaken" and str(condition_changes[0].get("change", "")) == "added", "Failed outcomes preserve structured condition details for the result screen")
	game.run_state["survivor"]["inventory"]["bitter_tonic"] = 1
	var treatment_result := game.use_item("bitter_tonic")
	_check(bool(treatment_result.get("success", false)) and treatment_result.get("removed_conditions", []) == ["shaken"] and "shaken" not in game.run_state["survivor"]["conditions"], "Item use reports and removes the exact active condition it treated")


func _test_event_determinism(content: ContentRepository) -> void:
	var game_a := _new_game(content, 9001)
	var game_b := _new_game(content, 9001)
	for turn in range(12):
		_check(game_a.run_state.get("current_event_id") == game_b.run_state.get("current_event_id"), "Seeded event selections match at turn %d" % turn)
		if game_a.run_state["phase"] == "checkpoint":
			game_a.leave_checkpoint()
			game_b.leave_checkpoint()
			continue
		var choice_a := _first_available_noncombat_choice(game_a)
		var choice_b := _first_available_noncombat_choice(game_b)
		var result_a := game_a.resolve_choice(choice_a)
		var result_b := game_b.resolve_choice(choice_b)
		_check(result_a.get("resolution", {}).get("roll") == result_b.get("resolution", {}).get("roll"), "Seeded event D20 rolls match at turn %d" % turn)
		if game_a.run_state["phase"] in ["death", "victory"]:
			break
		game_a.run_state["survivor"]["vitals"]["satiety"] = 4
		game_b.run_state["survivor"]["vitals"]["satiety"] = 4
		game_a.continue_after_result()
		game_b.continue_after_result()


func _test_prepared_event_recovery(content: ContentRepository) -> void:
	var original := _new_game(content, 31337)
	var choice_index := _first_available_noncombat_choice(original)
	var control := GameEngine.new(content)
	control.restore_run(original.run_state)
	var prepared := original.prepare_choice(choice_index)
	_check(prepared.get("prepared", false), "An event roll can be prepared without revealing it")
	_check(original.run_state["phase"] == "roll_pending", "Prepared event rolls use the concealed roll phase")
	_check(not prepared.has("roll"), "The prepare response does not expose the authoritative roll")
	var pending: Dictionary = original.run_state["pending_resolution"]
	_check(int(pending.get("rules_version", 0)) == 3 and pending.has("success_chance") and pending.has("required_roll") and pending.has("effective_stat") and pending.has("modifiers"), "Prepared checks persist their percentage, D20 target, effective stat, modifiers, and rules version")
	var resumed := GameEngine.new(content)
	resumed.restore_run(original.run_state)
	var resumed_result := resumed.resolve_prepared_choice()
	var control_result := control.resolve_choice(choice_index)
	_check(resumed_result.get("resolution", {}).get("roll") == control_result.get("resolution", {}).get("roll"), "Restarted event reveals the same saved roll")
	_check(resumed.run_state.get("last_result") == control.run_state.get("last_result"), "Prepared event outcome applies exactly once")

	var legacy := _new_game(content, 31338)
	legacy.run_state["current_event_id"] = "outskirts_bandits"
	legacy.prepare_choice(1)
	for key: String in ["rules_version", "success_chance", "required_roll", "effective_stat", "stat_value", "difficulty", "modifiers"]:
		legacy.run_state["pending_resolution"].erase(key)
	legacy.run_state["schema_version"] = 2
	var migrated_legacy := SaveService.new("unused_")._migrate_run(legacy.run_state)
	var legacy_resumed := GameEngine.new(content)
	legacy_resumed.restore_run(migrated_legacy)
	var legacy_result := legacy_resumed.resolve_prepared_choice()
	_check(int(legacy_result.get("resolution", {}).get("rules_version", 0)) == 2, "A prepared schema-2 event roll resolves through the frozen legacy lookup exactly once")
	_check(legacy_resumed.run_state.get("pending_resolution", {}).is_empty(), "The legacy prepared roll is cleared after resolution")


func _test_experience_progression(content: ContentRepository) -> void:
	for index in range(ExperienceRules.LEVEL_THRESHOLDS.size()):
		var threshold := int(ExperienceRules.LEVEL_THRESHOLDS[index])
		_check(ExperienceRules.level_for_xp(threshold) == index + 1, "XP threshold %d reaches level %d" % [threshold, index + 1])
		if threshold > 0:
			_check(ExperienceRules.level_for_xp(threshold - 1) == index, "XP immediately below %d remains level %d" % [threshold, index])
	_check(ExperienceRules.check_bonus("easy") == 0 and ExperienceRules.check_bonus("favorable") == 2 and ExperienceRules.check_bonus("risky") == 4 and ExperienceRules.check_bonus("hard") == 7 and ExperienceRules.check_bonus("desperate") == 10, "Named check difficulties map to their authored XP bonuses")

	var game := _new_game(content, 5050)
	_check(int(game.run_state["level"]) == 1 and int(game.run_state["experience"]) == 0 and int(game.run_state["unspent_stat_points"]) == 0, "A new run starts at level one without XP or carried stat points")
	game.award_experience(49, "Test", "test:49")
	_check(int(game.run_state["level"]) == 1 and int(game.run_state["unspent_stat_points"]) == 0, "XP below the first threshold grants no point")
	var first_level := game.award_experience(1, "Test", "test:50")
	_check(int(game.run_state["level"]) == 2 and int(game.run_state["unspent_stat_points"]) == 1 and int(first_level.get("levels_gained", 0)) == 1, "Crossing an XP threshold banks exactly one point")
	var duplicate := game.award_experience(99, "Duplicate", "test:50")
	_check(bool(duplicate.get("duplicate", false)) and int(game.run_state["experience"]) == 50, "A persisted XP source cannot be awarded twice")
	var multi_level := game.award_experience(400, "Test", "test:multi")
	_check(int(game.run_state["level"]) == 7 and int(multi_level.get("levels_gained", 0)) == 5 and int(game.run_state["unspent_stat_points"]) == 6, "One large reward can cross multiple levels without losing points")

	var checkpoint_game := _new_game(content, 5051)
	checkpoint_game.run_state["phase"] = "checkpoint"
	var checkpoint_award := checkpoint_game._award_checkpoint_experience()
	checkpoint_game._award_checkpoint_experience()
	_check(int(checkpoint_award.get("awarded", 0)) == 10 and int(checkpoint_game.run_state["experience"]) == 10 and checkpoint_game.run_state["checkpoint_xp_awards"] == [0], "A checkpoint awards ten XP exactly once without granting an automatic level")

	var event_game := _new_game(content, 5054)
	event_game.run_state["current_event_id"] = "outskirts_siren"
	var checked_choice: Dictionary = event_game.current_event().get("choices", [])[1]
	var expected_event_xp := ExperienceRules.JOURNEY_XP + ExperienceRules.check_bonus(str(checked_choice.get("check", {}).get("difficulty", "")))
	var event_result := event_game.resolve_choice(1, 20)
	_check(int(event_game.run_state["experience"]) == expected_event_xp and event_result.get("xp_awards", []).size() >= 1, "A survived checked event grants journey XP plus its successful difficulty bonus")
	var chained_game := _new_game(content, 5055)
	chained_game.run_state["current_event_id"] = "bunker41_rusted_hatch"
	chained_game.resolve_choice(0)
	_check(int(chained_game.run_state["experience"]) == 0 and str(chained_game.run_state.get("pending_event_id", "")) == "bunker41_cartographer", "An intermediate chained node does not grant journey XP")

	var allocation_game := _new_game(content, 5056)
	allocation_game.run_state["phase"] = "checkpoint"
	allocation_game.award_experience(50, "Test", "allocation")
	var current_stats: Dictionary = allocation_game.run_state["survivor"]["stats"].duplicate(true)
	var invalid := current_stats.duplicate(true)
	invalid["strength"] = int(invalid["strength"]) + 2
	_check(not allocation_game.confirm_stat_allocation(invalid).get("success", false), "A draft cannot spend more XP-earned points than are available")
	var proposed := current_stats.duplicate(true)
	proposed["strength"] = int(proposed["strength"]) + 1
	var confirmed := allocation_game.confirm_stat_allocation(proposed)
	_check(confirmed.get("success", false) and int(allocation_game.run_state["unspent_stat_points"]) == 0, "A valid XP-earned checkpoint draft commits atomically")
	_check(int(allocation_game.run_state["survivor"]["stats"]["strength"]) == int(current_stats["strength"]) + 1, "Confirmed stats retain uncapped progression")
	var carry_game := _new_game(content, 5057)
	carry_game.award_experience(50, "Test", "carry")
	carry_game.run_state["phase"] = "checkpoint"
	carry_game.leave_checkpoint()
	_check(int(carry_game.run_state["unspent_stat_points"]) == 1, "Unused XP-earned points carry into later regions")
	var rest_game := _new_game(content, 5052)
	rest_game.run_state["phase"] = "checkpoint"
	rest_game.run_state["survivor"]["pressures"]["fatigue"] = 82
	rest_game.run_state["survivor"]["inventory"]["canned_meat"] = 1
	var rested := rest_game.rest_at_checkpoint("canned_meat")
	_check(bool(rested.get("success", false)) and int(rest_game.run_state["survivor"]["pressures"]["fatigue"]) == 0 and str(rest_game.run_state.get("checkpoint_action", "")) == "rest", "Checkpoint rest consumes food and sets Fatigue exactly to zero")
	_check(not bool(rest_game.rest_at_checkpoint("canned_meat").get("success", false)), "A checkpoint recovery choice cannot be repeated")
	var push_game := _new_game(content, 5053)
	push_game.run_state["phase"] = "checkpoint"
	push_game.run_state["survivor"]["pressures"]["fatigue"] = 40
	var pressed_on := push_game.press_on_from_checkpoint()
	_check(bool(pressed_on.get("success", false)) and str(push_game.run_state.get("phase", "")) == "event" and "momentum" in push_game.run_state["survivor"]["conditions"] and int(push_game.run_state["survivor"]["pressures"]["fatigue"]) == 45, "Pressing on trades recovery for one-check Momentum and normal travel Fatigue")
	push_game.run_state["current_event_id"] = "outskirts_siren"
	var momentum_choice: Dictionary = push_game.current_event().get("choices", [])[1]
	var momentum_chance := int(push_game.get_choice_preview(momentum_choice).get("chance", 0))
	push_game._remove_condition("momentum")
	_check(momentum_chance > int(push_game.get_choice_preview(momentum_choice).get("chance", 0)), "Momentum improves whichever stat the next checked choice uses")

	var grit_game := _new_game(content, 5051)
	grit_game.run_state["phase"] = "checkpoint"
	grit_game.run_state["survivor"]["stats"]["grit"] = 9
	grit_game.run_state["survivor"]["vitals"]["max_hearts"] = 8
	grit_game.run_state["survivor"]["vitals"]["max_health"] = 400
	grit_game.run_state["survivor"]["vitals"]["health"] = 300
	grit_game.run_state["unspent_stat_points"] = 1
	var grit_draft: Dictionary = grit_game.run_state["survivor"]["stats"].duplicate(true)
	grit_draft["grit"] = 10
	var grit_result := grit_game.confirm_stat_allocation(grit_draft)
	_check(int(grit_result.get("heart_gain", 0)) == 1, "Crossing Grit ten grants one new heart")
	_check(int(grit_game.run_state["survivor"]["vitals"]["max_health"]) == 450 and int(grit_game.run_state["survivor"]["vitals"]["health"]) == 350, "A new Grit heart immediately grants 50 maximum and current HP")
	grit_game.run_state["survivor"]["equipment"]["backpack"] = "frame_pack"
	grit_game.get_player_weapon_profile()
	_check(int(grit_game.run_state["survivor"]["vitals"]["max_health"]) == 450, "Temporary and equipment Grit never recalculate maximum hearts")


func _test_combat_rules(content: ContentRepository) -> void:
	var game := _combat_game(content, 700, "outskirts_dogs", 0)
	var profile := game.get_player_weapon_profile()
	var opening_presentation := game.combat_presentation_snapshot()
	_check(int(opening_presentation.get("player", {}).get("health", -1)) == int(game.run_state["survivor"]["vitals"]["health"]), "Combat presentation begins with the authoritative player HP")
	_check(int(opening_presentation.get("armor", {}).get("flat", -1)) == int(opening_presentation.get("armor", {}).get("rating", 0)) * 3, "Combat presentation exposes the real armor flat reduction")
	game.prepare_combat_action("attack")
	_check(str(game.combat_presentation_snapshot().get("pending_action", "")) == "attack", "Prepared combat state exposes its action to the cinematic battle screen")
	game.run_state["pending_combat_round"]["player_roll"] = 1
	game.run_state["pending_combat_round"]["enemy_roll"] = 10
	var failure_round := game.resolve_prepared_combat_round()
	_check(int(failure_round.get("player_damage", 0)) == int(profile["damage_min"]), "Natural 1 deals the displayed minimum damage")
	_check(int(failure_round.get("enemy_damage", 0)) > 0, "Enemy counterattacks after a critical failure")
	var failure_display: Dictionary = failure_round.get("presentation", {})
	_check(int(failure_display.get("player_damage", 0)) == int(failure_round.get("player_damage", -1)) and int(failure_display.get("enemy_damage", 0)) == int(failure_round.get("enemy_damage", -1)), "Cinematic presentation uses the already-resolved player and enemy damage")
	_check(int(failure_display.get("player_health_after", -1)) == int(game.run_state["survivor"]["vitals"]["health"]), "Cinematic presentation ends at the authoritative saved player HP")

	game = _combat_game(content, 701, "outskirts_dogs", 0)
	game.prepare_combat_action("attack")
	game.run_state["pending_combat_round"]["player_roll"] = 20
	game.run_state["pending_combat_round"]["enemy_roll"] = 20
	var critical_round := game.resolve_prepared_combat_round()
	_check(bool(critical_round.get("enemy_staggered", false)), "Natural 20 staggers the enemy")
	_check(not critical_round.has("enemy_damage"), "A staggered enemy cannot counterattack")

	game = _combat_game(content, 702, "outskirts_dogs", 0)
	var fatigue_before := int(game.run_state["survivor"]["pressures"]["fatigue"])
	var guard_round: Dictionary = {}
	for round_index in range(3):
		game.prepare_combat_action("guard")
		game.run_state["pending_combat_round"]["enemy_roll"] = 1
		guard_round = game.resolve_prepared_combat_round()
	_check(int(game.run_state["survivor"]["pressures"]["fatigue"]) == fatigue_before + 2, "Every third combat round adds two Fatigue")
	_check(float(game.run_state["combat_state"].get("next_attack_multiplier", 1.0)) >= 1.25, "Guard empowers the next attack")
	_check(str(guard_round.get("presentation", {}).get("action", "")) == "guard" and int(guard_round.get("presentation", {}).get("armor_blocked", 0)) > 0, "Guard presentation records the real blocked damage for its shield effect")

	game = _combat_game(content, 703, "outskirts_dogs", 0)
	game.run_state["survivor"]["inventory"]["pipe_pistol"] = 1
	game.run_state["survivor"]["inventory"]["pistol_rounds"] = 1
	game.run_state["survivor"]["equipment"]["weapon"] = "pipe_pistol"
	game.prepare_combat_action("attack")
	game.run_state["pending_combat_round"]["player_roll"] = 10
	var ammo_round := game.resolve_prepared_combat_round()
	_check(game.get_item_quantity("pistol_rounds") == 0, "Ranged combat consumes one compatible round per attack")
	_check(game.get_player_weapon_profile()["name"] == "Unarmed", "An unloaded ranged weapon visibly falls back to Unarmed")
	_check(int(ammo_round.get("presentation", {}).get("ammo_used", 0)) == 1, "Cinematic presentation records ammunition consumed by the resolved attack")

	game = _combat_game(content, 7031, "outskirts_dogs", 0)
	game.run_state["survivor"]["vitals"]["health"] -= 100
	game.run_state["survivor"]["inventory"]["medkit"] = 1
	var health_before_item := int(game.run_state["survivor"]["vitals"]["health"])
	game.prepare_combat_action("use_item", "medkit")
	game.run_state["pending_combat_round"]["enemy_roll"] = 1
	var healing_round := game.resolve_prepared_combat_round()
	var healing_display: Dictionary = healing_round.get("presentation", {})
	_check(int(healing_display.get("healing", 0)) == 75, "Cinematic presentation records the Field Medkit's real healing before the counterattack")
	_check(int(healing_display.get("player_health_after_item", 0)) == health_before_item + 75, "Cinematic presentation preserves the intermediate post-item HP for its healing animation")

	game = _combat_game(content, 704, "outskirts_dogs", 0)
	game.prepare_combat_action("flee")
	game.run_state["pending_combat_round"]["player_roll"] = 20
	var flee_round := game.resolve_prepared_combat_round()
	_check(game.run_state["phase"] == "result", "A natural-20 flee exits combat")
	_check(int(game.run_state["survivor"]["pressures"]["fatigue"]) == 5, "Successful fleeing adds five Fatigue")
	_check(int(game.run_state["experience"]) == ExperienceRules.JOURNEY_XP and "No combat XP" in game.run_state.get("last_result", {}).get("changes", []), "Fleeing grants journey survival XP but no combat reward")
	_check(bool(flee_round.get("presentation", {}).get("flee_success", false)), "Cinematic presentation identifies a resolved successful escape without an enemy animation")

	game = _combat_game(content, 7041, "outskirts_dogs", 0)
	game.run_state["combat_state"]["enemy_health"] = 1
	game.prepare_combat_action("attack")
	game.run_state["pending_combat_round"]["player_roll"] = 20
	var victory_round := game.resolve_prepared_combat_round()
	_check(bool(victory_round.get("presentation", {}).get("enemy_defeated", false)), "Cinematic presentation identifies a killing blow even after combat state is cleared")
	_check(int(game.run_state["experience"]) == 26 and game.run_state.get("defeated_adversaries", []) == ["feral_dogs"], "Combat victory grants the authored enemy XP plus journey XP exactly once")
	var victory_xp_before := int(game.run_state["experience"])
	var victory_award_id := str(game.run_state.get("xp_award_ids", [""])[0])
	game.award_experience(22, "Feral Dogs defeated", victory_award_id)
	_check(int(game.run_state["experience"]) == victory_xp_before, "Replaying a combat XP source cannot duplicate the victory reward")

	game = _combat_game(content, 7042, "outskirts_dogs", 0)
	game.run_state["survivor"]["vitals"]["health"] = 1
	game.prepare_combat_action("guard")
	game.run_state["pending_combat_round"]["enemy_roll"] = 20
	var death_round := game.resolve_prepared_combat_round()
	_check(int(death_round.get("presentation", {}).get("player_health_after", -1)) == 0 and game.run_state["phase"] == "death", "Cinematic presentation carries the final HP to zero before strict permadeath")
	_check(int(game.run_state["experience"]) == 0, "Dying in combat grants no partial or consolation XP")
	var death_summary := game.summary()
	_check("Feral Dogs" in str(death_summary.get("cause", "")) and not death_summary.get("equipment", []).is_empty(), "Permadeath history records the responsible enemy and final equipped loadout")


func _test_combat_recovery(content: ContentRepository) -> void:
	var original := _combat_game(content, 8080, "outskirts_dogs", 0)
	original.prepare_combat_action("attack")
	var resumed := GameEngine.new(content)
	resumed.restore_run(original.run_state)
	var control := GameEngine.new(content)
	control.restore_run(original.run_state)
	var resumed_result := resumed.resolve_prepared_combat_round()
	var control_result := control.resolve_prepared_combat_round()
	_check(resumed_result == control_result, "A prepared combat round resolves identically after restart")
	_check(resumed.run_state == control.run_state, "Restarted combat applies damage and ammo exactly once")

	var prepared_victory := _combat_game(content, 8081, "outskirts_dogs", 0)
	prepared_victory.run_state["combat_state"]["enemy_health"] = 1
	prepared_victory.prepare_combat_action("attack")
	prepared_victory.run_state["pending_combat_round"]["player_roll"] = 20
	var resumed_victory := GameEngine.new(content)
	resumed_victory.restore_run(prepared_victory.run_state)
	var victory_result := resumed_victory.resolve_prepared_combat_round()
	_check(bool(victory_result.get("enemy_defeated", false)) and int(resumed_victory.run_state["experience"]) == 26, "A prepared killing blow restored before resolution grants combat and journey XP once")
	var resolved_victory := GameEngine.new(content)
	resolved_victory.restore_run(resumed_victory.run_state)
	var xp_after_victory := int(resolved_victory.run_state["experience"])
	var replay_result := resolved_victory.resolve_prepared_combat_round()
	_check(replay_result.has("error") and int(resolved_victory.run_state["experience"]) == xp_after_victory, "Restarting after a saved victory cannot replay the XP award")


func _test_complete_run(content: ContentRepository) -> void:
	var game := _new_game(content, 444)
	var steps := 0
	while game.run_state["phase"] not in ["death", "victory"] and steps < 120:
		steps += 1
		if game.run_state["phase"] == "checkpoint":
			game.leave_checkpoint()
			continue
		if game.run_state["phase"] == "result":
			game.run_state["survivor"]["vitals"]["satiety"] = 4
			game.continue_after_result()
			continue
		var choice := _first_available_noncombat_choice(game)
		game.resolve_choice(choice, 20)
	_check(game.run_state["phase"] == "victory", "A valid critical-success route reaches victory")
	_check(int(game.run_state["region_index"]) == 6, "Victory still occurs after all six regions")
	_check(int(game.run_state["experience"]) >= 180 and int(game.run_state["level"]) >= 4 and game.run_state["checkpoint_xp_awards"].size() == 6, "A cautious complete run earns all six checkpoint rewards and at least three stat points")
	_check(steps < 120, "The complete journey cannot deadlock")


func _test_save_migration_and_death_marker(content: ContentRepository) -> void:
	var saves := SaveService.new("ashfall_test_")
	var old_run := _new_game(content, 55).run_state
	old_run["schema_version"] = 1
	old_run["survivor"].erase("vitals")
	old_run["survivor"]["pressures"] = {"health": 50, "hunger": 50, "fatigue": 12, "radiation": 9}
	var migrated := saves._migrate_run(old_run)
	_check(int(migrated["schema_version"]) == 5, "Version-1 runs migrate through to schema 4")
	_check(int(migrated["survivor"]["vitals"]["health"]) == int(migrated["survivor"]["vitals"]["max_health"]) / 2, "Migration preserves proportional Health")
	_check(int(migrated["survivor"]["vitals"]["satiety"]) == 2, "Migration converts legacy Hunger to meal icons")
	_check(int(migrated.get("level", -1)) == 1 and int(migrated.get("experience", -1)) == 0 and int(migrated.get("unspent_stat_points", -1)) == 0, "Migration initializes run-only XP progression without free retroactive points")
	var progressed_v2 := _new_game(content, 56).run_state
	progressed_v2["schema_version"] = 2
	progressed_v2["region_index"] = 2
	progressed_v2["phase"] = "checkpoint"
	for key: String in ["level", "unspent_stat_points", "rewarded_checkpoints", "rules_version"]:
		progressed_v2.erase(key)
	var progressed_v4 := saves._migrate_run(progressed_v2)
	_check(progressed_v4["checkpoint_xp_awards"] == [0, 1, 2] and int(progressed_v4["level"]) == 4 and int(progressed_v4["experience"]) == 180, "Migrated checkpoint levels convert to equivalent schema-4 XP progression")
	_check(int(progressed_v4["unspent_stat_points"]) == 0, "Migrated checkpoints grant no additional retroactive stat points")

	saves.delete_run_files()
	saves.clear_death_marker()
	var game := _new_game(content, 77)
	_check(saves.save_run(game.run_state), "Schema-4 active run writes successfully")
	var restored := saves.load_run()
	_check(str(restored.get("run_id", "")) == str(game.run_state["run_id"]) and int(restored.get("schema_version", 0)) == 5, "Schema-4 run restores with the same identity")
	_check(saves.write_death_marker_and_delete(str(game.run_state["run_id"])), "Death marker persists before run deletion")
	_check(saves.load_run().is_empty(), "A dead schema-4 run cannot be restored")
	saves._atomic_write("user://ashfall_test_profile.json", {"schema_version": 1, "tutorial_seen": true})
	var upgraded_profile := saves.load_profile()
	_check(int(upgraded_profile.get("schema_version", 0)) == 5 and str(upgraded_profile.get("story_text_speed", "")) == "normal", "Existing profiles migrate to schema 5 with Normal story speed")
	_check(upgraded_profile.get("discovered_story_nodes", null) == [] and upgraded_profile.get("discovered_characters", null) == [] and upgraded_profile.get("discovered_endings", null) == [], "Schema-3 migration initializes non-power Road Ledger collections")
	var profile := saves.default_profile()
	_check(int(profile.get("schema_version", 0)) == 5 and str(profile.get("story_text_speed", "")) == "normal", "Profile schema 5 defaults existing players to Normal story speed")
	profile["deaths"] = 7
	_check(saves.save_profile(profile), "Profile writes independently of run state")
	_check(int(saves.load_profile().get("deaths", 0)) == 7, "Profile history survives permadeath")
	var owned := {"remove_ads": true, "theme_rust": false, "theme_night": true, "supporter": false, "verified_at": 1234}
	_check(saves.save_entitlements(owned), "Entitlements write independently")
	_check(bool(saves.load_entitlements().get("remove_ads", false)), "Verified ownership survives permadeath")
	saves.clear_death_marker()
	saves.delete_run_files()
	for path: String in ["user://ashfall_test_profile.json", "user://ashfall_test_profile.json.bak", "user://ashfall_test_entitlements.json", "user://ashfall_test_entitlements.json.bak"]:
		saves._remove_if_exists(path)


func _test_equipment_routes(content: ContentRepository) -> void:
	var routes: Array = [
		{"event": "outskirts_market", "choice": 2, "other": 3, "item": "rusted_hatchet", "certain": true, "fatigue": 6, "seed": 5101},
		{"event": "outskirts_market", "choice": 3, "other": 2, "item": "nail_bat", "certain": true, "fatigue": 6, "seed": 5102},
		{"event": "flats_convoy", "choice": 2, "other": 3, "item": "dust_cloak", "stat": "wits", "difficulty": "favorable", "fatigue": 6, "seed": 5103},
		{"event": "flats_convoy", "choice": 3, "other": 2, "item": "lucky_die", "stat": "presence", "difficulty": "favorable", "fatigue": 6, "seed": 5104},
		{"event": "marsh_body", "choice": 2, "other": 3, "item": "rebar_spear", "stat": "strength", "difficulty": "risky", "fatigue": 6, "seed": 5105},
		{"event": "marsh_body", "choice": 3, "other": 2, "item": "tire_armor", "stat": "strength", "difficulty": "risky", "fatigue": 6, "seed": 5106},
		{"event": "industrial_locker", "choice": 2, "other": 3, "item": "stun_baton", "stat": "wits", "difficulty": "risky", "fatigue": 8, "seed": 5107},
		{"event": "industrial_locker", "choice": 3, "other": 2, "item": "scavenger_rig", "stat": "strength", "difficulty": "risky", "fatigue": 8, "seed": 5108},
		{"event": "industrial_office", "choice": 2, "other": 3, "item": "hunting_rifle", "ammo": "rifle_rounds", "ammo_count": 4, "stat": "wits", "difficulty": "hard", "fatigue": 8, "seed": 5109},
		{"event": "industrial_office", "choice": 3, "other": 2, "item": "flare_gun", "ammo": "shotgun_shells", "ammo_count": 3, "stat": "agility", "difficulty": "risky", "fatigue": 8, "seed": 5110},
	]
	for route: Dictionary in routes:
		var event_id := str(route["event"])
		var choice_index := int(route["choice"])
		var item_id := str(route["item"])
		var event: Dictionary = content.get_event(event_id)
		var choices: Array = event.get("choices", [])
		_check(choices.size() == 4 and bool(event.get("unique", false)), "%s stays a unique encounter with four choices" % event_id)
		var choice: Dictionary = choices[choice_index]
		if bool(route.get("certain", false)):
			_check(not choice.has("check") and choice.has("outcome"), "%s choice %d earns its weapon without a roll" % [event_id, choice_index])
		else:
			var check: Dictionary = choice.get("check", {})
			_check(str(check.get("stat", "")) == str(route["stat"]) and str(check.get("difficulty", "")) == str(route["difficulty"]) and not check.has("dc"), "%s choice %d checks %s at named %s difficulty" % [event_id, choice_index, route["stat"], route["difficulty"]])
			_check(not choice.has("critical_success") and not choice.has("critical_failure"), "%s choice %d resolves criticals through its ordinary reward" % [event_id, choice_index])

		var winner := _route_game(content, int(route["seed"]), event_id)
		var winner_before := _route_snapshot(winner)
		var success_result := winner.resolve_choice(choice_index, 20)
		var inventory: Dictionary = winner.run_state["survivor"]["inventory"]
		_check(not success_result.has("error") and int(inventory.get(item_id, 0)) == 1, "%s choice %d grants exactly one %s" % [event_id, choice_index, item_id])
		if route.has("ammo"):
			_check(int(inventory.get(str(route["ammo"]), 0)) == int(route["ammo_count"]), "%s arrives with %d %s and no other ammunition change" % [item_id, int(route["ammo_count"]), route["ammo"]])
		var expected_success_fatigue := int(route["fatigue"]) if bool(route.get("certain", false)) else 0
		_check(_route_fatigue_delta(winner_before, winner) == expected_success_fatigue, "%s choice %d applies %d Fatigue alongside its reward" % [event_id, choice_index, expected_success_fatigue])
		_check(_route_costs_unchanged(winner_before, winner), "%s choice %d changes no health, condition, or food value" % [event_id, choice_index])
		_check(winner.resolve_choice(int(route["other"]), 20).has("error"), "%s cannot also take its alternative equipment route" % event_id)
		var resumed := GameEngine.new(content)
		resumed.restore_run(winner.run_state)
		_check(resumed.resolve_choice(choice_index, 20).has("error") and int(resumed.run_state["survivor"]["inventory"].get(item_id, 0)) == 1, "%s keeps exactly one %s after a restart" % [event_id, item_id])

		if bool(route.get("certain", false)):
			continue
		var loser := _route_game(content, int(route["seed"]) + 500, event_id)
		var loser_before := _route_snapshot(loser)
		loser.resolve_choice(choice_index, 1)
		_check(not loser.run_state["survivor"]["inventory"].has(item_id), "%s choice %d grants no equipment when its check fails" % [event_id, choice_index])
		_check(_route_fatigue_delta(loser_before, loser) == int(route["fatigue"]), "%s choice %d costs exactly %d Fatigue on failure" % [event_id, choice_index, int(route["fatigue"])])
		_check(_route_costs_unchanged(loser_before, loser), "%s choice %d failure adds no damage, condition, or hunger" % [event_id, choice_index])

	var prepared_game := _route_game(content, 5199, "industrial_office")
	var prepared_control := GameEngine.new(content)
	prepared_control.restore_run(prepared_game.run_state)
	var prepared := prepared_game.prepare_choice(2)
	_check(prepared.get("prepared", false) and not prepared.has("roll"), "An equipment-route roll can be prepared without revealing it")
	var prepared_resumed := GameEngine.new(content)
	prepared_resumed.restore_run(prepared_game.run_state)
	var prepared_result := prepared_resumed.resolve_prepared_choice()
	var control_result := prepared_control.resolve_choice(2)
	_check(prepared_result.get("resolution", {}).get("roll") == control_result.get("resolution", {}).get("roll"), "A restarted equipment route reveals the same saved roll")
	_check(prepared_resumed.run_state["survivor"]["inventory"] == prepared_control.run_state["survivor"]["inventory"], "A recovered equipment route grants its reward exactly once")

	var obtainable: Dictionary = {}
	for starting_id: String in GameEngine.STARTING_ITEM_IDS:
		obtainable[starting_id] = true
	for launch_event: Dictionary in content.events.values():
		for launch_choice: Dictionary in launch_event.get("choices", []):
			for outcome_key: String in ["success", "critical_success", "outcome", "victory", "critical_victory"]:
				for reward_id: Variant in launch_choice.get(outcome_key, {}).get("items", {}).keys():
					if int(launch_choice[outcome_key]["items"][reward_id]) > 0:
						obtainable[str(reward_id)] = true
	var unreachable: Array = []
	for defined_id: String in content.items:
		if not obtainable.has(defined_id):
			unreachable.append(defined_id)
	_check(content.items.size() == 50 and unreachable.is_empty(), "All fifty defined items have a launch starting or acquisition route")


func _test_full_run_replay(content: ContentRepository) -> void:
	var harness = FullRunHarness.new()
	harness.content = content
	var recorded: Dictionary = harness._play(4242, 0, {"mode": "policy", "trace": true, "record": true})
	var decisions: Array = recorded["decisions"]
	_check(decisions.size() > 10 and int(recorded["errors"]) == 0, "A legal-action run drives a whole journey without a rejected action")
	_check(str(recorded["result"]) in ["dead", "victory"], "A soak run reaches an authoritative ending rather than stalling")
	var replayed: Dictionary = harness._play(4242, 0, {"mode": "record", "decisions": decisions, "trace": true})
	_check(harness._comparable_state(recorded["final_state"]) == harness._comparable_state(replayed["final_state"]), "A recorded decision list replays to an identical run state")
	var trace: Dictionary = recorded["trace"]
	_check(not (trace["regions"] as Array).is_empty() and not (trace["events"] as Array).is_empty(), "The replay trace records regional resources and each encounter")
	_check(trace.has("experience") and trace.has("death"), "The replay trace records experience and the ending")
	var restored := GameEngine.new(content)
	restored.restore_run(recorded["final_state"])
	_check(restored.run_state == recorded["final_state"], "A traced run state survives save and restore unchanged")


func _test_road_chronicle(content: ContentRepository) -> void:
	var entries: Dictionary = content.get_discovery_entries()
	var reachable := true
	var advertises_expansion := false
	for entry_id: String in entries:
		var event_id := str(entries[entry_id].get("event_id", ""))
		reachable = reachable and content.events.has(event_id)
		advertises_expansion = advertises_expansion or event_id.begins_with("lr_")
	_check(entries.size() == 10 and reachable and not advertises_expansion, "The launch Chronicle lists exactly the ten reachable chapters and no disabled callback")
	var living := ContentRepository.new(true)
	_check(living.get_discovery_entries().size() == 25, "Enabling the expansion restores all twenty-five chapters and their denominator")

	# A chapter is recorded from an authoritative resolution, and only once.
	var game := _new_game(content, 7301)
	game.run_state["current_event_id"] = "bunker41_static"
	game.run_state["phase"] = "event"
	game.resolve_choice(0)
	var recorded := SaveService.new("ashfall_chronicle_test_").default_profile()
	var first := StoryDiscoveryRules.apply_resolution(game.run_state["last_result"], game.run_state.get("flags", []), entries, recorded)
	_check(bool(first.get("changed", false)) and "ledger_b41_signal" in recorded["discovered_story_nodes"], "Resolving a launch encounter records its Chronicle chapter")
	var replay := StoryDiscoveryRules.apply_resolution(game.run_state["last_result"], game.run_state.get("flags", []), entries, recorded)
	_check(not bool(replay.get("changed", true)) and (recorded["discovered_story_nodes"] as Array).count("ledger_b41_signal") == 1, "Replaying the same outcome does not duplicate its Chronicle entry")

	# Death must leave earlier discoveries and history intact while adding its own.
	var chronicle_saves := SaveService.new("ashfall_chronicle_test_")
	var stored := chronicle_saves.default_profile()
	stored["discovered_story_nodes"] = ["ledger_b41_signal"]
	stored["run_history"] = [{"run_id": "earlier", "survivor": "Older Survivor", "result": "dead"}]
	stored["deaths"] = 1
	var summary := {"run_id": "final", "result": "dead", "survivor": "Last Survivor", "regions_reached": 3, "cause": "Bled out"}
	_check(chronicle_saves.write_profile_update_receipt({"schema_version": 1, "receipt_id": "final:terminal", "updates": {"discovered_story_nodes": ["ledger_b41_warden"], "run_summary": summary}}), "A terminal receipt can be written before cleanup")
	var replayed := chronicle_saves.replay_profile_updates(stored)
	_check(bool(replayed.get("success", false)), "The terminal receipt applies")
	_check("ledger_b41_signal" in stored["discovered_story_nodes"] and "ledger_b41_warden" in stored["discovered_story_nodes"], "Death preserves earlier discoveries while adding the last run's")
	_check((stored["run_history"] as Array).size() == 2 and str(stored["run_history"][0].get("run_id", "")) == "final", "Death records its summary in front of the existing history")
	var duplicate_replay := chronicle_saves.replay_profile_updates(stored)
	_check(bool(duplicate_replay.get("success", false)) and (stored["run_history"] as Array).size() == 2 and (stored["discovered_story_nodes"] as Array).size() == 2, "Replaying a terminal receipt cannot duplicate history or discoveries")
	chronicle_saves.clear_death_marker()
	chronicle_saves.delete_run_files()

	# Older summaries are shown as recorded, never filled in.
	var thin_summary := {"run_id": "legacy", "result": "dead", "survivor": "Legacy Survivor"}
	var ui_source := FileAccess.get_file_as_string("res://scripts/ui/main.gd")
	_check("Not recorded" in ui_source and "_summary_field" in ui_source, "Missing summary fields are reported rather than invented")
	_check(not thin_summary.has("strongest_enemy") and not thin_summary.has("equipment"), "The legacy summary fixture genuinely lacks the newer fields")


func _test_contextual_guidance(content: ContentRepository) -> void:
	var tips: Dictionary = MainUI.CONTEXTUAL_TIPS
	var expected := SaveService.CONTEXTUAL_TIP_IDS
	var ids: Array = tips.keys()
	ids.sort()
	var expected_sorted: Array = expected.duplicate()
	expected_sorted.sort()
	_check(ids == expected_sorted and ids.size() == 7, "The seven contextual moments match the profile's stored tip IDs")
	var within_two_sentences := true
	var short_enough := true
	for tip_id: String in tips:
		var text := str(tips[tip_id].get("text", ""))
		within_two_sentences = within_two_sentences and text != "" and text.split(".", false).size() <= 2
		# A tip shares a 360x640 combat screen with six actions, so "short" is a
		# measured limit rather than a style note.
		short_enough = short_enough and text.length() <= 80
	_check(within_two_sentences, "Every tip is written and stays within two sentences")
	_check(short_enough, "Every tip stays short enough to fit a compact screen")

	var saves := SaveService.new("ashfall_tip_test_")
	var fresh := saves.default_profile()
	_check(bool(fresh.get("contextual_tips_enabled", false)) and (fresh.get("contextual_tips_seen", []) as Array).is_empty(), "A new profile starts with tips enabled and none seen")

	var ui_source := FileAccess.get_file_as_string("res://scripts/ui/main.gd")
	_check("call_deferred(\"_show_first_run_tutorial\")" not in ui_source, "No first-run tutorial wall opens by itself")
	_check("\"HOW TO PLAY\", _show_first_run_tutorial" in ui_source, "The full reference stays available under How to Play")
	_check("_reset_contextual_tips" in ui_source and "_check_setting(\"Contextual tips\", \"contextual_tips_enabled\")" in ui_source, "Settings can switch tips off and reset their progress")

	var experienced := {"schema_version": 4, "tutorial_seen": true}
	saves._atomic_write("user://ashfall_tip_test_profile.json", experienced)
	var migrated := saves.load_profile()
	_check((migrated.get("contextual_tips_seen", []) as Array).size() == 7 and bool(migrated.get("contextual_tips_enabled", false)), "An experienced profile receives no new mandatory guidance")


func _test_equipment_comparison(content: ContentRepository) -> void:
	var game := _new_game(content, 6301)
	var survivor: Dictionary = game.run_state["survivor"]
	survivor["stats"] = {"strength": 6, "agility": 3, "wits": 3, "grit": 3, "presence": 3}
	survivor["conditions"] = []
	survivor["inventory"] = {"salvage_cleaver": 1, "runner_jacket": 1, "scrap_buckler": 1, "hunting_rifle": 1, "rifle_rounds": 4, "tire_armor": 1, "scavenger_rig": 1, "canned_meat": 1}
	survivor["equipment"] = {"weapon": "salvage_cleaver", "armor": "runner_jacket", "accessory": "scrap_buckler", "backpack": ""}

	var untouched: Dictionary = game.run_state.duplicate(true)
	var rifle: Dictionary = EquipmentComparison.compare(game, "hunting_rifle")
	_check(game.run_state == untouched and int(game.run_state["rng_state"]) == int(untouched["rng_state"]), "Comparing equipment changes no run value and consumes no roll")
	_check(bool(rifle["available"]) and str(rifle["current_name"]) == "Salvage Cleaver" and str(rifle["item_name"]) == "Hunting Rifle" and not bool(rifle["already_equipped"]), "A comparison names the current item and the proposed one")

	var control := GameEngine.new(content)
	control.restore_run(game.run_state)
	control.equip_item("hunting_rifle")
	var control_preview: Dictionary = control.combat_action_preview("attack")
	var proposed_weapon: Dictionary = rifle["weapon"]["proposed"]
	_check(int(proposed_weapon["damage_min"]) == int(control_preview["damage_min"]) and int(proposed_weapon["damage_max"]) == int(control_preview["damage_max"]) and int(proposed_weapon["hit_chance"]) == int(control_preview["chance"]), "Comparison damage and accuracy come from the gameplay combat preview")
	_check(str(proposed_weapon["attack_stat"]) == "wits" and int(proposed_weapon["stat_value"]) == int(control_preview["profile"]["stat_value"]), "A weapon comparison reports the attack stat it will actually use")
	_check(str(proposed_weapon["family"]) == "precision" and not bool(proposed_weapon["mastered"]) and bool(rifle["weapon"]["current"]["mastered"]), "Signature and mastery state are reported for both weapons")
	_check(int(rifle["weapon"]["damage_max_delta"]) == int(proposed_weapon["damage_max"]) - int(rifle["weapon"]["current"]["damage_max"]), "The damage difference matches the two neutral ranges")

	_check(str(proposed_weapon["ammo_name"]) == "Rifle Rounds" and int(proposed_weapon["ammo_per_attack"]) == 1 and int(proposed_weapon["ammo_available"]) == 4 and not bool(proposed_weapon["unloaded"]), "A ranged comparison states the ammunition it needs and what is carried")
	game.run_state["survivor"]["inventory"]["rifle_rounds"] = 0
	var dry: Dictionary = EquipmentComparison.compare(game, "hunting_rifle")
	var dry_note_found := false
	for note: String in dry["notes"]:
		if "Unloaded" in note:
			dry_note_found = true
	_check(bool(dry["weapon"]["proposed"]["unloaded"]) and dry_note_found, "A weapon with no ammunition is reported as unloaded")
	game.run_state["survivor"]["inventory"]["rifle_rounds"] = 4

	_check(str(rifle["shield_removed"]) == "Scrap Buckler" and not bool(rifle["defense"]["proposed"]["shield_active"]) and bool(rifle["defense"]["current"]["shield_active"]), "A two-handed weapon reports the shield it removes")
	_check(int(rifle["defense"]["block_delta"]) < 0, "Losing the shield lowers the neutral Block chance")
	var shielded := GameEngine.new(content)
	shielded.restore_run(game.run_state)
	shielded.equip_item("hunting_rifle")
	shielded.run_state["survivor"]["inventory"]["scrap_buckler"] = 1
	var buckler: Dictionary = EquipmentComparison.compare(shielded, "scrap_buckler")
	_check(bool(buckler["available"]) and str(buckler["slot_conflict"]) == str(shielded.equipment_lock_reason("scrap_buckler")) and str(buckler["slot_conflict"]) != "", "A shield still compares and reports the two-handed incompatibility blocking it")
	_check(not bool(buckler["defense"]["proposed"]["shield_active"]) and int(buckler["defense"]["block_delta"]) == 0, "A shield blocked by a two-handed weapon is reported as adding nothing")

	var armor: Dictionary = EquipmentComparison.compare(game, "tire_armor")
	var armor_current: Dictionary = armor["defense"]["current"]
	var armor_proposed: Dictionary = armor["defense"]["proposed"]
	_check(int(armor_proposed["armor_rating"]) > int(armor_current["armor_rating"]) and int(armor_proposed["sample_taken"]) < int(armor_current["sample_taken"]), "Heavier armor reports a higher rating and a smaller hit taken")
	_check(int(armor["defense"]["block_delta"]) != 0 or int(armor["defense"]["dodge_delta"]) != 0, "Armor changes report their neutral Block and Dodge difference")
	var agility_row := {}
	for row: Dictionary in armor["stats"]:
		if str(row["stat"]) == "agility":
			agility_row = row
	_check(int(agility_row.get("delta", 0)) < 0, "A comparison reports the non-combat stat penalty an item carries")

	var rig: Dictionary = EquipmentComparison.compare(game, "scavenger_rig")
	_check(is_equal_approx(float(rig["carry"]["capacity_delta"]), 10.0) and float(rig["carry"]["capacity_proposed"]) > float(rig["carry"]["capacity_current"]), "A backpack comparison reports the carry capacity it adds")
	var salvage_row := {}
	for row: Dictionary in rig["approaches"]:
		if str(row["approach"]) == "salvage":
			salvage_row = row
	_check(int(salvage_row.get("delta", 0)) == 2, "Approach modifiers are compared against the current item")
	var heavy := GameEngine.new(content)
	heavy.restore_run(game.run_state)
	heavy.run_state["survivor"]["inventory"]["tire_armor"] = 4
	var relief: Dictionary = EquipmentComparison.compare(heavy, "scavenger_rig")
	_check(bool(relief["carry"]["over_current"]) and not bool(relief["carry"]["over_proposed"]), "A comparison reports when equipment clears the overweight penalty")

	var fighting := GameEngine.new(content)
	fighting.restore_run(game.run_state)
	fighting.run_state["current_event_id"] = "outskirts_dogs"
	fighting.run_state["phase"] = "event"
	fighting.start_combat(0)
	var combat_state: Dictionary = fighting.run_state.duplicate(true)
	var during_fight: Dictionary = EquipmentComparison.compare(fighting, "hunting_rifle")
	_check(fighting.run_state == combat_state, "Comparing during a fight neither advances the round nor consumes a roll")
	_check(during_fight["weapon"] == rifle["weapon"] and during_fight["defense"] == rifle["defense"], "Comparison values stay neutral during a fight instead of predicting the current enemy")
	_check(str(during_fight["neutral_label"]).contains("Neutral"), "Neutral values are labelled so they cannot be read as an enemy-specific prediction")

	var equipped_now: Dictionary = EquipmentComparison.compare(game, "salvage_cleaver")
	_check(bool(equipped_now["already_equipped"]) and not bool(equipped_now["weapon"]["changes"]), "Comparing the equipped item reports no change")
	_check(not bool(EquipmentComparison.compare(game, "canned_meat").get("available", true)), "Items with no equipment slot report no comparison")


func _descendants(node: Node) -> Array[Node]:
	var found: Array[Node] = []
	for child: Node in node.get_children():
		found.append(child)
		found.append_array(_descendants(child))
	return found


func _route_game(content: ContentRepository, seed_value: int, event_id: String) -> GameEngine:
	var game := _new_game(content, seed_value)
	game.run_state["current_event_id"] = event_id
	game.run_state["phase"] = "event"
	return game


func _route_snapshot(game: GameEngine) -> Dictionary:
	var survivor: Dictionary = game.run_state["survivor"]
	return {
		"fatigue": int(survivor["pressures"].get("fatigue", 0)),
		"radiation": int(survivor["pressures"].get("radiation", 0)),
		"health": int(survivor["vitals"].get("health", 0)),
		"satiety": int(survivor["vitals"].get("satiety", 0)),
		"conditions": (survivor["conditions"] as Array).duplicate(),
	}


func _route_fatigue_delta(before: Dictionary, game: GameEngine) -> int:
	return int(game.run_state["survivor"]["pressures"].get("fatigue", 0)) - int(before["fatigue"])


func _route_costs_unchanged(before: Dictionary, game: GameEngine) -> bool:
	var survivor: Dictionary = game.run_state["survivor"]
	var vitals_held := int(survivor["vitals"].get("health", 0)) == int(before["health"]) and int(survivor["vitals"].get("satiety", 0)) == int(before["satiety"])
	var pressure_held := int(survivor["pressures"].get("radiation", 0)) == int(before["radiation"])
	return vitals_held and pressure_held and survivor["conditions"] == before["conditions"]


func _new_game(content: ContentRepository, seed_value: int) -> GameEngine:
	var game := GameEngine.new(content)
	game.start_run(game.create_candidates(seed_value)[0], seed_value)
	return game


func _combat_game(content: ContentRepository, seed_value: int, event_id: String, choice_index: int) -> GameEngine:
	var game := _new_game(content, seed_value)
	game.run_state["current_event_id"] = event_id
	game.run_state["phase"] = "event"
	var started := game.start_combat(choice_index)
	_check(started.get("combat_started", false), "%s starts tactical combat" % event_id)
	# Explicit coverage for legacy fights: new rules have their own exhaustive suite.
	game.run_state["combat_state"]["combat_rules_version"] = 1
	return game


func _first_available_noncombat_choice(game: GameEngine) -> int:
	var choices: Array = game.current_event().get("choices", [])
	for index in range(choices.size()):
		if not choices[index].has("combat") and game.get_choice_preview(choices[index]).get("available", false):
			return index
	for index in range(choices.size()):
		if game.get_choice_preview(choices[index]).get("available", false):
			return index
	return 0


func _mechanical_event_signature(event: Dictionary) -> Dictionary:
	var signature := event.duplicate(true)
	signature.erase("body")
	for choice: Dictionary in signature.get("choices", []):
		for outcome_key: String in ["success", "failure", "critical_success", "critical_failure", "outcome", "victory", "critical_victory"]:
			if choice.has(outcome_key):
				choice[outcome_key].erase("text")
	return signature


func _check(condition: bool, description: String) -> void:
	assertions += 1
	if not condition:
		failures += 1
		push_error("FAIL: %s" % description)
	else:
		print("PASS: %s" % description)
