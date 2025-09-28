extends Resource
class_name SpawnBiasConfig

@export var building_bias: float = 1.0
@export var tree_bias: float = 1.0
@export var garbage_bias: float = 1.0
@export var barrel_bias: float = 1.0
@export var prop_bias: float = 1.0

func get_bias_multiplier(object_type: String) -> float:
	match object_type:
		"building":
			return building_bias
		"tree":
			return tree_bias
		"garbage":
			return garbage_bias
		"barrel":
			return barrel_bias
		"prop":
			return prop_bias
		_:
			return 1.0
