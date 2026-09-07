class_name GameEngine
extends RefCounted

const CombatRules = preload("res://scripts/domain/combat_resolver.gd")
const NarrativeCombat = preload("res://scripts/domain/narrative_combat.gd")
const ExperienceRules = preload("res://scripts/domain/experience_rules.gd")

const STATS := ["strength", "agility", "wits", "grit", "presence"]
const STAT_LABELS := {
	"strength": "Strength",
	"agility": "Agility",
	"wits": "Wits",
	"grit": "Grit",
	"presence": "Presence",
}
const PRESSURES := ["fatigue", "radiation"]
const EVENTS_PER_REGION := 5
const FINAL_EVENT_ID := "final_gate_1"
const HP_PER_HEART := 50
const MAX_SATIETY := 4
const EQUIPMENT_SLOTS := ["weapon", "armor", "accessory", "backpack"]
const STARTING_ITEM_IDS := [
	"canned_meat", "clean_water", "cloth_bandage",
	"salvage_cleaver", "scrap_vest",
	"pipe_pistol", "pistol_rounds", "runner_jacket",
	"shock_probe", "field_scanner",
	"wrecking_bar", "plated_coat", "scrap_buckler",
	"holdout_revolver", "revolver_rounds", "trader_token",
]
const SURVIVOR_PORTRAIT_IDS := ["survivor_1", "survivor_2", "survivor_3", "survivor_4"]
const OPENING_SAFE_TAG := "opening_safe"
const OPENING_RESOURCE_TAG := "opening_resource"
const OPENING_EQUIPMENT_TAG := "opening_equipment"

var content
var run_state: Dictionary = {}


func _init(repository) -> void:
	content = repository


