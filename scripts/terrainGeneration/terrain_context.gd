extends RefCounted
class_name TerrainContext

var position: Vector2
var base_noise_value: float
var detail_noise_value: float
var object_noise_value: float
var combined_terrain_value: float

func _init(pos: Vector2, noise_values: Dictionary):
	position = pos
	base_noise_value = noise_values.get("base", 0.0)
	detail_noise_value = noise_values.get("detail", 0.0)
	object_noise_value = noise_values.get("object", 0.0)
	combined_terrain_value = noise_values.get("combined", 0.0)

func get_biome_type() -> String:
	if combined_terrain_value < -0.15:
		return "bleak_yellow"
	else:
		return "green"

func get_tree_color_variant() -> String:
	var biome = get_biome_type()

	if biome == "bleak_yellow":
		if detail_noise_value > 0.3:
			return "Bleak-Yellow"
		elif detail_noise_value > 0.0:
			return "Yellow"
		else:
			return "Orange"
	else:
		if detail_noise_value > 0.3:
			return "Green"
		elif detail_noise_value > 0.0:
			return "Dark-Green"
		else:
			return "Red"

func is_near_building(buildings: Array) -> bool:
	for building in buildings:
		if position.distance_to(building) < 64.0:  # Within 4 tiles
			return true
	return false
