extends SceneTree
## Content dossier generator.
##
## Loads both shipping configurations of the content package (launch, and the
## expanded build with the Living Road pack) and writes one machine-readable
## dossier plus one readable dossier per configuration. Read-only: it edits no
## content, it reports what the loaded package actually contains.

const ContentRepositoryScript = preload("res://scripts/domain/content_repository.gd")

const OUTCOME_KEYS := ["success", "failure", "critical_success", "critical_failure", "outcome", "victory", "critical_victory"]
const SOURCE_FILES := [
	"res://data/events.json",
	"res://data/bunker41_events.json",
	"res://data/rustsea_events.json",
	"res://data/living_road_events.json",
]
const LIVING_ROAD_FILE := "res://data/living_road_events.json"
const FINAL_EVENT_ID := "final_gate_1"
const ENGINE_FALLBACK_ID := "fallback_dust"
const JSON_PATH := "res://builds/content_dossier.json"
const MARKDOWN_PATHS := {
	"launch": "res://builds/content_dossier_launch.md",
	"expanded": "res://builds/content_dossier_expanded.md",
}
const BODY_PREVIEW_WORDS := 12

var problems: Array[String] = []


func _init() -> void:
	if Engine.get_main_loop() == null:
		call_deferred("_run")


func _run() -> void:
	var source_map := _build_source_map()
	var launch := _analyse(ContentRepositoryScript.new(false), "launch", source_map)
	var expanded := _analyse(ContentRepositoryScript.new(true), "expanded", source_map)
	var dossier := {"launch": launch, "expanded": expanded}
	var written: Array[String] = []
	_write_text(JSON_PATH, JSON.stringify(dossier, "\t", false), written)
	_write_text(MARKDOWN_PATHS["launch"], _render_markdown(launch), written)
	_write_text(MARKDOWN_PATHS["expanded"], _render_markdown(expanded), written)
	print("Ashfall Road content dossier")
	_print_summary(launch)
	_print_summary(expanded)
	for path: String in written:
		print("wrote %s (%d bytes)" % [path, _file_size(path)])
	for problem: String in problems:
		print("PROBLEM: %s" % problem)
	quit(1 if not problems.is_empty() else 0)


func _print_summary(config: Dictionary) -> void:
	var totals: Dictionary = config["totals"]
	print("%s: events=%d choices=%d outcomes=%d discoveries=%d adversaries=%d reachable=%d unreachable=%d" % [
		config["configuration"],
		totals["events"],
		totals["choices"],
		totals["outcomes"],
		totals["discoveries"],
		totals["adversaries"],
		totals["reachable"],
		totals["unreachable"],
	])


# ---------------------------------------------------------------- source files


## Which data file defines each event id. Narrative override documents only
## rewrite prose on ids defined elsewhere, so they never appear as a source.
func _build_source_map() -> Dictionary:
	var source_map: Dictionary = {}
	for path: String in SOURCE_FILES:
		if not FileAccess.file_exists(path):
			problems.append("Missing content file: %s" % path)
			continue
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if typeof(parsed) != TYPE_DICTIONARY or typeof(parsed.get("events", null)) != TYPE_ARRAY:
			problems.append("Unreadable event document: %s" % path)
			continue
		for definition: Variant in parsed["events"]:
			if typeof(definition) != TYPE_DICTIONARY or not definition.has("id"):
				continue
			var event_id := str(definition["id"])
			if source_map.has(event_id):
				continue
			source_map[event_id] = path.replace("res://", "")
	return source_map


func _source_index(source_file: String) -> int:
	var index := SOURCE_FILES.find("res://" + source_file)
	return index if index >= 0 else SOURCE_FILES.size()


# -------------------------------------------------------------------- analysis


