extends BossAttack
class_name FlamethrowerAttack

## Attack 2: Flamethrower
## Plays flamethrower animation for 2 seconds with active hitbox
## Can be interrupted if boss takes damage

const ATTACK_DURATION: float = 2.0
const DAMAGE_TICK_RATE: float = 0.3  # Damage every 0.3 seconds

var hitbox: Area2D = null
var hitbox_shape: CollisionShape2D = null
var elapsed_time: float = 0.0
var animation_player: AnimatedSprite2D = null
var damage_timer: float = 0.0
var has_damaged_this_tick: bool = false

func can_execute() -> bool:
	return true

func execute() -> void:
	print("ATTACK 2: Flamethrower - EXECUTING")

	if not boss:
		print("  ERROR: Boss is null!")
		return

	is_active = true
	elapsed_time = 0.0
	damage_timer = 0.0
	has_damaged_this_tick = false

	# Get the animation player from boss
	animation_player = boss.get_node_or_null("AnimatedSprite2D")
	if animation_player:
		animation_player.play("flamethrower")
		print("  Playing flamethrower animation")

	# Create hitbox
	create_hitbox()

func update(delta: float) -> bool:
	if not is_active:
		return true

	elapsed_time += delta
	damage_timer += delta

	# Update hitbox position based on boss facing direction
	update_hitbox_position()

	# Check for player collision and deal damage periodically
	if damage_timer >= DAMAGE_TICK_RATE:
		check_hitbox_collision()
		damage_timer = 0.0

	# Check if attack duration is complete
	if elapsed_time >= ATTACK_DURATION:
		cleanup()
		return true  # Attack finished

	return false  # Attack still running

func interrupt() -> void:
	# Stop animation
	if animation_player and is_instance_valid(animation_player):
		animation_player.play("idle")

	cleanup()

func cleanup() -> void:
	is_active = false

	# Remove hitbox
	if hitbox and is_instance_valid(hitbox):
		hitbox.queue_free()
		hitbox = null

	# Reset animation to idle if still valid
	if animation_player and is_instance_valid(animation_player):
		animation_player.play("idle")

func create_hitbox() -> void:
	if not boss:
		return

	# Try to find existing FlamethrowerHitbox in the boss scene
	hitbox = boss.get_node_or_null("FlamethrowerHitbox")

	if not hitbox:
		# Create Area2D for hitbox if it doesn't exist
		hitbox = Area2D.new()
		hitbox.name = "FlamethrowerHitbox"

		# Set collision layers
		hitbox.collision_layer = 0  # Don't need layer, just detecting
		hitbox.collision_mask = 1  # Layer 1 - Player only

		# Create collision shape with default rectangle
		var shape = RectangleShape2D.new()
		shape.size = Vector2(80, 40)

		var collision_shape = CollisionShape2D.new()
		collision_shape.name = "CollisionShape2D"
		collision_shape.shape = shape
		collision_shape.position = Vector2(40, 0)  # Offset in front of boss

		hitbox.add_child(collision_shape)
		boss.add_child(hitbox)

		print("  Created new FlamethrowerHitbox")
	else:
		# Use existing hitbox from scene
		print("  Using existing FlamethrowerHitbox from scene")
		# Make sure it's enabled
		hitbox.monitoring = true
		hitbox.monitorable = true

	# Get reference to collision shape for positioning
	hitbox_shape = hitbox.get_node_or_null("CollisionShape2D")

	# Position hitbox in front of boss
	update_hitbox_position()

func update_hitbox_position() -> void:
	if not hitbox or not is_instance_valid(hitbox) or not boss:
		return

	# Determine facing direction
	var facing_direction = Vector2.RIGHT

	# Check if boss has velocity to determine direction
	if boss.velocity.length() > 0:
		facing_direction = boss.velocity.normalized()
	elif player:
		# Face towards player
		facing_direction = (player.global_position - boss.global_position).normalized()

	# Calculate rotation angle from facing direction
	var angle = facing_direction.angle()
	hitbox.rotation = angle

	# Keep hitbox at boss position (offset is handled by CollisionShape2D position)
	hitbox.global_position = boss.global_position

func check_hitbox_collision() -> void:
	if not hitbox or not is_instance_valid(hitbox) or not player:
		return

	# Check for overlapping bodies (player CharacterBody2D)
	var overlapping_bodies = hitbox.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body == player or body.is_in_group("player"):
			print("  Flamethrower hitting player!")
			if player.has_method("take_damage"):
				player.take_damage(2)  # Flamethrower deals 2 damage per tick
			return

	# Also check overlapping areas (player's hurtbox)
	var overlapping_areas = hitbox.get_overlapping_areas()
	for area in overlapping_areas:
		# Check if it's the player's hurtbox
		if area.name == "Hurtbox" and area.get_parent() == player:
			print("  Flamethrower hitting player hurtbox!")
			if player.has_method("take_damage"):
				player.take_damage(2)  # Flamethrower deals 2 damage per tick
			return
