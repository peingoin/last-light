class_name AssetUtils

static func load_weapon_sprite(weapon_name: String) -> Texture2D:
	var sprite_path = "res://assets/Melee/oubliette_weapons - free/spr_wep_" + weapon_name + ".png"
	return load(sprite_path) as Texture2D

static func load_attack_animation_sequence(animation_name: String) -> SpriteFrames:
	var base_path = "res://assets/Melee/Melee Effects/+40FXPack_NYKNCK/Slash and Swing/" + animation_name + "/"
	var sprite_frames = SpriteFrames.new()
	sprite_frames.add_animation("default")

	# Try to load S0191 through S0195 sequence
	for i in range(191, 196):
		var frame_path = base_path + "S0" + str(i) + ".png"
		var texture = load(frame_path) as Texture2D
		if texture:
			sprite_frames.add_frame("default", texture)

	return sprite_frames