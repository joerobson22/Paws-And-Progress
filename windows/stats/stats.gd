extends Node2D

@onready var Label_Username = $CanvasLayer/HBoxContainer/Labels/Username_Label/Label
@onready var Label_DateJoined = $CanvasLayer/HBoxContainer/Labels/Date_Joined_Label/Label
@onready var Label_WeeklyPB = $CanvasLayer/HBoxContainer/Labels/Weekly_PB_Label/Label
@onready var Label_TotalFocus = $CanvasLayer/HBoxContainer/Labels/Total_Focus_Label/Label
@onready var Label_FocusTimePB = $CanvasLayer/HBoxContainer/Labels/Focus_Time_PB_Label/Label

@onready var Bars = $CanvasLayer/HBoxContainer/Graph/Bars

@onready var Button_LeftArrow = $CanvasLayer/HBoxContainer/Buttons/Left_Arrow
@onready var Button_RightArrow = $CanvasLayer/HBoxContainer/Buttons/Right_Arrow


var Main_Menu_Scene : String = "res://windows/main/main_menu.tscn"

var graphWeek : int = global.totalWeeks

func _ready():
	if global.founder:
		$CanvasLayer/HBoxContainer/Badge.show()
	else:
		$CanvasLayer/HBoxContainer/Badge.hide()
	Display_Stats()
	Display_Bars()
	Update_Arrows()


func Display_Stats() -> void:
	#display username
	Label_Username.text = "Username: " + global.username
	#display date joined
	Label_DateJoined.text = "Date Joined: " + type_convert(global.dateJoined.day, TYPE_STRING) + "/" + type_convert(global.dateJoined.month, TYPE_STRING) + "/" + type_convert(global.dateJoined.year, TYPE_STRING)
	#display weekly PB
	Label_WeeklyPB.text = "Weekly PB: " + type_convert(global.Convert_Time(global.weeklyFocusPB), TYPE_STRING)
	#display total focus time
	Label_TotalFocus.text = "Overall Focus Time: " + type_convert(global.Convert_Time(global.totalFocusTime), TYPE_STRING)
	#display longest focus session
	Label_FocusTimePB.text = "Longest Focus Session: " + type_convert(global.Convert_Time(global.longestFocusTime), TYPE_STRING)



func Display_Bars() -> void:
	$CanvasLayer/HBoxContainer/Graph/Label_WeekNum.text = "Week " + type_convert(graphWeek + 1, TYPE_STRING) + ": "
	if graphWeek == global.totalWeeks:
		$CanvasLayer/HBoxContainer/Graph/Label_WeekNum.text += global.Convert_Time(global.weeklyFocusTotal)
	else:
		$CanvasLayer/HBoxContainer/Graph/Label_WeekNum.text += global.Convert_Time(global.pastWeeks[graphWeek])
	#equation for size of a bar:
		#(hours * 31) + 10
	var i : int = 0
	
	for bar in Bars.get_children():
		if graphWeek == global.totalWeeks:
			var hours : float = Seconds_To_Hours(global.thisWeekDailyTotals[i])
			bar.size.x = (hours * 31) + 10
		else:
			var hours : float = Seconds_To_Hours(global.pastWeekDailyTotals[type_convert(graphWeek, TYPE_STRING)][i])
			bar.size.x = (hours * 31) + 10
		i += 1


func Update_Arrows() -> void:
	if graphWeek == 0:
		Button_LeftArrow.hide()
	else:
		Button_LeftArrow.show()
	
	if graphWeek == global.totalWeeks:
		Button_RightArrow.hide()
	else:
		Button_RightArrow.show()


func Seconds_To_Hours(seconds: float) -> float:
	return seconds / 3600.0



func _on_home_button_pressed():
	global.showTransition = false
	sounds.Make_Sound_Effect("button_click2")
	get_tree().change_scene_to_file(Main_Menu_Scene)
	queue_free()


func _on_button_mouse_entered_LEFTARROW():
	Button_LeftArrow.get_node("AnimationPlayer").play("in")


func _on_button_mouse_exited_LEFTARROW():
	Button_LeftArrow.get_node("AnimationPlayer").play_backwards("in")


func _on_button_pressed_LEFTARROW():
	if graphWeek == 0:
		graphWeek = global.totalWeeks
	else:
		graphWeek -= 1
	Display_Bars()
	Update_Arrows()


func _on_button_pressed_RIGHTARROW():
	if graphWeek == global.totalWeeks:
		graphWeek = 0
	else:
		graphWeek += 1
	Display_Bars()
	Update_Arrows()


func _on_button_mouse_entered_RIGHTARROW():
	Button_RightArrow.get_node("AnimationPlayer").play("in")


func _on_button_mouse_exited_RIGHTARROW():
	Button_RightArrow.get_node("AnimationPlayer").play_backwards("in")
	

func Display_Hours(num : int) -> void:
	$CanvasLayer/HBoxContainer/Graph/Label_HoursDisplay.text = "Hours: " + type_convert(snappedf((Bars.get_node("Bar" + type_convert(num, TYPE_STRING)).size.x - 10) / 31, 0.01), TYPE_STRING)
	$CanvasLayer/HBoxContainer/Graph/Label_HoursDisplay.show()


func _on_bar_1_mouse_entered():
	Display_Hours(1)


func bar_exited():
	$CanvasLayer/HBoxContainer/Graph/Label_HoursDisplay.hide()


func _on_bar_2_mouse_entered():
	Display_Hours(2)


func _on_bar_3_mouse_entered():
	Display_Hours(3)


func _on_bar_4_mouse_entered():
	Display_Hours(4)


func _on_bar_5_mouse_entered():
	Display_Hours(5)


func _on_bar_6_mouse_entered():
	Display_Hours(6)


func _on_bar_7_mouse_entered():
	Display_Hours(7)


func _on_control_mouse_entered_FOUNDER():
	$CanvasLayer/HBoxContainer/Badge/AnimationPlayer.play("in")


func _on_control_mouse_exited_FOUNDER():
	$CanvasLayer/HBoxContainer/Badge/AnimationPlayer.play_backwards("in")
