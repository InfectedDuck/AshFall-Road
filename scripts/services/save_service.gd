class_name SaveService
extends RefCounted

const ExperienceRules = preload("res://scripts/domain/experience_rules.gd")

const PROFILE_SCHEMA := 5
const RUN_SCHEMA := 5
const ENTITLEMENT_SCHEMA := 1
const CONTEXTUAL_TIP_IDS := ["checked_choice", "event_preparation", "enemy_heavy_sweep", "defense_window", "weapon_mastery", "opportunity", "checkpoint_allocation"]
const DISCOVERY_COLLECTIONS := ["discovered_story_nodes", "discovered_characters", "discovered_endings"]

var prefix := ""


func _init(file_prefix: String = "") -> void:
	prefix = file_prefix


func save_run(run_state: Dictionary) -> bool:
	if run_state.is_empty():
		return false
	var copy := run_state.duplicate(true)
	copy["schema_version"] = RUN_SCHEMA
	copy["saved_at"] = Time.get_unix_time_from_system()
	return _atomic_write(_path("active_run.json"), copy)


func load_run() -> Dictionary:
	var run := _read_json(_path("active_run.json"))
	if run.is_empty():
		run = _read_json(_path("active_run.backup.json"))
	if run.is_empty():
		return {}
	var marker := _read_json(_path("death_marker.json"))
	if marker.is_empty():
		marker = _read_json(_path("death_marker.json.bak"))
	if not marker.is_empty() and str(marker.get("run_id", "")) == str(run.get("run_id", "")):
		delete_run_files()
		return {}
	return _migrate_run(run)


func write_death_marker_and_delete(run_id: String) -> bool:
	if not write_death_marker(run_id):
		return false
	return delete_run_files()


func write_death_marker(run_id: String) -> bool:
	return _atomic_write(_path("death_marker.json"), {
		"run_id": run_id,
		"recorded_at": Time.get_unix_time_from_system(),
	})


func clear_death_marker() -> void:
	_remove_if_exists(_path("death_marker.json"))
	_remove_if_exists(_path("death_marker.json.bak"))


func delete_run_files() -> bool:
	var primary_removed := _remove_if_exists(_path("active_run.json"))
	var backup_removed := _remove_if_exists(_path("active_run.backup.json"))
	var temporary_removed := _remove_if_exists(_path("active_run.json.tmp"))
	return primary_removed and backup_removed and temporary_removed


func save_profile(profile: Dictionary) -> bool:
	var copy := profile.duplicate(true)
	copy["schema_version"] = PROFILE_SCHEMA
	return _atomic_write(_path("profile.json"), copy)


func load_profile() -> Dictionary:
	var profile := _read_json(_path("profile.json"))
	if profile.is_empty():
		profile = _read_json(_path("profile.json.bak"))
	var old_schema := int(profile.get("schema_version", 1))
	if old_schema < 5:
		profile["contextual_tips_seen"] = CONTEXTUAL_TIP_IDS.duplicate() if bool(profile.get("tutorial_seen", false)) else []
	var defaults := default_profile()
	for key: String in defaults:
		if not profile.has(key):
			profile[key] = defaults[key]
	for collection_key: String in DISCOVERY_COLLECTIONS + ["contextual_tips_seen", "applied_profile_update_ids"]:
		if typeof(profile.get(collection_key, null)) != TYPE_ARRAY:
			profile[collection_key] = []
		else:
			var unique_values: Array = []
			for value: Variant in profile[collection_key]:
				var normalized := str(value)
				if normalized != "" and normalized not in unique_values:
					unique_values.append(normalized)
			profile[collection_key] = unique_values
	profile["schema_version"] = PROFILE_SCHEMA
	if str(profile.get("combat_presentation", "manual")) not in ["manual", "quick"]:
		profile["combat_presentation"] = "manual"
	return profile


func save_entitlements(entitlements: Dictionary) -> bool:
	var copy := entitlements.duplicate(true)
	copy["schema_version"] = ENTITLEMENT_SCHEMA
	return _atomic_write(_path("entitlements.json"), copy)


