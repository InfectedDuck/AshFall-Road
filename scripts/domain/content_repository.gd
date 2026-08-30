class_name ContentRepository
extends RefCounted

var regions: Dictionary = {}
var events: Dictionary = {}
var items: Dictionary = {}
var conditions: Dictionary = {}
var adversaries: Dictionary = {}
var load_errors: PackedStringArray = []


func _init() -> void:
	reload()


func reload() -> void:
	load_errors.clear()
	regions = _load_index("res://data/regions.json", "regions")
	events = _load_index("res://data/events.json", "events")
	items = _load_index("res://data/items.json", "items")
	conditions = _load_index("res://data/conditions.json", "conditions")
	adversaries = _load_index("res://data/adversaries.json", "adversaries")


func _load_index(path: String, collection_key: String) -> Dictionary:
	var index: Dictionary = {}
	if not FileAccess.file_exists(path):
		load_errors.append("Missing content file: %s" % path)
		return index
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has(collection_key):
		load_errors.append("Invalid content document: %s" % path)
		return index
	if typeof(parsed[collection_key]) != TYPE_ARRAY:
		load_errors.append("Content collection '%s' is not an array" % collection_key)
		return index
	for definition: Variant in parsed[collection_key]:
		if typeof(definition) != TYPE_DICTIONARY or not definition.has("id"):
			load_errors.append("Definition without an id in %s" % path)
			continue
		var definition_id := str(definition["id"])
		if index.has(definition_id):
			load_errors.append("Duplicate id '%s' in %s" % [definition_id, path])
			continue
		index[definition_id] = definition
	return index


func validate_all() -> PackedStringArray:
	var errors := load_errors.duplicate()
	for region_id: String in regions:
		var region: Dictionary = regions[region_id]
		for event_id: Variant in region.get("event_pool", []):
			if not events.has(str(event_id)):
				errors.append("Region '%s' references missing event '%s'" % [region_id, event_id])
	for event_id: String in events:
		var event: Dictionary = events[event_id]
		var choices: Array = event.get("choices", [])
		if choices.size() < 2 or choices.size() > 4:
			errors.append("Event '%s' must have two to four choices" % event_id)
		if event.has("adversary_id") and not adversaries.has(str(event["adversary_id"])):
			errors.append("Event '%s' references missing adversary" % event_id)
		for choice: Variant in choices:
			_validate_choice(event_id, choice, errors)
	for item_id: String in items:
		var item: Dictionary = items[item_id]
		var slot := str(item.get("equipment_slot", ""))
		if slot not in ["", "weapon", "armor", "accessory", "backpack"]:
			errors.append("Item '%s' uses invalid equipment slot '%s'" % [item_id, slot])
	return errors


func _validate_choice(event_id: String, choice: Variant, errors: PackedStringArray) -> void:
	if typeof(choice) != TYPE_DICTIONARY:
		errors.append("Event '%s' contains a non-object choice" % event_id)
		return
	if not choice.has("label"):
		errors.append("Event '%s' contains an unlabeled choice" % event_id)
	for item_id: Variant in choice.get("requires", {}).get("items", {}).keys():
		if not items.has(str(item_id)):
			errors.append("Event '%s' requires missing item '%s'" % [event_id, item_id])
	for item_id: Variant in choice.get("costs", {}).get("items", {}).keys():
		if not items.has(str(item_id)):
			errors.append("Event '%s' costs missing item '%s'" % [event_id, item_id])
	for outcome_key: String in ["success", "failure", "critical_success", "critical_failure", "outcome"]:
		if choice.has(outcome_key):
			_validate_outcome(event_id, choice[outcome_key], errors)


func _validate_outcome(event_id: String, outcome: Variant, errors: PackedStringArray) -> void:
	if typeof(outcome) != TYPE_DICTIONARY:
		errors.append("Event '%s' contains an invalid outcome" % event_id)
		return
	for item_id: Variant in outcome.get("items", {}).keys():
		if not items.has(str(item_id)):
			errors.append("Event '%s' outcome references missing item '%s'" % [event_id, item_id])
	for condition_id: Variant in outcome.get("add_conditions", []):
		if not conditions.has(str(condition_id)):
			errors.append("Event '%s' outcome references missing condition '%s'" % [event_id, condition_id])
	if outcome.has("next_event") and not events.has(str(outcome["next_event"])):
		errors.append("Event '%s' points to missing follow-up '%s'" % [event_id, outcome["next_event"]])


func ordered_regions() -> Array:
	var result: Array = regions.values()
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("order", 0)) < int(b.get("order", 0)))
	return result


func get_event(event_id: String) -> Dictionary:
	return events.get(event_id, {})


func get_item(item_id: String) -> Dictionary:
	return items.get(item_id, {})


func get_condition(condition_id: String) -> Dictionary:
	return conditions.get(condition_id, {})

