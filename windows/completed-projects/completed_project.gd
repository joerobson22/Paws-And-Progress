extends Node2D

@onready var Label_Name = $Visuals/Labels/Name_Label/Label
@onready var Label_Dates = $Visuals/Labels/Start_To_End_Label/Label
@onready var Label_TotalTime = $Visuals/Labels/Total_Time_Label/Label

@onready var Animal = $Visuals/Animal

var project
var projectNum : int


func _ready() -> void:
	Label_Name.text = project.animalName
	Label_Dates.text = project.dateStarted + " - " + project.dateFinished
	Label_TotalTime.text = global.Convert_Time(project.totalFocusTime)
	
	Animal.get_node("AnimationPlayer").play(global.animals[project.animal])
	$Visuals/AnimationPlayer.play(global.animals[project.animal])
	Animal.get_node("Legs").modulate = project.colours[0]
	Animal.get_node("Body/Part2").modulate = project.colours[1]
	Animal.get_node("Body/Part3").modulate = project.colours[2]
