extends Node2D

@onready var Label_Title = $Labels/Title_Label/Label
@onready var Label_Total_Time = $Labels/Total_Time_Label/Label
@onready var Label_YouReceived = $Gift/You_Received_Label/Label
@onready var Label_Gift = $Gift/Gift_Label/Label
@onready var Gift = $Gift/Gift

@onready var Button_MainMenu = $Buttons/Main_Menu_Button
@onready var Button_Complete = $Buttons/Complete_Button

var rarities = ["common", "rare", "epic"]

var focusTime : float
var focus : int
var totalTimeString : String
var gift : int
var giftNum : int
var giftName : String
var animal : int

var mouse_in : int = 0

signal die_parent

func Focus_Ended() -> void:
	#process data and give gift
	Process_Data()

#function that stores all data passed
func Process_Data() -> void:
	if global.testing:
		focusTime = 1801
	#increase total focus time
	global.totalFocusTime += focusTime
	global.weeklyFocusTotal += focusTime
	global.dailyFocusTotal += focusTime
	#increase total project focus time
	global.projects[focus].totalFocusTime += focusTime
	
	if global.longestFocusTime < focusTime:
		global.longestFocusTime = focusTime
	
	global.thisWeekDailyTotals[global.timeDict.weekday] = global.dailyFocusTotal
	
	#give random gift
	Give_Gift()

func Display() -> void:
	#display total time
	var n = global.Generate_Random(0, 3)
	if n == 0:
		Label_Total_Time.text = "Total Focus Time: " + totalTimeString
	elif n == 1:
		Label_Total_Time.text = "Spent the last " + totalTimeString + " working on " + global.projects[focus].projectName
	elif n == 2:
		Label_Total_Time.text = totalTimeString + " spent working on " + global.projects[focus].projectName
	elif n == 3:
		Label_Total_Time.text = "Spent " + totalTimeString + " walking " + global.projects[focus].animalName
	#display gift received
	if giftNum > -1:
		#first find out gift name
		var animalName : String = global.animals[animal]
		giftName = global.animalGifts[animalName][giftNum]
		#display
		n = global.Generate_Random(0, 1)
		if n == 0:
			Label_YouReceived.text = "You Received A..."
		elif n == 1:
			Label_YouReceived.text = global.projects[focus].animalName + " Gave You A..."
		Label_Gift.text = giftName + "!"
		
		Gift.frame = gift
		$Gift/Shine.show()
		$Gift/Gift.show()
		$Gift/Shine/AnimationPlayer2.play(rarities[giftNum])
		$Gift/Shine/AnimationPlayer.play("wiggle")
	else:
		Label_YouReceived.text = "Focus Time not enough to receive a gift!"
		Label_Gift.text = "Focus for more than 10 mins to receive a gift!"
		$Gift/Shine.hide()
		$Gift/Gift.hide()

#function for giving a gift
func Give_Gift() -> void:
	var probabilities = [0, 0, 0]
	#generate random number, probabilities of each gift dependent on how long they focussed for
	var thresholds = [600, 1800, 3600, 5400, 7200, 9000, 10800, 14400, 18000, 21600]
	#loop through thresholds to identify which one it is less than
	#set probabilities to be that one
	for n in thresholds:
		if focusTime < n:
			var c : int = 0
			for i in global.giftProbabilities[n]:
				probabilities[c] = i
				c += 1
			break
	
	#print(type_convert(probabilities, TYPE_STRING))
	
	
	if focusTime > thresholds[0]:
		#generate random number
		var num : int = global.Generate_Random(0, 100)
		#print(type_convert(num, TYPE_STRING))
		var total : int = 0
		giftNum = 0
		
		for i in probabilities:
			total += i
			if num <= total:
				break
			giftNum += 1
		
		gift = (animal * 3) + giftNum
		
		global.gifts[gift] += 1
	else:
		giftNum = -1
	
	#save data
	save.save_data()
	
	#display total time and gift
	Display()



#function for pressing 'complete' button
func Project_Complete() -> void:
	sounds.Make_Sound_Effect("project_complete")
	#set project to complete
	#set to complete
	global.projects[focus].complete = true
	
	var date = Time.get_datetime_dict_from_system()
	global.projects[focus].dateFinished = type_convert(date.day, TYPE_STRING) + "/" + type_convert(date.month, TYPE_STRING) + "/" + type_convert(date.year, TYPE_STRING)
	
	#move the project into the completed projects array
	global.completedProjects.append(global.projects[focus])
	global.projects.remove_at(focus)
	#update pointers
	global.totalCompletedProjects += 1
	global.totalCurrentProjects -= 1
	
	#cutscene
	
	#return to main menu
	emit_signal("die_parent")


func _input(event: InputEvent) -> void:
	#if clicked an arrow, scroll in that direction
	#then update the human's appearance 
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and mouse_in > 0:
		if mouse_in == 1:
			#main menu
			Main_Menu()
		elif mouse_in == 2:
			#project complete
			Project_Complete()


func Main_Menu() -> void:
	sounds.Make_Sound_Effect("button_click3")
	emit_signal("die_parent")


func complete_mouse_entered() -> void:
	mouse_in = 2
	Button_Complete.get_node("AnimationPlayer").play("in")


func complete_mouse_exited() -> void:
	mouse_in = 0
	Button_Complete.get_node("AnimationPlayer").play_backwards("in")


func home_mouse_entered() -> void:
	mouse_in = 1
	Button_MainMenu.get_node("AnimationPlayer").play("in")


func home_mouse_exited() -> void:
	mouse_in = 0
	Button_MainMenu.get_node("AnimationPlayer").play_backwards("in")
