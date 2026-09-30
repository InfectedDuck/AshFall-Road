extends Control

const SoundServiceScript = preload("res://scripts/services/sound_service.gd")
const SurvivorHudScript = preload("res://scripts/ui/survivor_hud.gd")
const DiceWidgetScript = preload("res://scripts/ui/dice_widget.gd")
const StoryTypewriterScript = preload("res://scripts/ui/story_typewriter.gd")
const StatsCapsuleScript = preload("res://scripts/ui/stats_capsule.gd")
const PressureStripScript = preload("res://scripts/ui/pressure_strip.gd")
const ItemIconScript = preload("res://scripts/ui/item_icon.gd")
const UiIconScript = preload("res://scripts/ui/ui_icon.gd")
const EquipmentComparisonScript = preload("res://scripts/domain/equipment_comparison.gd")
const ResponsiveRulesScript = preload("res://scripts/ui/responsive_rules.gd")
const UiPaletteScript = preload("res://scripts/ui/ui_palette.gd")
const CombatPresentationScript = preload("res://scripts/ui/combat_presentation.gd")
const PortraitArtScript = preload("res://scripts/ui/portrait_art.gd")
const StoryDiscoveryScript = preload("res://scripts/domain/story_discovery.gd")
const UiTypeScript = preload("res://scripts/ui/ui_type.gd")
const AtmosphereLayersScript = preload("res://scripts/ui/atmosphere_layers.gd")
const TouchScrollContainerScript = preload("res://scripts/ui/touch_scroll_container.gd")

## Leave more of a phone screen for reading. Hardware safe areas are applied
## separately; decorative padding must not duplicate the system's insets.
const SAFE_AREA_TOP := 24
const SAFE_AREA_BOTTOM := 20
const SAFE_AREA_SIDE := 12
const SAFE_AREA_TOP_COMPACT := 12
const SAFE_AREA_BOTTOM_COMPACT := 12
const CORNER_RADIUS := 0
const ACTION_HEIGHT := 48
const TOUCH_TARGET := 44
const FOCUS_RING_WIDTH := 2
const FOCUS_RING_OFFSET := 2
const REVEAL_DIE_SIZE := 168
const VERDICT_DOT_SIZE := 6
const SCROLLBAR_GUTTER := 12

var content: ContentRepository
var game: GameEngine
var saves: SaveService
var ads: AdService
var billing: BillingService
var sound: Node
var profile: Dictionary = {}
var entitlements: Dictionary = {}
var candidates: Array = []
var candidate_seed := 1
var monetization_enabled := false

var background: TextureRect
var atmosphere: AtmosphereLayers
var content_margin: MarginContainer
var page: VBoxContainer
var inventory_popup: PopupPanel
var settings_popup: PopupPanel
var tutorial_popup: PopupPanel
var recap_popup: PopupPanel
var chronicle_tab := "runs"
var tip_banner: PanelContainer
var tip_body: VBoxContainer
var active_tip_id := ""
var store_popup: PopupPanel
var action_popup: PopupPanel
var level_popup: PopupPanel
var item_detail_popup: PopupPanel
var confirmation_popup: PopupPanel
var stat_details_popup: PopupPanel
var conditions_popup: PopupPanel
var save_recovery_popup: PopupPanel
var save_recovery_label: Label
var save_success_callback: Callable
var event_committing := false
var stat_draft: Dictionary = {}
var allocation_remaining_label: Label
var allocation_confirm_button: Button
var allocation_stat_controls: Dictionary = {}
var toast_label: Label
var active_story: StoryTypewriter
var active_story_actions: Control
var active_story_key := ""
var active_combat_presentation: Control
var story_reveal_cache: Dictionary = {}
var inventory_filter := "all"
var inventory_scroll_offset := 0
var bootstrap_on_ready := true
var palette: Dictionary = {}
# Compatibility aliases keep legacy widget call sites semantic while their values
# are refreshed exclusively from UiPalette whenever the player switches theme.
var COLOR_TEXT := Color.WHITE
var COLOR_MUTED := Color.WHITE
var COLOR_DANGER := Color.WHITE
var COLOR_SUCCESS := Color.WHITE
var COLOR_CRITICAL := Color.WHITE
var COLOR_FATIGUE := Color.WHITE
var COLOR_RADIATION := Color.WHITE


func _ready() -> void:
	if not bootstrap_on_ready:
		return
	if OS.has_feature("android"):
		# Match the portrait phone's width so shorter displays get a shorter
		# logical viewport and activate the compact layout instead of side bars.
		get_window().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP_WIDTH
	get_tree().quit_on_go_back = false
	content = ContentRepository.new()
	saves = SaveService.new()
	game = GameEngine.new(content)
	profile = saves.load_profile()
	entitlements = saves.load_entitlements()
	monetization_enabled = bool(ProjectSettings.get_setting("ashfall/release/monetization_enabled", false))
	ads = AdService.new()
	ads.configure(entitlements, monetization_enabled)
	billing = BillingService.new()
	billing.configure(entitlements, monetization_enabled)
	sound = SoundServiceScript.new()
	add_child(sound)
	sound.configure(profile)
	_build_shell()
	var errors := content.validate_all()
	if not errors.is_empty():
		_show_content_error(errors)
		return
	var recovery: Dictionary = combat_transaction.recover(game, saves, profile)
	_accept_action_result(recovery, _after_startup_recovery)


func _after_startup_recovery(_result: Dictionary) -> void:
	if str(profile.get("selected_theme", "default")) not in _available_themes():
		_commit_profile_changes({"selected_theme": "default"})
	if not game.run_state.is_empty():
		_render_current()
	else:
		_show_main_menu()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_active_run()
	elif what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_handle_back()


func _build_shell() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background = TextureRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	# Scrim, firelight, vignette and grain sit between the region plate and the
	# page, exactly as the canvas stacks them. Screens pick a mix, not colours.
	atmosphere = AtmosphereLayersScript.new()
	atmosphere.name = "Atmosphere"
	add_child(atmosphere)

	content_margin = MarginContainer.new()
	content_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(content_margin)

	var shell_column := VBoxContainer.new()
	shell_column.add_theme_constant_override("separation", 8)
	content_margin.add_child(shell_column)

	page = VBoxContainer.new()
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_theme_constant_override("separation", 8)
	shell_column.add_child(page)

	# Contextual guidance lives beside the page rather than over it: it never
	# covers an action, and _clear_page() cannot destroy it mid-screen.
	tip_banner = PanelContainer.new()
	tip_banner.name = "ContextualTipBanner"
	tip_banner.visible = false
	shell_column.add_child(tip_banner)
	tip_body = VBoxContainer.new()
	tip_body.add_theme_constant_override("separation", 5)
	tip_banner.add_child(tip_body)

	toast_label = Label.new()
	toast_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	toast_label.offset_left = SAFE_AREA_SIDE
	toast_label.offset_right = -SAFE_AREA_SIDE
	toast_label.offset_top = -100
	toast_label.offset_bottom = -24
	toast_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	toast_label.visible = false
	add_child(toast_label)
	_apply_theme()
	_apply_safe_area()
	get_viewport().size_changed.connect(_apply_safe_area)


func _apply_safe_area() -> void:
	# Reserve hardware cutouts once, while keeping page padding modest.
	var compact := not ResponsiveRulesScript.uses_full_safe_area(get_viewport_rect().size.y)
	# A window wider than the design column is letterboxed, not stretched.
	var letterbox := ResponsiveRulesScript.content_letterbox(get_viewport_rect().size.x)
	var left := SAFE_AREA_SIDE + letterbox
	var right := SAFE_AREA_SIDE + letterbox
	var top := SAFE_AREA_TOP_COMPACT if compact else SAFE_AREA_TOP
	var bottom := SAFE_AREA_BOTTOM_COMPACT if compact else SAFE_AREA_BOTTOM
	var safe := _device_safe_rect()
	var logical_size := get_viewport_rect().size
	left = maxi(left, ceili(safe.position.x))
	top = maxi(top, ceili(safe.position.y))
	right = maxi(right, ceili(logical_size.x - safe.end.x))
	bottom = maxi(bottom, ceili(logical_size.y - safe.end.y))
	content_margin.add_theme_constant_override("margin_left", left)
	content_margin.add_theme_constant_override("margin_right", right)
	content_margin.add_theme_constant_override("margin_top", top)
	content_margin.add_theme_constant_override("margin_bottom", bottom)


func _device_safe_rect() -> Rect2:
	var logical_size := get_viewport_rect().size
	if not OS.has_feature("android"):
		return Rect2(Vector2.ZERO, logical_size)
	return ResponsiveRulesScript.logical_safe_rect(logical_size, Vector2(DisplayServer.window_get_size()), Rect2(DisplayServer.get_display_safe_area()))


func _apply_theme() -> void:
	var ui_theme := Theme.new()
	var font_scale := float(profile.get("font_scale", 1.0))
	var base_size := int(16 * font_scale)
	var high_contrast := bool(profile.get("high_contrast", false))
	palette = UiPaletteScript.create(str(profile.get("selected_theme", "default")), high_contrast)
	COLOR_TEXT = palette["text"]
	COLOR_MUTED = palette["muted"]
	COLOR_DANGER = palette["danger"]
	COLOR_SUCCESS = palette["success"]
	COLOR_CRITICAL = palette["critical"]
	COLOR_FATIGUE = palette["fatigue"]
	COLOR_RADIATION = palette["radiation"]
	var text_color: Color = palette["text"]
	var panel_color: Color = palette["surface"]
	var accent: Color = palette["accent"]
	var panel_alt: Color = palette["surface_raised"]
	var interface_font: Font = UiTypeScript.base_font("title")
	ui_theme.default_font = interface_font
	ui_theme.set_default_font_size(base_size)
	ui_theme.set_color("font_color", "Label", text_color)
	ui_theme.set_color("font_color", "Button", text_color)
	ui_theme.set_color("font_hover_color", "Button", palette["accent_strong"])
	ui_theme.set_color("font_pressed_color", "Button", palette["text"])
	# The theme keeps buttons on the untracked face. Tracking belongs to the
	# canvas "action" voice, which _button applies to full-width actions only;
	# baking it here would stretch every 11px utility chip along with them.
	ui_theme.set_font("font", "Button", interface_font)
	ui_theme.set_font_size("font_size", "Button", UiTypeScript.size("action", font_scale))
	ui_theme.set_font_size("font_size", "Label", base_size)
	ui_theme.set_font_size("font_size", "RichTextLabel", base_size)
	ui_theme.set_constant("outline_size", "Label", 2 if high_contrast else 0)
	ui_theme.set_color("font_outline_color", "Label", palette["background"])
	ui_theme.set_stylebox("normal", "Button", _style_box(panel_alt, palette["border"], CORNER_RADIUS, 1))
	ui_theme.set_stylebox("hover", "Button", _style_box(panel_alt, accent, CORNER_RADIUS, 1))
	ui_theme.set_stylebox("pressed", "Button", _style_box(palette["surface_pressed"], accent, CORNER_RADIUS, 1))
	ui_theme.set_stylebox("disabled", "Button", _style_box(palette["surface_pressed"], palette["border_subtle"], CORNER_RADIUS, 1))
	ui_theme.set_stylebox("focus", "Button", _focus_ring())
	ui_theme.set_color("font_disabled_color", "Button", palette["disabled"])
	ui_theme.set_stylebox("panel", "PanelContainer", _style_box(panel_color, palette["border_subtle"], CORNER_RADIUS, 1))
	ui_theme.set_stylebox("panel", "PopupPanel", _style_box(panel_color, palette["border"], CORNER_RADIUS, 1))
	theme = ui_theme
	if atmosphere != null:
		atmosphere.configure(palette, atmosphere.preset_name())


func _accent_color() -> Color:
	return palette["accent"]


func _panel_alt_color() -> Color:
	return palette["surface_raised"]


func _c(token: String) -> Color:
	return palette[token]


func _style_box(fill: Color, border: Color, radius: int = CORNER_RADIUS, width: int = 1) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(radius)
	box.content_margin_left = 10
	box.content_margin_right = 10
	box.content_margin_top = 8
	box.content_margin_bottom = 8
	return box


## The canvas focus state is an outline *outside* the control with a 2px gap, not
## a recoloured border: the button keeps its resting fill and nothing reflows.
func _focus_ring() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.draw_center = false
	box.border_color = _c("accent_strong")
	box.set_border_width_all(FOCUS_RING_WIDTH)
	box.set_corner_radius_all(CORNER_RADIUS)
	box.set_expand_margin_all(FOCUS_RING_OFFSET + FOCUS_RING_WIDTH)
	return box


## Give a control one of the canvas type roles, scaled by the player's setting.
func _type(control: Control, role: String, override: String = "font") -> void:
	UiTypeScript.apply(control, role, float(profile.get("font_scale", 1.0)), override)


func _type_size(role: String) -> int:
	return UiTypeScript.size(role, float(profile.get("font_scale", 1.0)))


## A label in a named canvas role, with comfortable extra leading for prose.
func _role_label(text: String, role: String, color: Color = Color(0, 0, 0, 0)) -> Label:
	var label := _label(text, 0, color)
	_type(label, role)
	if not UiTypeScript.wraps(role):
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
	var leading := UiTypeScript.line_spacing(role, float(profile.get("font_scale", 1.0)))
	if leading > 0:
		label.add_theme_constant_override("line_spacing", leading)
	return label


## Eyebrows are the canvas's screen-locator: 11px Inter, uppercase, 0.22em tracked.
func _eyebrow(text: String, color: Color = Color(0, 0, 0, 0)) -> Label:
	return _role_label(text.to_upper(), "eyebrow", color if color.a > 0.0 else _c("muted"))


## Largest wordmark size, tracking included, that still sets on one line inside
## the page. Never grows past the canvas size, only shrinks toward it.
func _fitted_wordmark_size(lettering: String) -> int:
	var font_scale := float(profile.get("font_scale", 1.0))
	var available := minf(get_viewport_rect().size.x, ResponsiveRulesScript.CONTENT_COLUMN_WIDTH) - float(SAFE_AREA_SIDE * 2)
	var size := UiTypeScript.size("wordmark", font_scale)
	while size > 12:
		var face := UiTypeScript.font("wordmark", UiTypeScript.scale_for_size("wordmark", size))
		if face.get_string_size(lettering, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x <= available:
			break
		size -= 1
	return size


## Canvas verdict: a filled dot the size of the tracking, then the outcome in
## uppercase. The dot is what makes the colour legible to players who cannot
## separate the success green from the danger red.
func _verdict_row(outcome: String, color: Color) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	var dot := ColorRect.new()
	dot.color = color
	dot.custom_minimum_size = Vector2(VERDICT_DOT_SIZE, VERDICT_DOT_SIZE)
	dot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(dot)
	row.add_child(_role_label(_verdict_text(outcome), "eyebrow", color))
	return row


func _verdict_text(outcome: String) -> String:
	match outcome:
		"critical_success": return "CRITICAL SUCCESS"
		"critical_failure": return "CRITICAL FAILURE"
		"success": return "SUCCESS"
		_: return "FAILURE"


## A padded column inside a ScrollContainer. Godot draws the vertical scrollbar
## over the content, so right-aligned values need it held off the edge.
func _scroll_column(scroll: ScrollContainer, separation: int = 10) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_right", SCROLLBAR_GUTTER)
	scroll.add_child(margin)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", separation)
	margin.add_child(column)
	return column


## One row of the canvas run ledger: muted label left, value right, closed by
## the same hairline that separates every other list in the design.
func _ledger_row(parent: Node, label_text: String, value_text: String) -> void:
	var row := PanelContainer.new()
	var rule := StyleBoxFlat.new()
	rule.draw_center = false
	rule.border_color = _c("border_subtle")
	rule.border_width_bottom = 1
	rule.content_margin_top = 8
	rule.content_margin_bottom = 8
	row.add_theme_stylebox_override("panel", rule)
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 12)
	row.add_child(line)
	var name_label := _role_label(label_text, "body", _c("muted"))
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_child(name_label)
	var value := _role_label(value_text, "body", _c("icon_ink"))
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.add_child(value)
	parent.add_child(row)


## The canvas marks permadeath with a rotated danger square beside the sentence,
## so the warning does not rest on the red alone.
func _permadeath_notice(xp_lost: int) -> HBoxContainer:
	var notice := HBoxContainer.new()
	notice.add_theme_constant_override("separation", 10)
	var marker := _role_label("◆", "body", _c("danger"))
	marker.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	notice.add_child(marker)
	var copy := _role_label("Progression is gone. Levels, stats and the pack do not carry forward. %d run XP was lost to permadeath, and the run is recorded in the Road Chronicle." % xp_lost, "body")
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notice.add_child(copy)
	return notice


## Atmosphere is chosen per screen, never per colour. Safe to call before the
## shell exists so screen builders need no guard of their own.
func _set_atmosphere(preset: String) -> void:
	if atmosphere != null:
		atmosphere.configure(palette, preset)


func _apply_meter_style(bar: ProgressBar, fill: Color) -> void:
	bar.add_theme_stylebox_override("background", _meter_box(_c("meter_track")))
	bar.add_theme_stylebox_override("fill", _meter_box(fill))


func _meter_box(fill: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.set_corner_radius_all(CORNER_RADIUS)
	return box


func _clear_page() -> void:
	active_story = null
	active_story_actions = null
	active_story_key = ""
	active_combat_presentation = null
	_hide_contextual_tip()
	for child: Node in page.get_children():
		page.remove_child(child)
		child.queue_free()
	background.texture = null


## The canvas heads every screen the same way: a tracked uppercase eyebrow that
## says where you are, then a Literata lede that says what is being asked. The
## big lettering is reserved for the wordmark on the title screen.
func _title(text: String, subtitle: String = "", centered: bool = false) -> void:
	var alignment := HORIZONTAL_ALIGNMENT_CENTER if centered else HORIZONTAL_ALIGNMENT_LEFT
	var heading := _eyebrow(text)
	heading.horizontal_alignment = alignment
	page.add_child(heading)
	if subtitle != "":
		var sub := _role_label(subtitle, "lede")
		sub.horizontal_alignment = alignment
		page.add_child(sub)


## Title-screen lettering: 0.42em of tracking opens the word out across the plate.
## The trailing space keeps the last letter's tracking from pulling the line off
## centre, the way the canvas pads the wordmark by one em. Tracking that wide can
## overrun a narrow screen, and the wordmark is one line by design, so it steps
## the size down until it fits rather than wrapping.
func _wordmark(text: String, tagline: String = "") -> void:
	var lettering := "%s " % text.to_upper()
	var fitted := _fitted_wordmark_size(lettering)
	var mark := _role_label(lettering, "wordmark")
	mark.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Size and face together: tracking has to shrink with the lettering, or the
	# fitted size still overruns on the very letter-spacing it was fitted around.
	mark.add_theme_font_size_override("font_size", fitted)
	mark.add_theme_font_override("font", UiTypeScript.font("wordmark", UiTypeScript.scale_for_size("wordmark", fitted)))
	page.add_child(mark)
	if tagline != "":
		var line := _role_label(tagline, "flavour", _c("icon_ink"))
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		page.add_child(line)


func _label(text: String, size: int = 0, color: Color = Color(0, 0, 0, 0)) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", _c("text") if color.a <= 0.0 else color)
	if size > 0:
		label.add_theme_font_size_override("font_size", int(size * float(profile.get("font_scale", 1.0))))
	return label


func _button(text: String, callable: Callable, disabled: bool = false, allow_recovery: bool = false) -> Button:
	var button := Button.new()
	button.text = text.to_upper()
	button.custom_minimum_size.y = ACTION_HEIGHT
	button.disabled = disabled
	_type(button, "action")
	# A tracked uppercase action can outrun 353pt of content width. Wrapping it
	# keeps the page at artboard width instead of pushing every other screen
	# element off the right edge.
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.clip_text = false
	button.pressed.connect(func() -> void:
		if _gameplay_locked() and not allow_recovery:
			return
		if sound != null:
			sound.play_ui()
		callable.call()
	)
	return button


func _icon_button(glyph: String, description: String, callable: Callable, atlas_icon_id: String = "") -> Button:
	var button := _button(glyph, callable)
	button.text = "" if atlas_icon_id != "" else glyph
	button.custom_minimum_size = Vector2(TOUCH_TARGET, TOUCH_TARGET)
	button.tooltip_text = description
	button.accessibility_name = description
	# Glyphs are drawn, not spoken: no uppercasing, no action tracking.
	button.add_theme_font_override("font", UiTypeScript.base_font("title"))
	button.add_theme_font_size_override("font_size", int(19 * float(profile.get("font_scale", 1.0))))
	button.add_theme_color_override("font_color", _c("icon_ink"))
	var bare := _style_box(Color.TRANSPARENT, Color.TRANSPARENT)
	bare.set_content_margin_all(0)
	button.add_theme_stylebox_override("normal", bare)
	var touched := bare.duplicate()
	touched.draw_center = true
	touched.bg_color = _c("surface_raised")
	button.add_theme_stylebox_override("hover", touched)
	button.add_theme_stylebox_override("pressed", touched)
	if atlas_icon_id != "":
		_add_button_atlas_icon(button, atlas_icon_id, true)
	return button


func _add_button_atlas_icon(button: Button, icon_id: String, centered: bool = false) -> void:
	var icon := UiIconScript.new()
	icon.name = "%sIcon" % icon_id.capitalize()
	var icon_size := int(18 * float(profile.get("font_scale", 1.0)))
	icon.configure(icon_id, icon_size, _c("icon_ink"))
	icon.set_anchors_preset(Control.PRESET_CENTER if centered else Control.PRESET_CENTER_LEFT)
	icon.position = Vector2(-float(icon_size) * 0.5, -float(icon_size) * 0.5) if centered else Vector2(10, -float(icon_size) * 0.5)
	button.add_child(icon)


func _overlay_header(title_text: String, close_callable: Callable) -> HBoxContainer:
	var header := HBoxContainer.new()
	var title_label := _eyebrow(title_text)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(title_label)
	header.add_child(_icon_button("×", "Close", close_callable))
	return header


func _popup_body(popup: PopupPanel, margin_size: int = 10) -> VBoxContainer:
	var margin := MarginContainer.new()
	# Follow the popup's viewport-sized rectangle. Otherwise tall content can
	# push pinned actions below the phone screen while the popup stays in place.
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_%s" % side, margin_size)
	popup.add_child(margin)
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 8)
	margin.add_child(body)
	return body


