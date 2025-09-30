extends BaseNPC

var has_introduced: bool = false
var healing_services_used: int = 0
var medical_advice_given: Array[String] = []

func _ready() -> void:
	super._ready()
	display_name = "Dr. Elena Brightwater"
	
	# Ensure NPC cannot move
	set_physics_process(false)
	set_process(false)

func interact(player: Node) -> void:
	if is_talking:
		return
	
	is_talking = true
	
	if animated_sprite and animated_sprite.sprite_frames.has_animation(anim_talk):
		animated_sprite.play(anim_talk)
	
	if not has_introduced:
		_show_introduction()
		has_introduced = true
	else:
		_show_medical_dialogue()

func _show_introduction() -> void:
	var dialogue_content = """Dr. Elena: Ah, another traveler! Let me take a look at you - any wounds that need tending? I've seen too many adventurers ignore small cuts until they become serious infections.

How can I help you today?
[[OPTIONS]]
[h:health:_on_health_callback] I need medical attention.
[a:advice:_on_advice_callback] What health advice do you have?
[l:location:_on_location_callback] Tell me about medical dangers in the area.
[t:thanks:_on_thanks_callback] Thank you, but I'm fine for now.
[[/OPTIONS]]"""
	
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)

func _show_medical_dialogue() -> void:
	var greeting = "Dr. Elena: Good to see you again! "
	
	if healing_services_used > 0:
		greeting += "How are you feeling after the treatment? "
	
	var dialogue_content = greeting + """

What brings you back to my clinic?
[[OPTIONS]]
[h:health:_on_health_callback] I need healing services.
[s:supplies:_on_supplies_callback] Do you have any medical supplies?
[k:knowledge:_on_knowledge_callback] I need medical knowledge.
[g:goodbye:_on_goodbye_callback] Just checking in.
[[/OPTIONS]]"""
	
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)

func _get_dialogue_system():
	return get_node_or_null("/root/Dialogue")

func _on_health_callback() -> void:
	healing_services_used += 1
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Dr. Elena: *examines you carefully* You look to be in good health overall. Here, take this healing salve - apply it to any minor wounds. Remember, rest and proper nutrition are the foundation of good health.")

func _on_advice_callback() -> void:
	medical_advice_given.append("general_health")
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Dr. Elena: In my forty years of practice, I've learned that the best medicine is prevention. A well-fed body and rested mind can fight off most ailments nature throws at us. Drink clean water, avoid questionable berries, and never ignore persistent pain.")

func _on_location_callback() -> void:
	medical_advice_given.append("local_dangers")
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Dr. Elena: The swamp gas to the east can cause breathing problems - cover your nose and mouth if you must go there. Wolf bites are common on the forest paths, and the old ruins have unstable floors that cause many broken bones. Always carry bandages!")

func _on_supplies_callback() -> void:
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Dr. Elena: I keep a good stock of healing herbs and basic medical supplies. Bandages, antiseptic salves, pain-relieving tonics - all the essentials for a traveling adventurer. Prevention is worth a pound of cure!")

func _on_knowledge_callback() -> void:
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Dr. Elena: Medical knowledge is precious - what specifically would you like to know? Wound treatment? Poison identification? Disease symptoms? I've treated everything from common colds to exotic curses in my time.")

func _on_thanks_callback() -> void:
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Dr. Elena: Wise to check in regularly! Remember, your health is your most valuable asset. Don't take unnecessary risks, and come see me if anything seems amiss.")

func _on_goodbye_callback() -> void:
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Dr. Elena: Take care of yourself out there. My clinic is always open for those in need. May your health remain strong on your journeys!")

func _on_dialogue_finished() -> void:
	super._on_dialogue_finished()
