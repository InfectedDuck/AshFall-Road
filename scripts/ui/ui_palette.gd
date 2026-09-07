class_name UiPalette
extends RefCounted

## One semantic colour contract for every player-facing UI surface. Theme IDs are
## intentionally stable because they are stored in profiles and purchase records.

const REQUIRED_TOKENS := [
	"theme_id", "background", "background_tint", "scrim", "surface", "surface_overlay",
	"surface_raised", "surface_pressed", "border", "border_subtle", "text", "muted",
	"disabled", "accent", "accent_strong", "danger", "success", "critical", "fatigue",
	"radiation", "meter_track", "icon_ink", "die_surface", "die_line",
]

const DISPLAY_NAMES := {
	"default": "EMBER & PARCHMENT",
	"rust": "CINDER RUST",
	"night": "SIGNAL AT NIGHT",
}


static func create(theme_id: String, high_contrast: bool = false) -> Dictionary:
	if high_contrast:
		return {
			"theme_id": "high_contrast",
			"background": Color("#050708"), "background_tint": Color("#000000f0"), "scrim": Color("#000000e8"),
			"surface": Color("#050708"), "surface_overlay": Color("#101416f0"), "surface_raised": Color("#151b1e"), "surface_pressed": Color("#000000"),
			"border": Color("#ffffff"), "border_subtle": Color("#b9c1c4"), "text": Color("#ffffff"), "muted": Color("#e6e6e6"),
			"disabled": Color("#9ba4a8"), "accent": Color("#ffd54a"), "accent_strong": Color("#fff0a0"),
			"danger": Color("#ff7770"), "success": Color("#8cff9a"), "critical": Color("#ffe36e"),
			"fatigue": Color("#80c8ff"), "radiation": Color("#dbff70"), "meter_track": Color("#252b2e"),
			"icon_ink": Color("#f0f0f0"), "die_surface": Color("#101416"), "die_line": Color("#6f7b80"),
		}
	match theme_id:
		"rust":
			return {
				"theme_id": "rust",
				"background": Color("#160c09"), "background_tint": Color("#160604dc"), "scrim": Color("#090403d9"),
				"surface": Color("#21130f"), "surface_overlay": Color("#21130fe8"), "surface_raised": Color("#34201a"), "surface_pressed": Color("#180d0a"),
				"border": Color("#654337"), "border_subtle": Color("#49342d"), "text": Color("#f8e7d2"), "muted": Color("#c2aaa0"),
				"disabled": Color("#806a63"), "accent": Color("#e47745"), "accent_strong": Color("#f2a665"),
				"danger": Color("#df6c5e"), "success": Color("#8db780"), "critical": Color("#f0b35d"),
				"fatigue": Color("#88a6b1"), "radiation": Color("#b5be69"), "meter_track": Color("#3d2923"),
				"icon_ink": Color("#dcc7b8"), "die_surface": Color("#2c1913"), "die_line": Color("#8e6655"),
			}
		"night":
			return {
				"theme_id": "night",
				"background": Color("#08111f"), "background_tint": Color("#020713e0"), "scrim": Color("#01040cdb"),
				"surface": Color("#101c2b"), "surface_overlay": Color("#101c2bea"), "surface_raised": Color("#17293d"), "surface_pressed": Color("#0b1421"),
				"border": Color("#3d6083"), "border_subtle": Color("#2c4661"), "text": Color("#eaf1f3"), "muted": Color("#a9bac4"),
				"disabled": Color("#677a8b"), "accent": Color("#7eb8db"), "accent_strong": Color("#b7e0f2"),
				"danger": Color("#d96d68"), "success": Color("#79bf9c"), "critical": Color("#e0ba72"),
				"fatigue": Color("#80a6d4"), "radiation": Color("#a8be65"), "meter_track": Color("#1d3045"),
				"icon_ink": Color("#c7d5db"), "die_surface": Color("#14243a"), "die_line": Color("#6788aa"),
			}
		_:
			# Ember & Parchment, straight off the Ashfall Road design canvas. The
			# scrim tokens carry their design alpha: `surface_overlay` is the 72%
			# plate that sits between a region backdrop and the page.
			return {
				"theme_id": "default",
				"background": Color("#0b1415"), "background_tint": Color("#0b1415b8"), "scrim": Color("#0b1415db"),
				"surface": Color("#111d1e"), "surface_overlay": Color("#0b1415b8"), "surface_raised": Color("#182627"), "surface_pressed": Color("#0d1718"),
				"border": Color("#2a3a3b"), "border_subtle": Color("#1e2c2d"), "text": Color("#f4ebdd"), "muted": Color("#9a9487"),
				"disabled": Color("#5c5a53"), "accent": Color("#d9a458"), "accent_strong": Color("#f0c070"),
				"danger": Color("#d9695b"), "success": Color("#86b07a"), "critical": Color("#f2d27a"),
				"fatigue": Color("#6e93b8"), "radiation": Color("#8a9a4e"), "meter_track": Color("#1c2a2b"),
				"icon_ink": Color("#c9bfae"), "die_surface": Color("#1a2829"), "die_line": Color("#d9a458"),
			}


static func display_name(theme_id: String) -> String:
	return str(DISPLAY_NAMES.get(theme_id, DISPLAY_NAMES["default"]))


static func has_all_tokens(palette: Dictionary) -> bool:
	for key: String in REQUIRED_TOKENS:
		if not palette.has(key):
			return false
	return true


static func contrast_ratio(first: Color, second: Color) -> float:
	var bright := maxf(_relative_luminance(first), _relative_luminance(second))
	var dark := minf(_relative_luminance(first), _relative_luminance(second))
	return (bright + 0.05) / (dark + 0.05)


static func _relative_luminance(color: Color) -> float:
	var channels := [color.r, color.g, color.b]
	var linear: Array[float] = []
	for channel: float in channels:
		linear.append(channel / 12.92 if channel <= 0.03928 else pow((channel + 0.055) / 1.055, 2.4))
	return 0.2126 * linear[0] + 0.7152 * linear[1] + 0.0722 * linear[2]
