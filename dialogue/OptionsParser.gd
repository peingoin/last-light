class_name OptionsParser
extends RefCounted

static func parse_options(input) -> Dictionary:
	var lines: PackedStringArray
	
	if input is String:
		lines = input.split("\n")
	elif input is PackedStringArray:
		lines = input
	else:
		return {"options": []}
	
	var options: Array[Dictionary] = []
	var start_index: int = -1
	var end_index: int = -1
	var in_options_block: bool = false
	
	for i in range(lines.size()):
		var line = lines[i].strip_edges()
		
		if line == "[[OPTIONS]]":
			if start_index == -1:  # Only process first block
				start_index = i
				in_options_block = true
			continue
		
		if line == "[[/OPTIONS]]":
			if in_options_block:
				end_index = i
				break
		
		if in_options_block and line != "":
			var option = _parse_option_line(line)
			if option.has("key"):
				options.append(option)
			else:
				# Warning: Malformed option line skipped
	
	# Extract question text (everything before the options block)
	var question_text = ""
	if start_index > 0:
		var question_lines = lines.slice(0, start_index)
		question_text = "\n".join(question_lines).strip_edges()
	
	return {
		"options": options,
		"start_index": start_index,
		"end_index": end_index,
		"question_text": question_text
	}

static func _parse_option_line(line: String) -> Dictionary:
	# Use a simpler approach without regex to avoid potential issues
	var trimmed = line.strip_edges()
	
	# Check if line starts with [ and contains ]
	if not trimmed.begins_with("["):
		return {}
	
	var bracket_end = trimmed.find("]")
	if bracket_end == -1:
		return {}
	
	var bracket_content = trimmed.substr(1, bracket_end - 1)
	var colon_pos = bracket_content.find(":")
	if colon_pos == -1:
		return {}
	
	var key = bracket_content.substr(0, colon_pos).strip_edges().to_upper()
	var remaining = bracket_content.substr(colon_pos + 1).strip_edges()
	var text = trimmed.substr(bracket_end + 1).strip_edges()
	
	# Check if remaining part has another colon for callback function
	var second_colon = remaining.find(":")
	var id: String
	var callback: String = ""
	
	if second_colon != -1:
		# Format: [key:id:callback_function] text
		id = remaining.substr(0, second_colon).strip_edges()
		callback = remaining.substr(second_colon + 1).strip_edges()
	else:
		# Format: [key:id] text
		id = remaining
	
	if key.length() == 1 and id != "" and text != "":
		var option = {
			"key": key,
			"id": id,
			"text": text
		}
		if callback != "":
			option["callback"] = callback
		return option
	
	return {}
