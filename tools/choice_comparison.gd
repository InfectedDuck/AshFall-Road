extends SceneTree
## N02 measured input for the narrative consequence map (§3 of
## docs/NARRATIVE_CONSEQUENCE_MAP.md).
##
## Evaluates every choice of every event in the expanded configuration with the
## engine's own GameEngine.get_choice_preview under six survivor states, four
## starting kits, and two progression levels, then writes
## builds/choice_comparison.json and builds/choice_comparison.md so a card
## author cites measured odds instead of estimating a percentage by hand.
##
## Read-only by construction. It never resolves a choice, never advances an
## event, and never asks the engine for a random number. Every block of previews
## serializes the run state before and after itself and the two serializations
## must match, so the report proves the numbers were measured without moving the
## run, the content, or the RNG stream. The output carries no timestamp, so two
## runs over unchanged content produce byte-identical files.
##
## Usage:
##   Godot --headless --path . --script res://tools/choice_comparison.gd

const JSON_PATH := "res://builds/choice_comparison.json"
const MARKDOWN_PATH := "res://builds/choice_comparison.md"
const TOOL_VERSION := 1

const LEVELS := ["early", "progressed"]
const STATES := ["healthy", "hungry", "injured", "irradiated", "supplied", "depleted"]

## Four kits, one per starting-inventory branch a single highest stat can reach.
## GameEngine._starting_inventory picks its branch from the highest stat, so the
## kit is named after that stat. §3 asks for four and groups "Grit/Presence";
## Grit is the one built, because its branch is the only one that starts with a
## shield and because _starting_inventory reaches it before Presence on a tie.
## The Presence branch (holdout_revolver, trader_token) is not covered here.
const KITS := [
	{"id": "strength", "stat": "strength", "label": "Strength"},
	{"id": "agility", "stat": "agility", "label": "Agility"},
	{"id": "wits", "stat": "wits", "label": "Wits"},
	{"id": "grit", "stat": "grit", "label": "Grit"},
]
const KIT_SEED_BASE := 7000

## Early allocation: 15 points, the kit stat at 5, the other four stats in
## GameEngine.STATS order at 3/3/2/2. The kit stat is the unique maximum, which
## is what _starting_inventory reads.
const EARLY_HIGHEST := 5
const EARLY_OTHERS := [3, 3, 2, 2]
## Progressed allocation: the early one plus 6 points, +3 on the kit stat and +1
## on the first three other stats in GameEngine.STATS order. 21 points total.
const PROGRESSED_HIGHEST := 3
const PROGRESSED_OTHERS := [1, 1, 1, 0]

const HUNGRY_FATIGUE := 40
const IRRADIATED_RADIATION := 60
const LOW_HEALTH_DIVISOR := 4
const SUPPLIED_AMMUNITION := 12
const AMMUNITION_CATEGORY := "ammunition"
const SUPPLIED_SHIELD := "scrap_buckler"
const SUPPLIED_SLOTS := ["weapon", "armor", "backpack", "accessory"]

const PRESSURE_KEYS := ["health", "fatigue", "radiation", "hunger"]
## Reward direction per pressure key. Health is a gain when positive. Fatigue,
## radiation, and hunger are costs when positive; hunger belongs with the costs
## because GameEngine._apply_legacy_pressure turns a negative hunger value into
## a satiety gain and any other value into a satiety loss.
const PRESSURE_HIGHER_IS_BETTER := {"health": true, "fatigue": false, "radiation": false, "hunger": false}
## Fields that decide whether two outcome branches are mechanically identical.
## Everything except the prose, which redundancy explicitly ignores.
const TEXT_FIELDS := ["text"]

var content: ContentRepository
var problems: Array[String] = []
var supplied_gear: Dictionary = {}
var kit_profiles: Array = []
var events: Dictionary = {}
var comparison_values: Dictionary = {}
var totals: Dictionary = {}
var rng_proof: Dictionary = {}


func _init() -> void:
	# Only autostart when Godot is using this script as the main loop.
	if Engine.get_main_loop() == null:
		call_deferred("_run")


func _run() -> void:
	content = ContentRepository.new(true)
	for error: String in content.load_errors:
		problems.append("Content load error: %s" % error)
	for kit: Dictionary in KITS:
		supplied_gear[str(kit["id"])] = _supplied_gear(str(kit["stat"]))
	kit_profiles = _kit_profiles()
	events = _event_records()
	# Counted once up front so a failed read-only assertion still prints a
	# coherent summary instead of a cascade of missing keys.
	_count_totals(0)
	rng_proof = {"blocks": 0, "previews": 0, "rng_state_unchanged": false, "run_state_unchanged": false, "block_rng_states": [], "summary": "not measured"}
	_measure()
	_flag_events()
	var report := _report()
	var written: Array[String] = []
	_write_text(JSON_PATH, JSON.stringify(report, "\t", false), written)
	_write_text(MARKDOWN_PATH, _render_markdown(report), written)
	print("Ashfall Road choice comparison (expanded configuration)")
	print("events=%d choices=%d checked=%d certain=%d combat=%d gated=%d blocked=%d" % [
		int(totals["events"]), int(totals["choices"]), int(totals["checked"]), int(totals["certain"]),
		int(totals["combat"]), int(totals["gated"]), int(totals["blocked"]),
	])
	print("dominant events=%d (strict %d) redundant pairs=%d previews=%d cells=%d" % [
		int(totals["dominant_events"]), int(totals["dominant_strict_events"]), int(totals["redundant_pairs"]),
		int(totals["previews"]), int(totals["cells"]),
	])
	print("RNG proof: %s" % str(rng_proof["summary"]))
	for path: String in written:
		print("wrote %s (%d bytes)" % [path, _file_size(path)])
	for problem: String in problems:
		print("PROBLEM: %s" % problem)
	quit(1 if not problems.is_empty() else 0)


# ------------------------------------------------------------------ kit builds


## Stat block for a kit at a level. The kit stat is the unique maximum so that
## GameEngine._starting_inventory selects the kit's branch.
func _stats_for(kit_stat: String, level: String) -> Dictionary:
	var stats: Dictionary = {}
	var other_index := 0
	for stat: String in GameEngine.STATS:
		if stat == kit_stat:
			stats[stat] = EARLY_HIGHEST + (PROGRESSED_HIGHEST if level == "progressed" else 0)
		else:
			stats[stat] = int(EARLY_OTHERS[other_index]) + (int(PROGRESSED_OTHERS[other_index]) if level == "progressed" else 0)
			other_index += 1
	return stats