func _analyse(repository, configuration: String, source_map: Dictionary) -> Dictionary:
	var ordered_regions: Array = repository.ordered_regions()
	var last_region_index := ordered_regions.size() - 1
	var region_order: Array[String] = []
	var pool_map: Dictionary = {}
	for region: Dictionary in ordered_regions:
		var region_id := str(region.get("id", ""))
		region_order.append(region_id)
		for raw_id: Variant in region.get("event_pool", []):
			var event_id := str(raw_id)
			var listed: Array = pool_map.get(event_id, [])
			if region_id not in listed:
				listed.append(region_id)
			pool_map[event_id] = listed
	var event_ids: Array = repository.events.keys()
	event_ids.sort_custom(func(a: String, b: String) -> bool:
		var left := "%02d|%s" % [_source_index(str(source_map.get(a, ""))), a]
		var right := "%02d|%s" % [_source_index(str(source_map.get(b, ""))), b]
		return left < right)

	var produced: Dictionary = {}
	var consumed: Dictionary = {}
	var adversary_usage: Dictionary = {}
	var adversary_event_refs: Dictionary = {}
	var next_event_sources: Dictionary = {}
	var events: Array = []
	var choice_count := 0
	var outcome_count := 0

	for event_id: String in event_ids:
		var event: Dictionary = repository.events[event_id]
		var eligibility: Dictionary = event.get("eligibility", {})
		if str(event.get("adversary_id", "")) != "":
			_append_reference(adversary_event_refs, str(event["adversary_id"]), event_id)
		for eligibility_key: String in ["requires_flags", "requires_any_flags", "forbids_flags"]:
			for flag: Variant in eligibility.get(eligibility_key, []):
				_append_reference(consumed, str(flag), "%s eligibility:%s" % [event_id, eligibility_key])
		var choices: Array = []
		var raw_choices: Array = event.get("choices", [])
		for choice_index: int in range(raw_choices.size()):
			var choice: Dictionary = raw_choices[choice_index]
			choice_count += 1
			for requirement_key: String in ["flags", "any_flags"]:
				for flag: Variant in choice.get("requires", {}).get(requirement_key, []):
					_append_reference(consumed, str(flag), "%s:%d requires:%s" % [event_id, choice_index, requirement_key])
			if choice.has("combat"):
				var adversary_id := str(choice.get("combat", {}).get("adversary_id", event.get("adversary_id", "")))
				_append_reference(adversary_usage, adversary_id, "%s:%d" % [event_id, choice_index])
			var outcomes: Dictionary = {}
			for outcome_key: String in OUTCOME_KEYS:
				if not choice.has(outcome_key):
					continue
				outcome_count += 1
				var outcome: Dictionary = choice[outcome_key]
				for flag: Variant in outcome.get("add_flags", []):
					_append_reference(produced, str(flag), "%s:%d:%s" % [event_id, choice_index, outcome_key])
				var next_event := str(outcome.get("next_event", ""))
				if next_event != "":
					_append_reference(next_event_sources, next_event, "%s:%d:%s" % [event_id, choice_index, outcome_key])
				outcomes[outcome_key] = {
					"words": _word_count(str(outcome.get("text", ""))),
					"items": _copy_dictionary(outcome.get("items", {})),
					"pressures": _copy_dictionary(outcome.get("pressures", {})),
					"add_conditions": _string_array(outcome.get("add_conditions", [])),
					"remove_conditions": _string_array(outcome.get("remove_conditions", [])),
					"add_flags": _string_array(outcome.get("add_flags", [])),
					"next_event": next_event,
					"lethal": bool(outcome.get("lethal", false)),
					"damage_type": str(outcome.get("damage_type", "")),
					"experience": _normalize(outcome.get("experience", null)),
					"victory": bool(outcome.get("victory", false)),
				}
			choices.append({
				"index": choice_index,
				"label": str(choice.get("label", "")),
				"approach": str(choice.get("approach", "")),
				"check": _copy_dictionary(choice.get("check", {})),
				"modifier": _normalize(choice.get("modifier", null)),
				"combat": _copy_dictionary(choice.get("combat", {})),
				"requires": _copy_dictionary(choice.get("requires", {})),
				"costs": _copy_dictionary(choice.get("costs", {})),
				"outcomes": outcomes,
			})
		events.append({
			"id": event_id,
			"title": str(event.get("title", "")),
			"source_file": str(source_map.get(event_id, "unknown")),
			"region_pools": _string_array(pool_map.get(event_id, [])),
			"global": bool(event.get("global", false)),
			"unique": bool(event.get("unique", false)),
			"weight": int(event.get("weight", 1)),
			"tags": _string_array(event.get("tags", [])),
			"adversary_id": str(event.get("adversary_id", "")),
			"eligibility": _copy_dictionary(eligibility),
			"living_road_callback": bool(event.get("living_road_callback", false)),
			"callback_region": _normalize(event.get("callback_region", null)),
			"callback_thread": str(event.get("callback_thread", "")),
			"narrative_priority": int(event.get("narrative_priority", 0)),
			"body_words": _word_count(str(event.get("body", ""))),
			"body_preview": _preview(str(event.get("body", ""))),
			"choices": choices,
		})

	var discoveries := _collect_discoveries(repository, consumed)
	var adversaries := _collect_adversaries(repository, adversary_usage, adversary_event_refs)
	var patches := _collect_source_patches(repository, configuration)
	var reachability := _compute_reachability(repository, pool_map, next_event_sources, last_region_index)

	return {
		"configuration": configuration,
		"living_road_enabled": bool(repository.living_road_enabled),
		"totals": {
			"events": events.size(),
			"choices": choice_count,
			"outcomes": outcome_count,
			"discoveries": discoveries.size(),
			"adversaries": adversaries.size(),
			"reachable": reachability["reachable"].size(),
			"unreachable": reachability["unreachable"].size(),
			"source_patches_applied": patches.size(),
			"flags_produced": produced.size(),
			"flags_consumed": consumed.size(),
		},
		"region_order": region_order,
		"load_errors": _string_array(Array(repository.load_errors)),
		"events": events,
		"flags": {
			"produced": _sorted_index(produced),
			"consumed": _sorted_index(consumed),
		},
		"source_patches_applied": patches,
		"discoveries": discoveries,
		"adversaries": adversaries,
		"reachability": reachability,
	}


