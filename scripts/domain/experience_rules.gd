class_name ExperienceRules
extends RefCounted

const RULES_VERSION := 2
## v2 (GAMEPLAY_REVAMP_PLAN §4.2): the road pays little XP; fights pay by
## threat tier through each adversary's xp_reward.
const STARTING_LEVEL := 1
const MAX_LEVEL := 8
const JOURNEY_XP := 1
const CHECKPOINT_XP := 5
const LEVEL_THRESHOLDS := [0, 40, 88, 144, 208, 280, 360, 456]
const CHECK_BONUSES := {
	"easy": 0,
	"favorable": 1,
	"risky": 2,
	"hard": 3,
	"desperate": 5,
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
