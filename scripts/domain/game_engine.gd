class_name GameEngine
extends RefCounted

const STATS := ["strength", "agility", "wits", "grit", "presence"]
const STAT_LABELS := {
	"strength": "Strength",
	"agility": "Agility",
	"wits": "Wits",
	"grit": "Grit",
	"presence": "Presence",
}
const PRESSURES := ["health", "hunger", "fatigue", "radiation"]
const EVENTS_PER_REGION := 5
const FINAL_EVENT_ID := "final_gate_1"

var content
var run_state: Dictionary = {}


func _init(repository) -> void:
	content = repository


func create_candidates(seed_value: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var names := ["Mara Venn", "Jonah Pike", "Iris Vale", "Tomas Reed", "Nia Cross", "Silas Ward", "Kei Mercer", "Rhea Flint", "Oren Knox"]
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
		var name_index := rng.randi_range(0, names.size() - 1)
		var survivor_name: String = names.pop_at(name_index)
		var callsign_index := rng.randi_range(0, callsigns.size() - 1)
		var callsign: String = callsigns.pop_at(callsign_index)
		var survivor := {
			"id": "candidate_%d" % candidate_index,
			"name": survivor_name,
			"callsign": callsign,
			"stats": stats,
			"pressures": {"health": 100, "hunger": 0, "fatigue": 0, "radiation": 0},
			"conditions": [],
			"inventory": _starting_inventory(stats),
			"equipment": {"weapon": "", "armor": "", "accessory": "", "backpack": ""},
		}
		_auto_equip(survivor)
		candidates.append(survivor)
	return candidates


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
		"schema_version": 1,
		"run_id": "%d-%d" % [Time.get_unix_time_from_system(), normalized_seed],
		"seed": normalized_seed,
		"rng_state": normalized_seed,
		"status": "active",
		"phase": "event",
		"region_index": 0,
		"events_in_region": 0,
		"total_events": 0,
		"event_history": [],
		"flags": [],
		"current_event_id": "",
		"pending_event_id": "",
		"pending_resolution": {},
		"last_result": {},
		"condition_uses": {},
		"survivor": candidate.duplicate(true),
		"started_at": Time.get_unix_time_from_system(),
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


func get_choice_preview(choice: Dictionary) -> Dictionary:
	var availability := _choice_availability(choice)
	if not availability["available"]:
		return availability
	var check: Dictionary = choice.get("check", {})
	if check.is_empty():
		return {"available": true, "chance": -1, "description": "Certain outcome"}
	var stat := str(check.get("stat", "wits"))
	var stat_value := int(run_state["survivor"]["stats"].get(stat, 0))
	var modifiers := _collect_modifiers(stat, str(choice.get("approach", "")), int(choice.get("modifier", 0)))
	var modifier_total := stat_value
	for modifier: Dictionary in modifiers:
		modifier_total += int(modifier["value"])
	var dc := int(check.get("dc", 10))
	return {
		"available": true,
		"chance": D20Resolver.calculate_success_chance(modifier_total, dc),
		"stat": stat,
		"stat_label": STAT_LABELS.get(stat, stat.capitalize()),
		"stat_value": stat_value,
		"modifier_total": modifier_total,
		"dc": dc,
		"description": "D20 %+d vs DC %d" % [modifier_total, dc],
		"modifiers": modifiers,
	}


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
	var check: Dictionary = choice.get("check", {})
	var roll := 0 if check.is_empty() else _random_range(1, 20)
	run_state["pending_resolution"] = {
		"event_id": str(run_state.get("current_event_id", "")),
		"choice_index": choice_index,
		"roll": roll,
	}
	run_state["phase"] = "resolving"
	return {"prepared": true, "roll": roll}


func resolve_prepared_choice() -> Dictionary:
	if str(run_state.get("phase", "")) != "resolving":
		return {"error": "No prepared choice is waiting"}
	var pending: Dictionary = run_state.get("pending_resolution", {})
	if pending.is_empty() or str(pending.get("event_id", "")) != str(run_state.get("current_event_id", "")):
		return {"error": "Prepared choice does not match the current event"}
	var choice_index := int(pending.get("choice_index", -1))
	var roll := int(pending.get("roll", 0))
	run_state["phase"] = "event"
	var result := resolve_choice(choice_index, roll)
	if not result.has("error"):
		run_state["pending_resolution"] = {}
	return result


func resolve_choice(choice_index: int, forced_roll: int = -1) -> Dictionary:
	if str(run_state.get("phase", "")) != "event":
		return {"error": "No event is awaiting a choice"}
	var event := current_event()
	var choices: Array = event.get("choices", [])
	if choice_index < 0 or choice_index >= choices.size():
		return {"error": "Invalid choice"}
	var choice: Dictionary = choices[choice_index]
	var preview := get_choice_preview(choice)
	if not preview.get("available", false):
		return {"error": str(preview.get("reason", "Choice unavailable"))}
	_apply_costs(choice.get("costs", {}))
	var check: Dictionary = choice.get("check", {})
	var resolution: Dictionary
	var outcome_key := "outcome"
	if check.is_empty():
		resolution = {"roll": 0, "total": 0, "dc": 0, "outcome": "outcome", "succeeded": true, "breakdown": [], "success_chance": 100}
	else:
		var roll := forced_roll if forced_roll >= 1 and forced_roll <= 20 else _random_range(1, 20)
		var stat := str(check.get("stat", "wits"))
		var stat_value := int(run_state["survivor"]["stats"].get(stat, 0))
		var modifiers := _collect_modifiers(stat, str(choice.get("approach", "")), int(choice.get("modifier", 0)))
		resolution = D20Resolver.resolve(roll, stat_value, int(check.get("dc", 10)), modifiers)
		outcome_key = str(resolution["outcome"])
	var outcome: Dictionary = choice.get(outcome_key, choice.get("success" if resolution.get("succeeded", false) else "failure", {}))
	var changes: Array = []
	_consume_ranged_ammunition(str(choice.get("approach", "")), changes)
	_tick_temporary_conditions()
	_apply_outcome(outcome, changes)
	_record_event(event)
	var result := {
		"event_id": str(event.get("id", "")),
		"event_title": str(event.get("title", "Event")),
		"choice": str(choice.get("label", "Choice")),
		"resolution": resolution,
		"outcome_text": str(outcome.get("text", "The road moves on.")),
		"changes": changes,
	}
	run_state["last_result"] = result
	if int(run_state["survivor"]["pressures"]["health"]) <= 0:
		run_state["survivor"]["pressures"]["health"] = 0
		run_state["status"] = "dead"
		run_state["phase"] = "death"
	elif bool(outcome.get("victory", false)):
		run_state["status"] = "victory"
		run_state["phase"] = "victory"
	else:
		run_state["phase"] = "result"
	return result


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
	run_state["events_in_region"] = int(run_state["events_in_region"]) + 1
	run_state["total_events"] = int(run_state["total_events"]) + 1
	if int(run_state["events_in_region"]) >= EVENTS_PER_REGION:
		run_state["current_event_id"] = ""
		run_state["phase"] = "checkpoint"
	else:
		_select_next_event()
		run_state["phase"] = "event"


func rest_at_checkpoint() -> Dictionary:
	if str(run_state.get("phase", "")) != "checkpoint":
		return {"success": false, "text": "Rest is only possible at a checkpoint."}
	var food_id := _find_inventory_item_with_tag("food")
	if food_id == "":
		return {"success": false, "text": "You need one food item to rest."}
	_change_item(food_id, -1)
	_change_pressure("hunger", -30)
	_change_pressure("fatigue", -35)
	_change_pressure("health", 8)
	return {"success": true, "text": "You eat, dress your wounds, and sleep lightly. Fatigue -35, Hunger -30, Health +8."}


func leave_checkpoint() -> void:
	if str(run_state.get("phase", "")) != "checkpoint":
		return
	run_state["region_index"] = int(run_state["region_index"]) + 1
	run_state["events_in_region"] = 0
	if int(run_state["region_index"]) >= content.ordered_regions().size():
		run_state["current_event_id"] = FINAL_EVENT_ID
	else:
		_change_pressure("hunger", 4)
		_change_pressure("fatigue", 5)
		_select_next_event()
	run_state["phase"] = "event"


func equip_item(item_id: String) -> Dictionary:
	var item: Dictionary = content.get_item(item_id)
	if item.is_empty() or get_item_quantity(item_id) <= 0:
		return {"success": false, "text": "That item is not available."}
	var slot := str(item.get("equipment_slot", ""))
	if slot == "":
		return {"success": false, "text": "That item cannot be equipped."}
	run_state["survivor"]["equipment"][slot] = item_id
	return {"success": true, "text": "%s equipped." % item.get("name", item_id)}


func use_item(item_id: String) -> Dictionary:
	var item: Dictionary = content.get_item(item_id)
	if item.is_empty() or get_item_quantity(item_id) <= 0 or not bool(item.get("consumable", false)):
		return {"success": false, "text": "That item cannot be used."}
	var effects: Dictionary = item.get("effects", {})
	for pressure: String in effects.get("pressures", {}):
		_change_pressure(pressure, int(effects["pressures"][pressure]))
	for condition_id: Variant in effects.get("remove_conditions", []):
		_remove_condition(str(condition_id))
	for condition_id: Variant in effects.get("add_conditions", []):
		_apply_condition(str(condition_id))
	_change_item(item_id, -1)
	_update_death_state()
	return {"success": true, "text": str(item.get("use_text", "Item used."))}


func get_total_weight() -> float:
	var total := 0.0
	for item_id: String in run_state.get("survivor", {}).get("inventory", {}):
		var quantity := int(run_state["survivor"]["inventory"][item_id])
		total += float(content.get_item(item_id).get("weight", 0.0)) * quantity
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


func summary() -> Dictionary:
	var survivor: Dictionary = run_state.get("survivor", {})
	return {
		"run_id": str(run_state.get("run_id", "")),
		"survivor": str(survivor.get("name", "Unknown")),
		"callsign": str(survivor.get("callsign", "")),
		"result": str(run_state.get("status", "abandoned")),
		"regions_reached": min(int(run_state.get("region_index", 0)) + 1, content.ordered_regions().size()),
		"events_resolved": int(run_state.get("total_events", 0)),
		"ended_at": Time.get_unix_time_from_system(),
	}


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


func _event_eligible(event: Dictionary) -> bool:
	var eligibility: Dictionary = event.get("eligibility", {})
	for flag: Variant in eligibility.get("requires_flags", []):
		if str(flag) not in run_state.get("flags", []):
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
		if slot == "weapon" and ammo_type != "" and get_item_quantity(ammo_type) <= 0:
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


func _pressure_penalty() -> int:
	var pressures: Dictionary = run_state["survivor"]["pressures"]
	var penalty := 0
	for pressure: String in ["hunger", "fatigue", "radiation"]:
		var value := int(pressures[pressure])
		if value >= 75:
			penalty -= 3
		elif value >= 50:
			penalty -= 2
		elif value >= 25:
			penalty -= 1
	var health := int(pressures["health"])
	if health <= 25:
		penalty -= 2
	elif health <= 50:
		penalty -= 1
	return penalty


func _apply_costs(costs: Dictionary) -> void:
	for item_id: Variant in costs.get("items", {}):
		_change_item(str(item_id), -int(costs["items"][item_id]))
	for pressure: Variant in costs.get("pressures", {}):
		_change_pressure(str(pressure), int(costs["pressures"][pressure]))


func _apply_outcome(outcome: Dictionary, changes: Array) -> void:
	var damage_type := str(outcome.get("damage_type", ""))
	for pressure: String in outcome.get("pressures", {}):
		var delta := int(outcome["pressures"][pressure])
		if pressure == "health" and delta < 0 and damage_type == "physical":
			var armor_id := str(run_state["survivor"]["equipment"].get("armor", ""))
			var reduction := int(content.get_item(armor_id).get("damage_reduction", 0)) if armor_id != "" else 0
			delta = min(-1, delta + reduction)
		_change_pressure(pressure, delta)
		changes.append("%s %s%d" % [pressure.capitalize(), "+" if delta >= 0 else "", delta])
	for item_id: String in outcome.get("items", {}):
		var delta := int(outcome["items"][item_id])
		_change_item(item_id, delta)
		changes.append("%s %s%d" % [content.get_item(item_id).get("name", item_id), "+" if delta >= 0 else "", delta])
	for condition_id: Variant in outcome.get("add_conditions", []):
		if str(condition_id) not in run_state["survivor"]["conditions"]:
			_apply_condition(str(condition_id))
			changes.append("Condition: %s" % content.get_condition(str(condition_id)).get("name", condition_id))
	for condition_id: Variant in outcome.get("remove_conditions", []):
		if str(condition_id) in run_state["survivor"]["conditions"]:
			_remove_condition(str(condition_id))
			changes.append("Removed: %s" % content.get_condition(str(condition_id)).get("name", condition_id))
	for flag: Variant in outcome.get("add_flags", []):
		if str(flag) not in run_state["flags"]:
			run_state["flags"].append(str(flag))
	if outcome.has("next_event"):
		run_state["pending_event_id"] = str(outcome["next_event"])


func _record_event(event: Dictionary) -> void:
	var event_id := str(event.get("id", ""))
	if event_id != "":
		run_state["event_history"].append(event_id)


func _apply_travel_pressure() -> void:
	_change_pressure("hunger", 4)
	_change_pressure("fatigue", 5)
	var region := current_region()
	_change_pressure("radiation", int(region.get("travel_radiation", 0)))


func _change_pressure(pressure: String, delta: int) -> void:
	if pressure not in PRESSURES:
		return
	var value := int(run_state["survivor"]["pressures"].get(pressure, 0)) + delta
	run_state["survivor"]["pressures"][pressure] = clampi(value, 0, 100)


func _change_item(item_id: String, delta: int) -> void:
	var inventory: Dictionary = run_state["survivor"]["inventory"]
	var quantity := int(inventory.get(item_id, 0)) + delta
	if quantity <= 0:
		inventory.erase(item_id)
		for slot: String in run_state["survivor"]["equipment"]:
			if str(run_state["survivor"]["equipment"][slot]) == item_id:
				run_state["survivor"]["equipment"][slot] = ""
	else:
		inventory[item_id] = quantity


func _consume_ranged_ammunition(approach: String, changes: Array) -> void:
	if approach != "combat":
		return
	var weapon_id := str(run_state["survivor"]["equipment"].get("weapon", ""))
	if weapon_id == "":
		return
	var ammo_type := str(content.get_item(weapon_id).get("ammo_type", ""))
	if ammo_type == "" or get_item_quantity(ammo_type) <= 0:
		return
	_change_item(ammo_type, -1)
	changes.append("%s -1" % content.get_item(ammo_type).get("name", ammo_type))


func _apply_condition(condition_id: String) -> void:
	if condition_id not in run_state["survivor"]["conditions"]:
		run_state["survivor"]["conditions"].append(condition_id)
	var duration := int(content.get_condition(condition_id).get("duration_checks", 0))
	if duration > 0:
		if not run_state.has("condition_uses"):
			run_state["condition_uses"] = {}
		run_state["condition_uses"][condition_id] = duration


func _remove_condition(condition_id: String) -> void:
	run_state["survivor"]["conditions"].erase(condition_id)
	if run_state.has("condition_uses"):
		run_state["condition_uses"].erase(condition_id)


func _tick_temporary_conditions() -> void:
	if not run_state.has("condition_uses"):
		run_state["condition_uses"] = {}
	var expired: Array[String] = []
	for condition_id: String in run_state["condition_uses"]:
		var remaining := int(run_state["condition_uses"][condition_id]) - 1
		if remaining <= 0:
			expired.append(condition_id)
		else:
			run_state["condition_uses"][condition_id] = remaining
	for condition_id: String in expired:
		_remove_condition(condition_id)


func _update_death_state() -> void:
	if int(run_state["survivor"]["pressures"].get("health", 0)) <= 0:
		run_state["survivor"]["pressures"]["health"] = 0
		run_state["status"] = "dead"
		run_state["phase"] = "death"


func _find_inventory_item_with_tag(tag: String) -> String:
	for item_id: String in run_state["survivor"]["inventory"]:
		if tag in content.get_item(item_id).get("tags", []):
			return item_id
	return ""


func _next_random() -> int:
	var current := int(run_state.get("rng_state", 1))
	current = int((current * 48271) % 2147483647)
	if current <= 0:
		current = 1
	run_state["rng_state"] = current
	return current


func _random_range(minimum: int, maximum: int) -> int:
	return minimum + (_next_random() % (maximum - minimum + 1))
