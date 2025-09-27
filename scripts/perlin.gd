extends Node2D

var map_width = 256
var map_height 128
var noise_scale = 0.1

var deepwater_threshold = 0.4

func generate_map():
	var noise = FastNoiseLite.new()
	print(noise)


func _ready() -> void:
	generate_map()

	
	
func _process(delta: float) -> void:
