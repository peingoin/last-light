extends Node2D

var map_width = 500
var map_height = 500

@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var object_container: Node2D = $ObjectContainer
@onready var object_layer: Node2D = get_node("../ObjectLayer")

# Multi-layer noise system
var base_noise: FastNoiseLite
var detail_noise: FastNoiseLite
var object_noise: FastNoiseLite
var density_noise: FastNoiseLite

# Enhanced spawning system
var spawn_bias_config: SpawnBiasConfig
var spawn_rule_engine: SpawnRuleEngine
var object_factory: ObjectFactory
var occupancy_grid: Dictionary = {}

# Object exclusion radii configuration
var exclusion_radii = {
	"building": 4,    # 10x10 area (reduced)
	"garbage": 2,     # 5x5 area
	"tree": 1,        # 3x3 area
	"barrel": 1,      # 3x3 area
	"bin": 2,         # 5x5 area
	"bench": 1,       # 3x3 area
	"pallet": 1       # 3x3 area
}

func _ready() -> void:
	setup_enhanced_spawning_system()
	setup_noise_layers(0.05, 3)
	print("ObjectLayer reference: ", object_layer)
	print("ObjectLayer node type: ", object_layer.get_class() if object_layer else "null")
	print("FIXED: Player is now INSIDE ObjectLayer YSort container")
	print("YSort should now work for player and objects together!")
	generate_map(map_width, map_height, randi())

func setup_enhanced_spawning_system():
	spawn_bias_config = SpawnBiasConfig.new()
	spawn_rule_engine = SpawnRuleEngine.new(spawn_bias_config)
	object_factory = ObjectFactory.new(spawn_bias_config)

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

	# Density control noise - limits overall spawn density (1 per 5 tiles max)
	density_noise = FastNoiseLite.new()
	density_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	density_noise.frequency = base_frequency * 2.0

func generate_map(width: int, height: int, noise_seed: int):
	# Set seeds for all noise layers
	base_noise.seed = noise_seed
	detail_noise.seed = noise_seed + 1000
	object_noise.seed = noise_seed + 2000
	density_noise.seed = noise_seed + 3000

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

	# Random tile 3,2 spawning after perlin generation
	spawn_random_tile32(width, height)

func spawn_random_tile32(width: int, height: int):
	var spawn_chance = 5  # 5% probability per tile
	for x in range(width):
		for y in range(height):
			if randi() % 100 < spawn_chance:
				# Check if current tile is from source 2 (yellow/bleak terrain)
				var current_tile_data = tilemap.get_cell_source_id(Vector2i(x, y))
				if current_tile_data != 2:  # Only spawn if NOT on bleak yellow ground
					place_terrain_tile(x, y, 3)  # Override with tile 3,2

func classify_terrain(noise_value: float) -> int:
	if noise_value < -0.15:
		return 2  # Bleak-Yellow (harsh wasteland)
	else:
		return 1

func place_terrain_tile(x: int, y: int, tile_type: int):
	# Use the appropriate tileset source based on terrain type
	if tile_type == 3:
		tilemap.set_cell(Vector2i(x, y), 1, Vector2i(3, 2))  # Tile 3,2 from source 1 (Dark-Green)
	else:
		tilemap.set_cell(Vector2i(x, y), tile_type, Vector2i(5, 0))

func generate_object_layer(width: int, height: int):
	occupancy_grid.clear()

	# Pass 1: Buildings (pure noise-driven)
	var building_positions = generate_buildings_pass(width, height)

	# Pass 2: Objects with building proximity boost
	generate_objects_pass(width, height, building_positions)

