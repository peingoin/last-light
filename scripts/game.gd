extends Node2D

@export var player_scene: PackedScene        # e.g. res://scenes/player.tscn
@export var environment_scene: PackedScene   # e.g. res://scenes/environment.tscn
@export var spawner_scene: PackedScene       # optional, e.g. res://scenes/spawner.tscn


@onready var player = $Player
@onready var health_bar = $"CanvasLayer/UI Control/HealthBar"
@onready var wood_label = $"CanvasLayer/UI Control/HealthBar/Wood Indicator Control/Wood Label"
@onready var metal_label = $"CanvasLayer/UI Control/HealthBar/Metal Indicator Control/Metal Label"
@onready var textbox = $"CanvasLayer/UI Control/TextBox"
@onready var loading_screen = $"CanvasLayer/LoadingScreen"
@onready var weapon_ui_container = $"CanvasLayer/UI Control/WeaponUI"

func _ready() -> void:
	# Show loading screen immediately when game scene loads
	show_loading_screen()

	# Wait a frame to ensure all nodes are ready
	await get_tree().process_frame

	# Start map generation now that loading screen is visible
	if has_node("Perlin"):
		var perlin = $Perlin
		if perlin.has_method("start_map_generation"):
			perlin.start_map_generation()

	# Initialize health bar with player's max health
	if health_bar and player:
		health_bar.init_health(player.player_health)

		# Connect to player's health changes
		if not player.health_changed.is_connected(_on_player_health_changed):
			player.health_changed.connect(_on_player_health_changed)

		# Set up weapon UI
		if weapon_ui_container:
			player.weapon_ui_container = weapon_ui_container
			player.weapon_active_icon = weapon_ui_container.get_node("ActiveWeaponCircle/ActiveWeaponIcon")
			player.weapon_inactive_icon = weapon_ui_container.get_node("InactiveWeaponCircle/InactiveWeaponIcon")

		# Equip starting weapons
		player.equip_weapon("res://scenes/weapons/iron_sword.tscn", 1)
		player.equip_weapon("res://scenes/weapons/axe.tscn", 2)
		player.update_weapon_ui()

	# Start spawner if it exists (timer will handle spawning automatically)
	if has_node("Spawner"):
		var spawner = $Spawner
		# Timer-based spawning starts automatically in spawner._ready()

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

func show_loading_screen():
	if loading_screen:
		loading_screen.visible = true

func hide_loading_screen():
	if loading_screen:
		loading_screen.visible = false
