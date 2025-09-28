extends Node2D

@export var player_scene: PackedScene        # e.g. res://scenes/player.tscn
@export var environment_scene: PackedScene   # e.g. res://scenes/environment.tscn
@export var spawner_scene: PackedScene       # optional, e.g. res://scenes/spawner.tscn


@onready var player = $Player
@onready var health_bar = $"CanvasLayer/UI Control/HealthBar"
@onready var wood_label = $"CanvasLayer/UI Control/HealthBar/Wood Indicator Control/Wood Label"
@onready var metal_label = $"CanvasLayer/UI Control/HealthBar/Metal Indicator Control/Metal Label"
@onready var textbox = $"CanvasLayer/UI Control/TextBox"

func _ready() -> void:
	# Wait a frame to ensure all nodes are ready
	await get_tree().process_frame

	# Initialize health bar with player's max health
	if health_bar and player:
		health_bar.init_health(player.player_health)

		# Connect to player's health changes
		if not player.health_changed.is_connected(_on_player_health_changed):
			player.health_changed.connect(_on_player_health_changed)

		# Equip weapon after player is ready
		if player.has_method("equip_weapon"):
			player.equip_weapon("res://scenes/weapons/iron_sword.tscn")

	# Start spawner if it exists
	if has_node("Spawner"):
		var spawner = $Spawner
		if spawner.has_method("spawn_monsters") and player:
			# Spawn monsters around the player
			spawner.spawn_monsters(player.global_position)

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
	$Spawner.spawn_monsters()

func _on_player_health_changed(new_health):
	if health_bar:
		health_bar.health = new_health

func set_wood_count(amount: int):
	if wood_label:
		wood_label.text = str(amount)

func set_metal_count(amount: int):
	if metal_label:
		metal_label.text = str(amount)

func add_wood(amount: int):
	if wood_label:
		var current_wood = int(wood_label.text)
		set_wood_count(current_wood + amount)

func add_metal(amount: int):
	if metal_label:
		var current_metal = int(metal_label.text)
		set_metal_count(current_metal + amount)
