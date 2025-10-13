extends CanvasModulate

@export var gradient: GradientTexture1D

var time_controller: Node = null

func _ready():
	# Find the TimeController in the scene
	time_controller = get_node("/root/Game/TimeController")

	if time_controller:
		# Connect to day/night cycle changes
		time_controller.day_night_cycle_value_changed.connect(_on_day_night_value_changed)

func _on_day_night_value_changed(value: float):
	if gradient and gradient.gradient:
		self.color = gradient.gradient.sample(value)
