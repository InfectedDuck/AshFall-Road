extends RefCounted
## Read-only equipment comparison.
##
## Every number here comes from the same domain calculations gameplay uses: the
## comparison equips the proposed item on a sandbox copy of the run through
## GameEngine.equip_item, then reads the ordinary weapon profile and combat
## previews from that copy. Nothing is recalculated locally, the live run is
## never touched, and no roll is made, so opening this sheet cannot change a run
## or consume RNG.
##
## The sandbox clears combat state on purpose. With no committed enemy move,
## Riposte, or Opening, the previews return neutral-encounter values rather than
## a prediction about the fight in progress.

const NarrativeCombat = preload("res://scripts/domain/narrative_combat.gd")
const CombatRules = preload("res://scripts/domain/combat_resolver.gd")

const SAMPLE_HIT := 40
const NEUTRAL_LABEL := "Neutral values: no enemy, tell, Riposte, or Opening applied."


static func compare(game, item_id: String) -> Dictionary:
	var blank := _blank(item_id)
	if game == null or game.run_state.is_empty():
		blank["reason"] = "No active run."
		return blank
	var item: Dictionary = game.content.get_item(item_id)
	var slot := str(item.get("equipment_slot", ""))
	if item.is_empty() or slot == "":
		blank["reason"] = "This item cannot be equipped."
		return blank
	blank["item_name"] = str(item.get("name", item_id))
	blank["slot"] = slot
	if game.get_item_quantity(item_id) <= 0:
		blank["reason"] = "This item is not in your inventory."
		return blank

	var equipment: Dictionary = game.run_state["survivor"]["equipment"]
	var current_id := str(equipment.get(slot, ""))
	var before := _sandbox(game)
	var after := _sandbox(game)
	# The sandbox has no combat, so the only lock left is the two-handed shield
	# rule. A blocked item still deserves a comparison: fill the slot directly so
	# the domain reports the item present but inactive, and keep the reason.
	var slot_conflict := str(after.equipment_lock_reason(item_id))
	if slot_conflict == "":
		var equip_result: Dictionary = after.equip_item(item_id)
		if not bool(equip_result.get("success", false)):
			blank["reason"] = str(equip_result.get("text", "This item cannot be equipped."))
			return blank
	else:
		after.run_state["survivor"]["equipment"][slot] = item_id

	var report := {
		"available": true,
		"reason": "",
		"slot": slot,
		"item_id": item_id,
		"item_name": str(item.get("name", item_id)),
		"current_id": current_id,
		"current_name": str(game.content.get_item(current_id).get("name", current_id)) if current_id != "" else "",
		"already_equipped": current_id == item_id,
		"blocked_reason": str(game.equipment_lock_reason(item_id)),
		"slot_conflict": slot_conflict,
		"shield_removed": "",
		"neutral_label": NEUTRAL_LABEL,
		"weapon": _weapon_section(game, before, after),
		"defense": _defense_section(game, before, after),
		"stats": _stat_rows(before, after),
		"approaches": _approach_rows(game, current_id, item_id),
		"carry": _carry_section(before, after),
		"notes": [],
	}

	var accessory_before := str(before.run_state["survivor"]["equipment"].get("accessory", ""))
	var accessory_after := str(after.run_state["survivor"]["equipment"].get("accessory", ""))
	if accessory_before != "" and accessory_after == "":
		report["shield_removed"] = str(game.content.get_item(accessory_before).get("name", accessory_before))

	report["notes"] = _notes(game, report)
	return report


## Every comparison answers with the same keys, so callers can read a refused
## comparison without guarding each field.
static func _blank(item_id: String) -> Dictionary:
	return {
		"available": false,
		"reason": "",
		"slot": "",
		"item_id": item_id,
		"item_name": "",
		"current_id": "",
		"current_name": "",
		"already_equipped": false,
		"blocked_reason": "",
		"slot_conflict": "",
		"shield_removed": "",
		"neutral_label": NEUTRAL_LABEL,
		"weapon": {"changes": false, "current": {}, "proposed": {}, "damage_min_delta": 0, "damage_max_delta": 0, "hit_chance_delta": 0},
		"defense": {"changes": false, "current": {}, "proposed": {}, "sample_hit": SAMPLE_HIT, "block_delta": 0, "dodge_delta": 0, "taken_delta": 0},
		"stats": [],
		"approaches": [],
		"carry": {},
		"notes": [],
	}


