extends Node2D
class_name BaseWeapon

signal weapon_hit(target, damage, knockback_force, knockback_direction)
signal attack_started
signal attack_finished
signal cooldown_changed(cooldown_percent)

@export var weapon_name: String = "Base Weapon"
@export var damage: int = 10
@export var attack_cooldown: float = 1.0
@export var knockback_force: float = 200.0
@export var hitbox_start_frame: int = 2  # Frame when hitbox becomes active
@export var hitbox_end_frame: int = 4    # Frame when hitbox becomes inactive

var cooldown_timer: float = 0.0
var is_attacking: bool = false
var enemies_hit_this_attack: Array = []
var jiggle_time: float = 0.0
var base_position: Vector2 = Vector2.ZERO
var last_animation_state: String = ""

@onready var weapon_sprite: Sprite2D = $WeaponSprite
@onready var attack_animation: AnimationPlayer = $AttackAnimation
@onready var attack_effects: Node2D = $AttackEffects
@onready var slash_effect: AnimatedSprite2D = $AttackEffects/SlashEffect
@onready var hitbox: Area2D = $Hitbox
@onready var hitbox_shape: CollisionShape2D = $Hitbox/HitboxShape
@onready var attack_audio: AudioStreamPlayer2D = $AttackAudio

func _ready() -> void:
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	hitbox_shape.disabled = true

	# Set collision layers
	hitbox.collision_layer = 4  # Layer 3: Player Weapon Hitboxes
	hitbox.collision_mask = 8   # Layer 4: Enemy Hurtboxes

	# Hide attack effects initially
	if slash_effect:
		slash_effect.visible = false
		slash_effect.frame_changed.connect(_on_slash_frame_changed)

	# Store the base position for jiggling
	base_position = position

	# Debug weapon sprite

func _process(delta: float) -> void:
	if cooldown_timer > 0.0:
		cooldown_timer = max(0.0, cooldown_timer - delta)
		# Emit cooldown progress (1.0 = full cooldown, 0.0 = ready)
		var cooldown_percent = cooldown_timer / attack_cooldown
		cooldown_changed.emit(cooldown_percent)

	# Only track mouse direction when not attacking to rotate hitbox
	if not is_attacking:
		update_hitbox_rotation()

	# Add subtle idle jiggle when visible and not attacking
	if visible and not is_attacking:
		# Get player's animation state
		var player = get_parent().get_parent()
		var current_anim = "idle"
		if player and player.has_node("AnimatedSprite2D"):
			var anim_sprite = player.get_node("AnimatedSprite2D")
			current_anim = anim_sprite.animation

		# Reset timer when animation state changes
		if current_anim != last_animation_state:
			jiggle_time = 0.0
			last_animation_state = current_anim

		var jiggle_offset = 0.0
		if current_anim == "run":
			# Running pattern: up, up, down, down (4 frames at 10 FPS)
			jiggle_time += delta
			var frame = int(jiggle_time * 10.0) % 4
			if frame == 0 or frame == 1:
				jiggle_offset = -0.75  # up
			else:
				jiggle_offset = 0.75  # down
		else:
			# Idle pattern: down, same, up (3 frames, slower - 5 FPS for idle)
			jiggle_time += delta
			var frame = int(jiggle_time * 5.0) % 3
			if frame == 0:
				jiggle_offset = 0.5  # down
			elif frame == 1:
				jiggle_offset = 0.0  # same
			else:
				jiggle_offset = -0.5  # up

		position = base_position + Vector2(0, jiggle_offset)
	else:
		position = base_position

func attack(direction: Vector2) -> void:
	if not can_attack():
		return

	is_attacking = true
	cooldown_timer = attack_cooldown

	# Hide weapon sprite during attack
	if weapon_sprite:
		weapon_sprite.visible = false

	# Start attack animation and effects
	attack_started.emit()

	if slash_effect:
		# Rotate slash effect to match hitbox rotation
		var mouse_pos = get_global_mouse_position()
		var player = get_parent().get_parent()
		if player:
			var player_pos = player.global_position
			var attack_direction = (mouse_pos - player_pos).normalized()

			# Rotate the attack effects to match the hitbox
			var angle = attack_direction.angle()
			# Compensate for weapon slot flip
			var weapon_slot = get_parent()
			if weapon_slot and weapon_slot.scale.x < 0:
				angle = PI - angle
			attack_effects.rotation = angle

		slash_effect.visible = true
		slash_effect.frame = 0
		slash_effect.play("slash")
		slash_effect.animation_finished.connect(_on_attack_animation_finished)

	# Reset the list of enemies hit for this new attack
	enemies_hit_this_attack.clear()

func can_attack() -> bool:
	return cooldown_timer <= 0.0 and not is_attacking

func enable_hitbox() -> void:
	if hitbox_shape:
		hitbox_shape.disabled = false

func disable_hitbox() -> void:
	if hitbox_shape:
		hitbox_shape.disabled = true

func equip() -> void:
	visible = true

func unequip() -> void:
	visible = false

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "Hurtbox":
		var enemy = area.get_parent()
		var player = get_parent().get_parent()
		if player and enemy:
			# Only hit each enemy once per attack
			if enemy in enemies_hit_this_attack:
				print("Enemy already hit this attack, skipping")
				return
			enemies_hit_this_attack.append(enemy)
			print("Hitting enemy with damage: ", damage)

			# Calculate knockback direction from player to enemy
			var knockback_direction = (enemy.global_position - player.global_position).normalized()
			weapon_hit.emit(enemy, damage, knockback_force, knockback_direction)

func _on_slash_frame_changed() -> void:
	if not is_attacking:
		return

	var current_frame = slash_effect.frame

	# Enable/disable hitbox based on current frame
	if current_frame >= hitbox_start_frame and current_frame <= hitbox_end_frame:
		enable_hitbox()
	else:
		disable_hitbox()

func _on_attack_animation_finished() -> void:
	is_attacking = false
	disable_hitbox()

	# Show weapon sprite again after attack
	if weapon_sprite:
		weapon_sprite.visible = true

	attack_finished.emit()
	if slash_effect:
		slash_effect.stop()
		slash_effect.visible = false
		slash_effect.animation_finished.disconnect(_on_attack_animation_finished)

func update_hitbox_rotation() -> void:
	# Get the player (parent of weapon slot)
	var player = get_parent().get_parent()
	if player and player.global_position != Vector2.ZERO:
		var mouse_pos = get_global_mouse_position()
		var player_pos = player.global_position
		var direction = (mouse_pos - player_pos).normalized()
		# Only rotate the hitbox, not the entire weapon node
		# Account for parent scale when player is flipped
		if hitbox:
			var weapon_slot = get_parent()
			var angle = direction.angle()
			# Compensate for weapon slot flip
			if weapon_slot and weapon_slot.scale.x < 0:
				angle = PI - angle
			hitbox.rotation = angle
