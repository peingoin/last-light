extends BaseNPC

var has_introduced: bool = false
var plant_knowledge_shared: Array[String] = []
var foraging_tips_given: int = 0

func _ready() -> void:
	super._ready()
	display_name = "Sage Greenthumb"
	
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
		_show_foraging_dialogue()

func _show_introduction() -> void:
	var dialogue_content = """Sage: The forest whispers your arrival, traveler. You move like one who respects the wild places - good. Too many stomp through here like they own the woods.

What brings you to seek the forest's wisdom?
[[OPTIONS]]
[p:plants:_on_plants_callback] Tell me about local plants.
[d:dangers:_on_dangers_callback] What should I avoid in the wilderness?
[f:foraging:_on_foraging_callback] Can you teach me to forage?
[r:respect:_on_respect_callback] How should I move through nature?
[[/OPTIONS]]"""
	
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)

func _show_foraging_dialogue() -> void:
	var greeting = "Sage: The woods remember your footsteps. "
	
	if foraging_tips_given > 0:
		greeting += "Have you been practicing what the forest taught you? "
	
	var dialogue_content = greeting + """

What wisdom of the wild do you seek today?
[[OPTIONS]]
[s:seasons:_on_seasons_callback] What changes with the seasons?
[i:ingredients:_on_ingredients_callback] Where can I find rare ingredients?
[a:animals:_on_animals_callback] Tell me about forest creatures.
[l:leave:_on_leave_callback] I should let you return to your work.
[[/OPTIONS]]"""
	
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)

func _get_dialogue_system():
	return get_node_or_null("/root/Dialogue")

func _on_plants_callback() -> void:
	plant_knowledge_shared.append("basic_plants")
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Sage: Each plant has its story, its purpose. The crimson berries by the old oak? Deadly poison. But the silver moss growing beside them? It's the finest antidote you'll ever find. Nature always provides balance, if you know where to look.")

func _on_dangers_callback() -> void:
	plant_knowledge_shared.append("dangerous_plants")
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Sage: The red-spotted mushrooms sing sweet death. Thornvines that move without wind will bind you tight. And beware the flowers that bloom in perfect circles - fairy rings are not meant for mortal feet. The forest tests those who enter unprepared.")

func _on_foraging_callback() -> void:
	foraging_tips_given += 1
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Sage: Foraging is not taking - it's receiving what the forest offers freely. Never harvest more than one in three. Listen to the plant's spirit before you pluck. And always leave an offering - a drop of clean water, a kind word to the soil.")

func _on_respect_callback() -> void:
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Sage: Walk softly, breathe quietly, observe before acting. The forest sees all but judges only those who bring harm. Step on stones rather than moss, follow deer paths instead of forcing your own. Become part of the woods, don't fight against them.")

func _on_seasons_callback() -> void:
	plant_knowledge_shared.append("seasonal_knowledge")
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Sage: Spring brings the healing herbs - young leaves hold the most power. Summer offers fruits and flowers, but watch for territorial birds. Autumn yields nuts and roots, while winter reveals the hidden fungi. Each season has its gifts for those who know when to look.")

func _on_ingredients_callback() -> void:
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Sage: Moonbell flowers bloom only in shadow near running water. Starwhisper moss grows on the north side of the oldest trees. And if you need something truly special, the Crystal Cave holds minerals that sing with ancient power. But such places demand proper respect.")

func _on_animals_callback() -> void:
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Sage: The deer will lead you to fresh water, but never follow them at dusk - that's when they visit the spirit realm. Squirrels chatter warnings of approaching storms. And if you see a white rabbit, follow it - they know secrets paths through the deepest woods.")

func _on_leave_callback() -> void:
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Sage: Go well, nature-friend. Remember the forest's teachings, and may the green paths always lead you home. The woods will remember your kindness.")

func _on_dialogue_finished() -> void:
	super._on_dialogue_finished()