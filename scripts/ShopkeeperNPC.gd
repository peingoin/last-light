extends BaseNPC

var has_bought_item: bool = false
var has_asked_about_town: bool = false

func _ready() -> void:
	super._ready()
	
	# Shopkeeper can be talked to 5 times before getting tired
	max_interactions = 5
	interaction_limit_message = "Shopkeeper: I'm sorry, but I need to help other customers now. Come back later!"
	
	# Connect to choice signals
	var dialogue_system = get_node_or_null("/root/Dialogue")
	if dialogue_system and dialogue_system.has_signal("choice_picked"):
		if not dialogue_system.choice_picked.is_connected(_on_choice_picked):
			dialogue_system.choice_picked.connect(_on_choice_picked)

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
		var dialogue_system = get_node_or_null("/root/Dialogue")
		if dialogue_system and dialogue_system.has_method("open_single"):
			dialogue_system.open_single(display_name, interaction_limit_message)
		return
	
	is_talking = true
	interaction_count += 1
	
	if animated_sprite and animated_sprite.sprite_frames.has_animation(anim_talk):
		animated_sprite.play(anim_talk)
	
	_show_shop_dialogue()

func _show_shop_dialogue() -> void:
	var dialogue_content = """Shopkeeper: Welcome to my humble shop! I have the finest goods in the village.

What brings you to my establishment today?
[[OPTIONS]]
[b:buy] I'd like to buy something.
[s:sell] Do you buy items from travelers?
[i:info] Tell me about this village.
[n:news] Any interesting news lately?
[l:leave] Just browsing, thanks.
[[/OPTIONS]]"""
	
	var dialogue_system = get_node_or_null("/root/Dialogue")
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)

func _on_choice_picked(choice_id: String) -> void:
	var dialogue_system = get_node_or_null("/root/Dialogue")
	if not dialogue_system:
		return
	
	match choice_id:
		"buy":
			if not has_bought_item:
				has_bought_item = true
				_show_buy_dialogue()
			else:
				if dialogue_system.has_method("open_single"):
					dialogue_system.open_single(display_name, "Shopkeeper: You've already made a purchase today. Come back tomorrow for more goods!")
		
		"sell":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Shopkeeper: I do buy certain items, especially rare materials and weapons. What do you have?")
		
		"info":
			if not has_asked_about_town:
				has_asked_about_town = true
				_show_town_info_dialogue()
			else:
				if dialogue_system.has_method("open_single"):
					dialogue_system.open_single(display_name, "Shopkeeper: As I mentioned before, we're a peaceful trading village with good folk.")
		
		"news":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Shopkeeper: I heard the eastern road has been cleared of bandits recently. Good news for trade!")
		
		"leave":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Shopkeeper: Feel free to look around! Let me know if anything catches your eye.")
		
		"sword":
			has_bought_item = true
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Shopkeeper: Excellent choice! This blade will serve you well. That'll be 50 gold pieces.")
		
		"potion":
			has_bought_item = true
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Shopkeeper: A wise purchase! Health potions are essential for any traveler. 15 gold pieces.")
		
		"map":
			has_bought_item = true
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Shopkeeper: This map shows all the safe routes around our region. 10 gold pieces.")
		
		"nothing_buy":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Shopkeeper: No worries at all! Come back when you're ready to make a purchase.")
		
		"history":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Shopkeeper: Our village was founded 200 years ago by traders. We've maintained that tradition of commerce ever since.")
		
		"people":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Shopkeeper: We have farmers, crafters, guards, and traders. Everyone contributes to our community's success.")
		
		"location":
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Shopkeeper: We're perfectly situated between the mountains and the sea, making us ideal for trade routes.")
		
		_:
			print("Warning: Unexpected choice ID received: ", choice_id)
			if dialogue_system.has_method("open_single"):
				dialogue_system.open_single(display_name, "Shopkeeper: I'm not sure I understand what you mean.")

func _show_buy_dialogue() -> void:
	var dialogue_content = """Shopkeeper: Wonderful! I have several items that might interest a traveler like yourself.

What type of item are you looking for?
[[OPTIONS]]
[sword:sword] A sturdy sword (50 gold)
[potion:potion] Health potion (15 gold)
[map:map] Regional map (10 gold)
[nothing_buy:nothing_buy] Actually, nothing right now.
[[/OPTIONS]]"""
	
	var dialogue_system = get_node_or_null("/root/Dialogue")
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)

func _show_town_info_dialogue() -> void:
	var dialogue_content = """Shopkeeper: Ah, you want to know about our village! I've lived here all my life and love sharing our story.

What would you like to know specifically?
[[OPTIONS]]
[history:history] Tell me about the village's history.
[people:people] What kind of people live here?
[location:location] Why was this location chosen?
[[/OPTIONS]]"""
	
	var dialogue_system = get_node_or_null("/root/Dialogue")
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)

func _on_dialogue_finished() -> void:
	super._on_dialogue_finished()