class_name SaveService
extends RefCounted

const PROFILE_SCHEMA := 1
const RUN_SCHEMA := 1
const ENTITLEMENT_SCHEMA := 1

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
	if not marker.is_empty() and str(marker.get("run_id", "")) == str(run.get("run_id", "")):
		delete_run_files()
		return {}
	return _migrate_run(run)


func write_death_marker_and_delete(run_id: String) -> bool:
	var marked := _atomic_write(_path("death_marker.json"), {
		"run_id": run_id,
		"recorded_at": Time.get_unix_time_from_system(),
	})
	if marked:
		_remove_if_exists(_path("active_run.json"))
		_remove_if_exists(_path("active_run.backup.json"))
	return marked


func clear_death_marker() -> void:
	_remove_if_exists(_path("death_marker.json"))


func delete_run_files() -> void:
	_remove_if_exists(_path("active_run.json"))
	_remove_if_exists(_path("active_run.backup.json"))


func save_profile(profile: Dictionary) -> bool:
	var copy := profile.duplicate(true)
	copy["schema_version"] = PROFILE_SCHEMA
	return _atomic_write(_path("profile.json"), copy)


func load_profile() -> Dictionary:
	var profile := _read_json(_path("profile.json"))
	if profile.is_empty():
		profile = _read_json(_path("profile.json.bak"))
	var defaults := default_profile()
	for key: String in defaults:
		if not profile.has(key):
			profile[key] = defaults[key]
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
		"selected_theme": "default",
		"font_scale": 1.0,
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
	}


func _migrate_run(run: Dictionary) -> Dictionary:
	if int(run.get("schema_version", 1)) > RUN_SCHEMA:
		return {}
	if not run.has("pending_resolution"):
		run["pending_resolution"] = {}
	if not run.has("condition_uses"):
		run["condition_uses"] = {}
	return run


func _atomic_write(path: String, value: Dictionary) -> bool:
	var temp_path := "%s.tmp" % path
	var backup_path := path.replace(".json", ".backup.json") if path.ends_with("active_run.json") else "%s.bak" % path
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(value, "\t"))
	file.flush()
	file.close()
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


func _remove_if_exists(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _path(file_name: String) -> String:
	return "user://%s%s" % [prefix, file_name]