## A deep copy of the run with combat cleared, so previews describe a neutral
## encounter and every mutation stays inside the copy.
static func _sandbox(game) -> GameEngine:
	var copy := GameEngine.new(game.content)
	copy.restore_run(game.run_state)
	copy.run_state["combat_state"] = {}
	copy.run_state["pending_combat_round"] = {}
	return copy


static func _weapon_section(game, before, after) -> Dictionary:
	var current := _weapon_side(game, before)
	var proposed := _weapon_side(game, after)
	return {
		"changes": current != proposed,
		"current": current,
		"proposed": proposed,
		"damage_min_delta": int(proposed["damage_min"]) - int(current["damage_min"]),
		"damage_max_delta": int(proposed["damage_max"]) - int(current["damage_max"]),
		"hit_chance_delta": int(proposed["hit_chance"]) - int(current["hit_chance"]),
	}


static func _weapon_side(game, sandbox) -> Dictionary:
	var preview: Dictionary = NarrativeCombat.preview(sandbox, "attack")
	var profile: Dictionary = preview["profile"]
	var weapon_id := str(sandbox.run_state["survivor"]["equipment"].get("weapon", ""))
	var weapon: Dictionary = game.content.get_item(weapon_id)
	var ammo_type := str(profile.get("ammo_type", ""))
	return {
		"item_id": weapon_id,
		"name": str(profile.get("equipped_name", "Unarmed")),
		"attack_stat": str(profile.get("attack_stat", "strength")),
		"stat_value": int(profile.get("stat_value", 0)),
		"damage_min": int(preview.get("damage_min", 0)),
		"damage_max": int(preview.get("damage_max", 0)),
		"hit_chance": int(preview.get("chance", 0)),
		"required_roll": int(preview.get("required_roll", 0)),
		"family": str(profile.get("family", "unarmed")),
		"mastered": bool(profile.get("mastered", false)),
		"opportunity_name": str(profile.get("opportunity_name", "")),
		"two_handed": bool(weapon.get("two_handed", false)),
		"ammo_type": ammo_type,
		"ammo_name": str(game.content.get_item(ammo_type).get("name", ammo_type)) if ammo_type != "" else "",
		"ammo_per_attack": int(profile.get("ammo_per_attack", 0)),
		"ammo_available": sandbox.get_item_quantity(ammo_type) if ammo_type != "" else 0,
		"unloaded": bool(profile.get("unloaded", false)),
		"affinity": profile.get("affinity", {}),
	}


static func _defense_section(game, before, after) -> Dictionary:
	var current := _defense_side(game, before)
	var proposed := _defense_side(game, after)
	return {
		"changes": current != proposed,
		"current": current,
		"proposed": proposed,
		"sample_hit": SAMPLE_HIT,
		"block_delta": int(proposed["block_chance"]) - int(current["block_chance"]),
		"dodge_delta": int(proposed["dodge_chance"]) - int(current["dodge_chance"]),
		"taken_delta": int(proposed["sample_taken"]) - int(current["sample_taken"]),
	}


static func _defense_side(game, sandbox) -> Dictionary:
	var equipment: Dictionary = sandbox.run_state["survivor"]["equipment"]
	var armor_id := str(equipment.get("armor", ""))
	var accessory: Dictionary = game.content.get_item(str(equipment.get("accessory", "")))
	var weapon: Dictionary = game.content.get_item(str(equipment.get("weapon", "")))
	var rating := clampi(int(sandbox._armor_rating()), 0, 5)
	var shield_active: bool = bool(accessory.get("shield", false)) and not bool(weapon.get("two_handed", false))
	return {
		"armor_name": str(game.content.get_item(armor_id).get("name", "None")) if armor_id != "" else "None",
		"armor_rating": rating,
		"block_chance": int(NarrativeCombat.preview(sandbox, "block").get("chance", 0)),
		"dodge_chance": int(NarrativeCombat.preview(sandbox, "dodge").get("chance", 0)),
		"sample_taken": int(CombatRules.mitigate_damage(SAMPLE_HIT, rating)["final"]),
		"shield_name": str(accessory.get("name", "")) if bool(accessory.get("shield", false)) else "",
		"shield_active": shield_active,
	}


