extends Area2D
class_name Interactable

@onready var prompt: Label = $Prompt

func _ready() -> void:
	add_to_group("interactable")
	
	if prompt:
		prompt.visible = false
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		on_player_entered()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		on_player_exited()

func on_player_entered() -> void:
	if prompt:
		prompt.visible = true

func on_player_exited() -> void:
	if prompt:
		prompt.visible = false

func interact(_player: Node) -> void:
	pass