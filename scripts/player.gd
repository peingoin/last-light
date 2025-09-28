extends CharacterBody2D

signal health_changed(new_health)

const speed: float = 400.0
const accel: float = 2.0

var input: Vector2
var player_health: int = 20

@export var invuln_duration: float = 0.6
var is_invulnerable: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interact_sensor: Area2D = $InteractSensor

var nearby_interactables: Array[Interactable] = []
var closest_interactable: Interactable = null

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

func _ready() -> void:
	add_to_group("player")
	
	if interact_sensor:
		interact_sensor.area_entered.connect(_on_interactable_entered)
		interact_sensor.area_exited.connect(_on_interactable_exited)

func _process(delta: float) -> void:
	var player_input := get_input()
	velocity = lerp(velocity, player_input * speed, delta * accel)
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_handle_interact()

func _handle_interact() -> void:
	if Dialogue and Dialogue.current_lines.size() > 0:
		return
	
	if closest_interactable:
		closest_interactable.interact(self)

func can_take_damage() -> bool:
	# Return TRUE only when the player is NOT invulnerable
	return not is_invulnerable

func take_damage(damage: int) -> void:
	if is_invulnerable:
		return

	player_health -= damage
	health_changed.emit(player_health)
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
	var original_alpha := sprite.modulate.a
	var flicker_interval := 0.1
	var elapsed_time := 0.0

	while elapsed_time < duration:
		sprite.modulate.a = 0.5 if sprite.modulate.a == original_alpha else original_alpha
		await get_tree().create_timer(flicker_interval).timeout
		elapsed_time += flicker_interval

	# Restore original alpha
	sprite.modulate.a = original_alpha

func _on_interactable_entered(area: Area2D) -> void:
	if area is Interactable:
		nearby_interactables.append(area)
		_update_closest_interactable()

func _on_interactable_exited(area: Area2D) -> void:
	if area is Interactable:
		nearby_interactables.erase(area)
		_update_closest_interactable()

func _update_closest_interactable() -> void:
	if nearby_interactables.is_empty():
		closest_interactable = null
		return
	
	var closest_distance := INF
	var new_closest: Interactable = null
	
	for interactable in nearby_interactables:
		if not is_instance_valid(interactable):
			continue
		
		var distance := global_position.distance_to(interactable.global_position)
		if distance < closest_distance:
			closest_distance = distance
			new_closest = interactable
	
	closest_interactable = new_closest
