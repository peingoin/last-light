class_name OptionKeymap
extends RefCounted

var key_to_action: Dictionary = {}

func _init(action_mappings: Dictionary = {}):
	key_to_action = action_mappings

func is_action_for_key_pressed(key: String) -> bool:
	var uppercase_key = key.to_upper()
	
	# Check if we have a mapped action for this key
	if key_to_action.has(uppercase_key):
		var action_name = key_to_action[uppercase_key]
		return Input.is_action_just_pressed(action_name)
	
	# Fallback to direct key checking
	return _is_key_just_pressed(uppercase_key)

func _is_key_just_pressed(key: String) -> bool:
	# This method is now deprecated in favor of direct event handling in TextBox
	# But keeping for compatibility if needed
	var key_code = _get_key_code(key)
	if key_code != KEY_NONE:
		return Input.is_physical_key_pressed(key_code)
	
	return false

func _get_key_code(key: String) -> Key:
	match key.to_upper():
		"A": return KEY_A
		"B": return KEY_B
		"C": return KEY_C
		"D": return KEY_D
		"E": return KEY_E
		"F": return KEY_F
		"G": return KEY_G
		"H": return KEY_H
		"I": return KEY_I
		"J": return KEY_J
		"K": return KEY_K
		"L": return KEY_L
		"M": return KEY_M
		"N": return KEY_N
		"O": return KEY_O
		"P": return KEY_P
		"Q": return KEY_Q
		"R": return KEY_R
		"S": return KEY_S
		"T": return KEY_T
		"U": return KEY_U
		"V": return KEY_V
		"W": return KEY_W
		"X": return KEY_X
		"Y": return KEY_Y
		"Z": return KEY_Z
		"0": return KEY_0
		"1": return KEY_1
		"2": return KEY_2
		"3": return KEY_3
		"4": return KEY_4
		"5": return KEY_5
		"6": return KEY_6
		"7": return KEY_7
		"8": return KEY_8
		"9": return KEY_9
		_: return KEY_NONE