## A real run at the requested kit and level. The candidate comes from the
## engine's own generator; its stats, inventory, equipment, and vitals are then
## replaced by the kit's, using the same calls create_candidates makes, so the
## survivor is exactly what the engine would have built for those stats.
func _build_kit_run(engine: GameEngine, kit_index: int, level: String) -> void:
	var kit: Dictionary = KITS[kit_index]
	var seed_value := KIT_SEED_BASE + kit_index
	var candidates := engine.create_candidates(seed_value)
	engine.start_run(candidates[0], seed_value)
	var stats := _stats_for(str(kit["stat"]), level)
	var survivor: Dictionary = engine.run_state["survivor"]
	survivor["stats"] = stats
	survivor["inventory"] = engine._starting_inventory(stats)
	var equipment: Dictionary = {}
	for slot: String in GameEngine.EQUIPMENT_SLOTS:
		equipment[slot] = ""
	survivor["equipment"] = equipment
	engine._auto_equip(survivor)
	var hearts := GameEngine.max_hearts_for_grit(int(stats["grit"]))
	var maximum := hearts * GameEngine.HP_PER_HEART
	survivor["vitals"] = {"health": maximum, "max_health": maximum, "max_hearts": hearts, "satiety": GameEngine.MAX_SATIETY}
	survivor["pressures"] = {"fatigue": 0, "radiation": 0}
	survivor["conditions"] = []
	engine.run_state["flags"] = []
	engine.run_state["phase"] = "event"


## The best gear a kit can hold, read out of the loaded item table rather than
## hard-coded: the highest-damage weapon its attack stat can use, that weapon's
## ammunition, the highest damage_reduction armor (the engine's armor rating),
## the largest backpack, and a shield when the weapon leaves a hand free.
func _supplied_gear(kit_stat: String) -> Dictionary:
	var weapon_id := ""
	var best_damage := -1
	var armor_id := ""
	var best_armor := -1
	var backpack_id := ""
	var best_capacity := -1
	var item_ids: Array = content.items.keys()
	item_ids.sort()
	for item_id: String in item_ids:
		var item: Dictionary = content.get_item(item_id)
		match str(item.get("equipment_slot", "")):
			"weapon":
				var combat: Dictionary = item.get("combat", {})
				if str(combat.get("attack_stat", "")) != kit_stat:
					continue
				# Ranked by maximum damage, then minimum damage, then item id.
				var damage := int(combat.get("damage_max", 0)) * 1000 + int(combat.get("damage_min", 0))
				if damage > best_damage:
					best_damage = damage
					weapon_id = item_id
			"armor":
				var rating := int(item.get("damage_reduction", 0))
				if rating > best_armor:
					best_armor = rating
					armor_id = item_id
			"backpack":
				var capacity := int(item.get("capacity_bonus", 0))
				if capacity > best_capacity:
					best_capacity = capacity
					backpack_id = item_id
	var weapon: Dictionary = content.get_item(weapon_id)
	var two_handed := bool(weapon.get("two_handed", false))
	var ammunition := str(weapon.get("ammo_type", ""))
	var accessory_id := "" if two_handed or content.get_item(SUPPLIED_SHIELD).is_empty() else SUPPLIED_SHIELD
	return {
		"weapon": weapon_id,
		"weapon_damage": "%d-%d" % [int(weapon.get("combat", {}).get("damage_min", 0)), int(weapon.get("combat", {}).get("damage_max", 0))],
		"two_handed": two_handed,
		"ammunition": ammunition,
		"ammunition_quantity": SUPPLIED_AMMUNITION if ammunition != "" else 0,
		"armor": armor_id,
		"armor_rating": best_armor,
		"backpack": backpack_id,
		"backpack_capacity": best_capacity,
		"accessory": accessory_id,
	}


func _kit_profiles() -> Array:
	var profiles: Array = []
	for kit_index in range(KITS.size()):
		var kit: Dictionary = KITS[kit_index]
		var engine := GameEngine.new(content)
		var profile: Dictionary = {
			"id": str(kit["id"]),
			"label": str(kit["label"]),
			"stat": str(kit["stat"]),
			"seed": KIT_SEED_BASE + kit_index,
			"stats": {},
			"inventory": {},
			"equipment": {},
			"max_health": {},
			"supplied": supplied_gear[str(kit["id"])],
			"supplied_equipment": {},
			"supplied_inventory": {},
		}
		for level: String in LEVELS:
			_build_kit_run(engine, kit_index, level)
			profile["stats"][level] = engine.run_state["survivor"]["stats"].duplicate(true)
			profile["inventory"][level] = engine.run_state["survivor"]["inventory"].duplicate(true)
			profile["equipment"][level] = engine.run_state["survivor"]["equipment"].duplicate(true)
			profile["max_health"][level] = int(engine.run_state["survivor"]["vitals"]["max_health"])
			_apply_state(engine, "supplied", kit_index)
			profile["supplied_equipment"][level] = engine.run_state["survivor"]["equipment"].duplicate(true)
			profile["supplied_inventory"][level] = engine.run_state["survivor"]["inventory"].duplicate(true)
		profiles.append(profile)
	return profiles


# --------------------------------------------------------------------- states


## Builds one of the six §3 states on top of an already-built kit run.
func _apply_state(engine: GameEngine, state: String, kit_index: int) -> void:
	var survivor: Dictionary = engine.run_state["survivor"]
	match state:
		"healthy":
			pass
		"hungry":
			survivor["vitals"]["satiety"] = 0
			survivor["pressures"]["fatigue"] = HUNGRY_FATIGUE
		"injured":
			survivor["vitals"]["health"] = _quarter_health(survivor)
			survivor["conditions"] = ["bleeding"]
		"irradiated":
			survivor["pressures"]["radiation"] = IRRADIATED_RADIATION
			survivor["conditions"] = ["irradiated"]
		"supplied":
			_apply_supplied(engine, kit_index)
		"depleted":
			survivor["vitals"]["satiety"] = 0
			survivor["pressures"]["fatigue"] = HUNGRY_FATIGUE
			survivor["pressures"]["radiation"] = IRRADIATED_RADIATION
			survivor["vitals"]["health"] = _quarter_health(survivor)
			survivor["conditions"] = ["exhausted"]
			_strip_ammunition(engine)
		_:
			problems.append("Unknown survivor state '%s'" % state)


func _quarter_health(survivor: Dictionary) -> int:
	return floori(float(int(survivor["vitals"]["max_health"])) / float(LOW_HEALTH_DIVISOR))


