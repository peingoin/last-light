extends RefCounted
class_name SpawnRuleEngine

var bias_config: SpawnBiasConfig
var building_positions: Array = []

func _init(config: SpawnBiasConfig):
	bias_config = config

func evaluate_spawn_rules(x: int, y: int, terrain_context: TerrainContext) -> Dictionary:
	var spawn_decision = {
		"should_spawn": false,
		"object_type": "",
		"variant": "",
		"probability": 0.0
	}

	var object_value = terrain_context.object_noise_value
	var normalized_value = (object_value + 1.0) / 2.0  # Convert to 0-1 range

	# Building spawning (much more frequent, 30-40%)
	var building_threshold = 0.6 * bias_config.get_bias_multiplier("building")
	if normalized_value > building_threshold:
		spawn_decision.should_spawn = true
		spawn_decision.object_type = "building"
		spawn_decision.probability = normalized_value
		building_positions.append(Vector2(x * 16, y * 16))
		return spawn_decision

	# Check if near buildings for attractor effect
	var near_building = terrain_context.is_near_building(building_positions)
	var attractor_multiplier = 2.0 if near_building else 1.0
	var tree_multiplier = 1.0  # No proximity effect for trees

	# Tree spawning (same frequency as props)
	var tree_threshold = (0.45 / 1.75) / bias_config.get_bias_multiplier("tree") / tree_multiplier
	if normalized_value > tree_threshold:
		spawn_decision.should_spawn = true
		spawn_decision.object_type = "tree"
		spawn_decision.variant = terrain_context.get_tree_color_variant()
		spawn_decision.probability = normalized_value
		return spawn_decision

	# Garbage pile spawning (reduced threshold for emergency fix)
	var garbage_threshold = 0.4 / bias_config.get_bias_multiplier("garbage") / attractor_multiplier
	if normalized_value > garbage_threshold:
		spawn_decision.should_spawn = true
		spawn_decision.object_type = "garbage"
		spawn_decision.probability = normalized_value
		return spawn_decision

	# Random prop spawning (barrels, pallets, bins, benches)
	var prop_threshold = 0.45 / bias_config.get_bias_multiplier("prop") / attractor_multiplier
	if normalized_value > prop_threshold:
		spawn_decision.should_spawn = true

		var prop_types = ["barrel", "pallet", "bin", "bench"]
		spawn_decision.object_type = prop_types[randi() % prop_types.size()]
		spawn_decision.probability = normalized_value
		return spawn_decision

	return spawn_decision
