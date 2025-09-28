# Spawner.gd
extends Node2D

# --- Pick your player reference style ---
@export var player_path: NodePath            # drag Player here (optional). Leave empty to auto-detect.

# --- Spawn settings ---
@export var monster_scenes: Array[PackedScene]
@export var default_radius: float = 10.0
@export var default_count: int = 6
@export var face_center: bool = false
@export var even_spacing: bool = true
@export_range(0.0, 3.14, 0.01) var angle_jitter: float = 0.2
@export var radial_thickness: float = 0.0
@export var spawn_parent_path: NodePath      # optional target container (e.g., "Enemies")

var _rng := RandomNumberGenerator.new()
var _player: Node2D = null

func _ready() -> void:
	_rng.randomize()
	_resolve_player()

func _resolve_player() -> void:
	# 1) Inspector path
	if player_path != NodePath():
		var n := get_node_or_null(player_path)
		if n and n is Node2D:
			_player = n
			return
	# 2) Sibling named "Player"
	if get_parent() and get_parent().has_node("Player"):
		var n2 := get_parent().get_node("Player")
		if n2 is Node2D:
			_player = n2
			return
	# 3) Anywhere in the tree (first match)
	var root := get_tree().get_root()
	var found := root.find_child("Player", true, false)  # recursive, no owned-only
	if found and found is Node2D:
		_player = found

func set_player(p: Node2D) -> void:
	_player = p

func get_player() -> Node2D:
	if _player == null:
		_resolve_player()
	return _player

func _resolve_spawn_parent() -> Node:
	if spawn_parent_path == NodePath():
		return get_parent() if get_parent() else self
	return get_node(spawn_parent_path)

## Spawns `count` monsters on a circle of `radius` around `center`.
## Returns an array of the spawned nodes.
func spawn_monsters(center: Vector2 = global_position, count: int = default_count, radius: float = default_radius) -> Array:
	print("spawning monsters")
	var spawned: Array = []
	var parent := _resolve_spawn_parent()

	if monster_scenes.is_empty(): 
		push_warning("Spawner: monster_scenes is empty; nothing to spawn.")
		return spawned
	if count <= 0 or radius <= 0.0:
		return spawned

	# Prepare angles
	var angles: Array[float] = []
	if even_spacing:
		var offset := _rng.randf_range(0.0, TAU)
		for i in count:
			var base := offset + float(i) * TAU / float(count)
			var jitter := _rng.randf_range(-angle_jitter, angle_jitter)
			angles.append(base + jitter)
	else:
		for i in count:
			angles.append(_rng.randf_range(0.0, TAU))

	for a in angles:
		var r := radius
		if radial_thickness > 0.0:
			var half := radial_thickness * 0.5
			r = _rng.randf_range(max(0.0, radius - half), radius + half)

		var pos := center + Vector2.RIGHT.rotated(a) * r

		var scene: PackedScene = monster_scenes[_rng.randi_range(0, monster_scenes.size() - 1)]
		var mob := scene.instantiate()

		if mob is Node2D:
			mob.global_position = pos
			if face_center:
				mob.look_at(center)
		elif mob.has_method("set_global_position"):
			mob.set_global_position(pos)

		parent.add_child(mob)
		spawned.append(mob)

	return spawned