func generate_buildings_pass(width: int, height: int) -> Array:
	var building_positions = []

	for x in range(width):
		for y in range(height):
			var object_value = object_noise.get_noise_2d(x, y)
			var normalized_value = (object_value + 1.0) / 2.0

			# PRD threshold: Buildings 0.95+ (very rare, < 5%)
			if normalized_value >= 0.75:
				if not is_position_occupied(x, y) and is_building_distance_valid(x, y, building_positions):
					var terrain_context = create_terrain_context(x, y)
					var spawn_decision = {
						"should_spawn": true,
						"object_type": "building",
						"variant": "",
						"probability": normalized_value
					}
					place_enhanced_object(x, y, spawn_decision, terrain_context)
					building_positions.append(Vector2(x, y))
					var radius = exclusion_radii.get("building", 4)
					mark_position_occupied_with_radius(x, y, radius)

	return building_positions

func is_building_distance_valid(x: int, y: int, existing_buildings: Array) -> bool:
	# Check if proposed building is at least 20 tiles away from any existing building
	var min_distance = 20
	for building_pos in existing_buildings:
		var distance = Vector2(x, y).distance_to(building_pos)
		if distance < min_distance:
			return false
	return true

func is_building_distance_valid_world_coords(x: int, y: int, existing_buildings: Array) -> bool:
	# Check if proposed building is at least 20 tiles away from any existing building
	# This version works with existing_buildings stored in world coordinates (pixels)
	var min_distance = 20 * 16  # Convert tiles to pixels (20 tiles * 16 pixels per tile)
	var pos_world = Vector2(x * 16, y * 16)  # Convert tile position to world position
	for building_pos in existing_buildings:
		var distance = pos_world.distance_to(building_pos)
		if distance < min_distance:
			return false
	return true

func mark_building_footprint(x: int, y: int):
	# Mark 9x9 area around building as occupied (building footprint)
	var footprint_size = 4  # 9x9 area (4 tiles radius)
	for dx in range(-footprint_size, footprint_size + 1):
		for dy in range(-footprint_size, footprint_size + 1):
			var check_x = x + dx
			var check_y = y + dy
			if check_x >= 0 and check_y >= 0:
				mark_position_occupied(check_x, check_y)

func generate_objects_pass(width: int, height: int, building_positions: Array):
	for x in range(width):
		for y in range(height):
			if not is_position_occupied(x, y):
				# Density control: Only allow spawning ~1 per 100 tiles (1% max)
				var density_value = density_noise.get_noise_2d(x, y)
				var density_normalized = (density_value + 1.0) / 2.0
				if density_normalized < 0.01:  # Only 1% of tiles eligible for spawning
					continue

				var object_value = object_noise.get_noise_2d(x, y)
				var proximity_boost = calculate_proximity_boost(x, y, building_positions)
				var enhanced_value = (object_value + proximity_boost + 1.0) / 2.0

				# Apply PRD thresholds in priority order: trees > garbage > pallets > benches
				if enhanced_value >= 0.9:
					# Benches (least common)
					select_contextual_object(x, y, building_positions, enhanced_value, "bench")
				elif enhanced_value >= 0.85:
					# Pallets (second least common)
					select_contextual_object(x, y, building_positions, enhanced_value, "pallet")
				elif enhanced_value >= 0.75:
					# Garbage bins (second most common)
					select_contextual_object(x, y, building_positions, enhanced_value, "garbage")
				elif enhanced_value >= 0.65:
					# Trees (most common) - use base value without proximity boost
					var tree_base_value = (object_value + 1.0) / 2.0
					if tree_base_value >= (0.65 / 1.75):
						select_contextual_object(x, y, building_positions, tree_base_value, "tree")

func calculate_proximity_boost(x: int, y: int, buildings: Array) -> float:
	var max_boost = 0.3  # Significant but not overwhelming
	var max_range = 32   # tiles (PRD: "many props spawn near them")

	var closest_distance = INF
	for building_pos in buildings:
		var distance = Vector2(x, y).distance_to(building_pos)
		closest_distance = min(closest_distance, distance)

	if closest_distance <= max_range:
		return max_boost * (1.0 - closest_distance / max_range)
	return 0.0

