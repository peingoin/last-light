extends Control

func _ready():
	hide()

func _input(event):
	if event.is_action_pressed("ui_cancel") and visible:
		hide()
		get_viewport().set_input_as_handled()

func toggle():
	visible = !visible

func _on_close_button_pressed():
	hide()
