extends RangedWeapon

## Fire Staff - Shoots fireball projectiles that home in on enemies

func _ready() -> void:
	# All weapon properties (weapon_name, damage, attack_cooldown, projectile_spawn_offset)
	# are configured in fire_staff.tscn inspector

	# Call parent ready
	super._ready()
