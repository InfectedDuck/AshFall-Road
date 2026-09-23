extends SceneTree
## Exercise the actual GUI input route, including native touch-to-mouse
## emulation. A list that merely hides its scrollbar is not a passing swipe.

const TouchScroll = preload("res://scripts/ui/touch_scroll_container.gd")
const Story = preload("res://scripts/ui/story_typewriter.gd")
const Main = preload("res://scripts/ui/main.gd")

var assertions := 0
var failures := 0
var actions := 0

class MemorySettings extends SaveService:
	var writes := 0
	func save_profile(_profile: Dictionary) -> bool:
		writes += 1
		return true


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.content_scale_size = Vector2i.ZERO
	root.size = Vector2i(360, 640)
	root.gui_embed_subwindows = true
	Input.use_accumulated_input = false
	verify(Input.emulate_mouse_from_touch, "Native touches produce GUI mouse input")
	verify(Input.emulate_touch_from_mouse, "Desktop preview supports the same swipe gesture")
	verify(DisplayServer.is_touchscreen_available(), "Touch scrolling is available in the input test")
	await _test_button_swipe(false)
	await _test_button_swipe(true)
	await _test_checkbox_swipe(false)
	await _test_checkbox_swipe(true)
	await _test_late_children()
	await _test_story(false)
	await _test_story(true)
	await _test_settings()
	print("Touch input assertions: %d | Failures: %d" % [assertions, failures])
	quit(1 if failures > 0 else 0)


func verify(valid: bool, message: String) -> void:
	assertions += 1
	if not valid:
		failures += 1
		push_error(message)


func _settle() -> void:
	for frame in range(4):
		await process_frame


func _make_scroll() -> ScrollContainer:
	var scroll := TouchScroll.new()
	scroll.position = Vector2(10, 10)
	scroll.size = Vector2(340, 360)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var body := VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 0)
	scroll.add_child(body)
	root.add_child(scroll)
	return scroll


func _body(scroll: ScrollContainer) -> VBoxContainer:
	for child: Node in scroll.get_children():
		if child is VBoxContainer:
			return child
	return null


func _add_filler(body: VBoxContainer) -> void:
	for index in range(20):
		var label := Label.new()
		label.text = "Scrollable row %d" % index
		label.custom_minimum_size.y = 44
		body.add_child(label)


func _press(position: Vector2, pressed: bool, native: bool, double := false) -> void:
	if native:
		var touch := InputEventScreenTouch.new()
		touch.index = 0
		touch.position = position
		touch.pressed = pressed
		touch.double_tap = double
		Input.parse_input_event(touch)
		Input.flush_buffered_events()
	else:
		var mouse := InputEventMouseButton.new()
		mouse.position = position
		mouse.global_position = position
		mouse.button_index = MOUSE_BUTTON_LEFT
		mouse.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		mouse.pressed = pressed
		mouse.double_click = double
		root.push_input(mouse, true)


func _move(position: Vector2, relative: Vector2, native: bool) -> void:
	if native:
		var drag := InputEventScreenDrag.new()
		drag.index = 0
		drag.position = position
		drag.relative = relative
		drag.velocity = relative * 60.0
		Input.parse_input_event(drag)
		Input.flush_buffered_events()
	else:
		var motion := InputEventMouseMotion.new()
		motion.position = position
		motion.global_position = position
		motion.relative = relative
		motion.velocity = relative * 60.0
		motion.button_mask = MOUSE_BUTTON_MASK_LEFT
		root.push_input(motion, true)


func _swipe(from: Vector2, to: Vector2, native: bool) -> void:
	_press(from, true, native)
	await process_frame
	var previous := from
	for step in range(1, 7):
		var current := from.lerp(to, float(step) / 6.0)
		_move(current, current - previous, native)
		previous = current
		await process_frame
	_press(to, false, native)


func _tap(position: Vector2, native: bool, double := false) -> void:
	_press(position, true, native, double)
	_press(position, false, native)
	await process_frame


func _test_button_swipe(native: bool) -> void:
	var scroll := _make_scroll()
	var button := Button.new()
	button.text = "Open item"
	button.custom_minimum_size.y = 220
	button.pressed.connect(func() -> void: actions += 1)
	_body(scroll).add_child(button)
	_add_filler(_body(scroll))
	await _settle()
	var before := actions
	var context := "native touch" if native else "mouse preview"
	await _swipe(Vector2(160, 180), Vector2(160, 45), native)
	verify(scroll.scroll_vertical > 40, "Swiping directly over a button moves the list: " + context)
	verify(actions == before, "Swiping a button does not activate it: " + context)
	# The first press also stops any remaining inertia; release still acts as
	# a regular tap when no drag exceeds the deadzone.
	scroll.scroll_vertical = 0
	await _tap(Vector2(160, 60), native)
	verify(actions == before + 1, "A normal button tap still activates exactly once: " + context)
	scroll.queue_free()
	await _settle()


