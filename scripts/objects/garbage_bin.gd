extends BaseSpawnableObject

func interact_with(player: Node) -> void:
	if has_been_looted:
		return

	# Generate 6-10 total resources split between wood and steel
	var total_resources = randi_range(6, 10)
	var wood_amount = randi_range(0, total_resources)
	var steel_amount = total_resources - wood_amount

	var loot = {
		"wood": wood_amount,
		"steel": steel_amount
	}

	# Connect to player's resource collection handler
	if not resources_collected.is_connected(player._on_resources_collected):
		resources_collected.connect(player._on_resources_collected)

	resources_collected.emit(loot)
	has_been_looted = true

