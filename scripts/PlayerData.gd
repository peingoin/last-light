extends Node

# Player stats that persist between scenes
var player_health: int = 5
var max_health: int = 5

# Player inventory
var inventory: Dictionary = {
	"wood": 0,
	"steel": 0
}

# Weapon data
var weapon_slot_1_path: String = ""
var weapon_slot_2_path: String = ""
var active_weapon_slot: int = 1

# Player position (for respawning in the correct location)
var last_position: Vector2 = Vector2.ZERO
var last_scene: String = ""

func save_player_state(player: CharacterBody2D) -> void:
	if not player:
		return

	# Save health
	if player.has_method("get") and "player_health" in player:
		player_health = player.player_health

	# Save inventory
	if player.has_method("get") and "inventory" in player:
		inventory = player.inventory.duplicate()

	# Save weapon data
	if player.has_method("get") and "active_weapon_slot" in player:
		active_weapon_slot = player.active_weapon_slot

	# Save position
	last_position = player.global_position

func load_player_state(player: CharacterBody2D) -> void:
	if not player:
		return

	# Load health
	if player.has_method("set") and "player_health" in player:
		player.player_health = player_health
		if player.has_signal("health_changed"):
			player.health_changed.emit(player_health)

	# Load inventory
	if player.has_method("set") and "inventory" in player:
		player.inventory = inventory.duplicate()

	# Load weapon slot
	if player.has_method("set") and "active_weapon_slot" in player:
		player.active_weapon_slot = active_weapon_slot

func reset_player_data() -> void:
	player_health = 5
	max_health = 5
	inventory = {"wood": 0, "steel": 0}
	weapon_slot_1_path = ""
	weapon_slot_2_path = ""
	active_weapon_slot = 1
	last_position = Vector2.ZERO
	last_scene = ""