func _test_checkbox_swipe(native: bool) -> void:
	var scroll := _make_scroll()
	var toggle := CheckButton.new()
	toggle.text = "Reduced motion"
	toggle.custom_minimum_size.y = 220
	_body(scroll).add_child(toggle)
	_add_filler(_body(scroll))
	await _settle()
	var context := "native touch" if native else "mouse preview"
	await _swipe(Vector2(160, 180), Vector2(160, 45), native)
	verify(scroll.scroll_vertical > 40, "Swiping directly over a setting moves the list: " + context)
	verify(not toggle.button_pressed, "Swiping a setting does not toggle it: " + context)
	scroll.scroll_vertical = 0
	await _tap(Vector2(160, 60), native)
	verify(toggle.button_pressed, "A normal setting tap still toggles it: " + context)
	scroll.queue_free()
	await _settle()


func _test_late_children() -> void:
	var scroll := _make_scroll()
	_add_filler(_body(scroll))
	await _settle()
	var panel := PanelContainer.new()
	var button := Button.new()
	button.text = "New inventory item"
	button.custom_minimum_size.y = 220
	panel.add_child(button)
	_body(scroll).add_child(panel)
	_body(scroll).move_child(panel, 0)
	await _settle()
	verify(button.mouse_filter == Control.MOUSE_FILTER_PASS, "Dynamically added nested buttons allow swipe propagation")
	await _swipe(Vector2(160, 180), Vector2(160, 45), false)
	verify(scroll.scroll_vertical > 40, "A newly inserted item supports swiping over its contents")
	scroll.queue_free()
	await _settle()


func _test_story(native: bool) -> void:
	var scroll := _make_scroll()
	var story := Story.new()
	story.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body(scroll).add_child(story)
	story.start("The road continues beyond the abandoned bridge. ".repeat(120), "slow")
	story.set_paused(true)
	await _settle()
	var context := "native touch" if native else "mouse preview"
	await _tap(Vector2(160, 180), native)
	verify(not story.is_reveal_complete(), "One physical tap does not count as a double tap: " + context)
	# A fresh passage also starts a fresh gesture sequence.
	story.start(story.full_text, "slow")
	await _swipe(Vector2(160, 180), Vector2(160, 45), native)
	verify(scroll.scroll_vertical > 40, "Dragging prose moves its enclosing reading surface: " + context)
	verify(not story.is_reveal_complete(), "Dragging prose does not skip its reveal: " + context)
	await _tap(Vector2(160, 80), native)
	verify(not story.is_reveal_complete(), "A tap after a swipe does not skip the story: " + context)
	await _tap(Vector2(160, 80), native, true)
	verify(story.is_reveal_complete(), "A deliberate double tap still reveals the story: " + context)
	scroll.queue_free()
	await _settle()


func _test_settings() -> void:
	var ui := Main.new()
	ui.bootstrap_on_ready = false
	ui.content = ContentRepository.new()
	ui.game = GameEngine.new(ui.content)
	var saves := MemorySettings.new()
	ui.saves = saves
	ui.profile = saves.default_profile()
	ui.billing = BillingService.new()
	ui.billing.configure({})
	root.add_child(ui)
	ui._build_shell()
	ui._show_settings()
	await _settle()
	var scrollers := ui.settings_popup.find_children("*", "ScrollContainer", true, false)
	verify(scrollers.size() == 1, "Settings uses one scrolling surface")
	if scrollers.is_empty():
		ui.queue_free()
		await _settle()
		return
	var scroll: ScrollContainer = scrollers[0]
	verify(scroll.get_script() == TouchScroll, "The real settings sheet uses the shared touch scroller")
	var toggles := scroll.find_children("*", "CheckButton", true, false)
	verify(not toggles.is_empty(), "Settings supplies actual preference toggles")
	if not toggles.is_empty():
		var toggle: CheckButton = toggles[0]
		# Bring a preference into view before touching it; long settings sheets
		# start with story and combat buttons above the first toggle.
		scroll.scroll_vertical = int(toggle.position.y)
		await _settle()
		var initial_profile: Dictionary = ui.profile.duplicate(true)
		var pointer := Vector2(ui.settings_popup.position) + toggle.get_global_rect().get_center()
		var before := scroll.scroll_vertical
		await _swipe(pointer, pointer - Vector2(0, 65), true)
		verify(scroll.scroll_vertical > before + 20, "A finger swipe over the real settings controls scrolls the sheet")
		verify(ui.profile == initial_profile and saves.writes == 0, "Swiping the settings sheet changes and saves no preferences")
	ui.queue_free()
	await _settle()
