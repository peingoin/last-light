extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var player: CharacterBody2D = $ObjectLayer/Player

func _ready():
	if player and camera:
		print("Camera following setup complete")

func _process(_delta):
	if player and camera:
		camera.global_position = player.global_position
		# Debug player position every 60 frames
		if Engine.get_process_frames() % 60 == 0:
			print("Player Y position: ", player.position.y)