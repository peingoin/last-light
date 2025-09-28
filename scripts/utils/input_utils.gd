class_name InputUtils

static func get_mouse_direction_from_player(player_pos: Vector2) -> Vector2:
	var mouse_pos = DisplayServer.mouse_get_position()
	var viewport = Engine.get_main_loop().current_scene.get_viewport()
	var camera = viewport.get_camera_2d()

	if camera:
		var world_mouse_pos = camera.get_global_mouse_position()
		return (world_mouse_pos - player_pos).normalized()
	else:
		return Vector2.ZERO

static func add_mouse_input_actions() -> void:
	if not InputMap.has_action("left_click"):
		InputMap.add_action("left_click")
		var left_click_event = InputEventMouseButton.new()
		left_click_event.button_index = MOUSE_BUTTON_LEFT
		InputMap.action_add_event("left_click", left_click_event)

	if not InputMap.has_action("right_click"):
		InputMap.add_action("right_click")
		var right_click_event = InputEventMouseButton.new()
		right_click_event.button_index = MOUSE_BUTTON_RIGHT
		InputMap.action_add_event("right_click", right_click_event)