extends BossAttack
class_name FlamethrowerAttack

## Attack 2: Flamethrower
## Plays flamethrower animation for 2 seconds with active hitbox
## Can be interrupted if boss takes damage

const ATTACK_DURATION: float = 2.0
const HITBOX_WIDTH: float = 60.0
const HITBOX_HEIGHT: float = 30.0
const HITBOX_OFFSET: float = 35.0  # Distance in front of boss

var hitbox: Area2D = null
var elapsed_time: float = 0.0
var animation_player: AnimatedSprite2D = null

func can_execute() -> bool:
	return true

func execute() -> void:
	if not boss:
		return

	is_active = true
	elapsed_time = 0.0

	# Get the animation player from boss
	animation_player = boss.get_node_or_null("AnimatedSprite2D")
	if animation_player:
		animation_player.play("flamethrower")

	# Create hitbox
	create_hitbox()

func update(delta: float) -> bool:
	if not is_active:
		return true

	elapsed_time += delta

	# Update hitbox position based on boss facing direction
	update_hitbox_position()

	# Check for player collision and deal damage
	check_hitbox_collision()

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

	# Create Area2D for hitbox
	hitbox = Area2D.new()
	hitbox.name = "FlamethrowerHitbox"

	# Set collision layers
	hitbox.collision_layer = 128  # Layer 7 - Enemy weapon hitbox
	hitbox.collision_mask = 1  # Layer 1 - Player

	# Create collision shape
	var shape = RectangleShape2D.new()
	shape.size = Vector2(HITBOX_WIDTH, HITBOX_HEIGHT)

	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = shape

	hitbox.add_child(collision_shape)
	boss.add_child(hitbox)

	# Position hitbox in front of boss
	update_hitbox_position()

func update_hitbox_position() -> void:
	if not hitbox or not is_instance_valid(hitbox) or not boss:
		return

	# Determine facing direction (assume boss has a facing variable or velocity)
	var facing_direction = Vector2.RIGHT

	# Check if boss has velocity to determine direction
	if boss.velocity.length() > 0:
		facing_direction = boss.velocity.normalized()
	elif player:
		# Face towards player
		facing_direction = (player.global_position - boss.global_position).normalized()

	# Position hitbox in front of boss
	hitbox.position = facing_direction * HITBOX_OFFSET

func check_hitbox_collision() -> void:
	if not hitbox or not is_instance_valid(hitbox) or not player:
		return

	# Get overlapping areas
	var overlapping_areas = hitbox.get_overlapping_areas()

	for area in overlapping_areas:
		# Check if it's the player's hurtbox
		if area.name == "Hurtbox" and area.get_parent() == player:
			# Deal damage to player (respect i-frames through player's take_damage method)
			if player.has_method("take_damage"):
				player.take_damage(2)  # Flamethrower deals 2 damage per tick
			return
