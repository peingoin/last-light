extends BaseNPC

var has_introduced: bool = false
var player_name: String = ""

func _ready() -> void:
	super._ready()
	
	# Set interaction limits for testing
	max_interactions = 4
	interaction_limit_message = "Villager: I really must get back to my work now. Perhaps we can chat again later!"
	
	# Connect to choice signals
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_signal("choice_picked"):
		if not dialogue_system.choice_picked.is_connected(_on_choice_picked):
			dialogue_system.choice_picked.connect(_on_choice_picked)

func _get_dialogue_system():
	var dialogue_system = get_node_or_null("/root/Dialogue")
	print("TestNPC: _get_dialogue_system() returning: ", dialogue_system)
	return dialogue_system

func interact(player: Node) -> void:
	print("TestNPC: interact() called with player: ", player)
	
	if is_talking:
		print("TestNPC: Already talking, returning")
		return
	
	print("TestNPC: max_interactions=", max_interactions, " interaction_count=", interaction_count)
	
	# Check interaction limits first
	if max_interactions == 0:
		print("TestNPC: max_interactions is 0, no interactions allowed")
		return
	elif max_interactions > 0 and interaction_count >= max_interactions:
		print("TestNPC: Reached interaction limit")
		is_talking = true
		if animated_sprite and animated_sprite.sprite_frames.has_animation(anim_talk):
			animated_sprite.play(anim_talk)
		var dialogue_system = _get_dialogue_system()
		if dialogue_system and dialogue_system.has_method("open_single"):
			dialogue_system.open_single(display_name, interaction_limit_message)
		return
	
	print("TestNPC: Starting interaction ", interaction_count + 1)
	is_talking = true
	interaction_count += 1
	
	if animated_sprite and animated_sprite.sprite_frames.has_animation(anim_talk):
		animated_sprite.play(anim_talk)
	
	# Show different dialogue based on interaction count
	if interaction_count == 1:
		print("TestNPC: Showing first meeting dialogue")
		_show_first_meeting()
	else:
		print("TestNPC: Showing regular dialogue")
		_show_regular_dialogue()

func _show_first_meeting() -> void:
	var dialogue_content = """Villager: Oh, hello there! I don't think we've met before. I'm just a simple villager, but I love meeting new people.

What brings you to our little village today?
[[OPTIONS]]
[h:hello:_on_hello_callback] Hello! I'm just passing through.
[e:explore:_on_explore_callback] I'm here to explore and learn about the area.
[t:trade] I'm looking for trade opportunities.
[q:quiet] I prefer to keep to myself.
[[/OPTIONS]]"""
	
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)

func _show_regular_dialogue() -> void:
	var greeting = "Villager: Nice to see you again"
	if player_name != "":
		greeting += ", " + player_name
	greeting += "! "
	
	var remaining = get_remaining_interactions()
	if remaining == 1:
		greeting += "I have time for one more quick chat."
	elif remaining == 2:
		greeting += "I still have a little time to talk."
	else:
		greeting += "What can I help you with?"
	
	var dialogue_content = greeting + """

What would you like to talk about?
[[OPTIONS]]
[w:weather] How's the weather been lately?
[v:village] Tell me more about this village.
[p:people] Who are the important people around here?
[g:goodbye] I should be going now.
[[/OPTIONS]]"""
	
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)

func _on_choice_picked(choice_id: String) -> void:
	var dialogue_system = _get_dialogue_system()
	if not dialogue_system:
		return
	
	match choice_id:
		"hello":
			player_name = "friend"
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Villager: Wonderful to meet you, friend! I hope you enjoy your time here.")
		
		"explore":
			player_name = "explorer"
			_show_exploration_dialogue()
		
		"trade":
			player_name = "trader"
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Villager: A trader! How exciting! You should definitely visit our shopkeeper and the market square.")
		
		"quiet":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Villager: I understand completely. Sometimes it's nice to just enjoy the peace and quiet of our village.")
		
		"weather":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Villager: The weather's been quite pleasant lately! Perfect for working in the fields and enjoying the outdoors.")
		
		"village":
			_show_village_info_dialogue()
		
		"people":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Villager: Well, there's our village guard who keeps us safe, the shopkeeper with the finest goods, and our wise elder who gives great advice.")
		
		"goodbye":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Villager: Safe travels! Come back and visit us again soon.")
		
		"history":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Villager: Our village was built near this crossroads because it's perfect for travelers and trade. We've been here for generations!")
		
		"festivals":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Villager: We have a harvest festival every autumn! There's music, dancing, and the best food you've ever tasted.")
		
		"problems":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Villager: Mostly just the occasional wild animal or bandit on the roads. Nothing our guard can't handle!")
		
		"routes":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Villager: The main road leads to the capital, the forest path goes to the ancient ruins, and the mountain trail leads to the mining town.")
		
		"ruins":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Villager: The old ruins in the forest are mysterious. Some say they're magical, but I think they're just really, really old!")
		
		"dangers":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Villager: Watch out for wolves in the forest and bandits on the mountain roads. Stick to the main paths during daylight.")
		
		_:
			print("Warning: Unexpected choice ID received: ", choice_id)
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Villager: I'm sorry, I didn't quite catch that.")

func _show_exploration_dialogue() -> void:
	var dialogue_content = """Villager: An explorer! How adventurous! There are many interesting places around here for someone with a curious spirit.

What kind of exploration interests you most?
[[OPTIONS]]
[routes:routes:_on_routes_callback] What are the main travel routes?
[ruins:ruins:_on_ruins_callback] Are there any ancient ruins nearby?
[dangers:dangers] What dangers should I watch out for?
[[/OPTIONS]]"""
	
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)

func _show_village_info_dialogue() -> void:
	var dialogue_content = """Villager: Our village may be small, but it has a rich history and wonderful community spirit!

What aspect of our village would you like to know about?
[[OPTIONS]]
[history:history:_on_history_callback] Tell me about the village's history.
[festivals:festivals:_on_festivals_callback] Do you have any festivals or celebrations?
[problems:problems] Are there any problems in the village?
[[/OPTIONS]]"""
	
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)

func _on_dialogue_finished() -> void:
	super._on_dialogue_finished()

# Callback functions for dialogue options
func _on_hello_callback() -> void:
	print("TestNPC: Hello callback triggered!")
	# Add some special behavior when hello is chosen
	player_name = "friendly traveler"

func _on_explore_callback() -> void:
	print("TestNPC: Explore callback triggered!")
	# Add some special behavior when explore is chosen
	player_name = "curious explorer"
	# Could add items, unlock new dialogue options, etc.

func _on_routes_callback() -> void:
	print("TestNPC: Routes callback triggered! Player is interested in travel routes.")
	# Could unlock a map item, mark routes on player's map, etc.

func _on_ruins_callback() -> void:
	print("TestNPC: Ruins callback triggered! Player is interested in ancient ruins.")
	# Could give a quest, unlock ruins location, provide ancient knowledge, etc.

func _on_history_callback() -> void:
	print("TestNPC: History callback triggered! Player wants to learn village history.")
	# Could increase reputation, unlock historical quests, etc.

func _on_festivals_callback() -> void:
	print("TestNPC: Festivals callback triggered! Player is interested in celebrations.")
	# Could unlock seasonal events, provide festival schedule, etc.