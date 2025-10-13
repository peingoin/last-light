extends StaticBody2D
class_name VanEntrance

@export var van_interior_scene: String = "res://scenes/VanInterior.tscn"

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = $InteractionArea
var player_nearby: bool = false
var interact_prompt: Label = null

func _ready() -> void:
	add_to_group("interactable")
	# Connect interaction area signals
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		_show_prompt()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		_hide_prompt()

func _unhandled_input(event: InputEvent) -> void:
	if player_nearby and event.is_action_pressed("interact"):
		enter_van()
		var viewport = get_viewport()
		if viewport:
			viewport.set_input_as_handled()

func enter_van() -> void:
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
				loading_audio.play()

		# Hide UI
		var ui_control = current_scene.get_node_or_null("CanvasLayer/UI Control")
		if ui_control:
			ui_control.visible = false

	# Save player state before entering van
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("save_state"):
		player.save_state()

	# Wait a bit for the audio to play
	await get_tree().create_timer(0.5).timeout

	# Change to van interior scene
	get_tree().change_scene_to_file(van_interior_scene)

func _show_prompt() -> void:
	# Find the interact prompt in the scene
	var current_scene = get_tree().current_scene
	if current_scene:
		interact_prompt = current_scene.get_node_or_null("CanvasLayer/UI Control/InteractPrompt")
		if interact_prompt:
			interact_prompt.text = "Press E to enter van"
			interact_prompt.visible = true

func _hide_prompt() -> void:
	if interact_prompt:
		interact_prompt.visible = false
