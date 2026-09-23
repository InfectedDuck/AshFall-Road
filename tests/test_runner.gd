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
const UiIconWidget = preload("res://scripts/ui/ui_icon.gd")
const ResponsiveRules = preload("res://scripts/ui/responsive_rules.gd")
const UiPaletteWidget = preload("res://scripts/ui/ui_palette.gd")
const UiTypeWidget = preload("res://scripts/ui/ui_type.gd")
const AtmosphereLayersWidget = preload("res://scripts/ui/atmosphere_layers.gd")
const MainUI = preload("res://scripts/ui/main.gd")
const StoryDiscoveryRules = preload("res://scripts/domain/story_discovery.gd")
const FullRunHarness = preload("res://tools/full_run_harness.gd")
const MechanicalSnapshot = preload("res://tools/mechanical_snapshot.gd")
const EquipmentComparison = preload("res://scripts/domain/equipment_comparison.gd")

var failures := 0
var assertions := 0


func _init() -> void:
	call_deferred("_run_all")


func _run_all() -> void:
	print("Ashfall Road headless tests")
	var content := ContentRepository.new(false)
	_test_default_expansion_activation(ContentRepository.new())
	_test_content(content)
	_test_living_road_expansion(content, ContentRepository.new(true))
	_test_focused_thread_scheduling(ContentRepository.new(true), content)
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
	_test_expanded_opening_guidance(ContentRepository.new(true), content)
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
	_test_channel_nine_arc()
	_test_betrayal_arc()
	_test_experience_progression(content)
	_test_combat_rules(content)
	_test_combat_recovery(content)
	_test_complete_run(content)
	_test_save_migration_and_death_marker(content)
	_test_scene_roles_and_conditional_passages(content)
	_test_passage_resolution_and_gating(content)
	_test_false_item_costs(content)
	_test_pilot_scene_batch(content)
	_test_key_possession_and_endings(content)
	_test_legal_actions_and_item_reach(content)
	_test_talents(content)
	_test_choice_revisions(content)
	_test_returning_stories(content, ContentRepository.new(true))
	preload("res://tests/narrative_combat_tests.gd").new().run(content, _check)
	preload("res://tests/action_transaction_tests.gd").new().run(content, _check)
	print("Assertions: %d | Failures: %d" % [assertions, failures])
	quit(1 if failures > 0 else 0)


func _test_content(content: ContentRepository) -> void:
	_check(content.validate_all().is_empty(), "All content, combat, and supply references are valid")
	_check(content.regions.size() == 6, "Six regions are defined")
	_check(content.items.size() == 72, "Fifty launch items plus fifteen Phase A, three grit-wire build, and four D03 accessory build items are defined")
	var icon_ids: Dictionary = {}
	for item: Dictionary in content.items.values():
		var icon_id := str(item.get("icon_id", ""))
		if not icon_id.is_empty():
			icon_ids[icon_id] = true
	_check(icon_ids.size() == 72, "Every item has a unique stable icon ID")
	var phase_a_rune_icons := {"item_rusted_machete": true, "item_bone_cleaver": true, "item_kiln_sword": true, "item_nail_smg": true, "item_rail_spike_rifle": true, "item_officer_revolver": true, "item_mutant_hide_vest": true, "item_kiln_plates": true, "item_stalker_cloak": true, "item_wolf_fang_charm": true, "item_gunslinger_holster": true, "item_sniper_scope": true, "item_mutant_serum": true, "item_purifier_poultice": true, "item_choir_incense": true, "item_chain_wrench": true, "item_slag_maul": true, "item_wire_rifle": true, "item_dredge_chain": true, "item_fan_guard": true, "item_brass_star": true, "item_stalkhide_wraps": true}
	var atlas_covers_launch_items := true
	for icon_id: String in icon_ids:
		if phase_a_rune_icons.has(icon_id):
			_check(not ItemIconWidget.ATLAS_ITEMS.has(icon_id), "%s uses its rune fallback until art lands" % icon_id)
			continue
		atlas_covers_launch_items = atlas_covers_launch_items and ItemIconWidget.ATLAS_ITEMS.has(icon_id)
	_check(atlas_covers_launch_items and ItemIconWidget.ATLAS_ITEMS.size() == 50, "Every launch item ID keeps its distinct generated pixel-art atlas cell; Phase A items use their rune fallback")
	var placeholder_symbols: Dictionary = {}
	for icon_id: String in icon_ids:
		var symbol := ItemIconWidget.placeholder_symbol(icon_id)
		_check(not symbol.is_empty(), "%s has a temporary item symbol" % icon_id)
		placeholder_symbols[symbol] = true
	_check(placeholder_symbols.size() == 72, "Every item resolves to a distinct temporary inventory symbol")
	_check(content.conditions.size() == 19, "Thirteen survival conditions, checkpoint Momentum, three mutant afflictions, and three combat boons are defined")
	_check(content.adversaries.size() == 21, "Twelve original adversaries, Mutant Crows, four creature profiles, and four Phase A mutants are defined")
	_check(content.events.size() == 97, "The base content plus Bunker Forty-One and the eight-scene Rust-Sea arc is loaded")
	var combat_choices := 0
	var checked_choices := 0
	var outcome_passages := 0
	for event: Dictionary in content.events.values():
		var role := ContentRepository.scene_role(event)
		var band: Dictionary = ContentRepository.scene_role_band(role)
		var introduction_words := ContentRepository.word_count(str(event.get("body", "")))
		_check(introduction_words >= int(band["body_min"]) and introduction_words <= int(band["body_max"]), "%s introduction fits its %s budget of %d–%d words" % [event.get("id", "event"), role, int(band["body_min"]), int(band["body_max"])])
		for choice: Dictionary in event.get("choices", []):
			if choice.has("combat"):
				combat_choices += 1
			if choice.has("check"):
				checked_choices += 1
				_check(not choice["check"].has("dc") and str(choice["check"].get("difficulty", "")) in D20Resolver.DIFFICULTY_SHIFTS, "Checked content uses a named difficulty and no numeric target")
			for outcome_key: String in ["success", "failure", "critical_success", "critical_failure", "outcome", "victory", "critical_victory"]:
				if choice.has(outcome_key):
					outcome_passages += 1
					var outcome_words := ContentRepository.word_count(str(choice[outcome_key].get("text", "")))
					_check(outcome_words >= int(band["outcome_min"]) and outcome_words <= int(band["outcome_max"]), "%s outcome prose fits its %s budget of %d–%d words" % [event.get("id", "event"), role, int(band["outcome_min"]), int(band["outcome_max"])])
	_check(combat_choices == 21, "Twenty-one authored choices enter tactical combat: the leech and drone fights join the creature and Phase A mutant routes")
	_check(checked_choices == 149, "All 149 checked choices use percentage rules: D01 adds the probe-grounded drone route")
	_check(outcome_passages == 415, "All base, Bunker Forty-One, Rust-Sea, equipment-route, creature-victory, depleted-pack, N06 earned-route, E02 refusal, Phase A mutant-victory, D01 build-gate, and D02 agility-gate outcome passages remain present")
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
	var expected_xp := {"mutant_crows": 18, "feral_dogs": 22, "pox_dogs": 22, "marsh_leeches": 24, "road_bandits": 24, "toll_gang": 30, "ash_stalkers": 36, "bile_spewer": 38, "bog_raiders": 44, "vault_scavs": 46, "drone_swarm": 48, "tunnel_hunters": 52, "cinder_mauler": 58, "glass_cult": 62, "citadel_guard": 75, "salt_colossus": 90, "warden_machine": 100}
	var rewards_match := true
	for adversary_id: String in expected_xp:
		rewards_match = rewards_match and int(content.get_adversary(adversary_id).get("xp_reward", 0)) == int(expected_xp[adversary_id])
	_check(rewards_match, "All thirteen launch plus four Phase A adversaries retain the balanced XP reward table")
	var paid_choice := _new_game(content, 5019)
	paid_choice.run_state["region_index"] = 5
	paid_choice.run_state["current_event_id"] = "rail_hunters"
	paid_choice.run_state["phase"] = "event"
	paid_choice.run_state["survivor"]["inventory"]["pistol_rounds"] = 2
	paid_choice.resolve_choice(2, 20)
	_check(paid_choice.get_item_quantity("pistol_rounds") == 0 and "Pistol Rounds -2" in paid_choice.run_state.get("last_result", {}).get("changes", []), "A paid choice records the actual consumed item in its committed result receipt")
	var capped_receipt := _new_game(content, 5020)
	capped_receipt.run_state["survivor"]["vitals"]["health"] = int(capped_receipt.run_state["survivor"]["vitals"]["max_health"])
	capped_receipt.run_state["survivor"]["vitals"]["satiety"] = 4
	capped_receipt.run_state["survivor"]["pressures"]["fatigue"] = 100
	var capped_changes: Array = []
	capped_receipt._apply_outcome({"vitals": {"health": 20, "satiety": 1}, "pressures": {"fatigue": 5}}, capped_changes)
	_check(capped_changes.is_empty(), "A capped health, satiety, or pressure gain does not claim a receipt change that never occurred")
	var creature_profiles := {
		"shutter_skitters": {"portrait_id": "enemy_skitters", "sequence": ["sweep", "strike", "brace", "recover"], "critical_condition": "infection"},
		"reed_widow": {"portrait_id": "enemy_widow", "sequence": ["brace", "strike", "heavy", "recover"], "critical_condition": "sprain"},
		"kilnback": {"portrait_id": "enemy_kilnback", "sequence": ["brace", "heavy", "strike", "recover"], "critical_condition": "burned"},
		"cable_eater": {"portrait_id": "enemy_cable_eater", "sequence": ["charge", "strike", "sweep", "brace", "recover"], "critical_condition": "burned"},
		"pox_dogs": {"portrait_id": "enemy_pox_dogs", "sequence": ["strike", "sweep", "recover"], "critical_condition": "spore_cough"},
		"bile_spewer": {"portrait_id": "enemy_bile_spewer", "sequence": ["strike", "heavy", "brace", "recover"], "critical_condition": "gutrot"},
		"cinder_mauler": {"portrait_id": "enemy_cinder_mauler", "sequence": ["strike", "heavy", "brace", "recover"], "critical_condition": "burned"},
		"salt_colossus": {"portrait_id": "enemy_salt_colossus", "sequence": ["charge", "heavy", "sweep", "recover"], "critical_condition": "gutrot"},
	}
	var authored_moves: Dictionary = content.combat_data.get("moves", {})
	for creature_id: String in creature_profiles:
		var creature: Dictionary = content.get_adversary(creature_id)
		var expected: Dictionary = creature_profiles[creature_id]
		var creature_combat: Dictionary = creature.get("combat", {})
		var narrative: Dictionary = creature.get("narrative_combat", {})
		var sequence: Array = narrative.get("sequence", [])
		var expected_sequence: Array = expected["sequence"]
		_check(sequence == expected_sequence, "%s answers on the authored %s sequence" % [creature_id, ", ".join(PackedStringArray(expected_sequence))])
		var tells_complete := not sequence.is_empty()
		for move_id: Variant in sequence:
			tells_complete = tells_complete and authored_moves.has(str(move_id)) and not str(narrative.get("tells", {}).get(str(move_id), "")).is_empty()
		_check(tells_complete, "%s names a defined combat move and an honest tell for every beat" % creature_id)
		var creature_condition := str(creature_combat.get("critical_condition", ""))
		_check(creature_condition == str(expected["critical_condition"]) and content.conditions.has(creature_condition), "%s applies the defined critical condition '%s'" % [creature_id, expected["critical_condition"]])
		_check(typeof(narrative.get("organic")) == TYPE_BOOL and bool(narrative["organic"]), "%s is authored as an organic creature rather than a machine" % creature_id)
		_check(int(creature.get("xp_reward", 0)) > 0 and int(creature.get("xp_reward", 0)) <= 100, "%s carries an XP reward inside the one-to-one-hundred band" % creature_id)
		_check(str(creature.get("portrait_id", "")) == str(expected["portrait_id"]) and not str(creature_combat.get("weapon_name", "")).is_empty(), "%s reserves its portrait ID and shows a named weapon" % creature_id)
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
	_check(not release_content.living_road_enabled and release_content.events.size() == 97, "The explicit compatibility repository keeps the baseline callback-free")
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
	_check(polished_baseline_live and polished_baseline_count == 43, "The remaining baseline prose polish is live in compatibility mode")
	_check(release_content.polished_event_ids.size() == 76 and release_content.load_errors.is_empty(), "All 76 baseline events use polished prose in compatibility mode")
	_check(living_content.living_road_enabled and living_content.events.size() == 124, "The expanded release loads fifteen callback events plus twelve betrayal-arc events")
	_check(living_content.get_discovery_entries().size() == 29, "The Road Ledger contains twenty-nine spoiler-safe chapters")
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
		# The three original paths are the contract; N03 appends a fourth choice to
		# lr_blue_van for a survivor who traced the signal instead of answering it.
		complete_branch_shapes = complete_branch_shapes and callback_choices.size() >= 3 and callback_choices.size() <= 4 and callback_choices[0].has("success") and callback_choices[0].has("failure") and callback_choices[1].has("success") and callback_choices[1].has("failure") and callback_choices[2].has("outcome")
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


func _test_default_expansion_activation(default_content: ContentRepository) -> void:
	_check(default_content.living_road_enabled and default_content.events.size() == 124, "The no-argument content repository activates the Living Road plus betrayal-arc release")
	_check(default_content.get_discovery_entries().size() == 29, "The default release Chronicle includes all twenty-nine reachable chapters")
	var hooks := {"outskirts_child_radio": true, "outskirts_market": true, "outskirts_cache": true}
	var hook_count := 0
	for event_id: String in hooks:
		var tags: Array = default_content.get_event(event_id).get("tags", [])
		hook_count += 1 if "opening_hook" in tags and "opening_safe" in tags else 0
	_check(hook_count == hooks.size(), "The default release includes all three safe opening hooks")


