extends BaseNPC

var has_introduced: bool = false
var player_name: String = ""
var player_interests: Array[String] = []
var conversation_history: Dictionary = {}

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
	return dialogue_system

func interact(player: Node) -> void:
	
	if is_talking:
		return
	
	
	# Check interaction limits first
	if max_interactions == 0:
		return
	elif max_interactions > 0 and interaction_count >= max_interactions:
		is_talking = true
		if animated_sprite and animated_sprite.sprite_frames.has_animation(anim_talk):
			animated_sprite.play(anim_talk)
		var dialogue_system = _get_dialogue_system()
		if dialogue_system and dialogue_system.has_method("open_single"):
			dialogue_system.open_single(display_name, interaction_limit_message)
		return
	
	is_talking = true
	interaction_count += 1
	
	if animated_sprite and animated_sprite.sprite_frames.has_animation(anim_talk):
		animated_sprite.play(anim_talk)
	
	# Show different dialogue based on interaction count
	if interaction_count == 1:
		_show_first_meeting()
	else:
		_show_regular_dialogue()

func _show_first_meeting() -> void:
	var dialogue_content = """Villager: Oh, hello there! I don't think we've met before. I'm just a simple villager, but I love meeting new people.

What brings you to our little village today?
[[OPTIONS]]
[h:hello:_on_hello_callback] Hello! I'm just passing through.
[e:explore:_on_explore_callback] I'm here to explore and learn about the area.
[t:trade:_on_trade_callback] I'm looking for trade opportunities.
[q:quiet:_on_quiet_callback] I prefer to keep to myself.
[[/OPTIONS]]"""
	
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)

func _show_regular_dialogue() -> void:
	var greeting = "Villager: Nice to see you again"
	if player_name != "":
		greeting += ", " + player_name
	greeting += "! "
	
	# Add personalized comments based on previous choices
	if "routes" in player_interests:
		greeting += "Still planning those travels? "
	elif "ruins" in player_interests:
		greeting += "Found any interesting artifacts lately? "
	elif "history" in player_interests:
		greeting += "I've been thinking more about our village's past since we last talked. "
	elif "festivals" in player_interests:
		greeting += "The next festival is coming up soon! "
	
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
[w:weather:_on_weather_callback] How's the weather been lately?
[v:village:_on_village_callback] Tell me more about this village.
[p:people:_on_people_callback] Who are the important people around here?
[g:goodbye:_on_goodbye_callback] I should be going now.
[[/OPTIONS]]"""
	
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)

func _on_choice_picked(choice_id: String) -> void:
	# This function now only handles fallback cases since we use specific callbacks
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Villager: I'm sorry, I didn't quite catch that.")

func _show_exploration_dialogue() -> void:
	var dialogue_content = """Villager: An explorer! How adventurous! There are many interesting places around here for someone with a curious spirit.

What kind of exploration interests you most?
[[OPTIONS]]
[r:routes:_on_routes_callback] What are the main travel routes?
[u:ruins:_on_ruins_callback] Are there any ancient ruins nearby?
[d:dangers:_on_dangers_callback] What dangers should I watch out for?
[[/OPTIONS]]"""
	
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)

func _show_village_info_dialogue() -> void:
	var dialogue_content = """Villager: Our village may be small, but it has a rich history and wonderful community spirit!

