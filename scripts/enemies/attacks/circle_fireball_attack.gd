extends BossAttack
class_name CircleFireballAttack

## Attack 1: Circle of Fireballs
## Spawns a rotating, expanding circle of fireballs around the boss

var circle_fireball_scene: PackedScene = preload("res://scenes/weapons/ranged/circle_fireball.tscn")

var fireballs: Array[Node2D] = []
var current_radius: float = 60.0
var current_angle: float = 0.0
var expansion_speed: float = 50.0
var rotation_speed: float = 2.0  # radians per second
var acceleration_factor: float = 1.05
var arena_radius: float = 500.0

func can_execute() -> bool:
	return true

func execute() -> void:
	if not boss or not player:
		return

	is_active = true

	# Determine fireball count based on phase
	var fireball_count = 14 if is_phase_2 else 10

	# Spawn fireballs in a circle
	var angle_step = TAU / fireball_count  # TAU = 2*PI = 360 degrees

	for i in range(fireball_count):
		var fireball = circle_fireball_scene.instantiate()
		var angle = angle_step * i

		# Calculate initial position
		var offset = Vector2(cos(angle), sin(angle)) * current_radius
		fireball.global_position = boss.global_position + offset

		# Store the angle for this fireball
		fireball.set_meta("circle_angle", angle)

		# Add to scene
		boss.get_parent().add_child(fireball)
		fireballs.append(fireball)

func update(delta: float) -> bool:
	if not is_active:
		return true

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
	current_radius = 60.0
	current_angle = 0.0
	expansion_speed = 50.0
	rotation_speed = 2.0