func _popup_center_responsive(popup: PopupPanel, width_ratio: float = 0.96, height_ratio: float = 0.96) -> void:
	var rect := ResponsiveRulesScript.overlay_rect(_device_safe_rect(), width_ratio, height_ratio)
	popup.popup_centered(rect.size)
	popup.size = rect.size
	popup.position = rect.position
	# PopupPanel can reconsider its child minimum on the next layout pass. Pin
	# the safe viewport again after that pass; readers within the sheet scroll.
	popup.set_deferred("size", rect.size)
	popup.set_deferred("position", rect.position)


func _popup_bottom_responsive(popup: PopupPanel, width_ratio: float = 0.92, height_ratio: float = 0.66) -> void:
	var rect := ResponsiveRulesScript.overlay_rect(_device_safe_rect(), width_ratio, height_ratio, true)
	popup.popup_centered(rect.size)
	popup.size = rect.size
	popup.position = rect.position
	popup.set_deferred("size", rect.size)
	popup.set_deferred("position", rect.position)


func _panel() -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 10)
	panel.add_child(body)
	page.add_child(panel)
	return body


func _show_main_menu() -> void:
	if _gameplay_locked():
		return
	_clear_page()
	_set_atmosphere("title")
	var utilities := HBoxContainer.new()
	utilities.alignment = BoxContainer.ALIGNMENT_END
	utilities.add_child(_icon_button("⚙", "Open settings", _show_settings, "settings"))
	page.add_child(utilities)
	# The canvas title screen holds the wordmark a third of the way down and lets
	# the whole action stack fall to the bottom edge, with no plate behind it.
	var lede_spacer := Control.new()
	lede_spacer.custom_minimum_size.y = 48 if ResponsiveRulesScript.is_compact_height(get_viewport_rect().size.y) else 80
	page.add_child(lede_spacer)
	_wordmark("Ashfall Road", "Walk until the road ends.")
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(spacer)
	var actions := VBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	page.add_child(actions)
	if not game.run_state.is_empty() and str(game.run_state.get("status", "")) == "active":
		actions.add_child(_button("Continue", _continue_run))
		var survivor: Dictionary = game.run_state.get("survivor", {})
		var carry := _role_label("%s \"%s\" · Region %d of 6" % [survivor.get("name", "Survivor"), survivor.get("callsign", ""), int(game.run_state.get("region_index", 0)) + 1], "label", _c("muted"))
		carry.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		carry.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		actions.add_child(carry)
	else:
		actions.add_child(_button("New run", _begin_candidate_selection))
	var chronicle_button := _button("   Road chronicle", _show_road_chronicle.bind(""))
	_add_button_atlas_icon(chronicle_button, "chronicle")
	actions.add_child(chronicle_button)
	var about := _button("About & privacy", _show_about)
	about.custom_minimum_size.y = TOUCH_TARGET
	about.add_theme_color_override("font_color", _c("muted"))
	about.add_theme_stylebox_override("normal", _style_box(Color.TRANSPARENT, Color.TRANSPARENT))
	actions.add_child(about)
	var stats_text := "%d runs · %d deaths · %d victories" % [profile.get("runs_started", 0), profile.get("deaths", 0), profile.get("victories", 0)]
	var stats := _role_label(stats_text, "caption", _c("disabled"))
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(stats)


func _begin_candidate_selection() -> void:
	if _gameplay_locked():
		return
	candidate_seed = int(Time.get_unix_time_from_system()) + Time.get_ticks_msec()
	candidates = game.create_candidates(candidate_seed)
	_show_candidates()


func _show_candidates() -> void:
	_clear_page()
	_set_atmosphere("survivor")
	_title("Three came to the fire", "Each carries 15 points of themselves. Pick who walks.")
	var scroll := TouchScrollContainerScript.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 12)
	scroll.add_child(list)
	for index in range(candidates.size()):
		var candidate: Dictionary = candidates[index]
		var card := PanelContainer.new()
		var card_body := VBoxContainer.new()
		card_body.add_theme_constant_override("separation", 7)
		card.add_child(card_body)
		var identity_row := HBoxContainer.new()
		identity_row.add_theme_constant_override("separation", 10)
		var candidate_portrait := PortraitArtScript.create_view(str(candidate.get("portrait_id", "survivor")), _c("muted"), 8)
		candidate_portrait.custom_minimum_size = Vector2(56, 56)
		identity_row.add_child(candidate_portrait)
		var identity_details := VBoxContainer.new()
		identity_details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		# Canvas survivor card: the name is prose, not accent. Accent on three
		# cards at once would spend the whole screen's budget on decoration.
		var candidate_name := _role_label("%s \"%s\"" % [candidate["name"], candidate["callsign"]], "title")
		candidate_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		identity_details.add_child(candidate_name)
		var stat_parts: Array[String] = []
		for stat: String in GameEngine.STATS:
			stat_parts.append("%s %d" % [_stat_glyph(stat), candidate["stats"][stat]])
		var candidate_stats := _role_label("   ".join(stat_parts), "body", _c("icon_ink"))
		candidate_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		identity_details.add_child(candidate_stats)
		identity_row.add_child(identity_details)
		card_body.add_child(identity_row)
		var gear_names: Array[String] = []
		for item_id: String in candidate["inventory"]:
			if str(content.get_item(item_id).get("equipment_slot", "")) != "":
				gear_names.append(str(content.get_item(item_id).get("name", item_id)))
		card_body.add_child(_role_label("Starting gear: %s" % ", ".join(gear_names), "flavour", _c("icon_ink")))
		var starting_weapon: Dictionary = content.get_item(str(candidate["equipment"].get("weapon", "")))
		var signature := _role_label(_weapon_signature_text(starting_weapon, candidate["stats"]), "caption", _c("muted"))
		signature.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card_body.add_child(signature)
		card_body.add_child(_button("Walk as %s" % candidate["callsign"], _select_candidate.bind(index)))
		list.add_child(card)
	page.add_child(_button("Back", _show_main_menu))


func _select_candidate(index: int) -> void:
	if _gameplay_locked():
		return
	if index < 0 or index >= candidates.size():
		return
	var before := game.run_state.duplicate(true)
	game.start_run(candidates[index], candidate_seed + index * 37)
	# Later runs remember what no single survivor could: a witnessed betrayal
	# opens Tess and Mina as alternative companions for this fresh life.
	game.apply_cross_run_unlocks(profile.get("discovered_story_nodes", []))
	if not saves.save_run(game.run_state):
		game.restore_run(before)
		_show_toast("Could not save the new run. Free some storage and try again.")
		return
	_commit_profile_changes({"runs_started": int(profile.get("runs_started", 0)) + 1})
	ads.reset_for_run()
	_render_current()
	# Contextual tips replace the first-run wall. The full reference is still one
	# tap away under Settings → HOW TO PLAY.


func _render_current() -> void:
	if _gameplay_locked():
		return
	if game.run_state.is_empty():
		_show_main_menu()
		return
	match str(game.run_state.get("phase", "event")):
		"event": _show_event()
		"resolving", "roll_pending": _show_event_roll()
		"combat": _show_combat()
		"combat_roll_pending": _show_combat_roll()
		"result": _show_result()
		"checkpoint": _show_checkpoint()
		"death": _finish_run(false)
		"victory": _finish_run(true)
		_: _show_event()
	_focus_first_action()


## Keyboard users land on the first available action of every fresh page, so
## Enter activates and the canvas focus ring shows where. Mouse and touch are
## unaffected: tapping any control moves focus there as before. Scrolling with
## the mouse wheel is native to the scroll containers on desktop.
func _focus_first_action() -> void:
	# Touch layouts keep their measured geometry: the focus ring draws outside
	# the control, so only keyboard-first devices take an initial focus.
	if page == null or DisplayServer.is_touchscreen_available():
		return
	var first := _find_first_action(page)
	if first != null:
		(first as Button).grab_focus()


func _find_first_action(node: Node) -> Button:
	if node is Button:
		var button := node as Button
		if button.visible and not button.disabled and button.focus_mode != Control.FOCUS_NONE:
			return button
	for child: Node in node.get_children():
		var found := _find_first_action(child)
		if found != null:
			return found
	return null


func _set_region_background() -> void:
	var region := game.current_region()
	var is_final := int(game.run_state.get("region_index", 0)) >= content.ordered_regions().size()
	var path := "res://assets/backgrounds/region_7_citadel.png" if is_final else str(region.get("background", ""))
	if path != "" and ResourceLoader.exists(path):
		background.texture = load(path)


func _show_event() -> void:
	_clear_page()
	_set_atmosphere("event")
	_set_region_background()
	var region := game.current_region()
	var is_final := int(game.run_state.get("region_index", 0)) >= content.ordered_regions().size()
	var region_name := "EAST CITADEL" if is_final else str(region.get("name", "The Road"))
	_show_survival_strip()
	var breadcrumb := HBoxContainer.new()
	var breadcrumb_label := _label(region_name.to_upper(), 11, _c("muted"))
	breadcrumb_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	breadcrumb.add_child(breadcrumb_label)
	breadcrumb.add_child(_role_label("◆ ◆ ◆" if is_final else _journey_pips(int(game.run_state.get("events_in_region", 0))), "eyebrow", _accent_color()))
	page.add_child(breadcrumb)
	var event := game.current_event()
	var event_panel := VBoxContainer.new()
	event_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	event_panel.add_theme_constant_override("separation", 10)
	page.add_child(event_panel)
	# Story and choices share one natural phone-scrolling surface. This keeps the
	# decision block directly after the prose instead of pinning it to the bottom.
	var text_scroll := TouchScrollContainerScript.new()
	text_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	text_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	text_scroll.scroll_deadzone = 10
	event_panel.add_child(text_scroll)
	var story_stack := VBoxContainer.new()
	story_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	story_stack.add_theme_constant_override("separation", 12)
	text_scroll.add_child(story_stack)
	var narrative = StoryTypewriterScript.new()
	narrative.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_type(narrative, "prose", "normal_font")
	narrative.add_theme_color_override("default_color", _c("text"))
	narrative.add_theme_constant_override("line_separation", UiTypeScript.line_spacing("prose", float(profile.get("font_scale", 1.0))))
	story_stack.add_child(narrative)
	var choice_panel := PanelContainer.new()
	choice_panel.name = "StoryChoices"
	choice_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var choice_style := StyleBoxFlat.new()
	choice_style.draw_center = false
	choice_style.border_color = _c("border_subtle")
	choice_style.border_width_bottom = 1
	choice_style.set_corner_radius_all(CORNER_RADIUS)
	choice_style.content_margin_top = 6
	choice_panel.add_theme_stylebox_override("panel", choice_style)
	story_stack.add_child(choice_panel)
	var choice_section := VBoxContainer.new()
	choice_section.add_theme_constant_override("separation", 0)
	choice_panel.add_child(choice_section)
	var choice_list := VBoxContainer.new()
	choice_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Rows carry their own hairline rule, so they butt straight up against
	# each other with no gap for a separator to sit in.
	choice_list.add_theme_constant_override("separation", 0)
	choice_section.add_child(choice_list)
	var choices: Array = event.get("choices", [])
	for choice: Dictionary in choices:
		if choice.has("check"):
			_show_contextual_tip("checked_choice")
			break
	for index in range(choices.size()):
		var choice: Dictionary = choices[index]
		var preview := game.get_choice_preview(choice)
		# A gate the survivor could not yet know about is absent rather than
		# disabled. Rows keep their authored index, so the engine still resolves
		# the choice the player actually pressed.
		if not preview.get("available", false) and bool(preview.get("hidden", false)):
			continue
		var guaranteed_cost := _choice_cost_text(choice)
		var button_text := str(choice.get("label", "Choose"))
		if guaranteed_cost != "":
			button_text += "\n%s" % guaranteed_cost
		if preview.get("available", false):
			if bool(preview.get("combat", false)):
				button_text += "\n%s" % preview.get("description", "FIGHT")
			elif int(preview.get("chance", -1)) >= 0:
				button_text += "\n[%s] %s" % [_stat_glyph(str(preview.get("stat", ""))), preview.get("description", "")]
			else:
				button_text += "\nCERTAIN"
		else:
			button_text += "\n▣ LOCKED: %s" % preview.get("reason", "Unavailable")
		var choice_button := _choice_button(button_text, _resolve_choice.bind(index), not preview.get("available", false))
		choice_button.tooltip_text = "%s\n%s" % [str(preview.get("reason", "")).strip_edges(), guaranteed_cost] if guaranteed_cost != "" else str(preview.get("reason", ""))
		choice_list.add_child(choice_button)
	choice_panel.modulate.a = 0.0
	choice_panel.visible = false
	active_story_actions = choice_panel
	var story_key := _story_instance_key("event", str(game.run_state.get("current_event_id", "")))
	_start_story(narrative, game.resolve_body(event), story_key, func() -> void: _reveal_choices(choice_panel))


func _show_survival_strip() -> void:
	var hud = SurvivorHudScript.new()
	hud.configure(game.run_state["survivor"], palette, float(profile.get("font_scale", 1.0)), false, game.run_state, true)
	hud.inventory_requested.connect(_show_inventory)
	hud.settings_requested.connect(_show_settings)
	hud.stats_requested.connect(_show_stat_details)
	hud.conditions_requested.connect(_show_conditions)
	page.add_child(hud)
	_show_pressure_strip()
	var utilities := HBoxContainer.new()
	utilities.alignment = BoxContainer.ALIGNMENT_END
	utilities.add_theme_constant_override("separation", 6)
	utilities.add_child(hud.make_conditions_link(game.run_state.get("survivor", {}).get("conditions", []).size(), float(profile.get("font_scale", 1.0))))
	utilities.add_child(hud.make_inventory_link(float(profile.get("font_scale", 1.0))))
	page.add_child(utilities)


func _show_pressure_strip(parent: Node = page) -> void:
	var strip = PressureStripScript.new()
	strip.configure(game.run_state["survivor"].get("pressures", {}), palette, float(profile.get("font_scale", 1.0)))
	parent.add_child(strip)


func _journey_pips(completed: int) -> String:
	var parts: Array[String] = []
	for index in range(5):
		parts.append("◆" if index < completed else "◇")
	return " ".join(parts)


## A choice and its cost read aloud as one sentence. Joining them with a period
## unconditionally would double the one the choice usually ends with already.
func _spoken_choice(lines: PackedStringArray) -> String:
	var spoken := str(lines[0]).strip_edges()
	if lines.size() < 2:
		return spoken
	if not spoken.is_empty() and not spoken.right(1) in [".", "?", "!"]:
		spoken += "."
	return "%s %s" % [spoken, str(lines[1]).strip_edges()]


## Prices are known before a choice and use the same item names and pressure
## vocabulary as the committed receipt. Risk and chance remain separate.
func _choice_cost_text(choice: Dictionary) -> String:
	var costs: Dictionary = choice.get("costs", {})
	var parts: Array[String] = []
	for item_id: Variant in costs.get("items", {}):
		var quantity := int(costs["items"][item_id])
		if quantity > 0:
			parts.append("%s -%d" % [str(content.get_item(str(item_id)).get("name", item_id)), quantity])
	for pressure: Variant in costs.get("pressures", {}):
		var delta := int(costs["pressures"][pressure])
		if delta != 0:
			parts.append("%s %s%d" % [str(pressure).capitalize(), "+" if delta >= 0 else "-", absi(delta)])
	return "GUARANTEED COST - %s" % " | ".join(parts) if not parts.is_empty() else ""


## Canvas choice row: no plate and no fill, just a hairline rule above each
## option, an accent chevron, the choice in Literata, and its cost in tracked
## Inter underneath. Accent appears once per row, which is what keeps the canvas
## budget of three accent moments per screen intact.
func _choice_button(text: String, callable: Callable, disabled: bool = false) -> Button:
	var button := _button("", callable, disabled)
	var lines := text.split("\n", true, 1)
	button.accessibility_name = _spoken_choice(lines)
	button.custom_minimum_size.y = 0
	button.clip_text = false

	var normal := StyleBoxFlat.new()
	normal.draw_center = false
	normal.border_color = _c("border_subtle")
	normal.border_width_top = 1
	normal.set_corner_radius_all(CORNER_RADIUS)
	normal.content_margin_left = 4
	normal.content_margin_right = 4
	normal.content_margin_top = 7
	normal.content_margin_bottom = 7
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate()
	hover.draw_center = true
	hover.bg_color = _c("surface_raised")
	button.add_theme_stylebox_override("hover", hover)
	var pressed := hover.duplicate()
	pressed.bg_color = _c("surface_pressed")
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", normal)

	var row := HBoxContainer.new()
	row.name = "ChoiceRow"
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 4)
	row.add_theme_constant_override("separation", 12)
	var chevron := _role_label("›", "title", _c("disabled") if disabled else _accent_color())
	chevron.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chevron.custom_minimum_size.x = 10
	row.add_child(chevron)
	var copy := VBoxContainer.new()
	copy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_theme_constant_override("separation", 4)
	var action_label := _role_label(str(lines[0]), "flavour", _c("disabled") if disabled else COLOR_TEXT)
	action_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_child(action_label)
	if lines.size() > 1:
		var detail_label := _role_label(str(lines[1]), "label", _c("disabled") if disabled else _c("muted"))
		detail_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		detail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		copy.add_child(detail_label)
	row.add_child(copy)
	button.add_child(row)
	# The copy is anchored inside the button, so the button has to be told how
	# tall it grew once the choice text wraps.
	var fit_height := func() -> void:
		if is_instance_valid(button) and is_instance_valid(row):
			button.custom_minimum_size.y = maxf(float(TOUCH_TARGET), row.get_combined_minimum_size().y + 14.0)
	# Wrapping can shrink the content minimum without resizing the already-tall row.
	# Refit on minimum-size changes too, so an initial narrow layout cannot latch.
	row.minimum_size_changed.connect(fit_height)
	row.resized.connect(fit_height)
	fit_height.call()
	return button


