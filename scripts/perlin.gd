extends Node2D

var map_width = 256
var map_height = 128

@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var object_container: Node2D = $ObjectContainer

# Multi-layer noise system
var base_noise: FastNoiseLite
var detail_noise: FastNoiseLite
var object_noise: FastNoiseLite

func _ready() -> void:
	setup_noise_layers(0.05, 3)
	generate_map(map_width, map_height, randi())

func setup_noise_layers(base_frequency: float, _octaves: int):
	# Base terrain noise - large scale features
	base_noise = FastNoiseLite.new()
	base_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	base_noise.frequency = base_frequency

	# Detail variation noise - medium scale texture
	detail_noise = FastNoiseLite.new()
	detail_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	detail_noise.frequency = base_frequency * 3.0

	# Object placement noise - controls object density
	object_noise = FastNoiseLite.new()
	object_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	object_noise.frequency = base_frequency * 5.0

func generate_map(width: int, height: int, noise_seed: int):
	# Set seeds for all noise layers
	base_noise.seed = noise_seed
	detail_noise.seed = noise_seed + 1000
	object_noise.seed = noise_seed + 2000

	# Clear existing content
	tilemap.clear()
	clear_objects()

	# Generate terrain layer
	generate_terrain_layer(width, height)

	# Generate object layer
	generate_object_layer(width, height)

func generate_terrain_layer(width: int, height: int):
	for x in range(width):
		for y in range(height):
			var base_value = base_noise.get_noise_2d(x, y)
			var detail_value = detail_noise.get_noise_2d(x, y)

			# Combine noise layers: 70% base, 30% detail
			var combined_value = (base_value * 0.7) + (detail_value * 0.3)

			# Classify terrain type based on combined value
			var terrain_type = classify_terrain(combined_value)
			place_terrain_tile(x, y, terrain_type)

func classify_terrain(noise_value: float) -> int:
	if noise_value < -0.15:
		return 2  # Bleak-Yellow (harsh wasteland)
	else:
		return 1

func place_terrain_tile(x: int, y: int, tile_type: int):
	# Use the appropriate tileset source based on terrain type
	tilemap.set_cell(Vector2i(x, y), tile_type, Vector2i(5, 0))

func generate_object_layer(width: int, height: int):
	# Sample object placement every 4 tiles for performance
	for x in range(0, width, 4):
		for y in range(0, height, 4):
			var object_value = object_noise.get_noise_2d(x, y)
			object_value = (object_value + 1) / 2  # Normalize to 0-1

			# Place object if noise value exceeds threshold
			if object_value > 0.5:
				place_random_object(x, y)

func place_random_object(x: int, y: int):
	# Create simple colored rectangle as placeholder object
	var object_sprite = ColorRect.new()
	object_sprite.size = Vector2(8, 8)
	object_sprite.position = Vector2(x * 16, y * 16)  # Assuming 16x16 tile size

	# Random color based on position for variety
	var color_seed = (x * 1000 + y) % 3
	if color_seed == 0:
		object_sprite.color = Color.BROWN  # Debris/garbage
	elif color_seed == 1:
		object_sprite.color = Color.DARK_GREEN  # Trees/vegetation
	else:
		object_sprite.color = Color.GRAY  # Metal/scrap

	object_container.add_child(object_sprite)

func clear_objects():
	for child in object_container.get_children():
		child.queue_free()

func _on_button_pressed():
	generate_map(map_width, map_height, randi())
