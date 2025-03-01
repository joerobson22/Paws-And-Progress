extends Node2D



func _ready():
	await get_tree().create_timer(global.Generate_Random_Float(0.1, 1.5)).timeout
	$AnimationPlayer.play(type_convert(global.Generate_Random(1, 5), TYPE_STRING))


func _on_animation_player_animation_finished(anim_name):
	$AnimationPlayer.play(type_convert(global.Generate_Random(1, 5), TYPE_STRING))
