extends CharacterBody2D

const speed = 400.0
const accel = 2.0

var input: Vector2

func get_input():
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	return input.normalized()


func _process(delta):
	var player_input = get_input()

	velocity = lerp(velocity, player_input * speed, delta * accel)

	move_and_slide()