func load_entitlements() -> Dictionary:
	var result := _read_json(_path("entitlements.json"))
	if result.is_empty():
		result = _read_json(_path("entitlements.json.bak"))
	var defaults := {"schema_version": ENTITLEMENT_SCHEMA, "remove_ads": false, "theme_rust": false, "theme_night": false, "supporter": false, "verified_at": 0}
	for key: String in defaults:
		if not result.has(key):
			result[key] = defaults[key]
	return result


func default_profile() -> Dictionary:
	return {
		"schema_version": PROFILE_SCHEMA,
		"tutorial_seen": false,
		"contextual_tips_seen": [],
		"contextual_tips_enabled": true,
		"applied_profile_update_ids": [],
		"selected_theme": "default",
		"font_scale": 1.0,
		"story_text_speed": "normal",
		"combat_presentation": "manual",
		"high_contrast": false,
		"reduced_motion": false,
		"music_enabled": true,
		"sound_enabled": true,
		"haptics_enabled": true,
		"runs_started": 0,
		"deaths": 0,
		"victories": 0,
		"best_region": 0,
		"run_history": [],
		"discovered_story_nodes": [],
		"discovered_characters": [],
		"discovered_endings": [],
	}



## The receipt contains only profile deltas and a terminal summary. It can never
## be restored as a living run. One receipt is outstanding at a time; callers
## must finish replay before accepting further gameplay or profile mutations.
func write_profile_update_receipt(receipt: Dictionary) -> bool:
	if not _valid_profile_receipt(receipt):
		return false
	var existing := _read_receipt()
	if not existing.is_empty() and existing != JSON.parse_string(JSON.stringify(receipt)):
		return false
	return _atomic_write(_path("profile_update.json"), receipt)


func _read_receipt() -> Dictionary:
	var receipt := _read_json(_path("profile_update.json"))
	if receipt.is_empty():
		receipt = _read_json(_path("profile_update.json.bak"))
	return receipt


func replay_profile_updates(profile: Dictionary) -> Dictionary:
	var receipt := _read_receipt()
	if receipt.is_empty():
		if FileAccess.file_exists(_path("profile_update.json")) or FileAccess.file_exists(_path("profile_update.json.bak")):
			return {"success": false, "error": "The pending profile record could not be read. Keep the save files and retry recovery."}
		return {"success": true}
	if not _valid_profile_receipt(receipt):
		return {"success": false, "error": "The pending profile record is invalid. Keep the save files and retry recovery."}
	var updates: Dictionary = receipt["updates"]
	var summary: Dictionary = updates.get("run_summary", {})
	# Secure death before deleting anything, including if profile saving fails.
	if not summary.is_empty() and str(summary["result"]) == "dead":
		if not write_death_marker(str(summary["run_id"])):
			return {"success": false, "error": "Could not secure the death record."}
	var next := profile.duplicate(true)
	var applied: Array = next.get("applied_profile_update_ids", []).duplicate()
	var receipt_id := str(receipt["receipt_id"])
	if receipt_id not in applied:
		for key: String in DISCOVERY_COLLECTIONS:
			var values: Array = next.get(key, []).duplicate()
			for token: String in updates.get(key, []):
				# Variants accumulate. Replacing them would erase what an earlier
				# run recorded about the same chapter.
				if token not in values:
					values.append(token)
			next[key] = values
		if not summary.is_empty():
			var completion_id := "completed:" + str(summary["run_id"])
			var history: Array = next.get("run_history", []).duplicate(true)
			var recorded := completion_id in applied
			for old: Dictionary in history:
				recorded = recorded or str(old.get("run_id", "")) == str(summary["run_id"])
			if not recorded:
				history.push_front(summary.duplicate(true))
				if history.size() > 20:
					history.resize(20)
				var counter := "victories" if str(summary["result"]) == "victory" else "deaths"
				next[counter] = int(next.get(counter, 0)) + 1
				next["best_region"] = maxi(int(next.get("best_region", 0)), int(summary.get("regions_reached", 0)))
			if completion_id not in applied:
				applied.append(completion_id)
			next["run_history"] = history
		applied.append(receipt_id)
		next["applied_profile_update_ids"] = applied
		if not save_profile(next):
			return {"success": false, "error": "Could not save discoveries or the completed-run summary."}
		profile.clear()
		profile.merge(next, true)
	# Repeat cleanup safely after a crash between profile commit and receipt removal.
	if not summary.is_empty() and not delete_run_files():
		return {"success": false, "error": "Could not finish terminal run cleanup."}
	for suffix: String in ["profile_update.json.bak", "profile_update.json.tmp", "profile_update.json"]:
		if not _remove_if_exists(_path(suffix)):
			return {"success": false, "error": "Could not finish clearing the committed profile record."}
	return {"success": true}


