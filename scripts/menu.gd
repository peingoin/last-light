extends Control

# Keep it simple: preload the game scene so it's never null.
@export var game_scene: PackedScene

# Track whether we're showing instructions or starting the game
var showing_instructions := false

func _ready() -> void:
	# Hide controls menu initially
	var controls_menu = $ControlsMenu
	if controls_menu:
		controls_menu.hide()

func _input(event):
	var controls_menu = $ControlsMenu
	if controls_menu and controls_menu.visible:
		if event.is_action_pressed("interact"):
			if showing_instructions:
				# Return to main menu
				controls_menu.hide()
				$CenterContainer.show()
				showing_instructions = false
			else:
				# Start the game
				get_tree().change_scene_to_packed(game_scene)

func _on_play_button_pressed() -> void:
	# Hide menu buttons and show controls before starting game
	$CenterContainer.hide()
	showing_instructions = false
	var controls_menu = $ControlsMenu
	if controls_menu:
		controls_menu.show()

func _on_instructions_button_pressed() -> void:
	# Hide menu buttons and show instructions
	$CenterContainer.hide()
	showing_instructions = true
	var controls_menu = $ControlsMenu
	if controls_menu:
		controls_menu.show()
