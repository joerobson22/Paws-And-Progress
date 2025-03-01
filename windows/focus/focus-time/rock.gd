extends Node2D



func Randomise() -> void:
	$Sprites/AnimationPlayer.play("rock" + type_convert(global.Generate_Random(1, 3), TYPE_STRING))
