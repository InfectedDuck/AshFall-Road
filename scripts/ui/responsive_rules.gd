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
	# Overlays follow the same column as the page beneath them.
	var width := minf(viewport_size.x, CONTENT_COLUMN_WIDTH) * width_ratio
	return Vector2i(
		maxi(280, roundi(width)),
		maxi(360, roundi(viewport_size.y * height_ratio))
	)
