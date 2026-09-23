class_name ContentRepository
extends RefCounted

const OUTCOME_KEYS := ["success", "failure", "critical_success", "critical_failure", "outcome", "victory", "critical_victory"]

## Scene-role budget contract from NARRATIVE_REFINEMENT_PLAN section 3. An event
## without a scene_role is compact, and the compact band is deliberately wider
## than the old 60-90 / 30-50 rule, so every passage authored under that rule
## still validates without being touched.
const DEFAULT_SCENE_ROLE := "compact"
const SCENE_ROLE_BANDS := {
	"micro": {"body_min": 35, "body_max": 55, "outcome_min": 15, "outcome_max": 30},
	"compact": {"body_min": 60, "body_max": 100, "outcome_min": 30, "outcome_max": 65},
	"substantial": {"body_min": 110, "body_max": 180, "outcome_min": 60, "outcome_max": 110},
	"chapter": {"body_min": 180, "body_max": 280, "outcome_min": 100, "outcome_max": 180},
	"finale": {"body_min": 180, "body_max": 280, "outcome_min": 150, "outcome_max": 260},
}

static var _whitespace_pattern: RegEx = null

var regions: Dictionary = {}
var events: Dictionary = {}
var items: Dictionary = {}
var conditions: Dictionary = {}
var adversaries: Dictionary = {}
var combat_data: Dictionary = {}
var legacy_v2_checks: Dictionary = {}
var discovery_entries: Dictionary = {}
var polished_event_ids: Dictionary = {}
var living_road_enabled := false
var load_errors: PackedStringArray = []


func _init(enable_living_road: Variant = null) -> void:
	if enable_living_road == null:
		living_road_enabled = bool(ProjectSettings.get_setting("ashfall/release/living_road_enabled", false))
	else:
		living_road_enabled = bool(enable_living_road)
	reload()


func reload() -> void:
	load_errors.clear()
	polished_event_ids.clear()
	discovery_entries.clear()
	regions = _load_index("res://data/regions.json", "regions")
	events = _load_index("res://data/events.json", "events")
	_apply_narrative_overrides("res://data/narrative_overrides_v1.json")
	_apply_narrative_overrides("res://data/narrative_overrides_v11.json")
	_merge_index(events, "res://data/bunker41_events.json", "events")
	_merge_index(events, "res://data/rustsea_events.json", "events")
	if living_road_enabled:
		_merge_index(events, "res://data/living_road_events.json", "events")
		_apply_source_flag_patches("res://data/living_road_events.json")
		_merge_index(events, "res://data/betrayal_events.json", "events")
		for event_id: String in events:
			if bool(events[event_id].get("living_road_callback", false)):
				polished_event_ids[event_id] = true
	items = _load_index("res://data/items.json", "items")
	conditions = _load_index("res://data/conditions.json", "conditions")
	adversaries = _load_index("res://data/adversaries.json", "adversaries")
	combat_data = _load_map("res://data/combat_content.json", "combat")
	legacy_v2_checks = _load_map("res://data/legacy_v2_checks.json", "legacy_checks")
	_load_discovery_entries()


## A chapter is only real if the encounter that writes it exists in this build.
## Filtering here keeps disabled expansion chapters out of the Chronicle and out
## of its progress denominator, rather than advertising content v1 cannot reach.
func _load_discovery_entries() -> void:
	var available: Dictionary = _load_index("res://data/road_ledger.json", "entries")
	discovery_entries = {}
	for entry_id: String in available:
		var entry: Dictionary = available[entry_id]
		var event_id := str(entry.get("event_id", ""))
		if event_id == "" or events.has(event_id):
			discovery_entries[entry_id] = entry


