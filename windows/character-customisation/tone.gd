extends Node2D

var customising : int 

var mouse_in : bool = false
var toneNumber : int

signal updateHuman




func _on_control_mouse_entered() -> void:
	mouse_in = true
	$AnimationPlayer.play("in")


func _on_control_mouse_exited() -> void:
	mouse_in = false
	$AnimationPlayer.play_backwards("in")


func _on_button_pressed():
	sounds.Make_Sound_Effect("button_click1")
	if customising == 0:
		global.skinColour = toneNumber
	elif customising == 1:
		global.hairColour = toneNumber
	emit_signal("updateHuman")
