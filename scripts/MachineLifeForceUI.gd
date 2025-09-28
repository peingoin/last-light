extends PanelContainer

@onready var life_force_bar: ProgressBar = $VBoxContainer/LifeForceBar
@onready var life_force_label: Label = $VBoxContainer/LifeForceLabel

var machine: Machine

func _ready() -> void:
	# Find the Machine in the scene
	call_deferred("_find_machine")

func _find_machine() -> void:
	var machines = get_tree().get_nodes_in_group("machine")
	if machines.size() > 0:
		machine = machines[0]
		# Connect to life force changed signal
		if machine.has_signal("life_force_changed"):
			machine.life_force_changed.connect(_on_life_force_changed)
		# Set initial values
		_update_display(machine.current_life_force)

func _on_life_force_changed(new_value: int) -> void:
	_update_display(new_value)

func _update_display(current_life_force: int) -> void:
	if not machine:
		return
	
	if life_force_bar:
		life_force_bar.max_value = machine.max_life_force
		life_force_bar.value = current_life_force
	
	if life_force_label:
		life_force_label.text = "%d / %d" % [current_life_force, machine.max_life_force]