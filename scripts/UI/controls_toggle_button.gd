extends Button

@onready var controls_menu = get_node("../ControlsMenu")

func _on_pressed():
	if controls_menu:
		controls_menu.toggle()
