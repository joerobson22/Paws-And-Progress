extends Node2D



func Randomise() -> void:
	var weight : float = global.Generate_Random_Float(0.4, 0.75)
	get_node("Log_Type").play("log" + type_convert(global.Generate_Random(1, 3), TYPE_STRING))
	get_node("AnimationPlayer").speed_scale = (1 - weight) / 2
	await get_tree().create_timer(global.Generate_Random_Float(1.0, 3.0)).timeout
	get_node("AnimationPlayer").play("bob")