func _collect_discoveries(repository, consumed: Dictionary) -> Array:
	var entries: Dictionary = repository.get_discovery_entries()
	var entry_ids: Array = entries.keys()
	entry_ids.sort_custom(func(a: String, b: String) -> bool:
		var left := "%05d|%s" % [int(entries[a].get("order", 0)), a]
		var right := "%05d|%s" % [int(entries[b].get("order", 0)), b]
		return left < right)
	var discoveries: Array = []
	for entry_id: String in entry_ids:
		var entry: Dictionary = entries[entry_id]
		for requirement_key: String in ["requires_flags", "requires_any_flags"]:
			for flag: Variant in entry.get(requirement_key, []):
				_append_reference(consumed, str(flag), "discovery %s:%s" % [entry_id, requirement_key])
		var variants: Array = []
		for variant: Variant in entry.get("variants", []):
			if typeof(variant) != TYPE_DICTIONARY:
				continue
			var variant_id := str(variant.get("id", ""))
			for requirement_key: String in ["requires_flags", "requires_any_flags"]:
				for flag: Variant in variant.get(requirement_key, []):
					_append_reference(consumed, str(flag), "discovery %s:%s:%s" % [entry_id, variant_id, requirement_key])
			variants.append({
				"id": variant_id,
				"requires_flags": _string_array(variant.get("requires_flags", [])),
				"requires_any_flags": _string_array(variant.get("requires_any_flags", [])),
			})
		discoveries.append({
			"id": entry_id,
			"thread": str(entry.get("thread", "")),
			"event_id": str(entry.get("event_id", "")),
			"order": int(entry.get("order", 0)),
			"requires_flags": _string_array(entry.get("requires_flags", [])),
			"requires_any_flags": _string_array(entry.get("requires_any_flags", [])),
			"variants": variants,
		})
	return discoveries


## used_by lists the combat choices that actually fight the adversary. An event
## level adversary_id only supplies the portrait and the default combat target,
## so it is reported separately rather than counted as a fight.
func _collect_adversaries(repository, usage: Dictionary, event_refs: Dictionary) -> Array:
	var adversary_ids: Array = repository.adversaries.keys()
	adversary_ids.sort()
	var adversaries: Array = []
	for adversary_id: String in adversary_ids:
		adversaries.append({
			"id": adversary_id,
			"name": str(repository.adversaries[adversary_id].get("name", "")),
			"used_by": _string_array(usage.get(adversary_id, [])),
			"named_by_events": _string_array(event_refs.get(adversary_id, [])),
		})
	for referenced_id: String in usage:
		if repository.adversaries.has(referenced_id):
			continue
		problems.append("Combat choice references undefined adversary '%s' (%s)" % [referenced_id, ", ".join(_string_array(usage[referenced_id]))])
		adversaries.append({
			"id": referenced_id,
			"name": "MISSING DEFINITION",
			"used_by": _string_array(usage[referenced_id]),
			"named_by_events": _string_array(event_refs.get(referenced_id, [])),
		})
	return adversaries


