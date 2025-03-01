extends Node2D


signal pressed


func _on_button_pressed():
	emit_signal("pressed")


func _on_button_mouse_entered():
	$AnimationPlayer.play("in")


func _on_button_mouse_exited():
	$AnimationPlayer.play_backwards("in")
