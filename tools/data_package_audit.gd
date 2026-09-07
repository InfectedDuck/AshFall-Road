extends SceneTree
## M10 integrated data-package audit.
##
## Read-only. It repairs nothing and regenerates no snapshot; every discrepancy
## is printed for the owning mini-plan to fix. Exit code 1 means at least one
## check failed.

const ContentRepositoryScript = preload("res://scripts/domain/content_repository.gd")
const GameEngineScript = preload("res://scripts/domain/game_engine.gd")
const StoryDiscoveryScript = preload("res://scripts/domain/story_discovery.gd")
const ItemIconScript = preload("res://scripts/ui/item_icon.gd")
const SaveServiceScript = preload("res://scripts/services/save_service.gd")

const OUTCOME_KEYS := ["success", "failure", "critical_success", "critical_failure", "outcome", "victory", "critical_victory"]
const OVERRIDE_FILES := ["res://data/narrative_overrides_v1.json", "res://data/narrative_overrides_v11.json"]
const MAX_CHOICES := 4

var findings: Array[String] = []
var checks := 0
var passed := 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var launch := ContentRepositoryScript.new(false)
	var expansion := ContentRepositoryScript.new(true)
	print("Ashfall Road integrated data-package audit")
	print("Launch events: %d | Expansion events: %d" % [launch.events.size(), expansion.events.size()])
	_check_polished_prose_loaded(launch)
	_check_repeated_sentences(launch)
	_check_item_routes(launch)
	_check_added_choices(launch)
	_check_original_choices(launch)
	_check_callbacks_disabled(launch)
	_check_discoveries_reachable(launch, expansion)
	_check_unknown_references(launch)
	_check_every_event_resolvable(launch)
	print("")
	print("Checks: %d | Passed: %d | Discrepancies: %d" % [checks, passed, findings.size()])
	for finding: String in findings:
		print("DISCREPANCY: %s" % finding)
	if findings.is_empty():
		print("The integrated data package matches the launch configuration.")
	quit(1 if not findings.is_empty() else 0)


func _record(name: String, problems: Array) -> void:
	checks += 1
	if problems.is_empty():
		passed += 1
		print("  PASS  %s" % name)
		return
	print("  FAIL  %s (%d)" % [name, problems.size()])
	for problem: Variant in problems:
		findings.append("%s: %s" % [name, str(problem)])


## 1. The prose the player reads is the reviewed prose, in the launch build.
func _check_polished_prose_loaded(launch) -> void:
	var problems: Array = []
	var covered: Dictionary = {}
	for path: String in OVERRIDE_FILES:
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if typeof(parsed) != TYPE_DICTIONARY:
			problems.append("%s could not be read" % path)
			continue
		for override: Dictionary in parsed.get("events", []):
			var event_id := str(override.get("id", ""))
			covered[event_id] = true
			var live: Dictionary = launch.get_event(event_id)
			if live.is_empty():
				problems.append("%s overrides an event missing from the launch build" % event_id)
				continue
			if override.has("body") and str(live.get("body", "")) != str(override["body"]):
				problems.append("%s introduction is not the reviewed text" % event_id)
			for choice_override: Dictionary in override.get("choices", []):
				var index := int(choice_override.get("index", -1))
				var choices: Array = live.get("choices", [])
				if index < 0 or index >= choices.size():
					problems.append("%s override targets missing choice %d" % [event_id, index])
					continue
				for outcome_key: String in choice_override.get("outcomes", {}):
					var expected := str(choice_override["outcomes"][outcome_key])
					if str(choices[index].get(outcome_key, {}).get("text", "")) != expected:
						problems.append("%s choice %d %s is not the reviewed text" % [event_id, index, outcome_key])
	if covered.size() != 76:
		problems.append("expected 76 polished baseline events, found %d" % covered.size())
	_record("Polished prose loaded in the launch configuration", problems)


## 2. No prohibited filler and no reused long sentence anywhere the player reads.
func _check_repeated_sentences(launch) -> void:
	var problems: Array = []
	for error: String in launch.validate_all():
		if "prohibited filler" in error or "repeats a sentence" in error:
			problems.append(error)
	var sentence_pattern := RegEx.new()
	sentence_pattern.compile("[^.!?]+[.!?]+")
	var seen: Dictionary = {}
	for event_id: String in launch.events:
		for passage: String in _passages(launch.events[event_id]):
			for match_result: RegExMatch in sentence_pattern.search_all(passage):
				var normalized := " ".join(match_result.get_string().strip_edges().to_lower().split(" ", false))
				if normalized.split(" ", false).size() < 6:
					continue
				if seen.has(normalized) and str(seen[normalized]) != event_id:
					problems.append("'%s' repeats between %s and %s" % [match_result.get_string().strip_edges(), seen[normalized], event_id])
				else:
					seen[normalized] = event_id
	_record("No prohibited or repeated narrative sentences", problems)


