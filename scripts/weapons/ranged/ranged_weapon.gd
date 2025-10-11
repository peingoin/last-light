extends BaseWeapon
class_name RangedWeapon

## Base class for ranged weapons that spawn projectiles instead of using melee hitboxes.
## Reuses BaseWeapon's cooldown and signal system while overriding attack behavior.

@export var projectile_scene: PackedScene
@export var projectile_spawn_offset: float = 20.0

func _ready() -> void:
	# Disable melee-specific functionality
	if hitbox_shape:
		hitbox_shape.disabled = true

	# Hide slash effects if they exist
	if slash_effect:
		slash_effect.visible = false

	# Store the base position for jiggling
	base_position = position

func attack(direction: Vector2) -> void:
	if not can_attack():
		return

	is_attacking = true
	cooldown_timer = attack_cooldown

	attack_started.emit()

	# Spawn projectile
	spawn_projectile(direction)

	# Ranged weapons don't hide during attack
	# End attack immediately (no animation to wait for)
	is_attacking = false
	attack_finished.emit()

func spawn_projectile(direction: Vector2) -> void:
	if not projectile_scene:
		push_error("No projectile scene assigned to ranged weapon!")
		return

	# Get the player reference
	var player = get_parent().get_parent()
	if not player:
		return

	# Create projectile instance
	var projectile = projectile_scene.instantiate()

	# Calculate spawn position (offset from player in attack direction)
	var spawn_pos = get_spawn_position(direction)

	# Add to scene tree (at game level, not as weapon child)
	var game_root = get_tree().current_scene
	game_root.add_child(projectile)

	# Initialize projectile
	if projectile.has_method("initialize"):
		projectile.initialize(spawn_pos, direction, player)

func get_spawn_position(direction: Vector2) -> Vector2:
	var player = get_parent().get_parent()
	if player:
		return player.global_position + direction * projectile_spawn_offset
	return global_position
