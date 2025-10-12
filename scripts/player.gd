extends CharacterBody2D

signal health_changed(new_health)
signal weapon_equipped(weapon_name)
signal weapon_unequipped

const speed: float = 150.0
const accel: float = 1.0
const dash_speed: float = 200.0
const dash_duration: float = 0.2
const dash_cooldown: float = 1.0

var input: Vector2
var player_health: int = 5

@export var invuln_duration: float = 0.6
var is_invulnerable: bool = false

# Dash system variables
var is_dashing: bool = false
var dash_available: bool = true
var dash_direction: Vector2 = Vector2.ZERO
var dash_cooldown_timer: float = 0.0

# Weapon system variables
var weapon_slot_1: Node2D = null  # First weapon slot
var weapon_slot_2: Node2D = null  # Second weapon slot
var active_weapon_slot: int = 1   # Which slot is currently active (1 or 2)

# Interaction system variables
var current_interactable: Node = null
var inventory: Dictionary = {"wood": 0, "steel": 0}

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_effect: AnimatedSprite2D = $dash_effect
@onready var interact_sensor: Area2D = $InteractSensor
@onready var weapon_slot: Node2D = $WeaponSlot
@onready var interaction_area: Area2D = $InteractionArea

var weapon_ui_container: Control  # Will be set by game.gd
var weapon_active_icon: TextureRect
var weapon_inactive_icon: TextureRect
var cooldown_overlay: Panel  # Will be set by game.gd

var nearby_interactables: Array = []
var closest_interactable = null
var is_talking: bool = false


func get_input() -> Vector2:
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	# face direction
	if input.x > 0.0:
		animated_sprite.flip_h = false
	elif input.x < 0.0:
		animated_sprite.flip_h = true

	# don't interrupt the "hit" animation while it plays, and don't change animation during dash
	if animated_sprite.animation != "hit" and not is_dashing:
		if input == Vector2.ZERO:
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")
		else:
			if animated_sprite.animation != "run":
				animated_sprite.play("run")

	return input.normalized()

func _ready() -> void:
	add_to_group("player")

	# Load player state from global PlayerData
	if has_node("/root/PlayerData"):
		PlayerData.load_player_state(self)

	# Hide dash effect initially
	if dash_effect:
		dash_effect.visible = false

	# Connect interaction area signals
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)

	# Connect interact sensor signals if available
	if interact_sensor:
		interact_sensor.area_entered.connect(_on_interactable_entered)
		interact_sensor.area_exited.connect(_on_interactable_exited)

	# Connect to dialogue system signals
	if has_node("/root/Dialogue"):
		var dialogue = get_node("/root/Dialogue")
		if dialogue.has_signal("dialogue_finished"):
			dialogue.dialogue_finished.connect(_on_dialogue_finished)


func _process(delta):
	# Update dash cooldown
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0:
			dash_available = true

	# Handle dash movement or normal movement
	if is_dashing:
		velocity = dash_direction * dash_speed
	else:
		var player_input = Vector2.ZERO
		if not is_talking:
			player_input = get_input()
		velocity = player_input * speed

	move_and_slide()

	# Flip weapon to match player direction
	if weapon_slot and animated_sprite:
		weapon_slot.scale.x = -1 if animated_sprite.flip_h else 1

	# Handle weapon attacks (only if not talking and not dashing)
	if not is_talking and not is_dashing:
		handle_weapon_attack()

func _unhandled_input(event: InputEvent) -> void:
	# Disable all inputs when talking
	if is_talking:
		return

	if event.is_action_pressed("interact"):
		_handle_interact()

	# Switch between weapons with E key
	if event.is_action_pressed("switch_weapon"):
		swap_weapons()

	# Dash with Space key
	if event.is_action_pressed("dash"):
		perform_dash()

func _handle_interact() -> void:
	if closest_interactable:
		# Set is_talking to true when interacting with NPC
		if closest_interactable is BaseNPC:
			is_talking = true
			# Hide interact prompt when starting dialogue
			_hide_interact_prompt()
		closest_interactable.interact(self)

	# Handle interaction input
	handle_interaction()

func _hide_interact_prompt() -> void:
	# Find and hide the interact prompt in the scene
	var current_scene = get_tree().current_scene
	if current_scene:
		var prompt = current_scene.get_node_or_null("CanvasLayer/UI Control/InteractPrompt")
		if prompt:
			prompt.visible = false