func _start_story(story, passage: String, key: String, finished: Callable) -> void:
	active_story = story
	active_story_key = key
	story.accessibility_description = passage
	story.reveal_progress.connect(func(visible: int) -> void: story_reveal_cache[key] = visible)
	story.reveal_finished.connect(func() -> void:
		story_reveal_cache[key] = passage.length()
		finished.call()
	)
	story.start(passage, str(profile.get("story_text_speed", "normal")), int(story_reveal_cache.get(key, 0)), bool(profile.get("reduced_motion", false)))


func _story_instance_key(kind: String, event_id: String) -> String:
	# total_events identifies repeated normal events, while history size also
	# advances through chained events before the journey counter is incremented.
	# The previous UI read a nonexistent `events_resolved` state field, causing
	# every result (and a later repeat of the same event) to reuse reveal progress.
	return "%s:%s:r%d:s%d:t%d:h%d:%s" % [
		kind,
		str(game.run_state.get("run_id", "")),
		int(game.run_state.get("region_index", 0)),
		int(game.run_state.get("events_in_region", 0)),
		int(game.run_state.get("total_events", 0)),
		game.run_state.get("event_history", []).size(),
		event_id,
	]


func _reveal_choices(choices: Control) -> void:
	if not is_instance_valid(choices):
		return
	choices.visible = true
	if bool(profile.get("reduced_motion", false)):
		choices.modulate.a = 1.0
		return
	var tween := create_tween()
	tween.tween_property(choices, "modulate:a", 1.0, 0.12)


func _pause_story(paused: bool) -> void:
	if is_instance_valid(active_story):
		active_story.set_paused(paused)


func _show_conditions() -> void:
	if _gameplay_locked():
		return
	if game.run_state.is_empty():
		return
	_pause_story(true)
	if is_instance_valid(conditions_popup):
		conditions_popup.hide()
		conditions_popup.queue_free()
	conditions_popup = PopupPanel.new()
	conditions_popup.exclusive = true
	add_child(conditions_popup)
	var body := _popup_body(conditions_popup, 14)
	body.add_child(_overlay_header("SURVIVOR STATUS", _close_conditions))

	var harmful_conditions: Array[String] = []
	var helpful_conditions: Array[String] = []
	for condition_variant: Variant in game.run_state.get("survivor", {}).get("conditions", []):
		var condition_id := str(condition_variant)
		if _condition_is_harmful(content.get_condition(condition_id)):
			harmful_conditions.append(condition_id)
		else:
			helpful_conditions.append(condition_id)
	harmful_conditions.sort()
	helpful_conditions.sort()
	body.add_child(_label("%d HARMFUL  •  %d HELPFUL" % [harmful_conditions.size(), helpful_conditions.size()], 13, _c("danger") if not harmful_conditions.is_empty() else _c("success")))
	if _inventory_actions_locked():
		body.add_child(_label("You can inspect effects now. During combat or a prepared roll, treatments must wait; combat medicine is used through USE ITEM and consumes the round.", 12, COLOR_MUTED))
	else:
		body.add_child(_label("Owned treatments can be used here. Medicine is consumed immediately and the run autosaves.", 12, COLOR_MUTED))

	var scroll := TouchScrollContainerScript.new()
	scroll.name = "ConditionsScroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var list := VBoxContainer.new()
	list.name = "ConditionsList"
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	scroll.add_child(list)
	if harmful_conditions.is_empty() and helpful_conditions.is_empty():
		list.add_child(_label("CLEAR — no active injuries, illnesses, or temporary advantages.", 15, _c("success")))
		list.add_child(_label("New conditions will appear here with their exact effects and known treatments.", 13, COLOR_MUTED))
	else:
		_add_condition_section(list, "HARMFUL CONDITIONS", harmful_conditions, _c("danger"))
		_add_condition_section(list, "HELPFUL CONDITIONS", helpful_conditions, _c("success"))
	if game.is_narrative_combat():
		var combat: Dictionary = game.run_state["combat_state"]
		list.add_child(_label("COMBAT WINDOWS", 14, _c("accent")))
		if bool(combat.get("riposte", false)):
			list.add_child(_label("RIPOSTE • Next action only. Attack gains +10 points accuracy and +25% damage (Counter weapons: +50%, mastered +65%). A different action discards it.", 14))
		if bool(combat.get("opening", false)):
			list.add_child(_label("OPENING • Next action only. Attack gains +20 points accuracy. Precision weapons also gain +30% damage (+40% mastered). A different action discards it.", 14))
		if int(combat.get("interrupt_cooldown", 0)) > 0:
			list.add_child(_label("INTERRUPTION • Recharging for %d exchanges. Cannot cancel another Heavy yet." % int(combat["interrupt_cooldown"]), 14))
		var last: Dictionary = combat.get("last_round", {})
		if int(last.get("suppression_percent", 0)) > 0:
			list.add_child(_label("SUPPRESSION • −%d%% enemy damage on the last response only; now expired." % int(last["suppression_percent"]), 14))
		if bool(last.get("enemy_interrupted", false)):
			list.add_child(_label("INTERRUPTED • The last Heavy was cancelled; the enemy's sequence advanced.", 14))
		list.add_child(_label("Enemy critical condition: %s" % str(content.get_adversary(str(combat["adversary_id"]))["combat"].get("critical_condition", "None")).capitalize(), 14, _c("danger")))
	_popup_center_responsive(conditions_popup, 0.94, 0.86)


func _add_condition_section(parent: VBoxContainer, heading: String, condition_ids: Array[String], color: Color) -> void:
	if condition_ids.is_empty():
		return
	parent.add_child(_label(heading, 14, color))
	for condition_id: String in condition_ids:
		parent.add_child(_condition_card(condition_id, "status", true))


func _show_stat_details() -> void:
	if _gameplay_locked():
		return
	if game.run_state.is_empty():
		return
	_pause_story(true)
	if is_instance_valid(stat_details_popup):
		stat_details_popup.hide()
		stat_details_popup.queue_free()
	stat_details_popup = PopupPanel.new()
	stat_details_popup.exclusive = true
	add_child(stat_details_popup)
	var body := _popup_body(stat_details_popup, 14)
	_show_minimal_stat_details(body)
	_popup_bottom_responsive(stat_details_popup, 0.92, 0.72)


## The HUD opens this compact reference, not a second status screen. Conditions
## have their own dedicated Status control, where their duration and treatment
## can be read without competing with the survivor's core abilities.
func _show_minimal_stat_details(body: VBoxContainer) -> void:
	body.add_child(_overlay_header("STATS", _close_stat_details))
	body.add_child(_role_label("Base ability scores and bonuses from equipped gear.", "flavour", _c("muted")))
	var scroll := TouchScrollContainerScript.new()
	scroll.name = "StatDetailsScroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var list := _scroll_column(scroll, 8)
	var explanations := {
		"strength": "Force checks, heavy weapons, and carrying capacity. Base Strength adds 3 capacity per point.",
		"agility": "Movement checks, Dodge and Flee, and agile weapons.",
		"wits": "Technical and observation checks, planning, and weapons that rely on precision.",
		"grit": "Endurance checks, weapons that rely on toughness, and your maximum hearts.",
		"presence": "Social checks, pressure under negotiation, and commanding weapons.",
	}
	var stats: Dictionary = game.run_state.get("survivor", {}).get("stats", {})
	for index: int in range(GameEngine.STATS.size()):
		var stat: String = GameEngine.STATS[index]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		row.tooltip_text = _stat_hover_text(stat)
		var icon := UiIconScript.new()
		icon.configure(stat, 30, _accent_color())
		icon.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		row.add_child(icon)
		var copy := VBoxContainer.new()
		copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		copy.add_theme_constant_override("separation", 2)
		var header := HBoxContainer.new()
		var name_label := _role_label(str(GameEngine.STAT_LABELS.get(stat, stat)).to_upper(), "label", _accent_color())
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		header.add_child(name_label)
		header.add_child(_role_label(str(int(stats.get(stat, 0))), "numeric", _c("text")))
		copy.add_child(header)
		copy.add_child(_role_label(str(explanations.get(stat, "")), "flavour", _c("text")))
		copy.add_child(_role_label(_equipment_stat_adjustment_text(stat), "caption", _c("muted")))
		var status_effect := _condition_stat_adjustment(stat)
		if str(status_effect.get("text", "")) != "":
			copy.add_child(_role_label(str(status_effect["text"]), "caption", _c("danger") if bool(status_effect.get("penalty", false)) else _c("success")))
		row.add_child(copy)
		list.add_child(row)
		if index < GameEngine.STATS.size() - 1:
			list.add_child(HSeparator.new())
	# Durations and treatments intentionally live in the dedicated Status sheet;
	# each ability row above already names the statuses moving it. Name the way
	# there so an injured survivor is never left guessing.
	list.add_child(HSeparator.new())
	list.add_child(_role_label("Full durations and treatments live under STATUS.", "flavour", _c("muted")))


## Hover text for one stat row: base value, what currently modifies it, and
## which weapons answer to it, so a survivor can read a build at a glance.
func _stat_hover_text(stat: String) -> String:
	var stats: Dictionary = game.run_state.get("survivor", {}).get("stats", {})
	var parts: Array[String] = ["%s %d (base)" % [str(GameEngine.STAT_LABELS.get(stat, stat)), int(stats.get(stat, 0))]]
	var adjustments := _stat_adjustment_text(stat)
	if adjustments != "":
		parts.append(adjustments)
	var fitted: Array[String] = []
	for item_id: String in content.items:
		var item: Dictionary = content.get_item(item_id)
		if str(item.get("category", "")) == "weapon" and str(item.get("combat", {}).get("attack_stat", "")) == stat:
			fitted.append(str(item.get("name", item_id)))
	fitted.sort()
	var hidden := maxi(0, fitted.size() - 4)
	while fitted.size() > 4:
		fitted.remove_at(fitted.size() - 1)
	if not fitted.is_empty():
		parts.append("Answers: %s%s" % [", ".join(fitted), " +%d more" % hidden if hidden > 0 else ""])
	return "\n".join(parts)


func _equipment_stat_adjustment_text(stat: String) -> String:
	var equipment_parts: Array[String] = []
	var survivor: Dictionary = game.run_state.get("survivor", {})
	for slot: String in survivor.get("equipment", {}):
		var item_id := str(survivor["equipment"].get(slot, ""))
		if item_id == "":
			continue
		var item: Dictionary = content.get_item(item_id)
		var value := int(item.get("modifiers", {}).get("stats", {}).get(stat, 0))
		if value != 0:
			equipment_parts.append("%s %+.0f" % [str(item.get("name", item_id)), float(value)])
	return "EQUIPPED: %s" % ", ".join(equipment_parts) if not equipment_parts.is_empty() else "EQUIPPED: no bonus"


## Statuses moving one ability, for the stat sheet row itself: hover tooltips
## already knew this, but touch screens never see hover text. Returns the line
## plus whether any status penalizes the stat, so penalties read as warnings.
func _condition_stat_adjustment(stat: String) -> Dictionary:
	var parts: Array[String] = []
	var penalty := false
	var survivor: Dictionary = game.run_state.get("survivor", {})
	for condition_id: Variant in survivor.get("conditions", []):
		var condition: Dictionary = content.get_condition(str(condition_id))
		var value := int(condition.get("modifiers", {}).get(stat, 0))
		if value != 0:
			parts.append("%s %+.0f" % [condition.get("name", condition_id), float(value)])
			penalty = penalty or value < 0
	if parts.is_empty():
		return {"text": "", "penalty": false}
	return {"text": "STATUS: %s" % ", ".join(parts), "penalty": penalty}


func _stat_adjustment_text(stat: String) -> String:
	var equipment_parts: Array[String] = []
	var condition_parts: Array[String] = []
	var survivor: Dictionary = game.run_state.get("survivor", {})
	for slot: String in survivor.get("equipment", {}):
		var item_id := str(survivor["equipment"].get(slot, ""))
		if item_id == "":
			continue
		var value := int(content.get_item(item_id).get("modifiers", {}).get("stats", {}).get(stat, 0))
		if value != 0:
			equipment_parts.append("%s %+.0f" % [content.get_item(item_id).get("name", item_id), float(value)])
	for condition_id: Variant in survivor.get("conditions", []):
		var condition: Dictionary = content.get_condition(str(condition_id))
		var value := int(condition.get("modifiers", {}).get(stat, 0))
		if value != 0:
			condition_parts.append("%s %+.0f" % [condition.get("name", condition_id), float(value)])
	var parts: Array[String] = []
	if not equipment_parts.is_empty():
		parts.append("Gear: %s" % ", ".join(equipment_parts))
	if not condition_parts.is_empty():
		parts.append("Condition: %s" % ", ".join(condition_parts))
	if stat == "agility" and game.get_total_weight() > game.get_carry_capacity():
		parts.append("Over capacity: -2 on Agility checks")
	return "  •  ".join(parts)


func _condition_card(condition_id: String, change: String, show_treatments: bool = false) -> PanelContainer:
	var condition: Dictionary = content.get_condition(condition_id)
	var card := PanelContainer.new()
	card.name = "Condition_%s_%s" % [change, condition_id]
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	card.add_child(column)
	var harmful := _condition_is_harmful(condition)
	var heading_prefix := "NEW CONDITION" if change == "added" else "REMOVED" if change == "removed" else "HARMFUL" if change == "status" and harmful else "HELPFUL" if change == "status" else "ACTIVE"
	var heading_color := _c("success") if change == "removed" or not harmful else _c("danger")
	column.add_child(_label("%s — %s" % [heading_prefix, str(condition.get("name", condition_id)).to_upper()], 14, heading_color))
	column.add_child(_label(str(condition.get("description", "No description available.")), 13, COLOR_TEXT))
	column.add_child(_label(_condition_mechanics_text(condition, change, condition_id), 12, COLOR_MUTED))
	if show_treatments and harmful and change == "status":
		_add_condition_treatments(column, condition_id)
	return card


func _condition_is_harmful(condition: Dictionary) -> bool:
	for value: Variant in condition.get("modifiers", {}).values():
		if int(value) < 0:
			return true
	return false


func _condition_mechanics_text(condition: Dictionary, change: String = "active", condition_id: String = "") -> String:
	var modifiers: Array[String] = []
	for stat: String in GameEngine.STATS:
		var value := int(condition.get("modifiers", {}).get(stat, 0))
		if value != 0:
			modifiers.append("%s %s%d" % [str(GameEngine.STAT_LABELS.get(stat, stat)), "+" if value > 0 else "", value])
	var effect_text := "Effect: %s" % (" • ".join(modifiers) if not modifiers.is_empty() else "No stat modifier")
	if change == "removed":
		return "%s no longer applies." % effect_text
	var duration := int(condition.get("duration_checks", 0))
	var remaining := int(game.run_state.get("condition_uses", {}).get(condition_id, duration)) if condition_id != "" else duration
	var duration_text := "%d checked choice%s remaining" % [remaining, "" if remaining == 1 else "s"] if duration > 0 else "until removed or treated"
	return "%s • Duration: %s." % [effect_text, duration_text]


func _condition_remedy_ids(condition_id: String) -> Array[String]:
	var remedies: Array[String] = []
	for item_id: String in content.items:
		var removed_conditions: Array = content.get_item(item_id).get("effects", {}).get("remove_conditions", [])
		if condition_id in removed_conditions:
			remedies.append(item_id)
	remedies.sort_custom(func(a: String, b: String) -> bool:
		return str(content.get_item(a).get("name", a)) < str(content.get_item(b).get("name", b))
	)
	return remedies


func _add_condition_treatments(parent: VBoxContainer, condition_id: String) -> void:
	var remedy_ids := _condition_remedy_ids(condition_id)
	if remedy_ids.is_empty():
		parent.add_child(_label("NO KNOWN ITEM TREATMENT", 11, _c("danger")))
		return
	var carried := false
	var missing_names: Array[String] = []
	for item_id: String in remedy_ids:
		var item: Dictionary = content.get_item(item_id)
		var quantity := game.get_item_quantity(item_id)
		if quantity <= 0:
			missing_names.append(str(item.get("name", item_id)))
			continue
		carried = true
		var remedy := _button("USE %s  ×%d" % [str(item.get("name", item_id)).to_upper(), quantity], _use_condition_remedy.bind(item_id, condition_id), _inventory_actions_locked())
		remedy.name = "ConditionRemedy_%s_%s" % [condition_id, item_id]
		remedy.tooltip_text = str(item.get("use_text", "Use treatment"))
		parent.add_child(remedy)
		parent.add_child(_label(_item_effect_text(item), 11, COLOR_MUTED))
	if not carried:
		parent.add_child(_label("NOT CARRIED — %s" % ", ".join(missing_names), 11, COLOR_MUTED))
	elif not missing_names.is_empty():
		parent.add_child(_label("OTHER TREATMENTS — %s" % ", ".join(missing_names), 10, COLOR_MUTED))


func _use_condition_remedy(item_id: String, condition_id: String) -> void:
	if _inventory_actions_locked():
		_show_toast("Resolve the current roll, or use the combat USE ITEM action.")
		return
	if condition_id not in game.run_state.get("survivor", {}).get("conditions", []):
		_show_toast("That condition is no longer active.")
		_show_conditions()
		return
	_run_gameplay_action("use_item", [item_id], _after_condition_remedy)


func _after_condition_remedy(result: Dictionary) -> void:
	_show_toast(str(result.get("text", "")))
	if str(game.run_state.get("phase", "")) == "death":
		if is_instance_valid(conditions_popup):
			conditions_popup.hide()
		_finish_run(false)
	else:
		_show_conditions()


func _close_conditions() -> void:
	if _gameplay_locked():
		return
	if is_instance_valid(conditions_popup):
		conditions_popup.hide()
	_pause_story(false)


func _close_stat_details() -> void:
	if _gameplay_locked():
		return
	if is_instance_valid(stat_details_popup):
		stat_details_popup.hide()
	_pause_story(false)


func _pressure_color(pressure: String, value: int) -> Color:
	var dangerous := value >= 75
	var warning := value >= 50
	return _c("danger") if dangerous else _accent_color() if warning else _c("success")


func _stat_glyph(stat: String) -> String:
	return StatsCapsuleScript.stat_symbol(stat)


func _resolve_choice(index: int) -> void:
	if _gameplay_locked():
		return
	var prepared: Dictionary = combat_transaction.prepare_event(game, saves, index)
	if prepared.has("error"):
		_show_toast(str(prepared["error"]))
		return
	if prepared.get("combat_started", false):
		_show_combat()
		return
	if prepared.get("requires_roll", false):
		_show_event_roll()
		return
	_commit_event_roll(null)


func _show_event_roll() -> void:
	_clear_page()
	_set_atmosphere("reveal")
	_set_region_background()
	_show_survival_strip()
	var pending: Dictionary = game.run_state.get("pending_resolution", {})
	var choices: Array = game.current_event().get("choices", [])
	var choice_index := int(pending.get("choice_index", -1))
	var choice_text := str(choices[choice_index].get("label", "Your choice")) if choice_index >= 0 and choice_index < choices.size() else "Your choice"
	_title("D20 CHECK")
	var body := _panel()
	var scroll := TouchScrollContainerScript.new()
	scroll.name = "EventRollScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	var reading := _scroll_column(scroll, 8)
	reading.add_child(_role_label(choice_text, "lede"))
	var prompt := _label("The result is concealed until you roll.", 17, _c("muted"))
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reading.add_child(prompt)
	if int(pending.get("success_chance", -1)) >= 0:
		var saved_stat := str(pending.get("stat", "wits"))
		var saved_label := str(pending.get("stat_label", saved_stat.capitalize())).to_upper()
		var saved_chance := int(pending.get("success_chance", 0))
		var required_roll := int(pending.get("required_roll", D20Resolver.required_roll(saved_chance)))
		var chance_label := _label("[%s] %s • %d%% SUCCESS CHANCE" % [_stat_glyph(saved_stat), saved_label, saved_chance], 16, _accent_color())
		chance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		reading.add_child(chance_label)
		var target_label := _label("ROLL %d+" % required_roll, 21, COLOR_TEXT)
		target_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		reading.add_child(target_label)
	var dice = DiceWidgetScript.new()
	dice.set_palette(palette)
	dice.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	reading.add_child(dice)
	# A long choice and Large text may scroll; the way to roll stays on screen.
	body.add_child(_button("ROLL D20", _commit_event_roll.bind(dice)))