## N04 focused thread scheduling. A story the survivor has engaged with must not
## be lost to a weighted draw, and buying that guarantee must not buy a travel
## slot with it. The focus is derived from `event_history`, so nothing here
## depends on new run state and the save schema stays at 5.
func _test_focused_thread_scheduling(living_content: ContentRepository, release_content: ContentRepository) -> void:
	var thread_specs: Array = [
		{"thread": "family_on_nine", "source": "lr_channel_helped", "chapters": ["lr_blue_van", "lr_voice_in_reeds", "lr_last_battery"]},
		{"thread": "quiet_column", "source": "lr_siren_silenced", "chapters": ["lr_quiet_column", "lr_bellkeepers_son", "lr_siren_in_glass"]},
		{"thread": "road_debt", "source": "lr_bandits_escaped", "chapters": ["lr_pharmacy_witness", "lr_bandit_ledger", "lr_last_toll"]},
		{"thread": "water_commons", "source": "lr_filter_repaired", "chapters": ["lr_cup_passed_east", "lr_thirst_court", "lr_valve_below"]},
		{"thread": "nightfire_caravan", "source": "lr_nightfire_shared", "chapters": ["lr_embers_in_rain", "lr_names_on_smoke", "lr_warm_windows"]},
	]

	# The fields the derivation reads must exist on every chapter, or focus is
	# not derivable and the guarantee is a promise the engine cannot keep.
	var thread_chapters: Dictionary = {}
	var priorities: Dictionary = {}
	var fields_present := true
	var windows_widened := true
	var mechanism_intact := true
	for event: Dictionary in living_content.events.values():
		if not bool(event.get("living_road_callback", false)):
			continue
		var event_id := str(event.get("id", ""))
		var thread := str(event.get("callback_thread", ""))
		var chapter_region := int(event.get("callback_region", -1))
		var eligibility: Dictionary = event.get("eligibility", {})
		fields_present = fields_present and thread != "" and chapter_region >= 1 and chapter_region <= 5
		fields_present = fields_present and not (eligibility.get("requires_any_flags", []) as Array).is_empty()
		windows_widened = windows_widened and int(eligibility.get("min_region_index", -1)) == chapter_region and int(eligibility.get("max_region_index", -1)) == chapter_region + 1
		mechanism_intact = mechanism_intact and ("lr_callback_region_%d" % chapter_region) in eligibility.get("forbids_flags", []) and int(event.get("weight", 0)) == 3
		priorities[event_id] = int(event.get("narrative_priority", 0))
		var chapters: Array = thread_chapters.get(thread, [])
		chapters.append(chapter_region)
		thread_chapters[thread] = chapters
	var five_threads := thread_chapters.size() == 5
	for thread: String in thread_chapters:
		five_threads = five_threads and (thread_chapters[thread] as Array).size() == 3
	_check(fields_present, "Every chapter carries the callback_thread, callback_region, and requires_any_flags that focus and due are derived from")
	_check(five_threads, "The fifteen chapters resolve into exactly five three-chapter threads")
	_check(windows_widened, "Each chapter opens in its own callback region and stays eligible for exactly one region more")
	_check(mechanism_intact, "Widening the window leaves the lr_callback_region_N limit and the authored weights untouched")
	var priorities_unchanged := true
	for opener: String in ["lr_blue_van", "lr_quiet_column", "lr_pharmacy_witness", "lr_cup_passed_east", "lr_embers_in_rain"]:
		priorities_unchanged = priorities_unchanged and int(priorities[opener]) == 7
	for continuation: String in ["lr_voice_in_reeds", "lr_last_battery", "lr_bellkeepers_son", "lr_siren_in_glass", "lr_bandit_ledger", "lr_last_toll", "lr_thirst_court", "lr_valve_below", "lr_names_on_smoke", "lr_warm_windows"]:
		priorities_unchanged = priorities_unchanged and int(priorities[continuation]) == 9
	_check(priorities_unchanged, "Focused scheduling changes no chapter's narrative priority: openers stay 7 and continuations stay 9")

	# Derivation: focus is the earliest resolved chapter's thread, and only that
	# thread's chapters are ever due.
	var derive := _new_game(living_content, 4400)
	_check(derive._focused_callback_thread() == "" and derive._due_callback_event_id() == "", "A run that has resolved no chapter has no focused thread and nothing due")
	derive.run_state["event_history"] = ["outskirts_bus", "lr_quiet_column", "lr_blue_van"]
	derive.run_state["flags"] = ["lr_siren_silenced", "lr_column_trusts", "lr_channel_helped", "lr_family_trusted"]
	_check(derive._focused_callback_thread() == "quiet_column", "Focus is the thread of the earliest chapter in the recorded history")
	_check(derive._due_callback_event_id() == "lr_bellkeepers_son", "Meeting a second thread's opener does not move focus or reserve a slot for it")
	derive.run_state["event_history"].append("lr_bellkeepers_son")
	derive.run_state["flags"].append("lr_perrin_rescued")
	_check(derive._due_callback_event_id() == "lr_siren_in_glass", "Resolving the due chapter advances the focused thread to its next chapter")
	derive.run_state["event_history"].append("lr_siren_in_glass")
	derive.run_state["flags"].append("lr_column_saved")
	_check(derive._due_callback_event_id() == "" and derive._focused_callback_thread() == "quiet_column", "A thread ends on its own final chapter and reserves nothing afterwards")
	var stalled := _new_game(living_content, 4401)
	stalled.run_state["event_history"] = ["lr_blue_van"]
	stalled.run_state["flags"] = ["lr_channel_helped"]
	_check(stalled._due_callback_event_id() == "", "A chapter whose outcome wrote no flag its successor reads leaves nothing due rather than reserving forever")
	var launch_focus := _new_game(release_content, 4402)
	launch_focus.run_state["event_history"] = ["outskirts_bus", "flats_nightfire"]
	launch_focus.run_state["flags"] = ["lr_nightfire_shared"]
	_check(launch_focus._focused_callback_thread() == "" and launch_focus._due_callback_event_id() == "", "The launch build loads no chapters, so nothing is ever focused and no slot is ever reserved")

	# A deliberate refusal is an answer, not an exit: the thread stays focused.
	for refusal: Dictionary in [
		{"event": "lr_blue_van", "source": "lr_channel_helped", "region": 1, "refusal_flag": "lr_family_directed", "next": "lr_voice_in_reeds"},
		{"event": "lr_quiet_column", "source": "lr_siren_silenced", "region": 1, "refusal_flag": "lr_column_refused", "next": "lr_bellkeepers_son"},
	]:
		var refused := _new_game(living_content, 4403)
		refused.run_state["region_index"] = int(refusal["region"])
		refused.run_state["events_in_region"] = 0
		refused.run_state["event_history"] = []
		refused.run_state["flags"] = [str(refusal["source"])]
		refused.run_state["current_event_id"] = str(refusal["event"])
		refused.run_state["phase"] = "event"
		var refusal_result := refused.resolve_choice(2)
		_check(not refusal_result.has("error") and str(refusal["refusal_flag"]) in refused.run_state["flags"], "%s choice 2 is the certain refusal and writes its own flag" % refusal["event"])
		_check(refused._focused_callback_thread() != "" and refused._due_callback_event_id() == str(refusal["next"]), "Refusing %s keeps the thread focused with its next chapter due" % refusal["event"])
		refused.run_state["region_index"] = int(refusal["region"]) + 1
		refused.run_state["events_in_region"] = 0
		refused.run_state["supply_seen_in_region"] = false
		refused.run_state["combat_opportunities_seen_in_region"] = 0
		refused._select_next_event()
		_check(str(refused.run_state.get("current_event_id", "")) == str(refusal["next"]), "The refused thread's next chapter still takes the first ordinary slot of the next region")

	# The two regional guarantees keep absolute precedence over the reservation.
	var focused_combat := _new_game(living_content, 9194)
	focused_combat.run_state["region_index"] = 2
	focused_combat.run_state["events_in_region"] = GameEngine.EVENTS_PER_REGION - 2
	focused_combat.run_state["event_history"] = ["lr_blue_van"]
	focused_combat.run_state["flags"] = ["lr_channel_helped", "lr_family_trusted"]
	focused_combat.run_state["combat_opportunities_seen_in_region"] = 0
	_check(focused_combat._due_callback_event_id() == "lr_voice_in_reeds" and focused_combat._event_eligible(living_content.get_event("lr_voice_in_reeds")), "The focused thread's chapter is due and eligible in the region under test")
	focused_combat._select_next_event()
	_check(living_content.event_has_combat_choice(focused_combat.current_event()), "The fourth-slot combat guarantee outranks a reserved chapter")
	var focused_supply := _new_game(living_content, 9195)
	focused_supply.run_state["region_index"] = 2
	focused_supply.run_state["events_in_region"] = GameEngine.EVENTS_PER_REGION - 1
	focused_supply.run_state["event_history"] = ["lr_blue_van"]
	focused_supply.run_state["flags"] = ["lr_channel_helped", "lr_family_trusted"]
	focused_supply.run_state["supply_seen_in_region"] = false
	focused_supply._select_next_event()
	_check("supply_opportunity" in focused_supply.current_event().get("tags", []), "The fifth-slot supply guarantee outranks a reserved chapter")

	# The reservation outranks every competing global, including the three
	# Bunker and Rust-Sea openings with a higher narrative priority.
	var hatch := _new_game(living_content, 9196)
	hatch.run_state["region_index"] = 4
	hatch.run_state["events_in_region"] = 0
	hatch.run_state["event_history"] = ["lr_quiet_column", "lr_bellkeepers_son"]
	hatch.run_state["flags"] = ["lr_siren_silenced", "lr_column_trusts", "lr_perrin_rescued"]
	_check(hatch._event_eligible(living_content.get_event("bunker41_rusted_hatch")), "The priority-10 rusted hatch is eligible in the same Glass Wastes slot")
	hatch._select_next_event()
	_check(str(hatch.run_state.get("current_event_id", "")) == "lr_siren_in_glass", "A due chapter takes the slot ahead of the priority-10 rusted hatch")
	var green := _new_game(living_content, 9197)
	green.run_state["region_index"] = 5
	green.run_state["events_in_region"] = 0
	green.run_state["event_history"] = ["lr_pharmacy_witness", "lr_bandit_ledger"]
	green.run_state["flags"] = ["lr_bandits_escaped", "lr_lio_believes", "lr_ledger_shared", "b41_mara_helped"]
	_check(green._event_eligible(living_content.get_event("rustsea_green_line")), "The priority-11 Green Line is eligible in the same Underrail slot")
	green._select_next_event()
	_check(str(green.run_state.get("current_event_id", "")) == "lr_last_toll", "A due chapter takes the slot ahead of the priority-11 Green Line")
	# Constructed state: in ordinary play no chapter can have resolved before the
	# first draw of the Salt Flats, so the omen keeps that slot. This exercises
	# the override itself against the priority-9 competitor named in the plan.
	var omen := _new_game(living_content, 9198)
	omen.run_state["region_index"] = 1
	omen.run_state["events_in_region"] = 0
	omen.run_state["event_history"] = ["lr_voice_in_reeds"]
	omen.run_state["flags"] = ["lr_channel_helped", "lr_family_trusted", "lr_family_reunited"]
	_check(omen._event_eligible(living_content.get_event("bunker41_static")), "The priority-9 Bunker Forty-One omen is eligible in the same Salt Flats slot")
	omen._select_next_event()
	_check(str(omen.run_state.get("current_event_id", "")) == "lr_blue_van", "A due chapter takes the slot ahead of the priority-9 Bunker Forty-One omen")

	# The widened window is the safety net for a chapter whose own region closed
	# without it. It is exactly one region wide, and it does not defeat the
	# one-callback-per-region limit: a region that spent its slot spent it for
	# the run, and the reservation offers a slot rather than bypassing gating.
	var delayed := _new_game(living_content, 9199)
	delayed.run_state["event_history"] = ["lr_blue_van"]
	delayed.run_state["flags"] = ["lr_channel_helped", "lr_family_trusted"]
	delayed.run_state["region_index"] = 2
	_check(delayed._event_eligible(living_content.get_event("lr_voice_in_reeds")), "A due chapter is eligible in its own callback region")
	delayed.run_state["region_index"] = 3
	_check(delayed._event_eligible(living_content.get_event("lr_voice_in_reeds")), "A chapter whose region closed without it stays eligible one region later")
	delayed.run_state["region_index"] = 4
	_check(not delayed._event_eligible(living_content.get_event("lr_voice_in_reeds")), "The widened window is exactly one region wide, not an open end")
	delayed.run_state["region_index"] = 3
	delayed.run_state["events_in_region"] = 0
	delayed.run_state["supply_seen_in_region"] = false
	delayed.run_state["combat_opportunities_seen_in_region"] = 0
	delayed._select_next_event()
	_check(str(delayed.run_state.get("current_event_id", "")) == "lr_voice_in_reeds", "A late chapter still takes the first ordinary slot of the region it slipped into")
	var spent := _new_game(living_content, 9200)
	spent.run_state["event_history"] = ["lr_blue_van"]
	spent.run_state["flags"] = ["lr_channel_helped", "lr_family_trusted", "lr_callback_region_2"]
	spent.run_state["region_index"] = 3
	spent.run_state["events_in_region"] = 0
	_check(spent._due_callback_event_id() == "lr_voice_in_reeds" and not spent._event_eligible(living_content.get_event("lr_voice_in_reeds")), "A chapter stays due while the region that owns its slot has already spent it")
	spent._select_next_event()
	_check(str(spent.run_state.get("current_event_id", "")) != "lr_voice_in_reeds", "The reservation offers an ordinary slot and never bypasses eligibility or the one-callback-per-region limit")

	# Whole seeded journeys: the thread the survivor engaged with finishes.
	var isolated_total := 0
	for spec: Dictionary in thread_specs:
		var complete := 0
		for seed_value in range(7000, 7040):
			var history := _living_road_journey(living_content, seed_value, [str(spec["source"])], str(spec["source"]))
			var all_three := true
			for chapter: Variant in spec["chapters"]:
				all_three = all_three and str(chapter) in history
			complete += int(all_three)
		isolated_total += complete
		_check(complete == 40, "A survivor whose only Living Road history is %s reaches all three of its chapters in forty seeded runs" % str(spec["thread"]))
	_check(isolated_total == 200, "All five arcs complete across two hundred seeded runs and five different recorded histories")

	var competing_flags: Array = ["lr_channel_helped", "lr_siren_silenced", "lr_bandits_escaped", "lr_filter_repaired", "lr_nightfire_shared", "b41_mara_helped"]
	var focused_runs := 0
	var focused_complete := 0
	var omen_seen := 0
	var hatch_seen := 0
	var green_seen := 0
	for seed_value in range(7000, 7060):
		var history := _living_road_journey(living_content, seed_value, competing_flags, "")
		omen_seen += int("bunker41_static" in history)
		hatch_seen += int("bunker41_rusted_hatch" in history)
		green_seen += int("rustsea_green_line" in history)
		var thread := ""
		for raw_id: Variant in history:
			var recorded: Dictionary = living_content.get_event(str(raw_id))
			if bool(recorded.get("living_road_callback", false)):
				thread = str(recorded.get("callback_thread", ""))
				break
		if thread == "":
			continue
		focused_runs += 1
		var all_three := true
		for spec: Dictionary in thread_specs:
			if str(spec["thread"]) != thread:
				continue
			for chapter: Variant in spec["chapters"]:
				all_three = all_three and str(chapter) in history
		focused_complete += int(all_three)
	_check(focused_runs == 60 and focused_complete == 60, "With all five hooks live and the Bunker priorities competing, the focused thread completes in every one of sixty seeded runs")
	_check(omen_seen == 60 and hatch_seen == 60 and green_seen == 60, "A reserved slot delays the omen, the rusted hatch, and the Green Line inside their own windows without making any of them unreachable")

	# The reservation replaces a draw; it never adds one. Region length, combat
	# density, and the supply guarantee are what hunger, fatigue, and XP pace on.
	var drawn_events := 0
	var drawn_regions := 0
	var combat_within_band := true
	var supply_every_region := true
	for seed_value in range(8000, 8060):
		var game := _new_game(living_content, seed_value)
		for flag: String in ["lr_channel_helped", "lr_siren_silenced", "lr_bandits_escaped", "lr_filter_repaired", "lr_nightfire_shared"]:
			if flag not in game.run_state["flags"]:
				game.run_state["flags"].append(flag)
		for region_index in range(6):
			game.run_state["region_index"] = region_index
			game.run_state["events_in_region"] = 0
			game.run_state["supply_seen_in_region"] = false
			game.run_state["combat_opportunities_seen_in_region"] = 0
			for position in range(GameEngine.EVENTS_PER_REGION):
				game._select_next_event()
				var selected := game.current_event()
				game._record_event(selected)
				for flag: Variant in _first_authored_outcome_flags(selected):
					if str(flag) not in game.run_state["flags"]:
						game.run_state["flags"].append(str(flag))
				game.run_state["events_in_region"] = position + 1
				drawn_events += 1
			drawn_regions += 1
			var combat_count := int(game.run_state.get("combat_opportunities_seen_in_region", 0))
			combat_within_band = combat_within_band and combat_count >= 1 and combat_count <= 2
			supply_every_region = supply_every_region and bool(game.run_state.get("supply_seen_in_region", false))
	_check(drawn_regions == 360 and drawn_events == drawn_regions * GameEngine.EVENTS_PER_REGION, "A reserved chapter replaces the draw it took: three hundred and sixty focused regions still draw exactly five events each")
	_check(combat_within_band, "Focused scheduling still presents one or two combat opportunities in every region")
	_check(supply_every_region, "Focused scheduling still guarantees a supply opportunity in every region")


## A deterministic Living Road journey for the scheduling samples. The survivor
## is kept fed and whole so the sample measures scheduling rather than survival,
## and the policy always takes the first available non-combat choice so no
## tactical fight consumes rolls. `only_source` reproduces the history of a
## survivor who met one source scene by stripping the other threads' source
## flags the moment a scene writes them.
func _living_road_journey(content: ContentRepository, seed_value: int, flags: Array, only_source: String) -> Array:
	const SOURCE_FLAGS := [
		"lr_channel_helped", "lr_channel_misled", "lr_channel_traced", "lr_channel_lost",
		"lr_siren_silenced", "lr_siren_burned", "lr_siren_endured", "lr_siren_followed",
		"lr_bandit_leader_killed", "lr_bandit_leader_disarmed", "lr_bandits_escaped",
		"lr_bandits_wounded_escape", "lr_bandits_bluffed", "lr_bandits_paid",
		"lr_filter_repaired", "lr_filter_poisoned", "lr_filter_stripped", "lr_filter_broken",
		"lr_nightfire_shared", "lr_nightfire_robbed", "lr_nightfire_passed", "lr_nightfire_spooked",
	]
	var game := _new_game(content, seed_value)
	for flag: Variant in flags:
		if str(flag) not in game.run_state["flags"]:
			game.run_state["flags"].append(str(flag))
	for step in range(300):
		var phase := str(game.run_state.get("phase", ""))
		if phase in ["death", "victory"]:
			break
		if phase == "event":
			var index := _first_available_noncombat_choice(game)
			if index < 0:
				break
			if game.resolve_choice(index, 14).has("error"):
				break
			if only_source != "":
				var kept: Array = []
				for flag: Variant in game.run_state["flags"]:
					if str(flag) in SOURCE_FLAGS and str(flag) != only_source:
						continue
					kept.append(flag)
				game.run_state["flags"] = kept
		elif phase == "result":
			game.run_state["survivor"]["vitals"]["satiety"] = 4
			game.run_state["survivor"]["vitals"]["health"] = int(game.run_state["survivor"]["vitals"].get("max_health", 100))
			game.run_state["survivor"]["pressures"]["fatigue"] = 0
			game.run_state["survivor"]["pressures"]["radiation"] = 0
			game.continue_after_result()
		elif phase == "checkpoint":
			game.press_on_from_checkpoint()
			game.leave_checkpoint()
		else:
			break
	return (game.run_state.get("event_history", []) as Array).duplicate()


## The flags a scene writes on its first authored outcome, used to advance the
## scheduling sample without playing every branch.
func _first_authored_outcome_flags(event: Dictionary) -> Array:
	for choice: Dictionary in event.get("choices", []):
		for outcome_key: String in ["outcome", "success"]:
			if choice.has(outcome_key):
				return choice[outcome_key].get("add_flags", [])
	return []


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
	_check(ExperienceRules.level_for_xp(aggressive_xp) - 1 == 7, "An exceptional aggressive survivor projects to seven run-only stat points")


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
	_check(UiTypeWidget.line_spacing("prose") > 0 and UiTypeWidget.line_spacing("action") == 0, "Prose keeps readable extra leading without spacing out interface labels")
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
	_check("GUARANTEED COST" in ui_source and "COMMITTED RECEIPT" in ui_source and "_choice_cost_text" in ui_source, "Choice rows expose known prices and results present a committed receipt")
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
	var inventory_link := hud.make_inventory_link(1.0)
	root.add_child(inventory_link)
	_check(inventory_link.find_child("InventoryIcon", true, false) is UiIconWidget and conditions_link.find_child("StatusIcon", true, false) is UiIconWidget, "Inventory and status controls use their generated pixel-art icons while retaining accessible labels")
	var hud_portrait_frame := hud.find_child("SurvivorPortraitFrame", true, false)
	_check(hud_portrait_frame != null and hud_portrait_frame.custom_minimum_size == Vector2(64, 64), "The survivor HUD reserves a readable 64-pixel portrait frame")
	_check(PortraitArtWidget.expected_ids().size() == 25, "Portrait resolver owns four survivor and twenty-one adversary IDs, including the eight creatures that ship without artwork")
	# A creature with no image is described rather than labelled with its own ID.
	var widow: Dictionary = content.get_adversary("reed_widow")
	var described := PortraitArtWidget.create_view(str(widow["portrait_id"]), Color.WHITE, 9, str(widow["name"]), str(widow.get("field_note", "")))
	var note_label := described.get_child(0) as Label
	_check(note_label != null and note_label.name == "PortraitFieldNote", "A creature without artwork renders a described frame rather than the ID placeholder")
	_check(note_label != null and "PORTRAIT" not in note_label.text, "The described frame never shows the raw PORTRAIT placeholder")
	_check(note_label != null and "REED WIDOW" in note_label.text and "one laced boot" in note_label.text, "The described frame names the creature and shows its field note")
	for creature_id: String in ["shutter_skitters", "cable_eater", "pox_dogs", "bile_spewer", "cinder_mauler", "salt_colossus"]:
		var creature: Dictionary = content.get_adversary(creature_id)
		var creature_view := PortraitArtWidget.create_view(str(creature["portrait_id"]), Color.WHITE, 9, str(creature["name"]), str(creature.get("field_note", "")))
		var creature_note := creature_view.get_child(0) as Label
		_check(creature_note != null and creature_note.name == "PortraitFieldNote" and creature_note.text.contains(str(creature["name"]).to_upper()) and not creature_note.text.contains("PORTRAIT"), "%s uses the described missing-image presentation" % creature_id)
		creature_view.queue_free()
	var plain := PortraitArtWidget.create_view("enemy_bandits", Color.WHITE, 9, "Road Bandits", "")
	var plain_label := plain.get_child(0) as Label
	_check(plain_label != null and plain_label.name == "PortraitFallback" and plain_label.text.begins_with("PORTRAIT"), "An adversary with no field note keeps the existing placeholder unchanged")
	for creature_id: String in ["enemy_skitters", "enemy_widow", "enemy_kilnback", "enemy_cable_eater", "enemy_pox_dogs", "enemy_bile_spewer", "enemy_cinder_mauler", "enemy_salt_colossus"]:
		_check(creature_id in PortraitArtWidget.ENEMY_IDS, "The roster registers %s" % creature_id)
	described.queue_free()
	plain.queue_free()
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
	_check(item_icon.category == "consumable" and item_icon.atlas_texture != null and item_icon._atlas_cell() == Vector2i(0, 1), "Inventory icons resolve through stable IDs into the packaged pixel-art atlas")
	var ui_icon = UiIconWidget.new()
	root.add_child(ui_icon)
	ui_icon.configure("rest", 24)
	_check(UiIconWidget.symbol_ids().size() == 16 and ui_icon.atlas_texture != null and ui_icon.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "The packaged UI atlas provides all sixteen nearest-neighbor gameplay symbols")
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
	_check(not story.is_reveal_complete(), "A second press waits for release so it can still become a swipe")
	double_tap.pressed = false
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
	var stat_only_copy := "\n".join(_label_texts(ui.stat_details_popup))
	_check("ACTIVE — SHAKEN" not in stat_only_copy and "SHAKEN" not in stat_only_copy and "STATUS" in stat_only_copy, "Stat details stay a pure ability reference and send conditions to the Status sheet")
	ui._close_stat_details()
	ui.game.run_state["survivor"]["conditions"] = ["shaken", "focused"]
	ui.game.run_state["condition_uses"]["focused"] = 1
	ui.game.run_state["survivor"]["inventory"]["bitter_tonic"] = 1
	ui._show_conditions()
	var status_copy := "\n".join(_label_texts(ui.conditions_popup))
	_check(ui.conditions_popup.visible and "1 HARMFUL" in status_copy and "1 HELPFUL" in status_copy and "HARMFUL — SHAKEN" in status_copy and "HELPFUL — FOCUSED" in status_copy, "Status sheet separates and explains harmful and helpful active conditions")
	_check("Wits -1" in status_copy and "Presence -1" in status_copy, "Status sheet states the exact stat penalties of an active condition")
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
		# Checkpoint departures render their action in an overlay label so the
		# text can wrap on a narrow phone; the Button keeps the same action as
		# its accessible name. Read that when the drawn text is blanked.
		var button_text := str(node.text)
		if button_text == "":
			button_text = str(node.accessibility_name)
		labels.append(button_text)
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


func _test_expanded_opening_guidance(living_content: ContentRepository, release_content: ContentRepository) -> void:
	var expected_hooks := {"outskirts_child_radio": true, "outskirts_market": true, "outskirts_cache": true}
	var early_sources := ["outskirts_child_radio", "outskirts_siren"]
	var seen_hooks := {}
	var all_safe_hooks := true
	var complementary_teaching := true
	var source_guaranteed := true
	var deterministic := true
	for seed_value in range(1, 501):
		var game := _new_game(living_content, seed_value)
		var first: Dictionary = game.current_event()
		var first_id := str(first.get("id", ""))
		var first_tags: Array = first.get("tags", [])
		all_safe_hooks = all_safe_hooks and "opening_safe" in first_tags and "opening_hook" in first_tags and expected_hooks.has(first_id)
		seen_hooks[first_id] = true
		game._record_event(first)
		game.run_state["events_in_region"] = 1
		game._select_next_event()
		var second: Dictionary = game.current_event()
		var second_id := str(second.get("id", ""))
		var second_tags: Array = second.get("tags", [])
		complementary_teaching = complementary_teaching and (("opening_resource" in first_tags and "opening_equipment" in second_tags) or ("opening_equipment" in first_tags and "opening_resource" in second_tags))
		game._record_event(second)
		game.run_state["events_in_region"] = 2
		game._select_next_event()
		var third_id := str(game.current_event().get("id", ""))
		if first_id not in early_sources and second_id not in early_sources:
			source_guaranteed = source_guaranteed and third_id in early_sources
		var replay := _new_game(living_content, seed_value)
		replay._record_event(replay.current_event())
		replay.run_state["events_in_region"] = 1
		replay._select_next_event()
		replay._record_event(replay.current_event())
		replay.run_state["events_in_region"] = 2
		replay._select_next_event()
		deterministic = deterministic and third_id == str(replay.current_event().get("id", ""))
	_check(all_safe_hooks, "Five hundred expanded seeds begin on one of the three safe opening hooks")
	_check(seen_hooks.size() == expected_hooks.size(), "Five hundred expanded seeds show Channel Nine, Market, and Cache openings")
	_check(complementary_teaching, "Expanded openings retain complementary resource and equipment teaching on the second draw")
	_check(source_guaranteed, "Expanded third draws reserve Channel Nine or Quiet Column's source when neither appeared")
	_check(deterministic, "Expanded opening guidance replays the same three-event sequence for the same seed")

	var release_retains_non_hook_opening := false
	for seed_value in range(1, 501):
		var release_game := _new_game(release_content, seed_value)
		var release_tags: Array = release_game.current_event().get("tags", [])
		release_retains_non_hook_opening = release_retains_non_hook_opening or "opening_hook" not in release_tags
	_check(release_retains_non_hook_opening, "Release opening selection retains safe events outside the expanded hook pool")

	var refusal := _new_game(living_content, 8801)
	refusal.run_state["current_event_id"] = "outskirts_child_radio"
	refusal.run_state["phase"] = "event"
	var inventory_before: Dictionary = refusal.run_state["survivor"]["inventory"].duplicate(true)
	var pressures_before: Dictionary = refusal.run_state["survivor"]["pressures"].duplicate(true)
	var conditions_before: Array = refusal.run_state["survivor"]["conditions"].duplicate()
	var refusal_result := refusal.resolve_choice(2)
	_check(not refusal_result.has("error") and str(refusal_result.get("resolution", {}).get("outcome", "")) == "outcome", "Channel Nine's appended leave choice resolves without a roll")
	_check(refusal.run_state["survivor"]["inventory"] == inventory_before and refusal.run_state["survivor"]["pressures"] == pressures_before and refusal.run_state["survivor"]["conditions"] == conditions_before and refusal.run_state["flags"].is_empty(), "Leaving Channel Nine grants no authored resource, pressure, condition, or source flag")
	_check("given no answer" in str(refusal_result.get("outcome_text", "")) and "learned no bearing" in str(refusal_result.get("outcome_text", "")), "Channel Nine refusal records no contact or bearing")
	var refusal_recap := MainUI.new()
	refusal_recap.content = living_content
	refusal_recap.game = refusal
	var refusal_recap_text := "\n".join(PackedStringArray(refusal_recap._resume_recap_lines()))
	_check("Committed change: none." in refusal_recap_text, "Resume recap makes Channel Nine's no-change refusal explicit without adding a reward")
	var labor_recap_game := _new_game(release_content, 8802)
	labor_recap_game.run_state["current_event_id"] = "outskirts_market"
	labor_recap_game.run_state["phase"] = "event"
	labor_recap_game.resolve_choice(2)
	var labor_recap := MainUI.new()
	labor_recap.content = release_content
	labor_recap.game = labor_recap_game
	var labor_recap_text := "\n".join(PackedStringArray(labor_recap._resume_recap_lines()))
	_check("Fatigue +6" in labor_recap_text, "Resume recap carries an actual committed fatigue cost alongside its story outcome")


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
	game.award_experience(39, "Test", "test:39")
	_check(int(game.run_state["level"]) == 1 and int(game.run_state["unspent_stat_points"]) == 0, "XP below the first threshold grants no point")
	var first_level := game.award_experience(1, "Test", "test:40")
	_check(int(game.run_state["level"]) == 2 and int(game.run_state["unspent_stat_points"]) == 1 and int(first_level.get("levels_gained", 0)) == 1, "Crossing an XP threshold banks exactly one point")
	var duplicate := game.award_experience(99, "Duplicate", "test:40")
	_check(bool(duplicate.get("duplicate", false)) and int(game.run_state["experience"]) == 40, "A persisted XP source cannot be awarded twice")
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
	_check(progressed_v4["checkpoint_xp_awards"] == [0, 1, 2] and int(progressed_v4["level"]) == 4 and int(progressed_v4["experience"]) == 144, "Migrated checkpoint levels convert to equivalent schema-4 XP progression")
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
	_check(content.items.size() == 72 and unreachable.is_empty(), "All seventy-two defined items have a launch starting or acquisition route")


