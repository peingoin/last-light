extends BaseEnemy

func _ready() -> void:
	speed = 50.0
	enemy_health = 20.0
	knockback_resistance = 1.0
	swing_hit_frame = 3
	super._ready()
