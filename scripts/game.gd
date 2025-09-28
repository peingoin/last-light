extends Node2D

@export var player_scene: PackedScene        # e.g. res://scenes/player.tscn
@export var environment_scene: PackedScene   # e.g. res://scenes/environment.tscn
@export var spawner_scene: PackedScene       # optional, e.g. res://scenes/spawner.tscn

@onready var player = $Player
@onready var health_bar = $"CanvasLayer/UI Control/HealthBar"
@onready var wood_label = $"CanvasLayer/UI Control/HealthBar/Wood Indicator Control/Wood Label"
@onready var metal_label = $"CanvasLayer/UI Control/HealthBar/Metal Indicator Control/Metal Label"

func _ready() -> void:
	# Initialize health bar with player's max health
	health_bar.init_health(player.player_health)
	
	# Connect to player's health changes
	player.connect("health_changed", _on_player_health_changed)
	
	#_spawn_environment()
	#_spawn_player()
	#_start_spawner()
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

func _on_player_health_changed(new_health):
	health_bar.health = new_health

func set_wood_count(amount: int):
	wood_label.text = str(amount)

func set_metal_count(amount: int):
	metal_label.text = str(amount)

func add_wood(amount: int):
	var current_wood = int(wood_label.text)
	set_wood_count(current_wood + amount)

func add_metal(amount: int):
	var current_metal = int(metal_label.text)
	set_metal_count(current_metal + amount)