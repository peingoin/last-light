extends Area2D
class_name Projectile

## Base class for projectiles with homing behavior.
## Handles movement, collision detection, homing logic, and lifetime management.

signal hit_enemy(enemy, damage, knockback_force, knockback_direction)

@export var damage: int = 25
@export var speed: float = 300.0
@export var knockback_force: float = 150.0
@export var lifetime_multiplier: float = 2.0  # multiply by viewport diagonal length
@export var homing_activation_distance: float = 200.0
@export var homing_max_range: float = 500.0
@export var homing_turn_rate: float = 180.0  # degrees per second

var velocity: Vector2 = Vector2.ZERO
var traveled_distance: float = 0.0
var max_lifetime_distance: float = 0.0
var is_homing: bool = false
var shooter: Node2D = null
var current_target: Node2D = null

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Calculate max lifetime distance based on viewport size
	var viewport_size = get_viewport_rect().size
	max_lifetime_distance = viewport_size.length() * lifetime_multiplier

	# Set collision layers
	collision_layer = 4   # Layer 3: Player Weapon Hitboxes
	collision_mask = 41   # Layer 1 (walls) + Layer 4 (enemy hurtboxes) + Layer 6 = 1 + 8 + 32 = 41

	# Connect collision signals
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

	# Start animation if available
	if animated_sprite and animated_sprite.sprite_frames:
		animated_sprite.play()

func initialize(start_pos: Vector2, direction: Vector2, shooter_ref: Node2D) -> void:
	global_position = start_pos
	velocity = direction.normalized() * speed
	shooter = shooter_ref
	traveled_distance = 0.0
	is_homing = false
	current_target = null

	# Rotate sprite to match direction
	rotation = velocity.angle()

func _physics_process(delta: float) -> void:
	update_movement(delta)

	# Track distance traveled
	var distance_this_frame = velocity.length() * delta
	traveled_distance += distance_this_frame

	# Check if we should start homing
	if not is_homing and traveled_distance >= homing_activation_distance:
		check_homing_activation()

	# Apply homing if active
	if is_homing and current_target:
		apply_homing(current_target, delta)

	# Move the projectile
	global_position += velocity * delta

	# Rotate to face movement direction
	rotation = velocity.angle()

	# Check lifetime
	if traveled_distance >= max_lifetime_distance:
		despawn()

func update_movement(delta: float) -> void:
	# Basic movement is handled in _physics_process
	# This method can be overridden for custom movement patterns
	pass

func check_homing_activation() -> void:
	var nearest_enemy = find_nearest_enemy()
	if nearest_enemy:
		var distance_to_enemy = global_position.distance_to(nearest_enemy.global_position)
		if distance_to_enemy <= homing_max_range:
			is_homing = true
			current_target = nearest_enemy

func find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var nearest_distance: float = INF

	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue

		# Skip dead enemies
		if enemy.has_method("is_dying") and enemy.is_dying:
			continue
		if enemy.get("is_dying") and enemy.is_dying:
			continue

		var distance = global_position.distance_to(enemy.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = enemy

	return nearest

func apply_homing(target: Node2D, delta: float) -> void:
	if not is_instance_valid(target):
		is_homing = false
		current_target = null
		return

	# Check if target is still alive
	if target.has_method("is_dying") and target.is_dying:
		is_homing = false
		current_target = null
		return
	if target.get("is_dying") and target.is_dying:
		is_homing = false
		current_target = null
		return

	# Calculate direction to target
	var direction_to_target = (target.global_position - global_position).normalized()

	# Calculate how much we can turn this frame
	var max_turn_radians = deg_to_rad(homing_turn_rate) * delta

	# Get current direction
	var current_direction = velocity.normalized()

	# Calculate angle difference
	var angle_to_target = current_direction.angle_to(direction_to_target)

	# Clamp the turn to max turn rate
	var turn_amount = clamp(angle_to_target, -max_turn_radians, max_turn_radians)

	# Rotate velocity towards target
	velocity = velocity.rotated(turn_amount)

	# Maintain speed
	velocity = velocity.normalized() * speed

func _on_area_entered(area: Area2D) -> void:
	# Check if it's an enemy hurtbox
	if area.name == "Hurtbox":
		var enemy = area.get_parent()
		if enemy and enemy != shooter:
			hit_enemy_target(enemy)

func _on_body_entered(body: Node2D) -> void:
	# Hit a wall or environment object
	despawn()

func hit_enemy_target(enemy: Node2D) -> void:
	if not enemy:
		return

	# Calculate knockback direction
	var knockback_direction = (enemy.global_position - global_position).normalized()

	# Emit signal
	hit_enemy.emit(enemy, damage, knockback_force, knockback_direction)

	# Apply damage directly
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)

	# Apply knockback
	if enemy.has_method("apply_knockback"):
		enemy.apply_knockback(knockback_force, knockback_direction)

	# Despawn projectile
	despawn()

func despawn() -> void:
	queue_free()
