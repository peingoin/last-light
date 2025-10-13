extends Projectile
class_name CircleFireball

## Fireball that moves in a circular pattern, expanding outward.
## Used for the boss's circle attack.

var circle_center: Vector2 = Vector2.ZERO
var angle: float = 0.0
var current_radius: float = 60.0
var rotation_speed: float = 0.0

# Override to disable homing and normal movement
func _ready() -> void:
	# Set damage amount for this projectile
	damage = 2
	# Don't call super._ready() to avoid default projectile behavior

	# Set collision layers for enemy projectiles
	collision_layer = 128  # Layer 8 (Enemy Projectiles)
	collision_mask = 33     # Layer 1 (Player) + Layer 6 (Walls) = 1 + 32 = 33

	# Connect signals
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

	# Start animation if available
	if animated_sprite and animated_sprite.sprite_frames:
		animated_sprite.play()

func initialize_circle(center: Vector2, start_angle: float, start_radius: float) -> void:
	circle_center = center
	angle = start_angle
	current_radius = start_radius
	update_position()

func update_circle_position(new_radius: float, new_angle: float) -> void:
	current_radius = new_radius
	angle = new_angle
	update_position()

func update_position() -> void:
	var offset = Vector2(cos(angle), sin(angle)) * current_radius
	global_position = circle_center + offset

	# Rotate sprite to face outward
	rotation = angle + PI / 2

# Override physics process to disable normal movement
func _physics_process(_delta: float) -> void:
	# Position is updated externally by the attack
	pass

func _on_area_entered(area: Area2D) -> void:
	# Check if it hit the player
	if area.get_parent() and area.get_parent().is_in_group("player"):
		var player = area.get_parent()
		if player.has_method("take_damage") and player.has_method("can_take_damage"):
			if player.can_take_damage():
				player.take_damage(damage)
		despawn()

func _on_body_entered(_body: Node2D) -> void:
	# Hit a wall or boundary
	despawn()

func despawn() -> void:
	queue_free()
