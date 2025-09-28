extends Node2D

# Keep it simple: preload the game scene so it's never null.
@export var game_scene: PackedScene

@onready var play_btn: Button = find_child("play_button", true, false)
@onready var quit_btn: Button = find_child("quit_button", true, false)

func _ready() -> void:
	play_btn.pressed.connect(_on_play)
	quit_btn.pressed.connect(_on_quit)

func _on_play() -> void:
	# Either use the exported PackedScene...
	get_tree().change_scene_to_packed(game_scene)
	# ...or if you prefer a path:
	# get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit() -> void:
	
	get_tree().quit()