func _commit_event_roll(dice) -> void:
	if _gameplay_locked():
		return
	var result: Dictionary = combat_transaction.resolve_event(game, saves, profile)
	_accept_action_result(result, _present_event_result.bind(dice))


func _present_event_result(result: Dictionary, dice) -> void:
	event_committing = true
	var final_roll := int(result.get("resolution", {}).get("roll", 0))
	if dice != null and final_roll > 0:
		if sound != null:
			sound.play_effect("dice")
		await _animate_d20(dice, final_roll)
	_play_resolution_feedback(result)
	event_committing = false
	if str(game.run_state.get("phase", "")) == "death":
		_finish_run(false)
	elif str(game.run_state.get("phase", "")) == "victory":
		_finish_run(true)
	else:
		_show_result()


func _animate_d20(dice, final_roll: int) -> void:
	if not is_instance_valid(dice):
		return
	if bool(profile.get("reduced_motion", false)):
		dice.set_face(final_roll)
		return
	var cosmetic := RandomNumberGenerator.new()
	cosmetic.seed = Time.get_ticks_usec()
	for step in range(9):
		dice.set_face(cosmetic.randi_range(1, 20))
		dice.rotation = (-0.09 if step % 2 == 0 else 0.09)
		await get_tree().create_timer(0.055 + step * 0.006).timeout
	dice.rotation = 0.0
	dice.set_face(final_roll)
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	dice.scale = Vector2(0.78, 0.78)
	tween.tween_property(dice, "scale", Vector2.ONE, 0.24)
	await tween.finished


func _play_resolution_feedback(result: Dictionary) -> void:
	var resolution: Dictionary = result.get("resolution", {})
	var outcome := str(resolution.get("outcome", "success"))
	if sound != null:
		var phase := str(game.run_state.get("phase", ""))
		if phase in ["victory", "death"]:
			sound.play_effect(phase)
		else:
			sound.play_resolution(bool(resolution.get("succeeded", true)), outcome.begins_with("critical"))


func _show_combat() -> void:
	_show_cinematic_combat()


var combat_transaction = preload("res://scripts/services/combat_transaction.gd").new()
var combat_committing := false


func _show_cinematic_combat() -> void:
	_clear_page()
	_set_atmosphere("combat")
	_set_region_background()
	# Combat already owns portraits, HP, equipment, and status presentation. Keep
	# one compact pressure strip instead of repeating the complete journey HUD.
	_show_pressure_strip()
	var snapshot := game.combat_presentation_snapshot()
	snapshot["last_exchange"] = game.run_state.get("combat_state", {}).get("last_round", {}).get("presentation", {})
	if snapshot.is_empty():
		_render_current()
		return
	var profile_data := game.get_player_weapon_profile()
	snapshot["compact"] = get_viewport_rect().size.y < 760
	# A creature with no artwork is described rather than labelled; the note lives
	# with the adversary definition, so the UI reads it rather than inventing one.
	var fighting: Dictionary = content.get_adversary(str(game.run_state.get("combat_state", {}).get("adversary_id", "")))
	if snapshot.has("enemy") and str(fighting.get("field_note", "")) != "":
		snapshot["enemy"]["field_note"] = str(fighting["field_note"])
	if game.is_narrative_combat():
		snapshot["action_previews"] = {}
		for action: String in ["attack", "block", "dodge", "flee", "opportunity"]:
			snapshot["action_previews"][action] = game.combat_action_preview(action)
	var flee := game.get_flee_preview()
	var presentation = CombatPresentationScript.new()
	var has_consumables := not game.combat_usable_items().is_empty()
	var has_switch := not game.combat_switchable_weapons().is_empty() if game.has_method("combat_switchable_weapons") else false
	var has_interact := not game.combat_interactions().is_empty() if game.has_method("combat_interactions") else false
	presentation.configure(snapshot, palette, float(profile.get("font_scale", 1.0)), profile_data, flee, has_consumables or has_switch or has_interact)
	presentation.size_flags_vertical = Control.SIZE_EXPAND_FILL
	presentation.action_requested.connect(func(action: String) -> void: _prepare_combat_action(action, ""))
	presentation.items_requested.connect(_show_combat_items)
	presentation.status_requested.connect(_show_conditions)
	presentation.tactics_requested.connect(_show_combat_tactics)
	presentation.roll_requested.connect(func() -> void: _commit_combat_roll(presentation))
	page.add_child(presentation)
	active_combat_presentation = presentation
	_offer_combat_tips()


func _combatant_card(display_name: String, portrait_id: String, health: int, maximum: int, weapon: String, player_side: bool) -> PanelContainer:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 3)
	card.add_child(body)
	var portrait := PortraitArtScript.create_view(portrait_id, _c("muted"), 9)
	portrait.custom_minimum_size.y = 54
	body.add_child(portrait)
	var name_label := _label(("YOU • " if player_side else "ENEMY • ") + display_name, 14, _accent_color() if player_side else COLOR_DANGER)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(name_label)
	var hp := _label("%d / %d HP" % [health, maximum], 13, COLOR_DANGER if health * 4 <= maximum else COLOR_TEXT)
	hp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(hp)
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.max_value = maximum
	bar.value = health
	bar.custom_minimum_size.y = 9
	_apply_meter_style(bar, _c("danger"))
	body.add_child(bar)
	var weapon_label := _label(weapon, 11, _c("muted"))
	weapon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.add_child(weapon_label)
	return card


func _combat_log_color(kind: String) -> Color:
	if kind in ["damage", "critical_failure", "failure", "condition"]:
		return _c("danger")
	if kind in ["heal", "success"]:
		return _c("success")
	if kind == "critical_success":
		return _c("critical")
	return _c("muted")


func _scroll_combat_log(scroll: ScrollContainer) -> void:
	if is_instance_valid(scroll):
		scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)


func _prepare_combat_action(action: String, item_id: String = "") -> void:
	if _gameplay_locked():
		return
	var prepared: Dictionary = combat_transaction.prepare(game, saves, action, item_id)
	if prepared.has("error"):
		_show_toast(str(prepared["error"]))
		return
	if is_instance_valid(action_popup):
		action_popup.hide()
	_show_combat_roll()
	if str(profile.get("combat_presentation", "manual")) == "quick":
		call_deferred("_commit_combat_roll", active_combat_presentation)


func _show_combat_roll() -> void:
	_show_cinematic_combat()


func _commit_combat_roll(presentation) -> void:
	if _gameplay_locked():
		return
	if not is_instance_valid(presentation):
		_render_current()
		return
	var result: Dictionary = combat_transaction.resolve(game, saves, profile)
	_accept_action_result(result, _present_combat_result.bind(presentation))


func _present_combat_result(result: Dictionary, presentation) -> void:
	if not is_instance_valid(presentation):
		_render_current()
		return
	combat_committing = true
	if sound != null:
		sound.play_effect("dice")
	await presentation.play_round(result, bool(profile.get("reduced_motion", false)))
	combat_committing = false
	if sound != null:
		var player_roll := int(result.get("player_roll", 0))
		var critical := player_roll in [1, 20] or int(result.get("enemy_roll", 0)) in [1, 20]
		var display: Dictionary = result.get("presentation", {})
		var action := str(display.get("action", result.get("action", "")))
		if str(game.run_state.get("phase", "")) == "death":
			sound.play_effect("death")
		elif action == "use_item":
			sound.play_effect("inventory")
		elif bool(display.get("hit", false)):
			sound.play_effect("critical_success" if critical and player_roll == 20 else "impact")
		elif action in ["block", "dodge", "flee"] and player_roll >= int(result.get("required_roll", 20)) and player_roll != 1:
			sound.play_effect("block" if action == "block" else "evade")
		else:
			sound.play_resolution(false, critical)
	_render_current()


## Reads the snapshot the presentation was just built from. It changes nothing:
## the committed move, the windows, and the Opportunity state are already decided.
func _offer_combat_tips() -> void:
	if not game.is_narrative_combat():
		return
	var state: Dictionary = game.run_state.get("combat_state", {})
	if str(state.get("committed_move", {}).get("id", "")) in ["heavy", "sweep"]:
		_show_contextual_tip("enemy_heavy_sweep")
	if bool(state.get("riposte", false)) or bool(state.get("opening", false)):
		_show_contextual_tip("defense_window")
	if bool(state.get("opportunity_ready", false)) and not bool(state.get("opportunity_used", false)):
		_show_contextual_tip("opportunity")
	_apply_combat_guidance_space()


func _show_combat_tactics() -> void:
	if _gameplay_locked():
		return
	if not game.is_narrative_combat():
		return
	if is_instance_valid(action_popup):
		action_popup.queue_free()
	action_popup = PopupPanel.new()
	add_child(action_popup)
	var body := _popup_body(action_popup)
	body.add_child(_overlay_header("COMBAT • READ THE OPENING", func() -> void: action_popup.hide()))
	var scroll := TouchScrollContainerScript.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	list.add_child(_label(str(game.run_state["combat_state"]["committed_move"]["tell"]), 17))
	for action: String in ["attack", "block", "dodge", "flee", "opportunity"]:
		var preview := game.combat_action_preview(action)
		list.add_child(_label("%s • %d%% • ROLL %d+\n%s\n%s" % [action.to_upper(), preview["chance"], preview["required_roll"], "\n".join(preview["effects"]), preview["cost"]], 14))
	# Stage 1 counters: show switch and interact options alongside the six main
	# previews so testers can see every response to a trait.
	if game.has_method("combat_switchable_weapons"):
		for weapon_id: String in game.combat_switchable_weapons():
			var switch_preview := game.combat_action_preview("switch_weapon", weapon_id)
			list.add_child(_label("SWITCH → %s\n%s\n%s" % [content.get_item(weapon_id).get("name", weapon_id), "\n".join(switch_preview.get("effects", [])), switch_preview["cost"]], 14))
	if game.has_method("combat_interactions"):
		for interaction: Dictionary in game.combat_interactions():
			var interaction_preview := game.combat_action_preview("interact", str(interaction.get("id", "")))
			list.add_child(_label("INTERACT • %s\n%s\n%s" % [str(interaction.get("label", "")), "\n".join(interaction_preview.get("effects", [])), interaction_preview["cost"]], 14))
	var weapon: Dictionary = content.get_item(str(game.run_state["survivor"]["equipment"].get("weapon", "")))
	list.add_child(_label(_weapon_signature_text(weapon, game.run_state["survivor"]["stats"]), 14, _c("accent")))
	_popup_center_responsive(action_popup, 0.96, 0.86)


func _show_combat_items() -> void:
	if _gameplay_locked():
		return
	# Stage 1 Item sheet: consumables, carried-weapon switching, and available
	# environmental interactions. Switching or operating machinery costs the
	# round; every preview shows the committed enemy response.
	if is_instance_valid(action_popup):
		action_popup.queue_free()
	action_popup = PopupPanel.new()
	action_popup.exclusive = true
	add_child(action_popup)
	var body := _popup_body(action_popup, 14)
	body.add_child(_overlay_header("ITEM • SWITCH • INTERACT", action_popup.hide))
	var tell := str(game.run_state.get("combat_state", {}).get("committed_move", {}).get("tell", ""))
	if tell != "":
		body.add_child(_label("Enemy intends: " + tell, 12, _c("muted")))
	var consumables := game.combat_usable_items()
	body.add_child(_label("CONSUMABLES • enemy responds", 12, _c("accent")))
	if consumables.is_empty():
		body.add_child(_label("No consumables carried.", 12, _c("muted")))
	for item_id: String in consumables:
		var item: Dictionary = content.get_item(item_id)
		var preview := game.combat_action_preview("use_item", item_id)
		var detail := "×%d • %s" % [game.get_item_quantity(item_id), str(preview.get("cost", ""))]
		body.add_child(_button("%s  %s\n%s" % [item.get("name", item_id), detail, "\n".join(preview.get("effects", []))], func() -> void:
			_prepare_combat_action("use_item", item_id)
		))
	body.add_child(_label("CARRIED WEAPONS • switching costs the round", 12, _c("accent")))
	var switchable: Array = game.combat_switchable_weapons() if game.has_method("combat_switchable_weapons") else []
	if switchable.is_empty():
		body.add_child(_label("No other weapon carried.", 12, _c("muted")))
	for weapon_id: String in switchable:
		var weapon: Dictionary = content.get_item(weapon_id)
		var switch_preview := game.combat_action_preview("switch_weapon", weapon_id)
		body.add_child(_button("%s • %s\n%s" % [weapon.get("name", weapon_id), str(switch_preview.get("cost", "")), "\n".join(switch_preview.get("effects", []))], func() -> void:
			_prepare_combat_action("switch_weapon", weapon_id)
		))
	body.add_child(_label("ENVIRONMENT • machinery costs the round", 12, _c("accent")))
	var interactions: Array = game.combat_interactions() if game.has_method("combat_interactions") else []
	if interactions.is_empty():
		body.add_child(_label("Nothing to operate here.", 12, _c("muted")))
	for interaction: Dictionary in interactions:
		var interaction_id := str(interaction.get("id", ""))
		var interaction_preview := game.combat_action_preview("interact", interaction_id)
		body.add_child(_button("%s\n%s" % [str(interaction.get("label", interaction_id)), "\n".join(interaction_preview.get("effects", []))], func() -> void:
			_prepare_combat_action("interact", interaction_id)
		))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(spacer)
	_popup_center_responsive(action_popup, 0.96, 0.86)


func _show_result() -> void:
	_clear_page()
	_set_atmosphere("reveal")
	_set_region_background()
	_show_contextual_tip("event_preparation")
	var result: Dictionary = game.run_state.get("last_result", {})
	_show_survival_strip()
	var body := VBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 9)
	page.add_child(body)
	# The die, the arithmetic, the prose and the consequences are one reading and
	# they scroll together. Continue is pinned below: on a tall result the button
	# used to be pushed off the bottom of the screen with no way to reach it.
	var reveal_scroll := TouchScrollContainerScript.new()
	reveal_scroll.name = "RevealScroll"
	reveal_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	reveal_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	reveal_scroll.scroll_deadzone = 10
	body.add_child(reveal_scroll)
	var reveal := _scroll_column(reveal_scroll, 9)
	var resolution: Dictionary = result.get("resolution", {})
	if int(resolution.get("roll", 0)) > 0:
		var outcome := str(resolution.get("outcome", "failure"))
		var outcome_color := _c("critical") if outcome == "critical_success" else _c("success") if "success" in outcome else _c("danger")
		var dice = DiceWidgetScript.new()
		dice.set_palette(palette)
		dice.set_face(int(resolution.get("roll", 0)))
		var die_size := 132 if ResponsiveRulesScript.is_compact_height(get_viewport_rect().size.y) else REVEAL_DIE_SIZE
		dice.custom_minimum_size = Vector2(die_size, die_size)
		dice.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		reveal.add_child(dice)
		if not bool(profile.get("reduced_motion", false)):
			call_deferred("_animate_dice", dice)
		# Canvas reveal order: the roll's arithmetic in tracked numerics, then the
		# verdict as a dot and a word. Colour lands on the verdict alone, which
		# keeps the screen inside the canvas budget of three accent moments.
		var required_roll := int(resolution.get("required_roll", D20Resolver.required_roll(int(resolution.get("success_chance", 100)))))
		var modern_rules: bool = int(resolution.get("rules_version", 3)) >= 3 and resolution.has("difficulty")
		var math_text := "Rolled %d vs %d+" % [int(resolution.get("roll", 0)), required_roll] if modern_rules else "Rolled %d" % int(resolution.get("roll", 0))
		var math_label := _role_label(math_text.to_upper(), "numeric")
		math_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		reveal.add_child(math_label)
		reveal.add_child(_verdict_row(outcome, outcome_color))
		var odds := _role_label("%d%% original success chance" % int(resolution.get("success_chance", 100)), "label", _c("muted"))
		odds.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		odds.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		reveal.add_child(odds)
	var narrative = StoryTypewriterScript.new()
	narrative.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_type(narrative, "prose", "normal_font")
	narrative.add_theme_color_override("default_color", _c("text"))
	narrative.add_theme_constant_override("line_separation", UiTypeScript.line_spacing("prose", float(profile.get("font_scale", 1.0))))
	reveal.add_child(narrative)
	var footer := VBoxContainer.new()
	footer.modulate.a = 0.0
	footer.visible = false
	active_story_actions = footer
	var changes: Array = result.get("changes", [])
	# Items gained or spent render as icon rows from the structured entries;
	# their text lines are folded away so the receipt never lists them twice.
	# Old saves carry no entries, and their text receipt renders untouched.
	var item_lines: Dictionary = {}
	var item_rows: Array = []
	for entry: Variant in result.get("item_changes", []):
		if typeof(entry) != TYPE_DICTIONARY or str(entry.get("id", "")) == "":
			continue
		var row_item: Dictionary = content.get_item(str(entry.get("id", "")))
		if row_item.is_empty():
			continue
		var delta := int(entry.get("delta", 0))
		if delta == 0:
			continue
		item_lines["%s %s%d" % [str(row_item.get("name", "")), "+" if delta >= 0 else "", delta]] = true
		item_rows.append({"item": row_item, "delta": delta})
	var text_lines: Array[String] = []
	for line: Variant in changes:
		if not item_lines.has(str(line)):
			text_lines.append(str(line))
	if not changes.is_empty():
		footer.add_child(_label("COMMITTED RECEIPT", 13, _c("danger") if not bool(resolution.get("succeeded", true)) else _accent_color()))
		if not text_lines.is_empty():
			footer.add_child(_label("\n".join(text_lines), 14, _accent_color()))
		for row_data: Dictionary in item_rows:
			footer.add_child(_receipt_item_row(row_data))
	else:
		footer.add_child(_label("COMMITTED RECEIPT", 13, _c("muted")))
		footer.add_child(_label("No inventory, vital, pressure, or condition change.", 14, _c("muted")))
	var xp_awards: Array = result.get("xp_awards", [])
	if not xp_awards.is_empty():
		var xp_lines: Array[String] = []
		var levels_gained := 0
		for award: Variant in xp_awards:
			xp_lines.append("%s  +%d XP" % [str(award.get("source", "Experience")), int(award.get("awarded", 0))])
			levels_gained += int(award.get("levels_gained", 0))
		footer.add_child(_label("EXPERIENCE", 13, _c("success")))
		footer.add_child(_label("\n".join(xp_lines), 14, _c("success")))
		if levels_gained > 0:
			footer.add_child(_label("LEVEL UP — %d STAT POINT%s BANKED\nAllocate at the next checkpoint." % [levels_gained, "" if levels_gained == 1 else "S"], 15, _c("critical")))
	for condition_change: Variant in result.get("condition_changes", []):
		footer.add_child(_condition_card(str(condition_change.get("id", "")), str(condition_change.get("change", "added"))))
	reveal.add_child(footer)
	# Continue is the way off this screen, so it lives outside the scroll. It
	# arrives with the consequences rather than sitting lit while prose is still
	# revealing.
	var actions := VBoxContainer.new()
	actions.name = "RevealActions"
	actions.modulate.a = 0.0
	actions.visible = false
	actions.add_child(_button("Continue", _continue_from_result))
	body.add_child(actions)
	var story_key := _story_instance_key("result", str(result.get("event_id", "")))
	_start_story(narrative, str(result.get("outcome_text", "")), story_key, func() -> void:
		_reveal_choices(footer)
		_reveal_choices(actions)
	)


## One receipt row for an item gained or spent: the item's own icon beside its
## name and quantity. Gains read in accent, spends in muted, and the text
## label keeps the row legible to screen readers and large-text sizes.
func _receipt_item_row(row_data: Dictionary) -> Control:
	var item: Dictionary = row_data.get("item", {})
	var delta := int(row_data.get("delta", 0))
	var row := HBoxContainer.new()
	row.name = "ReceiptItemRow_%s" % str(item.get("icon_id", item.get("name", "item")))
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon = ItemIconScript.new()
	icon.custom_minimum_size = Vector2(30, 30)
	icon.configure(str(item.get("icon_id", "")), str(item.get("category", "utility")), palette)
	icon.accessibility_name = str(item.get("name", "item"))
	row.add_child(icon)
	var item_label := _label("%s  %s%d" % [str(item.get("name", "item")), "+" if delta >= 0 else "", delta], 14, _accent_color() if delta >= 0 else _c("muted"))
	item_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	item_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(item_label)
	return row