func _update_interact_prompt_visibility() -> void:
	# Show interact prompt if near an interactable
	if closest_interactable:
		var current_scene = get_tree().current_scene
		if current_scene:
			var prompt = current_scene.get_node_or_null("CanvasLayer/UI Control/InteractPrompt")
			if prompt:
				prompt.visible = true

func can_take_damage() -> bool:
	# Return TRUE only when the player is NOT invulnerable
	return not is_invulnerable

func can_dash() -> bool:
	return dash_available and not is_dashing and not is_talking

func perform_dash() -> void:
	if not can_dash():
		return

	# Determine dash direction
	if input != Vector2.ZERO:
		dash_direction = input.normalized()
	else:
		dash_direction = get_mouse_attack_direction()

	# Set dash state
	is_dashing = true
	dash_available = false

	# Grant i-frames during dash (Hades-style)
	is_invulnerable = true

	# Play dash effect animation
	if dash_effect:
		dash_effect.visible = true
		# Set rotation and flip based on dash direction FIRST (before positioning)
		# Handle vertical dashes
		if abs(dash_direction.y) > abs(dash_direction.x):
			# Mostly vertical dash
			dash_effect.flip_h = false
			if dash_direction.y > 0:
				dash_effect.rotation = -PI / 2  # Dash down, smoke points up (-90 degrees)
			else:
				dash_effect.rotation = PI / 2  # Dash up, smoke points down (90 degrees)
		else:
			# Mostly horizontal dash
			dash_effect.rotation = 0
			if dash_direction.x > 0:
				dash_effect.flip_h = true  # Dash right, smoke flipped
			else:
				dash_effect.flip_h = false  # Dash left, smoke not flipped

		# Position dash effect at feet, opposite to dash direction
		var feet_offset = Vector2(-7, -8)  # Player's feet position
		var opposite_direction = -dash_direction
		var dash_effect_offset = opposite_direction * 15.0  # Distance behind player
		dash_effect.position = feet_offset + dash_effect_offset

		dash_effect.frame = 0
		dash_effect.play("dash")

	# Start dash duration timer
	await get_tree().create_timer(dash_duration).timeout

	# End dash
	is_dashing = false
	is_invulnerable = false

	# Hide dash effect
	if dash_effect:
		dash_effect.visible = false
		dash_effect.stop()
		dash_effect.rotation = 0  # Reset rotation

	# Start cooldown timer
	dash_cooldown_timer = dash_cooldown

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
	if area.is_in_group("interactable"):
		nearby_interactables.append(area)
		_update_closest_interactable()

func _on_interactable_exited(area: Area2D) -> void:
	if area.is_in_group("interactable"):
		nearby_interactables.erase(area)
		_update_closest_interactable()

func _update_closest_interactable() -> void:
	if nearby_interactables.is_empty():
		closest_interactable = null
		return
	
	var closest_distance := INF
	var new_closest = null
	
	for interactable in nearby_interactables:
		if not is_instance_valid(interactable):
			continue
		
		var distance := global_position.distance_to(interactable.global_position)
		if distance < closest_distance:
			closest_distance = distance
			new_closest = interactable
	
	closest_interactable = new_closest

# Weapon management methods
func equip_weapon(weapon_scene_path: String, slot: int = 1) -> void:
	if slot < 1 or slot > 2:
		return

	var weapon_scene = load(weapon_scene_path)
	if not weapon_scene:
		return

	# Remove existing weapon in this slot
	if slot == 1 and weapon_slot_1:
		weapon_slot_1.queue_free()
		weapon_slot_1 = null
	elif slot == 2 and weapon_slot_2:
		weapon_slot_2.queue_free()
		weapon_slot_2 = null

	# Create and add new weapon
	var new_weapon = weapon_scene.instantiate()
	weapon_slot.add_child(new_weapon)
	new_weapon.weapon_hit.connect(_on_weapon_hit)

	# Assign to appropriate slot
	if slot == 1:
		weapon_slot_1 = new_weapon
	else:
		weapon_slot_2 = new_weapon

	# Show only if this is the active slot
	if slot == active_weapon_slot:
		new_weapon.equip()
		weapon_equipped.emit(new_weapon.weapon_name)
	else:
		new_weapon.unequip()

	# Update UI
	update_weapon_ui()

