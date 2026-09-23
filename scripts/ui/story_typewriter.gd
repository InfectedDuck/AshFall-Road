class_name StoryTypewriter
extends RichTextLabel

signal reveal_progress(visible_characters: int)
signal reveal_finished

const SPEEDS := {
	"slow": 20.0,
	"normal": 32.0,
	"fast": 50.0,
	"instant": 0.0,
}
const DOUBLE_TAP_MSEC := 350
const DOUBLE_TAP_DISTANCE := 24.0
const COMMA_PAUSE := 0.09
const SENTENCE_PAUSE := 0.18

var full_text := ""
var speed_key := "normal"
var running := false
var paused := false
var _time_to_next := 0.0
var _last_tap_msec := -1000
var _last_tap_position := Vector2.ZERO
var _gesture_dragged := false
var _tap_pressed := false
var _tap_start := Vector2.ZERO
var _native_double := false


func _ready() -> void:
	bbcode_enabled = false
	fit_content = true
	scroll_active = false
	selection_enabled = false
	context_menu_enabled = false
	# PASS lets the enclosing ScrollContainer receive swipe and drag gestures.
	mouse_filter = Control.MOUSE_FILTER_PASS
	gui_input.connect(_on_gui_input)
	set_process(false)


func start(passage: String, requested_speed: String = "normal", start_at: int = 0, reveal_immediately: bool = false) -> void:
	_last_tap_msec = -1000
	_gesture_dragged = false
	_tap_pressed = false
	full_text = passage
	text = passage
	speed_key = requested_speed if requested_speed in SPEEDS else "normal"
	visible_characters = clampi(start_at, 0, full_text.length())
	_time_to_next = 0.0
	if reveal_immediately or float(SPEEDS[speed_key]) <= 0.0 or visible_characters >= full_text.length():
		reveal_all()
		return
	running = true
	set_process(true)


func reveal_all() -> void:
	visible_characters = full_text.length()
	var was_running := running
	running = false
	set_process(false)
	reveal_progress.emit(visible_characters)
	if was_running or not full_text.is_empty():
		reveal_finished.emit()


func set_paused(value: bool) -> void:
	paused = value


func is_reveal_complete() -> bool:
	return visible_characters >= full_text.length()


func _process(delta: float) -> void:
	if not running or paused:
		return
	_time_to_next -= delta
	var characters_per_second := float(SPEEDS.get(speed_key, SPEEDS["normal"]))
	while _time_to_next <= 0.0 and visible_characters < full_text.length():
		visible_characters += 1
		_time_to_next += 1.0 / characters_per_second
		var character := full_text.substr(visible_characters - 1, 1)
		if character in [".", "!", "?"]:
			_time_to_next += SENTENCE_PAUSE
		elif character in [",", ";", ":"]:
			_time_to_next += COMMA_PAUSE
		reveal_progress.emit(visible_characters)
	if visible_characters >= full_text.length():
		running = false
		set_process(false)
		reveal_finished.emit()


func _on_gui_input(event: InputEvent) -> void:
	if is_reveal_complete():
		return
	if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		if _tap_pressed and event.position.distance_to(_tap_start) > 10.0:
			_gesture_dragged = true
		return
	# Touch also produces mouse input in this project. Count the mouse path
	# once, so one physical tap cannot be mistaken for a double tap.
	if not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT:
		return
	if event.pressed:
		_tap_pressed = true
		_tap_start = event.position
		_native_double = event.double_click
		_gesture_dragged = false
		return
	if not _tap_pressed:
		return
	_tap_pressed = false
	# Wait for the finger to lift: even a second press can become a swipe.
	if _gesture_dragged:
		_last_tap_msec = -1000
		return
	var now := Time.get_ticks_msec()
	var custom_double: bool = now - _last_tap_msec <= DOUBLE_TAP_MSEC and event.position.distance_to(_last_tap_position) <= DOUBLE_TAP_DISTANCE
	_last_tap_msec = now
	_last_tap_position = event.position
	if _native_double or custom_double:
		reveal_all()
