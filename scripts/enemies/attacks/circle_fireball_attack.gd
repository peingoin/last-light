extends BossAttack
class_name CircleFireballAttack

## Attack 1: Circle of Fireballs
## Spawns a rotating, expanding circle of fireballs around the boss

var circle_fireball_scene: PackedScene = preload("res://scenes/weapons/ranged/circle_fireball.tscn")

var fireballs: Array[Node2D] = []
var current_radius: float = 25.0  # Start very close to boss
var current_angle: float = 0.0
var expansion_speed: float = 0.5  # 5% of original (10.0 * 0.05)
var rotation_speed: float = 0.025  # 5% of original (0.5 * 0.05)
var acceleration_factor: float = 1.01  # Very slow exponential growth
var arena_radius: float = 500.0
var stationary_timer: float = 0.0
var stationary_duration: float = 1.5  # Stay still for 1.5 seconds
var is_stationary: bool = true

func can_execute() -> bool:
	return true

func execute() -> void:
	print("ATTACK 1: Circle of Fireballs - EXECUTING")

	if not boss or not player:
		print("  ERROR: Boss or player is null!")
		return

	is_active = true
	is_stationary = true
	stationary_timer = 0.0

	# Determine fireball count based on phase
	var fireball_count = 14 if is_phase_2 else 10
	print("  Spawning ", fireball_count, " fireballs at radius ", current_radius)

	# Spawn fireballs in a circle
	var angle_step = TAU / fireball_count  # TAU = 2*PI = 360 degrees

	for i in range(fireball_count):
		var fireball = circle_fireball_scene.instantiate()
		var angle = angle_step * i

		# Calculate initial position (start at 25 pixels from boss)
		var offset = Vector2(cos(angle), sin(angle)) * current_radius
		fireball.global_position = boss.global_position + offset

		# Store the angle for this fireball
		fireball.set_meta("circle_angle", angle)

		# Add to scene
		boss.get_parent().add_child(fireball)
		fireballs.append(fireball)

	print("  Spawned ", fireballs.size(), " fireballs successfully")

func update(delta: float) -> bool:
	if not is_active:
		return true

	# Handle stationary phase
	if is_stationary:
		stationary_timer += delta
		if stationary_timer >= stationary_duration:
			is_stationary = false
		else:
			# Keep fireballs at initial position during stationary phase
			for fireball in fireballs:
				if not is_instance_valid(fireball):
					continue
				var base_angle = fireball.get_meta("circle_angle")
				var offset = Vector2(cos(base_angle), sin(base_angle)) * current_radius
				fireball.global_position = boss.global_position + offset
			return false  # Still in stationary phase

	# After stationary phase, start moving
	# Update expansion and rotation speeds (exponential growth)
	expansion_speed *= acceleration_factor
	rotation_speed *= acceleration_factor

	# Update radius and rotation angle
	current_radius += expansion_speed * delta
	current_angle += rotation_speed * delta

	# Update all fireball positions
	for fireball in fireballs:
		if not is_instance_valid(fireball):
			continue

		# Get this fireball's angle in the circle
		var base_angle = fireball.get_meta("circle_angle")
		var total_angle = base_angle + current_angle

		# Calculate new position
		var offset = Vector2(cos(total_angle), sin(total_angle)) * current_radius
		fireball.global_position = boss.global_position + offset

	# Check if any fireballs have reached the arena boundary
	if current_radius >= arena_radius:
		cleanup()
		return true  # Attack finished

	return false  # Attack still running

func interrupt() -> void:
	cleanup()

func cleanup() -> void:
	is_active = false

	# Despawn all fireballs
	for fireball in fireballs:
		if is_instance_valid(fireball):
			fireball.queue_free()

	fireballs.clear()

	# Reset values for next use
	current_radius = 25.0
	current_angle = 0.0
	expansion_speed = 0.5
	rotation_speed = 0.025
	is_stationary = true
	stationary_timer = 0.0