func _animate_dice(dice: Control) -> void:
	if not is_instance_valid(dice):
		return
	dice.pivot_offset = dice.size * 0.5
	dice.scale = Vector2(0.72, 0.72)
	dice.modulate.a = 0.15
	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(dice, "scale", Vector2.ONE, 0.32)
	tween.tween_property(dice, "modulate:a", 1.0, 0.2)


func _continue_from_result() -> void:
	_run_gameplay_action("continue", [], _after_continue)


func _after_continue(result: Dictionary) -> void:
	_render_current()
	var notice := str(result.get("survival_notice", ""))
	if notice != "":
		_show_toast(notice)


func _show_checkpoint() -> void:
	_clear_page()
	if int(game.run_state.get("unspent_stat_points", 0)) > 0:
		_show_contextual_tip("checkpoint_allocation")
	_set_atmosphere("checkpoint")
	_set_region_background()
	var region := game.current_region()
	_show_survival_strip()
	_title("CHECKPOINT", "%s complete" % region.get("name", "Region"))
	# The artboard is 852 tall: the checkpoint's copy and its two departures do
	# not both fit, so the reading scrolls and the departures stay reachable.
	var body := _panel()
	var checkpoint_scroll := TouchScrollContainerScript.new()
	checkpoint_scroll.name = "CheckpointScroll"
	checkpoint_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	checkpoint_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	checkpoint_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(checkpoint_scroll)
	var checkpoint_column := _scroll_column(checkpoint_scroll)
	checkpoint_column.add_child(_role_label("You find defensible ground. Spend any banked stat points if you wish, then choose recovery or momentum before the road closes again.", "prose"))
	var checkpoint_award: Dictionary = game.run_state.get("last_checkpoint_xp", {})
	if int(checkpoint_award.get("awarded", 0)) > 0:
		var checkpoint_text := "REGION SURVIVED  +%d XP" % int(checkpoint_award.get("awarded", 0))
		if int(checkpoint_award.get("levels_gained", 0)) > 0:
			checkpoint_text += "\nLEVEL UP — %d STAT POINT%s BANKED" % [int(checkpoint_award.get("levels_gained", 0)), "" if int(checkpoint_award.get("levels_gained", 0)) == 1 else "S"]
		checkpoint_column.add_child(_role_label(checkpoint_text, "label", _c("success")))
	checkpoint_column.add_child(_eyebrow("1 — Growth (optional)"))
	var xp_progress := game.experience_progress()
	var xp_text := "XP MAX" if bool(xp_progress.get("at_max_level", false)) else "%d / %d XP" % [int(xp_progress.get("experience", 0)), int(xp_progress.get("next_threshold", 0))]
	var banked := int(game.run_state.get("unspent_stat_points", 0))
	checkpoint_column.add_child(_role_label("Level %d  ·  %s  ·  %d banked point%s" % [int(game.run_state.get("level", 1)), xp_text, banked, "" if banked == 1 else "s"], "label", _accent_color() if banked > 0 else _c("icon_ink")))
	var checkpoint_progress := checkpoint_column.get_child(-1) as Label
	checkpoint_progress.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# Allocation belongs beside the level it changes; only the departures pin.
	checkpoint_column.add_child(_button("ALLOCATE STAT POINTS", _show_level_allocation, int(game.run_state.get("unspent_stat_points", 0)) <= 0))
	checkpoint_column.add_child(HSeparator.new())
	_show_checkpoint_talents(checkpoint_column)
	checkpoint_column.add_child(HSeparator.new())
	checkpoint_column.add_child(_eyebrow("2 — How do you leave?"))
	var checkpoint_action := str(game.run_state.get("checkpoint_action", ""))
	if checkpoint_action == "rest":
		# This receipt must wrap on a narrow phone. As a single-line tracked label
		# it enlarged the scroll column and pushed the pinned departure off-screen.
		checkpoint_column.add_child(_role_label("REST COMPLETE • Fatigue reached 0 • HP +25 • one food consumed", "flavour", _c("success")))
		var continue_after_rest := _button("CONTINUE JOURNEY AFTER REST", _leave_checkpoint)
		_add_button_atlas_icon(continue_after_rest, "navigation")
		body.add_child(_checkpoint_departure(continue_after_rest))
	elif checkpoint_action == "barter":
		checkpoint_column.add_child(_role_label("BARTER COMPLETE • One purchase made • the trader packs up and the stock is gone", "flavour", _c("success")))
		var continue_after_barter := _button("CONTINUE JOURNEY AFTER BARTER", _leave_checkpoint)
		_add_button_atlas_icon(continue_after_barter, "navigation")
		body.add_child(_checkpoint_departure(continue_after_barter))
	else:
		checkpoint_column.add_child(_role_label("REST • Consume one food, restore its satiety, set Fatigue to 0, and recover 25 HP.", "flavour", _c("icon_ink")))
		var rest_button := _button("CHOOSE FOOD & REST", _show_rest_food, game.available_food_items().is_empty())
		_add_button_atlas_icon(rest_button, "rest")
		body.add_child(_checkpoint_departure(rest_button))
		_show_checkpoint_barter(checkpoint_column)
		checkpoint_column.add_child(_role_label("PRESS ON • Keep your food and gain Momentum: +1 to every stat for the next checked choice. Normal travel adds 5 Fatigue.", "flavour", _c("icon_ink")))
		var press_on_button := _button("CONTINUE JOURNEY — GAIN MOMENTUM", _press_on_checkpoint)
		_add_button_atlas_icon(press_on_button, "press_on")
		body.add_child(_checkpoint_departure(press_on_button))
	var region_number := int(game.run_state.get("region_index", 0)) + 1
	if ads.should_attempt(region_number, Time.get_ticks_msec()):
		# The provider adapter owns display callbacks. A failed or unavailable request is skipped here.
		ads.mark_attempted(region_number, false, Time.get_ticks_msec())


## A Button's text width normally becomes its minimum width even when its text
## wraps. This holder has the panel's width instead, allowing checkpoint action
## labels to wrap on an actual phone instead of widening the whole page.
func _checkpoint_departure(button: Button) -> Control:
	var holder := Control.new()
	holder.custom_minimum_size.y = button.custom_minimum_size.y
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Keep the real text in an overlay label. Button measures its own text as a
	# non-wrapping minimum width, even with AUTOWRAP_WORD_SMART enabled.
	var action_text := button.text
	button.text = ""
	button.name = "CheckpointDeparture"
	button.accessibility_name = action_text
	button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var label := _role_label(action_text, "action")
	label.name = "CheckpointDepartureLabel"
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_left = 34.0
	label.offset_right = -10.0
	label.offset_top = 2.0
	label.offset_bottom = -2.0
	button.add_child(label)
	holder.add_child(button)
	return holder


func _show_rest_food() -> void:
	if _gameplay_locked():
		return
	_show_action_popup("CHOOSE FOOD FOR REST", game.available_food_items(), func(item_id: String) -> void: _rest(item_id))


func _rest(food_id: String) -> void:
	_run_gameplay_action("rest", [food_id], _after_rest)


func _after_rest(result: Dictionary) -> void:
	if result.get("success", false):
		if sound != null:
			sound.play_effect("rest")
		if is_instance_valid(action_popup):
			action_popup.hide()
		_show_checkpoint()
	_show_toast(str(result.get("text", "")))


## Run-only talents at the checkpoint: one choice after the first region and
## another after the third, from the remaining talents, with no respecs.
## Owned talents read back with their effects; the choice commits through the
## save-aware transaction like every other checkpoint decision.
func _show_checkpoint_talents(checkpoint_column: Control) -> void:
	checkpoint_column.add_child(_eyebrow("Talents"))
	var owned: Array = game.run_state.get("talents", [])
	if owned.is_empty():
		checkpoint_column.add_child(_role_label("No talents yet — the road provides a choice after the first region.", "flavour", _c("icon_ink")))
	else:
		for talent_id: Variant in owned:
			var learned: Dictionary = game.content.get_talent(str(talent_id))
			checkpoint_column.add_child(_role_label("• %s — %s" % [str(learned.get("name", talent_id)), str(learned.get("effect", ""))], "flavour", _c("success")))
	if game.talent_choice_available():
		checkpoint_column.add_child(_role_label("Choose one talent. Browsing is free; learning commits immediately and cannot be undone.", "flavour", _c("icon_ink")))
		for option: Dictionary in game.list_talent_options():
			checkpoint_column.add_child(_role_label("%s — %s %s" % [str(option.get("name", "")), str(option.get("requirement", "")), str(option.get("effect", ""))], "prose"))
			checkpoint_column.add_child(_button("LEARN " + str(option.get("name", "")).to_upper(), _choose_talent.bind(str(option.get("id", ""))), false))


func _choose_talent(talent_id: String) -> void:
	_run_gameplay_action("select_talent", [talent_id], _after_checkpoint_choice)


## Checkpoint trading: one of three saved offers may be purchased instead of
## resting or pressing on. Prices show before commitment; buying packs the
## trader up. Reopening this screen cannot refresh the stock.
func _show_checkpoint_barter(checkpoint_column: Control) -> void:
	var offers: Array = game.checkpoint_offers()
	if offers.is_empty():
		return
	checkpoint_column.add_child(_role_label("BARTER • Buy one of three offers instead of resting or gaining Momentum. Prices show in full before you commit.", "flavour", _c("icon_ink")))
	for index in range(offers.size()):
		var preview: Dictionary = game.trade_preview(index)
		checkpoint_column.add_child(_role_label(str(preview.get("summary", "No offer.")), "prose"))
		if not bool(preview.get("available", false)):
			checkpoint_column.add_child(_role_label(str(preview.get("reason", "")), "flavour", _c("icon_ink")))
			continue
		checkpoint_column.add_child(_button("BUY — " + str(preview.get("summary", "offer")), _buy_offer.bind(index), false))


func _buy_offer(index: int) -> void:
	_run_gameplay_action("trade", [index], _after_checkpoint_choice)


func _after_checkpoint_choice(result: Dictionary) -> void:
	if bool(result.get("success", false)):
		_show_checkpoint()
	_show_toast(str(result.get("text", "")))


func _press_on_checkpoint() -> void:
	_run_gameplay_action("press_on", [], _after_press_on)


func _after_press_on(result: Dictionary) -> void:
	stat_draft = {}
	if bool(result.get("success", false)):
		_render_current()
	_show_toast(str(result.get("text", "")))


func _show_level_allocation(reset_draft: bool = true) -> void:
	if _gameplay_locked():
		return
	if reset_draft or stat_draft.is_empty():
		stat_draft = game.run_state.get("survivor", {}).get("stats", {}).duplicate(true)
	if is_instance_valid(level_popup):
		level_popup.hide()
		level_popup.queue_free()
	level_popup = PopupPanel.new()
	level_popup.exclusive = true
	add_child(level_popup)
	var body := _popup_body(level_popup, 12)
	body.add_child(_overlay_header("ALLOCATE STAT POINTS", _cancel_level_draft))
	allocation_remaining_label = _label("", 14, COLOR_MUTED)
	body.add_child(allocation_remaining_label)
	# Confirmation stays above the only scrollable area. It cannot be pushed
	# below a compact display by the five stat rows or large accessibility text.
	var action_panel := PanelContainer.new()
	action_panel.name = "AllocationFooter"
	var actions := VBoxContainer.new()
	actions.add_theme_constant_override("separation", 6)
	action_panel.add_child(actions)
	actions.add_child(_label("Choose with +, then apply the draft to return to the checkpoint.", 12, COLOR_MUTED))
	allocation_confirm_button = _button("APPLY POINTS & RETURN", _confirm_level_draft, true)
	allocation_confirm_button.name = "ConfirmAllocation"
	allocation_confirm_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(allocation_confirm_button)
	var keep_button := _button("RETURN WITHOUT SPENDING", _cancel_level_draft)
	keep_button.name = "KeepAllocationForLater"
	keep_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(keep_button)
	body.add_child(action_panel)
	body.add_child(HSeparator.new())
	var scroll := TouchScrollContainerScript.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size.y = 120
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 7)
	scroll.add_child(list)
	allocation_stat_controls.clear()
	for stat: String in GameEngine.STATS:
		var row := PanelContainer.new()
		var row_body := VBoxContainer.new()
		row.add_child(row_body)
		var controls := HBoxContainer.new()
		var title := _label("", 15, _accent_color())
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		controls.add_child(title)
		var minus_button := _button("−", _change_stat_draft.bind(stat, -1))
		minus_button.custom_minimum_size = Vector2(48, 44)
		controls.add_child(minus_button)
		var plus_button := _button("+", _change_stat_draft.bind(stat, 1))
		plus_button.custom_minimum_size = Vector2(48, 44)
		controls.add_child(plus_button)
		row_body.add_child(controls)
		var detail_label := _label("", 12, COLOR_MUTED)
		row_body.add_child(detail_label)
		list.add_child(row)
		allocation_stat_controls[stat] = {"title": title, "detail": detail_label, "minus": minus_button, "plus": plus_button}
	_refresh_level_draft_controls()
	_popup_center_responsive(level_popup, 0.98, 0.98)


func _change_stat_draft(stat: String, delta: int) -> void:
	if _gameplay_locked():
		return
	var current := int(game.run_state["survivor"]["stats"].get(stat, 0))
	var proposed := int(stat_draft.get(stat, current))
	if delta < 0:
		stat_draft[stat] = maxi(current, proposed - 1)
	else:
		var spent := 0
		for draft_stat: String in GameEngine.STATS:
			spent += int(stat_draft.get(draft_stat, game.run_state["survivor"]["stats"][draft_stat])) - int(game.run_state["survivor"]["stats"][draft_stat])
		if spent < int(game.run_state.get("unspent_stat_points", 0)):
			stat_draft[stat] = proposed + 1
	_refresh_level_draft_controls()


func _refresh_level_draft_controls() -> void:
	if not is_instance_valid(allocation_remaining_label) or not is_instance_valid(allocation_confirm_button):
		return
	var current_stats: Dictionary = game.run_state["survivor"]["stats"]
	var spent := 0
	for stat: String in GameEngine.STATS:
		spent += int(stat_draft.get(stat, current_stats[stat])) - int(current_stats[stat])
	var remaining := int(game.run_state.get("unspent_stat_points", 0)) - spent
	allocation_remaining_label.text = "%d point%s remaining • draft not applied yet" % [remaining, "" if remaining == 1 else "s"]
	allocation_confirm_button.disabled = spent <= 0
	for stat: String in GameEngine.STATS:
		var proposed := int(stat_draft.get(stat, current_stats[stat]))
		var preview := game.checkpoint_upgrade_preview(stat, proposed)
		var widgets: Dictionary = allocation_stat_controls.get(stat, {})
		var title := widgets.get("title") as Label
		var detail_label := widgets.get("detail") as Label
		var minus_button := widgets.get("minus") as Button
		var plus_button := widgets.get("plus") as Button
		if is_instance_valid(title):
			title.text = "[%s] %s  %d → %d" % [_stat_glyph(stat), str(GameEngine.STAT_LABELS[stat]).to_upper(), int(preview.get("current", 0)), proposed]
		var improvement := float(preview.get("raw_after", 0.0)) - float(preview.get("raw_before", 0.0))
		var detail := "Raw aptitude %.1f%% → %.1f%%  (%+.1f)" % [float(preview.get("raw_before", 0.0)), float(preview.get("raw_after", 0.0)), improvement]
		if int(preview.get("heart_gain", 0)) > 0:
			detail += "  •  +%d HEART / +%d HP" % [int(preview["heart_gain"]), int(preview["heart_gain"]) * GameEngine.HP_PER_HEART]
		detail += "\n" + GameEngine.stat_milestone_text(int(current_stats[stat]), proposed) + " (base only; gear never unlocks)."
		if is_instance_valid(detail_label):
			var weapon: Dictionary = content.get_item(str(game.run_state["survivor"]["equipment"].get("weapon", "")))
			if str(weapon.get("combat", {}).get("attack_stat", "")) == stat:
				detail += "\n" + str(weapon.get("signature", "")).capitalize() + (" MASTERY UNLOCKS ON CONFIRM" if int(current_stats[stat]) < 6 and proposed >= 6 else " • mastery at base 6" if proposed < 6 else " • mastered")
				var affinity_min := int(weapon.get("affinity_min", 0))
				if affinity_min > 0:
					detail += " • AFFINITY MET" if proposed >= affinity_min else " • affinity needs %d (unwieldy until then)" % affinity_min
			detail_label.text = detail
		if is_instance_valid(minus_button):
			minus_button.disabled = proposed <= int(current_stats[stat])
		if is_instance_valid(plus_button):
			plus_button.disabled = remaining <= 0


func _confirm_level_draft() -> void:
	_run_gameplay_action("allocate", [stat_draft.duplicate(true)], _after_allocation)


func _after_allocation(result: Dictionary) -> void:
	if result.get("success", false):
		if sound != null:
			sound.play_effect("level_up")
		stat_draft = {}
		if is_instance_valid(level_popup):
			level_popup.hide()
		_show_checkpoint()
		var receipt := "Stat points applied."
		if int(result.get("heart_gain", 0)) > 0:
			receipt += " +%d HEART." % int(result["heart_gain"])
		for stat: Variant in result.get("mastery_unlocked", []):
			receipt += " %s MASTERY UNLOCKED." % str(stat).to_upper()
		for stat: Variant in result.get("specialization_unlocked", []):
			receipt += " %s SPECIALIZATION UNLOCKED." % str(stat).to_upper()
		receipt += " Choose REST or CONTINUE JOURNEY."
		_show_toast(receipt)
	else:
		_show_toast(str(result.get("text", "")))


func _cancel_level_draft() -> void:
	if _gameplay_locked():
		return
	stat_draft = {}
	if is_instance_valid(level_popup):
		level_popup.hide()


func _show_action_popup(title_text: String, item_ids: Array[String], callback: Callable) -> void:
	if is_instance_valid(action_popup):
		action_popup.queue_free()
	action_popup = PopupPanel.new()
	action_popup.exclusive = true
	add_child(action_popup)
	var body := _popup_body(action_popup, 14)
	body.add_child(_overlay_header(title_text, action_popup.hide))
	for item_id: String in item_ids:
		var item: Dictionary = content.get_item(item_id)
		var effects: Dictionary = item.get("effects", {})
		var detail := "×%d" % game.get_item_quantity(item_id)
		if effects.has("satiety"):
			detail += " • FOOD +%d" % int(effects["satiety"])
		if effects.has("health"):
			detail += " • HP %+d" % int(effects["health"])
		var treatment_names: Array[String] = []
		for condition_id: Variant in effects.get("remove_conditions", []):
			if str(condition_id) in game.run_state.get("survivor", {}).get("conditions", []):
				treatment_names.append(str(content.get_condition(str(condition_id)).get("name", condition_id)))
		if not treatment_names.is_empty():
			detail += " • TREATS %s" % ", ".join(treatment_names)
		body.add_child(_button("%s  %s" % [item.get("name", item_id), detail], func() -> void:
			callback.call(item_id)
		))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(spacer)
	_popup_center_responsive(action_popup, 0.88, 0.48)


func _leave_checkpoint() -> void:
	_run_gameplay_action("leave_checkpoint", [], _after_leave_checkpoint)


func _after_leave_checkpoint(_result: Dictionary) -> void:
	stat_draft = {}
	_render_current()


