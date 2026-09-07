extends SceneTree
## N00 independent mechanical baseline for NARRATIVE_REFINEMENT_PLAN.
##
## The narrative refinement phases edit prose in the data files and in the two
## narrative override documents. A reviewer reading only the diff cannot tell a
## prose-only edit from a mechanical one when a data file and its override move
## together, because each explains the other. This snapshot is recorded before
## that work starts and is deliberately independent of the loader's own
## guarantees: it hashes the raw bytes of every data file AND the loaded
## mechanical state of both shipping configurations, so a later phase can prove
## a mechanical change was intentional rather than incidental.
##
## Write mode:
##   Godot --headless --path . --script res://tools/mechanical_snapshot.gd
## Diff mode (exit 1 when anything differs from the stored snapshot):
##   Godot --headless --path . --script res://tools/mechanical_snapshot.gd -- --diff

const ContentRepositoryScript = preload("res://scripts/domain/content_repository.gd")

const SNAPSHOT_PATH := "res://builds/mechanical_snapshot_narrative_baseline.json"
const CAPTURED_FOR := "NARRATIVE_REFINEMENT_PLAN N00"
const DATA_DIR := "res://data"
const OUTCOME_KEYS := ["success", "failure", "critical_success", "critical_failure", "outcome", "victory", "critical_victory"]
const CONFIGURATIONS := ["launch", "expanded"]
const HASH_SECTIONS := ["signatures", "items", "conditions", "adversaries", "discoveries"]
const COUNT_KEYS := ["choices", "outcomes", "checked_choices", "combat_choices", "lethal_outcomes", "flags_produced"]


func _init() -> void:
	if Engine.get_main_loop() == null:
		call_deferred("_run")


func _run() -> void:
	if "--diff" in OS.get_cmdline_user_args():
		_run_diff()
		return
	_run_write()


# ------------------------------------------------------------------ write mode

