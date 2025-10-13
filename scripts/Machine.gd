extends InteractableArea
class_name Machine

signal life_force_changed(new_value: int)
signal transfer_completed(npc_name: String, life_force_gained: int)

@export var max_life_force: int = 1000
@export var current_life_force: int = 1000

@onready var sprite: Sprite2D = $Sprite2D
@onready var prompt: Label = $Prompt

var is_interacting: bool = false
var _transfer_menu_npcs: Array[BaseNPC] = []
var _selected_npc: BaseNPC = null

func _ready() -> void:
	super._ready()
	add_to_group("machine")

	# Hide prompt initially
	if prompt:
		prompt.visible = false

func show_prompt() -> void:
	if prompt:
		prompt.visible = true

func hide_prompt() -> void:
	if prompt:
		prompt.visible = false

func interact(player: Node) -> void:
	if is_interacting:
		return

	is_interacting = true

	# Hide prompt when starting interaction
	if prompt:
		prompt.visible = false

	# Show current life force and prompt for filling
	var dialogue_system = get_node_or_null("/root/Dialogue")

	if dialogue_system:
		# First show current life force
		var life_force_needed = max_life_force - current_life_force
		dialogue_system.open_single("Machine", "Current Life Force: %d/%d\nLife Force Needed: %d" % [current_life_force, max_life_force, life_force_needed])
		await dialogue_system.dialogue_finished

		# Check if machine is already full
		if current_life_force >= max_life_force:
			dialogue_system.open_single("Machine", "Life Force is already at maximum capacity.")
			is_interacting = false
			return

		# Check if there are any NPCs available
		var living_npcs = get_living_npcs()
		if living_npcs.is_empty():
			dialogue_system.open_single("Machine", "No NPCs available to transfer life force from.")
			is_interacting = false
			return

		# Ask if player wants to fill the machine
		_show_fill_prompt()
	else:
		is_interacting = false

func _show_fill_prompt() -> void:
	var dialogue_system = get_node("/root/Dialogue")

	# Create options content with the proper format
	var content = """Do you want to fill the Life Force Machine?
[[OPTIONS]]
[y:yes:fill_yes] Yes
[n:no:fill_no] No
[[/OPTIONS]]"""

	dialogue_system.show_dialogue_with_options("Machine", content, self)

func fill_yes() -> void:
	_show_npc_selection_menu()

func fill_no() -> void:
	is_interacting = false

func _show_npc_selection_menu() -> void:
	var living_npcs = get_living_npcs()
	if living_npcs.is_empty():
		is_interacting = false
		return

	var dialogue_system = get_node("/root/Dialogue")

	# Build options content
	var content = "Choose NPC to transfer life force from:\n[[OPTIONS]]\n"

	# Add each living NPC as an option (using numbers 1-8 as keys)
	var keys = ["1", "2", "3", "4", "5", "6", "7", "8"]
	for i in range(living_npcs.size()):
		var npc = living_npcs[i]
		var npc_name = npc.display_name if npc.display_name else "Unknown NPC"
		var life_force = npc.get_life_force()
		var option_text = "%s (Life Force: %d)" % [npc_name, life_force]
		content += "[%s:npc%d:select_npc_%d] %s\n" % [keys[i], i, i, option_text]

	# Add cancel option
	content += "[x:cancel:transfer_cancel] Cancel\n"
	content += "[[/OPTIONS]]"

	dialogue_system.show_dialogue_with_options("Machine", content, self)

	# Store NPCs for callback reference
	_transfer_menu_npcs = living_npcs

