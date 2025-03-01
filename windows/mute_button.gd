extends Node2D


func _ready():
	if global.audioMuted:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
		$Sprites/Icon.frame = 1
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		$Sprites/Icon.frame = 0

func _on_check_button_mouse_entered():
	$AnimationPlayer.play("in")


func _on_check_button_mouse_exited():
	$AnimationPlayer.play_backwards("in")


func _on_check_button_pressed():
	global.audioMuted = !global.audioMuted
	_ready()
