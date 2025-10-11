extends Projectile
class_name Fireball

## Custom fireball projectile that explodes on impact dealing AOE damage

@export var explosion_damage: int = 50

@onready var explosion_sprite: AnimatedSprite2D = $ExplosionSprite
@onready var explosion_area: Area2D = $ExplosionArea
@onready var explosion_shape: CollisionShape2D = $ExplosionArea/ExplosionShape

var is_exploding: bool = false
var explosion_radius: float = 0.0

func _ready() -> void:
	# Disable direct damage - fireball only damages through explosion
	damage = 0

	# Get explosion radius from the collision shape
	if explosion_shape and explosion_shape.shape is CircleShape2D:
		explosion_radius = explosion_shape.shape.radius

	# Hide explosion sprite initially
	if explosion_sprite:
		explosion_sprite.visible = false
		explosion_sprite.animation_finished.connect(_on_explosion_finished)
		explosion_sprite.frame_changed.connect(_on_explosion_frame_changed)

	# Disable explosion area initially
	if explosion_area:
		explosion_area.monitoring = false
		explosion_area.monitorable = false

	super._ready()

func _on_area_entered(area: Area2D) -> void:
	# Check if it's an enemy hurtbox
	if area.name == "Hurtbox":
		var enemy = area.get_parent()
		if enemy and enemy != shooter:
			explode()

func _on_body_entered(body: Node2D) -> void:
	# Hit a wall or environment object
	explode()

func explode() -> void:
	if is_exploding:
		return

	is_exploding = true

	# Stop movement
	velocity = Vector2.ZERO

	# Hide the fireball sprite
	if animated_sprite:
		animated_sprite.visible = false

	# Disable collision to prevent multiple triggers
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	# Play explosion animation
	if explosion_sprite:
		explosion_sprite.visible = true
		explosion_sprite.play("explosion")
	else:
		# If no explosion sprite, just deal damage and despawn
		deal_explosion_damage()
		despawn()

func _on_explosion_frame_changed() -> void:
	if not explosion_sprite or not explosion_area:
		return

	var current_frame = explosion_sprite.frame

	# Enable hitbox only on frames 2 and 3
	if current_frame == 1 || 2:
		explosion_area.monitoring = true
		explosion_area.monitorable = true
		# Wait for physics to update then deal damage
		call_deferred("_deal_damage_deferred")
	elif current_frame == 3:
		# Keep monitoring on frame 3, but don't deal damage again
		pass
	else:
		explosion_area.monitoring = false
		explosion_area.monitorable = false

func _deal_damage_deferred() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	deal_explosion_damage()

func deal_explosion_damage() -> void:
	# Get all enemies and check distance manually
	var all_enemies = get_tree().get_nodes_in_group("enemies")

	for enemy in all_enemies:
		if not is_instance_valid(enemy):
			continue

		# Skip dead enemies
		if enemy.has_method("is_dying") and enemy.is_dying:
			continue
		if enemy.get("is_dying") and enemy.is_dying:
			continue

		# Calculate distance
		var distance = global_position.distance_to(enemy.global_position)

		# Check if within explosion radius
		if distance <= explosion_radius:
			# Apply damage
			if enemy.has_method("take_damage"):
				enemy.take_damage(explosion_damage)

			# Apply knockback away from explosion center
			if enemy.has_method("apply_knockback"):
				var knockback_direction = (enemy.global_position - global_position).normalized()
				enemy.apply_knockback(knockback_force, knockback_direction)

func _on_explosion_finished() -> void:
	# Disable explosion area and despawn
	if explosion_area:
		explosion_area.monitoring = false
		explosion_area.monitorable = false
	despawn()

# Override hit_enemy_target to use explosion instead
func hit_enemy_target(enemy: Node2D) -> void:
	explode()
