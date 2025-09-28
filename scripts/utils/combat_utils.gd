class_name CombatUtils

static func create_hitbox(shape: Shape2D, collision_layer: int, collision_mask: int) -> Area2D:
	var hitbox = Area2D.new()
	hitbox.name = "Hitbox"
	hitbox.collision_layer = collision_layer
	hitbox.collision_mask = collision_mask

	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = shape
	collision_shape.disabled = true  # Start disabled
	hitbox.add_child(collision_shape)

	return hitbox

static func create_hurtbox(collision_layer: int, collision_mask: int) -> Area2D:
	var hurtbox = Area2D.new()
	hurtbox.name = "Hurtbox"
	hurtbox.collision_layer = collision_layer
	hurtbox.collision_mask = collision_mask

	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = CircleShape2D.new()
	hurtbox.add_child(collision_shape)

	return hurtbox