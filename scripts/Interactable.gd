extends Area2D
class_name InteractableArea

signal player_nearby(interactable: Node)
signal player_left(interactable: Node)

func _ready() -> void:
	add_to_group("interactable")

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		on_player_entered()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		on_player_exited()

func on_player_entered() -> void:
	# Emit signal for UI to show prompt
	player_nearby.emit(self)

func on_player_exited() -> void:
	# Emit signal for UI to hide prompt
	player_left.emit(self)

func interact(_player: Node) -> void:
	pass
