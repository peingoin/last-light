extends Node

# Global scene lifecycle manager for background generation
var _game_scene_instance: Node = null
var _is_ready: bool = false
var _generation_started: bool = false

func _ready() -> void:
	print("[SceneManager] Initialized")
	set_process(false)  # Disabled until generation starts

func start_background_generation() -> void:
	if _generation_started:
		print("[SceneManager] Generation already started, ignoring duplicate call")
		return

	_generation_started = true
	print("[SceneManager] Starting background map generation...")

	# Load and instantiate game scene invisibly
	var game_scene = load("res://scenes/game.tscn")
	_game_scene_instance = game_scene.instantiate()

	# Hide from player and disable processing
	_game_scene_instance.visible = false
	_game_scene_instance.process_mode = Node.PROCESS_MODE_DISABLED

	# Add to scene tree to trigger generation
	get_tree().root.add_child(_game_scene_instance)

	# Wait for game scene ready signal (generation completes in _ready())
	await _game_scene_instance.ready
	_is_ready = true
	print("[SceneManager] Background generation complete! Game ready.")

func is_game_ready() -> bool:
	return _is_ready

func show_game_scene() -> void:
	if not _game_scene_instance or not _is_ready:
		print("[SceneManager] ERROR: Cannot show game - not ready")
		return

	print("[SceneManager] Showing game scene instantly...")

	# Make game visible and enable processing
	_game_scene_instance.visible = true
	_game_scene_instance.process_mode = Node.PROCESS_MODE_INHERIT

	# Remove menu from scene tree
	var menu = get_tree().root.get_node_or_null("Menu")
	if menu:
		menu.queue_free()

	print("[SceneManager] Transition complete!")
