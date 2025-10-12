extends Node

signal dialogue_finished
signal choice_picked(id: String)

var dialogue_ui: Control
var current_lines: PackedStringArray = []
var current_speaker: String = ""
var line_index: int = 0
var callback_registry: Dictionary = {}
var current_callback_owner: Node = null

func _ready() -> void:
	# Find the dialogue UI when the scene is ready
	call_deferred("_find_dialogue_ui")

func _find_dialogue_ui() -> void:
	# Try multiple possible paths to find the TextBox
	var current_scene = get_tree().current_scene

	# Try current scene paths first
	if current_scene:
		dialogue_ui = current_scene.get_node_or_null("CanvasLayer/UI Control/TextBox")
		if dialogue_ui:
			return
		dialogue_ui = current_scene.get_node_or_null("UI/TextBox")
		if dialogue_ui:
			return
		dialogue_ui = current_scene.get_node_or_null("TextBox")
		if dialogue_ui:
			return

	# Try absolute paths
	dialogue_ui = get_node_or_null("/root/Game/CanvasLayer/UI Control/TextBox")
	if dialogue_ui:
		return
	dialogue_ui = get_node_or_null("/root/VanInterior/CanvasLayer/UI Control/TextBox")
	if dialogue_ui:
		return
	dialogue_ui = get_node_or_null("/root/Game/UI/TextBox")
	if dialogue_ui:
		return
	dialogue_ui = get_node_or_null("/root/Game/TextBox")
	if dialogue_ui:
		return

	print("Warning: Could not find dialogue UI TextBox")

func open(lines: PackedStringArray, speaker_name: String = "") -> void:
	if lines.is_empty():
		return
	
	current_lines = lines
	current_speaker = speaker_name
	line_index = 0
	
	# Find dialogue UI if not found yet
	if not dialogue_ui:
		_find_dialogue_ui()
	
	if dialogue_ui and dialogue_ui.has_method("show_dialogue"):
		show_current_line()

func addText(speaker_name: String, content: String) -> void:
	# Find dialogue UI if not found yet
	if not dialogue_ui:
		_find_dialogue_ui()
	
	if dialogue_ui and dialogue_ui.has_method("addText"):
		dialogue_ui.addText(speaker_name, content)

func open_single(speaker_name: String, content: String) -> void:
	# Find dialogue UI if not found yet
	if not dialogue_ui:
		_find_dialogue_ui()
	
	if dialogue_ui and dialogue_ui.has_method("show_dialogue"):
		dialogue_ui.show_dialogue(speaker_name, content)

func show_current_line() -> void:
	if line_index >= current_lines.size() or not dialogue_ui:
		dialogue_finished.emit()
		return
	
	var current_text = current_lines[line_index]
	if line_index == 0:
		# First line uses show_dialogue
		dialogue_ui.show_dialogue(current_speaker, current_text)
	else:
		# Subsequent lines use addText to queue them
		dialogue_ui.addText(current_speaker, current_text)
	line_index += 1
	
	# Continue showing remaining lines
	while line_index < current_lines.size():
		var next_text = current_lines[line_index]
		dialogue_ui.addText(current_speaker, next_text)
		line_index += 1

func next_line() -> void:
	if line_index < current_lines.size():
		show_current_line()
	else:
		dialogue_finished.emit()

func show_dialogue_with_options(speaker_name: String, content: String, callback_owner: Node = null) -> void:
	# Find dialogue UI if not found yet
	if not dialogue_ui:
		_find_dialogue_ui()
	
	if not dialogue_ui:
		# Error: Could not find dialogue UI
		return
	
	# Set the callback owner for this dialogue
	current_callback_owner = callback_owner
	callback_registry.clear()
	
	# Parse options from the content
	var parser_result = OptionsParser.parse_options(content)
	var options = parser_result.options
	var question_text = parser_result.question_text
	
	# Register callbacks for options that have them
	for option in options:
		if option.has("callback"):
			callback_registry[option.id] = option.callback
	
	# Use the extracted question text, or fall back to original content
	var dialogue_text = question_text
	if dialogue_text == "":
		# No options block found, use entire content
		dialogue_text = content.strip_edges()
	
	# Show the dialogue (fallback if empty)
	if dialogue_text.strip_edges() == "":
		dialogue_text = "..."
	
	dialogue_ui.show_dialogue(speaker_name, dialogue_text)
	
	# Set up options if any exist
	if options.size() > 0:
		# Connect to choice_picked signal if available
		if dialogue_ui and dialogue_ui.has_signal("choice_picked"):
			var signal_obj = dialogue_ui.choice_picked
			if signal_obj and not signal_obj.is_connected(_on_choice_picked):
				signal_obj.connect(_on_choice_picked)

		# Set the options
		if dialogue_ui.has_method("set_options"):
			dialogue_ui.set_options(options)

func _on_choice_picked(choice_id: String) -> void:
	# Check if there's a callback for this choice
	if callback_registry.has(choice_id) and current_callback_owner:
		var callback_name = callback_registry[choice_id]
		if current_callback_owner.has_method(callback_name):
			current_callback_owner.call(callback_name)
		else:
			# Warning: Callback method not found
			pass
	
	choice_picked.emit(choice_id)
