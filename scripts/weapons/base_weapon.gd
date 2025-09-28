extends Node2D
class_name BaseWeapon

signal weapon_hit(target, damage, knockback_force, knockback_direction)
signal attack_started
signal attack_finished

@export var weapon_name: String = "Base Weapon"
@export var damage: int = 10
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 1.0
@export var knockback_force: float = 200.0

var cooldown_timer: float = 0.0
var is_attacking: bool = false

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

	# Debug weapon sprite
	print("Weapon ready - sprite texture: ", weapon_sprite.texture, " visible: ", weapon_sprite.visible)

func _process(delta: float) -> void:
	if cooldown_timer > 0.0:
		cooldown_timer = max(0.0, cooldown_timer - delta)

	# Only track mouse direction when not attacking
	if not is_attacking:
		update_weapon_rotation()

func attack(direction: Vector2) -> void:
	if not can_attack():
		return

	is_attacking = true
	cooldown_timer = attack_cooldown

	# Hide weapon sprite during attack
	if weapon_sprite:
		weapon_sprite.visible = false

	# Weapon is already rotated by update_weapon_rotation()
	# Start attack animation and effects
	attack_started.emit()

	if slash_effect:
		# Flip slash effect based on attack direction
		var mouse_pos = get_global_mouse_position()
		var player = get_parent().get_parent()
		if player:
			var player_pos = player.global_position
			var attack_direction = (mouse_pos - player_pos).normalized()

			# Flip the slash effect based on attack direction
			var angle = attack_direction.angle()
			var degrees = rad_to_deg(angle)
			if degrees < 0:
				degrees += 360

			# Determine flip based on quadrant
			if degrees >= 315 || degrees < 45:
				# Right (0°) - normal
				slash_effect.flip_h = false
				slash_effect.flip_v = false
			elif degrees >= 45 && degrees < 135:
				# Down (90°) - flip vertically
				slash_effect.flip_h = false
				slash_effect.flip_v = true
			elif degrees >= 135 && degrees < 225:
				# Left (180°) - flip vertically (reflection across x-axis)
				slash_effect.flip_h = false
				slash_effect.flip_v = true
			else:
				# Up (270°) - normal (so up slash looks like up)
				slash_effect.flip_h = false
				slash_effect.flip_v = false

		slash_effect.visible = true
		slash_effect.play("slash")
		slash_effect.animation_finished.connect(_on_attack_animation_finished)

	# Enable hitbox during attack (will be disabled by animation)
	enable_hitbox()

	# Disable hitbox after a brief moment (simulating attack frames)
	await get_tree().create_timer(0.2).timeout
	disable_hitbox()

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
	print("Weapon equipped - visible: ", visible, " position: ", global_position)

func unequip() -> void:
	visible = false

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "Hurtbox":
		var enemy = area.get_parent()
		var player = get_parent().get_parent()
		if player and enemy:
			# Calculate knockback direction from player to enemy
			var knockback_direction = (enemy.global_position - player.global_position).normalized()
			weapon_hit.emit(enemy, damage, knockback_force, knockback_direction)

func _on_attack_animation_finished() -> void:
	is_attacking = false

	# Show weapon sprite again after attack
	if weapon_sprite:
		weapon_sprite.visible = true

	attack_finished.emit()
	if slash_effect:
		slash_effect.stop()
		slash_effect.visible = false
		slash_effect.animation_finished.disconnect(_on_attack_animation_finished)

func update_weapon_rotation() -> void:
	# Get the player (parent of weapon slot)
	var player = get_parent().get_parent()
	if player and player.global_position != Vector2.ZERO:
		var mouse_pos = get_global_mouse_position()
		var player_pos = player.global_position
		var direction = (mouse_pos - player_pos).normalized()
		rotation = direction.angle()