## Best gear into the slots, equipped through the engine's own equip_item so the
## two-handed rule that drops a shield is the engine's, not the tool's.
func _apply_supplied(engine: GameEngine, kit_index: int) -> void:
	var gear: Dictionary = supplied_gear[str(KITS[kit_index]["id"])]
	for slot: String in SUPPLIED_SLOTS:
		var item_id := str(gear.get(slot, ""))
		if item_id == "":
			continue
		_ensure_item(engine, item_id)
		var result: Dictionary = engine.equip_item(item_id)
		if not bool(result.get("success", false)):
			problems.append("Supplied gear could not equip %s: %s" % [item_id, str(result.get("text", ""))])
		if slot == "weapon" and str(gear.get("ammunition", "")) != "":
			var ammunition := str(gear["ammunition"])
			var inventory: Dictionary = engine.run_state["survivor"]["inventory"]
			inventory[ammunition] = maxi(int(inventory.get(ammunition, 0)), int(gear["ammunition_quantity"]))


func _ensure_item(engine: GameEngine, item_id: String) -> void:
	var inventory: Dictionary = engine.run_state["survivor"]["inventory"]
	if int(inventory.get(item_id, 0)) < 1:
		inventory[item_id] = 1


## Every ammunition item leaves the pack, so a ranged weapon reads unloaded and
## GameEngine._collect_modifiers reports it as a zero-value modifier.
func _strip_ammunition(engine: GameEngine) -> void:
	var inventory: Dictionary = engine.run_state["survivor"]["inventory"]
	for item_id: String in inventory.keys():
		if str(content.get_item(item_id).get("category", "")) == AMMUNITION_CATEGORY:
			inventory.erase(item_id)


# --------------------------------------------------------------- choice record


func _event_records() -> Dictionary:
	var records: Dictionary = {}
	var event_ids: Array = content.events.keys()
	event_ids.sort()
	for event_id: String in event_ids:
		var event: Dictionary = content.get_event(event_id)
		var choices: Array = event.get("choices", [])
		var entry: Dictionary = {
			"title": str(event.get("title", event_id)),
			"choices": [],
			"dominant": [],
			"redundant": [],
		}
		comparison_values[event_id] = {}
		for index in range(choices.size()):
			entry["choices"].append(_choice_record(event, choices[index]))
			comparison_values[event_id][index] = {}
		if choices.is_empty():
			problems.append("Event '%s' has no choices" % event_id)
		records[event_id] = entry
	return records


func _choice_record(event: Dictionary, choice: Dictionary) -> Dictionary:
	var check: Dictionary = choice.get("check", {})
	var combat_block: Variant = null
	if choice.has("combat"):
		# The engine falls back to the event's adversary when the choice omits one.
		var adversary_id := str(choice.get("combat", {}).get("adversary_id", event.get("adversary_id", "")))
		var adversary: Dictionary = content.get_adversary(adversary_id)
		if adversary.is_empty():
			problems.append("Choice in '%s' names unknown adversary '%s'" % [str(event.get("id", "")), adversary_id])
		combat_block = {
			"adversary_id": adversary_id,
			"threat": int(adversary.get("threat", 0)),
			"xp_reward": int(adversary.get("xp_reward", 0)),
			"can_flee": bool(choice.get("combat", {}).get("can_flee", true)),
		}
	var check_block: Variant = null
	if not check.is_empty():
		check_block = {"stat": str(check.get("stat", "wits")), "difficulty": str(check.get("difficulty", "risky"))}
	return {
		"label": str(choice.get("label", "")),
		"approach": str(choice.get("approach", "")),
		"check": check_block,
		"combat": combat_block,
		"certain": check_block == null and combat_block == null,
		"gated_by": [],
		"blocked": [],
		"requires": _requirement_map(choice.get("requires", {})),
		"costs": _requirement_map(choice.get("costs", {})),
		"success": _outcome_fields(_success_branch(choice)),
		"failure": _outcome_fields(choice.get("failure", {})),
		"chances": _empty_cells(),
		"required_roll": _empty_cells(),
	}


## The branch a successful resolution reads: `success` for a check, `outcome`
## for a certain choice, `victory` for a fight.
func _success_branch(choice: Dictionary) -> Dictionary:
	for key: String in ["success", "outcome", "victory"]:
		if choice.has(key):
			return choice[key]
	return {}


func _outcome_fields(branch: Dictionary) -> Dictionary:
	return {
		"items": _int_map(branch.get("items", {})),
		"pressures": _int_map(branch.get("pressures", {})),
		"add_conditions": branch.get("add_conditions", []).duplicate(true),
		"add_flags": branch.get("add_flags", []).duplicate(true),
		"next_event": str(branch.get("next_event", "")),
		"lethal": bool(branch.get("lethal", false)),
		"victory": bool(branch.get("victory", false)),
	}


