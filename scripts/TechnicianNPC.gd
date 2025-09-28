extends BaseNPC

var has_introduced: bool = false
var calibrations_performed: int = 0
var safety_protocols_shared: Array[String] = []

func _ready() -> void:
	super._ready()
	display_name = "Vera Sparkwire"
	
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
		_show_technical_dialogue()

func _show_introduction() -> void:
	var dialogue_content = """Vera: Hold on there! Before you touch anything, let me check the safety protocols. I've seen too many good tools ruined by hasty hands - and good hands ruined by dangerous tools.

What technical assistance do you require?
[[OPTIONS]]
[c:calibration:_on_calibration_callback] I need equipment calibrated.
[s:safety:_on_safety_callback] What safety measures should I know?
[i:inspection:_on_inspection_callback] Can you inspect my gear?
[t:training:_on_training_callback] I need technical training.
[[/OPTIONS]]"""
	
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)

func _show_technical_dialogue() -> void:
	var greeting = "Vera: Good to see proper safety consciousness! "
	
	if calibrations_performed > 0:
		greeting += "Are your instruments still reading accurately? "
	
	var dialogue_content = greeting + """

What precision work needs attention today?
[[OPTIONS]]
[m:maintenance:_on_maintenance_callback] I need maintenance advice.
[p:precision:_on_precision_callback] How do I improve precision?
[d:diagnostics:_on_diagnostics_callback] Can you run diagnostics?
[g:goodbye:_on_goodbye_callback] Thank you for your expertise.
[[/OPTIONS]]"""
	
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("show_dialogue_with_options"):
		dialogue_system.show_dialogue_with_options(display_name, dialogue_content, self)

func _get_dialogue_system():
	return get_node_or_null("/root/Dialogue")

func _on_calibration_callback() -> void:
	calibrations_performed += 1
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Vera: *carefully adjusts delicate instruments* Calibration requires patience and precision. Temperature affects readings, so we account for ambient conditions. Each measurement verified twice, each adjustment documented. Precision work demands precise methods.")

func _on_safety_callback() -> void:
	safety_protocols_shared.append("general_safety")
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Vera: Safety isn't paranoia - it's professionalism. Always ground yourself before handling sensitive electronics. Never force mechanisms that resist. Check twice, act once. And remember: if something seems dangerous, it probably is. Trust your instincts!")

func _on_inspection_callback() -> void:
	calibrations_performed += 1
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Vera: *examines equipment with a magnifying lens* Inspection reveals stress patterns invisible to casual observation. These micro-fractures indicate overload, this discoloration suggests overheating. Regular inspection prevents catastrophic failure. Prevention beats repair every time.")

func _on_training_callback() -> void:
	safety_protocols_shared.append("training_protocols")
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Vera: Precision isn't about being slow - it's about being deliberate. Every action should have purpose, every movement should have meaning. Master the fundamentals before attempting advanced techniques. Consistent accuracy builds to exceptional precision.")

func _on_maintenance_callback() -> void:
	safety_protocols_shared.append("maintenance_protocols")
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Vera: Maintenance schedules prevent emergencies. Clean contacts weekly, check alignment monthly, full calibration quarterly. Document everything - patterns in maintenance logs reveal developing problems. Systematic care extends equipment lifespan dramatically.")

func _on_precision_callback() -> void:
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Vera: Precision comes from understanding your tools intimately. Environmental factors, operator variables, equipment tolerances - all affect outcomes. Control what you can, compensate for what you can't, and always verify your results through independent methods.")

func _on_diagnostics_callback() -> void:
	calibrations_performed += 1
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Vera: *runs comprehensive diagnostic sequence* All systems operating within acceptable parameters. Signal integrity good, power regulation stable, timing synchronization optimal. I recommend recalibration in two weeks or after 100 hours of operation, whichever comes first.")

func _on_goodbye_callback() -> void:
	var dialogue_system = _get_dialogue_system()
	if dialogue_system and dialogue_system.has_method("open_single"):
		dialogue_system.open_single(display_name, "Vera: Remember the golden rule of technical work: measure twice, cut once. Precision and safety go hand in hand. Come back anytime you need calibration or consultation - quality work requires quality tools!")

func _on_dialogue_finished() -> void:
	super._on_dialogue_finished()