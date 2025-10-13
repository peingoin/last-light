class_name BossAttack
extends Node

## Base class for boss attack patterns.
## Each attack should extend this and implement the virtual methods.

# Properties set by boss
var boss: CharacterBody2D
var player: Node2D
var is_phase_2: bool = false

# Internal state
var is_active: bool = false
var attack_timer: float = 0.0

## Check if this attack can be executed (range requirements, etc.)
func can_execute() -> bool:
	return true

## Start executing the attack
func execute() -> void:
	is_active = true
	attack_timer = 0.0

## Update the attack each frame. Returns true when finished.
func update(delta: float) -> bool:
	attack_timer += delta
	return false  # Override to return true when done

## Called if attack is cancelled/interrupted
func interrupt() -> void:
	is_active = false
	cleanup()

## Clean up any spawned objects or effects
func cleanup() -> void:
	pass

## Get the damage this attack deals
func get_damage() -> int:
	return 2  # Default damage for all boss attacks