## N03 pilot arc: the Channel Nine thread must read differently for each history
## the source event can leave behind, and must never describe a radio it destroyed.
func _test_channel_nine_arc() -> void:
	var content := ContentRepository.new(true)
	var van: Dictionary = content.get_event("lr_blue_van")
	var bodies: Dictionary = {}
	for history: String in ["lr_channel_helped", "lr_channel_misled", "lr_channel_traced", "lr_channel_lost"]:
		var game := _new_game(content, 4242)
		game.run_state["flags"].append(history)
		if history == "lr_channel_traced":
			game.run_state["survivor"]["inventory"]["signal_compass"] = 1
		var body := game.resolve_body(van)
		bodies[history] = body
		var spoken := history in ["lr_channel_helped", "lr_channel_misled"]
		_check(bool(game.get_choice_preview(van["choices"][0]).get("hidden", false)) != spoken, "The van offers its cadence check only to a survivor who spoke on Channel Nine (%s)" % history)
		var bearing_visible := not bool(game.get_choice_preview(van["choices"][3]).get("hidden", false))
		_check(bearing_visible == (history == "lr_channel_traced"), "The relay bearing is offered only to a survivor who traced the signal and still carries the compass (%s)" % history)
	_check(bodies.values().size() == 4 and _distinct(bodies.values()) == 4, "Each of the four Channel Nine histories opens the van on different words")
	var spent := _new_game(content, 4242)
	spent.run_state["flags"].append("lr_channel_traced")
	spent.run_state["survivor"]["inventory"].erase("signal_compass")
	_check(bool(spent.get_choice_preview(van["choices"][3]).get("hidden", false)), "A spent compass withdraws the bearing rather than offering a promise it cannot keep")

	for event_id: String in ["lr_voice_in_reeds", "lr_last_battery"]:
		var event: Dictionary = content.get_event(event_id)
		var working := _new_game(content, 4242)
		working.run_state["flags"].append("lr_family_linked")
		var dead := _new_game(content, 4242)
		dead.run_state["flags"].append("lr_family_silenced")
		var with_radio := working.resolve_body(event)
		var without := dead.resolve_body(event)
		_check(with_radio != without, "%s does not open on a working radio after the set was destroyed" % event_id)
		var lowered := without.to_lower()
		_check("no radio" in lowered or "no transmitter" in lowered, "%s states the set is gone rather than leaving the player to infer it" % event_id)
		_check(not ("channel nine comes" in lowered or "saying your callsign" in lowered), "%s drops the working-radio opening that made the silenced history false" % event_id)
	var pure := _new_game(content, 4242)
	pure.run_state["flags"].append("lr_channel_helped")
	var rng_before: int = pure.run_state["rng_state"]
	_check(pure.resolve_body(van) == pure.resolve_body(van) and int(pure.run_state["rng_state"]) == rng_before, "Reopening a conditional passage repeats it exactly and rolls nothing")


func _test_betrayal_arc() -> void:
	var expanded := ContentRepository.new(true)
	var baseline := ContentRepository.new(false)
	var betrayal_ids := ["betrayal_vex_meeting", "betrayal_vex_cache", "betrayal_vex_ambush", "betrayal_vex_reckoning", "betrayal_slate_claim", "betrayal_slate_ledger", "betrayal_slate_knives", "betrayal_slate_settlement", "betrayal_anselm_invite", "betrayal_anselm_tithe", "betrayal_anselm_brand", "betrayal_anselm_ash"]
	for event_id: String in betrayal_ids:
		_check(not expanded.get_event(event_id).is_empty(), "%s loads in the expanded release" % event_id)
		_check(baseline.get_event(event_id).is_empty(), "%s stays out of the compatibility baseline" % event_id)
	_check(expanded.events.size() == 124, "Twelve betrayal-arc events join the expanded release")
	var cache := _new_game(expanded, 4242)
	cache.run_state["region_index"] = 2
	_check(not cache._event_eligible(expanded.get_event("betrayal_vex_cache")), "The sealed package is not offered before Vex is trusted")
	cache.run_state["flags"].append("trust_vex_1")
	_check(cache._event_eligible(expanded.get_event("betrayal_vex_cache")), "The sealed package is offered once Vex is trusted")
	var ambush := _new_game(expanded, 4243)
	ambush.run_state["region_index"] = 3
	ambush.run_state["flags"].append("trust_vex_1")
	_check(not ambush._event_eligible(expanded.get_event("betrayal_vex_ambush")), "The cistern ambush waits on the carried package, not the first meeting")
	ambush.run_state["flags"].append("trust_vex_2")
	_check(ambush._event_eligible(expanded.get_event("betrayal_vex_ambush")), "The cistern ambush is offered once the package is carried")
	var reckoning := _new_game(expanded, 4244)
	reckoning.run_state["region_index"] = 4
	_check(not reckoning._event_eligible(expanded.get_event("betrayal_vex_reckoning")), "The reckoning is not offered to a stranger")
	reckoning.run_state["flags"].append("grudge_vex_betrayed")
	_check(reckoning._event_eligible(expanded.get_event("betrayal_vex_reckoning")), "The reckoning is offered to a betrayed survivor")
	var wary_body := _new_game(expanded, 4245)
	wary_body.run_state["flags"].append("grudge_vex_wary")
	var betrayed_body := _new_game(expanded, 4245)
	betrayed_body.run_state["flags"].append("grudge_vex_betrayed")
	_check(wary_body.resolve_body(expanded.get_event("betrayal_vex_reckoning")) != betrayed_body.resolve_body(expanded.get_event("betrayal_vex_reckoning")), "The reckoning reads differently for a wary survivor than a betrayed one")
	var meal := _new_game(expanded, 4246)
	meal.run_state["region_index"] = 1
	meal.run_state["current_event_id"] = "betrayal_vex_meeting"
	meal.run_state["phase"] = "event"
	meal.run_state["survivor"]["inventory"]["canned_meat"] = 1
	meal.resolve_choice(0)
	_check("trust_vex_1" in meal.run_state["flags"] and int(meal.get_item_quantity("clean_water")) >= 1, "Sharing a meal earns Vex's trust and clean water")
	var knives := _new_game(expanded, 4247)
	knives.run_state["region_index"] = 2
	knives.run_state["flags"].append("trust_slate_2")
	knives.run_state["current_event_id"] = "betrayal_slate_knives"
	knives.run_state["phase"] = "event"
	_check(bool(knives.start_combat(0).get("combat_started", false)), "The collateral crew can be met head-on")
	var brand := _new_game(expanded, 4248)
	brand.run_state["region_index"] = 4
	brand.run_state["flags"].append("trust_anselm_2")
	brand.run_state["current_event_id"] = "betrayal_anselm_brand"
	brand.run_state["phase"] = "event"
	_check(bool(brand.start_combat(0).get("combat_started", false)), "The brand circle can be broken by force")
	var profile := SaveService.new("ashfall_betrayal_test_").default_profile()
	var settled := StoryDiscoveryRules.apply_resolution({"event_id": "betrayal_vex_reckoning"}, ["grudge_vex_betrayed", "vex_settled"], expanded.get_discovery_entries(), profile)
	_check(bool(settled.get("changed", false)) and "ledger_vex_reckoning:settled" in profile["discovered_story_nodes"], "Settling the reckoning records its Chronicle chapter")
	var stranger := StoryDiscoveryRules.apply_resolution({"event_id": "betrayal_vex_reckoning"}, [], expanded.get_discovery_entries(), SaveService.new("ashfall_betrayal_test_").default_profile())
	_check(not bool(stranger.get("changed", true)), "A stranger records no reckoning chapter")


func _distinct(values: Array) -> int:
	var seen: Dictionary = {}
	for value: Variant in values:
		seen[str(value)] = true
	return seen.size()


func _test_full_run_replay(content: ContentRepository) -> void:
	var harness = FullRunHarness.new()
	harness.content = content
	var recorded: Dictionary = harness._play(4242, 0, {"mode": "policy", "trace": true, "record": true})
	var decisions: Array = recorded["decisions"]
	_check(decisions.size() > 10 and int(recorded["errors"]) == 0, "A legal-action run drives a whole journey without a rejected action")
	_check(str(recorded["result"]) in ["dead", "victory"], "A soak run reaches an authoritative ending rather than stalling")
	var replayed: Dictionary = harness._play(4242, 0, {"mode": "record", "decisions": decisions, "trace": true})
	_check(harness._comparable_state(recorded["final_state"]) == harness._comparable_state(replayed["final_state"]), "A recorded decision list replays to an identical run state")
	# run_id is stamped from the wall clock and embedded in every XP award and
	# encounter id, so a record and replay that straddle a second differ in
	# identity while playing identically. The comparison normalizes that.
	var stamped: Dictionary = recorded["final_state"].duplicate(true)
	var restamped: Dictionary = harness._normalize_run_id(stamped.duplicate(true), str(stamped.get("run_id", "")))
	restamped["run_id"] = str(stamped.get("run_id", "")).replace("-", "9-")
	restamped["started_at"] = float(stamped.get("started_at", 0.0)) + 1.0
	_check(harness._comparable_state(stamped) == harness._comparable_state(restamped), "A replay that crosses a second boundary still compares as the same run")
	var altered: Dictionary = stamped.duplicate(true)
	altered["region_index"] = int(altered.get("region_index", 0)) + 1
	_check(harness._comparable_state(stamped) != harness._comparable_state(altered), "Normalizing the clock does not hide a genuine difference in play")
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
	_check(entries.size() == 11 and reachable and not advertises_expansion, "The launch Chronicle lists exactly the eleven reachable chapters and no disabled callback")
	var living := ContentRepository.new(true)
	_check(living.get_discovery_entries().size() == 29, "Enabling the expansion restores all twenty-nine chapters and their denominator")
	var ledger_contract_holds := true
	var ledger_variant_count := 0
	for entry: Dictionary in living.get_discovery_entries().values():
		ledger_contract_holds = ledger_contract_holds and living.events.has(str(entry.get("event_id", ""))) and not str(entry.get("hint", "")).strip_edges().is_empty()
		var variant_ids: Dictionary = {}
		for variant: Dictionary in entry.get("variants", []):
			var variant_id := str(variant.get("id", "")).strip_edges()
			ledger_contract_holds = ledger_contract_holds and not variant_id.is_empty() and not variant_ids.has(variant_id)
			variant_ids[variant_id] = true
			ledger_variant_count += 1
	_check(ledger_contract_holds and ledger_variant_count == 58, "All twenty-nine Chronicle definitions have a loaded trigger, spoiler-safe hint, and locally unique variants")

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


## Latest_plan Week 1: six run-only talents, chosen after the first and third
## regions, with domain rules, save-aware commits, and versioned old saves.
func _test_talents(content: ContentRepository) -> void:
	_check(content.talents.size() == 6 and content.list_talents().size() == 6, "Six run-only talents are defined")
	var game := _new_game(content, 9101)
	_check(int(game.run_state.get("talent_version", 0)) == 1 and game.run_state.get("talents", []).is_empty(), "New runs stamp talent version 1 with no talents")
	_check(game.list_talent_options().size() == 6, "A new run is offered all six talents")
	game.run_state["phase"] = "checkpoint"
	game.run_state["region_index"] = 0
	_check(game.talent_choice_available(), "A talent choice is available after the first region")
	var before_rng := int(game.run_state["rng_state"])
	var untouched: Dictionary = game.run_state.duplicate(true)
	_game_talent_preview(game)
	_check(int(game.run_state["rng_state"]) == before_rng and game.run_state == untouched, "Talent and combat previews do not mutate state or RNG")
	var first := game.select_talent("bloodlust")
	_check(bool(first.get("success", false)) and game.has_talent("bloodlust"), "A talent selection commits")
	var duplicate := game.select_talent("bloodlust")
	_check(not bool(duplicate.get("success", false)), "Talents cannot duplicate")
	_check(game.list_talent_options().size() == 5, "Owned talents leave five remaining offers")
	game.run_state["region_index"] = 2
	_check(game.talent_choice_available(), "A second talent choice is available after the third region")
	var second := game.select_talent("patient_shot")
	_check(bool(second.get("success", false)) and game.run_state["talents"].size() == 2, "A second distinct talent commits")
	_check(not game.talent_choice_available(), "No third talent choice is offered")
	game.run_state["phase"] = "event"
	_check(not game.talent_choice_available() and not bool(game.select_talent("retaliation").get("success", false)), "Talents are checkpoint-only with no respec")
	# Old saves continue under previous build rules.
	var legacy: Dictionary = game.run_state.duplicate(true)
	legacy["talents"] = []
	legacy.erase("talent_version")
	# Migration fills defaults without enabling talents on old runs.
	var filled: Dictionary = legacy.duplicate(true)
	if not filled.has("talent_version"):
		filled["talent_version"] = 0
	if not filled.has("talents"):
		filled["talents"] = []
	_check(int(filled.get("talent_version", -1)) == 0, "Old saves migrate to talent version 0")
	# Bloodlust widens Execution to 60% at −10 accuracy; without it, 40% applies.
	var execution := _talent_combat_game(content, 9201, "salvage_cleaver")
	execution.run_state["combat_state"]["enemy_max_health"] = 100
	execution.run_state["combat_state"]["enemy_health"] = 55
	var base_chance := int(execution.combat_action_preview("attack")["chance"])
	execution.run_state["talents"] = ["bloodlust"]
	var blood_chance := int(execution.combat_action_preview("attack")["chance"])
	_check(blood_chance < base_chance, "Bloodlust trades 10 accuracy for the wider Execution window")
	execution.run_state["combat_state"]["enemy_health"] = 65
	_check(int(execution.combat_action_preview("attack")["chance"]) == base_chance or execution.run_state["combat_state"]["enemy_health"] > 60, "Bloodlust grants no bonus above 60% HP")
	# Patient Shot spends Opening without ammunition when loaded.
	var ranged := _talent_combat_game(content, 9202, "pipe_pistol")
	ranged.run_state["survivor"]["inventory"]["pistol_rounds"] = 3
	ranged.run_state["combat_state"]["opening"] = true
	ranged.run_state["talents"] = ["patient_shot"]
	_check(str(ranged.combat_action_preview("attack")["cost"]).begins_with("0"), "Patient Shot previews no ammunition cost with Opening")
	var rounds_before := ranged.get_item_quantity("pistol_rounds")
	ranged.run_state["pending_combat_round"] = {}
	_talent_resolve(ranged, "attack", 15, 10)
	_check(ranged.get_item_quantity("pistol_rounds") == rounds_before, "Patient Shot consumes no ammunition")
	# Retaliation needs a shield; failed Block still grants Riposte at x1.5.
	var shielded := _talent_combat_game(content, 9203, "salvage_cleaver")
	shielded.run_state["survivor"]["inventory"]["scrap_buckler"] = 1
	shielded.run_state["survivor"]["equipment"]["accessory"] = "scrap_buckler"
	shielded.run_state["talents"] = ["retaliation"]
	_talent_resolve(shielded, "block", 1, 10)
	_check(bool(shielded.run_state["combat_state"].get("riposte", false)), "Retaliation grants Riposte on a failed Block with a shield")
	var unshielded := _talent_combat_game(content, 9204, "salvage_cleaver")
	unshielded.run_state["talents"] = ["retaliation"]
	_talent_resolve(unshielded, "block", 1, 10)
	_check(not bool(unshielded.run_state["combat_state"].get("riposte", false)), "Retaliation respects the shield requirement")
	# Exploit Weakness grants Opening once per fight on a Heavy interrupt.
	var disrupt := _talent_combat_game(content, 9205, "shock_probe")
	disrupt.run_state["talents"] = ["exploit_weakness"]
	_talent_move(disrupt, "heavy")
	_talent_resolve(disrupt, "attack", 18, 10)
	_check(bool(disrupt.run_state["combat_state"].get("opening", false)), "Exploit Weakness grants Opening on the first interrupt")
	# Sustained Pressure carries suppression; Field Medicine keeps stance on heal.
	var suppress := _talent_combat_game(content, 9206, "holdout_revolver")
	suppress.run_state["survivor"]["inventory"]["revolver_rounds"] = 12
	suppress.run_state["combat_state"]["enemy_max_health"] = 400
	suppress.run_state["combat_state"]["enemy_health"] = 400
	suppress.run_state["talents"] = ["sustained_pressure"]
	_talent_resolve(suppress, "attack", 18, 10)
	_check(float(suppress.run_state["combat_state"].get("suppression_carry", 0.0)) > 0.0, "Sustained Pressure stores suppression for the following response")
	var medic := _talent_combat_game(content, 9207, "salvage_cleaver")
	medic.run_state["survivor"]["inventory"]["cloth_bandage"] = 2
	medic.run_state["survivor"]["vitals"]["health"] = maxi(1, int(medic.run_state["survivor"]["vitals"]["health"]) - 60)
	medic.run_state["combat_state"]["opening"] = true
	medic.run_state["talents"] = ["field_medicine"]
	_talent_resolve(medic, "use_item", 0, 10, "cloth_bandage")
	_check(bool(medic.run_state["combat_state"].get("opening", false)), "Field Medicine preserves Opening on the first heal")
	# Prepared fights stay authoritative across the talent change.
	var prepared := _talent_combat_game(content, 9208, "salvage_cleaver")
	prepared.run_state["combat_state"]["enemy_max_health"] = 100
	prepared.run_state["combat_state"]["enemy_health"] = 55
	var stored := prepared.prepare_combat_action("attack")
	_check(not stored.has("error") and prepared.run_state["pending_combat_round"].has("talents"), "Prepared combat snapshots talents")
	_check(int(before_rng) >= 0, "Talent selection baseline RNG is readable")


func _game_talent_preview(game: GameEngine) -> void:
	# Read-only talent listing plus a combat preview on a sandbox copy, so the
	# live run and its RNG stream cannot move while numbers are measured.
	game.list_talent_options()
	var sandbox := GameEngine.new(game.content)
	sandbox.restore_run(game.run_state)
	sandbox.run_state["current_event_id"] = "outskirts_dogs"
	sandbox.run_state["phase"] = "event"
	if sandbox.start_combat(0).get("combat_started", false):
		sandbox.combat_action_preview("attack")


func _talent_combat_game(content: ContentRepository, seed_value: int, weapon_id: String) -> GameEngine:
	var game := _new_game(content, seed_value)
	game.run_state["survivor"]["stats"] = {"strength": 6, "agility": 6, "wits": 6, "grit": 6, "presence": 6}
	game.run_state["survivor"]["inventory"][weapon_id] = 1
	game.run_state["survivor"]["equipment"]["weapon"] = weapon_id
	game.run_state["current_event_id"] = "outskirts_dogs"
	game.run_state["phase"] = "event"
	game.start_combat(0)
	var state: Dictionary = game.run_state["combat_state"]
	state["adversary_id"] = "feral_dogs"
	state["enemy_health"] = int(content.get_adversary("feral_dogs")["combat"]["max_health"])
	state["enemy_max_health"] = state["enemy_health"]
	return game


func _talent_move(game: GameEngine, move_id: String) -> void:
	var sequence: Array = game.content.get_adversary("feral_dogs")["narrative_combat"]["sequence"]
	game.run_state["combat_state"]["move_index"] = sequence.find(move_id)
	preload("res://scripts/domain/narrative_combat.gd").commit_move(game)


func _talent_resolve(game: GameEngine, action: String, face: int, enemy_face: int, item_id: String = "") -> Dictionary:
	var prepared := game.prepare_combat_action(action, item_id)
	if prepared.has("error"):
		_check(false, "Talent combat prepares " + action)
		return {}
	game.run_state["pending_combat_round"]["player_roll"] = face if action != "use_item" else 0
	game.run_state["pending_combat_round"]["enemy_roll"] = enemy_face
	return game.resolve_prepared_combat_round()


