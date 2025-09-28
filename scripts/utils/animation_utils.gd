class_name AnimationUtils

static func create_sprite_frames_from_sequence(base_path: String, start_frame: int, end_frame: int) -> SpriteFrames:
	var sprite_frames = SpriteFrames.new()
	sprite_frames.add_animation("default")

	for i in range(start_frame, end_frame + 1):
		var frame_path = base_path + str(i).pad_zeros(4) + ".png"
		var texture = load(frame_path) as Texture2D
		if texture:
			sprite_frames.add_frame("default", texture)

	return sprite_frames

static func setup_attack_animation(anim_player: AnimationPlayer, frames: SpriteFrames, hit_frame: int) -> void:
	var animation = Animation.new()
	var sprite_track = animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(sprite_track, ".")

	# Enable hitbox at hit frame
	var hit_time = hit_frame / 10.0  # Assuming 10 FPS
	animation.track_insert_key(sprite_track, hit_time, {
		"method": "enable_hitbox",
		"args": []
	})

	# Disable hitbox after attack
	var end_time = frames.get_frame_count("default") / 10.0
	animation.track_insert_key(sprite_track, end_time, {
		"method": "disable_hitbox",
		"args": []
	})

	animation.length = end_time
	anim_player.add_animation_library("attack", animation)