func _apply_narrative_overrides(path: String) -> void:
	if not FileAccess.file_exists(path):
		load_errors.append("Missing narrative override file: %s" % path)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY or typeof(parsed.get("events", null)) != TYPE_ARRAY:
		load_errors.append("Invalid narrative override document: %s" % path)
		return
	for override: Variant in parsed["events"]:
		if typeof(override) != TYPE_DICTIONARY or not override.has("id"):
			load_errors.append("Narrative override without an event id in %s" % path)
			continue
		var event_id := str(override["id"])
		if not events.has(event_id):
			load_errors.append("Narrative override references missing event '%s'" % event_id)
			continue
		var event: Dictionary = events[event_id]
		if override.has("body"):
			event["body"] = str(override["body"])
		var event_choices: Array = event.get("choices", [])
		for choice_override: Variant in override.get("choices", []):
			if typeof(choice_override) != TYPE_DICTIONARY:
				load_errors.append("Narrative override '%s' contains an invalid choice override" % event_id)
				continue
			var choice_index := int(choice_override.get("index", -1))
			if choice_index < 0 or choice_index >= event_choices.size():
				load_errors.append("Narrative override '%s' references invalid choice %d" % [event_id, choice_index])
				continue
			var choice: Dictionary = event_choices[choice_index]
			for outcome_key: String in choice_override.get("outcomes", {}).keys():
				if not choice.has(outcome_key):
					load_errors.append("Narrative override '%s' choice %d references missing outcome '%s'" % [event_id, choice_index, outcome_key])
					continue
				choice[outcome_key]["text"] = str(choice_override["outcomes"][outcome_key])
		polished_event_ids[event_id] = true


func _apply_source_flag_patches(path: String) -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	for patch: Variant in parsed.get("source_flag_patches", []):
		if typeof(patch) != TYPE_DICTIONARY:
			continue
		var event_id := str(patch.get("event_id", ""))
		var choice_index := int(patch.get("choice_index", -1))
		var outcome_key := str(patch.get("outcome", ""))
		if not events.has(event_id) or choice_index < 0 or choice_index >= events[event_id].get("choices", []).size():
			load_errors.append("Living Road source patch references invalid choice '%s:%d'" % [event_id, choice_index])
			continue
		var choice: Dictionary = events[event_id]["choices"][choice_index]
		if not choice.has(outcome_key):
			load_errors.append("Living Road source patch references missing outcome '%s:%d:%s'" % [event_id, choice_index, outcome_key])
			continue
		var flags: Array = choice[outcome_key].get("add_flags", [])
		for flag: Variant in patch.get("add_flags", []):
			if str(flag) not in flags:
				flags.append(str(flag))
		choice[outcome_key]["add_flags"] = flags


