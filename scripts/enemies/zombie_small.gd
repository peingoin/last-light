extends BaseEnemy

func _ready() -> void:
	speed = 30.0
	enemy_health = 10.0
	knockback_resistance = 0.8
	swing_hit_frame = 3
	super._ready()
