extends Node

## Helper script to assign audio files to AudioStreamPlayer2D nodes in scenes.
## Run this once in the editor to set up all audio references.
## This is a utility script and should not be attached to any node in production.

const MELEE_ATTACK_PATH = "res://assets/Audio/Weapon/Attack/Melee Attack.mp3"
const FIRE_ATTACK_PATH = "res://assets/Audio/Weapon/Attack/Fire Attack.mp3"
const MELEE_IMPACT_PATH = "res://assets/Audio/Weapon/Impact/Melee Impact.mp3"
const FIRE_IMPACT_PATH = "res://assets/Audio/Weapon/Impact/Fire Impact.mp3"
const WALK_PATH = "res://assets/Audio/walk.mp3"
const DASH_PATH = "res://assets/Audio/Dash.mp3"
const ZOMBIE_PATH = "res://assets/Audio/zombie.mp3"
const TEXT_PATH = "res://assets/Audio/text.mp3"

func setup_weapon_audio(weapon: Node2D, is_fire_weapon: bool = false) -> void:
	"""Setup audio for a weapon node"""
	if weapon.has_node("AttackAudio"):
		var attack_audio = weapon.get_node("AttackAudio")
		var attack_sound = load(FIRE_ATTACK_PATH if is_fire_weapon else MELEE_ATTACK_PATH)
		if attack_sound:
			attack_audio.stream = attack_sound
			print("✓ Assigned attack audio to ", weapon.name)

	if weapon.has_node("ImpactAudio"):
		var impact_audio = weapon.get_node("ImpactAudio")
		var impact_sound = load(FIRE_IMPACT_PATH if is_fire_weapon else MELEE_IMPACT_PATH)
		if impact_sound:
			impact_audio.stream = impact_sound
			print("✓ Assigned impact audio to ", weapon.name)

func setup_projectile_audio(projectile: Node2D) -> void:
	"""Setup audio for a projectile node"""
	if projectile.has_node("ImpactAudio"):
		var impact_audio = projectile.get_node("ImpactAudio")
		var impact_sound = load(FIRE_IMPACT_PATH)
		if impact_sound:
			impact_audio.stream = impact_sound
			print("✓ Assigned impact audio to ", projectile.name)

func setup_player_audio(player: CharacterBody2D) -> void:
	"""Setup audio for the player"""
	if player.has_node("WalkAudio"):
		var walk_audio = player.get_node("WalkAudio")
		var walk_sound = load(WALK_PATH)
		if walk_sound:
			walk_audio.stream = walk_sound
			walk_audio.volume_db = -5.0  # Slightly quieter
			print("✓ Assigned walk audio to player")

	if player.has_node("DashAudio"):
		var dash_audio = player.get_node("DashAudio")
		var dash_sound = load(DASH_PATH)
		if dash_sound:
			dash_audio.stream = dash_sound
			print("✓ Assigned dash audio to player")

func setup_enemy_audio(enemy: CharacterBody2D) -> void:
	"""Setup audio for an enemy"""
	if enemy.has_node("ZombieAudio"):
		var zombie_audio = enemy.get_node("ZombieAudio")
		var zombie_sound = load(ZOMBIE_PATH)
		if zombie_sound:
			zombie_audio.stream = zombie_sound
			zombie_audio.volume_db = -10.0  # Quieter
			print("✓ Assigned zombie audio to ", enemy.name)

func setup_textbox_audio(textbox: Control) -> void:
	"""Setup audio for textbox"""
	if textbox.has_node("AudioStreamPlayer"):
		var text_audio = textbox.get_node("AudioStreamPlayer")
		var text_sound = load(TEXT_PATH)
		if text_sound:
			text_audio.stream = text_sound
			print("✓ Assigned text audio to textbox")

# Example usage:
# var helper = AudioSetupHelper.new()
# helper.setup_player_audio($Player)
# helper.setup_weapon_audio($Player/WeaponSlot/Axe, false)
# helper.setup_weapon_audio($Player/WeaponSlot/FireStaff, true)
# helper.setup_enemy_audio($ZombieSmall)
