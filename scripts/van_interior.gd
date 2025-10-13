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

	# Save player state before leaving van
	if body.has_method("save_state"):
		body.save_state()

	# Show loading screen and play audio
	var current_scene = get_tree().current_scene
	if current_scene:
		# Show loading screen
		var loading_screen = current_scene.get_node_or_null("CanvasLayer/LoadingScreen")
		if loading_screen:
			loading_screen.visible = true
			# Play loading audio
			if loading_screen.has_node("LoadingAudio"):
				var loading_audio = loading_screen.get_node("LoadingAudio")
				# Load and play audio
				loading_audio.stream = load("res://assets/Audio/Loading.mp3")
				loading_audio.play()

		# Hide UI
		var ui_control = current_scene.get_node_or_null("CanvasLayer/UI Control")
		if ui_control:
			ui_control.visible = false

	if delay_seconds > 0.0:
		await get_tree().create_timer(delay_seconds).timeout
	else:
		# Wait a bit for the audio to play
		await get_tree().create_timer(0.5).timeout

	if not is_inside_tree():
		return

	# Return to game scene (use call_deferred to avoid physics callback issues)
	get_tree().call_deferred("change_scene_to_file", target_scene)
