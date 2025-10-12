extends BaseNPC

var has_introduced: bool = false
var routes_mapped: Array[String] = []
var travel_tips_shared: int = 0

func _ready() -> void:
	super._ready()
	display_name = "Raven Swiftfoot"
	
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
		_show_scouting_dialogue()

func _show_introduction() -> void:
	var dialogue_content = """Raven: Well met, fellow wanderer! I can see the road-dust on your boots and the adventure-gleam in your eyes. Tell me, which paths have you traveled?

What can this scout share with a fellow traveler?
[[OPTIONS]]
[r:routes:_on_routes_callback] What routes do you recommend?
[d:dangers:_on_dangers_callback] What dangers should I know about?
[m:maps:_on_maps_callback] Do you have any maps?
[t:tales:_on_tales_callback] Tell me about your travels.
[[/OPTIONS]]"""
	
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)

func _show_scouting_dialogue() -> void:
	var greeting = "Raven: The roads call to you again! "
	
	if travel_tips_shared > 0:
		greeting += "Have my previous directions served you well? "
	
	var dialogue_content = greeting + """

What intelligence does a fellow scout require?
[[OPTIONS]]
[u:updates:_on_updates_callback] Any new route updates?
[s:shortcuts:_on_shortcuts_callback] Know any shortcuts?
[w:weather:_on_weather_callback] How are the travel conditions?
[f:farewell:_on_farewell_callback] Safe travels to you too.
[[/OPTIONS]]"""
	
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)

func _get_dialogue_system():
	return get_node_or_null("/root/Dialogue")

func _on_routes_callback() -> void:
	routes_mapped.append("main_routes")
	travel_tips_shared += 1
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Raven: The King's Road runs straight and true to the capital - three days of easy walking, with inns every evening. The Forest Path is more dangerous but half the distance if you know the hidden ways. The Mountain Trail is treacherous but leads to rare trading opportunities.")

func _on_dangers_callback() -> void:
	routes_mapped.append("danger_zones")
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Raven: Bandit camps move frequently, but they favor the narrow passes where travelers can't escape. Wolf packs hunt the forest paths during new moon nights. And beware the old bridge near Raven's Crossing - the supports are failing, though locals haven't repaired it yet.")

func _on_maps_callback() -> void:
	routes_mapped.append("detailed_maps")
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Raven: *unfurls a detailed hand-drawn map* These charts show water sources, shelter locations, and current hazard zones. I update them after every scouting run. The red marks indicate recent dangers, green shows safe camping spots. Knowledge shared is survival doubled!")

func _on_tales_callback() -> void:
	travel_tips_shared += 1
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Raven: A good scout reads the land like a book - every broken branch tells a story, every worn stone marks a passage. The wilderness speaks to those who know how to listen. I've walked from the Frozen Peaks to the Desert of Whispers, and each place taught me something new.")

func _on_updates_callback() -> void:
	routes_mapped.append("recent_intelligence")
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Raven: Fresh intelligence from yesterday's patrol: the eastern bridge is out due to storm damage, forcing a detour through Miller's Ford. Merchant caravan spotted three days northeast - good trading opportunity. And strange lights seen near the old ruins after midnight.")

func _on_shortcuts_callback() -> void:
	routes_mapped.append("hidden_paths")
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Raven: *leans in conspiratorially* There's a hunter's trail through Shadowbrook Valley that cuts two days off the mountain route. Steep and narrow, but safe if you're sure-footed. Follow the white stones - I placed them myself as waymarkers.")

func _on_weather_callback() -> void:
	travel_tips_shared += 1
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Raven: Weather's been favorable for travel - clear skies, mild temperatures, roads dry and firm. But I smell rain coming from the west in two days, so plan accordingly. Mountain passes can become deadly during storms - seek shelter before the weather turns.")

func _on_farewell_callback() -> void:
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Raven: May the wind be at your back and the path rise up to meet you! Remember - when in doubt, take the longer but safer route. Dead heroes help no one. Until our paths cross again, fellow wanderer!")

func _on_dialogue_finished() -> void:
	super._on_dialogue_finished()