func _finish_run(victory: bool) -> void:
	if _gameplay_locked():
		return
	if not bool(game.run_state.get("finalized", false)):
		_accept_action_result(combat_transaction.flush(game, saves, profile), func(_result: Dictionary) -> void: _finish_run(victory))
		return
	var summary := game.summary()
	_clear_page()
	_set_atmosphere("death")
	_title("THE CITADEL OPENS" if victory else "THE ROAD ENDS", "Victory" if victory else "Permadeath")
	var body := _panel()
	# The record scrolls; the two ways out of this screen never do.
	var summary_scroll := TouchScrollContainerScript.new()
	summary_scroll.name = "RunSummaryScroll"
	summary_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	summary_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(summary_scroll)
	var summary_column := _scroll_column(summary_scroll, 7)
	# Canvas death screen: the survivor's ending as a Literata headline, the cause
	# as prose, then the run itself as a ledger of hairline rows.
	var ending := "%s \"%s\" reached clean air beyond the East Gate." % [summary["survivor"], summary["callsign"]] if victory else "%s \"%s\" did not reach the gate." % [summary["survivor"], summary["callsign"]]
	summary_column.add_child(_role_label(ending, "heading", _c("success") if victory else _c("text")))
	if not victory:
		summary_column.add_child(_role_label(str(summary.get("cause", "The road claimed the survivor.")), "prose"))
	var ledger := VBoxContainer.new()
	ledger.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ledger.add_theme_constant_override("separation", 0)
	summary_column.add_child(ledger)
	_ledger_row(ledger, "Regions reached", str(summary["regions_reached"]))
	_ledger_row(ledger, "Events resolved", str(summary["events_resolved"]))
	_ledger_row(ledger, "Level reached", "%d · %d XP" % [summary.get("level", 1), summary.get("experience", 0)])
	_ledger_row(ledger, "Stat points earned", str(summary.get("stat_points_earned", 0)))
	if not victory:
		var condition_text := ", ".join(summary.get("conditions", [])) if not summary.get("conditions", []).is_empty() else "None"
		var equipment_text := ", ".join(summary.get("equipment", [])) if not summary.get("equipment", []).is_empty() else "Unarmed and unprotected"
		_ledger_row(ledger, "Final conditions", condition_text)
		_ledger_row(ledger, "Equipped", equipment_text)
		_ledger_row(ledger, "Enemies defeated", str(summary.get("enemies_defeated", []).size()))
		_ledger_row(ledger, "Strongest defeated", str(summary.get("strongest_enemy", "None")))
		summary_column.add_child(_permadeath_notice(int(summary.get("xp_lost", 0))))
	body.add_child(_button("New run", _reset_after_run))
	var menu_button := _button("Main menu", _reset_to_menu)
	menu_button.custom_minimum_size.y = TOUCH_TARGET
	menu_button.add_theme_color_override("font_color", _c("muted"))
	menu_button.add_theme_stylebox_override("normal", _style_box(Color.TRANSPARENT, Color.TRANSPARENT))
	body.add_child(menu_button)


func _reset_after_run() -> void:
	if _gameplay_locked():
		return
	game.run_state = {}
	_begin_candidate_selection()


func _reset_to_menu() -> void:
	if _gameplay_locked():
		return
	game.run_state = {}
	_show_main_menu()


func _show_road_chronicle(tab: String = "") -> void:
	if tab != "":
		chronicle_tab = tab
	_clear_page()
	_set_atmosphere("plain")
	_title("ROAD CHRONICLE", "What the road recorded")
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 6)
	for tab_data: Array in [["runs", "RUNS"], ["discoveries", "DISCOVERIES"]]:
		var tab_id := str(tab_data[0])
		var tab_button := _button(str(tab_data[1]), _show_road_chronicle.bind(tab_id))
		tab_button.name = "ChronicleTab_" + tab_id
		tab_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab_button.disabled = chronicle_tab == tab_id
		tabs.add_child(tab_button)
	page.add_child(tabs)
	if chronicle_tab == "runs":
		_build_chronicle_runs()
	else:
		_build_chronicle_discoveries()
	page.add_child(_button("BACK", _show_main_menu))


## Twenty stored summaries, rendered from what each one actually recorded. An
## older summary that never captured a field says so instead of inventing it.
func _build_chronicle_runs() -> void:
	var history: Array = profile.get("run_history", [])
	var completed := _label("%d recorded %s  •  %d deaths  •  %d victories" % [history.size(), "run" if history.size() == 1 else "runs", profile.get("deaths", 0), profile.get("victories", 0)], 14, _c("muted"))
	completed.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(completed)
	var scroll := TouchScrollContainerScript.new()
	scroll.name = "ChronicleRunsScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	scroll.add_child(list)
	if history.is_empty():
		list.add_child(_label("No run has ended yet. Every completed journey is recorded here.", 14, _c("muted")))
		return
	for summary: Dictionary in history:
		var card := PanelContainer.new()
		var card_body := VBoxContainer.new()
		card_body.add_theme_constant_override("separation", 3)
		card.add_child(card_body)
		var victory := str(summary.get("result", "")) == "victory"
		var callsign := str(summary.get("callsign", ""))
		var name_text := str(summary.get("survivor", "Unrecorded survivor"))
		if callsign != "":
			name_text += " \"%s\"" % callsign
		card_body.add_child(_label(name_text, 16, COLOR_TEXT))
		card_body.add_child(_label("REACHED THE CITADEL" if victory else "DIED ON THE ROAD", 12, _c("success") if victory else _c("danger")))
		card_body.add_child(_label("Region reached: %s" % _summary_field(summary, "region"), 13, _c("muted")))
		card_body.add_child(_label("Level: %s" % _summary_field(summary, "level"), 13, _c("muted")))
		card_body.add_child(_label("Equipped: %s" % _summary_list(summary, "equipment", "Nothing recorded"), 13, _c("muted")))
		card_body.add_child(_label("Strongest defeated: %s" % _summary_field(summary, "strongest_enemy"), 13, _c("muted")))
		if not victory:
			card_body.add_child(_label("Cause: %s" % _summary_field(summary, "cause"), 13, _c("danger")))
		list.add_child(card)


## Absent means absent. Older summaries predate some fields and must not be
## filled in with a plausible guess.
func _summary_field(summary: Dictionary, key: String) -> String:
	if not summary.has(key):
		return "Not recorded"
	var value := str(summary[key])
	return value if value.strip_edges() != "" else "Not recorded"


func _summary_list(summary: Dictionary, key: String, empty_text: String) -> String:
	if not summary.has(key) or typeof(summary[key]) != TYPE_ARRAY:
		return "Not recorded"
	var values: Array = summary[key]
	if values.is_empty():
		return empty_text
	return ", ".join(values)


func _build_chronicle_discoveries() -> void:
	var entries: Array = content.get_discovery_entries().values()
	entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var thread_compare := str(a.get("thread", "")).naturalnocasecmp_to(str(b.get("thread", "")))
		return int(a.get("order", 0)) < int(b.get("order", 0)) if thread_compare == 0 else thread_compare < 0
	)
	var discovered: Array = profile.get("discovered_story_nodes", [])
	# Chapters and accounts are different counts, and both ignore anything this
	# build cannot reach so a disabled expansion is never advertised.
	var available_chapters: Dictionary = content.get_discovery_entries()
	var found_chapters := 0
	var found_accounts := 0
	for chapter_id: String in StoryDiscoveryScript.chapter_ids(discovered):
		if available_chapters.has(chapter_id):
			found_chapters += 1
			found_accounts += StoryDiscoveryScript.variant_tokens(discovered, chapter_id).size()
	var progress := _label("%d / %d chapters  •  %d recorded %s  •  %d people remembered  •  %d endings" % [found_chapters, entries.size(), found_accounts, "account" if found_accounts == 1 else "accounts", profile.get("discovered_characters", []).size(), profile.get("discovered_endings", []).size()], 14, _c("muted"))
	progress.name = "ChronicleProgress"
	progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	page.add_child(progress)
	var scroll := TouchScrollContainerScript.new()
	scroll.name = "ChronicleDiscoveriesScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	page.add_child(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 9)
	scroll.add_child(list)
	var current_thread := ""
	for entry: Dictionary in entries:
		var thread_name := str(entry.get("thread", "Other Records"))
		if thread_name != current_thread:
			current_thread = thread_name
			list.add_child(_label(current_thread.to_upper(), 15, _accent_color()))
		var entry_id := str(entry.get("id", ""))
		var stored_tokens: Array = StoryDiscoveryScript.variant_tokens(discovered, entry_id)
		var card := PanelContainer.new()
		var card_body := VBoxContainer.new()
		card_body.add_theme_constant_override("separation", 4)
		card.add_child(card_body)
		if not stored_tokens.is_empty():
			if stored_tokens.size() > 1:
				card_body.add_child(_label("%d ACCOUNTS FROM DIFFERENT RUNS" % stored_tokens.size(), 11, _accent_color()))
			for account_index: int in range(stored_tokens.size()):
				var stored_token := str(stored_tokens[account_index])
				var display_entry := entry
				if ":" in stored_token:
					var variant_id := stored_token.get_slice(":", 1)
					for variant: Dictionary in entry.get("variants", []):
						if str(variant.get("id", "")) == variant_id:
							display_entry = entry.duplicate(true)
							for key: String in variant:
								display_entry[key] = variant[key]
							break
				if account_index > 0:
					card_body.add_child(_label("— a different survivor recorded —", 11, _c("muted")))
				card_body.add_child(_label(str(display_entry.get("title", "Recovered account")), 17, COLOR_TEXT))
				card_body.add_child(_label(str(display_entry.get("body", "")), 14, _c("muted")))
				var state_text := str(display_entry.get("character_state", ""))
				if state_text != "":
					card_body.add_child(_label(state_text, 12, _c("success")))
		else:
			card_body.add_child(_label("◇  UNRESOLVED", 15, _c("disabled")))
			card_body.add_child(_label(str(entry.get("hint", "Another road may reveal this account.")), 13, _c("muted")))
		list.add_child(card)


## Shown only when the player chooses to continue, and dismissible. Everything
## here is read from the saved run: where it stopped, what it is waiting on, the
## last thing that happened, and what the survivor is carrying.
func _continue_run() -> void:
	if _gameplay_locked():
		return
	if is_instance_valid(recap_popup):
		recap_popup.queue_free()
	recap_popup = PopupPanel.new()
	recap_popup.exclusive = true
	add_child(recap_popup)
	var body := _popup_body(recap_popup, 12)
	body.add_child(_overlay_header("WHERE YOU STOPPED", _dismiss_recap))
	var scroll := TouchScrollContainerScript.new()
	scroll.name = "ResumeRecapScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var lines := VBoxContainer.new()
	lines.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lines.add_theme_constant_override("separation", 6)
	scroll.add_child(lines)
	for line: String in _resume_recap_lines():
		lines.add_child(_label(line, 14))
	var resume := _button("RESUME", _dismiss_recap)
	resume.name = "ResumeRun"
	body.add_child(resume)
	_popup_bottom_responsive(recap_popup, 0.92, 0.6)


func _resume_recap_lines() -> Array:
	var lines: Array = []
	var survivor: Dictionary = game.run_state.get("survivor", {})
	var region_index := int(game.run_state.get("region_index", 0))
	var region_name := str(game.current_region().get("name", "the East Citadel"))
	lines.append("%s \"%s\" — %s, region %d of %d." % [survivor.get("name", "Your survivor"), survivor.get("callsign", ""), region_name, region_index + 1, content.ordered_regions().size()])
	var phase := str(game.run_state.get("phase", "event"))
	var waiting := "An encounter is waiting for your choice."
	match phase:
		"roll_pending", "resolving":
			waiting = "A saved roll is waiting to be revealed."
		"combat", "combat_roll_pending":
			waiting = "You are mid-fight with %s." % str(content.get_adversary(str(game.run_state.get("combat_state", {}).get("adversary_id", ""))).get("name", "an adversary"))
		"result":
			waiting = "You were reading the outcome of your last choice."
		"checkpoint":
			waiting = "You are at a checkpoint, deciding how to leave it."
	lines.append(waiting)
	var last_result: Dictionary = game.run_state.get("last_result", {})
	if not last_result.is_empty():
		lines.append("Last choice: %s — %s" % [str(last_result.get("choice", "a decision")), str(last_result.get("outcome_text", ""))])
		var receipt_changes: Array = last_result.get("changes", [])
		lines.append("Committed change: %s" % (", ".join(PackedStringArray(receipt_changes)) if not receipt_changes.is_empty() else "none."))
	var condition_names: Array = []
	for condition_id: Variant in survivor.get("conditions", []):
		condition_names.append(str(content.get_condition(str(condition_id)).get("name", condition_id)))
	lines.append("Carrying: %s" % (", ".join(condition_names) if not condition_names.is_empty() else "no active conditions"))
	return lines


func _dismiss_recap() -> void:
	if is_instance_valid(recap_popup):
		recap_popup.hide()
	_render_current()


func _show_first_run_tutorial() -> void:
	_pause_story(true)
	if is_instance_valid(tutorial_popup):
		tutorial_popup.queue_free()
	tutorial_popup = PopupPanel.new()
	tutorial_popup.exclusive = not (is_instance_valid(settings_popup) and settings_popup.visible)
	add_child(tutorial_popup)
	var body := _popup_body(tutorial_popup, 15)
	body.add_child(_overlay_header("HOW THE ROAD WORKS", _dismiss_tutorial))
	var scroll := TouchScrollContainerScript.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(scroll)
	var instructions := VBoxContainer.new()
	instructions.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	instructions.add_theme_constant_override("separation", 10)
	scroll.add_child(instructions)
	instructions.add_child(_label("1. Read the story and odds", 19, _accent_color()))
	instructions.add_child(_label("Introductions and outcomes reveal gradually. Double-tap the story to show it immediately. Each checked choice shows both its exact success percentage and the minimum D20 roll needed."))
	instructions.add_child(_label("2. Prepare between events", 19, _accent_color()))
	instructions.add_child(_label("Tap the backpack icon to equip gear, use supplies, or inspect what you carry. Rest is only available after each region and consumes food."))
	instructions.add_child(_label("3. Protect hearts and food", 19, _accent_color()))
	instructions.add_child(_label("Grit determines your 50-HP hearts and can earn more at later thresholds. One food icon empties every two travel events; travelling while empty costs one heart."))
	instructions.add_child(_label("Failed choices can cause conditions such as Shaken. The result explains each new effect; open STATUS to review helpful and harmful conditions, see their remaining duration, and use a matching treatment you carry."))
	instructions.add_child(_label("4. Fight one round at a time", 19, _accent_color()))
	instructions.add_child(_label("Read the enemy's clue before choosing. Attack can miss. Block risks extra damage but earns Riposte; Dodge earns Opening. Use that benefit on your next action. Heavy blows are easier to dodge, sweeps easier to block. Tap the clue for details. Old saved fights keep Guard until they finish."))
	instructions.add_child(_label("Weapons have signature effects; base stat 6 unlocks mastery. A ready Opportunity is one powerful attack per fight, with no timer. Smoke guarantees escape only where fleeing is allowed. Manual and Quick Roll use the same saved dice."))
	instructions.add_child(_label("5. Earn experience, grow at checkpoints", 19, _accent_color()))
	instructions.add_child(_label("Surviving events grants steady XP; difficult successes and defeated enemies grant more. Levels bank run-only stat points that you may allocate at checkpoints. Then rest with food or press on for Momentum. Death erases every level and all XP."))
	instructions.add_child(_label("6. Death is final", 19, COLOR_DANGER))
	instructions.add_child(_label("There is one autosaved run. Death erases it; settings, run history, and cosmetic ownership remain."))
	body.add_child(_button("I UNDERSTAND", _dismiss_tutorial))
	_popup_center_responsive(tutorial_popup, 0.92, 0.9)


func _dismiss_tutorial() -> void:
	if not _commit_profile_changes({"tutorial_seen": true}):
		return
	if is_instance_valid(tutorial_popup):
		tutorial_popup.hide()
	if not (is_instance_valid(settings_popup) and settings_popup.visible):
		_pause_story(false)


func _show_inventory(reset_filter: bool = true) -> void:
	if _gameplay_locked():
		return
	if game.run_state.is_empty():
		return
	_pause_story(true)
	if reset_filter:
		inventory_filter = "all"
		inventory_scroll_offset = 0
	if is_instance_valid(item_detail_popup):
		item_detail_popup.hide()
	if is_instance_valid(inventory_popup):
		# Remember where the list was so returning from an item sheet does not
		# drop the player back at the top of a long inventory.
		var previous_scroll := inventory_popup.find_child("InventoryScroll", true, false) as ScrollContainer
		if is_instance_valid(previous_scroll):
			inventory_scroll_offset = previous_scroll.scroll_vertical
		inventory_popup.hide()
		inventory_popup.queue_free()
	inventory_popup = PopupPanel.new()
	inventory_popup.exclusive = true
	add_child(inventory_popup)
	var body := _popup_body(inventory_popup, 12)
	body.add_child(_overlay_header("INVENTORY", _close_inventory))

	var equipment_grid := GridContainer.new()
	equipment_grid.columns = ResponsiveRulesScript.equipment_slot_columns(get_viewport_rect().size.x)
	equipment_grid.add_theme_constant_override("h_separation", 5)
	equipment_grid.add_theme_constant_override("v_separation", 5)
	for slot: String in GameEngine.EQUIPMENT_SLOTS:
		equipment_grid.add_child(_equipment_slot(slot))
	body.add_child(equipment_grid)

	# A narrow phone needs two equipment rows. Put its five filters above the
	# pack so their vertical rail cannot impose another 240px minimum height.
	var horizontal_filters := get_viewport_rect().size.x < ResponsiveRulesScript.COMPACT_EQUIPMENT_WIDTH
	var inventory_body: BoxContainer = VBoxContainer.new() if horizontal_filters else HBoxContainer.new()
	inventory_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_body.add_theme_constant_override("separation", 7)
	body.add_child(inventory_body)
	var filters: BoxContainer = HBoxContainer.new() if horizontal_filters else VBoxContainer.new()
	filters.custom_minimum_size.x = 44
	filters.add_theme_constant_override("separation", 5)
	inventory_body.add_child(filters)
	for filter_data: Array in [["all", "◈", "All items"], ["gear", "◆", "Gear"], ["supplies", "+", "Supplies"], ["ammo", "•", "Ammunition"], ["utility", "⌁", "Utility"]]:
		filters.add_child(_inventory_filter_button(str(filter_data[0]), str(filter_data[1]), str(filter_data[2])))
	var scroll := TouchScrollContainerScript.new()
	scroll.name = "InventoryScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# The pack grid sizes to the rail it sits beside; it never scrolls sideways,
	# and its last column keeps clear of the vertical scrollbar.
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	inventory_body.add_child(scroll)
	var grid_margin := MarginContainer.new()
	grid_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_margin.add_theme_constant_override("margin_right", SCROLLBAR_GUTTER)
	scroll.add_child(grid_margin)
	var grid := GridContainer.new()
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.columns = ResponsiveRulesScript.inventory_columns(get_viewport_rect().size.x - (48.0 if horizontal_filters else 96.0))
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	grid_margin.add_child(grid)
	for item_id: String in _filtered_inventory_ids():
		grid.add_child(_inventory_cell(item_id))
	if grid.get_child_count() == 0:
		grid.add_child(_label("No items match this filter.", 14, _c("muted")))
	scroll.set_deferred("scroll_vertical", inventory_scroll_offset)
	body.add_child(_inventory_weight_footer())
	_popup_center_responsive(inventory_popup)


func _equipment_slot(slot: String) -> Button:
	var item_id := str(game.run_state["survivor"]["equipment"].get(slot, ""))
	var item: Dictionary = content.get_item(item_id) if item_id != "" else {}
	var button := Button.new()
	button.custom_minimum_size.y = 64
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.tooltip_text = "Open %s equipment slot" % slot
	button.accessibility_name = "%s slot%s" % [slot.capitalize(), "; equipped with %s" % item.get("name", item_id) if item_id != "" else "; empty"]
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 5)
	var icon = ItemIconScript.new()
	icon.custom_minimum_size = Vector2(34, 34)
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon.configure(str(item.get("icon_id", "slot_%s" % slot)), str(item.get("category", slot)), palette)
	column.add_child(icon)
	var label := _label("%s%s" % [slot.to_upper(), "  ✓" if item_id != "" else ""], 9, _accent_color() if item_id != "" else COLOR_MUTED)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(label)
	button.add_child(column)
	button.pressed.connect(func() -> void:
		if item_id == "":
			inventory_filter = "slot:%s" % slot
			_show_inventory(false)
		else:
			_show_item_detail(item_id)
	)
	return button


