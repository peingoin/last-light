extends BaseEnemy

func _ready() -> void:
	speed = 80.0
	enemy_health = 15.0
	knockback_resistance = 0.9
	swing_hit_frame = 3
	super._ready()
