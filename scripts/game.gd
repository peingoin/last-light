extends Node2D

@onready var player = $Player
@onready var health_bar = $"CanvasLayer/UI Control/HealthBar"
@onready var wood_label = $"CanvasLayer/UI Control/HealthBar/Wood Indicator Control/Wood Label"
@onready var metal_label = $"CanvasLayer/UI Control/HealthBar/Metal Indicator Control/Metal Label"

func _ready():
	# Initialize health bar with player's max health
	health_bar.init_health(player.player_health)
	
	# Connect to player's health changes
	player.connect("health_changed", _on_player_health_changed)

func _on_player_health_changed(new_health):
	health_bar.health = new_health

func set_wood_count(amount: int):
	wood_label.text = str(amount)

func set_metal_count(amount: int):
	metal_label.text = str(amount)

func add_wood(amount: int):
	var current_wood = int(wood_label.text)
	set_wood_count(current_wood + amount)

func add_metal(amount: int):
	var current_metal = int(metal_label.text)
	set_metal_count(current_metal + amount)