func _inventory_filter_button(filter_name: String, glyph: String, description: String) -> Button:
	var button := Button.new()
	button.text = glyph
	button.tooltip_text = description
	button.accessibility_name = "Show %s" % description.to_lower()
	button.toggle_mode = true
	button.button_pressed = inventory_filter == filter_name
	button.custom_minimum_size = Vector2(44, 44)
	button.add_theme_font_size_override("font_size", int(16 * float(profile.get("font_scale", 1.0))))
	# Canvas filter rail: the active tab is marked by a 2px accent edge on its
	# leading side, not by outlining the whole tile.
	var selected := inventory_filter == filter_name
	var normal := StyleBoxFlat.new()
	normal.bg_color = _c("surface_raised") if selected else Color(_c("surface_raised"), 0.0)
	normal.border_color = _c("accent")
	normal.border_width_left = 2 if selected else 0
	normal.set_corner_radius_all(CORNER_RADIUS)
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate()
	hover.bg_color = _c("surface_raised")
	hover.border_color = _c("accent_strong")
	button.add_theme_stylebox_override("hover", hover)
	button.pressed.connect(_set_inventory_filter.bind(filter_name))
	return button


## The weight label sits above its value so Large text stays legible on phones.
func _inventory_weight_footer() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = "InventoryWeightFooter"
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)
	var icon = ItemIconScript.new()
	icon.custom_minimum_size = Vector2(24, 24)
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.configure("weight", "weight", palette)
	row.add_child(icon)
	var total := game.get_total_weight()
	var capacity := game.get_carry_capacity()
	var overweight := total > capacity
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 5)
	row.add_child(column)
	var heading := VBoxContainer.new()
	heading.add_theme_constant_override("separation", 2)
	column.add_child(heading)
	var heading_label := _role_label("CARRY WEIGHT", "label", _c("danger") if overweight else _c("muted"))
	heading_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(heading_label)
	var remaining := capacity - total
	# "over" rather than "over capacity": the row is already red, and the longer
	# phrasing squeezes the label beside it down to an ellipsis.
	var value_text := "%.1f / %.1f kg · over" % [total, capacity] if overweight else "%.1f / %.1f kg · %.1f left" % [total, capacity, remaining]
	# Untracked: the canvas sets this readout at 0.02em, and tracked numerals here
	# only crowd out the label beside them.
	var value_label := _role_label(value_text, "body", _c("danger") if overweight else _c("text"))
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	heading.add_child(value_label)
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.max_value = maxf(1.0, capacity)
	bar.value = total
	bar.custom_minimum_size = Vector2(72, 4)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_meter_style(bar, _c("danger") if overweight else _c("text"))
	column.add_child(bar)
	return panel


func _filtered_inventory_ids() -> Array[String]:
	var ids: Array[String] = []
	for raw_id: Variant in game.run_state["survivor"]["inventory"].keys():
		var item_id := str(raw_id)
		var item: Dictionary = content.get_item(item_id)
		var category := str(item.get("category", "utility"))
		var slot_filter := inventory_filter.trim_prefix("slot:") if inventory_filter.begins_with("slot:") else ""
		var matches := inventory_filter == "all"
		matches = matches or (inventory_filter == "gear" and category in ["weapon", "armor", "accessory", "backpack"])
		matches = matches or (inventory_filter == "supplies" and category == "consumable")
		matches = matches or (inventory_filter == "ammo" and category == "ammunition")
		matches = matches or (inventory_filter == "utility" and category == "utility")
		matches = matches or (slot_filter != "" and str(item.get("equipment_slot", "")) == slot_filter)
		if matches:
			ids.append(item_id)
	ids.sort_custom(func(a: String, b: String) -> bool:
		var a_equipped := _is_item_equipped(a)
		var b_equipped := _is_item_equipped(b)
		if a_equipped != b_equipped:
			return a_equipped
		var a_item := content.get_item(a)
		var b_item := content.get_item(b)
		var a_key := "%s:%s" % [a_item.get("category", ""), a_item.get("name", a)]
		var b_key := "%s:%s" % [b_item.get("category", ""), b_item.get("name", b)]
		return a_key < b_key
	)
	return ids


func _inventory_cell(item_id: String) -> Button:
	var item: Dictionary = content.get_item(item_id)
	var quantity := game.get_item_quantity(item_id)
	var button := Button.new()
	button.name = "InventoryCell_%s" % item_id
	button.custom_minimum_size = Vector2(0, 72)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.tooltip_text = str(item.get("description", ""))
	button.accessibility_name = "%s. Quantity %d%s" % [item.get("name", item_id), quantity, ". Equipped" if _is_item_equipped(item_id) else ""]
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 5)
	column.add_theme_constant_override("separation", 0)
	var icon = ItemIconScript.new()
	icon.custom_minimum_size = Vector2(40, 40)
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon.configure(str(item.get("icon_id", item_id)), str(item.get("category", "utility")), palette)
	column.add_child(icon)
	var markers := HBoxContainer.new()
	markers.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var equipped := _label("✓" if _is_item_equipped(item_id) else "", 11, _accent_color())
	equipped.mouse_filter = Control.MOUSE_FILTER_IGNORE
	equipped.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	markers.add_child(equipped)
	var quantity_label := _label("×%d" % quantity, 10, COLOR_TEXT)
	quantity_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	quantity_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	quantity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	markers.add_child(quantity_label)
	column.add_child(markers)
	button.add_child(column)
	button.pressed.connect(_show_item_detail.bind(item_id))
	return button


func _set_inventory_filter(filter_name: String) -> void:
	inventory_filter = filter_name
	inventory_scroll_offset = 0
	_show_inventory(false)


func _is_item_equipped(item_id: String) -> bool:
	return item_id in game.run_state.get("survivor", {}).get("equipment", {}).values()


func _show_item_detail(item_id: String) -> void:
	if _gameplay_locked():
		return
	var item: Dictionary = content.get_item(item_id)
	if item.is_empty() or game.get_item_quantity(item_id) <= 0:
		return
	if is_instance_valid(item_detail_popup):
		item_detail_popup.queue_free()
	item_detail_popup = PopupPanel.new()
	# This sheet sits above the already-modal inventory window.
	item_detail_popup.exclusive = false
	add_child(item_detail_popup)
	var body := _popup_body(item_detail_popup, 12)
	body.add_child(_overlay_header(str(item.get("name", item_id)), _close_item_detail))
	# Description, modifiers, and the comparison share one scroll. The header and
	# every action stay outside it so they remain reachable on a short screen.
	var detail_scroll := TouchScrollContainerScript.new()
	detail_scroll.name = "ItemDetailScroll"
	detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(detail_scroll)
	var detail_column := VBoxContainer.new()
	detail_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_column.add_theme_constant_override("separation", 6)
	detail_scroll.add_child(detail_column)
	var icon = ItemIconScript.new()
	icon.custom_minimum_size = Vector2(56, 56)
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon.configure(str(item.get("icon_id", item_id)), str(item.get("category", "utility")), palette)
	detail_column.add_child(icon)
	detail_column.add_child(_label(str(item.get("description", "")), 15))
	var quantity := game.get_item_quantity(item_id)
	detail_column.add_child(_label(_item_effect_text(item), 13, _accent_color()))
	detail_column.add_child(_label("×%d  •  %.1f kg each  •  %.1f kg total" % [quantity, float(item.get("weight", 0.0)), float(item.get("weight", 0.0)) * quantity], 12, COLOR_MUTED))
	if item.has("signature"):
		_show_contextual_tip("weapon_mastery")
	var comparison: Dictionary = EquipmentComparisonScript.compare(game, item_id)
	if bool(comparison.get("available", false)):
		detail_column.add_child(_comparison_panel(comparison))
	var actions_locked := _inventory_actions_locked()
	if actions_locked:
		body.add_child(_label("Actions are unavailable until the current roll or combat turn is resolved.", 13, COLOR_MUTED))
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 6)
	var slot := str(item.get("equipment_slot", ""))
	if _is_item_equipped(item_id) and not actions_locked:
		var unequip := _button("UNEQUIP", _inventory_action.bind("unequip", item_id, slot))
		unequip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		actions.add_child(unequip)
	elif slot != "" and not actions_locked:
		var lock_reason := game.equipment_lock_reason(item_id)
		var equip := _button("EQUIP", _inventory_action.bind("equip", item_id, slot), lock_reason != "")
		if lock_reason != "":
			body.add_child(_label(lock_reason, 13, _c("muted")))
		equip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		actions.add_child(equip)
	if bool(item.get("consumable", false)) and item_id != "smoke_bomb" and not actions_locked:
		var use := _button("USE", _inventory_action.bind("use", item_id, ""))
		use.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		actions.add_child(use)
	if actions.get_child_count() > 0:
		body.add_child(actions)
	if not _is_item_equipped(item_id) and not actions_locked:
		var drop_row := HBoxContainer.new()
		var drop_one := _button("DROP ONE", _confirm_drop.bind(item_id, 1))
		drop_one.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		drop_row.add_child(drop_one)
		var drop_all := _button("DROP ALL", _confirm_drop.bind(item_id, quantity), quantity <= 1)
		drop_all.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		drop_row.add_child(drop_all)
		body.add_child(drop_row)
	_popup_bottom_responsive(item_detail_popup, 0.92, 0.78 if bool(comparison.get("available", false)) else 0.62)


## Read-only comparison rows. Every value arrives from EquipmentComparison,
## which reads the domain calculations; this method only formats them.
func _comparison_panel(comparison: Dictionary) -> Control:
	var panel := PanelContainer.new()
	panel.name = "EquipmentComparisonPanel"
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	panel.add_child(column)

	var equipped := bool(comparison.get("already_equipped", false))
	var current_name := str(comparison.get("current_name", ""))
	column.add_child(_label("EQUIPPED NOW" if equipped else "IF YOU EQUIP THIS", 12, _accent_color()))
	if equipped:
		column.add_child(_label("%s is in your %s slot." % [comparison["item_name"], str(comparison["slot"]).capitalize()], 13))
	else:
		column.add_child(_label("%s  →  %s" % [current_name if current_name != "" else "Nothing", comparison["item_name"]], 14))

	# An item already in its slot has nothing to compare, so the same rows report
	# the neutral values it is currently providing.
	var slot := str(comparison["slot"])
	var weapon: Dictionary = comparison["weapon"]
	if bool(weapon.get("changes", false)) or (equipped and slot == "weapon"):
		var current_weapon: Dictionary = weapon["current"]
		var proposed_weapon: Dictionary = weapon["proposed"]
		column.add_child(_comparison_heading("ATTACK"))
		column.add_child(_comparison_row("Damage", "%d–%d" % [current_weapon["damage_min"], current_weapon["damage_max"]], "%d–%d" % [proposed_weapon["damage_min"], proposed_weapon["damage_max"]], int(weapon["damage_max_delta"])))
		column.add_child(_comparison_row("Hit chance", "%d%%" % int(current_weapon["hit_chance"]), "%d%%" % int(proposed_weapon["hit_chance"]), int(weapon["hit_chance_delta"])))
		column.add_child(_comparison_row("Attack stat", "%s %d" % [str(current_weapon["attack_stat"]).capitalize(), int(current_weapon["stat_value"])], "%s %d" % [str(proposed_weapon["attack_stat"]).capitalize(), int(proposed_weapon["stat_value"])], 0))
		column.add_child(_comparison_row("Signature", _signature_summary(current_weapon), _signature_summary(proposed_weapon), 0))

	var defense: Dictionary = comparison["defense"]
	if bool(defense.get("changes", false)) or (equipped and slot in ["armor", "accessory"]):
		var current_defense: Dictionary = defense["current"]
		var proposed_defense: Dictionary = defense["proposed"]
		column.add_child(_comparison_heading("DEFENCE"))
		column.add_child(_comparison_row("Armor rating", str(current_defense["armor_rating"]), str(proposed_defense["armor_rating"]), int(proposed_defense["armor_rating"]) - int(current_defense["armor_rating"])))
		column.add_child(_comparison_row("A %d hit takes" % int(defense["sample_hit"]), str(current_defense["sample_taken"]), str(proposed_defense["sample_taken"]), -int(defense["taken_delta"])))
		column.add_child(_comparison_row("Block", "%d%%" % int(current_defense["block_chance"]), "%d%%" % int(proposed_defense["block_chance"]), int(defense["block_delta"])))
		column.add_child(_comparison_row("Dodge", "%d%%" % int(current_defense["dodge_chance"]), "%d%%" % int(proposed_defense["dodge_chance"]), int(defense["dodge_delta"])))

	var stat_rows: Array = []
	for row: Dictionary in comparison["stats"]:
		if int(row["delta"]) != 0:
			stat_rows.append(row)
	for row: Dictionary in comparison["approaches"]:
		if int(row["delta"]) != 0:
			stat_rows.append(row)
	if not stat_rows.is_empty():
		column.add_child(_comparison_heading("CHECKS"))
		for row: Dictionary in stat_rows:
			var name_text: String = "%s approach" % str(row["approach"]).capitalize() if row.has("approach") else str(row["stat"]).capitalize()
			column.add_child(_comparison_row(name_text, "%+d" % int(row["current"]) if row.has("approach") else str(row["current"]), "%+d" % int(row["proposed"]) if row.has("approach") else str(row["proposed"]), int(row["delta"])))

	var carry: Dictionary = comparison["carry"]
	if not is_equal_approx(float(carry["capacity_current"]), float(carry["capacity_proposed"])) or bool(carry["over_current"]) or bool(carry["over_proposed"]):
		column.add_child(_comparison_heading("CARRYING"))
		column.add_child(_comparison_row("Capacity", "%.1f kg" % float(carry["capacity_current"]), "%.1f kg" % float(carry["capacity_proposed"]), roundi(float(carry["capacity_delta"]))))
		var weight_text := "%.1f kg carried" % float(carry["weight"])
		if bool(carry["over_proposed"]):
			weight_text += "  •  over capacity"
		column.add_child(_label(weight_text, 12, _c("danger") if bool(carry["over_proposed"]) else COLOR_MUTED))

	for note: String in comparison["notes"]:
		column.add_child(_label("• %s" % note, 12, COLOR_MUTED))
	column.add_child(_label(str(comparison["neutral_label"]), 11, COLOR_MUTED))
	return panel


func _comparison_heading(title: String) -> Label:
	return _label(title, 11, _c("muted"))


func _comparison_row(title: String, current_text: String, proposed_text: String, delta: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var name_label := _label(title, 13, COLOR_MUTED)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)
	var value_color := _c("text")
	if delta > 0:
		value_color = _c("success")
	elif delta < 0:
		value_color = _c("danger")
	var value_text := proposed_text if current_text == proposed_text else "%s → %s" % [current_text, proposed_text]
	var value_label := _label(value_text, 13, value_color)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	# Both halves of a comparison row expand: without its own share the value
	# label collapses to ~1px inside the HBox and every value renders one
	# letter per line. See _ledger_row for the same two-sided pattern.
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(value_label)
	return row


func _signature_summary(weapon: Dictionary) -> String:
	var family := str(weapon.get("family", "unarmed")).capitalize()
	if str(weapon.get("family", "")) == "unarmed":
		return "Unarmed"
	return "%s %s" % [family, "mastered" if bool(weapon.get("mastered", false)) else "unmastered"]


func _item_effect_text(item: Dictionary) -> String:
	var lines: Array[String] = []
	if item.has("signature"):
		lines.append(_weapon_signature_text(item, game.run_state.get("survivor", {}).get("stats", {})))
	if bool(item.get("shield", false)):
		lines.append("Block +%d points • Dodge %d points • incompatible with two-handed weapons" % [item["block_bonus"], item["dodge_bonus"]])
	if bool(item.get("two_handed", false)):
		lines.append("Two-handed: equipping returns your shield to inventory")
	var combat: Dictionary = item.get("combat", {})
	if not combat.is_empty():
		lines.append("%s attack • %d–%d base damage" % [str(combat.get("attack_stat", "strength")).capitalize(), int(combat.get("damage_min", 0)), int(combat.get("damage_max", 0))])
	if int(item.get("damage_reduction", 0)) > 0:
		lines.append("Armor rating %d" % int(item.get("damage_reduction", 0)))
	if float(item.get("capacity_bonus", 0.0)) > 0.0:
		lines.append("Capacity +%.0f kg" % float(item.get("capacity_bonus", 0.0)))
	if str(item.get("ammo_type", "")) != "":
		lines.append("Uses %s" % str(content.get_item(str(item.get("ammo_type", ""))).get("name", item.get("ammo_type", "ammunition"))))
	var modifiers: Dictionary = item.get("modifiers", {})
	for stat: String in modifiers.get("stats", {}):
		lines.append("%s %+.0f" % [stat.capitalize(), float(modifiers["stats"][stat])])
	for approach: String in modifiers.get("approaches", {}):
		lines.append("%s approach %+.0f" % [approach.capitalize(), float(modifiers["approaches"][approach])])
	var effects: Dictionary = item.get("effects", {})
	if effects.has("health"):
		lines.append("HP %+.0f" % float(effects["health"]))
	if effects.has("satiety"):
		lines.append("Food +%d" % int(effects["satiety"]))
	for pressure: String in effects.get("pressures", {}):
		lines.append("%s %+.0f" % [pressure.capitalize(), float(effects["pressures"][pressure])])
	var removed_names: Array[String] = []
	for condition_id: Variant in effects.get("remove_conditions", []):
		removed_names.append(str(content.get_condition(str(condition_id)).get("name", condition_id)))
	if not removed_names.is_empty():
		lines.append("Treats %s" % ", ".join(removed_names))
	var added_names: Array[String] = []
	for condition_id: Variant in effects.get("add_conditions", []):
		added_names.append(str(content.get_condition(str(condition_id)).get("name", condition_id)))
	if not added_names.is_empty():
		lines.append("Grants %s" % ", ".join(added_names))
	return " • ".join(lines) if not lines.is_empty() else "No direct numerical effect."


func _weapon_signature_text(item: Dictionary, stats: Dictionary) -> String:
	var family := str(item.get("signature", "unarmed"))
	var stat := str(item.get("combat", {}).get("attack_stat", "strength"))
	var value := int(stats.get(stat, 0))
	var lines: Array[String] = ["%s • %s" % [family.capitalize(), "MASTERED" if value >= 6 else "%s %d / 6 base for mastery" % [stat.capitalize(), value]]]
	var affinity_min := int(item.get("affinity_min", 0))
	if affinity_min > 0:
		lines.append("Needs %s %d • %s" % [stat.capitalize(), affinity_min, "GOOD FIT" if value >= affinity_min else "WEAK FIT (unwieldy: −15 hit, −25% damage)"])
	lines.append(str(content.combat_data.get("families", {}).get(family, {}).get("description", "")))
	return "\n".join(lines)


func _inventory_action(action: String, item_id: String, slot: String = "") -> void:
	if _inventory_actions_locked():
		_show_toast("Resolve the current roll or combat turn first.")
		return
	var operation := "use_item" if action == "use" else action
	_run_gameplay_action(operation, [slot if action == "unequip" else item_id], _after_inventory_action)


func _after_inventory_action(result: Dictionary) -> void:
	if sound != null and bool(result.get("success", false)):
		sound.play_effect("inventory")
	if is_instance_valid(item_detail_popup):
		item_detail_popup.hide()
	_show_toast(str(result.get("text", "")))
	if str(game.run_state.get("phase", "")) == "death":
		if is_instance_valid(inventory_popup):
			inventory_popup.hide()
		_finish_run(false)
	else:
		_show_inventory(false)


func _close_item_detail() -> void:
	if _gameplay_locked():
		return
	if is_instance_valid(item_detail_popup):
		item_detail_popup.hide()
	_pause_story(false)


func _confirm_drop(item_id: String, quantity: int) -> void:
	var item := content.get_item(item_id)
	if is_instance_valid(confirmation_popup):
		confirmation_popup.queue_free()
	confirmation_popup = PopupPanel.new()
	# The confirmation sits above inventory and its item sheet.
	confirmation_popup.exclusive = false
	add_child(confirmation_popup)
	var body := _popup_body(confirmation_popup, 15)
	body.add_child(_overlay_header("DROP ITEM?", confirmation_popup.hide))
	body.add_child(_label("Leave %s%s behind? This cannot be undone." % [item.get("name", item_id), " ×%d" % quantity if quantity > 1 else ""], 16))
	var actions := HBoxContainer.new()
	var cancel := _button("CANCEL", confirmation_popup.hide)
	cancel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(cancel)
	var confirm := _button("DROP", _perform_drop.bind(item_id, quantity))
	confirm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(confirm)
	body.add_child(actions)
	_popup_center_responsive(confirmation_popup, 0.84, 0.32)


