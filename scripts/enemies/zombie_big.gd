extends BaseEnemy

func _ready() -> void:
	# Movement and detection
	speed = 80.0
	detect_range = 200.0
	attack_range = 30.0

	# Combat
	damage = 1
	swing_hit_frame = 5
	swing_max_distance = 15.0 * 1.5
	attack_interrupt_factor = 1.25

	# Timing
	pause_time = 0.5
	attack_cooldown = pause_time

	# Defense
	enemy_health = 25.0
	knockback_resistance = 1.5

	super._ready()