func select_contextual_object(x: int, y: int, buildings: Array, noise_value: float, object_category: String):
	var distance_to_building = INF
	for building_pos in buildings:
		distance_to_building = min(distance_to_building, Vector2(x, y).distance_to(building_pos))

	var terrain_context = create_terrain_context(x, y)
	var spawn_decision = {
		"should_spawn": true,
		"object_type": "",
		"variant": "",
		"probability": noise_value
	}

	if object_category == "garbage":
		spawn_decision.object_type = "bin"
	elif object_category == "tree":
		spawn_decision.object_type = "tree"
		spawn_decision.variant = terrain_context.get_tree_color_variant()
	elif object_category == "pallet":
		spawn_decision.object_type = "pallet"
	elif object_category == "bench":
		spawn_decision.object_type = "bench"
	elif object_category == "prop":
		# Legacy prop category - distribute based on building proximity
		if distance_to_building <= 16:
			# Urban objects near buildings
			var urban_objects = ["bin", "barrel", "bench"]
			spawn_decision.object_type = urban_objects[randi() % urban_objects.size()]
		else:
			# Rural objects away from buildings
			var rural_objects = ["tree", "pallet", "barrel"]
			spawn_decision.object_type = rural_objects[randi() % rural_objects.size()]
			if spawn_decision.object_type == "tree":
				spawn_decision.variant = terrain_context.get_tree_color_variant()

	place_enhanced_object(x, y, spawn_decision, terrain_context)

func generate_object_layer_multipass(width: int, height: int):
	occupancy_grid.clear()
	spawn_rule_engine.building_positions.clear()

	# Collect all sample positions
	var sample_positions = []
	for x in range(0, width, 50):
		for y in range(0, height, 50):
			sample_positions.append(Vector2i(x, y))

	# Pass 1: Buildings (claim large exclusion zones)
	spawn_pass_buildings(sample_positions)

	# Pass 2: Trees (avoid buildings)
	spawn_pass_trees(sample_positions)

	# Pass 3: Props (fill remaining spaces)
	spawn_pass_props(sample_positions)

func create_terrain_context(x: int, y: int) -> TerrainContext:
	var base_value = base_noise.get_noise_2d(x, y)
	var detail_value = detail_noise.get_noise_2d(x, y)
	var object_value = object_noise.get_noise_2d(x, y)
	var combined_value = (base_value * 0.7) + (detail_value * 0.3)

	var noise_values = {
		"base": base_value,
		"detail": detail_value,
		"object": object_value,
		"combined": combined_value
	}

	return TerrainContext.new(Vector2(x, y), noise_values)

func place_enhanced_object(x: int, y: int, spawn_decision: Dictionary, terrain_context: TerrainContext):
	var object_instance = object_factory.create_object(
		spawn_decision.object_type,
		Vector2(x * 16, y * 16),
		terrain_context,
		spawn_decision.variant
	)

	object_layer.add_child(object_instance)
	print("Added ", spawn_decision.object_type, " to ObjectLayer at Y position: ", object_instance.position.y)
	print("ObjectLayer children count: ", object_layer.get_child_count())
	var radius = exclusion_radii.get(spawn_decision.object_type, 1)
	mark_position_occupied_with_radius(x, y, radius)

func spawn_pass_buildings(positions: Array):
	for pos in positions:
		if not is_position_occupied(pos.x, pos.y) and is_building_distance_valid_world_coords(pos.x, pos.y, spawn_rule_engine.building_positions):
			var terrain_context = create_terrain_context(pos.x, pos.y)
			var object_value = terrain_context.object_noise_value
			var normalized_value = (object_value + 1.0) / 2.0

			var building_threshold = 0.6 * spawn_bias_config.get_bias_multiplier("building")
			if normalized_value > building_threshold:
				var spawn_decision = {
					"should_spawn": true,
					"object_type": "building",
					"variant": "",
					"probability": normalized_value
				}
				place_enhanced_object(pos.x, pos.y, spawn_decision, terrain_context)
				spawn_rule_engine.building_positions.append(Vector2(pos.x * 16, pos.y * 16))
				mark_exclusion_zone(pos.x, pos.y, 64)  # Large exclusion zone for buildings

