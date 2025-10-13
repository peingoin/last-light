extends Control

signal choice_picked(id: String)

@onready var speaker_label: Label = $MarginContainer/VBoxContainer/Label
@onready var content_label: RichTextLabel = $MarginContainer/VBoxContainer/RichTextLabel
@onready var text_audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var skip_label: Label = $MarginContainer/SkipLabel
@onready var options_list: VBoxContainer

@export var advance_allowed_with_options := false

var full_text: String = ""
var text_chunks: PackedStringArray = []
var current_chunk_index: int = 0
var current_chunk_text: String = ""
var is_typing: bool = false
var can_skip: bool = false
var text_queue: Array[Dictionary] = []
var is_dialogue_active: bool = false

var current_options: Array[Dictionary] = []
var current_keymap: OptionKeymap = null

func _ready() -> void:
	# Make the textbox clickable
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Ensure content label has proper wrapping
	if content_label:
		content_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content_label.fit_content = true
	
	# Create options list container if it doesn't exist
	_ensure_options_list()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_on_textbox_clicked()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	# Check for X key to exit dialogue
	if event is InputEventKey and event.pressed:
		var pressed_key = ""
		if event.keycode != 0:
			pressed_key = OS.get_keycode_string(event.keycode).to_upper()
		elif event.physical_keycode != 0:
			pressed_key = OS.get_keycode_string(event.physical_keycode).to_upper()

		if pressed_key == "X":
			# Exit dialogue immediately
			hide_dialogue()
			return

	# Handle option selection if options are present
	if current_options.size() > 0:
		# Check for key presses using InputEventKey directly
		if event is InputEventKey and event.pressed:
			# Use physical_keycode for more reliable key detection
			var pressed_key = ""
			if event.keycode != 0:
				pressed_key = OS.get_keycode_string(event.keycode).to_upper()
			elif event.physical_keycode != 0:
				pressed_key = OS.get_keycode_string(event.physical_keycode).to_upper()

			if pressed_key != "":
				for option in current_options:
					var option_key = option.key.to_upper()
					if pressed_key == option_key:
						choice_picked.emit(option.id)
						_clear_options()
						return

		# Block interaction advance if options are present and advance_allowed_with_options is false
		if not advance_allowed_with_options:
			return

	if event.is_action_pressed("interact"):
		_on_textbox_clicked()
		get_viewport().set_input_as_handled()

func show_dialogue(speaker_name: String, content: String) -> void:
	if content.strip_edges() == "":
		return  # Don't show empty dialogue

	if is_dialogue_active:
		# Queue the dialogue if one is already active
		text_queue.append({"speaker": speaker_name, "content": content})
		return

	is_dialogue_active = true
	speaker_label.text = speaker_name
	full_text = content

	# Split text into 2-line chunks
	text_chunks = _split_text_into_chunks(content)
	current_chunk_index = 0

	visible = true
	if skip_label:
		skip_label.visible = true
	_show_current_chunk()

func addText(speaker_name: String, content: String) -> void:
	if content.strip_edges() == "":
		return  # Don't add empty text
		
	if is_dialogue_active:
		# Queue the dialogue
		text_queue.append({"speaker": speaker_name, "content": content})
	else:
		# Show immediately if no dialogue is active
		show_dialogue(speaker_name, content)

func _split_text_into_chunks(text: String) -> PackedStringArray:
	var chunks: PackedStringArray = []
	var words = text.split(" ")
	var current_chunk = ""
	var current_line = ""
	var line_count = 0
	var max_chars_per_line = 45  # Approximate based on font size and container width
	
	for word in words:
		var test_line = current_line
		if test_line != "":
			test_line += " "
		test_line += word
		
		# Check if adding this word would exceed line width
		if test_line.length() > max_chars_per_line:
			# Finish current line and start new one
			if current_chunk != "":
				current_chunk += "\n"
			current_chunk += current_line
			line_count += 1
			
			# If we've reached 2 lines, start a new chunk
			if line_count >= 2:
				chunks.append(current_chunk.strip_edges())
				current_chunk = ""
				line_count = 0
			
			current_line = word
		else:
			current_line = test_line
	
	# Add remaining line to current chunk
	if current_line != "":
		if current_chunk != "":
			current_chunk += "\n"
		current_chunk += current_line
	
	# Add the last chunk if it's not empty
	if current_chunk.strip_edges() != "":
		chunks.append(current_chunk.strip_edges())
	
	return chunks