func _show_amount_selection_menu(npc: BaseNPC) -> void:
	if not npc or not npc.is_alive:
		is_interacting = false
		return

	_selected_npc = npc
	var dialogue_system = get_node("/root/Dialogue")
	var npc_life_force = npc.get_life_force()
	var life_force_needed = max_life_force - current_life_force

	# Build options for different amounts
	var content = "How much life force to transfer from %s?\n[[OPTIONS]]\n" % npc.display_name

	# Offer options: 10, 25, 50, 100, or all
	var amounts = [10, 25, 50, 100]
	var keys = ["a", "b", "c", "d"]
	var key_index = 0
	for amount in amounts:
		if amount <= npc_life_force:
			content += "[%s:amt%d:transfer_amount_%d] %d Life Force\n" % [keys[key_index], amount, amount, amount]
			key_index += 1

	# Option to transfer all
	if npc_life_force > 0:
		content += "[%s:all:transfer_amount_all] All (%d Life Force)\n" % [keys[key_index], npc_life_force]

	# Add cancel option
	content += "[x:cancel:transfer_cancel] Cancel\n"
	content += "[[/OPTIONS]]"

	dialogue_system.show_dialogue_with_options("Machine", content, self)

func _transfer_life_force(npc: BaseNPC, amount: int) -> void:
	if not npc or not npc.is_alive:
		is_interacting = false
		return

	var npc_name = npc.display_name

	# Consume life force from NPC
	var amount_consumed = npc.consume_life_force(amount)

	# Add to Machine's life force
	current_life_force = min(max_life_force, current_life_force + amount_consumed)
	life_force_changed.emit(current_life_force)

	# Show result
	var dialogue_system = get_node("/root/Dialogue")
	var message = "Transferred %d Life Force from %s.\nMachine Life Force: %d/%d" % [amount_consumed, npc_name, current_life_force, max_life_force]

	# Check if NPC died from the transfer
	if not npc.is_alive:
		message += "\n%s has died from the transfer." % npc_name

	dialogue_system.open_single("Machine", message)

	transfer_completed.emit(npc_name, amount_consumed)

	await dialogue_system.dialogue_finished
	is_interacting = false
	_transfer_menu_npcs.clear()
	_selected_npc = null

func transfer_cancel() -> void:
	is_interacting = false
	_transfer_menu_npcs.clear()
	_selected_npc = null

# Dynamic callback methods for NPC selection
func select_npc_0() -> void:
	if _transfer_menu_npcs.size() > 0:
		_show_amount_selection_menu(_transfer_menu_npcs[0])

func select_npc_1() -> void:
	if _transfer_menu_npcs.size() > 1:
		_show_amount_selection_menu(_transfer_menu_npcs[1])

func select_npc_2() -> void:
	if _transfer_menu_npcs.size() > 2:
		_show_amount_selection_menu(_transfer_menu_npcs[2])

func select_npc_3() -> void:
	if _transfer_menu_npcs.size() > 3:
		_show_amount_selection_menu(_transfer_menu_npcs[3])

func select_npc_4() -> void:
	if _transfer_menu_npcs.size() > 4:
		_show_amount_selection_menu(_transfer_menu_npcs[4])

func select_npc_5() -> void:
	if _transfer_menu_npcs.size() > 5:
		_show_amount_selection_menu(_transfer_menu_npcs[5])

func select_npc_6() -> void:
	if _transfer_menu_npcs.size() > 6:
		_show_amount_selection_menu(_transfer_menu_npcs[6])

func select_npc_7() -> void:
	if _transfer_menu_npcs.size() > 7:
		_show_amount_selection_menu(_transfer_menu_npcs[7])

# Dynamic callback methods for amount selection
func transfer_amount_10() -> void:
	if _selected_npc:
		_transfer_life_force(_selected_npc, 10)

func transfer_amount_25() -> void:
	if _selected_npc:
		_transfer_life_force(_selected_npc, 25)

func transfer_amount_50() -> void:
	if _selected_npc:
		_transfer_life_force(_selected_npc, 50)

func transfer_amount_100() -> void:
	if _selected_npc:
		_transfer_life_force(_selected_npc, 100)

func transfer_amount_all() -> void:
	if _selected_npc:
		var amount = _selected_npc.get_life_force()
		_transfer_life_force(_selected_npc, amount)

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