func _perform_drop(item_id: String, quantity: int) -> void:
	if _inventory_actions_locked():
		_show_toast("Resolve the current roll or combat turn first.")
		return
	_run_gameplay_action("drop", [item_id, quantity], _after_drop)


func _after_drop(result: Dictionary) -> void:
	if is_instance_valid(confirmation_popup):
		confirmation_popup.hide()
	if is_instance_valid(item_detail_popup):
		item_detail_popup.hide()
	_show_toast(str(result.get("text", "")))
	_show_inventory(false)


func _close_inventory() -> void:
	if _gameplay_locked():
		return
	if is_instance_valid(confirmation_popup):
		confirmation_popup.hide()
	if is_instance_valid(item_detail_popup):
		item_detail_popup.hide()
	if is_instance_valid(inventory_popup):
		inventory_popup.hide()
	_pause_story(false)
	_render_current()


func _inventory_actions_locked() -> bool:
	return _gameplay_locked() or str(game.run_state.get("phase", "")) not in ["event", "result", "checkpoint"]


var settings_section := "Reading"


func _show_settings() -> void:
	if _gameplay_locked():
		return
	_pause_story(true)
	if is_instance_valid(settings_popup):
		settings_popup.hide()
		settings_popup.queue_free()
	settings_popup = PopupPanel.new()
	settings_popup.exclusive = true
	add_child(settings_popup)
	var body := _popup_body(settings_popup, 15)
	body.add_child(_overlay_header("SETTINGS", _close_settings))
	var tabs := GridContainer.new()
	tabs.name = "SettingsCategories"
	tabs.columns = 2
	tabs.add_theme_constant_override("h_separation", 6)
	tabs.add_theme_constant_override("v_separation", 6)
	body.add_child(tabs)
	for section: String in ["Reading", "Sound", "Display", "Help"]:
		var tab := _button(section, _select_settings_section.bind(section))
		tab.toggle_mode = true
		tab.button_pressed = section == settings_section
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tab.accessibility_name = section + (" settings, selected" if section == settings_section else " settings")
		tabs.add_child(tab)
	var scroll := TouchScrollContainerScript.new()
	scroll.name = "SettingsScroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var options := _scroll_column(scroll, 10)
	match settings_section:
		"Reading":
			_settings_choice(options, "Text size", "Choose a comfortable reading size.", "font_scale", ["Small", "Normal", "Large"], [0.9, 1.0, 1.2])
			_settings_choice(options, "Story reveal", "Instant shows the full passage immediately.", "story_text_speed", ["Slow", "Normal", "Fast", "Instant"], ["slow", "normal", "fast", "instant"])
			_settings_choice(options, "Combat rolls", "Manual waits for your tap. Quick rolls automatically.", "combat_presentation", ["Manual", "Quick"], ["manual", "quick"])
		"Sound":
			options.add_child(_check_setting("Sound effects", "sound_enabled"))
			options.add_child(_role_label("Clicks, dice, combat and journey sounds.", "flavour", _c("muted")))
			options.add_child(_check_setting("Vibration", "haptics_enabled"))
			options.add_child(_role_label("A short vibration when a roll resolves.", "flavour", _c("muted")))
			options.add_child(_button("PREVIEW SOUND", func() -> void:
				if sound != null:
					sound.play_effect("success")
			))
		"Display":
			options.add_child(_check_setting("High contrast", "high_contrast"))
			options.add_child(_role_label("Stronger contrast for text and controls.", "flavour", _c("muted")))
			options.add_child(_check_setting("Reduced motion", "reduced_motion"))
			options.add_child(_role_label("Skip dice movement and shorten transitions.", "flavour", _c("muted")))
			var themes := _available_themes()
			var theme_names: Array = []
			for theme_id: String in themes:
				theme_names.append(UiPaletteScript.display_name(theme_id))
			_settings_choice(options, "Color theme", "", "selected_theme", theme_names, themes)
		"Help":
			options.add_child(_check_setting("Contextual tips", "contextual_tips_enabled"))
			options.add_child(_role_label("Show brief guidance when a mechanic first appears.", "flavour", _c("muted")))
			options.add_child(_button("SHOW TIPS AGAIN", func() -> void:
				_reset_contextual_tips()
				_show_settings()
			))
			options.add_child(_button("HOW TO PLAY", _show_first_run_tutorial))
			if monetization_enabled:
				options.add_child(_button("COSMETIC STORE", _show_store))
	body.add_child(_button("DONE", _close_settings))
	_popup_center_responsive(settings_popup, 0.94, 0.88)


func _select_settings_section(section: String) -> void:
	settings_section = section
	_show_settings()


func _settings_choice(parent: VBoxContainer, title_text: String, hint: String, key: String, labels: Array, values: Array) -> void:
	parent.add_child(_role_label(title_text, "title"))
	if hint != "":
		parent.add_child(_role_label(hint, "flavour", _c("muted")))
	var selector := OptionButton.new()
	selector.name = "Setting_" + key
	selector.custom_minimum_size.y = TOUCH_TARGET
	selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selector.fit_to_longest_item = false
	selector.accessibility_name = title_text
	_type(selector, "body")
	var selected := maxi(values.find(profile.get(key)), 0)
	for label_text: String in labels:
		selector.add_item(label_text)
	selector.select(selected)
	selector.disabled = values.size() < 2
	parent.add_child(selector)
	selector.item_selected.connect(func(index: int) -> void:
		if not _commit_profile_changes({key: values[index]}):
			selector.select(maxi(values.find(profile.get(key)), 0))
			return
		if key in ["font_scale", "selected_theme"]:
			_apply_theme()
			settings_popup.hide()
			_render_current() if not game.run_state.is_empty() else _show_main_menu()
			_show_settings()
	)


func _check_setting(label_text: String, key: String) -> CheckButton:
	var check := CheckButton.new()
	check.text = label_text
	check.custom_minimum_size.y = TOUCH_TARGET
	check.button_pressed = bool(profile.get(key, false))
	check.toggled.connect(func(value: bool) -> void:
		if not _toggle_setting(value, key):
			check.set_pressed_no_signal(bool(profile.get(key, false)))
	)
	return check


## Single-file preferences can roll back before confirmation. Cross-file
## discoveries/summaries MUST use the transaction receipt, not this helper.
func _commit_profile_changes(changes: Dictionary) -> bool:
	if _gameplay_locked():
		return false
	var updated := profile.duplicate(true)
	updated.merge(changes, true)
	if not saves.save_profile(updated):
		_show_toast("Could not save the profile change. Free some storage and try again.")
		return false
	profile.clear()
	profile.merge(updated, true)
	return true


func _toggle_setting(value: bool, key: String) -> bool:
	if not _commit_profile_changes({key: value}):
		return false
	if key in ["sound_enabled", "haptics_enabled"] and sound != null:
		sound.configure(profile)
	if key == "high_contrast":
		_apply_theme()
	if key == "contextual_tips_enabled" and not value:
		_hide_contextual_tip()
	return true


func _cycle_font_scale() -> void:
	var scale := float(profile.get("font_scale", 1.0))
	if not _commit_profile_changes({"font_scale": 1.2 if scale < 1.1 else 0.9 if scale > 1.1 else 1.0}):
		return
	_apply_theme()
	settings_popup.hide()
	_render_current() if not game.run_state.is_empty() else _show_main_menu()
	_show_settings()


func _cycle_combat_presentation() -> void:
	if not _commit_profile_changes({"combat_presentation": "quick" if str(profile.get("combat_presentation", "manual")) == "manual" else "manual"}):
		return
	settings_popup.hide()
	_show_settings()


func _cycle_story_speed() -> void:
	var speeds: Array[String] = ["slow", "normal", "fast", "instant"]
	var current := speeds.find(str(profile.get("story_text_speed", "normal")))
	if not _commit_profile_changes({"story_text_speed": speeds[(maxi(current, 0) + 1) % speeds.size()]}):
		return
	if is_instance_valid(settings_popup):
		settings_popup.hide()
	_show_settings()


func _story_speed_name() -> String:
	return str(profile.get("story_text_speed", "normal")).to_upper()


func _font_scale_name() -> String:
	var scale := float(profile.get("font_scale", 1.0))
	return "SMALL" if scale < 1.0 else "LARGE" if scale > 1.0 else "NORMAL"


func _available_themes() -> Array[String]:
	var themes: Array[String] = ["default"]
	if billing.owns("theme_rust") or billing.owns("supporter"):
		themes.append("rust")
	if billing.owns("theme_night") or billing.owns("supporter"):
		themes.append("night")
	return themes


func _cycle_theme() -> void:
	var themes := _available_themes()
	var current_index := themes.find(str(profile.get("selected_theme", "default")))
	if not _commit_profile_changes({"selected_theme": themes[(max(current_index, 0) + 1) % themes.size()]}):
		return
	_apply_theme()
	if is_instance_valid(settings_popup):
		settings_popup.hide()
	_render_current() if not game.run_state.is_empty() else _show_main_menu()
	_show_settings()


func _close_settings() -> void:
	if _gameplay_locked():
		return
	if is_instance_valid(settings_popup):
		settings_popup.hide()
	_pause_story(false)
	_render_current() if not game.run_state.is_empty() else _show_main_menu()


func _show_store() -> void:
	if is_instance_valid(store_popup):
		store_popup.queue_free()
	store_popup = PopupPanel.new()
	# Store is launched from the already-modal settings sheet.
	store_popup.exclusive = false
	add_child(store_popup)
	var body := _popup_body(store_popup, 15)
	body.add_child(_overlay_header("COSMETIC STORE", store_popup.hide))
	body.add_child(_label("Purchases are non-consumable and never affect a D20 roll. Previously verified ownership remains usable offline.", 14, _c("muted")))
	var offers := [
		["remove_ads", "Remove Ads"],
		["theme_rust", "Cinder Rust Theme Pack"],
		["theme_night", "Signal at Night Theme Pack"],
		["supporter", "Supporter Theme Bundle"],
	]
	for offer: Array in offers:
		var entitlement_id := str(offer[0])
		var owned := billing.owns(entitlement_id)
		var suffix := "OWNED" if owned else "UNAVAILABLE OFFLINE" if not billing.available else "OPEN GOOGLE PLAY"
		body.add_child(_button("%s - %s" % [offer[1], suffix], _request_purchase.bind(entitlement_id), owned or not billing.available))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(spacer)
	body.add_child(_label(billing.store_status(), 13, _c("muted")))
	_popup_center_responsive(store_popup, 0.9, 0.82)


func _request_purchase(entitlement_id: String) -> void:
	_show_toast(billing.begin_purchase(entitlement_id))


func _show_about() -> void:
	_clear_page()
	_set_atmosphere("plain")
	_title("ABOUT ASHFALL ROAD", "Offline by design")
	var body := _panel()
	body.add_child(_label("Ashfall Road is a mechanics-first D20 roguelike. The active run is stored only on this device and is erased when the survivor dies.", 18))
	var release_text := "This release is fully offline and contains no advertising or purchases." if not monetization_enabled else "Optional Google Play purchases and advertisements never block the offline game."
	body.add_child(_label(release_text, 16, _c("muted")))
	body.add_child(_label("No account, cloud save, multiplayer, or external analytics service is used in version 1.", 16, _c("muted")))
	body.add_child(_button("BACK", _show_main_menu))


func _show_content_error(errors: PackedStringArray) -> void:
	_clear_page()
	_set_atmosphere("plain")
	_title("CONTENT ERROR", "The game cannot safely start")
	var body := _panel()
	body.add_child(_label("\n".join(errors), 15, _c("danger")))


## Contextual guidance. Each tip is at most two sentences, appears once at the
## moment it applies, and is dismissed individually or switched off entirely.
## Tips only read run state and write profile preferences: they never touch the
## engine, so enemy commitment, RNG, choice availability, and combat results are
## identical whether or not guidance is on screen.
const CONTEXTUAL_TIPS := {
	"checked_choice": {"text": "A checked choice shows your exact odds and the lowest roll that wins."},
	"event_preparation": {"text": "Open the backpack between events to equip, use, or compare gear."},
	"enemy_heavy_sweep": {"text": "Dodge heavy blows; block sweeps."},
	"defense_window": {"text": "Spend Riposte or Opening on your next action."},
	"weapon_mastery": {"text": "A weapon signature grows stronger at base stat 6, where mastery unlocks."},
	"opportunity": {"text": "Opportunity: one big attack per fight. It never expires."},
	"checkpoint_allocation": {"text": "Apply stat points first. Rest and Press On are a separate decision."},
}


func _tip_available(tip_id: String) -> bool:
	if not is_instance_valid(tip_banner) or not CONTEXTUAL_TIPS.has(tip_id):
		return false
	if not bool(profile.get("contextual_tips_enabled", true)):
		return false
	if tip_id in profile.get("contextual_tips_seen", []):
		return false
	if active_tip_id != "":
		return false
	# Never interrupt a die that is still resolving, a saved roll waiting to be
	# revealed, or a save awaiting the player.
	if str(game.run_state.get("phase", "")) in ["roll_pending", "combat_roll_pending", "resolving"]:
		return false
	return not _gameplay_locked()


func _show_contextual_tip(tip_id: String) -> void:
	if not _tip_available(tip_id):
		return
	active_tip_id = tip_id
	for child: Node in tip_body.get_children():
		tip_body.remove_child(child)
		child.queue_free()
	var tip_box := _style_box(_panel_alt_color(), _c("border"))
	tip_box.content_margin_left = 8
	tip_box.content_margin_right = 8
	tip_box.content_margin_top = 4
	tip_box.content_margin_bottom = 4
	tip_banner.add_theme_stylebox_override("panel", tip_box)
	var tip: Dictionary = CONTEXTUAL_TIPS[tip_id]
	var strip := Button.new()
	strip.name = "DismissTip"
	strip.text = "%s  ✕" % str(tip["text"])
	strip.flat = true
	strip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	strip.custom_minimum_size.y = 44
	strip.add_theme_font_size_override("font_size", int(12 * float(profile.get("font_scale", 1.0))))
	strip.add_theme_color_override("font_color", _c("text"))
	strip.tooltip_text = "Dismiss this tip. Settings can switch tips off or reset them."
	strip.accessibility_name = "Tip: %s. Activate to dismiss." % str(tip["text"])
	strip.pressed.connect(_dismiss_contextual_tip)
	tip_body.add_child(strip)
	tip_banner.visible = true
	_apply_combat_guidance_space()


func _dismiss_contextual_tip() -> void:
	var tip_id := active_tip_id
	_hide_contextual_tip()
	if tip_id == "":
		return
	var seen: Array = (profile.get("contextual_tips_seen", []) as Array).duplicate()
	if tip_id not in seen:
		seen.append(tip_id)
	_commit_profile_changes({"contextual_tips_seen": seen})


func _hide_contextual_tip() -> void:
	active_tip_id = ""
	if is_instance_valid(tip_banner):
		tip_banner.visible = false
	_apply_combat_guidance_space()


## Combat fills a 360x640 screen exactly. While guidance is visible the round log
## yields its row; the clue, the windows, and every action stay put.
func _apply_combat_guidance_space() -> void:
	if not is_instance_valid(active_combat_presentation):
		return
	var guided := active_tip_id != ""
	var feed = active_combat_presentation.get("feed_scroll")
	if is_instance_valid(feed):
		# The log keeps its full width and its place; it simply stops reserving
		# rows while a tip occupies the screen.
		feed.custom_minimum_size.y = 0 if guided else 44
	for stage: Node in active_combat_presentation.find_children("PortraitStage", "", true, false):
		var art := stage as Control
		if art != null and art.custom_minimum_size.y <= 64.0:
			art.custom_minimum_size.y = 44.0 if guided else 64.0


func _reset_contextual_tips() -> void:
	if not _commit_profile_changes({"contextual_tips_seen": [], "contextual_tips_enabled": true}):
		return
	_hide_contextual_tip()
	_show_toast("Contextual tips will appear again.")


func _show_toast(text: String) -> void:
	if text == "":
		return
	toast_label.text = text
	toast_label.visible = true
	var tween := create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(func() -> void: toast_label.visible = false)


func _save_active_run() -> bool:
	if game == null or saves == null:
		return true
	if combat_transaction.is_locked():
		return false
	var result: Dictionary = combat_transaction.flush(game, saves, profile)
	if result.has("error"):
		_show_save_recovery(str(result["error"]), _after_background_save)
		return false
	return true


func _after_background_save(_result: Dictionary) -> void:
	_render_current()


func _gameplay_locked() -> bool:
	return event_committing or combat_committing or combat_transaction.is_locked()


func _run_gameplay_action(operation: String, args: Array, on_committed: Callable) -> void:
	if _gameplay_locked():
		return
	_accept_action_result(combat_transaction.execute(game, saves, profile, operation, args), on_committed)


func _accept_action_result(result: Dictionary, on_committed: Callable) -> void:
	if result.has("error"):
		if bool(result.get("retry_save", false)):
			_show_save_recovery(str(result["error"]), on_committed)
		else:
			_show_toast(str(result["error"]))
		return
	on_committed.call(result)


func _show_save_recovery(message: String, on_committed: Callable) -> void:
	save_success_callback = on_committed
	_pause_story(true)
	if is_instance_valid(save_recovery_popup):
		save_recovery_label.text = message
		return
	save_recovery_popup = PopupPanel.new()
	save_recovery_popup.name = "SaveRecovery"
	save_recovery_popup.exclusive = true
	# Nest inside an existing modal so its Close/Back cannot sit above recovery.
	var parent: Node = self
	for child: Node in get_children():
		if child is PopupPanel and child.visible:
			parent = child
	parent.add_child(save_recovery_popup)
	var body := _popup_body(save_recovery_popup, 16)
	body.add_child(_label("SAVE NEEDS ATTENTION", 20, _c("danger")))
	var scroll := TouchScrollContainerScript.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	save_recovery_label = _label(message, 15)
	save_recovery_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(save_recovery_label)
	var retry_button := _button("RETRY SAVE", _retry_pending_save, false, true)
	retry_button.name = "RetrySave"
	body.add_child(retry_button)
	_popup_center_responsive(save_recovery_popup, 0.94, 0.60)


func _retry_pending_save() -> void:
	var result: Dictionary = combat_transaction.retry(game, saves, profile)
	if result.has("error"):
		if is_instance_valid(save_recovery_label):
			save_recovery_label.text = str(result["error"])
		return
	var on_committed := save_success_callback
	save_success_callback = Callable()
	if is_instance_valid(save_recovery_popup):
		save_recovery_popup.hide()
		save_recovery_popup.queue_free()
	save_recovery_popup = null
	_pause_story(false)
	if on_committed.is_valid():
		on_committed.call(result)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _gameplay_locked():
		get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_handle_back()


func _handle_back() -> void:
	if _gameplay_locked():
		_show_toast("Finish the current presentation or retry saving before leaving.")
		return
	if is_instance_valid(confirmation_popup) and confirmation_popup.visible:
		confirmation_popup.hide()
	elif is_instance_valid(item_detail_popup) and item_detail_popup.visible:
		_close_item_detail()
	elif is_instance_valid(conditions_popup) and conditions_popup.visible:
		_close_conditions()
	elif is_instance_valid(stat_details_popup) and stat_details_popup.visible:
		_close_stat_details()
	elif is_instance_valid(level_popup) and level_popup.visible:
		_cancel_level_draft()
	elif is_instance_valid(action_popup) and action_popup.visible:
		action_popup.hide()
	elif is_instance_valid(tutorial_popup) and tutorial_popup.visible:
		_dismiss_tutorial()
	elif is_instance_valid(store_popup) and store_popup.visible:
		store_popup.hide()
	elif is_instance_valid(inventory_popup) and inventory_popup.visible:
		_close_inventory()
	elif is_instance_valid(settings_popup) and settings_popup.visible:
		_close_settings()
	elif not game.run_state.is_empty():
		if _save_active_run():
			_show_main_menu()
