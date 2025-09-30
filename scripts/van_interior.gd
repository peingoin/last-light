extends Area2D

@export_file("*.tscn") var target_scene: String = "res://scenes/game.tscn"
@export var require_player_group: String = "player"
@export var one_shot: bool = true      # prevent multiple triggers
@export var delay_seconds: float = 0.0 # optional small delay before switch

var _used: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _used and one_shot:
		return
	# Only allow the Player to trigger
	if require_player_group != "" and not body.is_in_group(require_player_group):
		return
	_used = true
	if delay_seconds > 0.0:
		await get_tree().create_timer(delay_seconds).timeout
	if not is_inside_tree():
		return
	get_tree().change_scene_to_file(target_scene)
