extends Interactable
class_name BaseNPC

@export var display_name: StringName = "NPC"
@export var lines: PackedStringArray = []
@export var frames: SpriteFrames
@export var anim_idle: StringName = "idle"
@export var anim_talk: StringName = "talk"
@export var destination_scene: PackedScene

# Interaction limits
@export var max_interactions: int = -1  # -1 = infinite, 0 = no interactions, >0 = limited
@export var interaction_limit_message: String = "I have nothing more to say."

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_talking: bool = false
var interaction_count: int = 0

func _ready() -> void:
	super._ready()
	
	if animated_sprite and frames:
		animated_sprite.sprite_frames = frames
		animated_sprite.play(anim_idle)
	
	# Connect to dialogue system if available
	var dialogue_system = get_node_or_null("/root/Dialogue")
	if dialogue_system and dialogue_system.has_signal("dialogue_finished"):
		dialogue_system.dialogue_finished.connect(_on_dialogue_finished)

func interact(player: Node) -> void:
	if is_talking:
		return
	
	# Check interaction limits
	if max_interactions == 0:
		# No interactions allowed
		return
	elif max_interactions > 0 and interaction_count >= max_interactions:
		# Reached interaction limit
		is_talking = true
		if animated_sprite and animated_sprite.sprite_frames.has_animation(anim_talk):
			animated_sprite.play(anim_talk)
		var dialogue_system = get_node_or_null("/root/Dialogue")
		if dialogue_system and dialogue_system.has_method("open_single"):
			dialogue_system.open_single(display_name, interaction_limit_message)
		return
	
	if lines.is_empty():
		return
	
	is_talking = true
	interaction_count += 1
	
	if animated_sprite and animated_sprite.sprite_frames.has_animation(anim_talk):
		animated_sprite.play(anim_talk)
	
	var dialogue_system = get_node_or_null("/root/Dialogue")
	if dialogue_system and dialogue_system.has_method("open"):
		dialogue_system.open(lines, display_name)

func _on_dialogue_finished() -> void:
	is_talking = false
	
	if animated_sprite:
		animated_sprite.play(anim_idle)
	
	if destination_scene:
		get_tree().change_scene_to_packed(destination_scene)

# Utility methods for interaction limits
func reset_interaction_count() -> void:
	interaction_count = 0

func set_interaction_limit(limit: int) -> void:
	max_interactions = limit

func get_remaining_interactions() -> int:
	if max_interactions < 0:
		return -1  # Infinite
	return max(0, max_interactions - interaction_count)