## The Living Road pack patches flags onto baseline outcomes. The repository
## applies them during load, so this reports the patch list and confirms every
## patched flag is present on the live outcome.
func _collect_source_patches(repository, configuration: String) -> Array:
	if configuration != "expanded":
		return []
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LIVING_ROAD_FILE))
	if typeof(parsed) != TYPE_DICTIONARY:
		problems.append("Unreadable Living Road document: %s" % LIVING_ROAD_FILE)
		return []
	var patches: Array = []
	for patch: Variant in parsed.get("source_flag_patches", []):
		if typeof(patch) != TYPE_DICTIONARY:
			continue
		var event_id := str(patch.get("event_id", ""))
		var choice_index := int(patch.get("choice_index", -1))
		var outcome_key := str(patch.get("outcome", ""))
		var add_flags := _string_array(patch.get("add_flags", []))
		var applied := false
		var event: Dictionary = repository.events.get(event_id, {})
		var choices: Array = event.get("choices", [])
		if choice_index >= 0 and choice_index < choices.size() and choices[choice_index].has(outcome_key):
			var live_flags := _string_array(choices[choice_index][outcome_key].get("add_flags", []))
			applied = true
			for flag: String in add_flags:
				if flag not in live_flags:
					applied = false
		if not applied:
			problems.append("Living Road source patch did not apply: %s:%d:%s" % [event_id, choice_index, outcome_key])
		patches.append({
			"event": event_id,
			"choice": choice_index,
			"outcome": outcome_key,
			"add_flags": add_flags,
			"applied": applied,
		})
	return patches


# ---------------------------------------------------------------- reachability


## Reachability is a fixed point over the scheduler and the next_event graph.
## An event is reachable when the scheduler can offer it (a region pool entry or
## a global entry whose flag eligibility some reachable outcome satisfies), when
## a reachable outcome chains to it, or when the engine jumps to it directly.
func _compute_reachability(repository, pool_map: Dictionary, next_event_sources: Dictionary, last_region_index: int) -> Dictionary:
	var candidates: Dictionary = {}
	var beyond_schedule: Dictionary = {}
	for event_id: String in repository.events:
		var event: Dictionary = repository.events[event_id]
		if not pool_map.has(event_id) and not bool(event.get("global", false)):
			continue
		if int(event.get("eligibility", {}).get("min_region_index", 0)) > last_region_index:
			beyond_schedule[event_id] = true
			continue
		candidates[event_id] = true
	var reachable: Dictionary = {}
	if repository.events.has(FINAL_EVENT_ID):
		reachable[FINAL_EVENT_ID] = "engine final gate (GameEngine.FINAL_EVENT_ID)"
	var produced: Dictionary = {}
	var changed := true
	while changed:
		changed = false
		for event_id: String in reachable.keys():
			var event: Dictionary = repository.events[event_id]
			var choices: Array = event.get("choices", [])
			for choice_index: int in range(choices.size()):
				var choice: Dictionary = choices[choice_index]
				for outcome_key: String in OUTCOME_KEYS:
					if not choice.has(outcome_key):
						continue
					var outcome: Dictionary = choice[outcome_key]
					for flag: Variant in outcome.get("add_flags", []):
						if not produced.has(str(flag)):
							produced[str(flag)] = true
							changed = true
					var next_event := str(outcome.get("next_event", ""))
					if next_event == "" or not repository.events.has(next_event) or reachable.has(next_event):
						continue
					reachable[next_event] = "next_event from %s:%d:%s" % [event_id, choice_index, outcome_key]
					changed = true
		for event_id: String in candidates:
			if reachable.has(event_id):
				continue
			if not _eligibility_satisfied(repository.events[event_id], produced):
				continue
			reachable[event_id] = "scheduler candidate (%s)" % ("region pool" if pool_map.has(event_id) else "global")
			changed = true
	var reachable_ids: Array = reachable.keys()
	reachable_ids.sort()
	var unreachable_ids: Array = []
	for event_id: String in repository.events:
		if not reachable.has(event_id):
			unreachable_ids.append(event_id)
	unreachable_ids.sort()
	var unreachable: Array = []
	for event_id: String in unreachable_ids:
		unreachable.append({
			"id": event_id,
			"reason": _unreachable_reason(repository, event_id, pool_map, next_event_sources, candidates, beyond_schedule, reachable, produced, last_region_index),
		})
	var reachable_via: Dictionary = {}
	for event_id: String in reachable_ids:
		reachable_via[event_id] = reachable[event_id]
	return {
		"reachable": reachable_ids,
		"unreachable": unreachable,
		"reachable_via": reachable_via,
		"flags_reachable_content_produces": _sorted_keys(produced),
	}


