extends Node2D

var projectName : String
var animalName : String

var animal : int = 0

var totalFocusTime : float = 0.0

var complete : bool = false

var dateStarted : String
var dateFinished : String = "N/A"

var colours = []

var part1R : float
var part1G : float
var part1B : float

var part2R : float
var part2G : float
var part2B : float

var part3R : float
var part3G : float
var part3B : float


func setColours() -> void:
	colours.append(Color(part1R, part1G, part1B, 1.0))
	colours.append(Color(part2R, part2G, part2B, 1.0))
	colours.append(Color(part3R, part3G, part3B, 1.0))



func save() -> Dictionary:
	var save_dict = {
		"projectName" : projectName,
		"animalName" : animalName, 
		"animal" : animal,
		"totalFocusTime" : snappedi(totalFocusTime, 0.1),
		"complete" : complete, 
		"dateStarted" : dateStarted,
		"dateFinished" : dateFinished,
		"part1R" : part1R,
		"part1G" : part1G,
		"part1B" : part1B,
		"part2R" : part2R,
		"part2G" : part2G,
		"part2B" : part2B,
		"part3R" : part3R,
		"part3G" : part3G,
		"part3B" : part3B,
	}
	return save_dict
