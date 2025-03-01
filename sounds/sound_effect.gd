extends Node2D

var effectName : String

func _ready():
	$AnimationPlayer.play(effectName)


func _on_animation_player_animation_finished(anim_name):
	if effectName == "fireplace" or effectName == "daytime_birds" or effectName == "morning_birds" or effectName == "night_ambience" or effectName == "water":
		$AnimationPlayer.play(effectName)
	else:
		$AudioStreamPlayer.playing = false
		queue_free()

func Stop_Playing() -> void:
	queue_free()
