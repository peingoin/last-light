extends BaseNPC

var has_introduced: bool = false
var projects_discussed: Array[String] = []
var repairs_completed: int = 0

func _ready() -> void:
	super._ready()
	display_name = "Marcus Gearwright"
	
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
		_show_engineering_dialogue()

func _show_introduction() -> void:
	var dialogue_content = """Marcus: Excellent! A new problem to solve. I see you're carrying some interesting equipment there - proper maintenance is crucial for any successful expedition.

What engineering challenge brings you to my workshop?
[[OPTIONS]]
[e:equipment:_on_equipment_callback] Can you check my equipment?
[p:projects:_on_projects_callback] What are you working on?
[k:knowledge:_on_knowledge_callback] I need engineering advice.
[m:mechanical:_on_mechanical_callback] Tell me about local machinery.
[[/OPTIONS]]"""
	
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)

func _show_engineering_dialogue() -> void:
	var greeting = "Marcus: Back for more engineering wisdom? "
	
	if repairs_completed > 0:
		greeting += "How is that equipment performing? "
	
	var dialogue_content = greeting + """

What technical challenge can I help you solve today?
[[OPTIONS]]
[u:upgrade:_on_upgrade_callback] Can you upgrade my gear?
[r:repair:_on_repair_callback] I need something repaired.
[d:design:_on_design_callback] I need help with a design.
[f:farewell:_on_farewell_callback] Just wanted to check your progress.
[[/OPTIONS]]"""
	
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)

func _get_dialogue_system():
	return get_node_or_null("/root/Dialogue")

func _on_equipment_callback() -> void:
	repairs_completed += 1
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Marcus: *adjusts spectacles and examines your gear* Interesting craftsmanship! The joints need lubrication, and I see some stress fractures forming here. Let me apply some reinforcement - proper maintenance prevents catastrophic failure.")

func _on_projects_callback() -> void:
	projects_discussed.append("current_projects")
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Marcus: Currently designing an improved water wheel for the mill - efficiency is down 12% due to suboptimal blade angles. Also working on a new bridge support system that can handle both foot traffic and heavy cargo wagons. Engineering is about finding elegant solutions to complex problems!")

func _on_knowledge_callback() -> void:
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Marcus: People think engineering is just gears and springs, but it's really about understanding how forces flow. Once you see the patterns, everything becomes elegantly simple. Force, leverage, efficiency - these principles govern everything from clockwork to castle construction.")

func _on_mechanical_callback() -> void:
	projects_discussed.append("local_machinery")
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Marcus: The old ruins have fascinating mechanical puzzles - ancient gear systems that still function after centuries! The village mill uses my improved gear ratios, and I'm particularly proud of the new windlass system at the well. Every mechanism tells a story of human ingenuity.")

func _on_upgrade_callback() -> void:
	repairs_completed += 1
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Marcus: Upgrades require careful analysis of stress points and usage patterns. I can reinforce weak components, improve efficiency ratios, and add redundant safety systems. Good engineering anticipates failure and plans accordingly. What specific improvements are you seeking?")

func _on_repair_callback() -> void:
	repairs_completed += 1
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Marcus: Repair work is detective work - finding the root cause, not just treating symptoms. Metal fatigue? Poor lubrication? Design flaw? I'll analyze the failure pattern and implement a solution that prevents recurrence. Proper diagnosis saves time and materials.")

func _on_design_callback() -> void:
	projects_discussed.append("design_consultation")
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Marcus: Design challenges are my favorite! Define the problem precisely, identify all constraints, then iterate solutions. Form follows function, but good engineering makes function elegant. What kind of mechanism are you envisioning?")

func _on_farewell_callback() -> void:
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Marcus: Progress is steady! Three new innovations this week, and zero catastrophic failures. Remember, good engineering is invisible - it just works reliably. Come back anytime you need technical consultation!")

func _on_dialogue_finished() -> void:
	super._on_dialogue_finished()