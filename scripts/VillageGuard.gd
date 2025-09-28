extends BaseNPC

var has_pass: bool = false
var dialogue_state: String = "initial"

# Add test flag for edge case testing
@export var test_malformed_syntax: bool = false

func _ready() -> void:
	super._ready()
	
	# Set interaction limits for the guard (can only talk 3 times)
	max_interactions = 3
	interaction_limit_message = "Guard: I've told you everything I can. Please move along."
	
	# Connect to choice signals
	var dialogue_system = get_node_or_null("/root/Dialogue")
	if dialogue_system and dialogue_system.has_signal("choice_picked"):
		if not dialogue_system.choice_picked.is_connected(_on_choice_picked):
			dialogue_system.choice_picked.connect(_on_choice_picked)

func interact(_player: Node) -> void:
	if is_talking:
		return
	
	is_talking = true
	
	if animated_sprite and animated_sprite.sprite_frames.has_animation(anim_talk):
		animated_sprite.play(anim_talk)
	
	_show_dialogue_based_on_state()

func _show_dialogue_based_on_state() -> void:
	match dialogue_state:
		"initial":
			_show_initial_dialogue()
		"has_pass":
			_show_pass_dialogue()
		"no_pass":
			_show_no_pass_dialogue()

func _show_initial_dialogue() -> void:
	var dialogue_content: String
	
	if test_malformed_syntax:
		# Test malformed syntax handling
		dialogue_content = """Guard: Testing malformed syntax...
[[OPTIONS]]
[y:yes] Valid option.
malformed line without brackets
[invalid] Missing colon
[::empty] Double colon
[] Empty brackets
[a:] Missing text
[:missing_key] Missing key
[[/OPTIONS]]"""
	else:
		# Normal dialogue
		dialogue_content = """Guard: Halt! Do you have a pass to enter the village?
[[OPTIONS]]
[y:yes] Yes, here's my pass.
[n:no] No, I don't have one.
[l:lie] I lost it on the way here.
[[/OPTIONS]]"""
	
	var dialogue_system = get_node_or_null("/root/Dialogue")
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)
	else:
		print("Error: Dialogue system not found!")

func _show_pass_dialogue() -> void:
	var dialogue_content = """Guard: Your pass looks good. Welcome to the village!

What would you like to know about our town?
[[OPTIONS]]
[t:thanks] Thank you for your help!
[q:question] What should I watch out for?
[d:directions] Where can I find supplies?
[l:leave] I'll be on my way now.
[[/OPTIONS]]"""
	
	var dialogue_system = get_node_or_null("/root/Dialogue")
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)
	else:
		print("Error: Dialogue system not found!")

func _show_no_pass_dialogue() -> void:
	var dialogue_content = """Guard: I'm sorry, but you'll need a pass to enter. The village has strict security measures.

How would you like to proceed?
[[OPTIONS]]
[o:ok] Okay, I'll go find a pass.
[p:plead] Please, I really need to get in!
[w:where] Where can I get a pass?
[r:rules] Why do you need passes?
[[/OPTIONS]]"""
	
	var dialogue_system = get_node_or_null("/root/Dialogue")
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)
	else:
		print("Error: Dialogue system not found!")

func _on_choice_picked(choice_id: String) -> void:
	var dialogue_system = get_node_or_null("/root/Dialogue")
	if not dialogue_system:
		return
	
	match choice_id:
		"yes":
			if has_pass:
				dialogue_state = "has_pass"
				if dialogue_system.has_method("open_single"):
					dialogue_system.open_single(display_name, "Guard: Perfect! Your pass checks out.")
			else:
				dialogue_state = "no_pass"
				if dialogue_system.has_method("open_single"):
					dialogue_system.open_single(display_name, "Guard: I don't see any pass. You'll need to get one first.")
		
		"no":
			dialogue_state = "no_pass"
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Guard: Then I can't let you through, I'm afraid.")
		
		"lie":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Guard: That's unfortunate. You'll need to get a replacement from the merchant.")
		
		"thanks":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Guard: You're welcome, traveler! Stay safe out there.")
		
		"question":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Guard: Watch out for zombies at night, and visit the inn if you need rest.")
		
		"directions":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Guard: The general store is on Main Street, and the blacksmith is near the town square.")
		
		"leave":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Guard: Safe travels, and welcome to our village!")
		
		"ok":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Guard: The merchant is usually found near the eastern gate. Good luck!")
		
		"plead":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Guard: I wish I could help, but rules are rules. The safety of our citizens comes first.")
		
		"where":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Guard: You can get a pass from the merchant outside the eastern gate, or from the mayor's office.")
		
		"rules":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Guard: We've had trouble with bandits recently. Passes help us keep track of who enters the village.")
		
		_:
			# Handle unexpected choice IDs gracefully
			print("Warning: Unexpected choice ID received: ", choice_id)
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Guard: I didn't quite understand that.")

func _on_dialogue_finished() -> void:
	super._on_dialogue_finished()
	# Reset dialogue state after conversation ends
	dialogue_state = "initial"
