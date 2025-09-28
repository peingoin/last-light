extends RefCounted
class_name Interactable

# Interactable interface for objects that can be interacted with
# This is a duck-typing interface - objects implement these methods to be interactable

static func can_interact() -> bool:
	# Override in implementing classes
	return false

static func interact_with(player: Node) -> void:
	# Override in implementing classes
	pass