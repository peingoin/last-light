extends Node2D
class_name BaseSpawnableObject

@export var object_type: String = ""
@export var spawn_probability: float = 0.1
@export var visual_variant: String = ""

var spawn_position: Vector2
var terrain_context: TerrainContext

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
