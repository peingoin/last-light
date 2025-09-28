extends Node2D

@onready var menu: Control = $Menu
@onready var game: Node2D = $Game

func _ready() -> void:
	# show menu first, hide game
	menu.visible = true
	game.visible = false

	# wire buttons (find by name anywhere under Menu)
	var play_btn: Button = menu.find_child("PlayButton", true, false)
	var quit_btn: Button = menu.find_child("QuitButton", true, false)

	if play_btn:
		play_btn.pressed.connect(_on_play_pressed)
	else:
		push_warning("Couldn't find PlayButton under Menu")

	if quit_btn:
		quit_btn.pressed.connect(_on_quit_pressed)
	else:
		push_warning("Couldn't find QuitButton under Menu")

func _on_play_pressed() -> void:
	menu.visible = false
	game.visible = true

	# If Game has a start method, call it (to spawn player/env)
	if game.has_method("start_game"):
		game.call("start_game")

func _on_quit_pressed() -> void:
	get_tree().quit()
