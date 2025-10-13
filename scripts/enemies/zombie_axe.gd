extends BaseEnemy

func _ready() -> void:
	# Movement and detection
	speed = 80.0
	detect_range = 200.0
	attack_range = 20.0

	# Combat
	damage = 1
	swing_hit_frame = 3
	swing_max_distance = 20.0
	attack_interrupt_factor = 1.25

	# Timing
	pause_time = 0.5
	attack_cooldown = pause_time

	# Defense
	enemy_health = 15.0
	knockback_resistance = 0.9

	super._ready()
