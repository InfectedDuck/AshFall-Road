class_name ResponsiveRules
extends RefCounted

## Thresholds are read against the 393x852 canvas artboard: at that width the
## pack grid still runs four columns beside its 56px filter rail, and all four
## equipment slots still fit one row.
const COMPACT_HEIGHT := 760.0
const FOUR_COLUMN_WIDTH := 280.0
const COMPACT_EQUIPMENT_WIDTH := 340.0
## Below this height the canvas safe areas cost more than they are worth: six
## combat actions and a guidance strip stop fitting at 360x640 with Large text.
const FULL_SAFE_AREA_HEIGHT := 700.0
## The design canvas is a 393pt column. A window wider than that gets letterboxed
## rather than stretched: a phone layout smeared across a desktop window turns
## every card into a banner and drags the eye across dead space between a label
## and its value.
const CONTENT_COLUMN_WIDTH := 393.0


static func is_compact_height(height: float) -> bool:
	return height < COMPACT_HEIGHT


## Extra inset per side that holds the page to the design column and centres it.
## Zero on any screen no wider than the column, which is every phone.
static func content_letterbox(viewport_width: float) -> int:
	return maxi(0, floori((viewport_width - CONTENT_COLUMN_WIDTH) * 0.5))


static func uses_full_safe_area(height: float) -> bool:
	return height >= FULL_SAFE_AREA_HEIGHT


static func inventory_columns(available_width: float) -> int:
	return 3 if available_width < FOUR_COLUMN_WIDTH else 4


static func equipment_slot_columns(available_width: float) -> int:
	return 2 if available_width < COMPACT_EQUIPMENT_WIDTH else 4


static func overlay_size(viewport_size: Vector2, width_ratio: float = 0.96, height_ratio: float = 0.96) -> Vector2i:
	# Minimum sheet sizes must never enlarge a popup past a short phone screen
	# (for example when the keyboard opens or the available window is reduced).
	var width := minf(viewport_size.x, CONTENT_COLUMN_WIDTH) * width_ratio
	var maximum := Vector2i(maxi(1, floori(viewport_size.x) - 8), maxi(1, floori(viewport_size.y) - 16))
	return Vector2i(
		mini(maximum.x, maxi(280, roundi(width))),
		mini(maximum.y, maxi(360, roundi(viewport_size.y * height_ratio)))
	)


## Convert the Android display's physical safe area to the stretched canvas.
## Keep a small gap inside cutouts, and ignore unavailable/invalid reports.
static func logical_safe_rect(viewport_size: Vector2, window_size: Vector2, display_safe_area: Rect2) -> Rect2:
	var viewport := Rect2(Vector2.ZERO, viewport_size)
	if window_size.x <= 0.0 or window_size.y <= 0.0 or not display_safe_area.has_area():
		return viewport
	var scale := viewport_size / window_size
	var safe := Rect2(display_safe_area.position * scale, display_safe_area.size * scale).intersection(viewport)
	if safe.size.x <= 16.0 or safe.size.y <= 16.0:
		return viewport
	return safe.grow(-8.0)


static func overlay_rect(safe_area: Rect2, width_ratio: float = 0.96, height_ratio: float = 0.96, bottom_aligned: bool = false) -> Rect2i:
	var size := overlay_size(safe_area.size, width_ratio, height_ratio)
	var position := safe_area.position + (safe_area.size - Vector2(size)) * 0.5
	if bottom_aligned:
		position.y = safe_area.end.y - float(size.y) - 8.0
	return Rect2i(Vector2i(ceili(position.x), ceili(position.y)), size)