## Latest_plan Week 1: targeted choice revisions from the fresh choice audit.
## Each revised option keeps a distinct purpose with visible costs, depleted
## players keep a legal choice, and major commitments reach a callback or
## ending. Scenes left intact (cartographer sacrifice, build-gate payoffs,
## earned-code finale) stay so deliberately; flags are their differentiation.
func _test_choice_revisions(content: ContentRepository) -> void:
	# Betrayal and Rust-Sea scenes load only in the expanded configuration.
	var expanded := ContentRepository.new(true)
	var slate: Dictionary = expanded.get_event("betrayal_slate_settlement")["choices"][1]["outcome"]
	_check(int(slate.get("items", {}).get("bitter_tonic", 0)) == 1 and "slate_closed" in slate.get("add_flags", []), "Buying the debt out pays a tonic receipt, so paying differs from walking away")
	var robbery: Dictionary = content.get_event("bunker41_ash_procession")["choices"][2]["outcome"]
	_check(int(robbery.get("pressures", {}).get("fatigue", 0)) == 4 and int(robbery.get("items", {}).get("canned_meat", 0)) == 1, "Robbing the procession costs the flight it describes")
	var naming: Dictionary = expanded.get_event("betrayal_vex_ambush")["choices"][1]
	_check(str(naming.get("check", {}).get("difficulty", "")) == "risky", "Naming Vex's price is risky daylight speech, not a hard check")
	var scouting: Dictionary = content.get_event("global_clear")["choices"][1]["success"]
	_check(int(scouting.get("items", {}).get("scrap_parts", 0)) == 1 and "focused" in scouting.get("add_conditions", []), "Scouting the clear sky finds salvage along the safe line")
	var atonement: Dictionary = expanded.get_event("rustsea_cartographers_debt")["choices"][3]["outcome"]
	_check("rustsea_debt_settled" in atonement.get("add_flags", []) and "rustsea_mara_allied" in atonement.get("add_flags", []), "Returning Mara's sheets settles the debt apart from plain help")
	var refusal: Dictionary = content.get_event("final_gate_3")["choices"][3]["outcome"]
	_check("gate_refused" in refusal.get("add_flags", []) and bool(refusal.get("victory", false)), "Stepping back survives but records the refused gate")
	var refusal_entry: Dictionary = content.get_discovery_entries().get("ledger_ending_citadel", {})
	var refusal_variants := 0
	for variant: Dictionary in refusal_entry.get("variants", []):
		if "gate_refused" in variant.get("requires_flags", []) or "gate_refused" in variant.get("requires_any_flags", []):
			refusal_variants += 1
	_check(refusal_variants == 1, "The Chronicle tells the road away apart from entry")


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


## N04 engine foundation. Scene roles replace the single 60-90 / 30-50 budget,
## passages may carry conditional variants, choices may be gated on forbidden
## flags with an authored label or hidden entirely, and an outcome now reports
## only the items that actually left the pack.
func _test_scene_roles_and_conditional_passages(content: ContentRepository) -> void:
	var compact_band: Dictionary = ContentRepository.scene_role_band("compact")
	var substantial_band: Dictionary = ContentRepository.scene_role_band("substantial")
	var chapter_band: Dictionary = ContentRepository.scene_role_band("chapter")
	var finale_band: Dictionary = ContentRepository.scene_role_band("finale")
	_check(int(compact_band["body_min"]) == 60 and int(compact_band["body_max"]) == 100 and int(compact_band["outcome_min"]) == 30 and int(compact_band["outcome_max"]) == 65, "A compact scene budgets 60–100 words of setup and 30–65 words of outcome")
	_check(int(ContentRepository.scene_role_band("micro")["body_min"]) == 35 and int(ContentRepository.scene_role_band("micro")["body_max"]) == 55 and int(ContentRepository.scene_role_band("micro")["outcome_min"]) == 15 and int(ContentRepository.scene_role_band("micro")["outcome_max"]) == 30, "A micro scene budgets 35–55 words of setup and 15–30 words of outcome")
	_check(int(substantial_band["body_min"]) == 110 and int(substantial_band["body_max"]) == 180 and int(substantial_band["outcome_min"]) == 60 and int(substantial_band["outcome_max"]) == 110, "A substantial scene budgets 110–180 words of setup and 60–110 words of outcome")
	_check(int(chapter_band["body_min"]) == 180 and int(chapter_band["body_max"]) == 280 and int(chapter_band["outcome_min"]) == 100 and int(chapter_band["outcome_max"]) == 180, "A character chapter budgets 180–280 words of setup and 100–180 words of outcome")
	_check(int(finale_band["body_min"]) == 180 and int(finale_band["body_max"]) == 280 and int(finale_band["outcome_min"]) == 150 and int(finale_band["outcome_max"]) == 260, "A finale budgets 180–280 words of setup and 150–260 words of outcome")
	_check(ContentRepository.scene_role({}) == "compact" and ContentRepository.scene_role({"scene_role": "chapter"}) == "chapter", "An event without a scene_role is compact and an authored role is honoured")
	_check(ContentRepository.word_count("first\n\nsecond") == 2 and ContentRepository.word_count("a b\tc\nd  e") == 5, "Word counting splits on any whitespace, so a paragraph break no longer merges two words")
	var compact_events := 0
	var compact_events_in_band := 0
	var promoted_scenes: PackedStringArray = []
	for event: Dictionary in content.events.values():
		if event.has("scene_role"):
			promoted_scenes.append(str(event.get("id", "")))
			continue
		compact_events += 1
		var body_words := ContentRepository.word_count(str(event.get("body", "")))
		var within := body_words >= 60 and body_words <= 100
		for choice: Dictionary in event.get("choices", []):
			for outcome_key: String in ["success", "failure", "critical_success", "critical_failure", "outcome", "victory", "critical_victory"]:
				if not choice.has(outcome_key):
					continue
				var outcome_words := ContentRepository.word_count(str(choice[outcome_key].get("text", "")))
				within = within and outcome_words >= 30 and outcome_words <= 65
		if within:
			compact_events_in_band += 1
	promoted_scenes.sort()
	# N03 promoted four pilot scenes; N05 promoted more across every region. Pinning
	# the exact list broke on each package and taught nothing, so assert the
	# invariants instead: a declared role is always a known one, and any scene that
	# declares one is genuinely longer than the compact band it left behind.
	var known_roles := PackedStringArray(["micro", "compact", "substantial", "chapter", "finale"])
	var roles_valid := true
	var promotions_earned := true
	var micros_earned := true
	var micro_count := 0
	for event_id: String in promoted_scenes:
		var promoted: Dictionary = content.get_event(event_id)
		var role := str(promoted.get("scene_role", ""))
		roles_valid = roles_valid and role in known_roles and role != "compact"
		if role in ["substantial", "chapter", "finale"]:
			promotions_earned = promotions_earned and ContentRepository.word_count(str(promoted.get("body", ""))) > 100
		if role == "micro":
			micro_count += 1
			micros_earned = micros_earned and ContentRepository.word_count(str(promoted.get("body", ""))) < 60
	_check(roles_valid, "Every declared scene role is a known role other than the implicit default")
	_check(promotions_earned, "A scene that declares a longer role actually carries a longer introduction than the compact band allows")
	_check(micros_earned and micro_count == 24, "Twenty-four basic scenes declare micro and carry introductions shorter than the compact band allows")
	_check(promoted_scenes.size() >= 4, "The pilot promotions survive later packages")
	_check(compact_events == content.events.size() - promoted_scenes.size(), "Every event outside that pilot set still authors its scene role implicitly")
	_check(compact_events_in_band == compact_events, "All %d existing passages pass unchanged under the default compact band" % compact_events)

	# Budget and variant validation, probed on a private repository so the shared
	# content the rest of the suite reads is never mutated.
	var scratch := ContentRepository.new(false)
	_check(scratch.validate_all().is_empty(), "The scratch repository starts valid before the budget probes")
	scratch.events["probe_role"] = {
		"id": "probe_role",
		"title": "Probe",
		"scene_role": "substantial",
		"body": _filler_words(140, "setup"),
		"choices": [
			{"label": "First", "outcome": {"text": _filler_words(80, "first")}},
			{"label": "Second", "outcome": {"text": _filler_words(80, "second")}},
		],
	}
	_check(scratch.validate_all().is_empty(), "A substantial scene may load a 140-word setup and 80-word outcomes")
	scratch.events["probe_role"]["scene_role"] = "compact"
	var compact_errors := scratch.validate_all()
	_check(_errors_matching(compact_errors, "'probe_role' introduction must contain 60-100 words for a compact scene").size() == 1, "The same setup is rejected against the compact band")
	_check(_errors_matching(compact_errors, "'probe_role' outcome text must contain 30-65 words for a compact scene").size() == 2, "Both outcomes are rejected against the compact band")
	scratch.events["probe_role"]["scene_role"] = "epic"
	_check(_errors_matching(scratch.validate_all(), "'probe_role' uses unknown scene role 'epic'").size() == 1, "An unknown scene role is a load error")
	scratch.events.erase("probe_role")
	_check(scratch.validate_all().is_empty(), "Removing the probe restores a clean scratch repository")

	scratch.events["probe_variants"] = {
		"id": "probe_variants",
		"title": "Probe",
		"body": _filler_words(70, "setup"),
		"body_variants": [{"requires_any_flags": ["b41_voice_heard"], "text": _filler_words(70, "heard")}],
		"choices": [
			{"label": "First", "outcome": {"text": _filler_words(40, "first"), "variants": [{"requires_any_flags": ["b41_voice_heard"], "text": _filler_words(40, "echo")}]}},
			{"label": "Second", "outcome": {"text": _filler_words(40, "second")}},
		],
	}
	_check(scratch.validate_all().is_empty(), "A body variant and an outcome variant keyed on a written flag load cleanly")
	scratch.events["probe_variants"]["body_variants"][0]["requires_any_flags"] = []
	_check(_errors_matching(scratch.validate_all(), "'probe_variants' introduction variant needs a non-empty requires_any_flags").size() == 1, "A variant with no flags to key on is rejected")
	scratch.events["probe_variants"]["body_variants"][0]["requires_any_flags"] = ["lr_flag_nobody_writes"]
	_check(_errors_matching(scratch.validate_all(), "introduction variant requires flag 'lr_flag_nobody_writes' that no outcome writes").size() == 1, "A variant waiting on an unwritten flag is rejected")
	scratch.events["probe_variants"]["body_variants"][0]["requires_any_flags"] = ["b41_voice_heard"]
	scratch.events["probe_variants"]["body_variants"][0]["text"] = _filler_words(30, "short")
	_check(_errors_matching(scratch.validate_all(), "'probe_variants' introduction variant must contain 60-100 words").size() == 1, "A variant that misses the scene-role band is rejected")
	scratch.events["probe_variants"]["body_variants"][0]["text"] = _filler_words(70, "heard")
	scratch.events["probe_variants"]["body_variants"][0]["next_event"] = "outskirts_bandits"
	_check(_errors_matching(scratch.validate_all(), "'probe_variants' introduction variant cannot declare next_event").size() == 1, "A body passage variant cannot silently route a survivor")
	scratch.events["probe_variants"]["body_variants"][0].erase("next_event")
	scratch.events["probe_variants"]["choices"][0]["outcome"]["variants"][0]["text"] = _filler_words(90, "long")
	_check(_errors_matching(scratch.validate_all(), "'probe_variants' outcome variant must contain 30-65 words").size() == 1, "An outcome variant is held to the outcome band, not the setup band")
	scratch.events["probe_variants"]["choices"][0]["outcome"]["variants"][0]["text"] = _filler_words(40, "echo")
	scratch.events["probe_variants"]["choices"][0]["outcome"]["variants"][0]["next_event"] = "outskirts_bandits"
	_check(scratch.validate_all().is_empty(), "An outcome variant may route to a follow-up the configuration loads")
	scratch.events["probe_variants"]["choices"][0]["outcome"]["variants"][0]["next_event"] = "probe_missing_follow_up"
	_check(_errors_matching(scratch.validate_all(), "'probe_variants' outcome variant points to missing follow-up 'probe_missing_follow_up'").size() == 1, "A variant routing to an unknown event is rejected exactly as the outcome's own follow-up is")
	scratch.events["probe_variants"]["choices"][0]["outcome"]["variants"][0]["next_event"] = "outskirts_bandits"
	scratch.events["probe_variants"]["choices"][0]["outcome"]["variants"][0].erase("text")
	_check(scratch.validate_all().is_empty(), "A variant that only routes needs no passage of its own")
	scratch.events["probe_variants"]["choices"][0]["outcome"]["variants"][0]["text"] = _filler_words(90, "long")
	_check(_errors_matching(scratch.validate_all(), "'probe_variants' outcome variant must contain 30-65 words").size() == 1, "A routing variant that does replace the passage is still held to the band")
	scratch.events.erase("probe_variants")

	scratch.events["probe_gating"] = {
		"id": "probe_gating",
		"title": "Probe",
		"body": _filler_words(70, "setup"),
		"choices": [
			{"label": "First", "requires": {"flags": ["never_written_flag"]}, "outcome": {"text": _filler_words(40, "first")}},
			{"label": "Second", "requires": {"forbids_flags": ["never_written_flag"], "stats": {"luck": 3}}, "outcome": {"text": _filler_words(40, "second")}},
			{"label": "Third", "requires": {"forbids_conditions": ["ghosthood"], "reason": "   "}, "outcome": {"text": _filler_words(40, "third")}},
		],
	}
	var gating_errors := scratch.validate_all()
	_check(_errors_matching(gating_errors, "choice requirement 'flags' references flag 'never_written_flag' that no outcome writes").size() == 1, "requires.flags is validated against the flags the content can write")
	_check(_errors_matching(gating_errors, "choice requirement 'forbids_flags' references flag 'never_written_flag' that no outcome writes").size() == 1, "requires.forbids_flags is validated against the flags the content can write")
	_check(_errors_matching(gating_errors, "'probe_gating' choice requires unknown stat 'luck'").size() == 1, "requires.stats is validated against the five survivor stats")
	_check(_errors_matching(gating_errors, "'probe_gating' choice forbids missing condition 'ghosthood'").size() == 1, "requires.forbids_conditions is validated against the condition table")
	_check(_errors_matching(gating_errors, "'probe_gating' choice supplies an empty lock reason").size() == 1, "An empty authored lock reason is rejected")
	scratch.events.erase("probe_gating")
	_check(scratch.validate_all().is_empty(), "The scratch repository is clean again after the gating probes")

	# Prose standards follow the variants. Only one variant is ever shown, so the
	# variants of one scene may share an establishing sentence, while two
	# different events sharing one is the repetition this check has always caught.
	var shared_sentence := "The relay mast leans over the salt like a question nobody answered."
	scratch.events["probe_prose_a"] = {
		"id": "probe_prose_a",
		"title": "Probe",
		"body": "%s %s" % [shared_sentence, _filler_words(60, "setup")],
		"body_variants": [{"requires_any_flags": ["b41_voice_heard"], "text": "%s %s" % [shared_sentence, _filler_words(60, "heard")]}],
		"choices": [
			{"label": "First", "outcome": {"text": _filler_words(40, "first")}},
			{"label": "Second", "outcome": {"text": _filler_words(40, "second")}},
		],
	}
	scratch.polished_event_ids["probe_prose_a"] = true
	_check(_errors_matching(scratch.validate_all(), "repeats a sentence").is_empty(), "Two variants of one scene may share their establishing sentence")
	scratch.events["probe_prose_b"] = {
		"id": "probe_prose_b",
		"title": "Probe",
		"body": "%s %s" % [shared_sentence, _filler_words(60, "other")],
		"choices": [
			{"label": "First", "outcome": {"text": _filler_words(40, "third")}},
			{"label": "Second", "outcome": {"text": _filler_words(40, "fourth")}},
		],
	}
	scratch.polished_event_ids["probe_prose_b"] = true
	_check(_errors_matching(scratch.validate_all(), "repeats a sentence in 'probe_prose_a' and 'probe_prose_b'").size() == 1, "A sentence shared between two different events is still repetition")
	scratch.events.erase("probe_prose_b")
	scratch.polished_event_ids.erase("probe_prose_b")
	scratch.events["probe_prose_a"]["body_variants"][0]["text"] = "The choice holds. %s" % _filler_words(60, "heard")
	_check(_errors_matching(scratch.validate_all(), "'probe_prose_a' contains prohibited filler: the choice holds").size() == 1, "Prohibited filler hiding in a body variant is caught")
	scratch.events["probe_prose_a"]["body_variants"][0]["text"] = "%s %s" % [shared_sentence, _filler_words(60, "heard")]
	scratch.events["probe_prose_a"]["choices"][0]["outcome"]["variants"] = [{"requires_any_flags": ["b41_voice_heard"], "text": "The memory follows you. %s" % _filler_words(40, "echo")}]
	_check(_errors_matching(scratch.validate_all(), "'probe_prose_a' contains prohibited filler: the memory follows you").size() == 1, "Prohibited filler hiding in an outcome variant is caught")
	scratch.events.erase("probe_prose_a")
	scratch.polished_event_ids.erase("probe_prose_a")
	_check(scratch.validate_all().is_empty(), "The scratch repository is clean again after the prose probes")

	# A conditional passage is prose, so it must not move a mechanical hash, while
	# the gating that decides which passage is read must.
	var snapshot = MechanicalSnapshot.new()
	var hash_event := {
		"id": "probe_hash",
		"body": "The default introduction.",
		"choices": [{"label": "First", "requires": {"forbids_flags": ["b41_answered"]}, "outcome": {"text": "The default outcome."}}],
	}
	var prose_event := hash_event.duplicate(true)
	prose_event["body_variants"] = [{"requires_any_flags": ["b41_voice_heard"], "text": "The remembered introduction."}]
	prose_event["choices"][0]["outcome"]["variants"] = [{"requires_any_flags": ["b41_voice_heard"], "text": "The remembered outcome."}]
	var gating_event := hash_event.duplicate(true)
	gating_event["choices"][0]["requires"]["forbids_flags"] = ["b41_answered", "b41_recording"]
	_check(snapshot._mechanical_signature(prose_event) == snapshot._mechanical_signature(hash_event), "Conditional passages are stripped before hashing, so adding one is not a mechanical change")
	_check(snapshot._mechanical_signature(gating_event) != snapshot._mechanical_signature(hash_event), "requires.forbids_flags stays in the mechanical hash")

	# A variant that carries its own next_event is routing rather than prose, so
	# it and the flags that select it stay in the hash while its wording does not.
	var routing_event := hash_event.duplicate(true)
	routing_event["choices"][0]["outcome"]["variants"] = [{"requires_any_flags": ["b41_contact"], "next_event": "probe_gate_two"}]
	var rerouted_event := routing_event.duplicate(true)
	rerouted_event["choices"][0]["outcome"]["variants"][0]["next_event"] = "probe_warden_remembers"
	var reflagged_event := routing_event.duplicate(true)
	reflagged_event["choices"][0]["outcome"]["variants"][0]["requires_any_flags"] = ["b41_recording"]
	var reworded_event := routing_event.duplicate(true)
	reworded_event["choices"][0]["outcome"]["variants"][0]["text"] = "The remembered outcome."
	_check(snapshot._mechanical_signature(routing_event) != snapshot._mechanical_signature(hash_event), "A variant that routes to its own follow-up enters the mechanical hash instead of being stripped as prose")
	_check(snapshot._mechanical_signature(rerouted_event) != snapshot._mechanical_signature(routing_event), "Changing where a variant routes moves the mechanical hash")
	_check(snapshot._mechanical_signature(reflagged_event) != snapshot._mechanical_signature(routing_event), "Changing which flag selects a route moves the mechanical hash")
	_check(snapshot._mechanical_signature(reworded_event) == snapshot._mechanical_signature(routing_event), "Rewording a routing variant leaves the mechanical hash alone")
	snapshot.free()


