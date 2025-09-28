extends CharacterBody2D

signal health_changed(new_health)
signal weapon_equipped(weapon_name)
signal weapon_unequipped

const speed: float = 150.0
const accel: float = 1.0

var input: Vector2
var player_health: int = 5

@export var invuln_duration: float = 0.6
var is_invulnerable: bool = false

# Weapon system variables
var current_weapon: Node2D = null

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interact_sensor: Area2D = $InteractSensor
@onready var weapon_slot: Node2D = $WeaponSlot

var nearby_interactables: Array[Interactable] = []
var closest_interactable: Interactable = null

func get_input() -> Vector2:
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	# face direction
	if input.x > 0.0:
		animated_sprite.flip_h = false
	elif input.x < 0.0:
		animated_sprite.flip_h = true

	# don't interrupt the "hit" animation while it plays
	if animated_sprite.animation != "hit":
		if input == Vector2.ZERO:
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")
		else:
			if animated_sprite.animation != "run":
				animated_sprite.play("run")

	return input.normalized()

func _ready() -> void:
	add_to_group("player")
	
	if interact_sensor:
		interact_sensor.area_entered.connect(_on_interactable_entered)
		interact_sensor.area_exited.connect(_on_interactable_exited)


func _process(delta):
	var player_input = get_input()

	velocity = player_input * speed

	move_and_slide()
	
	# Handle weapon attacks
	handle_weapon_attack()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_handle_interact()

func _handle_interact() -> void:
	if has_node("/root/Dialogue") and get_node("/root/Dialogue").current_lines.size() > 0:
		return
	
	if closest_interactable:
		closest_interactable.interact(self)

func can_take_damage() -> bool:
	# Return TRUE only when the player is NOT invulnerable
	return not is_invulnerable

func take_damage(damage: int) -> void:
	if is_invulnerable:
		return

	player_health -= damage
	health_changed.emit(player_health)

	# Check if player died
	if player_health <= 0:
		die()
		return

	is_invulnerable = true

	# play hit anim immediately
	animated_sprite.play("hit")

	# flicker while invulnerable (non-blocking)
	start_flicker(invuln_duration)

	# end i-frames after a delay
	await get_tree().create_timer(invuln_duration).timeout
	is_invulnerable = false

	# resume to idle/run depending on input
	if input == Vector2.ZERO:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("run")

# Visual feedback for i-frames (alpha toggle)
func start_flicker(duration: float) -> void:
	var sprite := animated_sprite
	var original_alpha := sprite.modulate.a
	var flicker_interval := 0.1
	var elapsed_time := 0.0

	while elapsed_time < duration:
		sprite.modulate.a = 0.5 if sprite.modulate.a == original_alpha else original_alpha
		await get_tree().create_timer(flicker_interval).timeout
		elapsed_time += flicker_interval

	# Restore original alpha
	sprite.modulate.a = original_alpha

func _on_interactable_entered(area: Area2D) -> void:
	if area is Interactable:
		nearby_interactables.append(area)
		_update_closest_interactable()

func _on_interactable_exited(area: Area2D) -> void:
	if area is Interactable:
		nearby_interactables.erase(area)
		_update_closest_interactable()

func _update_closest_interactable() -> void:
	if nearby_interactables.is_empty():
		closest_interactable = null
		return
	
	var closest_distance := INF
	var new_closest: Interactable = null
	
	for interactable in nearby_interactables:
		if not is_instance_valid(interactable):
			continue
		
		var distance := global_position.distance_to(interactable.global_position)
		if distance < closest_distance:
			closest_distance = distance
			new_closest = interactable
	
	closest_interactable = new_closest

# Weapon management methods
func equip_weapon(weapon_scene_path: String) -> void:
	unequip_weapon()  # Remove current weapon if any
	var weapon_scene = load(weapon_scene_path)
	if weapon_scene:
		current_weapon = weapon_scene.instantiate()
		weapon_slot.add_child(current_weapon)
		current_weapon.weapon_hit.connect(_on_weapon_hit)
		current_weapon.equip()
		weapon_equipped.emit(current_weapon.weapon_name)
		print("Player equipped weapon: ", current_weapon.weapon_name, " at slot position: ", weapon_slot.position)
	else:
		print("Failed to load weapon scene: ", weapon_scene_path)

func unequip_weapon() -> void:
	if current_weapon:
		current_weapon.queue_free()
		current_weapon = null
		weapon_unequipped.emit()

func handle_weapon_attack() -> void:
	if Input.is_action_just_pressed("left_click") and current_weapon and current_weapon.can_attack():
		var attack_direction = get_mouse_attack_direction()
		current_weapon.attack(attack_direction)

func get_mouse_attack_direction() -> Vector2:
	var mouse_pos = get_global_mouse_position()
	var player_pos = global_position
	return (mouse_pos - player_pos).normalized()

func _on_weapon_hit(enemy, damage: int, knockback_force: float, knockback_direction: Vector2) -> void:
	# Handle weapon hit events
	if enemy.has_method("take_damage"):
		enemy.call("take_damage", damage)
	if enemy.has_method("apply_knockback"):
		enemy.call("apply_knockback", knockback_force, knockback_direction)

func die() -> void:
	print("Player died!")
	# Disable player movement and input
	set_physics_process(false)
	set_process(false)

	# Play death animation if available, otherwise show hit animation
	animated_sprite.play("hit")

	# Create death message UI
	show_death_message()

	# Wait a moment for visual feedback
	await get_tree().create_timer(3.0).timeout

	# Return to main menu
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func show_death_message() -> void:
	# Create a CanvasLayer for the death message overlay
	var death_overlay = CanvasLayer.new()
	death_overlay.layer = 100  # Ensure it's on top of everything
	get_tree().current_scene.add_child(death_overlay)

	# Create a ColorRect for dark background
	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.7)  # Semi-transparent black
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	death_overlay.add_child(background)

	# Create the death message label
	var death_label = Label.new()
	death_label.text = "YOU DIED"
	death_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	death_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	death_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Set large red text
	death_label.add_theme_font_size_override("font_size", 72)
	death_label.add_theme_color_override("font_color", Color.RED)
	death_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	death_label.add_theme_constant_override("shadow_offset_x", 4)
	death_label.add_theme_constant_override("shadow_offset_y", 4)

	death_overlay.add_child(death_label)
