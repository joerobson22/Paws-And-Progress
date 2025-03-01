extends Node2D

var time : String = ""

var hours : int = 0
var minutes : int = 0
var seconds : int = 0

var totalSeconds : int = 0

var timing : bool = false



func Stopwatch() -> void:
	await get_tree().create_timer(1.0).timeout
	if timing:
		totalSeconds += 1
		seconds += 1
		if Has_Minute_Passed(seconds):
			get_parent().get_parent().get_parent().Show_Probabilities()
	
	$Label.text = global.Convert_Time(totalSeconds)
	Stopwatch()


func Has_Minute_Passed(seconds : int) -> bool:
	if seconds >= 60:
		seconds = 0
		return true
	return false