func _valid_profile_receipt(receipt: Dictionary) -> bool:
	if int(receipt.get("schema_version", 0)) != 1 or str(receipt.get("receipt_id", "")).is_empty():
		return false
	for key: String in receipt:
		if key not in ["schema_version", "receipt_id", "updates"]:
			return false
	if not (receipt.get("updates") is Dictionary):
		return false
	var updates: Dictionary = receipt["updates"]
	for key: String in updates:
		if key not in DISCOVERY_COLLECTIONS + ["run_summary"]:
			return false
		if key in DISCOVERY_COLLECTIONS:
			if not (updates[key] is Array):
				return false
			for token: Variant in updates[key]:
				if not (token is String) or str(token).is_empty():
					return false
	if updates.has("run_summary"):
		if not (updates["run_summary"] is Dictionary):
			return false
		var summary: Dictionary = updates["run_summary"]
		if str(summary.get("run_id", "")).is_empty() or str(summary.get("result", "")) not in ["dead", "victory"]:
			return false
		# Explicit summary allowlist prevents accidentally journalling RunState.
		for key: String in summary:
			if key not in ["run_id", "survivor", "callsign", "result", "regions_reached", "region", "events_resolved", "level", "experience", "stat_points_earned", "enemies_defeated", "strongest_enemy", "xp_lost", "cause", "conditions", "equipment", "ended_at"]:
				return false
			if key in ["enemies_defeated", "conditions", "equipment"]:
				if not (summary[key] is Array):
					return false
				for value: Variant in summary[key]:
					if not (value is String):
						return false
			elif key in ["regions_reached", "events_resolved", "level", "experience", "stat_points_earned", "xp_lost", "ended_at"]:
				if typeof(summary[key]) not in [TYPE_INT, TYPE_FLOAT]:
					return false
			elif not (summary[key] is String):
				return false
	return true