func _eligibility_satisfied(event: Dictionary, produced: Dictionary) -> bool:
	var eligibility: Dictionary = event.get("eligibility", {})
	for flag: Variant in eligibility.get("requires_flags", []):
		if not produced.has(str(flag)):
			return false
	var required_any: Array = eligibility.get("requires_any_flags", [])
	if required_any.is_empty():
		return true
	for flag: Variant in required_any:
		if produced.has(str(flag)):
			return true
	return false


func _unreachable_reason(repository, event_id: String, pool_map: Dictionary, next_event_sources: Dictionary, candidates: Dictionary, beyond_schedule: Dictionary, reachable: Dictionary, produced: Dictionary, last_region_index: int) -> String:
	var event: Dictionary = repository.events[event_id]
	var eligibility: Dictionary = event.get("eligibility", {})
	var reasons: Array[String] = []
	if candidates.has(event_id):
		var missing: Array[String] = []
		for flag: Variant in eligibility.get("requires_flags", []):
			if not produced.has(str(flag)):
				missing.append(str(flag))
		if not missing.is_empty():
			reasons.append("requires flag %s that nothing reachable produces" % ", ".join(missing))
		var required_any := _string_array(eligibility.get("requires_any_flags", []))
		if not required_any.is_empty() and not _any_produced(required_any, produced):
			reasons.append("requires any of [%s] and nothing reachable produces one" % ", ".join(required_any))
	elif beyond_schedule.has(event_id):
		reasons.append("eligibility min_region_index %d is past the last scheduled region index %d, so the scheduler never offers it" % [int(eligibility.get("min_region_index", 0)), last_region_index])
	else:
		reasons.append("no region event_pool lists it and it is not global, so the scheduler never offers it")
	var sources := _string_array(next_event_sources.get(event_id, []))
	if sources.is_empty():
		reasons.append("no outcome next_event points to it")
	else:
		var unreachable_sources: Array[String] = []
		for reference: String in sources:
			var origin := reference.split(":")[0]
			if not reachable.has(origin) and origin not in unreachable_sources:
				unreachable_sources.append(origin)
		if not unreachable_sources.is_empty():
			reasons.append("only reachable as next_event of unreachable event %s" % ", ".join(unreachable_sources))
	if event_id == ENGINE_FALLBACK_ID:
		reasons.append("engine literal only: GameEngine._select_next_event falls back to it when no candidate is eligible")
	return "; ".join(reasons)


# ---------------------------------------------------------------------- render


func _render_markdown(config: Dictionary) -> String:
	var lines: Array[String] = []
	var totals: Dictionary = config["totals"]
	lines.append("# Ashfall Road content dossier - %s configuration" % config["configuration"])
	lines.append("")
	lines.append("Living Road pack: %s. Mechanical fields only: prose bodies and outcome texts are" % ("enabled" if bool(config["living_road_enabled"]) else "disabled"))
	lines.append("reduced to a word count plus the first %d words of each body." % BODY_PREVIEW_WORDS)
	lines.append("")
	lines.append("| metric | count |")
	lines.append("| --- | --- |")
	for key: String in ["events", "choices", "outcomes", "discoveries", "adversaries", "reachable", "unreachable", "source_patches_applied", "flags_produced", "flags_consumed"]:
		lines.append("| %s | %d |" % [key.replace("_", " "), int(totals[key])])
	lines.append("")
	if not config["load_errors"].is_empty():
		lines.append("## Loader errors")
		lines.append("")
		for error: String in config["load_errors"]:
			lines.append("- %s" % error)
		lines.append("")
	_render_events(config, lines)
	_render_flags(config, lines)
	_render_reachability(config, lines)
	_render_discoveries(config, lines)
	_render_adversaries(config, lines)
	_render_patches(config, lines)
	return "\n".join(lines) + "\n"