func create_candidates(seed_value: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var portrait_rng := RandomNumberGenerator.new()
	portrait_rng.seed = seed_value ^ 0x5A17F00D
	var available_portraits := SURVIVOR_PORTRAIT_IDS.duplicate()
	var names := ["Mara Venn", "Jonah Pike", "Iris Vale", "Tomas Reed", "Nia Cross", "Silas Ward", "Oren Knox"]
	var callsigns := ["Cinder", "Latch", "Moth", "Rook", "Sparrow", "Tin", "Ghost", "Patch", "Kite"]
	var candidates: Array = []
	for candidate_index in range(3):
		var stats := {"strength": 1, "agility": 1, "wits": 1, "grit": 1, "presence": 1}
		var points := 10
		while points > 0:
			var stat: String = STATS[rng.randi_range(0, STATS.size() - 1)]
			if int(stats[stat]) < 5:
				stats[stat] = int(stats[stat]) + 1
				points -= 1
		var survivor_name: String = names.pop_at(rng.randi_range(0, names.size() - 1))
		var callsign: String = callsigns.pop_at(rng.randi_range(0, callsigns.size() - 1))
		var portrait_id: String = available_portraits.pop_at(portrait_rng.randi_range(0, available_portraits.size() - 1))
		var hearts := max_hearts_for_grit(int(stats["grit"]))
		var survivor := {
			"id": "candidate_%d" % candidate_index,
			"name": survivor_name,
			"callsign": callsign,
			"portrait_id": portrait_id,
			"stats": stats,
			"vitals": {"health": hearts * HP_PER_HEART, "max_health": hearts * HP_PER_HEART, "max_hearts": hearts, "satiety": MAX_SATIETY},
			"pressures": {"fatigue": 0, "radiation": 0},
			"conditions": [],
			"inventory": _starting_inventory(stats),
			"equipment": {"weapon": "", "armor": "", "accessory": "", "backpack": ""},
		}
		_auto_equip(survivor)
		candidates.append(survivor)
	return candidates


static func max_hearts_for_grit(grit: int) -> int:
	var safe_grit := maxi(1, grit)
	return 3 + mini(safe_grit, 5) + int(floor(float(maxi(safe_grit - 5, 0)) / 5.0))


func _starting_inventory(stats: Dictionary) -> Dictionary:
	var highest_stat := "strength"
	for stat: String in STATS:
		if int(stats[stat]) > int(stats[highest_stat]):
			highest_stat = stat
	var inventory := {"canned_meat": 2, "clean_water": 2, "cloth_bandage": 1}
	match highest_stat:
		"strength":
			inventory["salvage_cleaver"] = 1
			inventory["scrap_vest"] = 1
		"agility":
			inventory["pipe_pistol"] = 1
			inventory["pistol_rounds"] = 6
			inventory["runner_jacket"] = 1
		"wits":
			inventory["shock_probe"] = 1
			inventory["field_scanner"] = 1
		"grit":
			inventory["wrecking_bar"] = 1
			inventory["plated_coat"] = 1
			inventory["scrap_buckler"] = 1
		"presence":
			inventory["holdout_revolver"] = 1
			inventory["revolver_rounds"] = 4
			inventory["trader_token"] = 1
	return inventory


func _auto_equip(survivor: Dictionary) -> void:
	for item_id: String in survivor["inventory"]:
		var item: Dictionary = content.get_item(item_id)
		var slot := str(item.get("equipment_slot", ""))
		if slot != "" and str(survivor["equipment"].get(slot, "")) == "":
			survivor["equipment"][slot] = item_id


func start_run(candidate: Dictionary, seed_value: int) -> Dictionary:
	var normalized_seed: int = absi(seed_value) % 2147483646 + 1
	run_state = {
		"schema_version": 5, "run_id": "%d-%d" % [Time.get_unix_time_from_system(), normalized_seed],
		"seed": normalized_seed, "rng_state": normalized_seed, "status": "active", "phase": "event",
		"rules_version": D20Resolver.RULES_VERSION, "level": ExperienceRules.STARTING_LEVEL, "experience": 0,
		"xp_curve_version": ExperienceRules.RULES_VERSION, "unspent_stat_points": 0, "xp_award_ids": [],
		"checkpoint_xp_awards": [], "rewarded_checkpoints": [], "combat_opportunities_seen_in_region": 0,
		"region_index": 0, "events_in_region": 0, "total_events": 0, "hunger_clock": 0, "supply_seen_in_region": false,
		"event_history": [], "flags": [], "current_event_id": "", "pending_event_id": "", "pending_resolution": {},
		"pending_combat_round": {}, "combat_state": {}, "last_result": {}, "condition_uses": {}, "checkpoint_action": "",
		"last_checkpoint_xp": {}, "defeated_adversaries": [],
		"survivor": candidate.duplicate(true), "started_at": Time.get_unix_time_from_system(),
	}
	_select_next_event()
	return run_state


func restore_run(saved_state: Dictionary) -> void:
	run_state = saved_state.duplicate(true)


func current_region() -> Dictionary:
	var ordered: Array = content.ordered_regions()
	var index := int(run_state.get("region_index", 0))
	return ordered[index] if index >= 0 and index < ordered.size() else {}


func current_event() -> Dictionary:
	return content.get_event(str(run_state.get("current_event_id", "")))


func experience_progress() -> Dictionary:
	return ExperienceRules.progress(int(run_state.get("experience", 0)))


func award_experience(amount: int, source: String, source_id: String) -> Dictionary:
	var old_xp := int(run_state.get("experience", 0))
	var old_level := int(run_state.get("level", ExperienceRules.level_for_xp(old_xp)))
	var result := {
		"source": source,
		"source_id": source_id,
		"awarded": 0,
		"old_experience": old_xp,
		"new_experience": old_xp,
		"old_level": old_level,
		"new_level": old_level,
		"levels_gained": 0,
		"points_gained": 0,
		"duplicate": false,
	}
	if amount <= 0 or source_id.is_empty():
		return result
	var award_ids: Array = run_state.get("xp_award_ids", [])
	if source_id in award_ids:
		result["duplicate"] = true
		return result
	award_ids.append(source_id)
	run_state["xp_award_ids"] = award_ids
	var new_xp := old_xp + amount
	var new_level := ExperienceRules.level_for_xp(new_xp)
	var levels_gained := maxi(0, new_level - old_level)
	run_state["experience"] = new_xp
	run_state["level"] = new_level
	if levels_gained > 0:
		run_state["unspent_stat_points"] = int(run_state.get("unspent_stat_points", 0)) + levels_gained
	result["awarded"] = amount
	result["new_experience"] = new_xp
	result["new_level"] = new_level
	result["levels_gained"] = levels_gained
	result["points_gained"] = levels_gained
	return result


func _event_xp_source_id(kind: String) -> String:
	return "%s:r%d:s%d:h%d:%s:%s" % [str(run_state.get("run_id", "run")), int(run_state.get("region_index", 0)), int(run_state.get("events_in_region", 0)), run_state.get("event_history", []).size(), str(run_state.get("current_event_id", "event")), kind]


func _threat_label(threat: int) -> String:
	if threat >= 18:
		return "APEX"
	if threat >= 16:
		return "SEVERE"
	if threat >= 14:
		return "DANGEROUS"
	if threat >= 12:
		return "MODERATE"
	return "LOW"


func get_choice_preview(choice: Dictionary) -> Dictionary:
	var availability := _choice_availability(choice)
	if not availability["available"]:
		return availability
	if choice.has("combat"):
		var adversary: Dictionary = content.get_adversary(str(choice.get("combat", {}).get("adversary_id", current_event().get("adversary_id", ""))))
		var profile := get_player_weapon_profile()
		var threat := int(adversary.get("threat", 10))
		var enemy_combat: Dictionary = adversary.get("combat", {})
		var can_flee := bool(choice.get("combat", {}).get("can_flee", true))
		var flee_preview := _flee_preview_for_adversary(adversary)
		var flee_text := "Flee %d%% • Need %d+" % [int(flee_preview.get("chance", 0)), int(flee_preview.get("required_roll", 20))] if can_flee else "Flee unavailable"
		return {
			"available": true,
			"chance": -1,
			"combat": true,
			"stat": str(profile["attack_stat"]),
			"xp_reward": int(adversary.get("xp_reward", 0)),
			"threat": threat,
			"threat_label": _threat_label(threat),
			"enemy_damage_min": int(enemy_combat.get("damage_min", 0)),
			"enemy_damage_max": int(enemy_combat.get("damage_max", 0)),
			"flee_chance": int(flee_preview.get("chance", 0)) if can_flee else -1,
			"description": "FIGHT • %s THREAT • +%d XP\nYour damage %d-%d • Enemy damage %d-%d • %s" % [_threat_label(threat), int(adversary.get("xp_reward", 0)), profile["damage_min"], profile["damage_max"], int(enemy_combat.get("damage_min", 0)), int(enemy_combat.get("damage_max", 0)), flee_text],
		}
	var check: Dictionary = choice.get("check", {})
	if check.is_empty():
		return {"available": true, "chance": -1, "description": "CERTAIN"}
	var stat := str(check.get("stat", "wits"))
	var stat_value := int(run_state["survivor"]["stats"].get(stat, 0))
	var modifiers := _collect_modifiers(stat, str(choice.get("approach", "")), int(choice.get("modifier", 0)))
	var effective_stat := stat_value
	for modifier: Dictionary in modifiers:
		effective_stat += int(modifier["value"])
	effective_stat = maxi(0, effective_stat)
	var difficulty := str(check.get("difficulty", "risky"))
	var chance := D20Resolver.calculate_percentage(effective_stat, difficulty)
	var required_roll := D20Resolver.required_roll(chance)
	var stat_label := str(STAT_LABELS.get(stat, stat.capitalize()))
	return {"available": true, "chance": chance, "required_roll": required_roll, "stat": stat, "stat_label": stat_label, "stat_value": stat_value, "effective_stat": effective_stat, "difficulty": difficulty, "description": "%s • %d%% SUCCESS • NEED %d+" % [stat_label.to_upper(), chance, required_roll], "modifiers": modifiers}


func prepare_choice(choice_index: int) -> Dictionary:
	if str(run_state.get("phase", "")) != "event":
		return {"error": "No event is awaiting a choice"}
	var choices: Array = current_event().get("choices", [])
	if choice_index < 0 or choice_index >= choices.size():
		return {"error": "Invalid choice"}
	var choice: Dictionary = choices[choice_index]
	var preview := get_choice_preview(choice)
	if not preview.get("available", false):
		return {"error": str(preview.get("reason", "Choice unavailable"))}
	if choice.has("combat"):
		return start_combat(choice_index)
	var check: Dictionary = choice.get("check", {})
	var roll := 0 if check.is_empty() else _random_range(1, 20)
	run_state["pending_resolution"] = {
		"event_id": str(run_state.get("current_event_id", "")),
		"choice_index": choice_index,
		"roll": roll,
		"rules_version": D20Resolver.RULES_VERSION,
		"success_chance": int(preview.get("chance", 100)),
		"required_roll": int(preview.get("required_roll", D20Resolver.required_roll(int(preview.get("chance", 100))))),
		"effective_stat": int(preview.get("effective_stat", 0)),
		"stat": str(preview.get("stat", "")),
		"stat_label": str(preview.get("stat_label", "")),
		"stat_value": int(preview.get("stat_value", 0)),
		"difficulty": str(preview.get("difficulty", "")),
		"modifiers": preview.get("modifiers", []).duplicate(true),
	}
	run_state["phase"] = "roll_pending"
	return {"prepared": true, "requires_roll": roll > 0}


func resolve_prepared_choice() -> Dictionary:
	if str(run_state.get("phase", "")) not in ["roll_pending", "resolving"]:
		return {"error": "No prepared choice is waiting"}
	var pending: Dictionary = run_state.get("pending_resolution", {})
	if pending.is_empty() or str(pending.get("event_id", "")) != str(run_state.get("current_event_id", "")):
		return {"error": "Prepared choice does not match the current event"}
	var choice_index := int(pending.get("choice_index", -1))
	var roll := int(pending.get("roll", 0))
	run_state["phase"] = "event"
	var result := _resolve_choice_internal(choice_index, roll, pending)
	if not result.has("error"):
		run_state["pending_resolution"] = {}
	else:
		run_state["phase"] = "roll_pending"
	return result


func resolve_choice(choice_index: int, forced_roll: int = -1) -> Dictionary:
	return _resolve_choice_internal(choice_index, forced_roll, {})


func _resolve_choice_internal(choice_index: int, forced_roll: int = -1, prepared: Dictionary = {}) -> Dictionary:
	if str(run_state.get("phase", "")) != "event":
		return {"error": "No event is awaiting a choice"}
	var event := current_event()
	var choices: Array = event.get("choices", [])
	if choice_index < 0 or choice_index >= choices.size():
		return {"error": "Invalid choice"}
	var choice: Dictionary = choices[choice_index]
	if choice.has("combat"):
		return start_combat(choice_index)
	var preview := get_choice_preview(choice)
	if not preview.get("available", false):
		return {"error": str(preview.get("reason", "Choice unavailable"))}
	_apply_costs(choice.get("costs", {}))
	var check: Dictionary = choice.get("check", {})
	var resolution: Dictionary
	var outcome_key := "outcome"
	if check.is_empty():
		resolution = {"rules_version": D20Resolver.RULES_VERSION, "roll": 0, "outcome": "outcome", "succeeded": true, "breakdown": [], "success_chance": 100}
	else:
		var roll := forced_roll if forced_roll >= 1 and forced_roll <= 20 else _random_range(1, 20)
		var stat := str(check.get("stat", "wits"))
		var stat_value := int(run_state["survivor"]["stats"].get(stat, 0))
		var modifiers := _collect_modifiers(stat, str(choice.get("approach", "")), int(choice.get("modifier", 0)))
		if not prepared.is_empty() and int(prepared.get("rules_version", 2)) < D20Resolver.RULES_VERSION:
			var legacy_dc: int = content.get_legacy_v2_dc(str(event.get("id", "")), choice_index)
			if legacy_dc <= 0:
				return {"error": "Legacy prepared check could not be recovered"}
			resolution = D20Resolver.resolve_legacy(roll, stat_value, legacy_dc, modifiers)
		else:
			var effective_stat := int(prepared.get("effective_stat", preview.get("effective_stat", stat_value)))
			var difficulty := str(prepared.get("difficulty", preview.get("difficulty", "risky")))
			var stored_modifiers: Array = prepared.get("modifiers", modifiers)
			var stored_chance := int(prepared.get("success_chance", preview.get("chance", -1)))
			resolution = D20Resolver.resolve_percentage(roll, stat_value, effective_stat, difficulty, stored_modifiers, stored_chance)
		outcome_key = str(resolution["outcome"])
	var outcome: Dictionary = choice.get(outcome_key, choice.get("success" if resolution.get("succeeded", false) else "failure", {}))
	var changes: Array = []
	var condition_changes: Array = []
	var xp_source := _event_xp_source_id("choice")
	if not check.is_empty():
		_tick_temporary_conditions()
	_apply_outcome(outcome, changes, condition_changes)
	var xp_awards := _event_experience_awards(event, check, resolution, outcome, xp_source)
	_record_event(event)
	return _finish_event_result(event, choice, resolution, outcome, changes, condition_changes, xp_awards)


func _finish_event_result(event: Dictionary, choice: Dictionary, resolution: Dictionary, outcome: Dictionary, changes: Array, condition_changes: Array = [], xp_awards: Array = []) -> Dictionary:
	var result := {"event_id": str(event.get("id", "")), "event_title": str(event.get("title", "Event")), "choice": str(choice.get("label", "Choice")), "resolution": resolution, "outcome_text": str(outcome.get("text", "The road moves on.")), "changes": changes, "condition_changes": condition_changes, "xp_awards": xp_awards}
	run_state["last_result"] = result
	_update_death_state()
	if str(run_state.get("phase", "")) == "death":
		return result
	if bool(outcome.get("victory", false)):
		run_state["status"] = "victory"
		run_state["phase"] = "victory"
	else:
		run_state["phase"] = "result"
	return result


func _event_experience_awards(event: Dictionary, check: Dictionary, resolution: Dictionary, outcome: Dictionary, source_prefix: String) -> Array:
	var awards: Array = []
	if int(run_state.get("survivor", {}).get("vitals", {}).get("health", 0)) <= 0:
		return awards
	if not check.is_empty() and bool(resolution.get("succeeded", false)):
		var check_xp := ExperienceRules.check_bonus(str(check.get("difficulty", "")))
		_append_xp_award(awards, award_experience(check_xp, "%s success" % str(check.get("difficulty", "risky")).capitalize(), "%s:check" % source_prefix))
	var milestone_xp := int(outcome.get("experience", 0))
	_append_xp_award(awards, award_experience(milestone_xp, "Story milestone", "%s:milestone" % source_prefix))
	var journey_complete: bool = str(run_state.get("pending_event_id", "")).is_empty() and int(run_state.get("region_index", 0)) < content.ordered_regions().size()
	if journey_complete:
		_append_xp_award(awards, award_experience(ExperienceRules.JOURNEY_XP, "Journey survived", "%s:journey" % source_prefix))
	return awards


func _append_xp_award(awards: Array, award: Dictionary) -> void:
	if int(award.get("awarded", 0)) > 0:
		awards.append(award)


func continue_after_result() -> void:
	if str(run_state.get("phase", "")) != "result":
		return
	var pending := str(run_state.get("pending_event_id", ""))
	run_state["last_result"] = {}
	if pending != "":
		run_state["current_event_id"] = pending
		run_state["pending_event_id"] = ""
		run_state["phase"] = "event"
		return
	_apply_travel_pressure()
	_apply_hunger_tick()
	_update_death_state()
	if str(run_state.get("phase", "")) == "death":
		return
	run_state["events_in_region"] = int(run_state["events_in_region"]) + 1
	run_state["total_events"] = int(run_state["total_events"]) + 1
	if int(run_state["events_in_region"]) >= EVENTS_PER_REGION:
		run_state["current_event_id"] = ""
		run_state["phase"] = "checkpoint"
		run_state["checkpoint_action"] = ""
		_award_checkpoint_experience()
	else:
		_select_next_event()
		run_state["phase"] = "event"


func rest_at_checkpoint(food_id: String = "") -> Dictionary:
	if str(run_state.get("phase", "")) != "checkpoint":
		return {"success": false, "text": "Rest is only possible at a checkpoint."}
	if str(run_state.get("checkpoint_action", "")) != "":
		return {"success": false, "text": "You already chose how to leave this checkpoint."}
	var selected := food_id if food_id != "" else _find_inventory_item_with_tag("food")
	if selected == "" or get_item_quantity(selected) <= 0 or "food" not in content.get_item(selected).get("tags", []):
		return {"success": false, "text": "Choose one available food item to rest."}
	var nutrition := int(content.get_item(selected).get("effects", {}).get("satiety", 0))
	_change_item(selected, -1)
	_change_satiety(nutrition)
	var fatigue_before := int(run_state["survivor"]["pressures"].get("fatigue", 0))
	run_state["survivor"]["pressures"]["fatigue"] = 0
	_change_health(25)
	run_state["checkpoint_action"] = "rest"
	return {"success": true, "text": "You eat %s, dress your wounds, and sleep lightly. Satiety +%d, Fatigue %d → 0, HP +25." % [content.get_item(selected).get("name", selected), nutrition, fatigue_before]}


func press_on_from_checkpoint() -> Dictionary:
	if str(run_state.get("phase", "")) != "checkpoint":
		return {"success": false, "text": "You are not at a checkpoint."}
	if str(run_state.get("checkpoint_action", "")) != "":
		return {"success": false, "text": "You already chose how to leave this checkpoint."}
	_apply_condition("momentum")
	run_state["checkpoint_action"] = "press_on"
	leave_checkpoint()
	return {"success": true, "text": "You move before comfort can soften your edge. Momentum grants +1 to the next checked choice."}


func available_food_items() -> Array[String]:
	var result: Array[String] = []
	for item_id: String in run_state.get("survivor", {}).get("inventory", {}):
		if get_item_quantity(item_id) > 0 and "food" in content.get_item(item_id).get("tags", []):
			result.append(item_id)
	return result


func checkpoint_upgrade_preview(stat: String, proposed_value: int) -> Dictionary:
	if stat not in STATS or run_state.is_empty():
		return {}
	var current := int(run_state.get("survivor", {}).get("stats", {}).get(stat, 0))
	var proposed := maxi(current, proposed_value)
	var old_hearts := max_hearts_for_grit(int(run_state["survivor"]["stats"].get("grit", 1)))
	var preview_grit := proposed if stat == "grit" else int(run_state["survivor"]["stats"].get("grit", 1))
	var new_hearts := max_hearts_for_grit(preview_grit)
	return {
		"stat": stat,
		"current": current,
		"proposed": proposed,
		"raw_before": D20Resolver.raw_stat_chance(current),
		"raw_after": D20Resolver.raw_stat_chance(proposed),
		"heart_gain": maxi(0, new_hearts - old_hearts),
	}


func confirm_stat_allocation(proposed_stats: Dictionary) -> Dictionary:
	if str(run_state.get("phase", "")) != "checkpoint":
		return {"success": false, "text": "Stat points can only be allocated at a checkpoint."}
	var current: Dictionary = run_state["survivor"]["stats"]
	var spent := 0
	for stat: String in STATS:
		var old_value := int(current.get(stat, 0))
		var new_value := int(proposed_stats.get(stat, old_value))
		if new_value < old_value:
			return {"success": false, "text": "A confirmed stat cannot be reduced."}
		spent += new_value - old_value
	if spent <= 0:
		return {"success": false, "text": "Allocate at least one available point."}
	if spent > int(run_state.get("unspent_stat_points", 0)):
		return {"success": false, "text": "That draft spends more points than are available."}
	var old_hearts := max_hearts_for_grit(int(current.get("grit", 1)))
	for stat: String in STATS:
		current[stat] = int(proposed_stats.get(stat, current.get(stat, 0)))
	var new_hearts := max_hearts_for_grit(int(current.get("grit", 1)))
	var gained_hearts := maxi(0, new_hearts - old_hearts)
	if gained_hearts > 0:
		var vitals: Dictionary = run_state["survivor"]["vitals"]
		vitals["max_hearts"] = new_hearts
		vitals["max_health"] = new_hearts * HP_PER_HEART
		vitals["health"] = mini(int(vitals["max_health"]), int(vitals.get("health", 0)) + gained_hearts * HP_PER_HEART)
	run_state["unspent_stat_points"] = int(run_state.get("unspent_stat_points", 0)) - spent
	return {"success": true, "spent": spent, "heart_gain": gained_hearts, "text": "%d stat point%s committed." % [spent, "" if spent == 1 else "s"]}


func _award_checkpoint_experience() -> Dictionary:
	var checkpoint_index := int(run_state.get("region_index", 0))
	if checkpoint_index < 0 or checkpoint_index >= content.ordered_regions().size():
		return {}
	var rewarded: Array = run_state.get("checkpoint_xp_awards", [])
	for rewarded_index: Variant in rewarded:
		if int(rewarded_index) == checkpoint_index:
			return {}
	rewarded.append(checkpoint_index)
	run_state["checkpoint_xp_awards"] = rewarded
	var award := award_experience(ExperienceRules.CHECKPOINT_XP, "Regional checkpoint", "checkpoint:%d" % checkpoint_index)
	run_state["last_checkpoint_xp"] = award
	return award


func leave_checkpoint() -> void:
	if str(run_state.get("phase", "")) != "checkpoint":
		return
	run_state["region_index"] = int(run_state["region_index"]) + 1
	run_state["events_in_region"] = 0
	run_state["supply_seen_in_region"] = false
	run_state["combat_opportunities_seen_in_region"] = 0
	run_state["last_checkpoint_xp"] = {}
	if int(run_state["region_index"]) >= content.ordered_regions().size():
		run_state["current_event_id"] = FINAL_EVENT_ID
	else:
		_change_pressure("fatigue", 5)
		_select_next_event()
	run_state["checkpoint_action"] = ""
	run_state["phase"] = "event"


func equip_item(item_id: String) -> Dictionary:
	var reason := equipment_lock_reason(item_id)
	if reason != "":
		return {"success": false, "text": reason}
	var item: Dictionary = content.get_item(item_id)
	if item.is_empty() or get_item_quantity(item_id) <= 0:
		return {"success": false, "text": "That item is not available."}
	var slot := str(item.get("equipment_slot", ""))
	if slot == "":
		return {"success": false, "text": "That item cannot be equipped."}
	if bool(item.get("two_handed", false)):
		var accessory: Dictionary = content.get_item(str(run_state["survivor"]["equipment"].get("accessory", "")))
		if bool(accessory.get("shield", false)):
			run_state["survivor"]["equipment"]["accessory"] = ""
	run_state["survivor"]["equipment"][slot] = item_id
	return {"success": true, "text": "%s equipped." % item.get("name", item_id)}


func unequip_item(slot: String) -> Dictionary:
	if not run_state.get("combat_state", {}).is_empty():
		return {"success": false, "text": "Equipment cannot change during combat."}
	if slot not in EQUIPMENT_SLOTS:
		return {"success": false, "text": "That equipment slot does not exist."}
	var item_id := str(run_state.get("survivor", {}).get("equipment", {}).get(slot, ""))
	if item_id == "":
		return {"success": false, "text": "That slot is already empty."}
	run_state["survivor"]["equipment"][slot] = ""
	return {"success": true, "item_id": item_id, "slot": slot, "text": "%s unequipped." % content.get_item(item_id).get("name", item_id)}


func drop_item(item_id: String, quantity: int) -> Dictionary:
	var owned := get_item_quantity(item_id)
	if content.get_item(item_id).is_empty() or owned <= 0:
		return {"success": false, "text": "That item is not in your inventory."}
	if quantity <= 0 or quantity > owned:
		return {"success": false, "text": "Choose a valid quantity to drop."}
	for slot: String in EQUIPMENT_SLOTS:
		if str(run_state["survivor"]["equipment"].get(slot, "")) == item_id:
			return {"success": false, "text": "Unequip this item before dropping it."}
	var item: Dictionary = content.get_item(item_id)
	var freed_weight := snappedf(float(item.get("weight", 0.0)) * quantity, 0.1)
	_change_item(item_id, -quantity)
	return {
		"success": true,
		"item_id": item_id,
		"quantity": quantity,
		"freed_weight": freed_weight,
		"text": "Dropped %s%s." % [str(item.get("name", item_id)), " ×%d" % quantity if quantity > 1 else ""],
	}


func use_item(item_id: String) -> Dictionary:
	if not run_state.get("combat_state", {}).is_empty():
		return {"success": false, "text": "Use the combat Item action; the enemy will respond."}
	return _use_item_internal(item_id)


func _use_item_internal(item_id: String) -> Dictionary:
	var item: Dictionary = content.get_item(item_id)
	if item.is_empty() or get_item_quantity(item_id) <= 0 or not bool(item.get("consumable", false)):
		return {"success": false, "text": "That item cannot be used."}
	if item_id == "smoke_bomb":
		return {"success": false, "text": "Smoke bombs are used by specific event choices."}
	var effects: Dictionary = item.get("effects", {})
	var removed_conditions: Array[String] = []
	var added_conditions: Array[String] = []
	if effects.has("health"):
		_change_health(int(effects["health"]))
	if effects.has("satiety"):
		_change_satiety(int(effects["satiety"]))
	for pressure: String in effects.get("pressures", {}):
		_change_pressure(pressure, int(effects["pressures"][pressure]))
	for condition_id: Variant in effects.get("remove_conditions", []):
		var removed_id := str(condition_id)
		if removed_id in run_state["survivor"]["conditions"]:
			removed_conditions.append(removed_id)
		_remove_condition(removed_id)
	for condition_id: Variant in effects.get("add_conditions", []):
		var added_id := str(condition_id)
		if added_id not in run_state["survivor"]["conditions"]:
			added_conditions.append(added_id)
		_apply_condition(added_id)
	_change_item(item_id, -1)
	_update_death_state()
	return {
		"success": true,
		"item_id": item_id,
		"removed_conditions": removed_conditions,
		"added_conditions": added_conditions,
		"text": str(item.get("use_text", "Item used.")),
	}


func combat_usable_items() -> Array[String]:
	var result: Array[String] = []
	for item_id: String in run_state.get("survivor", {}).get("inventory", {}):
		var item: Dictionary = content.get_item(item_id)
		var smoke_allowed := is_narrative_combat() and bool(run_state.get("combat_state", {}).get("can_flee", true))
		if get_item_quantity(item_id) > 0 and bool(item.get("consumable", false)) and (item_id != "smoke_bomb" or smoke_allowed):
			result.append(item_id)
	result.sort_custom(func(a: String, b: String) -> bool:
		var pa := _combat_item_priority(a)
		var pb := _combat_item_priority(b)
		return pa < pb if pa != pb else a < b
	)
	return result


func _combat_item_priority(item_id: String) -> int:
	var effects: Dictionary = content.get_item(item_id).get("effects", {})
	for condition_id: Variant in effects.get("remove_conditions", []):
		if condition_id in run_state["survivor"].get("conditions", []):
			return 0
	if int(effects.get("health", 0)) > 0:
		return 1
	if effects.has("satiety") or effects.has("pressures"):
		return 2
	return 3


func equipment_lock_reason(item_id: String) -> String:
	if not run_state.get("combat_state", {}).is_empty():
		return "Equipment cannot change during combat."
	var item: Dictionary = content.get_item(item_id)
	var weapon: Dictionary = content.get_item(str(run_state.get("survivor", {}).get("equipment", {}).get("weapon", "")))
	if bool(item.get("shield", false)) and bool(weapon.get("two_handed", false)):
		return "This weapon needs two hands. Unequip it before equipping a shield."
	return ""


func is_narrative_combat() -> bool:
	return int(run_state.get("combat_state", {}).get("combat_rules_version", 1)) == NarrativeCombat.VERSION


func combat_effective_stats() -> Dictionary:
	var stats: Dictionary = run_state.get("survivor", {}).get("stats", {}).duplicate(true)
	for stat: String in STATS:
		var value := int(stats.get(stat, 1))
		for modifier: Dictionary in _collect_modifiers(stat, "", 0):
			value += int(modifier.get("value", 0))
		stats[stat] = maxi(0, value)
	return stats


func combat_action_preview(action: String, item_id: String = "") -> Dictionary:
	return NarrativeCombat.preview(self, action, item_id)


func get_total_weight() -> float:
	var total := 0.0
	for item_id: String in run_state.get("survivor", {}).get("inventory", {}):
		total += float(content.get_item(item_id).get("weight", 0.0)) * int(run_state["survivor"]["inventory"][item_id])
	return snappedf(total, 0.1)


func get_carry_capacity() -> float:
	if run_state.is_empty():
		return 0.0
	var strength := int(run_state["survivor"]["stats"].get("strength", 1))
	var capacity := 10.0 + strength * 3.0
	var backpack_id := str(run_state["survivor"]["equipment"].get("backpack", ""))
	if backpack_id != "":
		capacity += float(content.get_item(backpack_id).get("capacity_bonus", 0.0))
	return capacity


func get_item_quantity(item_id: String) -> int:
	return int(run_state.get("survivor", {}).get("inventory", {}).get(item_id, 0))


func get_player_weapon_profile() -> Dictionary:
	if is_narrative_combat() or run_state.get("combat_state", {}).is_empty():
		return NarrativeCombat.weapon_profile(self)
	var weapon_id := str(run_state.get("survivor", {}).get("equipment", {}).get("weapon", ""))
	var item: Dictionary = content.get_item(weapon_id)
	var ammo_type := str(item.get("ammo_type", ""))
	var ammunition_needed := maxi(0, int(item.get("combat", {}).get("ammo_per_attack", 0)))
	var loaded := ammo_type == "" or get_item_quantity(ammo_type) >= ammunition_needed
	return CombatRules.weapon_profile(item, _effective_stats(), loaded)


func summary() -> Dictionary:
	var survivor: Dictionary = run_state.get("survivor", {})
	var condition_names: Array[String] = []
	for condition_id: Variant in survivor.get("conditions", []):
		condition_names.append(str(content.get_condition(str(condition_id)).get("name", condition_id)))
	var equipment_names: Array[String] = []
	for slot: String in EQUIPMENT_SLOTS:
		var item_id := str(survivor.get("equipment", {}).get(slot, ""))
		if item_id != "":
			equipment_names.append(str(content.get_item(item_id).get("name", item_id)))
	var defeated_names: Array[String] = []
	var strongest_name := "None"
	var strongest_threat := -1
	for adversary_id: Variant in run_state.get("defeated_adversaries", []):
		var adversary: Dictionary = content.get_adversary(str(adversary_id))
		defeated_names.append(str(adversary.get("name", adversary_id)))
		if int(adversary.get("threat", -1)) > strongest_threat:
			strongest_threat = int(adversary.get("threat", -1))
			strongest_name = str(adversary.get("name", adversary_id))
	return {
		"run_id": str(run_state.get("run_id", "")),
		"survivor": str(survivor.get("name", "Unknown")),
		"callsign": str(survivor.get("callsign", "")),
		"result": str(run_state.get("status", "abandoned")),
		"regions_reached": min(int(run_state.get("region_index", 0)) + 1, content.ordered_regions().size()),
		"region": str(current_region().get("name", "East Citadel")),
		"events_resolved": int(run_state.get("total_events", 0)),
		"level": int(run_state.get("level", ExperienceRules.STARTING_LEVEL)),
		"experience": int(run_state.get("experience", 0)),
		"stat_points_earned": maxi(0, int(run_state.get("level", ExperienceRules.STARTING_LEVEL)) - ExperienceRules.STARTING_LEVEL),
		"enemies_defeated": defeated_names,
		"strongest_enemy": strongest_name,
		"xp_lost": int(run_state.get("experience", 0)),
		"cause": _death_cause_summary(),
		"conditions": condition_names,
		"equipment": equipment_names,
		"ended_at": Time.get_unix_time_from_system(),
	}


func _death_cause_summary() -> String:
	if str(run_state.get("status", "")) != "dead":
		return ""
	var notice := str(run_state.get("last_survival_notice", ""))
	if notice.begins_with("STARVATION"):
		return "Starvation after travelling without food."
	var combat: Dictionary = run_state.get("combat_state", {})
	if not combat.is_empty():
		var adversary: Dictionary = content.get_adversary(str(combat.get("adversary_id", "")))
		return "Killed by %s during %s." % [adversary.get("name", "an enemy"), current_event().get("title", "a fight")]
	var result: Dictionary = run_state.get("last_result", {})
	if not result.is_empty():
		return "Fatal consequences after choosing \"%s\" during %s." % [result.get("choice", "an uncertain path"), result.get("event_title", "the journey")]
	return "The road claimed the survivor."


func start_combat(choice_index: int) -> Dictionary:
	if str(run_state.get("phase", "")) != "event":
		return {"error": "Combat cannot start now"}
	var event := current_event()
	var choices: Array = event.get("choices", [])
	if choice_index < 0 or choice_index >= choices.size():
		return {"error": "Invalid combat choice"}
	var choice: Dictionary = choices[choice_index]
	var combat: Dictionary = choice.get("combat", {})
	var adversary_id := str(combat.get("adversary_id", event.get("adversary_id", "")))
	var adversary: Dictionary = content.get_adversary(adversary_id)
	if combat.is_empty() or adversary.is_empty():
		return {"error": "Combat definition is incomplete"}
	_apply_costs(choice.get("costs", {}))
	var maximum := int(adversary.get("combat", {}).get("max_health", 1))
	run_state["combat_state"] = {"event_id": str(event.get("id", "")), "choice_index": choice_index, "adversary_id": adversary_id, "encounter_id": _event_xp_source_id("combat:%s" % adversary_id), "enemy_health": maximum, "enemy_max_health": maximum, "round": 0, "guarded": false, "next_attack_multiplier": 1.0, "exposed": false, "can_flee": bool(combat.get("can_flee", true)), "log": [{"kind": "system", "text": "%s closes in. Combat begins." % adversary.get("name", "Enemy")}], "last_round": {}}
	run_state["phase"] = "combat"
	NarrativeCombat.initialize(self)
	return {"combat_started": true}


func get_flee_preview() -> Dictionary:
	var adversary: Dictionary = content.get_adversary(str(run_state.get("combat_state", {}).get("adversary_id", "")))
	return _flee_preview_for_adversary(adversary)


func _flee_preview_for_adversary(adversary: Dictionary) -> Dictionary:
	var difficulty := str(adversary.get("combat", {}).get("flee_difficulty", "risky"))
	var stat_value := int(run_state.get("survivor", {}).get("stats", {}).get("agility", 1))
	var modifiers := _collect_modifiers("agility", "evade", 0)
	var effective_stat := stat_value
	for modifier: Dictionary in modifiers:
		effective_stat += int(modifier.get("value", 0))
	effective_stat = maxi(0, effective_stat)
	var chance := D20Resolver.calculate_percentage(effective_stat, difficulty)
	return {"stat_value": stat_value, "effective_stat": effective_stat, "difficulty": difficulty, "modifiers": modifiers, "chance": chance, "required_roll": D20Resolver.required_roll(chance)}


func combat_presentation_snapshot() -> Dictionary:
	var state: Dictionary = run_state.get("combat_state", {})
	if state.is_empty():
		return {}
	var survivor: Dictionary = run_state.get("survivor", {})
	var adversary: Dictionary = content.get_adversary(str(state.get("adversary_id", "")))
	var profile := get_player_weapon_profile()
	var armor_rating := _armor_rating()
	var armor_percent := roundi(float(CombatRules.ARMOR_PERCENT.get(armor_rating, 0.0)) * 100.0)
	var ammo_text := ""
	if str(profile.get("ammo_type", "")) != "":
		ammo_text = "%s %d" % [content.get_item(str(profile["ammo_type"])).get("name", "Ammo"), get_item_quantity(str(profile["ammo_type"]))]
	var condition_names: Array[String] = []
	for condition_id: Variant in survivor.get("conditions", []):
		condition_names.append(str(content.get_condition(str(condition_id)).get("name", condition_id)))
	var status_labels: Array[String] = []
	if bool(state.get("exposed", false)):
		status_labels.append("EXPOSED +25%")
	if float(state.get("next_attack_multiplier", 1.0)) > 1.0:
		status_labels.append("GUARD BONUS +25%")
	status_labels.append_array(condition_names)
	if bool(state.get("riposte", false)):
		status_labels.append("RIPOSTE • NEXT ACTION")
	if bool(state.get("opening", false)):
		status_labels.append("OPENING • NEXT ACTION")
	if int(state.get("interrupt_cooldown", 0)) > 0:
		status_labels.append("INTERRUPT RECHARGING • %d" % int(state["interrupt_cooldown"]))
	var pending: Dictionary = run_state.get("pending_combat_round", {})
	return {
		"round": int(state.get("round", 0)) + 1,
		"combat_rules_version": int(state.get("combat_rules_version", 1)),
		"enemy_tell": str(state.get("committed_move", {}).get("tell", "")),
		"prepared_preview": pending.get("preview", {}).duplicate(true),
		"player": {
			"name": str(survivor.get("callsign", "YOU")),
			"portrait_id": str(survivor.get("portrait_id", "survivor")),
			"health": int(survivor.get("vitals", {}).get("health", 0)),
			"max_health": int(survivor.get("vitals", {}).get("max_health", 1)),
			"weapon": "%s • EMPTY → UNARMED" % str(profile.get("equipped_name", "Weapon")) if bool(profile.get("unloaded", false)) else str(profile.get("name", "Unarmed")),
			"ammo": ammo_text,
		},
		"enemy": {
			"name": str(adversary.get("name", "Enemy")),
			"portrait_id": str(adversary.get("portrait_id", "enemy")),
			"health": int(state.get("enemy_health", 0)),
			"max_health": int(state.get("enemy_max_health", 1)),
			"weapon": str(adversary.get("combat", {}).get("weapon_name", "Attack")),
			"critical_condition": str(adversary.get("combat", {}).get("critical_condition", "")),
		},
		"armor": {"rating": armor_rating, "flat": armor_rating * 3, "percent": armor_percent},
		"status_labels": status_labels,
		"pending_action": str(pending.get("action", "")),
		"can_flee": bool(state.get("can_flee", true)),
		"log": state.get("log", []).duplicate(true),
	}


func prepare_combat_action(action: String, item_id: String = "") -> Dictionary:
	if str(run_state.get("phase", "")) != "combat":
		return {"error": "No combat action is available"}
	if is_narrative_combat():
		return NarrativeCombat.prepare(self, action, item_id)
	if action not in ["attack", "guard", "use_item", "flee"]:
		return {"error": "Unknown combat action"}
	if action == "flee" and not bool(run_state["combat_state"].get("can_flee", true)):
		return {"error": "There is no escape from this fight"}
	if action == "use_item" and item_id not in combat_usable_items():
		return {"error": "Choose an available consumable"}
	var pending := {"action": action, "item_id": item_id, "player_roll": 0, "enemy_roll": _random_range(1, 20)}
	if action in ["attack", "flee"]:
		pending["player_roll"] = _random_range(1, 20)
	if action == "flee":
		var flee_preview := get_flee_preview()
		pending["flee_rules_version"] = D20Resolver.RULES_VERSION
		pending["flee_chance"] = int(flee_preview["chance"])
		pending["flee_effective_stat"] = int(flee_preview["effective_stat"])
		pending["flee_stat_value"] = int(flee_preview["stat_value"])
		pending["flee_difficulty"] = str(flee_preview["difficulty"])
		pending["flee_modifiers"] = flee_preview["modifiers"].duplicate(true)
	run_state["pending_combat_round"] = pending
	run_state["phase"] = "combat_roll_pending"
	return {"prepared": true, "requires_roll": true}


func resolve_prepared_combat_round() -> Dictionary:
	if str(run_state.get("phase", "")) != "combat_roll_pending":
		return {"error": "No prepared combat round is waiting"}
	var pending: Dictionary = run_state.get("pending_combat_round", {})
	if pending.is_empty():
		return {"error": "Prepared combat round is missing"}
	if is_narrative_combat():
		return NarrativeCombat.resolve(self)
	var state: Dictionary = run_state["combat_state"]
	var player_health_before := int(run_state.get("survivor", {}).get("vitals", {}).get("health", 0))
	var enemy_health_before := int(state.get("enemy_health", 0))
	var action := str(pending.get("action", ""))
	var round_result := {"action": action, "player_roll": int(pending.get("player_roll", 0)), "enemy_roll": int(pending.get("enemy_roll", 0)), "entries": []}
	run_state["phase"] = "combat"
	state["round"] = int(state.get("round", 0)) + 1
	match action:
		"attack":
			_resolve_player_attack(round_result)
		"guard":
			state["guarded"] = true
			state["next_attack_multiplier"] = 1.25
			_add_combat_entry(round_result, "guard", "You brace behind your armor. Incoming damage is reduced by 60%.", 0, "player")
		"use_item":
			var item_health_before := int(run_state.get("survivor", {}).get("vitals", {}).get("health", 0))
			var item_result := _use_item_internal(str(pending.get("item_id", "")))
			round_result["player_health_after_item"] = int(run_state.get("survivor", {}).get("vitals", {}).get("health", 0))
			round_result["healing"] = maxi(0, int(round_result["player_health_after_item"]) - item_health_before)
			_add_combat_entry(round_result, "heal" if item_result.get("success", false) else "system", str(item_result.get("text", "Item use failed.")), 0, "player")
		"flee":
			if _resolve_flee(round_result):
				_capture_round_presentation(round_result, state, player_health_before, enemy_health_before)
				return _finish_combat_round(round_result)
	if str(run_state.get("phase", "")) == "combat" and int(state.get("enemy_health", 0)) > 0:
		if bool(round_result.get("enemy_staggered", false)):
			_add_combat_entry(round_result, "critical_success", "CRITICAL SUCCESS — the enemy is staggered and cannot counterattack.", 0, "player")
		else:
			_resolve_enemy_attack(round_result, bool(state.get("guarded", false)))
	state["guarded"] = false
	if int(state.get("round", 0)) % 3 == 0 and str(run_state.get("phase", "")) == "combat":
		_change_pressure("fatigue", 2)
		_add_combat_entry(round_result, "system", "Extended combat adds 2 Fatigue.")
	_capture_round_presentation(round_result, state, player_health_before, enemy_health_before)
	return _finish_combat_round(round_result)


func _resolve_player_attack(round_result: Dictionary) -> void:
	var state: Dictionary = run_state["combat_state"]
	var roll := int(round_result["player_roll"])
	var profile := get_player_weapon_profile()
	var damage: int = CombatRules.damage_for_roll(roll, int(profile["damage_min"]), int(profile["damage_max"]), float(state.get("next_attack_multiplier", 1.0)))
	state["next_attack_multiplier"] = 1.0
	state["enemy_health"] = maxi(0, int(state.get("enemy_health", 0)) - damage)
	var kind := "critical_success" if roll == 20 else "critical_failure" if roll == 1 else "damage"
	_add_combat_entry(round_result, kind, "%s — %s deals %d damage." % [CombatRules.roll_label(roll), profile["name"], damage], damage, "player")
	round_result["player_damage"] = damage
	if str(profile.get("ammo_type", "")) != "":
		var ammunition_used := maxi(1, int(profile.get("ammo_per_attack", 1)))
		_change_item(str(profile["ammo_type"]), -ammunition_used)
		round_result["ammo_used"] = ammunition_used
		_add_combat_entry(round_result, "ammo", "%s −%d" % [content.get_item(str(profile["ammo_type"])).get("name", profile["ammo_type"]), ammunition_used], 0, "player")
	if roll == 1:
		state["exposed"] = true
	if roll == 20:
		round_result["enemy_staggered"] = true
	_tick_temporary_conditions()
	if int(state["enemy_health"]) <= 0:
		_complete_combat_victory(roll == 20, round_result)


func _resolve_enemy_attack(round_result: Dictionary, guarded: bool) -> void:
	var state: Dictionary = run_state["combat_state"]
	var adversary: Dictionary = content.get_adversary(str(state.get("adversary_id", "")))
	var combat: Dictionary = adversary.get("combat", {})
	var roll := int(round_result["enemy_roll"])
	var raw: int = CombatRules.damage_for_roll(roll, int(combat.get("damage_min", 1)), int(combat.get("damage_max", 1)))
	var mitigated: Dictionary = CombatRules.mitigate_damage(raw, _armor_rating(), guarded, bool(state.get("exposed", false)))
	var armor_only := CombatRules.mitigate_damage(raw, _armor_rating())
	var guarded_only := CombatRules.mitigate_damage(raw, _armor_rating(), guarded)
	state["exposed"] = false
	_change_health(-int(mitigated["final"]))
	var kind := "critical_success" if roll == 20 else "critical_failure" if roll == 1 else "damage"
	_add_combat_entry(round_result, kind, "%s — %s deals %d damage; armor prevents %d, Guard prevents %d, exposure adds %d. You take %d." % [CombatRules.roll_label(roll), combat.get("weapon_name", "Enemy attack"), raw, armor_only["blocked"], int(armor_only["final"]) - int(guarded_only["final"]), int(mitigated["final"]) - int(guarded_only["final"]), mitigated["final"]], int(mitigated["final"]), "enemy")
	round_result["enemy_damage"] = int(mitigated["final"])
	round_result["armor_blocked"] = int(armor_only["blocked"])
	round_result["defense_blocked"] = int(armor_only["final"]) - int(guarded_only["final"])
	round_result["exposure_damage"] = int(mitigated["final"]) - int(guarded_only["final"])
	if roll == 20:
		var condition_id := str(combat.get("critical_condition", ""))
		if condition_id != "":
			_apply_condition(condition_id)
			round_result["critical_condition"] = str(content.get_condition(condition_id).get("name", condition_id))
			_add_combat_entry(round_result, "condition", "CRITICAL CONDITION — %s" % content.get_condition(condition_id).get("name", condition_id), 0, "enemy")
	if roll == 1:
		state["next_attack_multiplier"] = maxf(1.25, float(state.get("next_attack_multiplier", 1.0)))
	_update_death_state()


func _resolve_flee(round_result: Dictionary) -> bool:
	var roll := int(round_result["player_roll"])
	var pending: Dictionary = run_state.get("pending_combat_round", {})
	var preview := get_flee_preview()
	var resolution := D20Resolver.resolve_percentage(
		roll,
		int(pending.get("flee_stat_value", preview["stat_value"])),
		int(pending.get("flee_effective_stat", preview["effective_stat"])),
		str(pending.get("flee_difficulty", preview["difficulty"])),
		pending.get("flee_modifiers", preview["modifiers"]),
		int(pending.get("flee_chance", preview["chance"]))
	)
	round_result["flee_resolution"] = resolution
	_tick_temporary_conditions()
	if bool(resolution.get("succeeded", false)):
		_change_pressure("fatigue", 5)
		_add_combat_entry(round_result, "success", "%s — you escape. Fatigue +5; no loot gained." % CombatRules.roll_label(roll), 0, "player")
		var event := current_event()
		var choice: Dictionary = event.get("choices", [])[int(run_state["combat_state"]["choice_index"])]
		var encounter_id := str(run_state["combat_state"].get("encounter_id", _event_xp_source_id("flee")))
		var xp_awards: Array = []
		if int(run_state.get("region_index", 0)) < content.ordered_regions().size():
			_append_xp_award(xp_awards, award_experience(ExperienceRules.JOURNEY_XP, "Journey survived", "%s:journey" % encounter_id))
		_record_event(event)
		run_state["last_result"] = {"event_id": str(event.get("id", "")), "event_title": str(event.get("title", "Event")), "choice": str(choice.get("label", "Fight")), "resolution": resolution, "outcome_text": "You escape the fight without spoils.", "changes": ["Fatigue +5", "No combat XP"], "xp_awards": xp_awards}
		run_state["combat_state"] = {}
		run_state["phase"] = "result"
		round_result["flee_success"] = true
		return true
	_add_combat_entry(round_result, "failure", "%s — escape fails. The enemy attacks." % CombatRules.roll_label(roll), 0, "player")
	return false


func _complete_combat_victory(critical_kill: bool, round_result: Dictionary) -> void:
	var event := current_event()
	var choice: Dictionary = event.get("choices", [])[int(run_state["combat_state"]["choice_index"])]
	var adversary_id := str(run_state["combat_state"].get("adversary_id", ""))
	var adversary: Dictionary = content.get_adversary(adversary_id)
	var encounter_id := str(run_state["combat_state"].get("encounter_id", _event_xp_source_id("combat:%s" % adversary_id)))
	var outcome: Dictionary = choice.get("critical_victory", choice.get("victory", {})) if critical_kill else choice.get("victory", {})
	var changes: Array = []
	var condition_changes: Array = []
	_apply_outcome(outcome, changes, condition_changes)
	var xp_awards: Array = []
	_append_xp_award(xp_awards, award_experience(int(adversary.get("xp_reward", 0)), "%s defeated" % str(adversary.get("name", "Enemy")), "%s:victory" % encounter_id))
	for award: Variant in _event_experience_awards(event, {}, {}, outcome, encounter_id):
		xp_awards.append(award)
	var defeated: Array = run_state.get("defeated_adversaries", [])
	defeated.append(adversary_id)
	run_state["defeated_adversaries"] = defeated
	_record_event(event)
	var resolution := {"rules_version": D20Resolver.RULES_VERSION, "roll": int(round_result.get("player_roll", 0)), "outcome": "critical_success" if critical_kill else "success", "succeeded": true, "breakdown": [], "success_chance": 100}
	if int(round_result.get("combat_rules_version", 1)) == NarrativeCombat.VERSION:
		resolution["success_chance"] = int(round_result["chance"])
		resolution["required_roll"] = int(round_result["required_roll"])
	run_state["last_result"] = {"event_id": str(event.get("id", "")), "event_title": str(event.get("title", "Event")), "choice": str(choice.get("label", "Fight")), "resolution": resolution, "outcome_text": str(outcome.get("text", "The enemy falls.")), "changes": changes, "condition_changes": condition_changes, "combat_log": run_state["combat_state"].get("log", []).duplicate(true), "xp_awards": xp_awards}
	run_state["combat_state"] = {}
	round_result["enemy_defeated"] = true
	if bool(outcome.get("victory", false)):
		run_state["status"] = "victory"
		run_state["phase"] = "victory"
	else:
		run_state["phase"] = "result"


func _finish_combat_round(round_result: Dictionary) -> Dictionary:
	if not run_state.get("combat_state", {}).is_empty():
		run_state["combat_state"]["last_round"] = round_result.duplicate(true)
	run_state["pending_combat_round"] = {}
	_update_death_state()
	return round_result


func _capture_round_presentation(round_result: Dictionary, state: Dictionary, player_health_before: int, enemy_health_before: int) -> void:
	var player_health_after := int(run_state.get("survivor", {}).get("vitals", {}).get("health", 0))
	var enemy_health_after := int(state.get("enemy_health", 0))
	round_result["presentation"] = {
		"action": str(round_result.get("action", "")),
		"player_health_before": player_health_before,
		"player_health_after": player_health_after,
		"player_health_after_item": int(round_result.get("player_health_after_item", player_health_after)),
		"enemy_health_before": enemy_health_before,
		"enemy_health_after": enemy_health_after,
		"player_damage": int(round_result.get("player_damage", maxi(0, enemy_health_before - enemy_health_after))),
		"enemy_damage": int(round_result.get("enemy_damage", maxi(0, player_health_before - player_health_after))),
		"healing": int(round_result.get("healing", maxi(0, player_health_after - player_health_before))),
		"armor_blocked": int(round_result.get("armor_blocked", 0)),
		"defense_blocked": int(round_result.get("defense_blocked", 0)),
		"exposure_damage": int(round_result.get("exposure_damage", 0)),
		"ammo_used": int(round_result.get("ammo_used", 0)),
		"enemy_staggered": bool(round_result.get("enemy_staggered", false)),
		"enemy_defeated": bool(round_result.get("enemy_defeated", false)) or enemy_health_after <= 0,
		"flee_success": bool(round_result.get("flee_success", false)),
		"critical_condition": str(round_result.get("critical_condition", "")),
		"player_roll": int(round_result.get("player_roll", 0)),
		"enemy_roll": int(round_result.get("enemy_roll", 0)),
	}


func _add_combat_entry(round_result: Dictionary, kind: String, message: String, amount: int = 0, actor: String = "system") -> void:
	var entry := {"kind": kind, "text": message, "amount": amount, "actor": actor}
	round_result["entries"].append(entry)
	if not run_state.get("combat_state", {}).is_empty():
		var log: Array = run_state["combat_state"].get("log", [])
		log.append(entry)
		while log.size() > 80:
			log.pop_front()


func _select_next_event() -> void:
	var region := current_region()
	var candidate_ids: Array = region.get("event_pool", []).duplicate()
	for event_id: String in content.events:
		if bool(content.events[event_id].get("global", false)):
			candidate_ids.append(event_id)
	var eligible: Array = []
	var recent: Array = run_state.get("event_history", []).slice(max(0, run_state.get("event_history", []).size() - 3))
	for raw_id: Variant in candidate_ids:
		var event_id := str(raw_id)
		var event: Dictionary = content.get_event(event_id)
		if event.is_empty() or not _event_eligible(event):
			continue
		if bool(event.get("unique", false)) and event_id in run_state["event_history"]:
			continue
		if event_id in recent:
			continue
		eligible.append(event)
	eligible = _apply_opening_guidance(eligible)
	var combat_seen := int(run_state.get("combat_opportunities_seen_in_region", 0))
	if combat_seen >= 2:
		var noncombat_events: Array = []
		for event: Dictionary in eligible:
			if not content.event_has_combat_choice(event):
				noncombat_events.append(event)
		if not noncombat_events.is_empty():
			eligible = noncombat_events
	var forced_role := false
	if int(run_state.get("events_in_region", 0)) == EVENTS_PER_REGION - 2 and combat_seen == 0:
		var combat_events: Array = []
		for event: Dictionary in eligible:
			if content.event_has_combat_choice(event):
				combat_events.append(event)
		if not combat_events.is_empty():
			eligible = combat_events
			forced_role = true
	if int(run_state.get("events_in_region", 0)) == EVENTS_PER_REGION - 1 and not bool(run_state.get("supply_seen_in_region", false)):
		var supply: Array = []
		for event: Dictionary in eligible:
			if "supply_opportunity" in event.get("tags", []):
				supply.append(event)
		if not supply.is_empty():
			eligible = supply
			forced_role = true
	if not forced_role and not eligible.is_empty():
		var highest_priority := 0
		for event: Dictionary in eligible:
			highest_priority = maxi(highest_priority, int(event.get("narrative_priority", 0)))
		if highest_priority > 0:
			var priority_events: Array = []
			for event: Dictionary in eligible:
				if int(event.get("narrative_priority", 0)) == highest_priority:
					priority_events.append(event)
			eligible = priority_events
	if eligible.is_empty():
		run_state["current_event_id"] = "fallback_dust"
		return
	var total_weight := 0
	for event: Dictionary in eligible:
		total_weight += max(1, int(event.get("weight", 1)))
	var pick := _random_range(1, total_weight)
	for event: Dictionary in eligible:
		pick -= max(1, int(event.get("weight", 1)))
		if pick <= 0:
			run_state["current_event_id"] = str(event["id"])
			return
	run_state["current_event_id"] = str(eligible.back()["id"])


func _apply_opening_guidance(eligible: Array) -> Array:
	if int(run_state.get("region_index", 0)) != 0:
		return eligible
	var position := int(run_state.get("events_in_region", 0))
	if position == 0:
		return _events_with_tag_or_original(eligible, OPENING_SAFE_TAG)
	if position != 1 or run_state.get("event_history", []).is_empty():
		return eligible
	var first_event_id := str(run_state.get("event_history", []).back())
	var first_tags: Array = content.get_event(first_event_id).get("tags", [])
	var missing_role := OPENING_EQUIPMENT_TAG if OPENING_RESOURCE_TAG in first_tags else OPENING_RESOURCE_TAG
	return _events_with_tag_or_original(eligible, missing_role)


func _events_with_tag_or_original(events: Array, required_tag: String) -> Array:
	var tagged: Array = []
	for event: Dictionary in events:
		if required_tag in event.get("tags", []):
			tagged.append(event)
	return tagged if not tagged.is_empty() else events


func _event_eligible(event: Dictionary) -> bool:
	var eligibility: Dictionary = event.get("eligibility", {})
	var region_index := int(run_state.get("region_index", 0))
	if region_index < int(eligibility.get("min_region_index", 0)):
		return false
	if region_index > int(eligibility.get("max_region_index", 999)):
		return false
	for flag: Variant in eligibility.get("requires_flags", []):
		if str(flag) not in run_state.get("flags", []):
			return false
	var required_any: Array = eligibility.get("requires_any_flags", [])
	if not required_any.is_empty():
		var found_any := false
		for flag: Variant in required_any:
			if str(flag) in run_state.get("flags", []):
				found_any = true
				break
		if not found_any:
			return false
	for flag: Variant in eligibility.get("forbids_flags", []):
		if str(flag) in run_state.get("flags", []):
			return false
	for item_id: Variant in eligibility.get("requires_items", {}):
		if get_item_quantity(str(item_id)) < int(eligibility["requires_items"][item_id]):
			return false
	return true


func _choice_availability(choice: Dictionary) -> Dictionary:
	var requirements: Dictionary = choice.get("requires", {})
	for flag: Variant in requirements.get("flags", []):
		if str(flag) not in run_state.get("flags", []):
			return {"available": false, "reason": "Requires the relevant Bunker Forty-One record"}
	var required_any: Array = requirements.get("any_flags", [])
	if not required_any.is_empty():
		var found_any := false
		for flag: Variant in required_any:
			if str(flag) in run_state.get("flags", []):
				found_any = true
				break
		if not found_any:
			return {"available": false, "reason": "Requires Bunker Forty-One testimony or evidence"}
	for item_id: Variant in requirements.get("items", {}):
		if get_item_quantity(str(item_id)) < int(requirements["items"][item_id]):
			return {"available": false, "reason": "Requires %s" % content.get_item(str(item_id)).get("name", item_id)}
	for stat: Variant in requirements.get("stats", {}):
		if int(run_state["survivor"]["stats"].get(str(stat), 0)) < int(requirements["stats"][stat]):
			return {"available": false, "reason": "Requires %s %d" % [STAT_LABELS.get(str(stat), str(stat).capitalize()), requirements["stats"][stat]]}
	for condition_id: Variant in requirements.get("forbids_conditions", []):
		if str(condition_id) in run_state["survivor"]["conditions"]:
			return {"available": false, "reason": "Blocked by %s" % content.get_condition(str(condition_id)).get("name", condition_id)}
	for item_id: Variant in choice.get("costs", {}).get("items", {}):
		if get_item_quantity(str(item_id)) < int(choice["costs"]["items"][item_id]):
			return {"available": false, "reason": "Not enough %s" % content.get_item(str(item_id)).get("name", item_id)}
	return {"available": true}


func _collect_modifiers(stat: String, approach: String, choice_modifier: int) -> Array:
	var modifiers: Array = []
	if choice_modifier != 0:
		modifiers.append({"label": "Approach", "value": choice_modifier})
	for slot: String in run_state["survivor"]["equipment"]:
		var item_id := str(run_state["survivor"]["equipment"][slot])
		if item_id == "":
			continue
		var item: Dictionary = content.get_item(item_id)
		var ammo_type := str(item.get("ammo_type", ""))
		var ammunition_needed := maxi(0, int(item.get("combat", {}).get("ammo_per_attack", 0)))
		if slot == "weapon" and ammo_type != "" and get_item_quantity(ammo_type) < ammunition_needed:
			modifiers.append({"label": "%s (unloaded)" % item.get("name", item_id), "value": 0})
			continue
		var item_modifiers: Dictionary = item.get("modifiers", {})
		var value := int(item_modifiers.get("stats", {}).get(stat, 0)) + int(item_modifiers.get("approaches", {}).get(approach, 0))
		if value != 0:
			modifiers.append({"label": str(item.get("name", item_id)), "value": value})
	for condition_id: Variant in run_state["survivor"]["conditions"]:
		var condition: Dictionary = content.get_condition(str(condition_id))
		var value := int(condition.get("modifiers", {}).get(stat, 0))
		if value != 0:
			modifiers.append({"label": str(condition.get("name", condition_id)), "value": value})
	var pressure_penalty := _pressure_penalty()
	if pressure_penalty != 0:
		modifiers.append({"label": "Survival strain", "value": pressure_penalty})
	if stat == "agility" and get_total_weight() > get_carry_capacity():
		modifiers.append({"label": "Over capacity", "value": -2})
	return modifiers


func _effective_stats() -> Dictionary:
	var result: Dictionary = run_state.get("survivor", {}).get("stats", {}).duplicate(true)
	for slot: String in run_state.get("survivor", {}).get("equipment", {}):
		var item_id := str(run_state["survivor"]["equipment"][slot])
		var bonuses: Dictionary = content.get_item(item_id).get("modifiers", {}).get("stats", {})
		for stat: String in bonuses:
			result[stat] = maxi(0, int(result.get(stat, 1)) + int(bonuses[stat]))
	return result


func _pressure_penalty() -> int:
	var survivor: Dictionary = run_state["survivor"]
	var penalty := 0
	for pressure: String in PRESSURES:
		var value := int(survivor["pressures"].get(pressure, 0))
		if value >= 75: penalty -= 3
		elif value >= 50: penalty -= 2
		elif value >= 25: penalty -= 1
	var satiety := int(survivor["vitals"].get("satiety", MAX_SATIETY))
	if satiety <= 0: penalty -= 3
	elif satiety == 1: penalty -= 2
	elif satiety == 2: penalty -= 1
	var health := int(survivor["vitals"].get("health", 0))
	var maximum := maxi(1, int(survivor["vitals"].get("max_health", 1)))
	if health * 4 <= maximum: penalty -= 2
	elif health * 2 <= maximum: penalty -= 1
	return penalty


func _apply_costs(costs: Dictionary) -> void:
	for item_id: Variant in costs.get("items", {}):
		_change_item(str(item_id), -int(costs["items"][item_id]))
	for pressure: Variant in costs.get("pressures", {}):
		_apply_legacy_pressure(str(pressure), int(costs["pressures"][pressure]), "")


func _apply_outcome(outcome: Dictionary, changes: Array, condition_changes: Array = []) -> void:
	if bool(outcome.get("lethal", false)):
		_change_health(-int(run_state["survivor"]["vitals"]["max_health"]))
		changes.append("HP reduced to 0")
	var damage_type := str(outcome.get("damage_type", ""))
	for vital: String in outcome.get("vitals", {}):
		var delta := int(outcome["vitals"][vital])
		if vital == "health":
			var applied := _apply_health_delta(delta, damage_type)
			changes.append("HP %s%d" % ["+" if applied >= 0 else "", applied])
		elif vital == "satiety":
			_change_satiety(delta)
			changes.append("Satiety %s%d" % ["+" if delta >= 0 else "", delta])
	for pressure: String in outcome.get("pressures", {}):
		var description := _apply_legacy_pressure(pressure, int(outcome["pressures"][pressure]), damage_type)
		if description != "": changes.append(description)
	for item_id: String in outcome.get("items", {}):
		var delta := int(outcome["items"][item_id])
		_change_item(item_id, delta)
		changes.append("%s %s%d" % [content.get_item(item_id).get("name", item_id), "+" if delta >= 0 else "", delta])
	for condition_id: Variant in outcome.get("add_conditions", []):
		if str(condition_id) not in run_state["survivor"]["conditions"]:
			_apply_condition(str(condition_id))
			changes.append("New condition: %s" % content.get_condition(str(condition_id)).get("name", condition_id))
			condition_changes.append({"id": str(condition_id), "change": "added"})
	for condition_id: Variant in outcome.get("remove_conditions", []):
		if str(condition_id) in run_state["survivor"]["conditions"]:
			_remove_condition(str(condition_id))
			changes.append("Removed: %s" % content.get_condition(str(condition_id)).get("name", condition_id))
			condition_changes.append({"id": str(condition_id), "change": "removed"})
	for flag: Variant in outcome.get("add_flags", []):
		if str(flag) not in run_state["flags"]: run_state["flags"].append(str(flag))
	if outcome.has("next_event"): run_state["pending_event_id"] = str(outcome["next_event"])


func _apply_legacy_pressure(pressure: String, delta: int, damage_type: String) -> String:
	if pressure == "health":
		var scaled := roundi(float(delta) * 2.5 / 5.0) * 5
		var applied := _apply_health_delta(scaled, damage_type)
		return "HP %s%d" % ["+" if applied >= 0 else "", applied]
	if pressure == "hunger":
		var satiety_delta := ceili(absf(float(delta)) / 10.0) if delta < 0 else -1
		_change_satiety(satiety_delta)
		return "Satiety %s%d" % ["+" if satiety_delta >= 0 else "", satiety_delta]
	_change_pressure(pressure, delta)
	return "%s %s%d" % [pressure.capitalize(), "+" if delta >= 0 else "", delta]


func _apply_health_delta(delta: int, damage_type: String) -> int:
	if delta >= 0 or damage_type != "physical":
		_change_health(delta)
		return delta
	var mitigated: Dictionary = CombatRules.mitigate_damage(-delta, _armor_rating())
	_change_health(-int(mitigated["final"]))
	return -int(mitigated["final"])


func _record_event(event: Dictionary) -> void:
	var event_id := str(event.get("id", ""))
	if event_id != "": run_state["event_history"].append(event_id)
	if "supply_opportunity" in event.get("tags", []): run_state["supply_seen_in_region"] = true
	if content.event_has_combat_choice(event):
		run_state["combat_opportunities_seen_in_region"] = int(run_state.get("combat_opportunities_seen_in_region", 0)) + 1


func _apply_travel_pressure() -> void:
	_change_pressure("fatigue", 5)
	_change_pressure("radiation", int(current_region().get("travel_radiation", 0)))


func _apply_hunger_tick() -> void:
	run_state["hunger_clock"] = int(run_state.get("hunger_clock", 0)) + 1
	if int(run_state["hunger_clock"]) < 2: return
	run_state["hunger_clock"] = 0
	if int(run_state["survivor"]["vitals"].get("satiety", 0)) > 0:
		_change_satiety(-1)
	else:
		_change_health(-HP_PER_HEART)
		run_state["last_survival_notice"] = "STARVATION — one heart lost (50 HP)."


func _change_health(delta: int) -> void:
	var vitals: Dictionary = run_state["survivor"]["vitals"]
	vitals["health"] = clampi(int(vitals.get("health", 0)) + delta, 0, int(vitals.get("max_health", HP_PER_HEART)))


func _change_satiety(delta: int) -> void:
	var vitals: Dictionary = run_state["survivor"]["vitals"]
	vitals["satiety"] = clampi(int(vitals.get("satiety", MAX_SATIETY)) + delta, 0, MAX_SATIETY)


func _change_pressure(pressure: String, delta: int) -> void:
	if pressure not in PRESSURES: return
	var value := int(run_state["survivor"]["pressures"].get(pressure, 0)) + delta
	run_state["survivor"]["pressures"][pressure] = clampi(value, 0, 100)


func _change_item(item_id: String, delta: int) -> void:
	var inventory: Dictionary = run_state["survivor"]["inventory"]
	var quantity := int(inventory.get(item_id, 0)) + delta
	if quantity <= 0:
		inventory.erase(item_id)
		for slot: String in run_state["survivor"]["equipment"]:
			if str(run_state["survivor"]["equipment"][slot]) == item_id: run_state["survivor"]["equipment"][slot] = ""
	else: inventory[item_id] = quantity


func _armor_rating() -> int:
	var armor_id := str(run_state.get("survivor", {}).get("equipment", {}).get("armor", ""))
	return int(content.get_item(armor_id).get("damage_reduction", 0)) if armor_id != "" else 0


func _apply_condition(condition_id: String) -> void:
	if condition_id not in run_state["survivor"]["conditions"]: run_state["survivor"]["conditions"].append(condition_id)
	var duration := int(content.get_condition(condition_id).get("duration_checks", 0))
	if duration > 0: run_state["condition_uses"][condition_id] = duration


func _remove_condition(condition_id: String) -> void:
	run_state["survivor"]["conditions"].erase(condition_id)
	run_state["condition_uses"].erase(condition_id)


func _tick_temporary_conditions() -> void:
	var expired: Array[String] = []
	for condition_id: String in run_state.get("condition_uses", {}):
		var remaining := int(run_state["condition_uses"][condition_id]) - 1
		if remaining <= 0: expired.append(condition_id)
		else: run_state["condition_uses"][condition_id] = remaining
	for condition_id: String in expired: _remove_condition(condition_id)


func _update_death_state() -> void:
	if run_state.is_empty() or not run_state.get("survivor", {}).has("vitals"): return
	if int(run_state["survivor"]["vitals"].get("health", 0)) <= 0:
		run_state["survivor"]["vitals"]["health"] = 0
		run_state["status"] = "dead"
		run_state["phase"] = "death"


func _find_inventory_item_with_tag(tag: String) -> String:
	for item_id: String in run_state["survivor"]["inventory"]:
		if tag in content.get_item(item_id).get("tags", []): return item_id
	return ""


func _next_random() -> int:
	var current := int(run_state.get("rng_state", 1))
	current = int((current * 48271) % 2147483647)
	if current <= 0: current = 1
	run_state["rng_state"] = current
	return current


func _random_range(minimum: int, maximum: int) -> int:
	return minimum + (_next_random() % (maximum - minimum + 1))
