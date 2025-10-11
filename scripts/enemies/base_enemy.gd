## Base class for all enemies in the game.
## Handles AI, combat, movement, knockback, and death.
##
## To create a new enemy:
## 1. Create a new script that extends BaseEnemy
## 2. Override stats in _ready() before calling super._ready()
## 3. (Optional) Override functions for custom behavior

class_name BaseEnemy
extends CharacterBody2D

var speed: float
var detect_range: float
var attack_range: float
var pause_time: float
var attack_cooldown: float
var damage: int
var swing_hit_frame: int
var swing_max_distance: float
var attack_interrupt_factor: float
var knockback_resistance: float
var invuln_duration: float
var enemy_health: float

var player: Node2D
var cooldown_timer := 0.0
var is_attacking := false
var swing_already_hit := false
var recovering := false   # <-- new: short pause after a landed hit
var knockback_velocity := Vector2.ZERO
var is_dying := false
var is_invulnerable := false

func _ready() -> void:
	if get_parent().has_node("Player"):
		player = get_parent().get_node("Player")
	$AnimatedSprite2D.animation_finished.connect(_on_anim_finished)
	$AnimatedSprite2D.frame_changed.connect(_on_frame_changed)
	$AnimatedSprite2D.play("idle")

	# Connect hurtbox for weapon damage
	if has_node("Hurtbox"):
		$Hurtbox.area_entered.connect(_on_hurtbox_hit)

	# Make sure "swing" does NOT loop in the SpriteFrames resource (editor).

func _physics_process(delta: float) -> void:
	if player == null or is_dying:
		return

	# Apply knockback velocity and reduce it over time
	if knockback_velocity != Vector2.ZERO:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 500.0 * delta)
		move_and_slide()
		return

	# cooldown tick
	if cooldown_timer > 0.0:
		cooldown_timer = max(0.0, cooldown_timer - delta)

	# while recovering, do nothing
	if recovering:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var dist := global_position.distance_to(player.global_position)

	# --- INTERRUPT ATTACK IF PLAYER MOVES AWAY MID-SWING ---
	if is_attacking:
		# face the player during the windup
		$AnimatedSprite2D.flip_h = (player.global_position.x - global_position.x) < 0
		# If player got far enough, cancel attack and chase
		if dist > attack_range * attack_interrupt_factor:
			is_attacking = false
			swing_already_hit = false
			$AnimatedSprite2D.play("walk")
			# fall through into chase below (no early return)
		else:
			# still attacking; don't move
			velocity = Vector2.ZERO
			move_and_slide()
			return

	# out of detection range
	if dist > detect_range:
		if not is_attacking:
			velocity = Vector2.ZERO
			if $AnimatedSprite2D.animation != "idle":
				$AnimatedSprite2D.play("idle")
		move_and_slide()
		return

	# chase (only when not attacking)
	if dist > attack_range and not is_attacking:
		var dir := (player.global_position - global_position).normalized()
		velocity = dir * speed
		$AnimatedSprite2D.flip_h = dir.x < 0
		if $AnimatedSprite2D.animation != "walk":
			$AnimatedSprite2D.play("walk")
		move_and_slide()
		return

	# start attack
	if dist <= attack_range and cooldown_timer == 0.0 and not is_attacking:
		is_attacking = true
		swing_already_hit = false
		velocity = Vector2.ZERO
		$AnimatedSprite2D.flip_h = (player.global_position.x - global_position.x) < 0
		$AnimatedSprite2D.frame = 0         # ensure the swing restarts
		$AnimatedSprite2D.play("swing")
		cooldown_timer = attack_cooldown

	move_and_slide()

func _on_frame_changed() -> void:
	# Deal damage exactly once at the apex frame
	if not is_attacking: return
	if $AnimatedSprite2D.animation != "swing": return
	if swing_already_hit: return
	if $AnimatedSprite2D.frame != swing_hit_frame: return

	# Only hit if player still close
	var dist := global_position.distance_to(player.global_position)
	if dist <= swing_max_distance + 7:
		# Respect player i-frames: only hit if they CAN take damage
		if not player.call("can_take_damage"):
			return

		if player.has_method("take_damage"):
			player.call("take_damage", damage)

		swing_already_hit = true

		# Exit attack and pause briefly (1s) before resuming normal logic
		await pause_for(pause_time)

func _on_anim_finished() -> void:
	var anim_name = $AnimatedSprite2D.animation
	# Handle death animation completion
	if anim_name == "death":
		queue_free()
		return

	# Keep this for the case when a swing completes naturally
	if anim_name == "swing":
		is_attacking = false
		swing_already_hit = false
		if not player:
			$AnimatedSprite2D.play("idle")
			return
		var dist := global_position.distance_to(player.global_position)
		if dist > attack_range:
			$AnimatedSprite2D.play("walk")
		else:
			$AnimatedSprite2D.play("idle")

# ----- Recovery helper -----
func pause_for(seconds: float) -> void:
	recovering = true
	is_attacking = false
	swing_already_hit = false
	velocity = Vector2.ZERO
	$AnimatedSprite2D.play("idle")
	await get_tree().create_timer(seconds).timeout
	recovering = false

# Handle weapon damage
func _on_hurtbox_hit(hitbox: Area2D) -> void:
	# This will be called when weapon hitbox hits this enemy's hurtbox
	# The actual damage will be handled by the player's weapon system
	pass

func take_damage(damage: int) -> void:
	if is_dying or is_invulnerable:
		print("invun")
		return

	print("Taking damage: ", damage, " | Current health: ", enemy_health, " | New health: ", enemy_health - damage)
	enemy_health = enemy_health - damage

	# White flash effect
	var original_modulate = $AnimatedSprite2D.modulate
	$AnimatedSprite2D.modulate = Color(10, 10, 10, 1)  # Bright white
	await get_tree().create_timer(0.1).timeout
	$AnimatedSprite2D.modulate = original_modulate

	if enemy_health <= 0:
		die()
		return

	# Start invulnerability period
	is_invulnerable = true
	await get_tree().create_timer(invuln_duration).timeout
	is_invulnerable = false

func die() -> void:
	if is_dying:
		return
	is_dying = true
	# Play death animation
	$AnimatedSprite2D.play("death")
	# Disable movement and attacking
	is_attacking = false
	recovering = true
	velocity = Vector2.ZERO

	# Disable hurtbox so dead enemies can't be hit
	if has_node("Hurtbox"):
		$Hurtbox.set_deferred("monitoring", false)
		$Hurtbox.set_deferred("monitorable", false)

func apply_knockback(force: float, direction: Vector2) -> void:
	# Apply knockback based on resistance
	var actual_force = force / knockback_resistance
	knockback_velocity = direction * actual_force
