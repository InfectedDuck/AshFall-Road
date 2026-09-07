extends SceneTree

const ContentRepositoryScript = preload("res://scripts/domain/content_repository.gd")

var blockers: Array[String] = []
var warnings: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_content()
	_check_project()
	_check_export_preset()
	_check_release_assets()
	print("Ashfall Road release-readiness audit")
	print("Blockers: %d | Warnings: %d" % [blockers.size(), warnings.size()])
	for blocker: String in blockers:
		print("BLOCKER: %s" % blocker)
	for warning: String in warnings:
		print("WARNING: %s" % warning)
	if blockers.is_empty():
		print("LOCAL RELEASE GATE PASSED. Play Console, tester, policy, and human-device gates still require owner confirmation.")
	quit(1 if not blockers.is_empty() else 0)


func _check_content() -> void:
	var errors: PackedStringArray = ContentRepositoryScript.new().validate_all()
	for error: String in errors:
		blockers.append("Content: %s" % error)


func _check_project() -> void:
	if str(ProjectSettings.get_setting("application/config/name", "")) != "Ashfall Road":
		blockers.append("The application name is not Ashfall Road.")
	if int(ProjectSettings.get_setting("display/window/handheld/orientation", 0)) != 1:
		blockers.append("Android orientation is not locked to portrait.")
	if bool(ProjectSettings.get_setting("ashfall/release/monetization_enabled", true)):
		blockers.append("Monetization must remain disabled for the free v1 launch.")


func _check_export_preset() -> void:
	var presets := ConfigFile.new()
	if presets.load("res://export_presets.cfg") != OK:
		blockers.append("export_presets.cfg cannot be read.")
		return
	var package_id := str(presets.get_value("preset.1.options", "package/unique_name", ""))
	if package_id == "" or "yourstudio" in package_id:
		blockers.append("Choose the permanent reverse-domain package ID before the first Play upload.")
	if int(presets.get_value("preset.1.options", "gradle_build/target_sdk", 0)) != 36:
		blockers.append("Google Play AAB must target API 36.")
	if int(presets.get_value("preset.1.options", "gradle_build/export_format", 0)) != 1:
		blockers.append("Google Play preset is not configured to export an AAB.")
	if int(presets.get_value("preset.1.options", "version/code", 0)) < 1:
		blockers.append("Release version code must be positive.")
	if str(presets.get_value("preset.1.options", "keystore/release", "")) == "":
		blockers.append("Release upload keystore has not been configured.")
	if str(presets.get_value("preset.1.options", "keystore/release_user", "")) == "":
		blockers.append("Release upload-key alias has not been configured.")
	if not bool(presets.get_value("preset.1.options", "user_data_backup/allow", true)):
		warnings.append("Release backup is disabled; profile/settings will not transfer. Active-run exclusion is still safe.")


func _check_release_assets() -> void:
	if not FileAccess.file_exists("res://docs/PRIVACY_POLICY.md"):
		blockers.append("Create the completed privacy policy from docs/PRIVACY_POLICY_TEMPLATE.md and host the same text at a public URL.")
	for asset_path: String in [
		"res://assets/store/icon_512.png",
		"res://assets/store/feature_graphic_1024x500.png",
	]:
		if not FileAccess.file_exists(asset_path):
			blockers.append("Missing Play Store asset: %s" % asset_path.trim_prefix("res://"))
	var screenshot_count := 0
	if DirAccess.dir_exists_absolute("res://assets/store/screenshots"):
		for file_name: String in DirAccess.get_files_at("res://assets/store/screenshots"):
			if file_name.get_extension().to_lower() in ["png", "jpg", "jpeg"]:
				screenshot_count += 1
	if screenshot_count < 2:
		blockers.append("Add at least two real-device screenshots under assets/store/screenshots (six are planned).")
	for license_path: String in ["res://assets/fonts/OFL-Literata.txt", "res://assets/fonts/OFL-Inter.txt", "res://docs/ASSET_PROVENANCE.md"]:
		if not FileAccess.file_exists(license_path):
			blockers.append("Missing license/provenance record: %s" % license_path.trim_prefix("res://"))
