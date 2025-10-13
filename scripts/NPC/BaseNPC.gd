extends InteractableArea
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

# Health properties
@export var max_health: int = 100
@export var current_health: int = 100

# Life force properties
@export var max_life_force: int = 100
@export var current_life_force: int = 100

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar

var is_talking: bool = false
var interaction_count: int = 0
var is_alive: bool = true
var can_interact_again: bool = true

func _ready() -> void:
	super._ready()

	# Add to NPCs group for the sacrifice system
	add_to_group("npcs")

	if animated_sprite and frames:
		animated_sprite.sprite_frames = frames
		animated_sprite.play(anim_idle)

	# Initialize health bar
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
		# Only show health bar if damaged
		if current_health < max_health:
			health_bar.show()
		else:
			health_bar.hide()

	# Connect to dialogue system if available
	var dialogue_system = get_node_or_null("/root/Dialogue")
	if dialogue_system and dialogue_system.has_signal("dialogue_finished"):
		dialogue_system.dialogue_finished.connect(_on_dialogue_finished)

func _process(_delta: float) -> void:
	# Update z_index for depth sorting
	z_index = int(global_position.y)

func interact(player: Node) -> void:
	if is_talking or not can_interact_again:
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
	can_interact_again = false
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

	# Add a small delay before allowing interaction again
	await get_tree().create_timer(0.3).timeout
	can_interact_again = true

	if destination_scene:
		get_tree().change_scene_to_packed(destination_scene)

# Override show_prompt and hide_prompt - NPCs use global prompt, so these are no-ops
func show_prompt() -> void:
	pass

func hide_prompt() -> void:
	pass

# Utility methods for interaction limits
func reset_interaction_count() -> void:
	interaction_count = 0

func set_interaction_limit(limit: int) -> void:
	max_interactions = limit

func get_remaining_interactions() -> int:
	if max_interactions < 0:
		return -1  # Infinite
	return max(0, max_interactions - interaction_count)

# Health management methods
func take_damage(amount: int) -> void:
	if not is_alive:
		return

	current_health = max(0, current_health - amount)
	if health_bar:
		health_bar.value = current_health
		# Show health bar when taking damage
		health_bar.show()

	if current_health <= 0:
		die()

func heal(amount: int) -> void:
	if not is_alive:
		return

	current_health = min(max_health, current_health + amount)
	if health_bar:
		health_bar.value = current_health
		# Hide health bar if fully healed
		if current_health >= max_health:
			health_bar.hide()
		else:
			health_bar.show()

func die() -> void:
	is_alive = false
	if health_bar:
		health_bar.hide()
	
	# Remove from NPCs group for sacrifice system
	if is_in_group("npcs"):
		remove_from_group("npcs")
	
	# Disable interactions
	set_process(false)
	set_physics_process(false)
	
	# Play death animation if available, otherwise just hide
	if animated_sprite and animated_sprite.sprite_frames.has_animation("death"):
		animated_sprite.play("death")
		await animated_sprite.animation_finished
	
	queue_free()

func get_life_force() -> int:
	return current_life_force

func consume_life_force(amount: int) -> int:
	"""Consume life force from NPC and return actual amount consumed"""
	var amount_consumed = min(amount, current_life_force)
	current_life_force -= amount_consumed

	if current_life_force <= 0:
		die()

	return amount_consumed