func spawn_pass_trees(positions: Array):
	for pos in positions:
		if not is_position_occupied(pos.x, pos.y):
			var terrain_context = create_terrain_context(pos.x, pos.y)
			var object_value = terrain_context.object_noise_value
			var normalized_value = (object_value + 1.0) / 2.0

			var near_building = terrain_context.is_near_building(spawn_rule_engine.building_positions)
			var tree_multiplier = 1.0  # No proximity effect for trees

			var tree_threshold = (0.45 / 1.75) / spawn_bias_config.get_bias_multiplier("tree") / tree_multiplier
			if normalized_value > tree_threshold:
				var spawn_decision = {
					"should_spawn": true,
					"object_type": "tree",
					"variant": terrain_context.get_tree_color_variant(),
					"probability": normalized_value
				}
				place_enhanced_object(pos.x, pos.y, spawn_decision, terrain_context)
				mark_exclusion_zone(pos.x, pos.y, 16)  # Small exclusion zone for trees

func spawn_pass_props(positions: Array):
	for pos in positions:
		if not is_position_occupied(pos.x, pos.y):
			var terrain_context = create_terrain_context(pos.x, pos.y)
			var object_value = terrain_context.object_noise_value
			var normalized_value = (object_value + 1.0) / 2.0

			var near_building = terrain_context.is_near_building(spawn_rule_engine.building_positions)
			var attractor_multiplier = 2.0 if near_building else 1.0

			# Garbage piles
			var garbage_threshold = 0.4 / spawn_bias_config.get_bias_multiplier("garbage") / attractor_multiplier
			if normalized_value > garbage_threshold:
				var spawn_decision = {
					"should_spawn": true,
					"object_type": "garbage",
					"variant": "",
					"probability": normalized_value
				}
				place_enhanced_object(pos.x, pos.y, spawn_decision, terrain_context)
				continue

			# Random props (barrels, pallets, bins, benches)
			var prop_threshold = 0.45 / spawn_bias_config.get_bias_multiplier("prop") / attractor_multiplier
			if normalized_value > prop_threshold:
				var prop_types = ["barrel", "pallet", "bin", "bench"]
				var spawn_decision = {
					"should_spawn": true,
					"object_type": prop_types[randi() % prop_types.size()],
					"variant": "",
					"probability": normalized_value
				}
				place_enhanced_object(pos.x, pos.y, spawn_decision, terrain_context)

func mark_exclusion_zone(x: int, y: int, radius: int):
	var tile_radius = radius / 16  # Convert to tile unitsddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
	for dx in range(-tile_radius, tile_radius + 1, 1):
		for dy in range(-tile_radius, tile_radius + 1, 1):
			var check_x = x + dx
			var check_y = y + dy
			if check_x >= 0 and check_y >= 0:
				mark_position_occupied(check_x, check_y)

func is_position_occupied(x: int, y: int) -> bool:
	var key = str(x) + "," + str(y)
	return occupancy_grid.has(key)

func mark_position_occupied(x: int, y: int):
	var key = str(x) + "," + str(y)
	occupancy_grid[key] = true

func mark_position_occupied_with_radius(x: int, y: int, radius: int):
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			var check_x = x + dx
			var check_y = y + dy
			if check_x >= 0 and check_y >= 0:
				mark_position_occupied(check_x, check_y)

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

	object_layer.add_child(object_sprite)
	print("Added random object to ObjectLayer at Y position: ", object_sprite.position.y)

func clear_objects():
	for child in object_container.get_children():
		child.queue_free()

func _on_button_pressed():
	generate_map(map_width, map_height, randi())
