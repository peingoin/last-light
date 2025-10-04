extends BaseEnemy

func _ready() -> void:
	speed = 80.0
	enemy_health = 25.0
	knockback_resistance = 1.5
	swing_hit_frame = 5
	swing_max_distance = 15.0 * 1.5
	super._ready()
