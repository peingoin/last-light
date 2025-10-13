extends Control

@onready var time_label = $TimeLabel

var time_controller: Node = null

func _ready():
	# Find the TimeController in the scene
	time_controller = get_node("/root/Game/TimeController")

	if time_controller:
		# Connect to time changes
		time_controller.time_changed.connect(_on_time_changed)
		# Set initial time
		_update_time_display()

func _on_time_changed(_hour: int, _minute: int):
	_update_time_display()

func _update_time_display():
	if time_controller and time_label:
		time_label.text = time_controller.get_time_string()
