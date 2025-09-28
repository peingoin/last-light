extends Interactable
class_name Machine

signal life_force_changed(new_value: int)
signal sacrifice_completed(npc_name: String, life_force_gained: int)

@export var max_life_force: int = 1000
@export var current_life_force: int = 100

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_interacting: bool = false
var _sacrifice_menu_npcs: Array[BaseNPC] = []

func _ready() -> void:
	super._ready()
	add_to_group("machine")

func interact(player: Node) -> void:
	if is_interacting:
		return
	
	is_interacting = true
	
	# Show current life force and prompt for sacrifice
	var dialogue_system = get_node_or_null("/root/Dialogue")
	if dialogue_system:
		# First show current life force
		dialogue_system.open_single("Machine", "Current Life Force: %d" % current_life_force)
		await dialogue_system.dialogue_finished
		
		# Check if there are any NPCs available
		var living_npcs = get_living_npcs()
		if living_npcs.is_empty():
			dialogue_system.open_single("Machine", "No NPCs available for sacrifice.")
			is_interacting = false
			return
		
		# Ask if player wants to sacrifice someone
		_show_sacrifice_prompt()
	else:
		is_interacting = false

func _show_sacrifice_prompt() -> void:
	var dialogue_system = get_node("/root/Dialogue")
	
	# Create options content with the proper format
	var content = """Do you want to sacrifice someone this turn?

[options]
- Yes | sacrifice_yes
- No | sacrifice_no
[/options]"""
	
	dialogue_system.show_dialogue_with_options("Machine", content, self)

func sacrifice_yes() -> void:
	_show_npc_selection_menu()

func sacrifice_no() -> void:
	is_interacting = false

func _show_npc_selection_menu() -> void:
	var living_npcs = get_living_npcs()
	if living_npcs.is_empty():
		is_interacting = false
		return
	
	var dialogue_system = get_node("/root/Dialogue")
	
	# Build options content
	var content = "Choose who to sacrifice:\n\n[options]\n"
	
	# Add each living NPC as an option
	for i in range(living_npcs.size()):
		var npc = living_npcs[i]
		var npc_name = npc.display_name if npc.display_name else "Unknown NPC"
		var life_force = npc.get_life_force()
		var option_text = "%s (Life Force: %d)" % [npc_name, life_force]
		content += "- %s | sacrifice_npc_%d\n" % [option_text, i]
	
	# Add cancel option
	content += "- Cancel | sacrifice_cancel\n"
	content += "[/options]"
	
	dialogue_system.show_dialogue_with_options("Machine", content, self)
	
	# Store NPCs for callback reference
	_sacrifice_menu_npcs = living_npcs

func _sacrifice_npc(npc: BaseNPC) -> void:
	if not npc or not npc.is_alive:
		is_interacting = false
		return
	
	# Get life force from NPC
	var life_force_gained = npc.get_life_force()
	var npc_name = npc.display_name
	
	# Add to Machine's life force
	current_life_force = min(max_life_force, current_life_force + life_force_gained)
	life_force_changed.emit(current_life_force)
	
	# Kill the NPC
	npc.die()
	
	# Show result
	var dialogue_system = get_node("/root/Dialogue")
	dialogue_system.open_single("Machine", "%s has been sacrificed. Life Force gained: %d\nTotal Life Force: %d" % [npc_name, life_force_gained, current_life_force])
	
	sacrifice_completed.emit(npc_name, life_force_gained)
	
	await dialogue_system.dialogue_finished
	is_interacting = false
	_sacrifice_menu_npcs.clear()

func sacrifice_cancel() -> void:
	is_interacting = false
	_sacrifice_menu_npcs.clear()

# Dynamic callback methods for NPC selection
func sacrifice_npc_0() -> void:
	if _sacrifice_menu_npcs.size() > 0:
		_sacrifice_npc(_sacrifice_menu_npcs[0])

func sacrifice_npc_1() -> void:
	if _sacrifice_menu_npcs.size() > 1:
		_sacrifice_npc(_sacrifice_menu_npcs[1])

func sacrifice_npc_2() -> void:
	if _sacrifice_menu_npcs.size() > 2:
		_sacrifice_npc(_sacrifice_menu_npcs[2])

func sacrifice_npc_3() -> void:
	if _sacrifice_menu_npcs.size() > 3:
		_sacrifice_npc(_sacrifice_menu_npcs[3])

func sacrifice_npc_4() -> void:
	if _sacrifice_menu_npcs.size() > 4:
		_sacrifice_npc(_sacrifice_menu_npcs[4])

func sacrifice_npc_5() -> void:
	if _sacrifice_menu_npcs.size() > 5:
		_sacrifice_npc(_sacrifice_menu_npcs[5])

func sacrifice_npc_6() -> void:
	if _sacrifice_menu_npcs.size() > 6:
		_sacrifice_npc(_sacrifice_menu_npcs[6])

func sacrifice_npc_7() -> void:
	if _sacrifice_menu_npcs.size() > 7:
		_sacrifice_npc(_sacrifice_menu_npcs[7])

func get_living_npcs() -> Array[BaseNPC]:
	var npcs: Array[BaseNPC] = []
	for node in get_tree().get_nodes_in_group("npcs"):
		if node is BaseNPC and node.is_alive:
			npcs.append(node)
	return npcs

func add_life_force(amount: int) -> void:
	current_life_force = min(max_life_force, current_life_force + amount)
	life_force_changed.emit(current_life_force)

func consume_life_force(amount: int) -> bool:
	if current_life_force >= amount:
		current_life_force -= amount
		life_force_changed.emit(current_life_force)
		return true
	return false