func update_weapon_ui() -> void:
	if not weapon_active_icon or not weapon_inactive_icon:
		return

	var active_weapon = weapon_slot_1 if active_weapon_slot == 1 else weapon_slot_2
	var inactive_weapon = weapon_slot_2 if active_weapon_slot == 1 else weapon_slot_1

	# Update active weapon icon
	weapon_active_icon.texture = _get_weapon_icon_texture(active_weapon)

	# Update inactive weapon icon
	weapon_inactive_icon.texture = _get_weapon_icon_texture(inactive_weapon)

func _get_weapon_icon_texture(weapon: Node2D) -> Texture2D:
	if not weapon or not weapon.has_node("WeaponSprite"):
		return null

	var sprite = weapon.get_node("WeaponSprite")

	# Check if sprite uses region (for texture atlases)
	if sprite.region_enabled:
		# Create AtlasTexture to extract the specific region
		var atlas = AtlasTexture.new()
		atlas.atlas = sprite.texture
		atlas.region = sprite.region_rect
		return atlas
	else:
		# Use texture directly for non-region sprites
		return sprite.texture

func swap_weapons() -> void:
	# Switch to the other slot
	var new_slot = 2 if active_weapon_slot == 1 else 1
	var target_weapon = weapon_slot_1 if new_slot == 1 else weapon_slot_2

	if not target_weapon:
		return  # No weapon in the other slot

	# Hide current weapon
	var current_weapon = weapon_slot_1 if active_weapon_slot == 1 else weapon_slot_2
	if current_weapon:
		current_weapon.unequip()

	# Show new weapon
	active_weapon_slot = new_slot
	target_weapon.equip()
	weapon_equipped.emit(target_weapon.weapon_name)
	update_weapon_ui()

	# Reconnect cooldown to UI
	_reconnect_cooldown_to_ui()

func switch_to_weapon(slot: int) -> void:
	if slot < 1 or slot > 2:
		return

	var target_weapon = weapon_slot_1 if slot == 1 else weapon_slot_2
	if not target_weapon:
		return  # No weapon in this slot

	# Hide current weapon
	var current_weapon = weapon_slot_1 if active_weapon_slot == 1 else weapon_slot_2
	if current_weapon:
		current_weapon.unequip()

	# Show new weapon
	active_weapon_slot = slot
	target_weapon.equip()
	weapon_equipped.emit(target_weapon.weapon_name)

func get_current_weapon() -> Node2D:
	return weapon_slot_1 if active_weapon_slot == 1 else weapon_slot_2

# Property to get active weapon (for easier access)
var active_weapon: Node2D:
	get:
		return get_current_weapon()

func unequip_weapon() -> void:
	if weapon_slot_1:
		weapon_slot_1.queue_free()
		weapon_slot_1 = null
	if weapon_slot_2:
		weapon_slot_2.queue_free()
		weapon_slot_2 = null
	weapon_unequipped.emit()

func handle_weapon_attack() -> void:
	var current_weapon = get_current_weapon()
	if not current_weapon:
		return

	# Check if weapon is a ranged weapon for continuous firing
	var is_ranged = current_weapon is RangedWeapon

	# Ranged weapons: hold to fire continuously; Melee weapons: click each time
	var should_attack = false
	if is_ranged:
		should_attack = Input.is_action_pressed("left_click") and current_weapon.can_attack()
	else:
		should_attack = Input.is_action_just_pressed("left_click") and current_weapon.can_attack()

	if should_attack:
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
	# Player died
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

func handle_interaction() -> void:
	if Input.is_action_just_pressed("interact") and current_interactable:
		if current_interactable.has_method("can_interact") and current_interactable.can_interact():
			current_interactable.interact_with(self)

func _on_resources_collected(resources: Dictionary) -> void:
	for resource_type in resources:
		inventory[resource_type] += resources[resource_type]
	# Resources collected and added to inventory

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.has_method("can_interact"):
		current_interactable = body
		# Near interactable

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body == current_interactable:
		current_interactable = null
		# Left interactable area

func _reconnect_cooldown_to_ui() -> void:
	# Call the game's reconnection function
	var game = get_parent()
	if game and game.has_method("_connect_weapon_cooldown"):
		game._connect_weapon_cooldown()

func _on_dialogue_finished() -> void:
	# Re-enable inputs when dialogue finishes
	is_talking = false

	# Show interact prompt again if still near an interactable
	_update_interact_prompt_visibility()

func save_state() -> void:
	# Save player state to global PlayerData before scene transitions
	if has_node("/root/PlayerData"):
		PlayerData.save_player_state(self)

func _exit_tree() -> void:
	# Auto-save player state when player is removed from scene tree
	save_state()