func _render_events(config: Dictionary, lines: Array[String]) -> void:
	lines.append("## Events by source file and region")
	lines.append("")
	var by_source: Dictionary = {}
	for event: Dictionary in config["events"]:
		var source_file := str(event["source_file"])
		var grouped: Array = by_source.get(source_file, [])
		grouped.append(event)
		by_source[source_file] = grouped
	for source_file: String in by_source:
		lines.append("### %s (%d events)" % [source_file, by_source[source_file].size()])
		lines.append("")
		var buckets: Dictionary = {}
		for region_id: String in config["region_order"]:
			buckets[region_id] = []
		buckets["(global, no region pool)"] = []
		buckets["(no region pool, not global)"] = []
		for event: Dictionary in by_source[source_file]:
			var pools: Array = event["region_pools"]
			if not pools.is_empty():
				buckets[str(pools[0])].append(event)
			elif bool(event["global"]):
				buckets["(global, no region pool)"].append(event)
			else:
				buckets["(no region pool, not global)"].append(event)
		for bucket: String in buckets:
			if buckets[bucket].is_empty():
				continue
			lines.append("#### %s (%d)" % [bucket, buckets[bucket].size()])
			lines.append("")
			for event: Dictionary in buckets[bucket]:
				_render_event(event, lines)
	lines.append("")


func _render_event(event: Dictionary, lines: Array[String]) -> void:
	var markers: Array[String] = []
	if bool(event["global"]):
		markers.append("global")
	if bool(event["unique"]):
		markers.append("unique")
	if bool(event["living_road_callback"]):
		markers.append("living-road-callback")
	lines.append("- **%s** - \"%s\"" % [event["id"], event["title"]])
	var header := "  weight %d, priority %d, body %d words" % [int(event["weight"]), int(event["narrative_priority"]), int(event["body_words"])]
	if not markers.is_empty():
		header += ", " + ", ".join(markers)
	lines.append(header)
	var pools := _string_array(event["region_pools"])
	lines.append("  pools: %s" % ("none" if pools.is_empty() else ", ".join(pools)))
	var tags := _string_array(event["tags"])
	if not tags.is_empty():
		lines.append("  tags: %s" % ", ".join(tags))
	if str(event["adversary_id"]) != "":
		lines.append("  adversary: %s" % event["adversary_id"])
	var eligibility: Dictionary = event["eligibility"]
	if not eligibility.is_empty():
		lines.append("  eligibility: %s" % _describe_eligibility(eligibility))
	if bool(event["living_road_callback"]):
		lines.append("  callback: region %s, thread \"%s\"" % [str(event["callback_region"]), event["callback_thread"]])
	lines.append("  body: %s ..." % event["body_preview"])
	for choice: Dictionary in event["choices"]:
		lines.append("  - choice %d: \"%s\"%s" % [int(choice["index"]), choice["label"], _describe_choice(choice)])
		for outcome_key: String in choice["outcomes"]:
			lines.append("    - %s (%d words)%s" % [outcome_key, int(choice["outcomes"][outcome_key]["words"]), _describe_outcome(choice["outcomes"][outcome_key])])
	lines.append("")


func _describe_eligibility(eligibility: Dictionary) -> String:
	var parts: Array[String] = []
	if eligibility.has("min_region_index"):
		parts.append("min_region_index=%d" % int(eligibility["min_region_index"]))
	if eligibility.has("max_region_index"):
		parts.append("max_region_index=%d" % int(eligibility["max_region_index"]))
	for key: String in ["requires_flags", "requires_any_flags", "forbids_flags"]:
		var listed := _string_array(eligibility.get(key, []))
		if not listed.is_empty():
			parts.append("%s[%s]" % [key, ", ".join(listed)])
	var required_items: Dictionary = eligibility.get("requires_items", {})
	if not required_items.is_empty():
		parts.append(_describe_dictionary("requires_items", required_items))
	return "none" if parts.is_empty() else " ".join(parts)