## 3. Every defined item can be started with or earned.
func _check_item_routes(launch) -> void:
	var problems: Array = []
	var obtainable: Dictionary = {}
	for item_id: String in GameEngineScript.STARTING_ITEM_IDS:
		obtainable[item_id] = true
	for event_id: String in launch.events:
		for choice: Dictionary in launch.events[event_id].get("choices", []):
			for outcome_key: String in ["success", "critical_success", "outcome", "victory", "critical_victory"]:
				for item_id: Variant in choice.get(outcome_key, {}).get("items", {}).keys():
					if int(choice[outcome_key]["items"][item_id]) > 0:
						obtainable[str(item_id)] = true
	for item_id: String in launch.items:
		if not obtainable.has(item_id):
			problems.append("%s has no starting or authored acquisition route" % item_id)
	if launch.items.size() != 50:
		problems.append("expected 50 defined items, found %d" % launch.items.size())
	_record("All fifty items have acquisition routes", problems)


## 4. Appended choices are legal content and no event grew past four.
func _check_added_choices(launch) -> void:
	var problems: Array = []
	for event_id: String in launch.events:
		var event: Dictionary = launch.events[event_id]
		var choices: Array = event.get("choices", [])
		if choices.size() > MAX_CHOICES:
			problems.append("%s offers %d choices" % [event_id, choices.size()])
		var labels: Dictionary = {}
		for index: int in range(choices.size()):
			var choice: Dictionary = choices[index]
			var label := str(choice.get("label", ""))
			if label == "":
				problems.append("%s choice %d has no label" % [event_id, index])
			elif labels.has(label):
				problems.append("%s repeats the choice label '%s'" % [event_id, label])
			labels[label] = true
			var check: Dictionary = choice.get("check", {})
			if check.has("dc"):
				problems.append("%s choice %d uses a numeric target" % [event_id, index])
			if not check.is_empty() and str(check.get("difficulty", "")) not in D20Resolver.DIFFICULTY_SHIFTS:
				problems.append("%s choice %d uses an unknown difficulty" % [event_id, index])
			var has_outcome := false
			for outcome_key: String in OUTCOME_KEYS:
				if choice.has(outcome_key):
					has_outcome = true
			if not has_outcome and not choice.has("combat"):
				problems.append("%s choice %d resolves to nothing" % [event_id, index])
	_record("Added choices are legal and capped at four per event", problems)


## 5. Overrides changed prose only, so live mechanics still equal the authored file.
func _check_original_choices(launch) -> void:
	var problems: Array = []
	var raw: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://data/events.json"))
	if typeof(raw) != TYPE_DICTIONARY:
		problems.append("data/events.json could not be read")
	else:
		for raw_event: Dictionary in raw.get("events", []):
			var event_id := str(raw_event.get("id", ""))
			var live: Dictionary = launch.get_event(event_id)
			if live.is_empty():
				problems.append("%s is authored but not loaded" % event_id)
				continue
			if _mechanical_signature(raw_event) != _mechanical_signature(live):
				problems.append("%s live mechanics differ from the authored file" % event_id)
			var raw_choices: Array = raw_event.get("choices", [])
			var live_choices: Array = live.get("choices", [])
			if raw_choices.size() != live_choices.size():
				problems.append("%s choice count changed after loading" % event_id)
				continue
			for index: int in range(raw_choices.size()):
				if str(raw_choices[index].get("label", "")) != str(live_choices[index].get("label", "")):
					problems.append("%s choice %d changed its label or index" % [event_id, index])
	_record("Original choice indices and unrelated mechanics unchanged", problems)


## 6. The expansion stays out of the launch package entirely.
func _check_callbacks_disabled(launch) -> void:
	var problems: Array = []
	if bool(ProjectSettings.get_setting("ashfall/release/living_road_enabled", false)):
		problems.append("ashfall/release/living_road_enabled is true in project settings")
	if launch.living_road_enabled:
		problems.append("the default content repository reports the expansion as enabled")
	for event_id: String in launch.events:
		if event_id.begins_with("lr_") or bool(launch.events[event_id].get("living_road_callback", false)):
			problems.append("callback event %s is loaded" % event_id)
	for entry_id: String in launch.get_discovery_entries():
		if str(launch.get_discovery_entries()[entry_id].get("event_id", "")).begins_with("lr_"):
			problems.append("callback chapter %s is listed" % entry_id)
	if launch.events.size() != 97:
		problems.append("expected the 97-event launch boundary, found %d" % launch.events.size())
	_record("Callback events remain disabled", problems)


