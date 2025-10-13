extends Fireball
class_name BossFireball

## Fireball projectile used by the Fire Wizard boss.
## Shoots straight without homing and damages the player.

func _ready() -> void:
	# Disable homing behavior by setting activation distance very high
	homing_activation_distance = 999999.0

	# Set collision layers for enemy projectile
	collision_layer = 128  # Layer 7 - Enemy Projectiles
	collision_mask = 1 + 32  # Layer 1 (Player) + Layer 6 (Walls)

	# Set damage
	explosion_damage = 2

	super._ready()

func deal_explosion_damage() -> void:
	# Check if player is in explosion radius
	var player = get_tree().get_first_node_in_group("player")

	if not is_instance_valid(player):
		return

	# Calculate distance
	var distance = global_position.distance_to(player.global_position)

	# Check if within explosion radius
	if distance <= explosion_radius:
		# Apply damage to player
		if player.has_method("take_damage"):
			player.take_damage(explosion_damage)

		# Apply knockback away from explosion center
		if player.has_method("apply_knockback"):
			var knockback_direction = (player.global_position - global_position).normalized()
			player.apply_knockback(knockback_force, knockback_direction)
