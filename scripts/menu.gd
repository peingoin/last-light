extends Node2D

# Keep it simple: preload the game scene so it's never null.
@export var game_scene: PackedScene

func _ready() -> void:
	# Start background map generation while player views menu
	SceneManager.start_background_generation()

func _on_play_button_pressed() -> void:
	# Check if background generation finished - instant transition
	if SceneManager.is_game_ready():
		SceneManager.show_game_scene()
	else:
		# Fallback for impatient players - use normal loading screen
		get_tree().change_scene_to_packed(game_scene)
		
func _on_quit_button_pressed() -> void:
		get_tree().quit()
