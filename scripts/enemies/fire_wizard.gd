extends BaseEnemy
class_name FireWizard

## Fire Wizard Boss
## Features 3 attacks with state machine and 2-phase battle

# State machine
enum State {
	IDLE,                # Waiting for player to trigger battle
	BATTLE_ACTIVE,       # Selecting and preparing attacks
	ATTACKING,           # Executing current attack
	COOLDOWN,            # 1.5s delay after attack
	PHASE_TRANSITION,    # Health ≤ 250, updating stats
	DEFEATED             # Health ≤ 0
}

# Arena and battle setup
const TRIGGER_RADIUS: float = 500.0
const ARENA_RADIUS: float = 500.0
const COOLDOWN_DURATION: float = 1.5
const CLOSE_RANGE_THRESHOLD: float = 100.0
const PHASE_2_HEALTH_THRESHOLD: float = 250.0

# Phase tracking
var is_phase_2: bool = false
var has_transitioned_to_phase_2: bool = false

# State machine
var current_state: State = State.IDLE
var cooldown_timer_boss: float = 0.0

# Attack system
var attack_1: CircleFireballAttack
var attack_2: FlamethrowerAttack
var attack_3: ShootFireballAttack
var current_attack: BossAttack = null

# Arena
var arena_boundary_scene: PackedScene = preload("res://scenes/enemies/arena_boundary.tscn")
var arena_instance: Node2D = null

# Battle state
var battle_started: bool = false

func _ready() -> void:
	# Boss stats
	enemy_health = 500.0
	speed = 60.0
	detect_range = TRIGGER_RADIUS
	attack_range = CLOSE_RANGE_THRESHOLD
	attack_cooldown = COOLDOWN_DURATION
	damage = 2
	knockback_resistance = 100.0

	# Call parent ready
	super._ready()

	# Initialize attacks
	attack_1 = CircleFireballAttack.new()
	attack_1.boss = self
	attack_1.arena_radius = ARENA_RADIUS
	add_child(attack_1)

	attack_2 = FlamethrowerAttack.new()
	attack_2.boss = self
	add_child(attack_2)

	attack_3 = ShootFireballAttack.new()
	attack_3.boss = self
	add_child(attack_3)

	# Set initial state
	current_state = State.IDLE

func _physics_process(delta: float) -> void:
	if is_dying:
		return

	# Update player reference for attacks
	if player:
		attack_1.player = player
		attack_2.player = player
		attack_3.player = player

	# State machine
	match current_state:
		State.IDLE:
			_state_idle()

		State.BATTLE_ACTIVE:
			_state_battle_active()

		State.ATTACKING:
			_state_attacking(delta)

		State.COOLDOWN:
			_state_cooldown(delta)

		State.PHASE_TRANSITION:
			_state_phase_transition()

		State.DEFEATED:
			_state_defeated()

	# Check for phase transition
	check_phase_transition()

	move_and_slide()

func _state_idle() -> void:
	# Wait for player to enter trigger radius
	if not player:
		return

	var distance = global_position.distance_to(player.global_position)

	if distance <= TRIGGER_RADIUS and not battle_started:
		trigger_boss_battle()

func _state_battle_active() -> void:
	# Select and start an attack
	select_attack()

	if current_attack:
		current_attack.execute()
		current_state = State.ATTACKING

func _state_attacking(delta: float) -> void:
	# Update current attack
	if current_attack:
		var attack_finished = current_attack.update(delta)

		if attack_finished:
			current_attack = null
			current_state = State.COOLDOWN
			cooldown_timer_boss = COOLDOWN_DURATION

func _state_cooldown(delta: float) -> void:
	# Wait for cooldown to finish
	cooldown_timer_boss -= delta

	if cooldown_timer_boss <= 0.0:
		current_state = State.BATTLE_ACTIVE

func _state_phase_transition() -> void:
	# Update stats for phase 2
	if not has_transitioned_to_phase_2:
		is_phase_2 = true
		speed = 72.0  # 20% increase from 60

		# Update attack phase flags
		attack_1.is_phase_2 = true
		attack_2.is_phase_2 = true
		attack_3.is_phase_2 = true

		has_transitioned_to_phase_2 = true

		# Return to battle
		current_state = State.BATTLE_ACTIVE

func _state_defeated() -> void:
	# Already handled by die() from BaseEnemy
	pass

func trigger_boss_battle() -> void:
	battle_started = true
	current_state = State.BATTLE_ACTIVE

	# Spawn arena boundary
	spawn_arena()

func spawn_arena() -> void:
	if arena_instance:
		return

	arena_instance = arena_boundary_scene.instantiate()
	arena_instance.global_position = global_position
	get_parent().add_child(arena_instance)

func select_attack() -> void:
	if not player:
		return

	var distance = global_position.distance_to(player.global_position)

	# Select attacks based on distance
	var available_attacks: Array[BossAttack] = []

	if distance <= CLOSE_RANGE_THRESHOLD:
		# Close range: attacks 1 and 2
		available_attacks = [attack_1, attack_2]
	else:
		# Far range: attacks 1 and 3
		available_attacks = [attack_1, attack_3]

	# 50/50 random selection
	current_attack = available_attacks[randi() % 2]

func check_phase_transition() -> void:
	if has_transitioned_to_phase_2:
		return

	if enemy_health <= PHASE_2_HEALTH_THRESHOLD:
		current_state = State.PHASE_TRANSITION

func take_damage(damage_amount: int) -> void:
	# Check if flamethrower attack is active and interrupt it
	if current_state == State.ATTACKING and current_attack == attack_2:
		current_attack.interrupt()
		current_state = State.COOLDOWN
		cooldown_timer_boss = COOLDOWN_DURATION

	# Call parent take_damage
	super.take_damage(damage_amount)

func die() -> void:
	current_state = State.DEFEATED

	# Interrupt any active attack
	if current_attack:
		current_attack.interrupt()
		current_attack = null

	# Remove arena boundary
	if arena_instance and is_instance_valid(arena_instance):
		arena_instance.queue_free()

	super.die()