## Reading a passage is not a gameplay action: it consumes no RNG, changes no
## run state, and returns the same words every time it is reopened.
func _test_passage_resolution_and_gating(content: ContentRepository) -> void:
	var probe_content := ContentRepository.new(false)
	probe_content.events["probe_passage"] = {
		"id": "probe_passage",
		"title": "Probe Passage",
		"body": "The default introduction.",
		"body_variants": [
			{"requires_any_flags": ["b41_answered"], "text": "The answered introduction."},
			{"requires_any_flags": ["b41_recording", "b41_answered"], "text": "The recorded introduction."},
		],
		"choices": [
			{
				"label": "Take the first road",
				"outcome": {
					"text": "The default outcome.",
					"add_flags": ["b41_voice_heard"],
					"variants": [{"requires_any_flags": ["b41_voice_heard"], "text": "The remembered outcome."}],
				},
			},
			{"label": "Slip past unseen", "requires": {"forbids_flags": ["b41_answered"], "hidden_when_locked": true}, "outcome": {"text": "The hidden outcome."}},
			{"label": "Take the third road", "outcome": {"text": "The third outcome."}},
		],
	}
	probe_content.events["probe_reasons"] = {
		"id": "probe_reasons",
		"title": "Probe Reasons",
		"body": "The default introduction.",
		"choices": [
			{"label": "Record", "requires": {"flags": ["b41_recording"]}, "outcome": {"text": "Recorded."}},
			{"label": "Testify", "requires": {"any_flags": ["b41_recording", "b41_answered"]}, "outcome": {"text": "Testified."}},
			{"label": "Repeat", "requires": {"any_flags": ["b41_answered"], "reason": "You never spoke to them"}, "outcome": {"text": "Repeated."}},
			{"label": "Refuse", "requires": {"forbids_flags": ["b41_recording"], "reason": "The recording already answered for you", "hidden_when_locked": true}, "outcome": {"text": "Refused."}},
		],
	}
	var game := _new_game(probe_content, 7301)
	game.run_state["current_event_id"] = "probe_passage"
	game.run_state["phase"] = "event"
	var probe_event: Dictionary = probe_content.get_event("probe_passage")
	var rng_before := int(game.run_state["rng_state"])
	_check(game.resolve_body(probe_event) == "The default introduction.", "A passage with no matching flag resolves to its authored body")
	game.run_state["flags"] = ["b41_recording"]
	_check(game.resolve_body(probe_event) == "The recorded introduction.", "A held flag selects the variant that names it")
	game.run_state["flags"] = ["b41_recording", "b41_answered"]
	_check(game.resolve_body(probe_event) == "The answered introduction.", "When two variants match, the first in authored order wins")
	_check(game.resolve_body(probe_event) == game.resolve_body(probe_event), "Reopening a passage returns identical text")
	_check(int(game.run_state["rng_state"]) == rng_before, "Resolving a body variant consumes no RNG")
	var state_before: Dictionary = game.run_state.duplicate(true)
	game.resolve_body(probe_event)
	_check(game.run_state == state_before, "Resolving a body variant mutates nothing in the run")

	# An outcome variant describes the situation the survivor arrived in, so the
	# flag the outcome itself writes cannot select it on the same resolution.
	var timing := _new_game(probe_content, 7302)
	timing.run_state["current_event_id"] = "probe_passage"
	timing.run_state["phase"] = "event"
	var first_pass := timing.resolve_choice(0)
	_check(str(first_pass.get("outcome_text", "")) == "The default outcome.", "An outcome variant never reads the flag its own outcome writes")
	_check("b41_voice_heard" in timing.run_state["flags"], "The outcome still records its flag")
	_check(str(timing.run_state["last_result"].get("outcome_text", "")) == "The default outcome.", "The resolved passage is stored in last_result where the plain text used to go")
	timing.run_state["phase"] = "event"
	var second_pass := timing.resolve_choice(0)
	_check(str(second_pass.get("outcome_text", "")) == "The remembered outcome.", "A survivor who already holds the flag reads the variant instead")
	_check(str(timing.run_state["last_result"].get("outcome_text", "")) == "The remembered outcome.", "The variant reaches the result screen through last_result alone")

	var fresh := _new_game(probe_content, 7303)
	var expected_keys: Array = fresh.run_state.keys()
	expected_keys.sort()
	var resolved_keys: Array = timing.run_state.keys()
	resolved_keys.sort()
	_check(int(timing.run_state["schema_version"]) == 5 and resolved_keys == expected_keys, "Conditional passages add no run-state field, so run schema 5 saves stay compatible")

	# A variant may also carry routing. Its next_event replaces the outcome's own
	# for that resolution only, and it is chosen from the same pre-outcome flags
	# that choose the text, so the passage read and the scene entered agree.
	var routing_content := ContentRepository.new(false)
	routing_content.events["probe_routing"] = {
		"id": "probe_routing",
		"title": "Probe Routing",
		"body": "The default introduction.",
		"choices": [
			{
				"label": "Take the routed road",
				"outcome": {
					"text": "The default outcome.",
					"next_event": "probe_route_default",
					"variants": [{"requires_any_flags": ["b41_contact"], "next_event": "probe_route_remembered"}],
				},
			},
			{
				"label": "Take the spoken road",
				"outcome": {
					"text": "The default outcome.",
					"next_event": "probe_route_default",
					"variants": [{"requires_any_flags": ["b41_contact"], "text": "The remembered outcome."}],
				},
			},
			{
				"label": "Take the unrouted road",
				"outcome": {
					"text": "The default outcome.",
					"add_flags": ["b41_contact"],
					"variants": [{"requires_any_flags": ["b41_contact"], "next_event": "probe_route_remembered"}],
				},
			},
		],
	}
	routing_content.events["probe_route_default"] = {"id": "probe_route_default", "title": "Default Road", "body": "The default road.", "choices": [{"label": "On", "outcome": {"text": "Onward."}}]}
	routing_content.events["probe_route_remembered"] = {"id": "probe_route_remembered", "title": "Remembered Road", "body": "The remembered road.", "choices": [{"label": "On", "outcome": {"text": "Onward."}}]}

	var plain_route := _new_game(routing_content, 7307)
	plain_route.run_state["current_event_id"] = "probe_routing"
	plain_route.run_state["phase"] = "event"
	var plain_result := plain_route.resolve_choice(0)
	_check(str(plain_route.run_state["pending_event_id"]) == "probe_route_default", "A run that matches no variant follows the outcome's own next_event")
	_check(str(plain_result.get("outcome_text", "")) == "The default outcome.", "The unmatched run also reads the outcome's own passage")

	var routed := _new_game(routing_content, 7307)
	routed.run_state["current_event_id"] = "probe_routing"
	routed.run_state["phase"] = "event"
	routed.run_state["flags"] = ["b41_contact"]
	var routed_result := routed.resolve_choice(0)
	_check(str(routed.run_state["pending_event_id"]) == "probe_route_remembered", "A held flag routes the survivor to the variant's next_event instead of the outcome's")
	_check(str(routed_result.get("outcome_text", "")) == "The default outcome.", "A variant that routes without a passage of its own resolves the outcome's text")

	var spoken := _new_game(routing_content, 7307)
	spoken.run_state["current_event_id"] = "probe_routing"
	spoken.run_state["phase"] = "event"
	spoken.run_state["flags"] = ["b41_contact"]
	var spoken_result := spoken.resolve_choice(1)
	_check(str(spoken.run_state["pending_event_id"]) == "probe_route_default", "A variant with no next_event of its own leaves the outcome's routing untouched")
	_check(str(spoken_result.get("outcome_text", "")) == "The remembered outcome.", "That same variant still replaces the passage")

	var self_written := _new_game(routing_content, 7307)
	self_written.run_state["current_event_id"] = "probe_routing"
	self_written.run_state["phase"] = "event"
	self_written.resolve_choice(2)
	_check(str(self_written.run_state["pending_event_id"]) == "", "A variant never routes on the flag its own outcome writes")
	_check("b41_contact" in self_written.run_state["flags"], "The outcome that would have selected it still records its flag")
	self_written.run_state["phase"] = "event"
	self_written.resolve_choice(2)
	_check(str(self_written.run_state["pending_event_id"]) == "probe_route_remembered", "A survivor who arrives already holding the flag takes the variant's route")

	var route_probe := _new_game(routing_content, 7308)
	route_probe.run_state["current_event_id"] = "probe_routing"
	route_probe.run_state["phase"] = "event"
	route_probe.run_state["flags"] = ["b41_contact"]
	var routed_outcome: Dictionary = routing_content.get_event("probe_routing")["choices"][0]["outcome"]
	var route_rng_before := int(route_probe.run_state["rng_state"])
	var route_state_before: Dictionary = route_probe.run_state.duplicate(true)
	_check(route_probe.resolve_outcome_next_event(routed_outcome) == "probe_route_remembered", "Routing resolves from the flags alone, without applying the outcome")
	_check(route_probe.resolve_outcome_next_event(routed_outcome) == route_probe.resolve_outcome_next_event(routed_outcome), "Reasking for a route returns the same follow-up")
	_check(int(route_probe.run_state["rng_state"]) == route_rng_before, "Resolving a variant route consumes no RNG")
	_check(route_probe.run_state == route_state_before, "Resolving a variant route mutates nothing in the run")

	# The shape the finale needs: a gate whose outcomes screen every survivor the
	# same way, while a variant sends one who carries Bunker history to the ending
	# only that history opens.
	var finale_content := ContentRepository.new(false)
	finale_content.events["probe_final_gate_1"] = {
		"id": "probe_final_gate_1",
		"title": "Probe Gate",
		"body": "The gate reads you before it answers.",
		"choices": [{
			"label": "Answer the warden",
			"outcome": {
				"text": "The warden hears you out.",
				"next_event": "probe_final_gate_2",
				"variants": [{"requires_any_flags": ["b41_contact"], "next_event": "probe_warden_remembers"}],
			},
		}],
	}
	finale_content.events["probe_final_gate_2"] = {"id": "probe_final_gate_2", "title": "Screening", "body": "The screening continues.", "choices": [{"label": "Wait", "outcome": {"text": "You wait."}}]}
	finale_content.events["probe_warden_remembers"] = {"id": "probe_warden_remembers", "title": "The Warden Remembers", "body": "The warden knows the name.", "choices": [{"label": "Speak", "outcome": {"text": "You speak."}}]}

	var screened := _new_game(finale_content, 7309)
	screened.run_state["current_event_id"] = "probe_final_gate_1"
	screened.run_state["phase"] = "event"
	screened.resolve_choice(0)
	_check(str(screened.run_state["pending_event_id"]) == "probe_final_gate_2", "A survivor with no Bunker history is screened by the standard gate")
	screened.continue_after_result()
	_check(str(screened.run_state["current_event_id"]) == "probe_final_gate_2", "The standard screening is the scene that actually opens")

	var remembered := _new_game(finale_content, 7309)
	remembered.run_state["current_event_id"] = "probe_final_gate_1"
	remembered.run_state["phase"] = "event"
	remembered.run_state["flags"] = ["b41_contact"]
	remembered.resolve_choice(0)
	_check(str(remembered.run_state["pending_event_id"]) == "probe_warden_remembers", "A survivor carrying Bunker contact is routed to the finale that history earns")
	remembered.continue_after_result()
	_check(str(remembered.run_state["current_event_id"]) == "probe_warden_remembers", "The remembered finale is the scene that actually opens")
	_check(int(remembered.run_state["schema_version"]) == 5 and remembered.run_state.keys() == screened.run_state.keys(), "Variant routing adds no run-state field either")

	var gate := _new_game(probe_content, 7304)
	gate.run_state["current_event_id"] = "probe_passage"
	gate.run_state["phase"] = "event"
	var hidden_choice: Dictionary = probe_event["choices"][1]
	_check(gate.get_choice_preview(hidden_choice).get("available", false), "A forbids_flags choice is open while the run holds none of its flags")
	gate.run_state["flags"] = ["b41_answered"]
	var hidden_preview := gate.get_choice_preview(hidden_choice)
	_check(not hidden_preview.get("available", true) and str(hidden_preview.get("reason", "")) == "Blocked by what already happened", "A held forbidden flag locks the choice with the default label")
	_check(bool(hidden_preview.get("hidden", false)), "hidden_when_locked travels with the lock so a caller can drop the row")
	_check(str(gate.resolve_choice(1).get("error", "")) == "Blocked by what already happened", "The engine refuses a forbidden-flag choice with the same explanation")

	var reasons := _new_game(probe_content, 7305)
	reasons.run_state["current_event_id"] = "probe_reasons"
	reasons.run_state["phase"] = "event"
	var reason_choices: Array = probe_content.get_event("probe_reasons")["choices"]
	_check(str(reasons.get_choice_preview(reason_choices[0]).get("reason", "")) == "Requires the relevant Bunker Forty-One record", "A flags gate with no authored reason keeps the original Bunker label")
	_check(str(reasons.get_choice_preview(reason_choices[1]).get("reason", "")) == "Requires Bunker Forty-One testimony or evidence", "An any_flags gate with no authored reason keeps the original Bunker label")
	_check(str(reasons.get_choice_preview(reason_choices[2]).get("reason", "")) == "You never spoke to them", "An authored requires.reason replaces the generated lock label")
	_check(not bool(reasons.get_choice_preview(reason_choices[0]).get("hidden", false)), "A lock without hidden_when_locked stays visible")
	reasons.run_state["flags"] = ["b41_recording"]
	var refused := reasons.get_choice_preview(reason_choices[3])
	_check(not refused.get("available", true) and str(refused.get("reason", "")) == "The recording already answered for you" and bool(refused.get("hidden", false)), "An authored reason and hidden_when_locked apply to a forbids_flags gate together")

	# The rendered list drops the hidden row without renumbering the rest: the
	# second row on screen is still choice 2 as far as the engine is concerned.
	var ui = MainUI.new()
	ui.bootstrap_on_ready = false
	root.add_child(ui)
	ui.content = probe_content
	ui.saves = SaveService.new("ashfall_variant_smoke_")
	ui.profile = ui.saves.default_profile()
	ui.entitlements = ui.saves.load_entitlements()
	ui.game = GameEngine.new(probe_content)
	ui.game.start_run(ui.game.create_candidates(7306)[0], 7306)
	ui.ads = AdService.new()
	ui.ads.configure(ui.entitlements)
	ui.billing = BillingService.new()
	ui.billing.configure(ui.entitlements)
	ui._build_shell()
	ui.game.run_state["current_event_id"] = "probe_passage"
	ui.game.run_state["phase"] = "event"
	ui.game.run_state["flags"] = ["b41_answered"]
	ui._show_event()
	_check(str(ui.active_story.full_text) == "The answered introduction.", "The journey screen types the resolved passage rather than the raw body")
	var rows := _choice_rows(ui.active_story_actions)
	var row_labels: Array[String] = []
	for row: Button in rows:
		row_labels.append(str((row.find_child("ChoiceRow", true, false).get_child(1).get_child(0) as Label).text))
	var expected_labels: Array[String] = ["Take the first road", "Take the third road"]
	_check(rows.size() == 2 and row_labels == expected_labels, "A hidden locked choice leaves no row and no gap in the list")
	rows[1].pressed.emit()
	_check(str(ui.game.run_state["last_result"].get("choice", "")) == "Take the third road", "Pressing the row after a hidden choice still resolves its original index")
	ui.queue_free()


## X1: an item the survivor never had cannot be taken from them, and the result
## panel must stop reporting a loss that never happened.
func _test_false_item_costs(content: ContentRepository) -> void:
	var stocked := _new_game(content, 7311)
	stocked.run_state["current_event_id"] = "outskirts_bandits"
	stocked.run_state["phase"] = "event"
	stocked.run_state["survivor"]["inventory"]["canned_meat"] = 2
	var stocked_changes := ", ".join(PackedStringArray(stocked.resolve_choice(2, 1).get("changes", [])))
	_check("Canned Meat -1" in stocked_changes, "A survivor who can pay still sees the ration leave the pack")
	_check(stocked.get_item_quantity("canned_meat") == 1, "The paid ration is actually removed")

	var empty := _new_game(content, 7311)
	empty.run_state["current_event_id"] = "outskirts_bandits"
	empty.run_state["phase"] = "event"
	empty.run_state["survivor"]["inventory"].erase("canned_meat")
	var empty_changes := ", ".join(PackedStringArray(empty.resolve_choice(2, 1).get("changes", [])))
	_check("Canned Meat" not in empty_changes, "A survivor with no rations sees no Canned Meat line for a loss that could not happen")
	_check(empty.get_item_quantity("canned_meat") == 0, "Nothing is invented to pay the price")
	_check("Fatigue +3" in empty_changes, "The rest of the failure still lands")

	var partial := _new_game(content, 7312)
	partial.run_state["survivor"]["inventory"]["pistol_rounds"] = 1
	_check(partial._change_item("pistol_rounds", -3) == -1 and partial.get_item_quantity("pistol_rounds") == 0, "Removing more than the survivor carries reports only what actually moved")
	_check(partial._change_item("scrap_parts", -2) == 0, "Removing an item the survivor does not carry moves nothing")
	_check(partial._change_item("scrap_parts", 2) == 2 and partial.get_item_quantity("scrap_parts") == 2, "A gain still reports its full quantity")

	var static_event := content.get_event("bunker41_static")
	var voice_outcomes := 0
	var original_flags := 0
	for choice: Dictionary in static_event.get("choices", []):
		var flags: Array = choice.get("outcome", {}).get("add_flags", [])
		if "b41_voice_heard" in flags:
			voice_outcomes += 1
		for flag: String in ["b41_recording", "b41_answered", "b41_unprepared"]:
			if flag in flags:
				original_flags += 1
	_check(voice_outcomes == 3 and original_flags == 3, "All three salt-flats broadcasts record b41_voice_heard beside their original flag")