func _describe_choice(choice: Dictionary) -> String:
	var parts: Array[String] = []
	if str(choice["approach"]) != "":
		parts.append("approach=%s" % choice["approach"])
	var check: Dictionary = choice["check"]
	if not check.is_empty():
		parts.append("check=%s/%s" % [str(check.get("stat", "?")), str(check.get("difficulty", "?"))])
	if choice["modifier"] != null:
		parts.append("modifier=%s" % str(choice["modifier"]))
	var combat: Dictionary = choice["combat"]
	if not combat.is_empty():
		parts.append("combat=%s" % str(combat.get("adversary_id", "event adversary")))
	var requires: Dictionary = choice["requires"]
	for key: String in requires:
		if typeof(requires[key]) == TYPE_ARRAY:
			parts.append("requires.%s[%s]" % [key, ", ".join(_string_array(requires[key]))])
		elif typeof(requires[key]) == TYPE_DICTIONARY:
			parts.append(_describe_dictionary("requires.%s" % key, requires[key]))
		else:
			parts.append("requires.%s=%s" % [key, str(requires[key])])
	var costs: Dictionary = choice["costs"]
	for key: String in costs:
		if typeof(costs[key]) == TYPE_DICTIONARY:
			parts.append(_describe_dictionary("costs.%s" % key, costs[key]))
		else:
			parts.append("costs.%s=%s" % [key, str(costs[key])])
	return "" if parts.is_empty() else " - " + " ".join(parts)


func _describe_outcome(outcome: Dictionary) -> String:
	var parts: Array[String] = [
		_describe_dictionary("items", outcome["items"]),
		_describe_dictionary("pressures", outcome["pressures"]),
		_describe_list("add_conditions", outcome["add_conditions"]),
		_describe_list("remove_conditions", outcome["remove_conditions"]),
		_describe_list("add_flags", outcome["add_flags"]),
	]
	if str(outcome["next_event"]) != "":
		parts.append("next_event=%s" % outcome["next_event"])
	if bool(outcome["lethal"]):
		parts.append("LETHAL")
	if str(outcome["damage_type"]) != "":
		parts.append("damage_type=%s" % outcome["damage_type"])
	if outcome["experience"] != null:
		parts.append("experience=%s" % str(outcome["experience"]))
	if bool(outcome["victory"]):
		parts.append("VICTORY")
	var kept: Array[String] = []
	for part: String in parts:
		if part != "":
			kept.append(part)
	return " - no mechanical effect" if kept.is_empty() else " - " + " ".join(kept)


func _render_flags(config: Dictionary, lines: Array[String]) -> void:
	var produced: Dictionary = config["flags"]["produced"]
	var consumed: Dictionary = config["flags"]["consumed"]
	lines.append("## Flag index")
	lines.append("")
	lines.append("### Producers (%d flags)" % produced.size())
	lines.append("")
	for flag: String in produced:
		var readers := " - read by %d reference(s)" % _string_array(consumed.get(flag, [])).size() if consumed.has(flag) else " - NEVER READ"
		lines.append("- `%s`%s" % [flag, readers])
		lines.append("  - written by: %s" % ", ".join(_string_array(produced[flag])))
	lines.append("")
	lines.append("### Consumers (%d flags)" % consumed.size())
	lines.append("")
	for flag: String in consumed:
		var writers := "" if produced.has(flag) else " - NEVER WRITTEN"
		lines.append("- `%s`%s" % [flag, writers])
		lines.append("  - read by: %s" % ", ".join(_string_array(consumed[flag])))
	lines.append("")


func _render_reachability(config: Dictionary, lines: Array[String]) -> void:
	var reachability: Dictionary = config["reachability"]
	lines.append("## Reachability")
	lines.append("")
	lines.append("%d reachable, %d unreachable." % [reachability["reachable"].size(), reachability["unreachable"].size()])
	lines.append("")
	lines.append("### Unreachable")
	lines.append("")
	if reachability["unreachable"].is_empty():
		lines.append("- none")
	for entry: Dictionary in reachability["unreachable"]:
		lines.append("- **%s** - %s" % [entry["id"], entry["reason"]])
	lines.append("")


func _render_discoveries(config: Dictionary, lines: Array[String]) -> void:
	lines.append("## Discoveries (Road Ledger)")
	lines.append("")
	for entry: Dictionary in config["discoveries"]:
		lines.append("- **%s** - thread \"%s\", event %s" % [entry["id"], entry["thread"], "none" if str(entry["event_id"]) == "" else entry["event_id"]])
		var gate := _describe_gate(entry)
		if gate != "":
			lines.append("  entry gate: %s" % gate)
		for variant: Dictionary in entry["variants"]:
			var variant_gate := _describe_gate(variant)
			lines.append("  - variant %s%s" % [variant["id"], "" if variant_gate == "" else " - " + variant_gate])
	lines.append("")