func _migrate_run(run: Dictionary) -> Dictionary:
	if int(run.get("schema_version", 1)) > RUN_SCHEMA:
		return {}
	if int(run.get("schema_version", 1)) < 2:
		var survivor: Dictionary = run.get("survivor", {})
		var old_pressures: Dictionary = survivor.get("pressures", {})
		var grit := int(survivor.get("stats", {}).get("grit", 1))
		var hearts := GameEngine.max_hearts_for_grit(grit)
		var maximum := hearts * GameEngine.HP_PER_HEART
		var old_health := clampi(int(old_pressures.get("health", 100)), 0, 100)
		var old_hunger := clampi(int(old_pressures.get("hunger", 0)), 0, 100)
		survivor["portrait_id"] = str(survivor.get("portrait_id", "survivor_1"))
		survivor["vitals"] = {
			"health": clampi(roundi(float(old_health) / 100.0 * maximum), 0, maximum),
			"max_health": maximum,
			"max_hearts": hearts,
			"satiety": clampi(roundi(float(100 - old_hunger) / 25.0), 0, GameEngine.MAX_SATIETY),
		}
		survivor["pressures"] = {
			"fatigue": clampi(int(old_pressures.get("fatigue", 0)), 0, 100),
			"radiation": clampi(int(old_pressures.get("radiation", 0)), 0, 100),
		}
		run["survivor"] = survivor
		run["schema_version"] = 2
	if int(run.get("schema_version", 2)) < 3:
		var completed_checkpoints := clampi(int(run.get("region_index", 0)), 0, 6)
		if str(run.get("phase", "")) == "checkpoint":
			completed_checkpoints = clampi(completed_checkpoints + 1, 0, 6)
		var rewarded: Array = []
		for checkpoint_index in range(completed_checkpoints):
			rewarded.append(checkpoint_index)
		run["level"] = completed_checkpoints
		run["unspent_stat_points"] = 0
		run["rewarded_checkpoints"] = rewarded
		run["rules_version"] = D20Resolver.RULES_VERSION
		run["schema_version"] = 3
	if int(run.get("schema_version", 3)) < 4:
		var legacy_level := clampi(int(run.get("level", 0)), 0, ExperienceRules.MAX_LEVEL - 1)
		var converted_level := legacy_level + 1
		var completed_checkpoint_rewards: Array = run.get("rewarded_checkpoints", []).duplicate(true)
		run["level"] = converted_level
		run["experience"] = ExperienceRules.threshold_for_level(converted_level)
		run["xp_curve_version"] = ExperienceRules.RULES_VERSION
		run["xp_award_ids"] = []
		run["checkpoint_xp_awards"] = completed_checkpoint_rewards
		run["combat_opportunities_seen_in_region"] = 0
		run["defeated_adversaries"] = []
		run["last_checkpoint_xp"] = {}
		run["schema_version"] = 4
	if int(run.get("schema_version", 4)) < 5:
		# An existing fight, including all its future rounds, retains frozen v1 math.
		if not run.get("combat_state", {}).is_empty():
			run["combat_state"]["combat_rules_version"] = 1
		run["schema_version"] = 5
	if not run.has("pending_resolution"):
		run["pending_resolution"] = {}
	if not run.has("condition_uses"):
		run["condition_uses"] = {}
	if not run.has("checkpoint_action"):
		run["checkpoint_action"] = ""
	if not run.has("hunger_clock"):
		run["hunger_clock"] = 0
	if not run.has("supply_seen_in_region"):
		run["supply_seen_in_region"] = false
	if not run.has("combat_state"):
		run["combat_state"] = {}
	if not run.has("pending_combat_round"):
		run["pending_combat_round"] = {}
	if not run.has("level"):
		run["level"] = ExperienceRules.STARTING_LEVEL
	if not run.has("unspent_stat_points"):
		run["unspent_stat_points"] = 0
	if not run.has("rewarded_checkpoints"):
		run["rewarded_checkpoints"] = []
	if not run.has("rules_version"):
		run["rules_version"] = D20Resolver.RULES_VERSION
	if not run.has("experience"):
		run["experience"] = ExperienceRules.threshold_for_level(int(run["level"]))
	if not run.has("xp_curve_version"):
		run["xp_curve_version"] = ExperienceRules.RULES_VERSION
	if not run.has("xp_award_ids"):
		run["xp_award_ids"] = []
	if not run.has("checkpoint_xp_awards"):
		run["checkpoint_xp_awards"] = []
	if not run.has("combat_opportunities_seen_in_region"):
		run["combat_opportunities_seen_in_region"] = 0
	if not run.has("defeated_adversaries"):
		run["defeated_adversaries"] = []
	if not run.has("last_checkpoint_xp"):
		run["last_checkpoint_xp"] = {}
	return run


func _atomic_write(path: String, value: Dictionary) -> bool:
	var temp_path := "%s.tmp" % path
	var backup_path := path.replace(".json", ".backup.json") if path.ends_with("active_run.json") else "%s.bak" % path
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		return false
	var serialized := JSON.stringify(value, "\t")
	file.store_string(serialized)
	file.flush()
	var write_failed := file.get_error() != OK
	file.close()
	# Never rotate the known-good primary over an incomplete low-storage write.
	if write_failed or FileAccess.get_file_as_string(temp_path) != serialized:
		_remove_if_exists(temp_path)
		return false
	if FileAccess.file_exists(path):
		_remove_if_exists(backup_path)
		if DirAccess.rename_absolute(ProjectSettings.globalize_path(path), ProjectSettings.globalize_path(backup_path)) != OK:
			_remove_if_exists(temp_path)
			return false
	if DirAccess.rename_absolute(ProjectSettings.globalize_path(temp_path), ProjectSettings.globalize_path(path)) != OK:
		if FileAccess.file_exists(backup_path):
			DirAccess.rename_absolute(ProjectSettings.globalize_path(backup_path), ProjectSettings.globalize_path(path))
		return false
	return true


func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if typeof(parsed) == TYPE_DICTIONARY else {}


func _remove_if_exists(path: String) -> bool:
	if FileAccess.file_exists(path):
		return DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) == OK
	return true


func _path(file_name: String) -> String:
	return "user://%s%s" % [prefix, file_name]