func _show_current_chunk() -> void:
	if current_chunk_index >= text_chunks.size():
		_finish_dialogue()
		return

	current_chunk_text = text_chunks[current_chunk_index]
	content_label.text = ""
	can_skip = true
	is_typing = false
	if skip_label:
		skip_label.visible = true

	type_text()

func type_text() -> void:
	if is_typing:
		return
		
	is_typing = true
	
	# Start playing text sound
	if text_audio and not text_audio.playing:
		text_audio.play()
	
	var chars_per_second = 70.0
	var delay = 1.0 / chars_per_second
	
	for i in range(current_chunk_text.length()):
		if not visible or not is_typing:
			break
		content_label.text = current_chunk_text.left(i + 1)
		
		# Restart sound if it finished
		if text_audio and not text_audio.playing:
			text_audio.play()
			
		await get_tree().create_timer(delay).timeout
	
	is_typing = false
	
	# Stop the text sound when typing is done
	if text_audio:
		text_audio.stop()

func _on_textbox_clicked() -> void:
	if not visible:
		return

	# Prevent any skipping if options are present
	if current_options.size() > 0:
		return

	if is_typing:
		# Skip typing animation for current chunk
		content_label.text = current_chunk_text
		is_typing = false
		if text_audio:
			text_audio.stop()
	else:
		# Move to next chunk or finish dialogue
		current_chunk_index += 1
		if current_chunk_index < text_chunks.size():
			_show_current_chunk()
		else:
			_finish_dialogue()

func _finish_dialogue() -> void:
	is_dialogue_active = false

	# Check if there are queued dialogues
	if text_queue.size() > 0:
		var next_dialogue = text_queue.pop_front()
		show_dialogue(next_dialogue.speaker, next_dialogue.content)
	else:
		hide_dialogue()
		# Emit dialogue_finished signal through the global Dialogue system
		if has_node("/root/Dialogue"):
			var dialogue = get_node("/root/Dialogue")
			if dialogue.has_signal("dialogue_finished"):
				dialogue.dialogue_finished.emit()

func hide_dialogue() -> void:
	visible = false
	is_typing = false
	can_skip = false
	is_dialogue_active = false
	current_chunk_index = 0
	text_chunks.clear()
	text_queue.clear()
	_clear_options()
	if skip_label:
		skip_label.visible = false
	if text_audio:
		text_audio.stop()

	# Notify the Dialogue system that dialogue has ended
	# This ensures the player's is_talking flag is reset
	var dialogue_system = get_node_or_null("/root/Dialogue")
	if dialogue_system and dialogue_system.has_signal("dialogue_finished"):
		dialogue_system.dialogue_finished.emit()

func set_options(options: Array, keymap: OptionKeymap = null) -> void:
	# Validate options array
	var valid_options: Array[Dictionary] = []
	for option in options:
		if option is Dictionary and option.has("key") and option.has("id") and option.has("text"):
			if option.key != "" and option.id != "" and option.text != "":
				valid_options.append(option)
			else:
				pass
		else:
			pass
	
	current_options = valid_options
	current_keymap = keymap
	_render_options()

func _ensure_options_list() -> void:
	if not options_list:
		options_list = $MarginContainer/VBoxContainer.get_node_or_null("OptionsList")
		if not options_list:
			options_list = VBoxContainer.new()
			options_list.name = "OptionsList"
			$MarginContainer/VBoxContainer.add_child(options_list)

func _render_options() -> void:
	_ensure_options_list()
	_clear_options_ui()
	
	for option in current_options:
		var label = Label.new()
		label.text = "%s) %s" % [option.key, option.text]
		# Copy font settings from content_label
		if content_label.get_theme_font("font"):
			label.add_theme_font_override("font", content_label.get_theme_font("font"))
		if content_label.get_theme_font_size("font_size") > 0:
			label.add_theme_font_size_override("font_size", content_label.get_theme_font_size("font_size"))
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		options_list.add_child(label)

func _clear_options_ui() -> void:
	if options_list:
		for child in options_list.get_children():
			child.queue_free()

func _clear_options() -> void:
	current_options.clear()
	current_keymap = null
	_clear_options_ui()