func _run_write() -> void:
	var snapshot := _build_snapshot()
	var text := _canonical_json(snapshot, "  ") + "\n"
	var file := FileAccess.open(SNAPSHOT_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not open %s for writing (error %d)" % [SNAPSHOT_PATH, FileAccess.get_open_error()])
		quit(1)
		return
	file.store_string(text)
	file.close()
	print("Ashfall Road mechanical baseline snapshot")
	print("captured_for: %s" % CAPTURED_FOR)
	print("data files hashed: %d" % (snapshot["data_files"] as Dictionary).size())
	for configuration: String in CONFIGURATIONS:
		_print_configuration(configuration, snapshot[configuration])
	print("Wrote %s (%d bytes)" % [SNAPSHOT_PATH, text.to_utf8_buffer().size()])
	quit(0)


func _print_configuration(configuration: String, capture: Dictionary) -> void:
	print("%s: %d events, %d items, %d conditions, %d adversaries, %d discoveries" % [
		configuration,
		int(capture["event_count"]),
		(capture["items"] as Dictionary).size(),
		(capture["conditions"] as Dictionary).size(),
		(capture["adversaries"] as Dictionary).size(),
		(capture["discoveries"] as Dictionary).size(),
	])
	var counts: Dictionary = capture["counts"]
	var parts: PackedStringArray = []
	for count_key: String in COUNT_KEYS:
		parts.append("%s=%d" % [count_key, int(counts[count_key])])
	print("%s counts: %s" % [configuration, ", ".join(parts)])


# ------------------------------------------------------------------- diff mode

func _run_diff() -> void:
	if not FileAccess.file_exists(SNAPSHOT_PATH):
		print("No stored snapshot at %s. Run the tool without --diff first." % SNAPSHOT_PATH)
		quit(1)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SNAPSHOT_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		print("Stored snapshot is not a readable JSON object: %s" % SNAPSHOT_PATH)
		quit(1)
		return
	var stored: Dictionary = parsed
	var current := _build_snapshot()
	var differences: Array[String] = []
	if str(stored.get("captured_for", "")) != CAPTURED_FOR:
		differences.append("captured_for changed: %s -> %s" % [str(stored.get("captured_for", "")), CAPTURED_FOR])
	_diff_data_files(stored.get("data_files", {}), current["data_files"], differences)
	for configuration: String in CONFIGURATIONS:
		_diff_configuration(configuration, stored.get(configuration, {}), current[configuration], differences)
	print("Ashfall Road mechanical baseline diff")
	print("stored snapshot: %s" % SNAPSHOT_PATH)
	if differences.is_empty():
		print("no differences: %d data files, launch %d events, expanded %d events" % [
			(current["data_files"] as Dictionary).size(),
			int((current["launch"] as Dictionary)["event_count"]),
			int((current["expanded"] as Dictionary)["event_count"]),
		])
		quit(0)
		return
	for difference: String in differences:
		print("DIFFERENCE: %s" % difference)
	print("%d differences" % differences.size())
	quit(1)


func _diff_data_files(stored: Variant, current: Dictionary, differences: Array[String]) -> void:
	var previous: Dictionary = stored if typeof(stored) == TYPE_DICTIONARY else {}
	for path: String in _sorted_keys(current):
		if not previous.has(path):
			differences.append("data_files added: %s" % path)
			continue
		var was: Dictionary = previous[path] if typeof(previous[path]) == TYPE_DICTIONARY else {}
		var now: Dictionary = current[path]
		if str(was.get("sha256", "")) != str(now["sha256"]):
			differences.append("data_files changed: %s (%s -> %s, %d -> %d bytes)" % [
				path,
				_short(str(was.get("sha256", ""))),
				_short(str(now["sha256"])),
				int(was.get("bytes", -1)),
				int(now["bytes"]),
			])
		elif int(was.get("bytes", -1)) != int(now["bytes"]):
			differences.append("data_files size changed: %s (%d -> %d bytes)" % [path, int(was.get("bytes", -1)), int(now["bytes"])])
	for path: String in _sorted_keys(previous):
		if not current.has(path):
			differences.append("data_files removed: %s" % path)


func _diff_configuration(configuration: String, stored: Variant, current: Dictionary, differences: Array[String]) -> void:
	var previous: Dictionary = stored if typeof(stored) == TYPE_DICTIONARY else {}
	if int(previous.get("event_count", -1)) != int(current["event_count"]):
		differences.append("%s event_count changed: %d -> %d" % [configuration, int(previous.get("event_count", -1)), int(current["event_count"])])
	for section: String in HASH_SECTIONS:
		_diff_hashes("%s/%s" % [configuration, section], previous.get(section, {}), current[section], differences)
	_diff_choice_labels(configuration, previous.get("choice_labels", {}), current["choice_labels"], differences)
	var stored_counts: Variant = previous.get("counts", {})
	var counts: Dictionary = stored_counts if typeof(stored_counts) == TYPE_DICTIONARY else {}
	var current_counts: Dictionary = current["counts"]
	for count_key: String in COUNT_KEYS:
		if int(counts.get(count_key, -1)) != int(current_counts[count_key]):
			differences.append("%s counts.%s changed: %d -> %d" % [configuration, count_key, int(counts.get(count_key, -1)), int(current_counts[count_key])])


func _diff_hashes(label: String, stored: Variant, current: Dictionary, differences: Array[String]) -> void:
	var previous: Dictionary = stored if typeof(stored) == TYPE_DICTIONARY else {}
	for entry_id: String in _sorted_keys(current):
		if not previous.has(entry_id):
			differences.append("%s added: %s" % [label, entry_id])
		elif str(previous[entry_id]) != str(current[entry_id]):
			differences.append("%s changed: %s (%s -> %s)" % [label, entry_id, _short(str(previous[entry_id])), _short(str(current[entry_id]))])
	for entry_id: String in _sorted_keys(previous):
		if not current.has(entry_id):
			differences.append("%s removed: %s" % [label, entry_id])


## Choice labels are player-facing prose, but their order is a mechanical fact:
## the override documents and every saved run address a choice by its index.
func _diff_choice_labels(configuration: String, stored: Variant, current: Dictionary, differences: Array[String]) -> void:
	var previous: Dictionary = stored if typeof(stored) == TYPE_DICTIONARY else {}
	for event_id: String in _sorted_keys(current):
		if not previous.has(event_id):
			continue
		var was: Array = previous[event_id] if typeof(previous[event_id]) == TYPE_ARRAY else []
		var now: Array = current[event_id]
		if was.size() != now.size():
			differences.append("%s/choice_labels changed: %s (%d -> %d labels)" % [configuration, event_id, was.size(), now.size()])
			continue
		for index: int in range(now.size()):
			if str(was[index]) != str(now[index]):
				differences.append("%s/choice_labels changed: %s choice %d (%s -> %s)" % [configuration, event_id, index, str(was[index]), str(now[index])])


# --------------------------------------------------------------------- capture

func _build_snapshot() -> Dictionary:
	return {
		"captured_for": CAPTURED_FOR,
		"data_files": _hash_data_files(),
		"launch": _capture(ContentRepositoryScript.new(false)),
		"expanded": _capture(ContentRepositoryScript.new(true)),
	}


func _hash_data_files() -> Dictionary:
	var hashed: Dictionary = {}
	var directory := DirAccess.open(DATA_DIR)
	if directory == null:
		push_error("Could not open %s (error %d)" % [DATA_DIR, DirAccess.get_open_error()])
		return hashed
	var names: PackedStringArray = []
	for name: String in directory.get_files():
		if name.get_extension().to_lower() == "json":
			names.append(name)
	names.sort()
	for name: String in names:
		var bytes := FileAccess.get_file_as_bytes("%s/%s" % [DATA_DIR, name])
		hashed["data/%s" % name] = {"sha256": _hash_bytes(bytes), "bytes": bytes.size()}
	return hashed


func _capture(content) -> Dictionary:
	var signatures: Dictionary = {}
	var choice_labels: Dictionary = {}
	var produced_flags: Dictionary = {}
	var counts: Dictionary = {}
	for count_key: String in COUNT_KEYS:
		counts[count_key] = 0
	for event_id: String in content.events:
		var event: Dictionary = content.events[event_id]
		signatures[event_id] = _hash_value(_mechanical_signature(event))
		var labels: Array = []
		for choice: Dictionary in event.get("choices", []):
			labels.append(str(choice.get("label", "")))
			counts["choices"] += 1
			if not choice.get("check", {}).is_empty():
				counts["checked_choices"] += 1
			if choice.has("combat"):
				counts["combat_choices"] += 1
			for outcome_key: String in OUTCOME_KEYS:
				if not choice.has(outcome_key):
					continue
				var outcome: Dictionary = choice[outcome_key]
				counts["outcomes"] += 1
				if bool(outcome.get("lethal", false)):
					counts["lethal_outcomes"] += 1
				for flag: Variant in outcome.get("add_flags", []):
					produced_flags[str(flag)] = true
		choice_labels[event_id] = labels
	counts["flags_produced"] = produced_flags.size()
	return {
		"event_count": content.events.size(),
		"signatures": signatures,
		"choice_labels": choice_labels,
		"items": _hash_index(content.items),
		"conditions": _hash_index(content.conditions),
		"adversaries": _hash_index(content.adversaries),
		"discoveries": _hash_index(content.get_discovery_entries()),
		"counts": counts,
	}


## The same definition the test runner uses: the event with every authored
## passage removed, so a prose edit never moves a mechanical hash.
func _mechanical_signature(event: Dictionary) -> Dictionary:
	var signature := event.duplicate(true)
	signature.erase("body")
	for choice: Dictionary in signature.get("choices", []):
		for outcome_key: String in OUTCOME_KEYS:
			if choice.has(outcome_key):
				choice[outcome_key].erase("text")
	return signature


func _hash_index(index: Dictionary) -> Dictionary:
	var hashed: Dictionary = {}
	for entry_id: String in index:
		hashed[entry_id] = _hash_value(index[entry_id])
	return hashed


# -------------------------------------------------------------- canonical JSON

## Godot preserves dictionary insertion order, so two loads holding identical
## content can still stringify differently. Every key is sorted recursively
## before hashing, so a hash moves only when a value actually moves.
func _canonical(value: Variant) -> Variant:
	match typeof(value):
		TYPE_DICTIONARY:
			var source: Dictionary = value
			var sorted: Dictionary = {}
			for key: String in _sorted_keys(source):
				sorted[key] = _canonical(source[key])
			return sorted
		TYPE_ARRAY:
			var items: Array = []
			for item: Variant in value:
				items.append(_canonical(item))
			return items
	return value


func _canonical_json(value: Variant, indent: String = "") -> String:
	return JSON.stringify(_canonical(value), indent, true, true)


func _sorted_keys(source: Dictionary) -> PackedStringArray:
	var keys: PackedStringArray = []
	for key: Variant in source.keys():
		keys.append(str(key))
	keys.sort()
	return keys


func _hash_value(value: Variant) -> String:
	return _hash_bytes(_canonical_json(value).to_utf8_buffer())


func _hash_bytes(bytes: PackedByteArray) -> String:
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	if not bytes.is_empty():
		context.update(bytes)
	return context.finish().hex_encode()


func _short(digest: String) -> String:
	return digest.substr(0, 12) if digest.length() > 12 else digest
