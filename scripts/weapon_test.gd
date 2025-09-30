extends Node

# Test script to verify weapon system functionality
# Add this to the game scene as a child node to test weapons

func _ready() -> void:
	# Wait for scene to be ready
	await get_tree().process_frame

	# Find the player and equip a weapon
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_node("../Player")

	if player and player.has_method("equip_weapon"):
		player.equip_weapon("res://scenes/weapons/iron_sword.tscn")

		# Connect to weapon events for testing
		player.weapon_equipped.connect(_on_weapon_equipped)
		player.weapon_unequipped.connect(_on_weapon_unequipped)
	else:

func _on_weapon_equipped(weapon_name: String) -> void:

func _on_weapon_unequipped() -> void:

func _input(event: InputEvent) -> void:
	# Test keys for weapon system
	if event.is_action_pressed("ui_accept"):  # Space key
		var player = get_tree().get_first_node_in_group("player")
		if not player:
			player = get_node("../Player")

		if player:
			if player.current_weapon:
				player.unequip_weapon()
			else:
				player.equip_weapon("res://scenes/weapons/iron_sword.tscn")
