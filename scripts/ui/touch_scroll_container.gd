class_name TouchScrollContainer
extends ScrollContainer

## One-finger scrolling everywhere, including gestures that start on a button.
## Let Godot own the deadzone, momentum and NOTIFICATION_SCROLL_BEGIN, which
## cancels a pending button press as soon as the finger starts scrolling.

func _init() -> void:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	scroll_deadzone = 10


func _ready() -> void:
	_prepare_descendants(self)
	get_tree().node_added.connect(_prepare_added_control)


func _exit_tree() -> void:
	if get_tree().node_added.is_connected(_prepare_added_control):
		get_tree().node_added.disconnect(_prepare_added_control)


func _prepare_descendants(parent: Node) -> void:
	for child: Node in parent.get_children():
		_prepare_added_control(child)
		_prepare_descendants(child)


func _prepare_added_control(node: Node) -> void:
	if not is_ancestor_of(node) or not node is Control:
		return
	# A nested scroll or slider owns its own gesture. Decorative IGNORE nodes
	# should remain transparent, while cards and buttons pass drags upward.
	if node is ScrollContainer or node is Range:
		return
	var control := node as Control
	if control.mouse_filter == Control.MOUSE_FILTER_STOP:
		control.mouse_filter = Control.MOUSE_FILTER_PASS
	if control is BaseButton:
		# CheckButton normally toggles on touch-down, before a swipe can begin.
		(control as BaseButton).action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
