extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar = $DamageBar

var health = 0 : set = _set_health

func _ready():
	# Make sure timer is configured correctly
	timer.wait_time = 0.4
	timer.one_shot = true

func init_health(_health):
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health
	
func _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	
	# Update the green health bar immediately
	value = health
	
	if health <= 0:
		queue_free()
		return
		
	if health < prev_health:
		# CRITICAL: When taking damage, make sure damage bar stays at PREVIOUS value
		# This creates the white bar effect showing damage taken
		damage_bar.value = prev_health  # Explicitly set to previous health
		timer.stop()
		timer.start()
	elif health > prev_health:
		# When healing: update damage bar immediately
		damage_bar.value = health

func _on_timer_timeout():
	damage_bar.value = health