func _describe_gate(entry: Dictionary) -> String:
	var parts: Array[String] = []
	for key: String in ["requires_flags", "requires_any_flags"]:
		var listed := _string_array(entry.get(key, []))
		if not listed.is_empty():
			parts.append("%s[%s]" % [key, ", ".join(listed)])
	return " ".join(parts)


func _render_adversaries(config: Dictionary, lines: Array[String]) -> void:
	lines.append("## Adversary usage")
	lines.append("")
	for adversary: Dictionary in config["adversaries"]:
		var used_by := _string_array(adversary["used_by"])
		var named_by := _string_array(adversary["named_by_events"])
		var suffix := "" if named_by.is_empty() else " (named by event: %s)" % ", ".join(named_by)
		lines.append("- **%s** (%s) - %s%s" % [adversary["id"], adversary["name"], "NO COMBAT CHOICE" if used_by.is_empty() else ", ".join(used_by), suffix])
	lines.append("")


func _render_patches(config: Dictionary, lines: Array[String]) -> void:
	lines.append("## Living Road source flag patches")
	lines.append("")
	if config["source_patches_applied"].is_empty():
		lines.append("- none (the launch configuration applies no source flag patches)")
		lines.append("")
		return
	for patch: Dictionary in config["source_patches_applied"]:
		lines.append("- %s choice %d outcome %s gains [%s]%s" % [
			patch["event"],
			int(patch["choice"]),
			patch["outcome"],
			", ".join(_string_array(patch["add_flags"])),
			"" if bool(patch["applied"]) else " - NOT APPLIED",
		])
	lines.append("")


# --------------------------------------------------------------------- helpers


func _describe_dictionary(prefix: String, value: Dictionary) -> String:
	if value.is_empty():
		return ""
	var keys: Array = value.keys()
	keys.sort()
	var parts: Array[String] = []
	for key: Variant in keys:
		parts.append("%s:%s" % [str(key), str(value[key])])
	return "%s{%s}" % [prefix, ", ".join(parts)]


func _describe_list(prefix: String, value: Array) -> String:
	if value.is_empty():
		return ""
	return "%s[%s]" % [prefix, ", ".join(_string_array(value))]


func _append_reference(index: Dictionary, key: String, reference: String) -> void:
	var listed: Array = index.get(key, [])
	if reference not in listed:
		listed.append(reference)
	index[key] = listed


func _sorted_index(index: Dictionary) -> Dictionary:
	var keys: Array = index.keys()
	keys.sort()
	var sorted_index: Dictionary = {}
	for key: String in keys:
		sorted_index[key] = index[key]
	return sorted_index


func _sorted_keys(index: Dictionary) -> Array:
	var keys: Array = index.keys()
	keys.sort()
	return keys


func _any_produced(flags: Array, produced: Dictionary) -> bool:
	for flag: Variant in flags:
		if produced.has(str(flag)):
			return true
	return false


func _copy_dictionary(value: Variant) -> Dictionary:
	if typeof(value) != TYPE_DICTIONARY:
		return {}
	return _normalize(value) as Dictionary


## JSON parsing turns every authored number into a float, so a quantity of one
## arrives as 1.0. Whole numbers are folded back to integers for both outputs;
## anything genuinely fractional is left untouched.
func _normalize(value: Variant) -> Variant:
	match typeof(value):
		TYPE_FLOAT:
			var number: float = value
			return int(number) if is_equal_approx(number, floor(number)) else number
		TYPE_DICTIONARY:
			var copied: Dictionary = {}
			for key: Variant in value:
				copied[str(key)] = _normalize(value[key])
			return copied
		TYPE_ARRAY:
			var listed: Array = []
			for entry: Variant in value:
				listed.append(_normalize(entry))
			return listed
	return value


func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if typeof(value) != TYPE_ARRAY and typeof(value) != TYPE_PACKED_STRING_ARRAY:
		return result
	for entry: Variant in value:
		result.append(str(entry))
	return result


func _word_count(value: String) -> int:
	return value.split(" ", false).size()


func _preview(value: String) -> String:
	var words := value.replace("\n", " ").split(" ", false)
	var kept: Array[String] = []
	for index: int in range(min(BODY_PREVIEW_WORDS, words.size())):
		kept.append(words[index])
	return " ".join(kept)


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
