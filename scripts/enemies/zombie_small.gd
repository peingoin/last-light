extends CharacterBody2D

@export var speed: float = 30.0
@export var detect_range: float = 200.0
@export var attack_range: float = 30.0
@export var pause_time: float = 0.5
@export var attack_cooldown: float = pause_time
@export var damage: int = 1
@export var swing_hit_frame: int = 3
@export var swing_max_distance: float = 15.0
@export var attack_interrupt_factor: float = 1.25 # leave swing if target gets this far
@export var enemy_health: float = 10.0
@export var knockback_resistance: float = 0.8

var player: Node2D
var cooldown_timer := 0.0
var is_attacking := false
var swing_already_hit := false
var recovering := false   # <-- new: short pause after a landed hit
var knockback_velocity := Vector2.ZERO
var is_dying := false

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
			print("target is invulnerable (i-frames)")
			return

		if player.has_method("take_damage"):
			player.call("take_damage", damage)

		swing_already_hit = true

		# Exit attack and pause briefly (1s) before resuming normal logic
		await pause_for(pause_time)

func _on_anim_finished(anim_name: String) -> void:
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
	if is_dying:
		return
	enemy_health = enemy_health - damage
	print("Zombie Small health: ", enemy_health)
	if enemy_health <= 0:
		die()

func die() -> void:
	if is_dying:
		return
	print("Zombie Small died!")
	is_dying = true
	# Play death animation
	$AnimatedSprite2D.play("death")
	# Disable movement and attacking
	is_attacking = false
	recovering = true
	velocity = Vector2.ZERO

func apply_knockback(force: float, direction: Vector2) -> void:
	# Apply knockback based on resistance
	var actual_force = force / knockback_resistance
	knockback_velocity = direction * actual_force
