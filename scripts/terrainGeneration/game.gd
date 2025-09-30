extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var player: CharacterBody2D = $ObjectLayer/Player

func _ready():
	if player and camera:

func _process(_delta):
	if player and camera:
		camera.global_position = player.global_position
