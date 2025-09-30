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

func safe_load_texture(path: String) -> Texture2D:
	var texture = load(path)
	if texture and texture is Texture2D and texture.get_width() > 0 and texture.get_height() > 0:
		return texture
	else:
		return null

func create_fallback_rect(sprite: Sprite2D, size: Vector2, color: Color):
	var image = Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGB8)
	image.fill(color)
	var texture = ImageTexture.new()
	texture.set_image(image)
	sprite.texture = texture

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
	var tree_path = "res://assets/Apocalypse_Assets/PostApocalypse_AssetPack_v1.1.2/Objects/Nature/" + color_variant + "/Tree_1_Spruce_" + color_variant + ".png"
	var texture = safe_load_texture(tree_path)
	if texture:
		sprite.texture = texture
	else:
		create_fallback_rect(sprite, TREE_SPRITE_SIZE, Color.DARK_GREEN)
	tree.add_child(sprite)

	return tree

func create_garbage_visual(pos: Vector2, player: Node = null) -> Node2D:
	var garbage = StaticBody2D.new()
	garbage.position = pos

	var collision = create_bottom_collision(GARBAGE_COLLISION_SIZE)
	garbage.add_child(collision)

	var sprite = Sprite2D.new()
	var texture = safe_load_texture("res://assets/Apocalypse_Assets/PostApocalypse_AssetPack_v1.1.2/Objects/Garbage-Bin_1.png")
	if texture:
		sprite.texture = texture
	else:
		create_fallback_rect(sprite, GARBAGE_SPRITE_SIZE, Color.BROWN)
	garbage.add_child(sprite)

	return garbage

func create_barrel_visual(pos: Vector2, player: Node = null) -> Node2D:
	var barrel = StaticBody2D.new()
	barrel.position = pos

	var collision = create_bottom_collision(BARREL_COLLISION_SIZE)
	barrel.add_child(collision)

	var sprite = Sprite2D.new()
	var texture = safe_load_texture("res://assets/Apocalypse_Assets/PostApocalypse_AssetPack_v1.1.2/Objects/Barrel_rust_red_1.png")
	if texture:
		sprite.texture = texture
	else:
		create_fallback_rect(sprite, BARREL_SPRITE_SIZE, Color.ORANGE_RED)
	barrel.add_child(sprite)

	return barrel

func create_pallet_visual(pos: Vector2, player: Node = null) -> Node2D:
	var pallet = StaticBody2D.new()
	pallet.position = pos

	var collision = create_bottom_collision(PALLET_COLLISION_SIZE)
	pallet.add_child(collision)

	var sprite = Sprite2D.new()
	var pallet_variant = randi() % 2 + 1  # Choose between Pallet_1 and Pallet_2
	var texture = safe_load_texture("res://assets/Apocalypse_Assets/PostApocalypse_AssetPack_v1.1.2/Objects/Pallet_" + str(pallet_variant) + ".png")
	if texture:
		sprite.texture = texture
	else:
		create_fallback_rect(sprite, PALLET_SPRITE_SIZE, Color.SADDLE_BROWN)
	pallet.add_child(sprite)

	return pallet

func create_bin_visual(pos: Vector2, player: Node = null) -> Node2D:
	var bin = StaticBody2D.new()
	bin.position = pos

	var collision = create_bottom_collision(BIN_COLLISION_SIZE)
	bin.add_child(collision)

	var sprite = Sprite2D.new()
	var bin_variant = randi() % 4 + 1  # Choose between Garbage-Bin_1 through Garbage-Bin_4
	var texture = safe_load_texture("res://assets/Apocalypse_Assets/PostApocalypse_AssetPack_v1.1.2/Objects/Garbage-Bin_" + str(bin_variant) + ".png")
	if texture:
		sprite.texture = texture
	else:
		create_fallback_rect(sprite, BIN_SPRITE_SIZE, Color.GRAY)
	bin.add_child(sprite)

	return bin

func create_bench_visual(pos: Vector2, player: Node = null) -> Node2D:
	var bench = StaticBody2D.new()
	bench.position = pos

	var collision = create_bottom_collision(BENCH_COLLISION_SIZE)
	bench.add_child(collision)

	var sprite = Sprite2D.new()
	var is_overgrown = randi() % 2 == 0  # 50% chance for overgrown
	var texture: Texture2D

	if is_overgrown:
		texture = safe_load_texture("res://assets/Apocalypse_Assets/PostApocalypse_AssetPack_v1.1.2/Objects/Bench_2_down_Overgrown_Green.png")
	else:
		texture = safe_load_texture("res://assets/Apocalypse_Assets/PostApocalypse_AssetPack_v1.1.2/Objects/Bench_1_down.png")

	if texture:
		sprite.texture = texture
	else:
		create_fallback_rect(sprite, BENCH_SPRITE_SIZE, Color.SANDY_BROWN)

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