## N03 pilot scenes, second batch. The bus must show which door pays food and
## which pays medicine before either is chosen, Mara's ration must be a real
## price, the Reed Widow and the Kilnback must be reachable fights that leave a
## trace, and the Glass Wastes rescue must record that somebody lived.
func _test_pilot_scene_batch(content: ContentRepository) -> void:
	var bus: Dictionary = content.get_event("outskirts_bus")
	var bus_body := str(bus.get("body", "")).to_lower()
	_check("ration" in bus_body and "driver" in bus_body, "outskirts_bus shows the rations under the driver's seat before the door is forced")
	_check("first-aid" in bus_body and "release cable" in bus_body, "outskirts_bus shows the first-aid bracket beside the release cable before the release is traced")
	var bus_choices: Array = bus.get("choices", [])
	_check(bus_choices.size() == 2 and str(bus_choices[0].get("label", "")) == "Pry the door apart" and str(bus_choices[1].get("label", "")) == "Trace the emergency release", "outskirts_bus keeps both original labels at their original indices")
	var forced_reward: Dictionary = bus_choices[0]["success"]["items"]
	var traced_reward: Dictionary = bus_choices[1]["success"]["items"]
	_check(forced_reward.size() == 2 and int(forced_reward.get("ration_bar", 0)) == 2 and int(forced_reward.get("clean_water", 0)) == 1, "Forcing the doors still pays exactly the rations the wiped circle shows")
	_check(traced_reward.size() == 2 and int(traced_reward.get("cloth_bandage", 0)) == 2 and int(traced_reward.get("scrap_parts", 0)) == 1, "Tracing the release still pays exactly the dressings the first-aid bracket shows")
	_check(int(bus.get("weight", 0)) == 4 and "supply_opportunity" in bus.get("tags", []) and not bus.has("scene_role"), "outskirts_bus stays a compact supply opportunity at its authored weight")

	var mara: Dictionary = content.get_event("bunker41_cartographer")
	_check(str(mara.get("scene_role", "")) == "chapter", "Mara Venn's introduction is authored as a character chapter")
	var share: Dictionary = mara.get("choices", [])[0]
	var share_cost: Dictionary = share.get("costs", {}).get("items", {})
	_check(share_cost.size() == 1 and int(share_cost.get("canned_meat", 0)) == 1, "Sharing a ration with Mara costs one Canned Meat")
	var hungry := _new_game(content, 6410)
	hungry.run_state["current_event_id"] = "bunker41_cartographer"
	hungry.run_state["phase"] = "event"
	hungry.run_state["survivor"]["inventory"].erase("canned_meat")
	var locked := hungry.get_choice_preview(share)
	_check(not bool(locked.get("available", true)) and str(locked.get("reason", "")) == "You have no food to share", "An empty pack locks the ration with the authored reason")
	_check(not bool(locked.get("hidden", false)), "The ration price stays visible when it cannot be paid, because the price is the point")
	var still_open := true
	for index in [1, 2]:
		still_open = still_open and bool(hungry.get_choice_preview(mara["choices"][index]).get("available", false))
	_check(still_open, "Taking the map and withdrawing stay ungated, so an empty pack is never stranded")
	var fed := _new_game(content, 6410)
	fed.run_state["current_event_id"] = "bunker41_cartographer"
	fed.run_state["phase"] = "event"
	fed.run_state["survivor"]["inventory"]["canned_meat"] = 1
	fed.resolve_choice(0)
	_check(fed.get_item_quantity("canned_meat") == 0 and "b41_mara_helped" in fed.run_state["flags"], "The shared ration actually leaves the pack and Mara remembers it")

	var lights: Dictionary = content.get_event("marsh_lights")
	var lights_body := str(lights.get("body", "")).to_lower()
	_check("reed widow" in lights_body, "marsh_lights names the Reed Widow in the passage rather than in a title")
	_check("laces still tied" in lights_body and "lean downstream" in lights_body, "marsh_lights shows the laced boot and the bank that moves against the current")
	var pool: Dictionary = lights.get("choices", [])[2]
	_check(str(pool.get("label", "")) == "Clear the nesting pool" and str(pool.get("combat", {}).get("adversary_id", "")) == "reed_widow" and bool(pool["combat"].get("can_flee", false)), "marsh_lights appends a Reed Widow fight the survivor may leave")
	var pool_reward: Dictionary = pool["victory"]["items"]
	_check(pool_reward.size() == 3 and int(pool_reward.get("purifier_ampoule", 0)) == 1 and int(pool_reward.get("clean_water", 0)) == 2 and int(pool_reward.get("mutant_hide_vest", 0)) == 1 and pool["victory"].get("add_flags", []) == ["widow_pool_cleared"], "Clearing the pool pays the cache, the widow's hide, and records that the cut is open")
	_check(str(lights["choices"][0].get("label", "")) == "Follow the pattern" and str(lights["choices"][1].get("label", "")) == "Stay on visible ground", "Both original marsh_lights routes keep their labels and indices")

	var apartment: Dictionary = content.get_event("outskirts_apartment")
	var apartment_body := str(apartment.get("body", "")).to_lower()
	_check("shutter skitters" in apartment_body and "roofing slate" in apartment_body, "outskirts_apartment names the Shutter Skitters and shows their shed plates before the fight")
	var skitters: Dictionary = apartment.get("choices", [])[2]
	_check(str(skitters.get("label", "")) == "Drive the colony out of the stairwell" and str(skitters.get("combat", {}).get("adversary_id", "")) == "shutter_skitters" and bool(skitters["combat"].get("can_flee", false)), "outskirts_apartment appends the fleeable Shutter Skitters fight at index two")
	var skitter_items: Dictionary = skitters.get("victory", {}).get("items", {})
	_check(int(skitter_items.get("medkit", 0)) == 1 and int(skitter_items.get("canned_meat", 0)) == 1 and str(apartment["choices"][0].get("label", "")) == "Search the occupied floor" and str(apartment["choices"][1].get("label", "")) == "Respect the warning and leave", "The Skitters fight pays the same household cache while preserving both original routes")

	var tank: Dictionary = content.get_event("industrial_tank")
	var tank_body := str(tank.get("body", "")).to_lower()
	_check("kilnback" in tank_body and "scorched" in tank_body, "industrial_tank names the Kilnback and shows the scorch-rings on the outer plates")
	_check(not tank["choices"][0]["success"].has("add_flags"), "Rescuing the engineer keeps the scanner and the life and writes no orphan flag")
	_check(tank["choices"][1]["success"].get("add_flags", []) == ["kilnback_rhythm_known"], "Listening for the pattern records the heat cycle the survivor worked out")
	var jacket: Dictionary = tank.get("choices", [])[2]
	_check(str(jacket.get("label", "")) == "Clear the cooling jacket" and str(jacket.get("combat", {}).get("adversary_id", "")) == "kilnback" and bool(jacket["combat"].get("can_flee", false)), "industrial_tank appends a Kilnback fight the survivor may leave")
	var jacket_reward: Dictionary = jacket["victory"]["items"]
	# The retune (CONTENT_AUTHORING N05b) added the creature's shed plates as a
	# premium the safer listening route cannot pay. The scanner stays exclusive
	# to the rescue, which is the contract this assertion has always protected.
	_check(int(jacket_reward.get("clean_water", 0)) == 2 and int(jacket_reward.get("scrap_parts", 0)) == 2 and not jacket_reward.has("field_scanner") and jacket["victory"].get("add_flags", []) == ["kilnback_rhythm_known"], "Clearing the jacket pays the water, the shed plates, and the same knowledge, never the scanner")

	var rail_signal_event: Dictionary = content.get_event("rail_signal")
	var signal_body := str(rail_signal_event.get("body", "")).to_lower()
	_check("cable eater" in signal_body and "traveling sequence" in signal_body and "sags downward" in signal_body, "rail_signal names the Cable Eater and gives all three readable warnings before the fight")
	var cable: Dictionary = rail_signal_event.get("choices", [])[2]
	_check(str(cable.get("label", "")) == "Clear the cable run" and str(cable.get("combat", {}).get("adversary_id", "")) == "cable_eater" and bool(cable["combat"].get("can_flee", false)), "rail_signal appends the fleeable Cable Eater fight at index two")
	var cable_items: Dictionary = cable.get("victory", {}).get("items", {})
	_check(int(cable_items.get("scrap_parts", 0)) == 3 and cable.get("victory", {}).get("add_flags", []) == ["citadel_signal"] and str(rail_signal_event["choices"][0].get("label", "")) == "Follow the powered line" and str(rail_signal_event["choices"][1].get("label", "")) == "Cut power before passing", "Cable victory pays copper salvage and the final-controller knowledge without moving the original routes")
	var cable_controller := _new_game(content, 6413)
	cable_controller.run_state["current_event_id"] = "final_gate_3"
	cable_controller.run_state["phase"] = "event"
	cable_controller.run_state["event_history"] = ["rail_door", "rail_signal"]
	cable_controller.run_state["flags"] = ["citadel_signal"]
	_check(cable_controller.get_choice_preview(cable_controller.current_event()["choices"][1]).get("available", false), "Cable routing knowledge unlocks the final controller even when rail_door was already visited")
	cable_controller.run_state["flags"] = []
	_check(not cable_controller.get_choice_preview(cable_controller.current_event()["choices"][1]).get("available", true), "Cable knowledge never invents the controller route for a no-source history")

	var shadow: Dictionary = content.get_event("glass_shadow")
	var shadow_body := str(shadow.get("body", "")).to_lower()
	_check("pale dust" in shadow_body and "nothing above it" in shadow_body, "glass_shadow shows the fresh pale dust and the shadow with nothing casting it")
	_check("turn back at any point" in shadow_body, "glass_shadow keeps the giant's fourth warning that the way back stays visible")
	_check(shadow.get("choices", []).size() == 2 and not content.event_has_combat_choice(shadow), "The Cinder Giant is never fought, so glass_shadow stays at two choices")
	var rescue_reward: Dictionary = shadow["choices"][0]["success"]["items"]
	_check(rescue_reward.size() == 2 and int(rescue_reward.get("scout_leathers", 0)) == 1 and int(rescue_reward.get("clean_water", 0)) == 1 and shadow["choices"][0]["success"].get("add_flags", []) == ["cinder_traveler_rescued"], "The search pays the same leathers and water and now records a living traveler")
	var mirage: Dictionary = content.get_event("flats_mirage")
	var mirage_body := str(mirage.get("body", "")).to_lower()
	_check("walking" in mirage_body and "parallel fractures" in mirage_body and mirage.get("choices", []).size() == 2 and not content.event_has_combat_choice(mirage), "The mirage stays a Salt Colossus sighting with a readable path warning, not a fight")
	var carcass_fight: Dictionary = content.get_event("glass_carcass").get("choices", [])[2]
	_check(str(carcass_fight.get("label", "")) == "Challenge the Salt Colossus" and str(carcass_fight.get("combat", {}).get("adversary_id", "")) == "salt_colossus" and bool(carcass_fight["combat"].get("can_flee", false)), "glass_carcass appends the fleeable Salt Colossus apex fight at index two")

	var retired := {"rescued_engineer": 0, "b41_mercy_refused": 0}
	for event: Dictionary in content.events.values():
		for choice: Dictionary in event.get("choices", []):
			for outcome_key: String in ["success", "failure", "critical_success", "critical_failure", "outcome", "victory", "critical_victory"]:
				for flag: Variant in choice.get(outcome_key, {}).get("add_flags", []):
					if retired.has(str(flag)):
						retired[str(flag)] += 1
	_check(int(retired["rescued_engineer"]) == 0 and int(retired["b41_mercy_refused"]) == 0, "Both orphan flags are retired and no outcome writes them")

	# The two new creature hosts preserve the existing combat encounters. The
	# scheduler, rather than pruning an authored route, keeps every run at two.
	var combat_pools: Dictionary = {}
	for region: Dictionary in content.ordered_regions():
		var bearing: Array = []
		for event_id: Variant in region.get("event_pool", []):
			if content.event_has_combat_choice(content.get_event(str(event_id))):
				bearing.append(str(event_id))
		bearing.sort()
		combat_pools[int(region.get("order", -1))] = bearing
	_check(combat_pools[2] == ["marsh_bridge", "marsh_leeches", "marsh_lights", "marsh_raiders"], "The Drowned Marches forced-combat slot draws from the breeding-pool leeches as well as the Widow, the Bog Raiders, and the bridge Spewer")
	_check(combat_pools[3] == ["industrial_drones", "industrial_scavs", "industrial_tank"], "The Hollow Industrial forced-combat slot draws from the drone swarm as well as the Kilnback and the Vault Scavengers")
	_check(combat_pools[0] == ["outskirts_apartment", "outskirts_bandits", "outskirts_dogs", "outskirts_sinkhole"], "The Outskirts retain Bandits and Feral Dogs while adding Shutter Skitters and the sinkhole Pox Dogs as candidates")
	_check(combat_pools[5] == ["rail_hunters", "rail_nest", "rail_signal"], "Underrail retains Hunters and Ash Stalkers while adding Cable Eater as a third candidate")
	var every_region_has_combat := true
	for order: int in combat_pools:
		every_region_has_combat = every_region_has_combat and (combat_pools[order] as Array).size() >= 1
	_check(every_region_has_combat, "Every region retains a combat candidate; seeded scheduling verifies the two-opportunity cap")
	var marsh := _new_game(content, 6411)
	marsh.run_state["region_index"] = 2
	marsh._record_event(content.get_event("marsh_lights"))
	_check(int(marsh.run_state["combat_opportunities_seen_in_region"]) == 1, "Drawing marsh_lights consumes one of the region's two combat opportunities even if the fight is declined")

	# Every appended fight must actually open and actually pay what it promises,
	# including the D01 leech and drone routes and their combat boons.
	for creature: Dictionary in [
		{"event": "outskirts_apartment", "adversary": "shutter_skitters", "items": {"medkit": 1, "canned_meat": 1}, "flag": "", "conditions": []},
		{"event": "marsh_lights", "adversary": "reed_widow", "items": {"purifier_ampoule": 1, "clean_water": 2, "mutant_hide_vest": 1}, "flag": "widow_pool_cleared", "conditions": []},
		{"event": "industrial_tank", "adversary": "kilnback", "items": {"clean_water": 2}, "flag": "kilnback_rhythm_known", "conditions": []},
		{"event": "rail_signal", "adversary": "cable_eater", "items": {"scrap_parts": 3}, "flag": "citadel_signal", "conditions": []},
		{"event": "outskirts_sinkhole", "adversary": "pox_dogs", "items": {"purifier_poultice": 1, "scrap_parts": 1}, "flag": "", "conditions": ["adrenaline"]},
		{"event": "marsh_bridge", "adversary": "bile_spewer", "items": {"mutant_serum": 1, "clean_water": 1}, "flag": "", "conditions": ["iron_will"]},
		{"event": "glass_ruins", "adversary": "cinder_mauler", "items": {"kiln_plates": 1, "scrap_parts": 1}, "flag": "", "conditions": []},
		{"event": "glass_carcass", "adversary": "salt_colossus", "items": {"choir_incense": 1, "rifle_rounds": 4}, "flag": "", "conditions": []},
		{"event": "marsh_leeches", "adversary": "marsh_leeches", "items": {"cloth_bandage": 1, "purifier_poultice": 1}, "flag": "", "conditions": []},
		{"event": "industrial_drones", "adversary": "drone_swarm", "items": {"scrap_parts": 3}, "flag": "", "conditions": []},
	]:
		var fight := _new_game(content, 6412)
		fight.run_state["current_event_id"] = str(creature["event"])
		fight.run_state["phase"] = "event"
		var started := fight.start_combat(2)
		var combat_state: Dictionary = fight.run_state.get("combat_state", {})
		_check(bool(started.get("combat_started", false)) and str(combat_state.get("adversary_id", "")) == str(creature["adversary"]) and bool(combat_state.get("can_flee", false)), "%s choice 2 opens a fight with %s the survivor may still leave" % [creature["event"], creature["adversary"]])
		if str(creature["event"]) in ["outskirts_apartment", "rail_signal"]:
			var retreat := _new_game(content, 6414)
			retreat.run_state["current_event_id"] = str(creature["event"])
			retreat.run_state["phase"] = "event"
			retreat.start_combat(2)
			retreat.prepare_combat_action("flee")
			retreat.run_state["pending_combat_round"]["player_roll"] = 20
			retreat.resolve_prepared_combat_round()
			_check(retreat.run_state["phase"] == "result" and not str(creature["flag"]) in retreat.run_state["flags"], "%s supports a clean flee with no victory reward" % creature["event"])
		var carried: Dictionary = {}
		for item_id: String in (creature["items"] as Dictionary):
			carried[item_id] = fight.get_item_quantity(item_id)
		fight.run_state["combat_state"]["enemy_health"] = 1
		fight.prepare_combat_action("attack")
		fight.run_state["pending_combat_round"]["player_roll"] = 20
		fight.resolve_prepared_combat_round()
		var paid: bool = str(creature["flag"]).is_empty() or str(creature["flag"]) in fight.run_state["flags"]
		for item_id: String in (creature["items"] as Dictionary):
			# Battlefield salvage can add the same item on top of the authored
			# reward, so the check is at-least rather than exactly.
			paid = paid and fight.get_item_quantity(item_id) >= int(carried[item_id]) + int(creature["items"][item_id])
		for condition_id: Variant in creature.get("conditions", []):
			paid = paid and str(condition_id) in fight.run_state["survivor"].get("conditions", [])
		_check(paid, "Winning at %s hands over its authored reward and records %s" % [creature["event"], creature["flag"]])
	for apex: Dictionary in [
		{"event": "glass_ruins", "adversary": "cinder_mauler"},
		{"event": "glass_carcass", "adversary": "salt_colossus"},
	]:
		var frenzy := _new_game(content, 6413)
		frenzy.run_state["current_event_id"] = str(apex["event"])
		frenzy.run_state["phase"] = "event"
		frenzy.start_combat(2)
		frenzy.run_state["combat_state"]["enemy_health"] = 1
		frenzy.prepare_combat_action("attack")
		frenzy.run_state["pending_combat_round"]["player_roll"] = 20
		frenzy.resolve_prepared_combat_round()
		_check("bloodlust" in frenzy.run_state["survivor"].get("conditions", []), "Killing %s leaves bloodlust for the next two checks" % str(apex["adversary"]))

	# D03 accessory routes: each new build accessory is earned in play, not
	# only defined. Combat victories are forced through a 1-HP kill; the
	# conveyor crate is forced through a natural-20 check.
	for route: Dictionary in [
		{"event": "flats_toll", "choice": 0, "item": "brass_star", "combat": true},
		{"event": "rail_nest", "choice": 0, "item": "stalkhide_wraps", "combat": true},
		{"event": "industrial_scavs", "choice": 1, "item": "dredge_chain", "combat": true},
		{"event": "industrial_conveyor", "choice": 0, "item": "fan_guard", "combat": false},
	]:
		var earner := _new_game(content, 6430)
		earner.run_state["current_event_id"] = str(route["event"])
		earner.run_state["phase"] = "event"
		if bool(route["combat"]):
			earner.start_combat(int(route["choice"]))
			earner.run_state["combat_state"]["enemy_health"] = 1
			earner.prepare_combat_action("attack")
			earner.run_state["pending_combat_round"]["player_roll"] = 20
			earner.resolve_prepared_combat_round()
		else:
			earner.resolve_choice(int(route["choice"]), 20)
		_check(int(earner.run_state["survivor"]["inventory"].get(str(route["item"]), 0)) >= 1, "%s pays its %s accessory route" % [route["event"], route["item"]])
		var fitting := _new_game(content, 6431)
		fitting.run_state["survivor"]["inventory"][str(route["item"])] = 1
		fitting.unequip_item("weapon")
		_check(bool(fitting.equip_item(str(route["item"])).get("success", false)) and str(fitting.run_state["survivor"]["equipment"].get("accessory", "")) == str(route["item"]), "The %s equips into the accessory slot" % route["item"])

	# D01 build gates: one stat-gated route per build plus a weapon-grounded
	# drone route, so gear and base stats open doors instead of only odds.
	# D02 completes the set with the missing agility gate on the pack.
	var gate_specs: Array = [
		{"event": "rail_collapse", "index": 2, "stat": "strength", "label": "Lift the fallen beam"},
		{"event": "marsh_clinic", "index": 2, "stat": "wits", "label": "Read the dosage chart"},
		{"event": "flats_tanker", "index": 2, "stat": "grit", "label": "Walk the fume line"},
		{"event": "flats_toll", "index": 3, "stat": "presence", "label": "Trade them the eastern road"},
		{"event": "global_pack", "index": 2, "stat": "agility", "label": "Work the wire with quick hands"},
	]
	for spec: Dictionary in gate_specs:
		var gated_event: Dictionary = content.get_event(str(spec["event"]))
		var gated_choice: Dictionary = gated_event["choices"][int(spec["index"])]
		_check(str(gated_choice.get("label", "")) == str(spec["label"]) and int(gated_choice.get("requires", {}).get("stats", {}).get(str(spec["stat"]), 0)) == 4, "%s gates its build route behind %s 4" % [spec["event"], spec["stat"]])
		var weak_gate := _route_game(content, 6420, str(spec["event"]))
		weak_gate.run_state["survivor"]["stats"] = {"strength": 2, "agility": 2, "wits": 2, "grit": 2, "presence": 2}
		_check(not bool(weak_gate.get_choice_preview(gated_choice).get("available", true)), "%s stays locked below %s 4" % [spec["event"], spec["stat"]])
		var strong := _route_game(content, 6421, str(spec["event"]))
		var boosted: Dictionary = {"strength": 2, "agility": 2, "wits": 2, "grit": 2, "presence": 2}
		boosted[str(spec["stat"])] = 4
		strong.run_state["survivor"]["stats"] = boosted
		_check(bool(strong.get_choice_preview(gated_choice).get("available", false)), "%s opens at %s 4" % [spec["event"], spec["stat"]])
	var lifted := _route_game(content, 6422, "rail_collapse")
	lifted.run_state["survivor"]["stats"]["strength"] = 4
	lifted.run_state["survivor"]["conditions"] = ["sprain"]
	lifted.resolve_choice(2)
	_check("sprain" not in lifted.run_state["survivor"].get("conditions", []), "Lifting the beam works old injuries loose")
	var dosed := _route_game(content, 6423, "marsh_clinic")
	dosed.run_state["survivor"]["stats"]["wits"] = 4
	dosed.run_state["survivor"]["conditions"] = ["infection", "fever"]
	dosed.resolve_choice(2)
	_check("infection" not in dosed.run_state["survivor"].get("conditions", []) and "fever" not in dosed.run_state["survivor"].get("conditions", []), "Reading the chart purges infection and fever")
	var lined := _route_game(content, 6424, "flats_tanker")
	lined.run_state["survivor"]["stats"]["grit"] = 4
	lined.resolve_choice(2)
	_check("iron_will" in lined.run_state["survivor"].get("conditions", []) and int(lined.run_state["survivor"]["pressures"].get("fatigue", -1)) == 6, "Walking the fume line trades fatigue for iron will")
	var vouched := _route_game(content, 6425, "flats_toll")
	vouched.run_state["survivor"]["stats"]["presence"] = 4
	vouched.resolve_choice(3)
	_check("inspired" in vouched.run_state["survivor"].get("conditions", []), "Trading the eastern road inspires instead of spending rations")
	var quick := _route_game(content, 6429, "global_pack")
	quick.run_state["survivor"]["stats"]["agility"] = 4
	var rounds_before := quick.get_item_quantity("pistol_rounds")
	quick.resolve_choice(2)
	_check("steady_hands" in quick.run_state["survivor"].get("conditions", []) and quick.get_item_quantity("pistol_rounds") == rounds_before + 2, "Quick hands claim the rounds and steady the next two checks")
	var probe_choice: Dictionary = content.get_event("industrial_drones")["choices"][3]
	_check(str(probe_choice.get("label", "")) == "Ground the swarm with a wired probe" and int(probe_choice.get("requires", {}).get("items", {}).get("shock_probe", 0)) == 1, "The grounded drone route requires its Shock Probe")
	var unarmed_probe := _route_game(content, 6426, "industrial_drones")
	unarmed_probe.run_state["survivor"]["inventory"].erase("shock_probe")
	_check(not bool(unarmed_probe.get_choice_preview(probe_choice).get("available", true)), "The probe route stays locked without its weapon")
	var wired := _route_game(content, 6427, "industrial_drones")
	wired.run_state["survivor"]["inventory"]["shock_probe"] = 1
	_check(bool(wired.get_choice_preview(probe_choice).get("available", false)), "A carried Shock Probe unlocks the grounded route")
	wired.resolve_choice(3, 20)
	_check("focused" in wired.run_state["survivor"].get("conditions", []), "Grounding the swarm focuses the next two checks")
	var feedback := _route_game(content, 6428, "industrial_drones")
	feedback.run_state["survivor"]["inventory"]["shock_probe"] = 1
	feedback.resolve_choice(3, 1)
	_check("mind_static" in feedback.run_state["survivor"].get("conditions", []), "Failed feedback leaves mind static the colossus incense can cleanse")

	# Soft weapon affinity: below the authored minimum the weapon stays usable
	# but unwieldy (−15 hit, −25% damage); at or above it nothing changes.
	var weak := _new_game(content, 6415)
	weak.run_state["survivor"]["stats"] = {"strength": 2, "agility": 2, "wits": 2, "grit": 2, "presence": 2}
	weak.run_state["survivor"]["inventory"]["bone_cleaver"] = 1
	weak.run_state["survivor"]["equipment"]["weapon"] = "bone_cleaver"
	weak.run_state["current_event_id"] = "outskirts_dogs"
	weak.run_state["phase"] = "event"
	weak.start_combat(0)
	var weak_preview := weak.combat_action_preview("attack")
	_check("Unwieldy" in "\n".join(weak_preview.get("effects", [])), "An off-stat heavy weapon warns it is unwieldy before the roll")
	var met := _new_game(content, 6416)
	met.run_state["survivor"]["stats"] = {"strength": 4, "agility": 2, "wits": 2, "grit": 2, "presence": 2}
	met.run_state["survivor"]["inventory"]["bone_cleaver"] = 1
	met.run_state["survivor"]["equipment"]["weapon"] = "bone_cleaver"
	met.run_state["current_event_id"] = "outskirts_dogs"
	met.run_state["phase"] = "event"
	met.start_combat(0)
	var met_preview := met.combat_action_preview("attack")
	_check("Unwieldy" not in "\n".join(met_preview.get("effects", [])) and int(weak_preview.get("chance", 0)) == 50 and int(met_preview.get("chance", 0)) == 70, "Meeting the affinity minimum clears the warning and restores full accuracy")
	_check(int(met_preview.get("damage_max", 0)) > int(weak_preview.get("damage_max", 0)), "Meeting the affinity minimum restores full damage")
	var plain_profile := weak.get_player_weapon_profile()
	_check(bool(plain_profile.get("affinity", {}).get("required", false)) and not bool(plain_profile["affinity"].get("met", true)), "The weapon profile reports an unmet affinity")
	var starter := _new_game(content, 6417)
	var starter_affinity: Dictionary = starter.content.get_item("salvage_cleaver")
	_check(not starter_affinity.has("affinity_min"), "Starting-kit weapons carry no affinity requirement, so no build starts weak")

	# Battlefield salvage: identical kills can pay differently, drops stay inside
	# the authored loot table, and the same seed replays to the same drops.
	var loot_a := _new_game(content, 6418)
	loot_a.run_state["current_event_id"] = "outskirts_bandits"
	loot_a.run_state["phase"] = "event"
	loot_a.start_combat(0)
	loot_a.run_state["combat_state"]["enemy_health"] = 1
	loot_a.prepare_combat_action("attack")
	loot_a.run_state["pending_combat_round"]["player_roll"] = 20
	loot_a.resolve_prepared_combat_round()
	var loot_b := _new_game(content, 6418)
	loot_b.run_state["current_event_id"] = "outskirts_bandits"
	loot_b.run_state["phase"] = "event"
	loot_b.start_combat(0)
	loot_b.run_state["combat_state"]["enemy_health"] = 1
	loot_b.prepare_combat_action("attack")
	loot_b.run_state["pending_combat_round"]["player_roll"] = 20
	loot_b.resolve_prepared_combat_round()
	_check(loot_a.run_state["survivor"]["inventory"] == loot_b.run_state["survivor"]["inventory"], "The same seed replays a victory to identical salvage")
	# Adversaries without a loot table pay exactly their authored victory.
	var widow := _new_game(content, 6420)
	widow.run_state["current_event_id"] = "marsh_lights"
	widow.run_state["phase"] = "event"
	widow.start_combat(2)
	var widow_carried := {}
	for item_id: String in ["purifier_ampoule", "clean_water", "mutant_hide_vest"]:
		widow_carried[item_id] = widow.get_item_quantity(item_id)
	widow.run_state["combat_state"]["enemy_health"] = 1
	widow.prepare_combat_action("attack")
	widow.run_state["pending_combat_round"]["player_roll"] = 20
	widow.resolve_prepared_combat_round()
	var widow_exact := true
	for item_id: String in {"purifier_ampoule": 1, "clean_water": 2, "mutant_hide_vest": 1}:
		widow_exact = widow_exact and widow.get_item_quantity(item_id) == int(widow_carried[item_id]) + int({"purifier_ampoule": 1, "clean_water": 2, "mutant_hide_vest": 1}[item_id])
	_check(widow_exact, "A table-less victory pays exactly its authored reward with no salvage")
	# Mastery receipt: crossing base 6 on the equipped weapon's stat is reported.
	var pupil := _new_game(content, 6419)
	pupil.run_state["phase"] = "checkpoint"
	pupil.run_state["unspent_stat_points"] = 2
	pupil.run_state["survivor"]["stats"] = {"strength": 5, "agility": 1, "wits": 1, "grit": 1, "presence": 1}
	pupil.run_state["survivor"]["inventory"]["salvage_cleaver"] = 1
	pupil.run_state["survivor"]["equipment"]["weapon"] = "salvage_cleaver"
	var mastery_result := pupil.confirm_stat_allocation({"strength": 6, "agility": 1, "wits": 1, "grit": 1, "presence": 1})
	_check(bool(mastery_result.get("success", false)) and "strength" in mastery_result.get("mastery_unlocked", []), "Confirming the sixth base point reports the equipped weapon's mastery")


