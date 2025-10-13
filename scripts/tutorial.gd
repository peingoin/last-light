extends Node2D

enum WaveState { WAVE_1, WAVE_2, WAVE_3, WAVE_4, WAVE_5, COMPLETE }

var current_state: WaveState = WaveState.WAVE_1
var active_enemies_count: int = 0

@onready var spawner: Node2D = $Spawner
@onready var player: CharacterBody2D = $Player
@onready var tutorial_text: Label = $CanvasLayer/UIControl/TutorialText
@onready var health_bar = $"CanvasLayer/UIControl/HealthBar"
@onready var wood_label = $"CanvasLayer/UIControl/HealthBar/Wood Indicator Control/Wood Label"
@onready var metal_label = $"CanvasLayer/UIControl/HealthBar/Metal Indicator Control/Metal Label"
@onready var weapon_ui_container = $"CanvasLayer/UIControl/WeaponUI"
@onready var cooldown_overlay = $"CanvasLayer/UIControl/WeaponUI/ActiveWeaponCircle/CooldownOverlay"

func _ready() -> void:
	# Disable spawner timer (we control spawning manually)
	if spawner and spawner.has_node("spawn_timer"):
		var timer = spawner.get_node("spawn_timer")
		timer.stop()
		timer.autostart = false

	# Reset player health to max
	PlayerData.player_health = PlayerData.max_health

	# Load player state (this will set health to max we just set)
	PlayerData.load_player_state(player)

	# Initialize health bar
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

	# Equip iron sword in slot 1
	if player:
		player.equip_weapon("res://scenes/weapons/iron_sword.tscn", 1)

		# Set up weapon UI references
		if weapon_ui_container:
			player.weapon_ui_container = weapon_ui_container
			player.weapon_active_icon = weapon_ui_container.get_node("ActiveWeaponCircle/ActiveWeaponIcon")
			player.weapon_inactive_icon = weapon_ui_container.get_node("InactiveWeaponCircle/InactiveWeaponIcon")
			player.cooldown_overlay = cooldown_overlay

		player.update_weapon_ui()

		# Connect active weapon cooldown to UI
		_connect_weapon_cooldown()

	# Start wave 1
	_start_wave_1()

func _on_player_health_changed(new_health):
	if health_bar:
		health_bar.health = new_health

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

func _start_wave_1() -> void:
	current_state = WaveState.WAVE_1

	# Show tutorial text
	if tutorial_text:
		tutorial_text.visible = true

	# Spawn 1 orc around player
	var orc_scene = load("res://scenes/enemies/orc.tscn")
	var center = player.global_position
	var radius = 100.0

	# Manually spawn 1 orc
	var orc = orc_scene.instantiate()
	var angle = randf_range(0.0, TAU)
	var pos = center + Vector2.RIGHT.rotated(angle) * radius
	orc.global_position = pos

	# Add to scene
	add_child(orc)

	# Connect death signal
	orc.tree_exiting.connect(_on_enemy_died)
	active_enemies_count = 1

func _start_wave_2() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	return
	current_state = WaveState.WAVE_2

	# Hide tutorial text
	if tutorial_text:
		tutorial_text.visible = false

	# Spawn 3 random enemies around player
	var spawned = spawner.spawn_monsters(player.global_position, 3, 100.0)

	# Connect signals
	for enemy in spawned:
		enemy.tree_exiting.connect(_on_enemy_died)

	active_enemies_count = 3
	_complete_tutorial()

func _start_wave_3() -> void:
	current_state = WaveState.WAVE_3

	# Spawn fire wizard at center of room
	var wizard_scene = load("res://scenes/enemies/fire_wizard.tscn")
	var wizard = wizard_scene.instantiate()
	wizard.global_position = Vector2(150, 150)

	# Add to scene
	add_child(wizard)

	# Connect death signal
	wizard.tree_exiting.connect(_on_enemy_died)
	active_enemies_count = 1

func _start_wave_4() -> void:
	current_state = WaveState.WAVE_4

	# Spawn 5 random enemies around player
	var spawned = spawner.spawn_monsters(player.global_position, 5, 100.0)

	# Connect signals
	for enemy in spawned:
		enemy.tree_exiting.connect(_on_enemy_died)

	active_enemies_count = 5

func _start_wave_5() -> void:
	current_state = WaveState.WAVE_5

	# Spawn fire wizard at center of room
	var wizard_scene = load("res://scenes/enemies/fire_wizard.tscn")
	var wizard = wizard_scene.instantiate()
	wizard.global_position = Vector2(150, 150)

	# Add to scene
	add_child(wizard)

	# Connect death signal
	wizard.tree_exiting.connect(_on_enemy_died)
	active_enemies_count = 1

func _spawn_in_van() -> void:
	# Save player state
	PlayerData.save_player_state(player)

	# Transition to van interior
	get_tree().change_scene_to_file("res://scenes/VanInterior.tscn")

func _complete_tutorial() -> void:
	# Save player state
	PlayerData.save_player_state(player)

	# Transition to main game
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_enemy_died() -> void:
	# Decrement counter
	active_enemies_count -= 1

	# Check if wave is complete
	if active_enemies_count == 0:
		_advance_wave()

func _advance_wave() -> void:
	# Transition to next wave based on current state
	match current_state:
		WaveState.WAVE_1:
			_start_wave_2()
		WaveState.WAVE_2:
			_start_wave_3()
		WaveState.WAVE_3:
			# Fire wizard defeated, spawn player in van
			_spawn_in_van()
		WaveState.WAVE_4:
			_start_wave_5()
		WaveState.WAVE_5:
			_complete_tutorial()
