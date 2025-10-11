extends RangedWeapon

## Fire Staff - Shoots fireball projectiles that home in on enemies

func _ready() -> void:
	weapon_name = "Fire Staff"
	damage = 0  # Not used for ranged weapons - projectiles have their own damage
	attack_cooldown = 0.2
	projectile_spawn_offset = 20.0

	# Call parent ready
	super._ready()