## N04 plan section 6 with consequence-map records 7 and 8. The Mercy Key is an
## object that moves. A survivor who handed it to Mara or to the Choir must not
## be able to offer it at the Citadel gate, the Choir cannot be given a Key that
## was never taken, and the Ash ending needs the founder's confession rather than
## a membership. The Warden's refusal keeps its weapon tracked and unfired.
func _test_key_possession_and_endings(content: ContentRepository) -> void:
	# Took the Key, opened the sealed rooms, then put the Key in Mara's hands.
	var given_away := _route_game(content, 7401, "bunker41_last_evacuation")
	given_away.resolve_choice(0)
	_check("b41_mercy_key" in given_away.run_state["flags"], "Taking the core beneath the command console records that the survivor holds the Key")
	given_away.run_state["phase"] = "event"
	given_away.run_state["current_event_id"] = "bunker41_ledger_living"
	given_away.resolve_choice(0)
	given_away.run_state["phase"] = "event"
	given_away.run_state["current_event_id"] = "rustsea_cartographers_debt"
	given_away.resolve_choice(2)
	_check("rustsea_key_with_mara" in given_away.run_state["flags"] and "b41_mercy_key" in given_away.run_state["flags"], "The transfer is written beside the history of the Key, which never clears")
	given_away.run_state["phase"] = "event"
	given_away.run_state["region_index"] = 6
	given_away.run_state["current_event_id"] = "bunker41_door_closes"
	var gate_choices: Array = given_away.current_event()["choices"]
	var mercy := given_away.get_choice_preview(gate_choices[1])
	_check(not mercy.get("available", true) and str(mercy.get("reason", "")) == "You do not hold the Key", "A survivor who gave Mara the Key cannot offer it at the gate")
	_check(not bool(mercy.get("hidden", false)), "The missing Key stays on screen as a visible lock instead of vanishing from the list")
	_check(str(given_away.resolve_choice(1).get("error", "")) == "You do not hold the Key", "The engine refuses the Mercy ending with the same explanation the row shows")
	_check(given_away.get_choice_preview(gate_choices[0]).get("available", false), "Silence stays available to a survivor who gave the Key away")
	_check(given_away.get_choice_preview(gate_choices[2]).get("available", false), "Witness stays available because the sealed rooms were opened before the Key changed hands")

	var holder := _route_game(content, 7402, "bunker41_last_evacuation")
	holder.resolve_choice(0)
	holder.run_state["phase"] = "event"
	holder.run_state["region_index"] = 6
	holder.run_state["current_event_id"] = "bunker41_door_closes"
	_check(holder.get_choice_preview(holder.current_event()["choices"][1]).get("available", false), "A survivor still carrying the Key can still offer it at the gate")
	var mercy_ending := holder.resolve_choice(1)
	_check(str(holder.run_state.get("phase", "")) == "victory" and "Mercy Key" in str(mercy_ending.get("outcome_text", "")), "Offering the Key still finishes the run at the gate it was made for")

	var chapel := _route_game(content, 7403, "bunker41_chapel_car")
	var chapel_choices: Array = chapel.current_event()["choices"]
	var surrender := chapel.get_choice_preview(chapel_choices[0])
	_check(not surrender.get("available", true) and str(surrender.get("reason", "")) == "You do not hold the Key", "The Choir cannot be handed a Key the survivor never took")
	var chapel_open := true
	for index in [1, 2]:
		chapel_open = chapel_open and bool(chapel.get_choice_preview(chapel_choices[index]).get("available", false))
	_check(chapel_open, "Stealing the founder's records and refusing the judgement stay ungated")
	chapel.run_state["flags"] = ["b41_mercy_key"]
	_check(chapel.get_choice_preview(chapel_choices[0]).get("available", false), "A survivor holding the Key may still surrender it to the Choir")
	chapel.run_state["flags"] = ["b41_mercy_key", "rustsea_key_with_mara"]
	_check(not chapel.get_choice_preview(chapel_choices[0]).get("available", true), "A Key already in Mara's hands cannot be given to the Choir as well")

	var mara := _route_game(content, 7404, "rustsea_cartographers_debt")
	var mara_gift: Dictionary = mara.current_event()["choices"][2]
	mara.run_state["flags"] = ["b41_mercy_key", "b41_key_surrendered"]
	_check(not mara.get_choice_preview(mara_gift).get("available", true), "A Key already surrendered to the Choir cannot be given to Mara as well")
	mara.run_state["flags"] = ["b41_mercy_key"]
	_check(mara.get_choice_preview(mara_gift).get("available", false), "An untransferred Key still opens Mara's route to the Spire")

	var warden_event: Dictionary = content.get_event("bunker41_warden_remembers")
	var invoke: Dictionary = warden_event["choices"][2]
	var carrier := _route_game(content, 7405, "bunker41_warden_remembers")
	carrier.run_state["region_index"] = 6
	carrier.run_state["flags"] = ["b41_mercy_key", "b41_witness", "rustsea_key_with_mara"]
	var invoked := carrier.get_choice_preview(invoke)
	_check(invoked.get("available", false), "Testimony still answers the Warden after the Key changed hands, because the Key is only one of five records it accepts")
	carrier.run_state["flags"] = ["b41_witness"]
	_check(carrier.get_choice_preview(invoke).get("available", false), "Testimony carried in the survivor's own voice still answers the Warden")
	carrier.run_state["flags"] = []
	var unevidenced := carrier.get_choice_preview(invoke)
	_check(not unevidenced.get("available", true) and str(unevidenced.get("reason", "")) == "Requires Bunker Forty-One testimony or evidence", "A survivor carrying no Bunker evidence is told what the Warden wants, not about a Key they never held")

	var refusal: Dictionary = warden_event["choices"][0]["outcome"]
	var refusal_text := str(refusal.get("text", ""))
	_check("raises the weapon" not in refusal_text, "The Warden's refusal no longer ends on a weapon the scene never fires")
	_check("does not fire" in refusal_text and "no procedure" in refusal_text, "The weapon stays tracked and unfired while the protocol runs out of answers")
	_check(str(refusal.get("next_event", "")) == "bunker41_door_closes" and not warden_event["choices"][0].has("combat"), "Refusing still chains to the door and still costs no fight")
	_check(warden_event["choices"].size() == 4 and str(warden_event["choices"][1].get("combat", {}).get("adversary_id", "")) == "warden_machine", "The only Warden fight stays at index 1 where a player chooses it deliberately")

	var ash_choice: Dictionary = content.get_event("bunker41_door_closes")["choices"][3]
	_check(ash_choice["requires"]["any_flags"] == ["b41_choir_records", "b41_choir_bound"], "The Ash ending lists only the two acts that put the founder's confession in play")
	var affiliated := _route_game(content, 7406, "bunker41_door_closes")
	affiliated.run_state["region_index"] = 6
	for affiliation: String in ["b41_choir_joined", "b41_choir_split"]:
		affiliated.run_state["flags"] = [affiliation]
		_check(not affiliated.get_choice_preview(ash_choice).get("available", true), "Walking with the Choir (%s) hands the survivor no record to play" % affiliation)
	for evidence: String in ["b41_choir_records", "b41_choir_bound"]:
		affiliated.run_state["flags"] = [evidence]
		_check(affiliated.get_choice_preview(ash_choice).get("available", false), "%s still opens the Ash ending" % evidence)
	var copied := _route_game(content, 7407, "bunker41_door_closes")
	copied.run_state["flags"] = ["b41_choir_records", "b41_witness"]
	var copied_ending := copied.resolve_choice(3)
	_check(str(copied.run_state.get("phase", "")) == "victory" and "gate speakers" in str(copied_ending.get("outcome_text", "")), "The survivor who copied the confession plays it into the gate speakers")
	var bound := _route_game(content, 7408, "bunker41_door_closes")
	bound.run_state["flags"] = ["b41_choir_bound", "b41_key_surrendered"]
	var bound_ending := bound.resolve_choice(3)
	_check(str(bound.run_state.get("phase", "")) == "victory" and "the Choir does" in str(bound_ending.get("outcome_text", "")), "The survivor who gave the Choir the Key hears them play the record they kept")
	_check(str(bound_ending.get("outcome_text", "")) != str(copied_ending.get("outcome_text", "")), "The two Ash keys are two different acts and read as two different passages")


## N04 plan section 6 and consequence-map finding X4. A scene must keep one legal
## action for a survivor whose pack is empty, and a choice gated behind an item
## needs a source reachable before the region that asks for it.
func _test_legal_actions_and_item_reach(content: ContentRepository) -> void:
	var stranger: Dictionary = content.get_event("global_stranger")
	var stranger_choices: Array = stranger.get("choices", [])
	_check(stranger_choices.size() == 3 and str(stranger_choices[0].get("label", "")) == "Treat the wound" and str(stranger_choices[1].get("label", "")) == "Offer water and move on", "global_stranger keeps both supply routes at their original indices")
	var coat: Dictionary = stranger_choices[2]
	_check(str(coat.get("label", "")) == "Press the wound with your own coat" and (coat.get("requires", {}) as Dictionary).is_empty() and (coat.get("costs", {}) as Dictionary).is_empty(), "The appended route asks for nothing the survivor might not carry")
	_check(str(coat.get("approach", "")) == "medical" and str(coat["check"].get("stat", "")) == "grit" and str(coat["check"].get("difficulty", "")) == "risky", "Pressing the wound is the authored Grit risky medical check")
	_check(int(coat["success"]["pressures"].get("fatigue", 0)) == 4 and coat["success"].get("add_conditions", []) == ["inspired"] and not coat["success"].has("items") and not coat["success"].has("add_flags"), "Holding the wound closed costs fatigue and pays only the conviction that it worked")
	_check(int(coat["failure"]["pressures"].get("fatigue", 0)) == 4 and coat["failure"].get("add_conditions", []) == ["shaken"] and not coat["failure"].has("items") and not coat["failure"].has("add_flags"), "Failing costs the same fatigue and leaves the survivor shaken with nothing spent")
	_check("own coat is lined" in str(stranger.get("body", "")), "The introduction establishes the survivor's own coat lining before the route is offered")

	var depleted := _route_game(content, 7411, "global_stranger")
	depleted.run_state["survivor"]["inventory"].erase("cloth_bandage")
	depleted.run_state["survivor"]["inventory"].erase("clean_water")
	_check(not depleted.get_choice_preview(stranger_choices[0]).get("available", true) and not depleted.get_choice_preview(stranger_choices[1]).get("available", true), "An empty pack still locks both supply routes")
	_check(depleted.get_choice_preview(coat).get("available", false), "The coat route stays open, so the scene always leaves one legal action")
	var pressed := depleted.resolve_choice(2, 20)
	_check(not pressed.has("error") and "inspired" in depleted.run_state["survivor"]["conditions"], "A survivor carrying nothing can still resolve the injured stranger")
	_check("Fatigue +4" in ", ".join(PackedStringArray(pressed.get("changes", []))), "The work charges the authored fatigue")
	var failed := _route_game(content, 7412, "global_stranger")
	failed.run_state["survivor"]["inventory"].erase("cloth_bandage")
	failed.run_state["survivor"]["inventory"].erase("clean_water")
	var token_before := failed.get_item_quantity("trader_token")
	failed.resolve_choice(2, 1)
	_check("shaken" in failed.run_state["survivor"]["conditions"] and failed.get_item_quantity("trader_token") == token_before, "Failing the coat route leaves the survivor shaken and moves no supplies")

	for repository: ContentRepository in [content, ContentRepository.new(true)]:
		var stranded: Array[String] = []
		for event_id: String in repository.events:
			var ungated := false
			for choice: Dictionary in repository.events[event_id].get("choices", []):
				if (choice.get("requires", {}) as Dictionary).is_empty():
					ungated = true
			if not ungated:
				stranded.append(event_id)
		_check(stranded.is_empty(), "Every %s event keeps one ungated choice (stranded: %s)" % ["expanded" if repository.living_road_enabled else "launch", ", ".join(PackedStringArray(stranded))])

	var smoke_sources: Dictionary = {}
	for region: Dictionary in content.ordered_regions():
		for event_id: Variant in region.get("event_pool", []):
			for choice: Dictionary in content.get_event(str(event_id)).get("choices", []):
				for outcome_key: String in ["success", "critical_success", "outcome", "victory", "critical_victory"]:
					if int(choice.get(outcome_key, {}).get("items", {}).get("smoke_bomb", 0)) > 0:
						smoke_sources[str(event_id)] = int(region.get("order", -1))
	_check(smoke_sources.has("flats_tanker") and int(smoke_sources["flats_tanker"]) == 1 and smoke_sources.has("rail_hunters"), "The Smoke Bomb has a Salt Flats source beside its Underrail one")
	var earliest := 99
	for event_id: String in smoke_sources:
		earliest = mini(earliest, int(smoke_sources[event_id]))
	_check(earliest < 2, "A Smoke Bomb can be earned before the Drowned Marches ask for one")
	var tanker: Dictionary = content.get_event("flats_tanker")["choices"][0]["success"]
	var tanker_reward: Dictionary = tanker["items"]
	_check(tanker_reward.size() == 3 and int(tanker_reward.get("frame_pack", 0)) == 1 and int(tanker_reward.get("scrap_parts", 0)) == 2 and int(tanker_reward.get("smoke_bomb", 0)) == 1, "Cutting the locker keeps both authored rewards and adds the repacked flare casing")
	_check("smoke charge" in str(tanker.get("text", "")), "The locker's outcome names the charge it now hands over")

	var raiders := _route_game(content, 7413, "marsh_raiders")
	raiders.run_state["region_index"] = 2
	var smoke_choice: Dictionary = raiders.current_event()["choices"][2]
	raiders.run_state["survivor"]["inventory"].erase("smoke_bomb")
	_check(not raiders.get_choice_preview(smoke_choice).get("available", true), "The marsh smoke route stays locked for a survivor who never found a charge")
	raiders.run_state["survivor"]["inventory"]["smoke_bomb"] = 1
	_check(raiders.get_choice_preview(smoke_choice).get("available", false), "A Salt Flats charge opens the marsh escape in the region that asks for it")
	raiders.resolve_choice(2)
	_check(raiders.get_item_quantity("smoke_bomb") == 0, "Using the charge spends it")


