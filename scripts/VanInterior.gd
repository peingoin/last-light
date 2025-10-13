extends Node2D

@onready var interact_prompt = $"CanvasLayer/UI Control/InteractPrompt"
@onready var health_bar = $"CanvasLayer/UI Control/HealthBar"
@onready var wood_label = $"CanvasLayer/UI Control/HealthBar/Wood Indicator Control/Wood Label"
@onready var metal_label = $"CanvasLayer/UI Control/HealthBar/Metal Indicator Control/Metal Label"

func _ready() -> void:
	# Wait a frame to ensure all nodes are ready
	await get_tree().process_frame

	# Initialize UI from player data
	_initialize_ui()

	# Connect to all interactables in the scene
	_connect_interactables()

func _initialize_ui() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# Initialize health bar
	if health_bar:
		health_bar.init_health(player.player_health)

		# Connect to player's health changes
		if player.has_signal("health_changed"):
			if not player.health_changed.is_connected(_on_player_health_changed):
				player.health_changed.connect(_on_player_health_changed)

	# Initialize resource UI from player inventory
	if wood_label and "wood" in player.inventory:
		wood_label.text = str(player.inventory["wood"])
	if metal_label and "steel" in player.inventory:
		metal_label.text = str(player.inventory["steel"])

func _on_player_health_changed(new_health: int) -> void:
	if health_bar:
		health_bar.health = new_health

func _connect_interactables():
	# Connect to all existing interactables
	for interactable in get_tree().get_nodes_in_group("interactable"):
		if not interactable.player_nearby.is_connected(_on_interactable_nearby):
			interactable.player_nearby.connect(_on_interactable_nearby)
		if not interactable.player_left.is_connected(_on_interactable_left):
			interactable.player_left.connect(_on_interactable_left)

func _on_interactable_nearby(_interactable: Node):
	if interact_prompt:
		interact_prompt.visible = true

func _on_interactable_left(_interactable: Node):
	if interact_prompt:
		interact_prompt.visible = false