What aspect of our village would you like to know about?
[[OPTIONS]]
[h:history:_on_history_callback] Tell me about the village's history.
[f:festivals:_on_festivals_callback] Do you have any festivals or celebrations?
[p:problems:_on_problems_callback] Are there any problems in the village?
[[/OPTIONS]]"""
	
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)

func _on_dialogue_finished() -> void:
	super._on_dialogue_finished()

# Callback functions for dialogue options
func _on_hello_callback() -> void:
	player_name = "friendly traveler"
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Villager: Wonderful to meet you, friendly traveler! May the roads be kind to you on your journey.")

func _on_explore_callback() -> void:
	player_name = "curious explorer"
	player_interests.append("exploration")
	_show_exploration_dialogue()

func _on_trade_callback() -> void:
	player_name = "shrewd trader"
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Villager: A trader! How exciting! You should definitely visit our shopkeeper - she has the finest goods in the region. The market square is bustling this time of day!")

func _on_quiet_callback() -> void:
	player_name = "mysterious stranger"
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Villager: I understand completely, mysterious stranger. Sometimes the soul needs silence. Our village is peaceful - perfect for quiet contemplation.")

func _on_village_callback() -> void:
	conversation_history["asked_about_village"] = true
	_show_village_info_dialogue()

func _on_people_callback() -> void:
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Villager: Well, there's our brave village guard who keeps us safe from bandits, the shopkeeper with her amazing wares, and our wise elder who gives the best advice. Each person here has a story worth hearing!")

func _on_goodbye_callback() -> void:
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		var farewell_message = "Villager: Safe travels"
		if player_name != "":
			farewell_message += ", " + player_name
		farewell_message += "! May fortune smile upon your adventures, and don't forget to visit us again!"
		dialogue_system.open_single(display_name, farewell_message)

func _on_routes_callback() -> void:
	player_interests.append("routes")
	conversation_history["asked_about_routes"] = true
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		var routes_response: String
		if conversation_history.get("asked_about_routes", false):
			routes_response = "Villager: Since you're so interested in travel, I should mention that the merchant caravan comes through every month. You could probably join them for safer passage to distant lands!"
		else:
			routes_response = "Villager: The main road leads to the capital city, the forest path goes to the mysterious ancient ruins, and the mountain trail leads to the bustling mining town. Each route has its own adventures!"
		dialogue_system.open_single(display_name, routes_response)

func _on_ruins_callback() -> void:
	player_interests.append("ruins")
	conversation_history["asked_about_ruins"] = true
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		var ruins_response: String
		if conversation_history.get("asked_about_ruins", false):
			ruins_response = "Villager: You know, after our last talk about the ruins, I remembered my grandfather used to tell stories about strange lights coming from there at night. Maybe there's more to them than I thought! Ancient magic, perhaps?"
		else:
			ruins_response = "Villager: The old ruins in the forest are truly mysterious! Some say they're magical, others think they're just really, really old. I've seen strange symbols carved into the stones - nobody knows what they mean!"
		dialogue_system.open_single(display_name, ruins_response)

func _on_dangers_callback() -> void:
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Villager: Watch out for wolves in the deep forest - they hunt in packs at night! Bandits sometimes lurk on the mountain roads, so travel in daylight and stick to well-traveled paths. The old ruins can be treacherous too - unstable floors and hidden pitfalls!")

func _on_history_callback() -> void:
	player_interests.append("history")
	conversation_history["asked_about_history"] = true
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		var history_response: String
		if conversation_history.get("asked_about_history", false):
			history_response = "Villager: I've been digging through some old family records since we talked. Turns out my great-great-grandmother was one of the original founders! I had no idea our family went back that far. She was quite the adventurer herself!"
		else:
			history_response = "Villager: Our village was built near this crossroads because it's perfect for travelers and trade. We've been here for generations! Founded by brave settlers who saw the potential of this location."
		dialogue_system.open_single(display_name, history_response)

func _on_festivals_callback() -> void:
	player_interests.append("festivals")
	conversation_history["asked_about_festivals"] = true
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		var festivals_response: String
		if conversation_history.get("asked_about_festivals", false):
			festivals_response = "Villager: Since you're interested in our festivals, I should tell you that we're planning something special this year! The elder suggested adding a storytelling competition. You should participate if you're still here - I bet you have amazing tales to tell!"
		else:
			festivals_response = "Villager: We have a wonderful harvest festival every autumn! There's music, dancing, and the best food you've ever tasted. The whole village comes together - it's magical!"
		dialogue_system.open_single(display_name, festivals_response)

func _on_problems_callback() -> void:
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Villager: Nothing too serious! Just the occasional wild animal near the farms and some bandits on the outer roads. Our guard handles most threats well. Sometimes merchants are late with deliveries, but that's life in a small village!")

func _on_weather_callback() -> void:
	conversation_history["talked_about_weather"] = true
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		var weather_response: String
		if conversation_history.get("talked_about_weather", false):
			weather_response = "Villager: As I mentioned before, the weather's been lovely. Though I did notice some clouds gathering to the west earlier. Might get some rain tonight - good for the crops!"
		else:
			weather_response = "Villager: The weather's been quite pleasant lately! Perfect for working in the fields and enjoying the outdoors. The sunny days have been wonderful for everyone's spirits."
		dialogue_system.open_single(display_name, weather_response)