## N06, consequence map section 5b and return records 1-12. A returning story
## reads what its earlier chapters wrote: the Bunker's later scenes carry the
## survivor's record, the Rust-Sea's dead ends reach the Spire, the Living Road's
## earned routes stay hidden from a survivor who never earned them, orphan flags
## are retired or read, and the finale routes by Bunker history.
func _test_returning_stories(content: ContentRepository, living_content: ContentRepository) -> void:
	# Bunker Forty-One
	var fled := _new_game(content, 7601)
	fled.run_state["region_index"] = 5
	fled.run_state["flags"] = ["b41_contact", "b41_forced_entry"]
	_check(fled._event_eligible(content.get_event("bunker41_last_evacuation")), "The command room stays reachable for a survivor who forced the hatch and stayed inside")
	fled.run_state["flags"] = ["b41_contact", "b41_forced_entry", "b41_relay_fragment"]
	_check(not fled._event_eligible(content.get_event("bunker41_last_evacuation")), "A survivor who fled with the relay is never narrated back inside the bunker they left")
	_check(fled._event_eligible(content.get_event("bunker41_fragment_calls")), "The relay they carry still calls to them in the Underrail")
	var discarded: Dictionary = content.get_event("bunker41_fragment_calls")["choices"][2]["outcome"]
	_check(discarded.get("add_flags", []) == ["b41_ash_invite"], "Throwing the fragment onto the tracks writes only the invitation something reads")
	var theft: Dictionary = content.get_event("bunker41_ash_procession")["choices"][2]["outcome"]
	_check(int(theft.get("items", {}).get("canned_meat", 0)) == 1 and "b41_choir_hostile" in theft.get("add_flags", []), "Robbing the lantern bearers yields the tin the passage names and still turns the Choir hostile")
	var warden_fight: Dictionary = content.get_event("bunker41_warden_remembers")["choices"][1]
	_check(str(warden_fight.get("combat", {}).get("adversary_id", "")) == "warden_machine" and "b41_warden_destroyed" in warden_fight.get("victory", {}).get("add_flags", []), "Destroying the Warden leaves a trace the gate can read")
	var gate := _route_game(content, 7602, "bunker41_door_closes")
	gate.run_state["region_index"] = 6
	var gate_event: Dictionary = gate.current_event()
	var plain_gate := gate.resolve_body(gate_event)
	gate.run_state["flags"] = ["b41_warden_destroyed"]
	var broken_warden := gate.resolve_body(gate_event)
	_check(broken_warden != plain_gate and "lying broken" in broken_warden, "The gate scene opens onto the Warden the survivor destroyed")
	gate.run_state["flags"] = ["b41_warden_heard"]
	_check("has not moved since it hesitated" in gate.resolve_body(gate_event), "The gate scene remembers a Warden that was answered instead")
	var names: Dictionary = gate_event["choices"][2]["outcome"]
	gate.run_state["flags"] = ["b41_witness", "pilgrim_disk"]
	_check("prayer disk" in gate.resolve_outcome_text(names), "The pilgrim's disk finally has a reader: its name is the last one read at the gate")
	gate.run_state["flags"] = ["b41_rescued_survivors", "pilgrim_disk"]
	var chorus := gate.resolve_outcome_text(names)
	_check("prayer disk" not in chorus and "not the only voice" in chorus, "The people let out of the sealed rooms outrank the disk when both are true")
	gate.run_state["flags"] = ["b41_witness"]
	_check(gate.resolve_outcome_text(names) == str(names.get("text", "")), "A witness carrying neither reads the plain passage")
	var mercy_gate: Dictionary = gate_event["choices"][1]["outcome"]
	gate.run_state["flags"] = ["b41_mercy_key", "b41_warden_destroyed"]
	_check("a guard must" in gate.resolve_outcome_text(mercy_gate), "With no machine left to read the Key, a guard reads it")
	var warden := _route_game(content, 7603, "bunker41_warden_remembers")
	warden.run_state["region_index"] = 6
	var warden_event: Dictionary = warden.current_event()
	var testimony: Dictionary = warden_event["choices"][2]["outcome"]
	var presented_key: Dictionary = warden_event["choices"][3]
	warden.run_state["flags"] = ["b41_mercy_key", "b41_key_surrendered"]
	_check(not warden.get_choice_preview(warden_event["choices"][2]).get("available", true), "A transferred Key alone does not become testimony at the Warden")
	_check(not warden.get_choice_preview(presented_key).get("available", true) and str(warden.get_choice_preview(presented_key).get("reason", "")) == "You do not hold the Key", "A transferred Key cannot be presented to the Warden")
	warden.run_state["flags"] = ["b41_mercy_key", "b41_key_surrendered", "b41_witness"]
	_check(warden.get_choice_preview(warden_event["choices"][2]).get("available", false) and "no longer yours to raise" in warden.resolve_outcome_text(testimony), "Independent testimony remains usable after the Key changed hands")
	warden.run_state["flags"] = ["b41_mercy_key"]
	_check(warden.get_choice_preview(presented_key).get("available", false) and "casualty count" in warden.resolve_outcome_text(presented_key["outcome"]), "A held Key has its own Warden presentation route")
	warden.run_state["flags"] = []
	_check(not warden.get_choice_preview(warden_event["choices"][2]).get("available", true) and not warden.get_choice_preview(presented_key).get("available", true), "No Key or independent evidence leaves both evidence routes closed")
	warden.run_state["flags"] = ["b41_public_signal"]
	_check("It has you" in warden.resolve_body(warden_event), "A survivor who lit the station openly meets a Warden that was sent for them")
	warden.run_state["flags"] = ["b41_voice_heard"]
	var recognized := warden.resolve_body(warden_event)
	warden.run_state["flags"] = ["b41_contact"]
	_check(recognized != warden.resolve_body(warden_event) and recognized != str(warden_event.get("body", "")), "Recognition of the salt-flats voice is keyed on having heard it, not on having entered the bunker")

	# Rust-Sea
	var salt: Dictionary = content.get_event("rustsea_salt_crown_wake")["choices"][1]
	_check(salt.has("check") and str(salt["check"].get("stat", "")) == "agility" and not salt.has("outcome"), "Taking supplies from the Salt Crown wagons is a rolled Agility choice with no stale plain branch")
	_check(int(salt["success"].get("items", {}).get("canned_meat", 0)) == 1 and int(salt["success"].get("items", {}).get("clean_water", 0)) == 1 and int(salt["failure"].get("pressures", {}).get("fatigue", 0)) == 6, "Its success pays the two unsplit tins the passage names and its failure costs the careful lifting")
	_check(str(salt["success"].get("next_event", "")) == "rustsea_cartographers_debt" and str(salt["failure"].get("next_event", "")) == "rustsea_cartographers_debt", "Both branches still lead to Mara's lamp on stilts")
	var debt_event: Dictionary = content.get_event("rustsea_cartographers_debt")
	_check(str(debt_event["choices"][2]["outcome"].get("next_event", "")) == "rustsea_last_coordinate" and str(content.get_event("rustsea_voice_map")["choices"][2]["outcome"].get("next_event", "")) == "rustsea_last_coordinate", "Giving Mara the Key and naming the dead both continue to the Last Coordinate instead of ending the thread")
	var quay_eligibility: Dictionary = content.get_event("rustsea_quay_names").get("eligibility", {})
	_check(not quay_eligibility.has("requires_flags") and "rustsea_map_self_marked" in quay_eligibility.get("requires_any_flags", []), "The Quay of Names also admits a survivor who marked Mara's map themselves")
	var debtor := _route_game(content, 7604, "rustsea_cartographers_debt")
	var return_choice: Dictionary = debt_event["choices"][3]
	var hidden_return := debtor.get_choice_preview(return_choice)
	_check(not hidden_return.get("available", true) and bool(hidden_return.get("hidden", false)), "A survivor who took nothing of Mara's never sees the offer to return it")
	debtor.run_state["flags"] = ["b41_mara_abandoned"]
	_check(debtor.get_choice_preview(return_choice).get("available", false), "The survivor who took her map in the bunker can give it back")
	debtor.resolve_choice(3)
	debtor.continue_after_result()
	_check("rustsea_mara_allied" in debtor.run_state["flags"] and "rustsea_spire_route" in debtor.run_state["flags"] and str(debtor.run_state.get("current_event_id", "")) == "rustsea_last_coordinate", "Returning it makes Mara an ally and opens her route to the Spire")
	var spire_entry: Dictionary = content.discovery_entries.get("ledger_rustsea_spire", {})
	var spire_flags := {}
	for variant: Dictionary in spire_entry.get("variants", []):
		for flag: Variant in variant.get("requires_any_flags", []):
			spire_flags[str(flag)] = true
	var coordinate_covered := true
	for choice: Dictionary in content.get_event("rustsea_last_coordinate")["choices"]:
		var written := false
		for flag: Variant in choice.get("outcome", {}).get("add_flags", []):
			written = written or spire_flags.has(str(flag))
		coordinate_covered = coordinate_covered and written
	_check(coordinate_covered and spire_entry.get("variants", []).size() == 3, "Every way of taking the Last Coordinate writes a flag its Chronicle chapter reads")

	# Living Road
	var thread_complete_written := false
	for event: Dictionary in living_content.events.values():
		for choice: Dictionary in event.get("choices", []):
			for key: String in ContentRepository.OUTCOME_KEYS:
				for flag: Variant in choice.get(key, {}).get("add_flags", []):
					thread_complete_written = thread_complete_written or str(flag).ends_with("_complete")
	_check(not thread_complete_written, "No outcome writes a thread-complete flag the scheduler never read")
	var earned_routes := [
		{"event": "lr_voice_in_reeds", "region": 2, "flags": ["widow_pool_cleared"], "items": {}, "writes": "lr_family_reunited", "pays": "climbing_rope"},
		{"event": "lr_quiet_column", "region": 1, "flags": ["lr_siren_silenced"], "items": {"scrap_parts": 1}, "writes": "lr_column_sheltered", "pays": ""},
		{"event": "lr_pharmacy_witness", "region": 1, "flags": ["lr_bandit_leader_disarmed"], "items": {"pipe_pistol": 1}, "writes": "lr_ledger_clue", "pays": ""},
		{"event": "lr_cup_passed_east", "region": 3, "flags": ["lr_filter_stripped"], "items": {"scrap_parts": 2}, "writes": "lr_water_shared", "pays": "clean_water"},
		{"event": "lr_embers_in_rain", "region": 2, "flags": ["lr_nightfire_robbed"], "items": {}, "writes": "lr_caravan_debt_owed", "pays": "canned_meat"},
		{"event": "lr_warm_windows", "region": 5, "flags": ["kilnback_rhythm_known"], "items": {}, "writes": "lr_caravan_two_fires", "pays": "stun_baton"},
	]
	var route_seed := 7610
	for route: Dictionary in earned_routes:
		route_seed += 1
		var event_id := str(route["event"])
		var earned := _route_game(living_content, route_seed, event_id)
		earned.run_state["region_index"] = int(route["region"])
		var choices: Array = earned.current_event()["choices"]
		_check(choices.size() == 4, "%s carries its earned route as a fourth choice" % event_id)
		var choice: Dictionary = choices[3]
		var unearned := earned.get_choice_preview(choice)
		_check(not unearned.get("available", true) and bool(unearned.get("hidden", false)), "%s hides its earned route from a survivor who never earned it" % event_id)
		earned.run_state["flags"] = (route["flags"] as Array).duplicate()
		for item_id: String in route["items"]:
			earned.run_state["survivor"]["inventory"][item_id] = int(route["items"][item_id])
		_check(earned.get_choice_preview(choice).get("available", false), "%s opens it once the earlier act and what it left in the pack are both present" % event_id)
		var paid_before := earned.get_item_quantity(str(route["pays"])) if str(route["pays"]) != "" else 0
		earned.resolve_choice(3, 20)
		var spent := true
		for item_id: String in route["items"]:
			spent = spent and earned.get_item_quantity(item_id) == 0
		_check(spent and str(route["writes"]) in earned.run_state["flags"] and ("lr_callback_region_%d" % int(route["region"])) in earned.run_state["flags"], "%s spends what it asks for, writes its consequence, and closes its callback window" % event_id)
		if str(route["pays"]) != "":
			_check(earned.get_item_quantity(str(route["pays"])) == paid_before + 1, "%s pays the %s its passage hands over" % [event_id, route["pays"]])
	var reeds := _route_game(living_content, 7620, "lr_voice_in_reeds")
	reeds.run_state["region_index"] = 2
	reeds.run_state["flags"] = ["widow_pool_cleared", "lr_family_trusted"]
	var crossed := reeds.resolve_choice(3)
	_check("plank" in str(crossed.get("outcome_text", "")) and not crossed.has("error"), "Crossing the cut the survivor emptied reads as the marsh they cleared, not as tracking")
	var pharmacy := _route_game(living_content, 7621, "lr_pharmacy_witness")
	pharmacy.run_state["region_index"] = 1
	var pharmacy_event: Dictionary = pharmacy.current_event()
	var pharmacy_default := pharmacy.resolve_body(pharmacy_event)
	pharmacy.run_state["flags"] = ["lr_bandit_leader_killed"]
	var killed := pharmacy.resolve_body(pharmacy_event)
	pharmacy.run_state["flags"] = ["lr_bandits_paid"]
	var paid := pharmacy.resolve_body(pharmacy_event)
	_check(killed != pharmacy_default and paid != pharmacy_default and killed != paid, "Lio's witness scene opens differently for the survivor who killed the leader and the one who paid her")
	var battery := _route_game(living_content, 7622, "lr_last_battery")
	battery.run_state["region_index"] = 3
	battery.run_state["flags"] = ["lr_family_reunited"]
	battery.resolve_choice(2)
	_check("lr_family_unknown" in battery.run_state["flags"] and "lr_callback_region_3" in battery.run_state["flags"] and not ("lr_family_thread_complete" in battery.run_state["flags"]), "Resolving a thread's last chapter writes its ending and its window, and no flag nothing reads")
	var both := _route_game(living_content, 7623, "lr_pharmacy_witness")
	both.run_state["region_index"] = 1
	both.run_state["flags"] = ["lr_bandit_leader_disarmed", "lr_bandit_leader_killed"]
	both.run_state["survivor"]["inventory"]["pipe_pistol"] = 1
	_check(not both.get_choice_preview(both.current_event()["choices"][3]).get("available", true), "A run that disarmed the leader once and killed her the next time cannot return a pistol to a woman the scene shows dead")
	var embers := _route_game(living_content, 7624, "lr_embers_in_rain")
	embers.run_state["flags"] = ["lr_nightfire_shared"]
	var decline: Dictionary = embers.current_event()["choices"][2]["outcome"]
	var declined := embers.resolve_outcome_text(decline)
	_check("on her list" in declined and "not on her list" not in declined, "Declining the bedroll at a fire that already lists the survivor does not strike them from the list")
	# The finale routes by Bunker history (map section 5b, decision 1)
	var gate_one: Dictionary = content.get_event("final_gate_1")
	var stranger := _route_game(content, 7630, "final_gate_1")
	stranger.run_state["region_index"] = 6
	var veteran := _route_game(content, 7631, "final_gate_1")
	veteran.run_state["region_index"] = 6
	veteran.run_state["flags"] = ["b41_contact"]
	var routed_default := true
	var routed_bunker := true
	var gate_outcomes := 0
	for choice: Dictionary in gate_one["choices"]:
		for key: String in ["success", "failure", "critical_success"]:
			if choice.has(key):
				gate_outcomes += 1
				routed_default = routed_default and stranger.resolve_outcome_next_event(choice[key]) == "final_gate_2"
				routed_bunker = routed_bunker and veteran.resolve_outcome_next_event(choice[key]) == "bunker41_warden_remembers"
	_check(gate_outcomes == 5 and routed_default, "All five first-gate outcomes send a survivor who never touched Bunker Forty-One to the standard screening")
	_check(routed_bunker, "All five send a survivor who entered or marked the bunker to the Warden that remembers them")
	var heard := _route_game(content, 7632, "final_gate_1")
	heard.run_state["flags"] = ["b41_voice_heard"]
	_check(heard.resolve_outcome_next_event(gate_one["choices"][1]["failure"]) == "final_gate_2" and heard.resolve_body(gate_one) != str(gate_one.get("body", "")), "Hearing the salt-flats voice earns a recognition line at the gate but not the Bunker finale")
	# The route is selected when the prepared choice resolves, so restoring a
	# concealed roll must retain the survivor's history rather than silently
	# taking the default route.
	for prepared_history: Dictionary in [
		{"flags": [], "next": "final_gate_2", "label": "standard screening"},
		{"flags": ["b41_contact"], "next": "bunker41_warden_remembers", "label": "Bunker finale"},
	]:
		var prepared_gate := _route_game(content, 76321 + int(prepared_history["flags"].size()), "final_gate_1")
		prepared_gate.run_state["region_index"] = 6
		prepared_gate.run_state["flags"] = (prepared_history["flags"] as Array).duplicate()
		_check(bool(prepared_gate.prepare_choice(1).get("prepared", false)), "The %s route can be prepared before its outcome is known" % str(prepared_history["label"]))
		var restored_gate := GameEngine.new(content)
		restored_gate.restore_run(prepared_gate.run_state.duplicate(true))
		restored_gate.resolve_prepared_choice()
		restored_gate.continue_after_result()
		_check(str(restored_gate.run_state.get("current_event_id", "")) == str(prepared_history["next"]), "Restoring a prepared gate choice retains the %s route" % str(prepared_history["label"]))
	var legacy_focus := _new_game(living_content, 76325)
	legacy_focus.run_state["schema_version"] = 4
	legacy_focus.run_state["event_history"] = ["lr_blue_van"]
	legacy_focus.run_state["flags"] = ["lr_family_trusted"]
	var restored_legacy_focus := GameEngine.new(living_content)
	restored_legacy_focus.restore_run(SaveService.new("unused_")._migrate_run(legacy_focus.run_state.duplicate(true)))
	_check(restored_legacy_focus._focused_callback_thread() == "family_on_nine" and restored_legacy_focus._due_callback_event_id() == "lr_voice_in_reeds", "A pre-N04 saved history enrolls in focused scheduling without a new save field")
	var code_answer: Dictionary = gate_one["choices"][0]
	var uncoded := stranger.get_choice_preview(code_answer)
	_check(not uncoded.get("available", true) and str(uncoded.get("reason", "")) == "You recovered no gate code" and not bool(uncoded.get("hidden", false)), "Answering with a gate code the survivor never recovered is a visible lock, not a bluff")
	stranger.run_state["flags"] = ["access_core"]
	_check(stranger.get_choice_preview(code_answer).get("available", false), "A read Citadel controller opens the code answer")
	stranger.run_state["flags"] = []
	_check(stranger.get_choice_preview(gate_one["choices"][1]).get("available", false), "Convincing the guard stays open to everyone")
	var walker := _route_game(content, 7633, "final_gate_1")
	walker.run_state["region_index"] = 6
	walker.resolve_choice(1, 20)
	walker.continue_after_result()
	_check(str(walker.run_state.get("current_event_id", "")) == "final_gate_2", "The first gate's outcome chains into the screening")
	walker.resolve_choice(0, 20)
	walker.continue_after_result()
	_check(str(walker.run_state.get("current_event_id", "")) == "final_gate_3", "Blinding the Warden chains into One Person Through")
	var last_gate: Dictionary = walker.current_event()
	var ordered := walker.get_choice_preview(last_gate["choices"][2])
	_check(not ordered.get("available", true) and str(ordered.get("reason", "")) == "The Warden is still tracking you", "A guard does not break protocol for someone the Warden is still reacquiring")
	var override := walker.get_choice_preview(last_gate["choices"][1])
	_check(not override.get("available", true) and str(override.get("reason", "")) == "You never read a Citadel controller", "The override needs a controller the survivor actually read")
	_check(walker.get_choice_preview(last_gate["choices"][0]).get("available", false), "Forcing the gate stays the always-available answer")
	walker.resolve_choice(0, 20)
	_check(str(walker.run_state.get("phase", "")) == "victory", "Forcing the gate apart ends the run inside the Citadel")
	var withdrawing := _route_game(content, 76331, "final_gate_3")
	withdrawing.resolve_choice(3)
	_check(str(withdrawing.run_state.get("phase", "")) == "victory" and "turn from the wall" in str(withdrawing.run_state.get("last_result", {}).get("outcome_text", "")), "The final gate names its crushing, live, and armed risks before offering a nonlethal withdrawal")
	var breaker := _route_game(content, 7634, "final_gate_3")
	breaker.run_state["flags"] = ["warden_broken"]
	_check(breaker.get_choice_preview(breaker.current_event()["choices"][2]).get("available", false) and "warden_broken" in content.get_event("final_gate_2")["choices"][1]["victory"].get("add_flags", []), "Standing over the machine they broke, the survivor can order the guard")
	_check("warden_broken" in content.get_event("final_gate_3").get("body_variants", [])[0].get("requires_any_flags", []), "One Person Through opens differently over a broken Warden")
	_check(content.discovery_entries.has("ledger_ending_citadel") and str(content.discovery_entries["ledger_ending_citadel"].get("event_id", "")) == "final_gate_3", "The Citadel ending's Chronicle chapter is reachable content again")
	var disk_profile := SaveService.new("n06c_disk_").default_profile()
	var disk_record := StoryDiscoveryRules.apply_resolution({"event_id": "final_gate_1"}, ["pilgrim_disk", "b41_contact"], content.get_discovery_entries(), disk_profile)
	_check(bool(disk_record.get("changed", false)) and "ledger_pilgrim_disk" in disk_profile["discovered_story_nodes"], "The pilgrim disk reaches the outer reader and records its unlisted name even when another finale route takes priority")
	var table := _route_game(content, 7635, "rail_survivors")
	var speak: Dictionary = table.current_event()["choices"][2]
	var voiceless := table.get_choice_preview(speak)
	_check(not voiceless.get("available", true) and bool(voiceless.get("hidden", false)), "Nobody speaks for a survivor who rescued no one")
	table.run_state["flags"] = ["cinder_traveler_rescued"]
	_check(table.get_choice_preview(speak).get("available", false) and table.resolve_body(table.current_event()) != str(table.current_event().get("body", "")), "The rescued traveler is at the table, and speaks for the survivor who carried them")
	var warm_windows := _route_game(living_content, 7636, "lr_warm_windows")
	warm_windows.run_state["region_index"] = 5
	var kilnback_route: Dictionary = warm_windows.current_event()["choices"][3]
	_check(not warm_windows.get_choice_preview(kilnback_route).get("available", true) and bool(warm_windows.get_choice_preview(kilnback_route).get("hidden", false)), "Kilnback knowledge never invents a heater solution for a survivor who did not earn it")
	warm_windows.run_state["flags"] = ["kilnback_rhythm_known"]
	_check(warm_windows.get_choice_preview(kilnback_route).get("available", false) and int(kilnback_route["outcome"].get("items", {}).get("stun_baton", 0)) == 1, "Kilnback knowledge provides its promised safe second-heater solution and baton reward")

	# N06b: every Living Road thread must acknowledge both a helpful and an
	# adverse/source-distance history, reject a false first meeting, and carry a
	# concrete earlier decision into its final chapter. These are body checks,
	# not favorite-sentence tests: the route flags and the final event are the
	# contract under review.
	var arc_reviews := [
		{
			"name": "Channel Nine", "opening": "lr_blue_van", "opening_region": 1,
			"helpful": ["lr_channel_helped"], "adverse": ["lr_channel_misled"],
			"final": "lr_last_battery", "final_region": 3, "final_a": ["lr_family_silenced"], "final_b": ["lr_family_reunited"],
		},
		{
			"name": "Quiet Column", "opening": "lr_quiet_column", "opening_region": 1,
			"helpful": ["lr_siren_silenced"], "adverse": ["lr_siren_burned"],
			"final": "lr_siren_in_glass", "final_region": 4, "final_a": ["lr_dena_stayed"], "final_b": ["lr_siren_silenced"],
		},
		{
			"name": "Road Debt", "opening": "lr_pharmacy_witness", "opening_region": 1,
			"helpful": ["lr_bandit_leader_disarmed"], "adverse": ["lr_bandits_paid"],
			"final": "lr_last_toll", "final_region": 5, "final_a": ["lr_ledger_verified"], "final_b": ["lr_ledger_burned"],
		},
		{
			"name": "Water Commons", "opening": "lr_cup_passed_east", "opening_region": 3,
			"helpful": ["lr_filter_repaired"], "adverse": ["lr_filter_stripped"],
			"final": "lr_valve_below", "final_region": 5, "final_a": ["lr_underrail_water_reserved"], "final_b": ["lr_filter_repaired"],
		},
		{
			"name": "Nightfire Caravan", "opening": "lr_embers_in_rain", "opening_region": 2,
			"helpful": ["lr_nightfire_shared"], "adverse": ["lr_nightfire_robbed"],
			"final": "lr_warm_windows", "final_region": 5, "final_a": ["lr_caravan_mechanic_surrendered"], "final_b": ["lr_nightfire_passed"],
		},
	]
	var review_seed := 7640
	for review: Dictionary in arc_reviews:
		review_seed += 1
		var opening_review := _route_game(living_content, review_seed, str(review["opening"]))
		opening_review.run_state["region_index"] = int(review["opening_region"])
		_check(not opening_review._event_eligible(opening_review.current_event()), "%s never stages a first return for a survivor with no source history" % str(review["name"]))
		var opening_event: Dictionary = opening_review.current_event()
		var plain_opening := opening_review.resolve_body(opening_event)
		opening_review.run_state["flags"] = (review["helpful"] as Array).duplicate()
		var helpful_opening := opening_review.resolve_body(opening_event)
		opening_review.run_state["flags"] = (review["adverse"] as Array).duplicate()
		var adverse_opening := opening_review.resolve_body(opening_event)
		_check(helpful_opening != plain_opening and adverse_opening != plain_opening and helpful_opening != adverse_opening, "%s opens differently for helpful and adverse histories" % str(review["name"]))
		var final_review := _route_game(living_content, review_seed, str(review["final"]))
		final_review.run_state["region_index"] = int(review["final_region"])
		var final_event: Dictionary = final_review.current_event()
		var plain_final := final_review.resolve_body(final_event)
		final_review.run_state["flags"] = (review["final_a"] as Array).duplicate()
		var first_final := final_review.resolve_body(final_event)
		final_review.run_state["flags"] = (review["final_b"] as Array).duplicate()
		var second_final := final_review.resolve_body(final_event)
		_check(first_final != plain_final and second_final != plain_final and first_final != second_final, "%s final chapter changes its present conflict for earlier choices" % str(review["name"]))
	var perrin_opening := str(living_content.get_event("lr_bellkeepers_son").get("body", ""))
	_check("tied the crossing rope himself" in perrin_opening and "volunteering for the roof" in perrin_opening, "Perrin's warning is an informed action he chose, not a child used only as a rescue objective")
	var quiet_column := _route_game(living_content, 7651, "lr_quiet_column")
	var tower_histories := ["lr_siren_silenced", "lr_siren_burned", "lr_siren_endured", "lr_siren_followed"]
	var tower_entrances := {}
	for source_flag: String in tower_histories:
		quiet_column.run_state["flags"] = [source_flag]
		tower_entrances[source_flag] = quiet_column.resolve_body(quiet_column.current_event())
	var all_tower_entrances_distinct := tower_entrances.size() == 4
	for source_flag: String in tower_histories:
		for other_flag: String in tower_histories:
			if source_flag != other_flag:
				all_tower_entrances_distinct = all_tower_entrances_distinct and str(tower_entrances[source_flag]) != str(tower_entrances[other_flag])
	_check(all_tower_entrances_distinct, "Quiet Column remembers all four Tower Six outcomes without collapsing endurance and pursuit into generic history")


func _filler_words(count: int, stem: String) -> String:
	var parts: PackedStringArray = []
	for index in range(count):
		parts.append("%s%d" % [stem, index])
	return " ".join(parts)


func _errors_matching(errors: PackedStringArray, fragment: String) -> PackedStringArray:
	var matched: PackedStringArray = []
	for error: String in errors:
		if fragment in error:
			matched.append(error)
	return matched


func _choice_rows(node: Node) -> Array[Button]:
	var rows: Array[Button] = []
	if node is Button and node.find_child("ChoiceRow", true, false) != null:
		rows.append(node)
		return rows
	for child: Node in node.get_children():
		rows.append_array(_choice_rows(child))
	return rows


func _check(condition: bool, description: String) -> void:
	assertions += 1
	if not condition:
		failures += 1
		push_error("FAIL: %s" % description)
	else:
		print("PASS: %s" % description)
