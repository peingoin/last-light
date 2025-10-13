extends Node

# Time constants
const DAY_DURATION = 60.0  # 1 minute = 1 day
const HOURS_PER_DAY = 24

# Time scale
var time_scale: float = 1.0

# Signals
signal time_changed(hour: int, minute: int)
signal day_night_cycle_value_changed(value: float)

func _process(delta: float) -> void:
	# Update time using PlayerData
	var time_increment = (HOURS_PER_DAY / DAY_DURATION) * delta * time_scale
	PlayerData.current_time += time_increment

	# Wrap around after 24 hours
	if PlayerData.current_time >= HOURS_PER_DAY:
		PlayerData.current_time -= HOURS_PER_DAY

	# Emit time changed signal
	var hour = int(PlayerData.current_time)
	var minute = int((PlayerData.current_time - hour) * 60)
	time_changed.emit(hour, minute)

	# Calculate day/night cycle value (0 to 1)
	# 0 = midnight (darkest), 0.5 = noon (brightest)
	var cycle_value = get_day_night_value()
	day_night_cycle_value_changed.emit(cycle_value)

func get_day_night_value() -> float:
	# Day/night cycle where:
	# - Brightest at noon (12:00) -> value = 1.0
	# - Starts getting dark at 6pm (18:00) -> value decreasing
	# - Darkest at midnight (0:00/24:00) -> value = 0.0
	# - Starts getting bright at 6am (6:00) -> value increasing

	# Shift time so midnight (0) is at the bottom of sine wave
	# and noon (12) is at the top
	var shifted_time = PlayerData.current_time - 6.0  # Offset by 6 hours
	if shifted_time < 0:
		shifted_time += HOURS_PER_DAY

	# Create sine wave with midnight at minimum and noon at maximum
	var radians = (shifted_time / HOURS_PER_DAY) * TAU
	var value = (sin(radians) + 1.0) / 2.0

	return value

func get_time_string() -> String:
	var hour = int(PlayerData.current_time)

	# Convert to 12-hour format
	var display_hour = hour
	var period = "AM"

	if hour >= 12:
		period = "PM"
		if hour > 12:
			display_hour = hour - 12
	elif hour == 0:
		display_hour = 12

	return "%d %s" % [display_hour, period]
