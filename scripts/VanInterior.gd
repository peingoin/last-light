extends Node2D

@onready var interact_prompt = $"CanvasLayer/UI Control/InteractPrompt"

func _ready() -> void:
	# Wait a frame to ensure all nodes are ready
	await get_tree().process_frame

	# Connect to all interactables in the scene
	_connect_interactables()

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
