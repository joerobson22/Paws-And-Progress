extends Node2D

@onready var AP = $AnimationPlayer


signal done


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "out":
		emit_signal("done")
