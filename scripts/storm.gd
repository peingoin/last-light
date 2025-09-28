extends Node2D

@export var storm_radius: float = 1000.0
@export var storm_color: Color = Color(0.6, 0.2, 0.8, 0.3)  # Purple with transparency
@export var storm_border_width: float = 50.0
@export var storm_damage: int = 1000  # Instant kill damage

var player: CharacterBody2D = null
var player_in_storm: bool = false

func _ready() -> void:
	# Find the player
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	if not player:
		# Fallback: search for player node
		player = get_node_or_null("../Player")

	if player and not player.is_in_group("player"):
		player.add_to_group("player")

func _process(delta: float) -> void:
	if player:
		check_player_storm_collision()

func _draw() -> void:
	# Only draw visual effects beyond the storm radius
	# This ensures the safe zone remains completely clear

	# Get camera for screen-relative positioning
	var camera = get_viewport().get_camera_2d()
	var viewport_size = get_viewport_rect().size

	# Calculate how far we need to draw from the storm edge
	var max_draw_distance = 2000.0  # Draw storm effect this far beyond the edge

	# Draw gradient rings starting from the storm radius edge
	var ring_thickness = 10.0
	var num_rings = int(max_draw_distance / ring_thickness)

	for i in range(num_rings):
		var ring_radius = storm_radius + (i * ring_thickness)
		var distance_from_edge = i * ring_thickness

		# Fade the storm effect as we get further from the edge
		var fade_factor = 1.0 - min(distance_from_edge / max_draw_distance, 0.8)
		var ring_alpha = storm_color.a * fade_factor
		var ring_color = Color(storm_color.r, storm_color.g, storm_color.b, ring_alpha)

		# Draw thick ring outline to create filled appearance
		draw_circle(Vector2.ZERO, ring_radius, ring_color, false, ring_thickness)

	# Draw the border gradient for a smoother transition at the storm edge
	for i in range(int(storm_border_width)):
		var border_radius = storm_radius + i
		var progress = float(i) / storm_border_width
		var alpha = storm_color.a * (1.2 - progress * 0.4)  # Slightly more intense at the edge
		var border_color = Color(storm_color.r, storm_color.g, storm_color.b, alpha)
		draw_circle(Vector2.ZERO, border_radius, border_color, false, 3.0)

func check_player_storm_collision() -> void:
	var distance_to_center = player.global_position.distance_to(global_position)
	var currently_in_storm = distance_to_center > storm_radius

	if currently_in_storm and not player_in_storm:
		# Player just entered storm
		player_in_storm = true
		print("Player entered storm - instant death!")
		if player.has_method("take_damage"):
			player.take_damage(storm_damage)
	elif not currently_in_storm:
		# Player is in safe zone
		player_in_storm = false

func is_in_storm(position: Vector2) -> bool:
	return position.distance_to(global_position) > storm_radius

func get_distance_to_storm(position: Vector2) -> float:
	var distance_to_center = position.distance_to(global_position)
	return max(0.0, distance_to_center - storm_radius)
