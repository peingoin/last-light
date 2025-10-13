extends BossAttack
class_name ShootFireballAttack

## Attack 3: Shoot Fireballs
## Shoots 3 bursts of 3 fireballs (center, -20°, +20°)
## 0.5s delay between bursts

var boss_fireball_scene: PackedScene = preload("res://scenes/weapons/ranged/boss_fireball.tscn")

const BURST_COUNT: int = 3
const FIREBALLS_PER_BURST: int = 3
const BURST_DELAY: float = 0.5
const SPREAD_ANGLE: float = 20.0  # degrees

var current_burst: int = 0
var burst_timer: float = 0.0
var animation_player: AnimatedSprite2D = null

func can_execute() -> bool:
	return true

func execute() -> void:
	if not boss or not player:
		return

	is_active = true
	current_burst = 0
	burst_timer = 0.0

	# Get the animation player from boss
	animation_player = boss.get_node_or_null("AnimatedSprite2D")

	# Shoot first burst immediately
	shoot_burst()

func update(delta: float) -> bool:
	if not is_active:
		return true

	burst_timer += delta

	# Check if it's time for the next burst
	if burst_timer >= BURST_DELAY and current_burst < BURST_COUNT:
		shoot_burst()
		burst_timer = 0.0

	# Check if all bursts are complete
	if current_burst >= BURST_COUNT and burst_timer >= BURST_DELAY:
		cleanup()
		return true  # Attack finished

	return false  # Attack still running

func interrupt() -> void:
	cleanup()

func cleanup() -> void:
	is_active = false

	# Reset animation to idle if still valid
	if animation_player and is_instance_valid(animation_player):
		animation_player.play("idle")

func shoot_burst() -> void:
	if not boss or not player:
		return

	current_burst += 1

	# Play shoot animation
	if animation_player and is_instance_valid(animation_player):
		animation_player.play("shoot")

	# Calculate base direction to player
	var base_direction = (player.global_position - boss.global_position).normalized()

	# Spawn 3 fireballs with angular spread
	var angles = [
		0.0,  # Center
		-SPREAD_ANGLE,  # Left
		SPREAD_ANGLE   # Right
	]

	for angle_offset in angles:
		spawn_fireball(base_direction, angle_offset)

func spawn_fireball(base_direction: Vector2, angle_offset_degrees: float) -> void:
	if not boss:
		return

	# Create fireball
	var fireball = boss_fireball_scene.instantiate()

	# Calculate rotated direction
	var angle_radians = deg_to_rad(angle_offset_degrees)
	var direction = base_direction.rotated(angle_radians)

	# Increase speed by 20% in phase 2
	var projectile_speed = 200.0
	if is_phase_2:
		projectile_speed *= 1.2

	# Set the speed before initializing
	fireball.speed = projectile_speed

	# Add to scene first (required for some Godot nodes)
	boss.get_parent().add_child(fireball)

	# Initialize fireball
	fireball.initialize(
		boss.global_position,
		direction,
		boss  # shooter reference
	)
