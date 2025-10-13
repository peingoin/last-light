extends Node2D

# Keep it simple: preload the game scene so it's never null.
@export var game_scene: PackedScene

func _ready() -> void:
	var viewport_size = get_viewport_rect().size

	# Scale background to fit viewport
	var background = $Background
	if background:
		var texture_size = background.texture.get_size()
		var scale_x = viewport_size.x / texture_size.x
		var scale_y = viewport_size.y / texture_size.y
		var scale_factor = max(scale_x, scale_y)
		background.scale = Vector2(scale_factor, scale_factor)
		background.position = viewport_size / 2

	# Center the UI container
	var center_container = $CenterContainer
	center_container.position = viewport_size / 2

	# Hide controls menu initially
	var controls_menu = $ControlsMenu
	if controls_menu:
		controls_menu.hide()

func _input(event):
	var controls_menu = $ControlsMenu
	if controls_menu and controls_menu.visible:
		if event.is_action_pressed("interact"):
			get_tree().change_scene_to_packed(game_scene)

func _on_play_button_pressed() -> void:
	# Hide menu buttons and show controls
	$CenterContainer.hide()
	var controls_menu = $ControlsMenu
	if controls_menu:
		controls_menu.show()


func _on_quit_button_pressed() -> void:
		get_tree().quit()