## 7. Every listed chapter can actually be reached in the build that lists it.
func _check_discoveries_reachable(launch, expansion) -> void:
	var problems: Array = []
	var entries: Dictionary = launch.get_discovery_entries()
	if entries.size() != 10:
		problems.append("expected 10 reachable launch chapters, found %d" % entries.size())
	var produced: Dictionary = {}
	for event_id: String in launch.events:
		for choice: Dictionary in launch.events[event_id].get("choices", []):
			for outcome_key: String in OUTCOME_KEYS:
				for flag: Variant in choice.get(outcome_key, {}).get("add_flags", []):
					produced[str(flag)] = true
	for entry_id: String in entries:
		var entry: Dictionary = entries[entry_id]
		var event_id := str(entry.get("event_id", ""))
		if event_id != "" and not launch.events.has(event_id):
			problems.append("%s needs missing event %s" % [entry_id, event_id])
		for flag: Variant in entry.get("requires_flags", []):
			if not produced.has(str(flag)):
				problems.append("%s needs unreachable flag %s" % [entry_id, flag])
		var alternatives: Array = entry.get("requires_any_flags", [])
		if not alternatives.is_empty():
			var reachable := false
			for flag: Variant in alternatives:
				reachable = reachable or produced.has(str(flag))
			if not reachable:
				problems.append("%s needs one of several unreachable flags" % entry_id)
	if expansion.get_discovery_entries().size() != 25:
		problems.append("expansion should restore 25 chapters, found %d" % expansion.get_discovery_entries().size())
	_record("Existing-lore discoveries are reachable", problems)


## 8. Nothing points at an id the package does not define.
func _check_unknown_references(launch) -> void:
	var problems: Array = []
	var icon_ids: Dictionary = {}
	for item_id: String in launch.items:
		var icon_id := str(launch.items[item_id].get("icon_id", ""))
		if icon_id == "":
			problems.append("item %s has no icon id" % item_id)
		elif ItemIconScript.placeholder_symbol(icon_id) == "":
			problems.append("item %s uses unknown icon %s" % [item_id, icon_id])
		if icon_ids.has(icon_id):
			problems.append("icon %s is shared by more than one item" % icon_id)
		icon_ids[icon_id] = true
	for event_id: String in launch.events:
		var event: Dictionary = launch.events[event_id]
		for choice: Dictionary in event.get("choices", []):
			if choice.has("combat"):
				var adversary_id := str(choice["combat"].get("adversary_id", event.get("adversary_id", "")))
				if not launch.adversaries.has(adversary_id):
					problems.append("%s references unknown adversary %s" % [event_id, adversary_id])
			for collection: String in ["requires", "costs"]:
				for item_id: Variant in choice.get(collection, {}).get("items", {}).keys():
					if not launch.items.has(str(item_id)):
						problems.append("%s %s references unknown item %s" % [event_id, collection, item_id])
			for outcome_key: String in OUTCOME_KEYS:
				if not choice.has(outcome_key):
					continue
				var outcome: Dictionary = choice[outcome_key]
				for item_id: Variant in outcome.get("items", {}).keys():
					if not launch.items.has(str(item_id)):
						problems.append("%s outcome references unknown item %s" % [event_id, item_id])
				for condition_id: Variant in outcome.get("add_conditions", []) + outcome.get("remove_conditions", []):
					if not launch.conditions.has(str(condition_id)):
						problems.append("%s outcome references unknown condition %s" % [event_id, condition_id])
				if outcome.has("next_event") and not launch.events.has(str(outcome["next_event"])):
					problems.append("%s points at unknown follow-up %s" % [event_id, outcome["next_event"]])
	for adversary_id: String in launch.adversaries:
		var condition_id := str(launch.adversaries[adversary_id].get("narrative_combat", {}).get("critical_condition", ""))
		if condition_id != "" and not launch.conditions.has(condition_id):
			problems.append("adversary %s references unknown condition %s" % [adversary_id, condition_id])
	_record("No unknown icon, item, condition, or outcome reference", problems)


## 9. Every event must be resolvable by a survivor carrying nothing. A choice
## gated behind an item renders as a disabled button, so an event whose choices
## are all gated can strand a run with no legal action.
func _check_every_event_resolvable(launch) -> void:
	var problems: Array = []
	for event_id: String in launch.events:
		var choices: Array = launch.events[event_id].get("choices", [])
		if choices.is_empty():
			problems.append("%s offers no choice at all" % event_id)
			continue
		var ungated := false
		for choice: Dictionary in choices:
			if choice.get("requires", {}).is_empty():
				ungated = true
		if not ungated:
			var gates: Array = []
			for choice: Dictionary in choices:
				gates.append("%s needs %s" % [choice.get("label", "?"), ", ".join(PackedStringArray(choice.get("requires", {}).get("items", {}).keys()))])
			problems.append("%s gates every choice behind an item, so a survivor carrying none is stranded (%s)" % [event_id, "; ".join(gates)])
	_record("Every event is resolvable without a specific item", problems)


func _passages(event: Dictionary) -> Array:
	var passages: Array = [str(event.get("body", ""))]
	for choice: Dictionary in event.get("choices", []):
		for outcome_key: String in OUTCOME_KEYS:
			if choice.has(outcome_key):
				passages.append(str(choice[outcome_key].get("text", "")))
	return passages


func _mechanical_signature(event: Dictionary) -> Dictionary:
	var signature := event.duplicate(true)
	signature.erase("body")
	for choice: Dictionary in signature.get("choices", []):
		for outcome_key: String in OUTCOME_KEYS:
			if choice.has(outcome_key):
				choice[outcome_key].erase("text")
	return signature
