extends StaticBody2D

## Arena boundary for boss fights.
## Creates a circular wall that blocks all movement and projectiles.

@export var radius: float = 500.0
@export var line_color: Color = Color(1.0, 0.3, 0.1, 0.6)  # Orange-red
@export var line_width: float = 4.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: Line2D = $Visual

func _ready() -> void:
	# Set up collision shape
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = radius
	collision_shape.shape = circle_shape

	# Set collision layers - acts as a wall
	collision_layer = 32  # Layer 6 (Walls/Environment)
	collision_mask = 0

	# Create visual ring
	setup_visual()

func setup_visual() -> void:
	if not visual:
		return

	visual.width = line_width
	visual.default_color = line_color
	visual.closed = true

	# Generate circle points
	var num_points = 64
	visual.clear_points()

	for i in range(num_points + 1):
		var angle = (float(i) / num_points) * TAU
		var point = Vector2(cos(angle), sin(angle)) * radius
		visual.add_point(point)
