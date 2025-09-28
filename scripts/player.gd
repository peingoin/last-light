extends CharacterBody2D

const speed: float = 400.0
const accel: float = 2.0

var input: Vector2
var player_health: int = 20

@export var invuln_duration: float = 0.6
var is_invulnerable: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func get_input() -> Vector2:
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	# face direction
	if input.x > 0.0:
		animated_sprite.flip_h = false
	elif input.x < 0.0:
		animated_sprite.flip_h = true

	# don't interrupt the "hit" animation while it plays
	if animated_sprite.animation != "hit":
		if input == Vector2.ZERO:
			if animated_sprite.animation != "idle":
				animated_sprite.play("idle")
		else:
			if animated_sprite.animation != "run":
				animated_sprite.play("run")

	return input.normalized()

func _process(delta: float) -> void:
	var player_input := get_input()
	velocity = lerp(velocity, player_input * speed, delta * accel)
	move_and_slide()

func can_take_damage() -> bool:
	# Return TRUE only when the player is NOT invulnerable
	return not is_invulnerable

func take_damage(damage: int) -> void:
	if is_invulnerable:
		return

	player_health -= damage
	is_invulnerable = true

	# play hit anim immediately
	animated_sprite.play("hit")

	# flicker while invulnerable (non-blocking)
	start_flicker(invuln_duration)

	# end i-frames after a delay
	await get_tree().create_timer(invuln_duration).timeout
	is_invulnerable = false

	# resume to idle/run depending on input
	if input == Vector2.ZERO:
		animated_sprite.play("idle")
	else:
		animated_sprite.play("run")

# Visual feedback for i-frames (alpha toggle)
func start_flicker(duration: float) -> void:
	var sprite := animated_sprite
	var elapsed := 0.0
	var step := 0.08

	while elapsed < duration:
		sprite.modulate.a = 0.3 if sprite.modulate.a == 1.0 else 1.0
		await get_tree().create_timer(step).timeout
		elapsed += step

	# reset alpha at the end
	sprite.modulate.a = 1.0
