class_name ExperienceRules
extends RefCounted

const RULES_VERSION := 1
const STARTING_LEVEL := 1
const MAX_LEVEL := 8
const JOURNEY_XP := 4
const CHECKPOINT_XP := 10
const LEVEL_THRESHOLDS := [0, 50, 110, 180, 260, 350, 450, 570]
const CHECK_BONUSES := {
	"easy": 0,
	"favorable": 2,
	"risky": 4,
	"hard": 7,
	"desperate": 10,
}


static func level_for_xp(total_xp: int) -> int:
	var safe_xp := maxi(0, total_xp)
	var level := STARTING_LEVEL
	for index in range(1, LEVEL_THRESHOLDS.size()):
		if safe_xp < int(LEVEL_THRESHOLDS[index]):
			break
		level = index + 1
	return mini(level, MAX_LEVEL)


static func threshold_for_level(level: int) -> int:
	var safe_level := clampi(level, STARTING_LEVEL, MAX_LEVEL)
	return int(LEVEL_THRESHOLDS[safe_level - 1])


static func next_threshold(level: int) -> int:
	if level >= MAX_LEVEL:
		return int(LEVEL_THRESHOLDS.back())
	return threshold_for_level(level + 1)


static func check_bonus(difficulty: String) -> int:
	return int(CHECK_BONUSES.get(difficulty, 0))


static func progress(total_xp: int) -> Dictionary:
	var safe_xp := maxi(0, total_xp)
	var level := level_for_xp(safe_xp)
	var floor_xp := threshold_for_level(level)
	var ceiling_xp := next_threshold(level)
	return {
		"level": level,
		"experience": safe_xp,
		"current_floor": floor_xp,
		"next_threshold": ceiling_xp,
		"into_level": safe_xp - floor_xp,
		"level_span": maxi(0, ceiling_xp - floor_xp),
		"at_max_level": level >= MAX_LEVEL,
	}
