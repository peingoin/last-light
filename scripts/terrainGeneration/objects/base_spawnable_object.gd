extends Node2D
class_name BaseSpawnableObject

@export var object_type: String = ""
@export var spawn_probability: float = 0.1
@export var visual_variant: String = ""

var spawn_position: Vector2
var terrain_context: TerrainContext

# Interaction system
signal resources_collected(resources: Dictionary)
var has_been_looted: bool = false

func initialize(pos: Vector2, context: TerrainContext, variant: String = ""):
	spawn_position = pos
	terrain_context = context
	visual_variant = variant
	position = spawn_position
	setup_visual()

func setup_visual():
	pass

func get_object_type() -> String:
	return object_type

# Interaction interface implementation
func can_interact() -> bool:
	return not has_been_looted

func interact_with(player: Node) -> void:
	# Override in subclasses for specific interaction behavior
	pass