func _load_map(path: String, collection_key: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		load_errors.append("Missing content file: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY or typeof(parsed.get(collection_key, null)) != TYPE_DICTIONARY:
		load_errors.append("Invalid content map: %s" % path)
		return {}
	return parsed[collection_key]


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


func _merge_index(index: Dictionary, path: String, collection_key: String) -> void:
	if not FileAccess.file_exists(path):
		load_errors.append("Missing content file: %s" % path)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY or typeof(parsed.get(collection_key, null)) != TYPE_ARRAY:
		load_errors.append("Invalid content document: %s" % path)
		return
	for definition: Variant in parsed[collection_key]:
		if typeof(definition) != TYPE_DICTIONARY or not definition.has("id"):
			load_errors.append("Definition without an id in %s" % path)
			continue
		var definition_id := str(definition["id"])
		if index.has(definition_id):
			load_errors.append("Duplicate id '%s' in %s" % [definition_id, path])
			continue
		index[definition_id] = definition


func validate_all() -> PackedStringArray:
	var errors := load_errors.duplicate()
	for region_id: String in regions:
		var region: Dictionary = regions[region_id]
		var supply_count := 0
		var combat_opportunity_count := 0
		var opening_safe_count := 0
		var opening_resource_count := 0
		var opening_equipment_count := 0
		var opening_hook_count := 0
		for event_id: Variant in region.get("event_pool", []):
			if not events.has(str(event_id)):
				errors.append("Region '%s' references missing event '%s'" % [region_id, event_id])
			else:
				var event_tags: Array = events[str(event_id)].get("tags", [])
				if "supply_opportunity" in event_tags:
					supply_count += 1
				if event_has_combat_choice(events[str(event_id)]):
					combat_opportunity_count += 1
				if "opening_safe" in event_tags:
					opening_safe_count += 1
				if "opening_resource" in event_tags:
					opening_resource_count += 1
				if "opening_equipment" in event_tags:
					opening_equipment_count += 1
				if "opening_hook" in event_tags:
					opening_hook_count += 1
		if supply_count < 1:
			errors.append("Region '%s' needs a supply opportunity" % region_id)
		if combat_opportunity_count < 1:
			errors.append("Region '%s' needs a combat opportunity" % region_id)
		if int(region.get("order", -1)) == 0 and (opening_safe_count < 2 or opening_resource_count < 1 or opening_equipment_count < 1):
			errors.append("Opening region needs at least two safe events plus resource and equipment teaching roles")
		if living_road_enabled and int(region.get("order", -1)) == 0 and opening_hook_count != 3:
			errors.append("Expanded opening region needs exactly three opening_hook events")
	var produced_flags := _produced_flags()
	for event_id: String in events:
		var event: Dictionary = events[event_id]
		if event.has("scene_role") and not SCENE_ROLE_BANDS.has(str(event["scene_role"])):
			errors.append("Event '%s' uses unknown scene role '%s'" % [event_id, event["scene_role"]])
		var role := scene_role(event)
		var band: Dictionary = scene_role_band(role)
		var introduction_words := word_count(str(event.get("body", "")))
		if introduction_words < int(band["body_min"]) or introduction_words > int(band["body_max"]):
			errors.append("Event '%s' introduction must contain %d-%d words for a %s scene (found %d)" % [event_id, int(band["body_min"]), int(band["body_max"]), role, introduction_words])
		_validate_passage_variants(event_id, "introduction", event, "body_variants", int(band["body_min"]), int(band["body_max"]), produced_flags, errors)
		var choices: Array = event.get("choices", [])
		if choices.size() < 2 or choices.size() > 4:
			errors.append("Event '%s' must have two to four choices" % event_id)
		if "supply_opportunity" in event.get("tags", []) and not _event_has_two_satiety_route(event):
			errors.append("Supply event '%s' needs a successful route worth at least two satiety" % event_id)
		if event.has("adversary_id") and not adversaries.has(str(event["adversary_id"])):
			errors.append("Event '%s' references missing adversary" % event_id)
		for choice: Variant in choices:
			_validate_choice(event_id, choice, role, produced_flags, errors)
	var treatable_conditions: Dictionary = {}
	for item_id: String in items:
		var item: Dictionary = items[item_id]
		if str(item.get("icon_id", "")).is_empty():
			errors.append("Item '%s' needs a stable icon ID" % item_id)
		var slot := str(item.get("equipment_slot", ""))
		if slot not in ["", "weapon", "armor", "accessory", "backpack"]:
			errors.append("Item '%s' uses invalid equipment slot '%s'" % [item_id, slot])
		if slot == "weapon":
			var combat: Dictionary = item.get("combat", {})
			if combat.is_empty() or str(combat.get("attack_stat", "")) not in GameEngine.STATS:
				errors.append("Weapon '%s' needs a valid combat profile" % item_id)
			elif int(combat.get("damage_min", 0)) <= 0 or int(combat.get("damage_max", 0)) < int(combat.get("damage_min", 0)):
				errors.append("Weapon '%s' has an invalid damage range" % item_id)
			if not combat.has("ammo_per_attack") or int(combat.get("ammo_per_attack", -1)) < 0:
				errors.append("Weapon '%s' needs a non-negative ammo_per_attack" % item_id)
			if str(item.get("ammo_type", "")) != "" and int(combat.get("ammo_per_attack", 0)) <= 0:
				errors.append("Ranged weapon '%s' must consume ammunition" % item_id)
			if item.has("affinity_min") and (int(item.get("affinity_min", 0)) < 2 or int(item.get("affinity_min", 0)) > 6):
				errors.append("Weapon '%s' affinity_min must be a base stat from 2 to 6" % item_id)
		var effects: Dictionary = item.get("effects", {})
		for condition_id: Variant in effects.get("remove_conditions", []):
			var removed_id := str(condition_id)
			if not conditions.has(removed_id):
				errors.append("Item '%s' removes missing condition '%s'" % [item_id, removed_id])
			else:
				treatable_conditions[removed_id] = true
		for condition_id: Variant in effects.get("add_conditions", []):
			if not conditions.has(str(condition_id)):
				errors.append("Item '%s' adds missing condition '%s'" % [item_id, condition_id])
	for condition_id: String in conditions:
		var condition: Dictionary = conditions[condition_id]
		var harmful := false
		for modifier: Variant in condition.get("modifiers", {}).values():
			if int(modifier) < 0:
				harmful = true
				break
		if harmful and int(condition.get("duration_checks", 0)) <= 0 and not treatable_conditions.has(condition_id):
			errors.append("Harmful permanent condition '%s' needs an item treatment" % condition_id)
	for adversary_id: String in adversaries:
		var adversary: Dictionary = adversaries[adversary_id]
		var combat: Dictionary = adversary.get("combat", {})
		if int(combat.get("max_health", 0)) <= 0 or int(combat.get("damage_min", 0)) <= 0 or int(combat.get("damage_max", 0)) < int(combat.get("damage_min", 0)):
			errors.append("Adversary '%s' has an invalid combat profile" % adversary_id)
		if int(adversary.get("xp_reward", 0)) <= 0 or int(adversary.get("xp_reward", 0)) > 100:
			errors.append("Adversary '%s' needs an XP reward from 1 to 100" % adversary_id)
		if str(adversary.get("portrait_id", "")).is_empty():
			errors.append("Adversary '%s' needs a portrait ID" % adversary_id)
		if str(combat.get("weapon_name", "")).is_empty() or str(combat.get("flee_difficulty", "")) not in D20Resolver.DIFFICULTY_SHIFTS:
			errors.append("Adversary '%s' needs a displayed weapon and flee difficulty" % adversary_id)
		var condition_id := str(combat.get("critical_condition", ""))
		if condition_id != "" and not conditions.has(condition_id):
			errors.append("Adversary '%s' references missing critical condition '%s'" % [adversary_id, condition_id])
	_validate_polished_prose(errors)
	_validate_narrative_combat(errors)
	_validate_item_acquisition(errors)
	if living_road_enabled:
		_validate_living_road(errors)
	return errors


func _validate_narrative_combat(errors: PackedStringArray) -> void:
	var moves: Dictionary = combat_data.get("moves", {})
	var families: Dictionary = combat_data.get("families", {})
	for move_id: String in ["strike", "heavy", "sweep", "brace", "charge", "recover"]:
		if not moves.has(move_id):
			errors.append("Missing combat move: " + move_id)
		elif moves[move_id].get("narration", []).size() < 3:
			errors.append("Move needs three authored narration variants: " + move_id)
	for enemy: Dictionary in adversaries.values():
		var definition: Dictionary = enemy.get("narrative_combat", {})
		if definition.get("sequence", []).is_empty() or typeof(definition.get("organic")) != TYPE_BOOL:
			errors.append("Invalid enemy sequence/biology: " + str(enemy["id"]))
		for move_id: Variant in definition.get("sequence", []):
			if not moves.has(str(move_id)) or str(definition.get("tells", {}).get(str(move_id), "")).is_empty():
				errors.append("Enemy move has no definition or tell: " + str(enemy["id"]))
	for item: Dictionary in items.values():
		if str(item.get("category", "")) == "weapon":
			if not families.has(str(item.get("signature", ""))) or str(item.get("opportunity_name", "")).is_empty() or typeof(item.get("two_handed")) != TYPE_BOOL:
				errors.append("Incomplete weapon signature: " + str(item["id"]))
		if bool(item.get("shield", false)) and (str(item.get("equipment_slot", "")) != "accessory" or not item.has("block_bonus") or not item.has("dodge_bonus")):
			errors.append("Invalid shield: " + str(item["id"]))
	for family: String in families:
		if families[family].get("hit", []).size() < 3:
			errors.append("Weapon narration needs three variants: " + family)
	for category: String in combat_data.get("narration", {}):
		if combat_data["narration"][category].size() < 3:
			errors.append("Combat narration needs three variants: " + category)


func _validate_polished_prose(errors: PackedStringArray) -> void:
	var sentence_pattern := RegEx.new()
	sentence_pattern.compile("[^.!?]+[.!?]+")
	var seen_sentences: Dictionary = {}
	var forbidden := [
		"the road collects its price",
		"the choice holds",
		"the memory follows you",
		"you gather yourself quickly",
		"the situation turns at exactly the wrong instant",
		"for a moment, the road loosens its grip",
		"the mistake announces itself",
		"the sudden quiet feels larger than the fight",
	]
	for event_id: String in polished_event_ids:
		if not events.has(event_id):
			continue
		# Sentences are pooled per event before they are compared. Only one variant
		# of a passage is ever shown, so four variants of one scene may open on the
		# same establishing sentence; a sentence shared with a different event is
		# the repetition this check has always caught. Prohibited filler has no
		# such exemption and is read in every variant.
		var event_sentences: Dictionary = {}
		for passage: String in _event_passages(events[event_id]):
			var lowered := passage.to_lower()
			for phrase: String in forbidden:
				if phrase in lowered:
					errors.append("Polished event '%s' contains prohibited filler: %s" % [event_id, phrase])
			for match_result: RegExMatch in sentence_pattern.search_all(passage):
				var normalized := " ".join(match_result.get_string().strip_edges().to_lower().split(" ", false))
				if normalized.split(" ", false).size() < 6:
					continue
				if not event_sentences.has(normalized):
					event_sentences[normalized] = match_result.get_string().strip_edges()
		for normalized: String in event_sentences:
			if seen_sentences.has(normalized):
				errors.append("Polished prose repeats a sentence in '%s' and '%s': %s" % [seen_sentences[normalized], event_id, event_sentences[normalized]])
			else:
				seen_sentences[normalized] = event_id


func _validate_living_road(errors: PackedStringArray) -> void:
	var produced_flags: Dictionary = {}
	var callback_count := 0
	for event: Dictionary in events.values():
		for choice: Dictionary in event.get("choices", []):
			for outcome_key: String in ["success", "failure", "critical_success", "critical_failure", "outcome", "victory", "critical_victory"]:
				if choice.has(outcome_key):
					for flag: Variant in choice[outcome_key].get("add_flags", []):
						produced_flags[str(flag)] = true
		if not bool(event.get("living_road_callback", false)):
			continue
		callback_count += 1
		var event_id := str(event.get("id", ""))
		var region_index := int(event.get("callback_region", -1))
		var consumed_flag := "lr_callback_region_%d" % region_index
		var eligibility: Dictionary = event.get("eligibility", {})
		if not bool(event.get("global", false)) or not bool(event.get("unique", false)):
			errors.append("Living Road event '%s' must be global and unique" % event_id)
		# A chapter opens in its own region and stays open for one more, so a
		# chapter that could not be scheduled on time still lands instead of taking
		# the rest of its thread with it (N04 focused scheduling).
		if region_index < 1 or int(eligibility.get("min_region_index", -1)) != region_index or int(eligibility.get("max_region_index", -1)) != region_index + 1:
			errors.append("Living Road event '%s' needs its callback region plus exactly one region of slack" % event_id)
		if consumed_flag not in eligibility.get("forbids_flags", []):
			errors.append("Living Road event '%s' does not enforce the regional callback limit" % event_id)
		for choice: Dictionary in event.get("choices", []):
			var has_exit := false
			for outcome_key: String in ["success", "failure", "critical_success", "critical_failure", "outcome"]:
				if not choice.has(outcome_key):
					continue
				has_exit = true
				var outcome: Dictionary = choice[outcome_key]
				if consumed_flag not in outcome.get("add_flags", []):
					errors.append("Living Road event '%s' outcome '%s' does not close its regional callback slot" % [event_id, outcome_key])
				var meaningful_flags: Array = outcome.get("add_flags", []).filter(func(flag: Variant) -> bool: return str(flag) != consumed_flag)
				if meaningful_flags.is_empty():
					errors.append("Living Road event '%s' outcome '%s' creates no lasting narrative consequence" % [event_id, outcome_key])
				if region_index < 4 and bool(outcome.get("lethal", false)):
					errors.append("Living Road event '%s' introduces a lethal callback before the Glass Wastes" % event_id)
			if not has_exit:
				errors.append("Living Road event '%s' contains a choice without an intentional exit" % event_id)
	if callback_count != 15:
		errors.append("Living Road requires exactly 15 callback events (found %d)" % callback_count)
	for event: Dictionary in events.values():
		if not bool(event.get("living_road_callback", false)):
			continue
		var eligibility: Dictionary = event.get("eligibility", {})
		for flag: Variant in eligibility.get("requires_flags", []):
			if not produced_flags.has(str(flag)):
				errors.append("Living Road event '%s' requires unreachable flag '%s'" % [event.get("id", ""), flag])
		for flag: Variant in eligibility.get("requires_any_flags", []):
			if not produced_flags.has(str(flag)):
				errors.append("Living Road event '%s' requires unreachable alternative flag '%s'" % [event.get("id", ""), flag])
	for entry_id: String in discovery_entries:
		var entry: Dictionary = discovery_entries[entry_id]
		var event_id := str(entry.get("event_id", ""))
		if event_id != "" and not events.has(event_id):
			errors.append("Road Ledger entry '%s' references missing event '%s'" % [entry_id, event_id])
		if event_id == "" and entry.get("requires_any_flags", []).is_empty():
			errors.append("Road Ledger entry '%s' needs an event or flag trigger" % entry_id)
		var variant_ids: Dictionary = {}
		for variant: Dictionary in entry.get("variants", []):
			var variant_id := str(variant.get("id", ""))
			if variant_id == "" or variant_ids.has(variant_id):
				errors.append("Road Ledger entry '%s' has a missing or duplicate variant ID '%s'" % [entry_id, variant_id])
			variant_ids[variant_id] = true
			for flag: Variant in variant.get("requires_flags", []):
				if not produced_flags.has(str(flag)):
					errors.append("Road Ledger entry '%s' variant '%s' requires unreachable flag '%s'" % [entry_id, variant_id, flag])
			for flag: Variant in variant.get("requires_any_flags", []):
				if not produced_flags.has(str(flag)):
					errors.append("Road Ledger entry '%s' variant '%s' requires unreachable alternative flag '%s'" % [entry_id, variant_id, flag])


func _validate_item_acquisition(errors: PackedStringArray) -> void:
	var obtainable: Dictionary = {}
	for item_id: String in GameEngine.STARTING_ITEM_IDS:
		obtainable[item_id] = true
	for event: Dictionary in events.values():
		for choice: Dictionary in event.get("choices", []):
			for outcome_key: String in ["success", "critical_success", "outcome", "victory", "critical_victory"]:
				if not choice.has(outcome_key):
					continue
				for item_id: Variant in choice[outcome_key].get("items", {}).keys():
					if int(choice[outcome_key]["items"][item_id]) > 0:
						obtainable[str(item_id)] = true
	for item_id: String in items:
		if not obtainable.has(item_id):
			errors.append("Item '%s' has no starting or authored acquisition route" % item_id)


func _validate_choice(event_id: String, choice: Variant, role: String, produced_flags: Dictionary, errors: PackedStringArray) -> void:
	if typeof(choice) != TYPE_DICTIONARY:
		errors.append("Event '%s' contains a non-object choice" % event_id)
		return
	if not choice.has("label"):
		errors.append("Event '%s' contains an unlabeled choice" % event_id)
	var check: Dictionary = choice.get("check", {})
	if check.has("dc"):
		errors.append("Event '%s' contains a forbidden numeric dc" % event_id)
	elif not check.is_empty() and str(check.get("difficulty", "")) not in D20Resolver.DIFFICULTY_SHIFTS:
		errors.append("Event '%s' contains an unknown check difficulty" % event_id)
	if choice.has("combat"):
		var adversary_id := str(choice.get("combat", {}).get("adversary_id", events[event_id].get("adversary_id", "")))
		if not adversaries.has(adversary_id):
			errors.append("Event '%s' combat choice references missing adversary '%s'" % [event_id, adversary_id])
		if not choice.has("victory"):
			errors.append("Event '%s' combat choice needs a victory outcome" % event_id)
	_validate_choice_requirements(event_id, choice.get("requires", {}), produced_flags, errors)
	for item_id: Variant in choice.get("costs", {}).get("items", {}).keys():
		if not items.has(str(item_id)):
			errors.append("Event '%s' costs missing item '%s'" % [event_id, item_id])
	for outcome_key: String in ["success", "failure", "critical_success", "critical_failure", "outcome"]:
		if choice.has(outcome_key):
			_validate_outcome(event_id, choice[outcome_key], role, produced_flags, errors)
	for outcome_key: String in ["victory", "critical_victory"]:
		if choice.has(outcome_key):
			_validate_outcome(event_id, choice[outcome_key], role, produced_flags, errors)


## Gating is a mechanical contract, so every part of it is checked: a flag the
## content never writes, an unknown stat, or a condition that does not exist all
## produce a choice the player can never legally take.
func _validate_choice_requirements(event_id: String, requirements: Variant, produced_flags: Dictionary, errors: PackedStringArray) -> void:
	if typeof(requirements) != TYPE_DICTIONARY:
		errors.append("Event '%s' contains a non-object choice requirement" % event_id)
		return
	for item_id: Variant in requirements.get("items", {}).keys():
		if not items.has(str(item_id)):
			errors.append("Event '%s' requires missing item '%s'" % [event_id, item_id])
	for requirement_key: String in ["flags", "any_flags", "forbids_flags"]:
		if not requirements.has(requirement_key):
			continue
		if typeof(requirements[requirement_key]) != TYPE_ARRAY:
			errors.append("Event '%s' choice requirement '%s' must be an array" % [event_id, requirement_key])
			continue
		for flag: Variant in requirements[requirement_key]:
			if not produced_flags.has(str(flag)):
				errors.append("Event '%s' choice requirement '%s' references flag '%s' that no outcome writes" % [event_id, requirement_key, flag])
	for stat: Variant in requirements.get("stats", {}).keys():
		if str(stat) not in GameEngine.STATS:
			errors.append("Event '%s' choice requires unknown stat '%s'" % [event_id, stat])
		elif int(requirements["stats"][stat]) <= 0:
			errors.append("Event '%s' choice gates on '%s' at a non-positive value" % [event_id, stat])
	for condition_id: Variant in requirements.get("forbids_conditions", []):
		if not conditions.has(str(condition_id)):
			errors.append("Event '%s' choice forbids missing condition '%s'" % [event_id, condition_id])
	if requirements.has("reason") and str(requirements["reason"]).strip_edges().is_empty():
		errors.append("Event '%s' choice supplies an empty lock reason" % event_id)
	if requirements.has("hidden_when_locked") and typeof(requirements["hidden_when_locked"]) != TYPE_BOOL:
		errors.append("Event '%s' choice hidden_when_locked must be a boolean" % event_id)


func _validate_outcome(event_id: String, outcome: Variant, role: String, produced_flags: Dictionary, errors: PackedStringArray) -> void:
	if typeof(outcome) != TYPE_DICTIONARY:
		errors.append("Event '%s' contains an invalid outcome" % event_id)
		return
	var band: Dictionary = scene_role_band(role)
	var outcome_words := word_count(str(outcome.get("text", "")))
	if outcome_words < int(band["outcome_min"]) or outcome_words > int(band["outcome_max"]):
		errors.append("Event '%s' outcome text must contain %d-%d words for a %s scene (found %d)" % [event_id, int(band["outcome_min"]), int(band["outcome_max"]), role, outcome_words])
	_validate_passage_variants(event_id, "outcome", outcome, "variants", int(band["outcome_min"]), int(band["outcome_max"]), produced_flags, errors, true)
	for item_id: Variant in outcome.get("items", {}).keys():
		if not items.has(str(item_id)):
			errors.append("Event '%s' outcome references missing item '%s'" % [event_id, item_id])
	for condition_id: Variant in outcome.get("add_conditions", []):
		if not conditions.has(str(condition_id)):
			errors.append("Event '%s' outcome references missing condition '%s'" % [event_id, condition_id])
	if outcome.has("next_event") and not events.has(str(outcome["next_event"])):
		errors.append("Event '%s' points to missing follow-up '%s'" % [event_id, outcome["next_event"]])
	if outcome.has("experience") and (typeof(outcome["experience"]) != TYPE_INT or int(outcome["experience"]) < 0 or int(outcome["experience"]) > 20):
		errors.append("Event '%s' outcome experience must be an integer from 0 to 20" % event_id)


## A conditional passage is prose with a condition attached, so it is held to the
## same budget as the passage it replaces. The plain body/text is the required
## fallback, every variant needs at least one flag to key on, and a variant that
## waits on a flag no outcome ever writes is dead text rather than a variant.
##
## An outcome variant may also carry a next_event and route the survivor
## somewhere the plain outcome does not. That follow-up is held to the same rule
## as the outcome's own: it must name an event this configuration loads. A
## variant that routes and says nothing new needs no text of its own, because
## the outcome's text stands in for it, so the word band applies only to a
## variant that actually replaces the passage.
func _validate_passage_variants(event_id: String, label: String, passage: Dictionary, variants_key: String, minimum_words: int, maximum_words: int, produced_flags: Dictionary, errors: PackedStringArray, routing_allowed: bool = false) -> void:
	if not passage.has(variants_key):
		return
	if typeof(passage[variants_key]) != TYPE_ARRAY:
		errors.append("Event '%s' %s '%s' must be an array" % [event_id, label, variants_key])
		return
	for variant: Variant in passage[variants_key]:
		if typeof(variant) != TYPE_DICTIONARY:
			errors.append("Event '%s' %s contains a non-object variant" % [event_id, label])
			continue
		var required_any: Variant = variant.get("requires_any_flags", [])
		if typeof(required_any) != TYPE_ARRAY or (required_any as Array).is_empty():
			errors.append("Event '%s' %s variant needs a non-empty requires_any_flags" % [event_id, label])
		else:
			for flag: Variant in required_any:
				if not produced_flags.has(str(flag)):
					errors.append("Event '%s' %s variant requires flag '%s' that no outcome writes" % [event_id, label, flag])
		var declares_route: bool = (variant as Dictionary).has("next_event")
		if declares_route and not routing_allowed:
			errors.append("Event '%s' %s variant cannot declare next_event" % [event_id, label])
		var routes: bool = routing_allowed and declares_route
		if routes and not events.has(str(variant["next_event"])):
			errors.append("Event '%s' %s variant points to missing follow-up '%s'" % [event_id, label, variant["next_event"]])
		if routes and not (variant as Dictionary).has("text"):
			continue
		var variant_words := word_count(str(variant.get("text", "")))
		if variant_words < minimum_words or variant_words > maximum_words:
			errors.append("Event '%s' %s variant must contain %d-%d words (found %d)" % [event_id, label, minimum_words, maximum_words, variant_words])


## Every authored passage of one event: the introduction, its conditional
## variants, and each outcome with the variants that stand in for it. A variant
## is prose and is read by every prose check that reads the passage it replaces.
func _event_passages(event: Dictionary) -> Array[String]:
	var passages: Array[String] = [str(event.get("body", ""))]
	for variant: Variant in event.get("body_variants", []):
		if typeof(variant) == TYPE_DICTIONARY:
			passages.append(str(variant.get("text", "")))
	for choice: Variant in event.get("choices", []):
		if typeof(choice) != TYPE_DICTIONARY:
			continue
		for outcome_key: String in OUTCOME_KEYS:
			if typeof(choice.get(outcome_key, null)) != TYPE_DICTIONARY:
				continue
			passages.append(str(choice[outcome_key].get("text", "")))
			for variant: Variant in choice[outcome_key].get("variants", []):
				if typeof(variant) == TYPE_DICTIONARY:
					passages.append(str(variant.get("text", "")))
	return passages


## Every flag the loaded configuration can ever hold. Requirements and passage
## variants are checked against this set, so a card cannot gate on a flag the
## build has no way of writing.
func _produced_flags() -> Dictionary:
	var produced: Dictionary = {}
	for event: Dictionary in events.values():
		for choice: Variant in event.get("choices", []):
			if typeof(choice) != TYPE_DICTIONARY:
				continue
			for outcome_key: String in OUTCOME_KEYS:
				if typeof(choice.get(outcome_key, null)) != TYPE_DICTIONARY:
					continue
				for flag: Variant in choice[outcome_key].get("add_flags", []):
					produced[str(flag)] = true
	return produced


static func scene_role(event: Dictionary) -> String:
	var role := str(event.get("scene_role", "")).strip_edges()
	return role if SCENE_ROLE_BANDS.has(role) else DEFAULT_SCENE_ROLE


static func scene_role_band(role: String) -> Dictionary:
	return SCENE_ROLE_BANDS.get(role, SCENE_ROLE_BANDS[DEFAULT_SCENE_ROLE])


func event_has_combat_choice(event: Dictionary) -> bool:
	for choice: Variant in event.get("choices", []):
		if typeof(choice) == TYPE_DICTIONARY and choice.has("combat"):
			return true
	return false


func _event_has_two_satiety_route(event: Dictionary) -> bool:
	for choice: Dictionary in event.get("choices", []):
		for outcome_key: String in ["success", "critical_success", "outcome", "victory", "critical_victory"]:
			if choice.has(outcome_key) and _outcome_satiety_value(choice[outcome_key]) >= 2:
				return true
	return false


func _outcome_satiety_value(outcome: Dictionary) -> int:
	var value := maxi(0, int(outcome.get("vitals", {}).get("satiety", 0)))
	for item_id: Variant in outcome.get("items", {}).keys():
		var quantity := maxi(0, int(outcome.get("items", {}).get(item_id, 0)))
		value += quantity * maxi(0, int(items.get(str(item_id), {}).get("effects", {}).get("satiety", 0)))
	return value


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


func get_adversary(adversary_id: String) -> Dictionary:
	return adversaries.get(adversary_id, {})


func get_legacy_v2_dc(event_id: String, choice_index: int) -> int:
	return int(legacy_v2_checks.get("%s:%d" % [event_id, choice_index], 0))


func get_discovery_entries() -> Dictionary:
	return discovery_entries


## Words are separated by any whitespace, not only by a single space. Splitting
## on " " alone merged the words on either side of a \n\n paragraph break
## into one, so an authored passage measured shorter than it reads.
static func word_count(value: String) -> int:
	if _whitespace_pattern == null:
		_whitespace_pattern = RegEx.create_from_string("\\s+")
	return _whitespace_pattern.sub(value, " ", true).split(" ", false).size()
