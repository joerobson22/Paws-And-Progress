extends Sprite2D

var probabilities = [0.325, 0.225, 0.45]


func Randomise() -> void:
	var num = global.Generate_Random_Float(0.0, 1.0)
	var total : float = 0.0
	var i : int = 0
	for n in probabilities:
		total += n
		if num <= total:
			break
		i += 1
	$AnimationPlayer.play(type_convert(i + 1, TYPE_STRING))
