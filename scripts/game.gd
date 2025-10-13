extends Node2D

@export var player_scene: PackedScene        # e.g. res://scenes/player.tscn
@export var environment_scene: PackedScene   # e.g. res://scenes/environment.tscn
@export var spawner_scene: PackedScene       # optional, e.g. res://scenes/spawner.tscn


@onready var player = $Player
@onready var ui_control = $"CanvasLayer/UI Control"
@onready var health_bar = $"CanvasLayer/UI Control/HealthBar"
@onready var wood_label = $"CanvasLayer/UI Control/HealthBar/Wood Indicator Control/Wood Label"
@onready var metal_label = $"CanvasLayer/UI Control/HealthBar/Metal Indicator Control/Metal Label"
@onready var textbox = $"CanvasLayer/UI Control/TextBox"
@onready var loading_screen = $"CanvasLayer/LoadingScreen"
@onready var loading_audio: AudioStreamPlayer = null
@onready var weapon_ui_container = $"CanvasLayer/UI Control/WeaponUI"
@onready var cooldown_overlay = $"CanvasLayer/UI Control/WeaponUI/ActiveWeaponCircle/CooldownOverlay"
@onready var interact_prompt = $"CanvasLayer/UI Control/InteractPrompt"

func _ready() -> void:
	# Get loading audio node if it exists
	if loading_screen and loading_screen.has_node("LoadingAudio"):
		loading_audio = loading_screen.get_node("LoadingAudio")
		loading_audio.stream = load("res://assets/Audio/Loading.mp3")

	# Show loading screen for map generation
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
		var signal_obj = player.health_changed
		if signal_obj and not signal_obj.is_connected(_on_player_health_changed):
			signal_obj.connect(_on_player_health_changed)

		# Initialize resource UI from player inventory
		if wood_label and "wood" in player.inventory:
			wood_label.text = str(player.inventory["wood"])
		if metal_label and "steel" in player.inventory:
			metal_label.text = str(player.inventory["steel"])

		# Set up weapon UI
		if weapon_ui_container:
			player.weapon_ui_container = weapon_ui_container
			player.weapon_active_icon = weapon_ui_container.get_node("ActiveWeaponCircle/ActiveWeaponIcon")
			player.weapon_inactive_icon = weapon_ui_container.get_node("InactiveWeaponCircle/InactiveWeaponIcon")
			player.cooldown_overlay = cooldown_overlay

		# Equip starting weapons
		player.equip_weapon("res://scenes/weapons/ranged/fire_staff.tscn", 1)
		player.equip_weapon("res://scenes/weapons/axe.tscn", 2)
		player.update_weapon_ui()

		# Connect active weapon cooldown to UI
		_connect_weapon_cooldown()

	# Start spawner if it exists (timer will handle spawning automatically)
	if has_node("Spawner"):
		var spawner = $Spawner
		# Timer-based spawning starts automatically in spawner._ready()

	# Connect to all interactables in the scene
	_connect_interactables()

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
	# Play loading audio
	if loading_audio:
		loading_audio.play()
	# Hide UI during loading
	if ui_control:
		ui_control.visible = false

func hide_loading_screen():
	if loading_screen:
		loading_screen.visible = false
	# Stop loading audio
	if loading_audio:
		loading_audio.stop()
	# Show UI when map is loaded
	if ui_control:
		ui_control.visible = true

func _connect_weapon_cooldown():
	if player and player.active_weapon and cooldown_overlay:
		var signal_obj = player.active_weapon.cooldown_changed
		# Disconnect any existing connections
		if signal_obj and signal_obj.is_connected(_on_weapon_cooldown_changed):
			signal_obj.disconnect(_on_weapon_cooldown_changed)
		# Connect to the active weapon
		if signal_obj:
			signal_obj.connect(_on_weapon_cooldown_changed)
		# Initialize - hide overlay when ready
		cooldown_overlay.visible = false

func _on_weapon_cooldown_changed(cooldown_percent: float):
	if cooldown_overlay:
		if cooldown_percent > 0.0:
			# Show overlay during cooldown
			cooldown_overlay.visible = true
			# Fade out as cooldown decreases
			cooldown_overlay.modulate.a = cooldown_percent
		else:
			# Hide overlay when cooldown is complete
			cooldown_overlay.visible = false

func _connect_interactables():
	# Connect to all existing interactables
	for interactable in get_tree().get_nodes_in_group("interactable"):
		# Only connect if the interactable has these signals
		if interactable.has_signal("player_nearby"):
			var signal_obj = interactable.player_nearby
			if signal_obj and not signal_obj.is_connected(_on_interactable_nearby):
				signal_obj.connect(_on_interactable_nearby)

		if interactable.has_signal("player_left"):
			var signal_obj = interactable.player_left
			if signal_obj and not signal_obj.is_connected(_on_interactable_left):
				signal_obj.connect(_on_interactable_left)

func _on_interactable_nearby(_interactable: Node):
	if interact_prompt:
		interact_prompt.visible = true

func _on_interactable_left(_interactable: Node):
	if interact_prompt:
		interact_prompt.visible = false
