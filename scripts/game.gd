extends Node2D

@export var player_scene: PackedScene        # e.g. res://scenes/player.tscn
@export var environment_scene: PackedScene   # e.g. res://scenes/environment.tscn
@export var spawner_scene: PackedScene       # optional, e.g. res://scenes/spawner.tscn

func _ready() -> void:
	#_spawn_environment()
	#_spawn_player()
	#_start_spawnaer()
	$Spawner.spawn_monsters()

func _spawn_environment() -> void:
	if environment_scene:
		add_child(environment_scene.instantiate())

func _spawn_player() -> void:
	if player_scene:
		var p = player_scene.instantiate()
		add_child(p)
		if has_node("StartPosition"):
			p.global_position = %StartPosition.global_position
		else:
			p.global_position = get_viewport_rect().size / 2
			


func _start_spawner() -> void:
	if spawner_scene:
		var s = spawner_scene.instantiate()
		add_child(s)
		if "start" in s:
			s.start()
