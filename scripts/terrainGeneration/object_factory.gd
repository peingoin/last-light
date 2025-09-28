extends RefCounted
class_name ObjectFactory

# Collision size constants
const TREE_COLLISION_SIZE = Vector2(16, 20
)
const GARBAGE_COLLISION_SIZE = Vector2(14, 18)
const BARREL_COLLISION_SIZE = Vector2(12, 16)
const PALLET_COLLISION_SIZE = Vector2(20, 8)
const BIN_COLLISION_SIZE = Vector2(14, 18)
const BENCH_COLLISION_SIZE = Vector2(24, 12)
const DEFAULT_COLLISION_SIZE = Vector2(8, 8)

# Sprite size constants (typical PostApocalypse asset dimensions)
const TREE_SPRITE_SIZE = Vector2(64, 64)
const GARBAGE_SPRITE_SIZE = Vector2(32, 48)
const BARREL_SPRITE_SIZE = Vector2(32, 48)
const PALLET_SPRITE_SIZE = Vector2(48, 32)
const BIN_SPRITE_SIZE = Vector2(32, 48)
const BENCH_SPRITE_SIZE = Vector2(64, 32)
const DEFAULT_SPRITE_SIZE = Vector2(32, 32)


var bias_config: SpawnBiasConfig

func _init(config: SpawnBiasConfig):
	bias_config = config

static func create_bottom_collision(size: Vector2) -> CollisionShape2D:
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	collision.position = Vector2(0, size.y / 2)
	return collision


func create_object(object_type: String, position: Vector2, terrain_context: TerrainContext, variant: String = "", player: Node = null) -> Node2D:
	var object_instance: Node2D

	match object_type:
		"building":
			object_instance = create_building_visual(position, player)
		"tree":
			object_instance = create_tree_visual(position, variant, player)
		"garbage":
			object_instance = create_garbage_visual(position, player)
		"barrel":
			object_instance = create_barrel_visual(position, player)
		"pallet":
			object_instance = create_pallet_visual(position, player)
		"bin":
			object_instance = create_bin_visual(position, player)
		"bench":
			object_instance = create_bench_visual(position, player)
		_:
			object_instance = create_default_object(position, player)

	return object_instance

func create_building_visual(pos: Vector2, player: Node = null) -> Node2D:
	var building_scene = preload("res://scenes/buidling_2.tscn")
	var building = building_scene.instantiate()
	building.position = pos
	return building

func create_tree_visual(pos: Vector2, color_variant: String, player: Node = null) -> Node2D:
	var tree = StaticBody2D.new()
	tree.position = pos

	var collision = create_bottom_collision(TREE_COLLISION_SIZE)
	tree.add_child(collision)


	var sprite = Sprite2D.new()
	var tree_path = "res://assets/PostApocalypse_AssetPack_v1.1.2/Objects/Nature/" + color_variant + "/Tree_1_Spruce_" + color_variant + ".png"
	sprite.texture = load(tree_path)
	tree.add_child(sprite)

	return tree

func create_garbage_visual(pos: Vector2, player: Node = null) -> Node2D:
	var garbage = StaticBody2D.new()
	garbage.position = pos

	var collision = create_bottom_collision(GARBAGE_COLLISION_SIZE)
	garbage.add_child(collision)


	var sprite = Sprite2D.new()
	sprite.texture = load("res://assets/PostApocalypse_AssetPack_v1.1.2/Objects/Garbage-Bin_1.png")
	garbage.add_child(sprite)

	return garbage

func create_barrel_visual(pos: Vector2, player: Node = null) -> Node2D:
	var barrel = StaticBody2D.new()
	barrel.position = pos

	var collision = create_bottom_collision(BARREL_COLLISION_SIZE)
	barrel.add_child(collision)


	var sprite = Sprite2D.new()
	sprite.texture = load("res://assets/PostApocalypse_AssetPack_v1.1.2/Objects/Barrel_rust_red_1.png")
	barrel.add_child(sprite)

	return barrel

func create_pallet_visual(pos: Vector2, player: Node = null) -> Node2D:
	var pallet = StaticBody2D.new()
	pallet.position = pos

	var collision = create_bottom_collision(PALLET_COLLISION_SIZE)
	pallet.add_child(collision)


	var sprite = Sprite2D.new()
	var pallet_variant = randi() % 2 + 1  # Choose between Pallet_1 and Pallet_2
	sprite.texture = load("res://assets/PostApocalypse_AssetPack_v1.1.2/Objects/Pallet_" + str(pallet_variant) + ".png")
	pallet.add_child(sprite)

	return pallet

func create_bin_visual(pos: Vector2, player: Node = null) -> Node2D:
	var bin = StaticBody2D.new()
	bin.position = pos

	var collision = create_bottom_collision(BIN_COLLISION_SIZE)
	bin.add_child(collision)


	var sprite = Sprite2D.new()
	var bin_variant = randi() % 4 + 1  # Choose between Garbage-Bin_1 through Garbage-Bin_4
	sprite.texture = load("res://assets/PostApocalypse_AssetPack_v1.1.2/Objects/Garbage-Bin_" + str(bin_variant) + ".png")
	bin.add_child(sprite)

	return bin

func create_bench_visual(pos: Vector2, player: Node = null) -> Node2D:
	var bench = StaticBody2D.new()
	bench.position = pos

	var collision = create_bottom_collision(BENCH_COLLISION_SIZE)
	bench.add_child(collision)


	var sprite = Sprite2D.new()
	var is_overgrown = randi() % 2 == 0  # 50% chance for overgrown

	if is_overgrown:
		sprite.texture = load("res://assets/PostApocalypse_AssetPack_v1.1.2/Objects/Bench_2_down_Overgrown_Green.png")
	else:
		sprite.texture = load("res://assets/PostApocalypse_AssetPack_v1.1.2/Objects/Bench_1_down.png")

	bench.add_child(sprite)

	return bench

func create_default_object(pos: Vector2, player: Node = null) -> Node2D:
	var obj = StaticBody2D.new()
	obj.position = pos

	var collision = create_bottom_collision(DEFAULT_COLLISION_SIZE)
	obj.add_child(collision)

	var rect = ColorRect.new()
	rect.size = Vector2(8, 8)
	rect.color = Color.MAGENTA
	obj.add_child(rect)

	return obj
