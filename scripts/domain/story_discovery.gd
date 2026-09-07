class_name StoryDiscovery
extends RefCounted


static func apply_resolution(result: Dictionary, run_flags: Array, entries: Dictionary, profile: Dictionary) -> Dictionary:
	if result.is_empty():
		return {"changed": false, "new_nodes": [], "profile": profile}
	var resolved_event_id := str(result.get("event_id", ""))
	var nodes: Array = _normalized_collection(profile.get("discovered_story_nodes", []))
	var characters: Array = _normalized_collection(profile.get("discovered_characters", []))
	var endings: Array = _normalized_collection(profile.get("discovered_endings", []))
	var new_nodes: Array = []
	var changed := false
	for entry_id: String in entries:
		var entry: Dictionary = entries[entry_id]
		var entry_event := str(entry.get("event_id", ""))
		if entry_event != "" and entry_event != resolved_event_id:
			continue
		if not requirements_met(entry, run_flags):
			continue
		var selected_variant: Dictionary = {}
		for variant: Dictionary in entry.get("variants", []):
			if requirements_met(variant, run_flags):
				selected_variant = variant
				break
		if not entry.get("variants", []).is_empty() and selected_variant.is_empty():
			continue
		var discovery_token := entry_id
		if not selected_variant.is_empty():
			discovery_token += ":%s" % str(selected_variant.get("id", "resolved"))
		if discovery_token not in nodes:
			# Earlier variants are kept. A later run does not overwrite what a
			# previous survivor found; the Chronicle shows both accounts.
			nodes.append(discovery_token)
			new_nodes.append(discovery_token)
			changed = true
		var discovered_character_ids: Array = entry.get("characters", [])
		if not selected_variant.is_empty():
			discovered_character_ids = selected_variant.get("characters", discovered_character_ids)
		for character_id: Variant in discovered_character_ids:
			var normalized_id := str(character_id)
			if normalized_id != "" and normalized_id not in characters:
				characters.append(normalized_id)
				changed = true
		if str(entry.get("category", "story")) == "ending" and discovery_token not in endings:
			endings.append(discovery_token)
			changed = true
	profile["discovered_story_nodes"] = nodes
	profile["discovered_characters"] = characters
	profile["discovered_endings"] = endings
	return {"changed": changed, "new_nodes": new_nodes, "profile": profile}


## Unique chapters, counted apart from the variants recorded against them.
static func chapter_ids(nodes: Array) -> Array:
	var chapters: Array = []
	for token: Variant in nodes:
		var chapter := str(token).get_slice(":", 0)
		if chapter != "" and chapter not in chapters:
			chapters.append(chapter)
	return chapters


## Every recorded account for one chapter, in the order they were discovered.
static func variant_tokens(nodes: Array, entry_id: String) -> Array:
	var tokens: Array = []
	for token: Variant in nodes:
		var normalized := str(token)
		if normalized == entry_id or normalized.begins_with(entry_id + ":"):
			tokens.append(normalized)
	return tokens


static func requirements_met(definition: Dictionary, run_flags: Array) -> bool:
	for required_flag: Variant in definition.get("requires_flags", []):
		if str(required_flag) not in run_flags:
			return false
	var required_any: Array = definition.get("requires_any_flags", [])
	if required_any.is_empty():
		return true
	for possible_flag: Variant in required_any:
		if str(possible_flag) in run_flags:
			return true
	return false


static func _normalized_collection(value: Variant) -> Array:
	var result: Array = []
	if typeof(value) != TYPE_ARRAY:
		return result
	for entry: Variant in value:
		var normalized := str(entry)
		if normalized != "" and normalized not in result:
			result.append(normalized)
	return result
