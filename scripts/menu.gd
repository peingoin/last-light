extends Node2D

# Keep it simple: preload the game scene so it's never null.
@export var game_scene: PackedScene

func _ready() -> void:
	pass

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)
		
func _on_quit_button_pressed() -> void:
		get_tree().quit()
