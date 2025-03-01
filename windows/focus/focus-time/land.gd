extends Node2D



func Randomise() -> void:
	$Sprites/AnimationPlayer.play("land" + type_convert(global.Generate_Random(1, 2), TYPE_STRING))