## Godot's JSON loader returns every number as a float and the engine reads
## these fields through int(), so the report writes the quantity the engine will
## actually apply rather than 2.0 for two cans.
func _int_map(source: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key: Variant in source:
		result[str(key)] = int(source[key])
	return result


func _requirement_map(source: Dictionary) -> Dictionary:
	var result: Dictionary = source.duplicate(true)
	for key: String in ["items", "stats"]:
		if result.has(key):
			result[key] = _int_map(result[key])
	return result


func _empty_cells() -> Dictionary:
	var cells: Dictionary = {}
	for kit: Dictionary in KITS:
		var levels: Dictionary = {}
		for level: String in LEVELS:
			var states: Dictionary = {}
			for state: String in STATES:
				states[state] = null
			levels[level] = states
		cells[str(kit["id"])] = levels
	return cells


# ----------------------------------------------------------------- measurement


func _measure() -> void:
	var previews := 0
	var blocks: Array = []
	var rng_unchanged := true
	var state_unchanged := true
	for kit_index in range(KITS.size()):
		var kit_id := str(KITS[kit_index]["id"])
		var engine := GameEngine.new(content)
		for level: String in LEVELS:
			for state: String in STATES:
				_build_kit_run(engine, kit_index, level)
				_apply_state(engine, state, kit_index)
				var rng_before := int(engine.run_state.get("rng_state", 0))
				var serialized_before := JSON.stringify(engine.run_state, "", false)
				previews += _measure_block(engine, kit_id, level, state)
				var rng_after := int(engine.run_state.get("rng_state", 0))
				var serialized_after := JSON.stringify(engine.run_state, "", false)
				assert(rng_before == rng_after, "get_choice_preview consumed RNG; the comparison is not read-only.")
				assert(serialized_before == serialized_after, "The comparison changed the run state it measured.")
				if rng_before != rng_after:
					rng_unchanged = false
					problems.append("rng_state moved from %d to %d in %s/%s/%s" % [rng_before, rng_after, kit_id, level, state])
				if serialized_before != serialized_after:
					state_unchanged = false
					problems.append("Run state changed while measuring %s/%s/%s" % [kit_id, level, state])
				blocks.append({"kit": kit_id, "level": level, "state": state, "rng_state": rng_before, "rng_state_after": rng_after})
	rng_proof = {
		"blocks": blocks.size(),
		"previews": previews,
		"rng_state_unchanged": rng_unchanged,
		"run_state_unchanged": state_unchanged,
		"block_rng_states": blocks,
		"summary": "%d previews across %d kit/level/state blocks; rng_state unchanged in every block (%s); run state byte-identical before and after every block (%s)" % [
			previews, blocks.size(),
			"yes" if rng_unchanged else "NO",
			"yes" if state_unchanged else "NO",
		],
	}
	_count_totals(previews)


## One kit/level/state block: every choice of every event, in sorted event order.
func _measure_block(engine: GameEngine, kit_id: String, level: String, state: String) -> int:
	var previews := 0
	# The event cursor is the only thing the block moves, and it is put back
	# before the caller compares the run state with the one it started from.
	var cursor := str(engine.run_state.get("current_event_id", ""))
	var phase := str(engine.run_state.get("phase", ""))
	for event_id: String in events:
		var event: Dictionary = content.get_event(event_id)
		engine.run_state["current_event_id"] = event_id
		engine.run_state["phase"] = "event"
		var choices: Array = event.get("choices", [])
		var records: Array = events[event_id]["choices"]
		for index in range(choices.size()):
			var choice: Dictionary = choices[index]
			var record: Dictionary = records[index]
			var granted: Array = []
			var preview: Dictionary = engine.get_choice_preview(choice)
			previews += 1
			if not bool(preview.get("available", false)):
				granted = _grant_gates(engine, choice)
				if not granted.is_empty():
					preview = engine.get_choice_preview(choice)
					previews += 1
			_record_cell(record, comparison_values[event_id][index], kit_id, level, state, preview, granted)
			_restore_gates(engine, granted)
	engine.run_state["current_event_id"] = cursor
	engine.run_state["phase"] = phase
	return previews


func _record_cell(record: Dictionary, values: Dictionary, kit_id: String, level: String, state: String, preview: Dictionary, granted: Array) -> void:
	for gate: Dictionary in granted:
		var label := str(gate["label"])
		if label not in record["gated_by"]:
			record["gated_by"].append(label)
	var cell := "%s/%s/%s" % [kit_id, level, state]
	var chance: Variant = null
	var required: Variant = null
	# The comparison value is the chance, 100 for a certain choice, and -1 when
	# the choice cannot be taken in this state at all.
	var value := -1
	if not bool(preview.get("available", false)):
		var reason := "%s: %s" % [cell, str(preview.get("reason", "unavailable"))]
		if reason not in record["blocked"]:
			record["blocked"].append(reason)
	elif record["combat"] != null:
		value = -1
	elif bool(record["certain"]):
		value = 100
	else:
		chance = int(preview.get("chance", 0))
		required = int(preview.get("required_roll", 0))
		value = int(chance)
	record["chances"][kit_id][level][state] = chance
	record["required_roll"][kit_id][level][state] = required
	values[cell] = value


## Temporarily satisfies what a choice asks for so a gated choice still reports
## its odds. Flags are appended, missing items are added, and both are undone by
## _restore_gates before the next choice is measured.
func _grant_gates(engine: GameEngine, choice: Dictionary) -> Array:
	var granted: Array = []
	var requires: Dictionary = choice.get("requires", {})
	for flag: Variant in requires.get("flags", []):
		if str(flag) not in engine.run_state["flags"]:
			engine.run_state["flags"].append(str(flag))
			granted.append({"kind": "flag", "id": str(flag), "amount": 0, "label": "flag %s" % str(flag)})
	var any_flags: Array = requires.get("any_flags", [])
	if not any_flags.is_empty():
		var satisfied := false
		for flag: Variant in any_flags:
			if str(flag) in engine.run_state["flags"]:
				satisfied = true
				break
		if not satisfied:
			var first := str(any_flags[0])
			engine.run_state["flags"].append(first)
			granted.append({"kind": "flag", "id": first, "amount": 0, "label": "any_flag %s (1 of %d)" % [first, any_flags.size()]})
	var needed: Dictionary = {}
	for item_id: Variant in requires.get("items", {}):
		needed[str(item_id)] = maxi(int(needed.get(str(item_id), 0)), int(requires["items"][item_id]))
	for item_id: Variant in choice.get("costs", {}).get("items", {}):
		needed[str(item_id)] = maxi(int(needed.get(str(item_id), 0)), int(choice["costs"]["items"][item_id]))
	for item_id: String in needed:
		var missing := int(needed[item_id]) - engine.get_item_quantity(item_id)
		if missing > 0:
			engine.run_state["survivor"]["inventory"][item_id] = engine.get_item_quantity(item_id) + missing
			granted.append({"kind": "item", "id": item_id, "amount": missing, "label": "item %s x%d" % [item_id, missing]})
	for stat: Variant in requires.get("stats", {}):
		if int(engine.run_state["survivor"]["stats"].get(str(stat), 0)) < int(requires["stats"][stat]):
			var note := "Choice '%s' requires %s %d; a stat gate is not granted because raising it would change the measured odds" % [
				str(choice.get("label", "")), str(stat), int(requires["stats"][stat]),
			]
			if note not in problems:
				problems.append(note)
	return granted


func _restore_gates(engine: GameEngine, granted: Array) -> void:
	for gate: Dictionary in granted:
		if str(gate["kind"]) == "flag":
			engine.run_state["flags"].erase(str(gate["id"]))
			continue
		var item_id := str(gate["id"])
		var remaining := engine.get_item_quantity(item_id) - int(gate["amount"])
		if remaining > 0:
			engine.run_state["survivor"]["inventory"][item_id] = remaining
		else:
			engine.run_state["survivor"]["inventory"].erase(item_id)


func _count_totals(previews: int) -> void:
	var choices := 0
	var checked := 0
	var certain := 0
	var combat := 0
	var gated := 0
	var blocked := 0
	for event_id: String in events:
		for record: Dictionary in events[event_id]["choices"]:
			choices += 1
			if record["combat"] != null:
				combat += 1
			elif bool(record["certain"]):
				certain += 1
			else:
				checked += 1
			if not record["gated_by"].is_empty():
				gated += 1
			if not record["blocked"].is_empty():
				blocked += 1
	totals = {
		"events": events.size(),
		"choices": choices,
		"checked": checked,
		"certain": certain,
		"combat": combat,
		"gated": gated,
		"blocked": blocked,
		"states": STATES.size(),
		"kits": KITS.size(),
		"levels": LEVELS.size(),
		"cells": choices * STATES.size() * KITS.size() * LEVELS.size(),
		"previews": previews,
		"dominant_events": 0,
		"dominant_strict_events": 0,
		"redundant_pairs": 0,
	}


# --------------------------------------------------------- dominance and waste


func _flag_events() -> void:
	var dominant_events := 0
	var strict_events := 0
	var redundant_pairs := 0
	for event_id: String in events:
		var entry: Dictionary = events[event_id]
		var records: Array = entry["choices"]
		var source: Array = content.get_event(event_id).get("choices", [])
		var comparable: Array = []
		for index in range(records.size()):
			if records[index]["combat"] == null:
				comparable.append(index)
		if comparable.size() >= 2:
			for i: int in comparable:
				var dominant := true
				for j: int in comparable:
					if i == j:
						continue
					if not _chance_at_least(event_id, i, j):
						dominant = false
						break
					if not _reward_at_least(records[i]["success"], records[j]["success"]):
						dominant = false
						break
					if not _cost_no_greater(source[i], source[j]):
						dominant = false
						break
				if dominant:
					entry["dominant"].append(i)
		for i in range(records.size()):
			for j in range(i + 1, records.size()):
				if _redundant(source[i], source[j]):
					entry["redundant"].append([i, j])
		if not entry["dominant"].is_empty():
			dominant_events += 1
			for index: int in entry["dominant"]:
				if _dominance_is_strict(event_id, index):
					strict_events += 1
					break
		redundant_pairs += entry["redundant"].size()
	totals["dominant_events"] = dominant_events
	totals["dominant_strict_events"] = strict_events
	totals["redundant_pairs"] = redundant_pairs


## True when the choice beats at least one sibling on something, rather than
## merely tying every sibling. A scene whose choices are mechanically identical
## satisfies the §3 dominance rule in every direction; the rule still flags them
## all, and this marks the flag as a tie so a card author reads it correctly.
func _dominance_is_strict(event_id: String, index: int) -> bool:
	var records: Array = events[event_id]["choices"]
	var source: Array = content.get_event(event_id).get("choices", [])
	for sibling in range(records.size()):
		if sibling == index or records[sibling]["combat"] != null:
			continue
		var reversed_holds: bool = (
			_chance_at_least(event_id, sibling, index)
			and _reward_at_least(records[sibling]["success"], records[index]["success"])
			and _cost_no_greater(source[sibling], source[index])
		)
		if not reversed_holds:
			return true
	return false


## Chance at least the sibling's in every kit, level, and state. A certain
## choice counts as 100; a choice that cannot be taken at all counts as -1, so
## it never beats a sibling and never blocks one.
func _chance_at_least(event_id: String, index: int, sibling: int) -> bool:
	var mine: Dictionary = comparison_values[event_id][index]
	var theirs: Dictionary = comparison_values[event_id][sibling]
	for cell: String in mine:
		if int(mine[cell]) < int(theirs.get(cell, -1)):
			return false
	return true


## Success reward at least as good: every item quantity at least the sibling's
## and at least as many items gained in total, every pressure no worse, and no
## harmful condition the sibling does not also inflict.
func _reward_at_least(mine: Dictionary, theirs: Dictionary) -> bool:
	var my_items: Dictionary = mine["items"]
	var their_items: Dictionary = theirs["items"]
	var item_ids: Dictionary = {}
	for item_id: Variant in my_items:
		item_ids[str(item_id)] = true
	for item_id: Variant in their_items:
		item_ids[str(item_id)] = true
	var my_gained := 0
	var their_gained := 0
	for item_id: String in item_ids:
		var my_quantity := int(my_items.get(item_id, 0))
		var their_quantity := int(their_items.get(item_id, 0))
		if my_quantity < their_quantity:
			return false
		my_gained += maxi(0, my_quantity)
		their_gained += maxi(0, their_quantity)
	if my_gained < their_gained:
		return false
	for pressure: String in PRESSURE_KEYS:
		var my_value := int(mine["pressures"].get(pressure, 0))
		var their_value := int(theirs["pressures"].get(pressure, 0))
		if bool(PRESSURE_HIGHER_IS_BETTER[pressure]):
			if my_value < their_value:
				return false
		elif my_value > their_value:
			return false
	for condition_id: Variant in mine["add_conditions"]:
		if _is_harmful(str(condition_id)) and str(condition_id) not in theirs["add_conditions"]:
			return false
	return true


## A condition is harmful when the loaded condition table gives it at least one
## negative stat modifier.
func _is_harmful(condition_id: String) -> bool:
	var modifiers: Dictionary = content.get_condition(condition_id).get("modifiers", {})
	for stat: Variant in modifiers:
		if int(modifiers[stat]) < 0:
			return true
	return false


## Known cost no greater: for every item, what this choice demands up front
## (`requires.items` or `costs.items`, whichever is larger) is at most what the
## sibling demands.
func _cost_no_greater(mine: Dictionary, theirs: Dictionary) -> bool:
	var my_costs := _known_item_cost(mine)
	var their_costs := _known_item_cost(theirs)
	for item_id: String in my_costs:
		if int(my_costs[item_id]) > int(their_costs.get(item_id, 0)):
			return false
	return true


func _known_item_cost(choice: Dictionary) -> Dictionary:
	var costs: Dictionary = {}
	for item_id: Variant in choice.get("requires", {}).get("items", {}):
		costs[str(item_id)] = maxi(int(costs.get(str(item_id), 0)), int(choice["requires"]["items"][item_id]))
	for item_id: Variant in choice.get("costs", {}).get("items", {}):
		costs[str(item_id)] = maxi(int(costs.get(str(item_id), 0)), int(choice["costs"]["items"][item_id]))
	return costs


## Two choices are redundant when their success and failure branches are
## mechanically identical with the prose removed, or when they carry the same
## label.
func _redundant(mine: Dictionary, theirs: Dictionary) -> bool:
	if str(mine.get("label", "")).strip_edges() == str(theirs.get("label", "")).strip_edges():
		return true
	return _branch_signature(mine) == _branch_signature(theirs)


func _branch_signature(choice: Dictionary) -> String:
	return JSON.stringify([
		_canonical(_strip_text(_success_branch(choice))),
		_canonical(_strip_text(choice.get("failure", {}))),
	], "", false)


func _strip_text(branch: Dictionary) -> Dictionary:
	var stripped: Dictionary = branch.duplicate(true)
	for field: String in TEXT_FIELDS:
		stripped.erase(field)
	return stripped


## Sorted keys and sorted string arrays, so "identical" does not depend on the
## order the author happened to type the fields in.
func _canonical(value: Variant) -> Variant:
	if typeof(value) == TYPE_DICTIONARY:
		var keys: Array = (value as Dictionary).keys()
		keys.sort()
		var ordered: Dictionary = {}
		for key: Variant in keys:
			ordered[str(key)] = _canonical((value as Dictionary)[key])
		return ordered
	if typeof(value) == TYPE_ARRAY:
		var items: Array = []
		var strings := true
		for entry: Variant in value:
			items.append(_canonical(entry))
			if typeof(entry) != TYPE_STRING:
				strings = false
		if strings:
			items.sort()
		return items
	return value


# ------------------------------------------------------------------- reporting


func _report() -> Dictionary:
	return {
		"tool": "tools/choice_comparison.gd",
		"tool_version": TOOL_VERSION,
		"configuration": "expanded",
		"rules_version": D20Resolver.RULES_VERSION,
		"purpose": "Measured input for NARRATIVE_CONSEQUENCE_MAP.md §3. Read-only: no content, data file, or run is changed.",
		"states": _state_definitions(),
		"rules": _rule_text(),
		"kits": kit_profiles,
		"totals": totals,
		"rng_proof": rng_proof,
		"events": events,
	}


func _state_definitions() -> Dictionary:
	return {
		"healthy": "Full HP, satiety %d, pressures 0, no conditions, starting kit." % GameEngine.MAX_SATIETY,
		"hungry": "Healthy, then satiety 0 and fatigue %d." % HUNGRY_FATIGUE,
		"injured": "Healthy, then health = floor(max_health / %d) and the bleeding condition." % LOW_HEALTH_DIVISOR,
		"irradiated": "Healthy, then radiation %d and the irradiated condition." % IRRADIATED_RADIATION,
		"supplied": "Healthy, then the best gear the kit can hold, equipped through the engine, with %d rounds for a weapon that needs them." % SUPPLIED_AMMUNITION,
		"depleted": "Satiety 0, fatigue %d, health = floor(max_health / %d), radiation %d, the exhausted condition, and every ammunition item removed." % [HUNGRY_FATIGUE, LOW_HEALTH_DIVISOR, IRRADIATED_RADIATION],
	}


func _rule_text() -> Dictionary:
	return {
		"dominant_quoted": "Dominant — among a scene's choices, one has chance ≥ every sibling in every state and a success reward at least as good by the item/pressure totals and no greater known cost. A dominant choice makes its siblings decoration.",
		"redundant_quoted": "Redundant — two choices whose success and failure fields are identical, or whose intentions read the same. Redundancy is P1; dominance is P1 unless the dominated choice preserves useful expertise (a stat the player invested in), in which case the card says so and keeps it.",
		"dominant_applied": [
			"Chance: the choice's chance is at least every sibling's in all %d cells (%d kits x %d levels x %d states). A certain choice counts as 100. A choice that cannot be taken in a cell counts as -1." % [KITS.size() * LEVELS.size() * STATES.size(), KITS.size(), LEVELS.size(), STATES.size()],
			"Items: for every item id the success quantity is at least the sibling's, and the total of positive quantities is at least the sibling's.",
			"Pressures: health at least the sibling's; fatigue, radiation, and hunger no higher than the sibling's.",
			"Conditions: no harmful condition (one with a negative modifier in conditions.json) that the sibling does not also add.",
			"Known cost: for every item, max(requires.items, costs.items) is at most the sibling's.",
			"Combat choices are excluded from dominance entirely and are reported by threat, XP, and flee availability instead.",
		],
		"redundant_applied": [
			"Success and failure branches identical once the prose (text) is removed, with dictionary keys and string arrays sorted first, or",
			"identical labels after trimming whitespace.",
			"Combat choices are included here: two fights in one scene with the same fields are as redundant as two checks.",
		],
		"notes": [
			"Two mechanically identical choices satisfy the dominance rule in both directions, so an event can be flagged dominant and redundant at once; the redundancy is the finding to act on. The markdown marks such a flag '(ties every sibling)' and the totals count how many dominant events hold a choice that actually beats a sibling.",
			"A gated choice is measured with its gate temporarily satisfied, so its odds are real but its availability is not universal. Gates are listed per choice and repeated in the finding line.",
		],
	}


# -------------------------------------------------------------------- markdown


func _render_markdown(report: Dictionary) -> String:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("# Choice comparison (measured)")
	lines.append("")
	lines.append("Generated by `tools/choice_comparison.gd` for §3 of [NARRATIVE_CONSEQUENCE_MAP.md](../docs/NARRATIVE_CONSEQUENCE_MAP.md).")
	lines.append("Expanded configuration, D20 rules version %d. Every number here is the engine's own" % int(report["rules_version"]))
	lines.append("`GameEngine.get_choice_preview`, not an estimate. The tool changes no content and")
	lines.append("resolves nothing, so re-running it over unchanged content rewrites identical files.")
	lines.append("")
	lines.append("- Events %d, choices %d: %d checked, %d certain, %d combat." % [
		int(totals["events"]), int(totals["choices"]), int(totals["checked"]), int(totals["certain"]), int(totals["combat"]),
	])
	lines.append("- %d choices are gated behind a flag or an item; %d are blocked in at least one state." % [int(totals["gated"]), int(totals["blocked"])])
	lines.append("- %d previews over %d cells (%d kits x %d levels x %d states per choice)." % [
		int(totals["previews"]), int(totals["cells"]), int(totals["kits"]), int(totals["levels"]), int(totals["states"]),
	])
	lines.append("- %d events carry a dominant choice; %d redundant pairs." % [int(totals["dominant_events"]), int(totals["redundant_pairs"])])
	lines.append("- Read-only proof: %s." % str(rng_proof["summary"]))
	lines.append("")
	_append_state_section(lines)
	_append_kit_section(lines)
	_append_rule_section(lines, report)
	_append_event_sections(lines)
	_append_findings_section(lines)
	return "\n".join(lines) + "\n"


func _append_state_section(lines: PackedStringArray) -> void:
	lines.append("## The six survivor states")
	lines.append("")
	lines.append("Each state is built on a real run of each kit, then measured. The right column is")
	lines.append("what the engine itself then applies through `_collect_modifiers` and `_pressure_penalty`.")
	lines.append("")
	lines.append("| State | How the tool builds it | Engine effect on a check |")
	lines.append("|---|---|---|")
	lines.append("| healthy | Full HP, satiety %d, pressures 0, no conditions, starting kit | none |" % GameEngine.MAX_SATIETY)
	lines.append("| hungry | satiety 0, fatigue %d | -3 satiety, -1 fatigue band |" % HUNGRY_FATIGUE)
	lines.append("| injured | health = floor(max_health / %d), condition `bleeding` | -2 low health, Strength -1, Grit -1 |" % LOW_HEALTH_DIVISOR)
	lines.append("| irradiated | radiation %d, condition `irradiated` | -2 radiation band, Strength -1, Grit -2 |" % IRRADIATED_RADIATION)
	lines.append("| supplied | healthy plus the best gear the kit can hold, %d rounds when the weapon needs them | item stat and approach modifiers |" % SUPPLIED_AMMUNITION)
	lines.append("| depleted | satiety 0, fatigue %d, health = floor(max_health / %d), radiation %d, condition `exhausted`, every ammunition item removed | all of the above, and a ranged weapon reads unloaded |" % [HUNGRY_FATIGUE, LOW_HEALTH_DIVISOR, IRRADIATED_RADIATION])
	lines.append("")


func _append_kit_section(lines: PackedStringArray) -> void:
	lines.append("## The four kits")
	lines.append("")
	lines.append("`GameEngine._starting_inventory` chooses the kit from the highest stat, so each kit")
	lines.append("is named after that stat. Early is 15 points: the kit stat at %d and the other four" % EARLY_HIGHEST)
	lines.append("in `GameEngine.STATS` order at %d/%d/%d/%d. Progressed adds 6 points: +%d on the kit" % [
		int(EARLY_OTHERS[0]), int(EARLY_OTHERS[1]), int(EARLY_OTHERS[2]), int(EARLY_OTHERS[3]), PROGRESSED_HIGHEST,
	])
	lines.append("stat and +1 on the first three other stats in the same order, for 21 points. The")
	lines.append("Presence branch of `_starting_inventory` is the one not covered by these four.")
	lines.append("")
	lines.append("| Kit | Early stats | Progressed stats | Max HP early / progressed | Starting inventory | Starting equipment |")
	lines.append("|---|---|---|---|---|---|")
	for profile: Dictionary in kit_profiles:
		lines.append("| %s | %s | %s | %d / %d | %s | %s |" % [
			str(profile["label"]),
			_stat_text(profile["stats"]["early"]),
			_stat_text(profile["stats"]["progressed"]),
			int(profile["max_health"]["early"]), int(profile["max_health"]["progressed"]),
			_item_text(profile["inventory"]["early"]),
			_equipment_text(profile["equipment"]["early"]),
		])
	lines.append("")
	lines.append("### Supplied gear per kit")
	lines.append("")
	lines.append("The weapon is the highest-damage one in `data/items.json` whose `combat.attack_stat`")
	lines.append("is the kit's stat (ranked by maximum damage, then minimum damage, then id); the armor")
	lines.append("is the highest `damage_reduction`, which is the rating `GameEngine._armor_rating`")
	lines.append("reads; the backpack is the largest `capacity_bonus`; the shield is `%s`, which the" % SUPPLIED_SHIELD)
	lines.append("engine refuses to equip beside a two-handed weapon, so those kits keep the accessory")
	lines.append("their kit started with. Everything is equipped through `GameEngine.equip_item`.")
	lines.append("")
	lines.append("| Kit | Weapon | Damage | Ammunition | Armor | Backpack | Accessory | Equipped result (early) |")
	lines.append("|---|---|---|---|---|---|---|---|")
	for profile: Dictionary in kit_profiles:
		var gear: Dictionary = profile["supplied"]
		var ammunition := "none" if str(gear["ammunition"]) == "" else "%s x%d" % [str(gear["ammunition"]), int(gear["ammunition_quantity"])]
		var accessory := "none (two-handed weapon)" if str(gear["accessory"]) == "" else str(gear["accessory"])
		lines.append("| %s | %s%s | %s | %s | %s (DR %d) | %s (+%d) | %s | %s |" % [
			str(profile["label"]), str(gear["weapon"]), " (two-handed)" if bool(gear["two_handed"]) else "",
			str(gear["weapon_damage"]), ammunition,
			str(gear["armor"]), int(gear["armor_rating"]),
			str(gear["backpack"]), int(gear["backpack_capacity"]),
			accessory,
			_equipment_text(profile["supplied_equipment"]["early"]),
		])
	lines.append("")


func _append_rule_section(lines: PackedStringArray, report: Dictionary) -> void:
	var rules: Dictionary = report["rules"]
	lines.append("## Dominance and redundancy")
	lines.append("")
	lines.append("Quoted from §3 of the map:")
	lines.append("")
	lines.append("> **Dominant** — among a scene's choices, one has chance ≥ every sibling in every")
	lines.append("> state *and* a success reward at least as good by the item/pressure totals *and* no")
	lines.append("> greater known cost. A dominant choice makes its siblings decoration.")
	lines.append(">")
	lines.append("> **Redundant** — two choices whose success and failure fields are identical, or")
	lines.append("> whose intentions read the same. Redundancy is P1; dominance is P1 unless the")
	lines.append("> dominated choice preserves useful expertise (a stat the player invested in), in")
	lines.append("> which case the card says so and keeps it.")
	lines.append(">")
	lines.append("> Certain choices (no check) are compared by reward only. Combat choices are")
	lines.append("> compared by threat, XP, and flee availability.")
	lines.append("")
	lines.append("A tool cannot read an intention, so it applies exactly this and nothing else:")
	lines.append("")
	lines.append("**Dominant**")
	lines.append("")
	for rule: String in rules["dominant_applied"]:
		lines.append("- %s" % rule)
	lines.append("")
	lines.append("**Redundant**")
	lines.append("")
	for rule: String in rules["redundant_applied"]:
		lines.append("- %s" % rule)
	lines.append("")
	for note: String in rules["notes"]:
		lines.append("- Note: %s" % note)
	lines.append("")
	lines.append("## Reading a table")
	lines.append("")
	lines.append("One row per choice. The six state columns hold the chance range across the four")
	lines.append("kits at the **early** level: a single number when all four agree, `55-70` when they")
	lines.append("do not. Per-kit numbers, the progressed level, and the required roll are in")
	lines.append("`choice_comparison.json`. A certain choice reads `certain`; a fight reads")
	lines.append("`fight T<threat> +<xp>xp flee:<y/n>`, repeated across the states because threat and")
	lines.append("XP do not move with the survivor. `blocked` means the choice cannot be taken in that")
	lines.append("state, and a trailing `*` means it is blocked for some kits and not others. The")
	lines.append("flags column lists the flags the success branch writes; a flag the failure branch")
	lines.append("writes carries a trailing `(f)`.")
	lines.append("")


func _append_event_sections(lines: PackedStringArray) -> void:
	lines.append("## Per-event comparison")
	lines.append("")
	for event_id: String in events:
		var entry: Dictionary = events[event_id]
		lines.append("### %s - %s" % [event_id, str(entry["title"])])
		lines.append("")
		lines.append("| # | label | check | healthy | hungry | injured | irradiated | supplied | depleted | flags |")
		lines.append("|---|---|---|---|---|---|---|---|---|---|")
		var records: Array = entry["choices"]
		for index in range(records.size()):
			var record: Dictionary = records[index]
			var cells: PackedStringArray = PackedStringArray()
			for state: String in STATES:
				cells.append(_cell_text(event_id, index, record, state))
			lines.append("| %d | %s | %s | %s | %s |" % [
				index, _escape(str(record["label"])), _check_text(record), " | ".join(cells), _flag_text(record),
			])
		lines.append("")
		lines.append("- %s" % _finding_text(event_id, entry))
		lines.append("")


func _append_findings_section(lines: PackedStringArray) -> void:
	lines.append("## Findings")
	lines.append("")
	var flagged := 0
	for event_id: String in events:
		var entry: Dictionary = events[event_id]
		if entry["dominant"].is_empty() and entry["redundant"].is_empty():
			continue
		flagged += 1
		lines.append("- `%s` - %s" % [event_id, _finding_text(event_id, entry)])
	if flagged == 0:
		lines.append("- No event carries a dominant or redundant choice.")
	lines.append("")
	lines.append("%d of %d events carry a dominant or redundant flag: %d with a dominant choice, %d redundant pairs in total." % [
		flagged, int(totals["events"]), int(totals["dominant_events"]), int(totals["redundant_pairs"]),
	])
	lines.append("")
	lines.append("Of the %d events with a dominant choice, %d hold a choice that actually beats a" % [int(totals["dominant_events"]), int(totals["dominant_strict_events"])])
	lines.append("sibling; in the other %d every choice satisfies the rule against every other, which" % [int(totals["dominant_events"]) - int(totals["dominant_strict_events"])])
	lines.append("means the scene draws no mechanical distinction between its options at all.")
	lines.append("")


func _finding_text(event_id: String, entry: Dictionary) -> String:
	var parts: PackedStringArray = PackedStringArray()
	if not entry["dominant"].is_empty():
		var dominant: PackedStringArray = PackedStringArray()
		for index: int in entry["dominant"]:
			var record: Dictionary = entry["choices"][index]
			var gate := "" if record["gated_by"].is_empty() else " gated by %s" % ", ".join(_string_array(record["gated_by"]))
			var tie := "" if _dominance_is_strict(event_id, index) else " (ties every sibling)"
			dominant.append("[%d] %s%s%s" % [index, _escape(str(record["label"])), gate, tie])
		parts.append("dominant: %s" % "; ".join(dominant))
	if not entry["redundant"].is_empty():
		var redundant: PackedStringArray = PackedStringArray()
		for pair: Array in entry["redundant"]:
			redundant.append("[%d,%d]" % [int(pair[0]), int(pair[1])])
		parts.append("redundant: %s" % ", ".join(redundant))
	var gated: PackedStringArray = PackedStringArray()
	for index in range(entry["choices"].size()):
		var record: Dictionary = entry["choices"][index]
		if not record["gated_by"].is_empty():
			gated.append("[%d] %s" % [index, ", ".join(_string_array(record["gated_by"]))])
	if not gated.is_empty():
		parts.append("gated: %s" % "; ".join(gated))
	var blocked: PackedStringArray = PackedStringArray()
	for index in range(entry["choices"].size()):
		var record: Dictionary = entry["choices"][index]
		if not record["blocked"].is_empty():
			blocked.append("[%d] %s" % [index, ", ".join(_string_array(record["blocked"]))])
	if not blocked.is_empty():
		parts.append("blocked: %s" % "; ".join(blocked))
	return "none" if parts.is_empty() else " | ".join(parts)


func _cell_text(event_id: String, index: int, record: Dictionary, state: String) -> String:
	if record["combat"] != null:
		var combat: Dictionary = record["combat"]
		return "fight T%d +%dxp flee:%s" % [int(combat["threat"]), int(combat["xp_reward"]), "y" if bool(combat["can_flee"]) else "n"]
	var lowest := -1
	var highest := -1
	var blocked := 0
	var values: Dictionary = comparison_values[event_id][index]
	for kit: Dictionary in KITS:
		var value := int(values.get("%s/early/%s" % [str(kit["id"]), state], -1))
		if value < 0:
			blocked += 1
			continue
		lowest = value if lowest < 0 else mini(lowest, value)
		highest = maxi(highest, value)
	var marker := "*" if blocked > 0 and blocked < KITS.size() else ""
	if blocked == KITS.size():
		return "blocked"
	if bool(record["certain"]):
		return "certain%s" % marker
	if lowest == highest:
		return "%d%s" % [lowest, marker]
	return "%d-%d%s" % [lowest, highest, marker]


func _check_text(record: Dictionary) -> String:
	if record["combat"] != null:
		return "combat"
	if record["check"] == null:
		return "certain"
	var check: Dictionary = record["check"]
	var approach := str(record["approach"])
	return "%s %s%s" % [str(check["stat"]), str(check["difficulty"]), "" if approach == "" else " (%s)" % approach]


func _flag_text(record: Dictionary) -> String:
	var flags: PackedStringArray = PackedStringArray()
	for flag: Variant in record["success"]["add_flags"]:
		flags.append(str(flag))
	for flag: Variant in record["failure"]["add_flags"]:
		if str(flag) not in flags:
			flags.append("%s (f)" % str(flag))
	return "-" if flags.is_empty() else " ".join(flags)


func _stat_text(stats: Dictionary) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for stat: String in GameEngine.STATS:
		parts.append("%s %d" % [stat.substr(0, 3).capitalize(), int(stats.get(stat, 0))])
	return " ".join(parts)


func _item_text(items: Dictionary) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for item_id: String in items:
		parts.append("%s x%d" % [item_id, int(items[item_id])])
	return "-" if parts.is_empty() else ", ".join(parts)


func _equipment_text(equipment: Dictionary) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for slot: String in GameEngine.EQUIPMENT_SLOTS:
		var item_id := str(equipment.get(slot, ""))
		if item_id != "":
			parts.append("%s: %s" % [slot, item_id])
	return "-" if parts.is_empty() else ", ".join(parts)


func _string_array(values: Array) -> PackedStringArray:
	var strings: PackedStringArray = PackedStringArray()
	for value: Variant in values:
		strings.append(str(value))
	return strings


## Table cells are pipe-separated, so a label containing one must be escaped.
func _escape(text: String) -> String:
	return text.replace("|", "\\|")


# -------------------------------------------------------------------------- io


func _write_text(path: String, text: String, written: Array[String]) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		problems.append("Could not write %s (error %d)" % [path, FileAccess.get_open_error()])
		return
	file.store_string(text)
	file.close()
	written.append(path)


func _file_size(path: String) -> int:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return 0
	var length := file.get_length()
	file.close()
	return length
