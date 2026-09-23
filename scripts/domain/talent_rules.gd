extends RefCounted
## Run-only talents from Latest_plan Week 1.
##
## Six talents, one selection after the first region and another after the
## third. Players choose from the remaining talents, without random offers,
## duplicates, or respecs. Rules live here and in NarrativeCombat; UI only
## lists, previews, and commits through GameEngine + CombatTransaction.

const TALENT_IDS := ["retaliation", "patient_shot", "exploit_weakness", "bloodlust", "sustained_pressure", "field_medicine"]
## New runs stamp this; old saves migrate to 0 and keep previous build rules.
const TALENT_VERSION := 1
## Checkpoints (region_index at checkpoint time) granting a talent choice.
const TALENT_CHECKPOINTS := [0, 2]

const BLOODLUST_THRESHOLD := 0.6
const BLOODLUST_ACCURACY_PENALTY := 10.0
const RETALIATION_EXPOSURE := 1.5
const BASE_BLOCK_EXPOSURE := 1.25


static func talents_enabled(run_state: Dictionary) -> bool:
	return int(run_state.get("talent_version", 0)) >= TALENT_VERSION


static func owned_talents(run_state: Dictionary) -> Array:
	var owned: Array = []
	for talent_id: Variant in run_state.get("talents", []):
		if str(talent_id) in TALENT_IDS and str(talent_id) not in owned:
			owned.append(str(talent_id))
	return owned


static func has_talent(run_state: Dictionary, talent_id: String) -> bool:
	if not talents_enabled(run_state):
		return false
	return talent_id in owned_talents(run_state)


static func available_options(run_state: Dictionary) -> Array:
	var owned := owned_talents(run_state)
	var options: Array = []
	for talent_id: String in TALENT_IDS:
		if talent_id not in owned:
			options.append(talent_id)
	return options


static func expected_talent_count(region_index: int) -> int:
	var expected := 0
	for checkpoint_index: int in TALENT_CHECKPOINTS:
		if region_index >= checkpoint_index:
			expected += 1
	return mini(expected, 2)


static func talent_choice_available(game) -> bool:
	var run_state: Dictionary = game.run_state
	if run_state.is_empty() or str(run_state.get("phase", "")) != "checkpoint":
		return false
	if not talents_enabled(run_state):
		return false
	var expected := expected_talent_count(int(run_state.get("region_index", 0)))
	return owned_talents(run_state).size() < expected


static func validate_selection(game, talent_id: String) -> String:
	if not talents_enabled(game.run_state):
		return "Talents are not available for this run."
	if str(game.run_state.get("phase", "")) != "checkpoint":
		return "Talents can only be chosen at a checkpoint."
	if talent_id not in TALENT_IDS:
		return "Unknown talent."
	if talent_id in owned_talents(game.run_state):
		return "That talent is already owned."
	if talent_id not in available_options(game.run_state):
		return "That talent is not offered."
	if not talent_choice_available(game):
		return "No talent choice is available now."
	return ""


static func shield_active(game) -> bool:
	var equipment: Dictionary = game.run_state.get("survivor", {}).get("equipment", {})
	var shield: Dictionary = game.content.get_item(str(equipment.get("accessory", "")))
	var weapon: Dictionary = game.content.get_item(str(equipment.get("weapon", "")))
	return bool(shield.get("shield", false)) and not bool(weapon.get("two_handed", false))


static func execution_threshold() -> float:
	return BLOODLUST_THRESHOLD