static func _stat_rows(before, after) -> Array:
	var current: Dictionary = before.combat_effective_stats()
	var proposed: Dictionary = after.combat_effective_stats()
	var rows: Array = []
	for stat: String in GameEngine.STATS:
		var current_value := int(current.get(stat, 0))
		var proposed_value := int(proposed.get(stat, 0))
		rows.append({"stat": stat, "current": current_value, "proposed": proposed_value, "delta": proposed_value - current_value})
	return rows


static func _approach_rows(game, current_id: String, item_id: String) -> Array:
	var current_modifiers: Dictionary = game.content.get_item(current_id).get("modifiers", {}).get("approaches", {}) if current_id != "" else {}
	var proposed_modifiers: Dictionary = game.content.get_item(item_id).get("modifiers", {}).get("approaches", {})
	var names: Array = []
	for approach: String in current_modifiers:
		if approach not in names:
			names.append(approach)
	for approach: String in proposed_modifiers:
		if approach not in names:
			names.append(approach)
	names.sort()
	var rows: Array = []
	for approach: String in names:
		var current_value := int(current_modifiers.get(approach, 0))
		var proposed_value := int(proposed_modifiers.get(approach, 0))
		rows.append({"approach": approach, "current": current_value, "proposed": proposed_value, "delta": proposed_value - current_value})
	return rows


static func _carry_section(before, after) -> Dictionary:
	var weight := float(before.get_total_weight())
	var capacity_current := float(before.get_carry_capacity())
	var capacity_proposed := float(after.get_carry_capacity())
	return {
		"weight": weight,
		"capacity_current": capacity_current,
		"capacity_proposed": capacity_proposed,
		"capacity_delta": capacity_proposed - capacity_current,
		"over_current": weight > capacity_current,
		"over_proposed": weight > capacity_proposed,
	}


static func _notes(game, report: Dictionary) -> Array:
	var notes: Array = []
	var weapon: Dictionary = report["weapon"]
	var proposed_weapon: Dictionary = weapon["proposed"]
	if str(report["shield_removed"]) != "":
		notes.append("Two-handed: %s returns to your inventory and stops adding Block or Dodge." % report["shield_removed"])
	if str(report["blocked_reason"]) != "":
		notes.append(str(report["blocked_reason"]))
	if str(report["slot_conflict"]) != "" and str(report["slot_conflict"]) != str(report["blocked_reason"]):
		notes.append(str(report["slot_conflict"]))
	if bool(proposed_weapon["unloaded"]):
		notes.append("Unloaded: %s needs %d %s and you carry %d, so attacks fall back to Unarmed." % [proposed_weapon["name"], int(proposed_weapon["ammo_per_attack"]), proposed_weapon["ammo_name"], int(proposed_weapon["ammo_available"])])
	elif str(proposed_weapon["ammo_type"]) != "":
		notes.append("Ammunition: %d × %s per attack, %d carried." % [int(proposed_weapon["ammo_per_attack"]), proposed_weapon["ammo_name"], int(proposed_weapon["ammo_available"])])
	if bool(proposed_weapon["mastered"]) and not bool(weapon["current"]["mastered"]):
		notes.append("Mastery: base %s of 6 or more unlocks the stronger %s bonus." % [str(proposed_weapon["attack_stat"]).capitalize(), str(proposed_weapon["family"]).capitalize()])
	elif not bool(proposed_weapon["mastered"]) and str(proposed_weapon["family"]) != "unarmed":
		notes.append("Not mastered: %s reaches its stronger bonus at base %s 6." % [str(proposed_weapon["family"]).capitalize(), str(proposed_weapon["attack_stat"]).capitalize()])
	var proposed_affinity: Dictionary = proposed_weapon.get("affinity", {})
	if bool(proposed_affinity.get("required", false)) and not bool(proposed_affinity.get("met", true)):
		notes.append("Unwieldy: needs base %s %d (you have %d) • −15 hit, −25%% damage until the stat is raised." % [str(proposed_affinity.get("stat", "")).capitalize(), int(proposed_affinity.get("minimum", 0)), int(proposed_affinity.get("have", 0))])
	var carry: Dictionary = report["carry"]
	if bool(carry["over_current"]) and not bool(carry["over_proposed"]):
		notes.append("Capacity: this clears the overweight Agility penalty.")
	elif not bool(carry["over_current"]) and bool(carry["over_proposed"]):
		notes.append("Capacity: this puts you over capacity for an Agility penalty.")
	return notes
