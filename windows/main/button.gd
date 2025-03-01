extends Node2D

var scalingFactor : float = 1.2

func _on_button_mouse_entered() -> void:
	get_node("Sprite2D").scale.x *= scalingFactor
	get_node("Sprite2D").scale.y *= scalingFactor


func _on_button_mouse_exited() -> void:
	get_node("Sprite2D").scale.x /= scalingFactor
	get_node("Sprite2D").scale.y /= scalingFactor
