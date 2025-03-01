extends Node2D

@onready var Cabin_Window = $CanvasLayer/Centre/Cabin/Window
@onready var Cabin_Door = $CanvasLayer/Centre/Cabin/Door
@onready var Cabin_Rug = $CanvasLayer/Centre/Cabin/Rug
@onready var Cabin_Cat = $CanvasLayer/Centre/Cabin/Sleeping_Cat
@onready var Cabin_Shelves = $CanvasLayer/Centre/Cabin/Gift_Shelves
@onready var Cabin_Project_Board = $CanvasLayer/Centre/Cabin/Completed_Projects_Board
@onready var Cabin_Fireplace = $CanvasLayer/Centre/Cabin/Fireplace
@onready var Cabin_COD = $CanvasLayer/Centre/Cabin/Chest_Of_Drawers
@onready var Cabin_Armchair = $CanvasLayer/Centre/Cabin/Armchair
@onready var Cabin_Light = $CanvasLayer/Centre/Cabin/Light

@onready var Happy_Birthday = $CanvasLayer/Centre/Happy_Birthday/Label

@onready var Choose_Focus = $CanvasLayer/Centre/Choose_Focus

@onready var Character_Customisation = $CanvasLayer/Centre/Character_Customisation

@onready var Transition = $CanvasLayer/Centre/Transition
@onready var Mute_Button = $CanvasLayer/Centre/Buttons/Mute_Button

var fireplaceNoise = null
var soundEffect = preload("res://sounds/sound_effect.tscn")

var image = preload("res://windows/main/completed_project_image.tscn")
var giftImage = preload("res://windows/main/gift_image.tscn")

#var Choose_Focus_Scene = preload("res://windows/focus/choose-focus/choose_focus.tscn").instantiate()
var Gift_Scene = preload("res://windows/gifts/gifts.tscn").instantiate()
var Completed_Projects_Scene = preload("res://windows/completed-projects/completed_projects.tscn").instantiate()
var focusTimeScene = preload("res://windows/focus/focus-time/focus_time.tscn").instantiate()
var stats_Scene = preload("res://windows/stats/stats.tscn").instantiate()

var completedProjectsSprites = []
var giftSprites = []

var chooseFocusEnabled : bool = false
var switchingChooseFocus : bool = false

var characterCustomisationEnabled : bool = false
var switchingCharCust : bool = false

var time

func _ready() -> void:
	Update_Daily_Time()
	Update_Weekly_Time()
	#save data
	save.save_data()
	
	global.lastLoginDict = global.timeDict
	Choose_Focus.hide()
	$CanvasLayer/Centre/Border_Sprite.show()
	
	Cabin_Cat.get_node("Positions_Player").play(type_convert(global.Generate_Random(1, 4), TYPE_STRING))
	Cabin_Cat.get_node("Idle_Player").play("idle")
	Cabin_Door.get_node("Aura/AnimationPlayer").play("idle")
	
	
	
	Display_Post_It_Notes()
	Display_Gifts()
	
	Set_State()
	
	Get_Time()
	
	if global.fireplaceOn:
		Play_Fire_Noise()
		Animate_Fire()
	if global.curtainsOpen:
		Animate_Windows()
	
	Calculate_Light_Level()
	
	if global.showTransition:
		Transition.AP.play("RESET")
		await get_tree().create_timer(1.0).timeout
		Transition.AP.play("in")
	else:
		Transition.hide()
	
	print(global.timeDict)
	var birthdayDates = [[3, 3], [8, 3], [9, 2], [7, 4], [30, 5], [22, 5], [24, 6], [12, 12], [25, 8], [1,9], [31, 1]]
	var birthdayPeople = ["WILLIAM", "KATHRYN", "NICOLE", "JOE", "BEN", "MIKE", "LUKAS", "OSCAR", "REUBEN", "NIAMH", "MADI"]
	var birthday : bool = false
	
	var i : int = 0
	while i < birthdayDates.size():
		birthday = isDate(birthdayDates[i][0], birthdayDates[i][1])
		if birthday:
			Happy_Birthday.text = "HAPPY BIRTHDAY " + birthdayPeople[i] + "!!!"
			break
		i += 1
	
	Happy_Birthday.visible = birthday


func isDate(day : int, month : int) -> bool:
	return (global.timeDict["day"] == day and global.timeDict["month"] == month)


func Update_Weekly_Time() -> void:
	#check if on the same week as last login
	
	#get current time dictionary from system
	global.timeDict = Time.get_date_dict_from_system()
	print(global.timeDict)
	#then check if the last login was on the same week as this login
	if global.lastLoginDict != null:
		if !Is_Same_Week():
			#if not on the same week, check if weekly total is greater than weekly PB
			if global.weeklyFocusTotal > global.weeklyFocusPB:
				global.weeklyFocusPB = global.weeklyFocusTotal
			global.pastWeeks.append(global.weeklyFocusTotal)
			global.pastWeekDailyTotals[type_convert(global.totalWeeks, TYPE_STRING)] = global.thisWeekDailyTotals
			global.thisWeekDailyTotals = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
			global.totalWeeks += 1
			
			global.weeklyFocusTotal = 0.0
	
	#alter the text for cat (current total) and armchair (weeklyPB)
	Cabin_Cat.get_node("Label").text = "Weekly Total: " + global.Convert_Time(global.weeklyFocusTotal)


func Update_Daily_Time() -> void:
	global.timeDict = Time.get_date_dict_from_system()
	if !Is_Same_Day():
		global.thisWeekDailyTotals[global.lastLoginDict.weekday] = global.dailyFocusTotal
		global.dailyFocusTotal = 0.0


func Play_Fire_Noise() -> void:
	var se = soundEffect.instantiate()
	se.effectName = "fireplace"
	fireplaceNoise = se
	get_tree().get_root().add_child(se)


func Is_Same_Week() -> bool:
	var outcome : bool
	#first, if the current weekday is less, it's not the same week
	if global.timeDict["weekday"] < global.lastLoginDict["weekday"]:
		outcome = false
	else:
		if type_convert(global.lastLoginDict["year"], TYPE_INT) % 4 == 0:
			global.daysOfMonths[1] = 29
		#calculate which day of the year it is
		#use the array containing number of days in each month
		var i : int = 0
		var days : int = 0
		while i < 12:
			#if the month we're cycling through is the same as the month, then break the cycle
			if i + 1 == global.lastLoginDict["month"]:
				break
			#otherwise, add the number of days in that month
			days += global.daysOfMonths[i]
			i += 1
		days += global.lastLoginDict["day"]
		#once we have calculated which day of the year it was
		#use the weekday to calculate when the start of the week was
		var startOfLastWeek = days + 1 - global.lastLoginDict["weekday"]
		
		#now do the same with the current time dict
		if type_convert(global.timeDict["year"], TYPE_INT) % 4 == 0:
			global.daysOfMonths[1] = 29
		else:
			global.daysOfMonths[1] = 28
		#calculate which day of the year it is
		#use the array containing number of days in each month
		i = 0
		days = 0
		while i < 12:
			#if the month we're cycling through is the same as the month, then break the cycle
			if i + 1 == global.timeDict["month"]:
				break
			#otherwise, add the number of days in that month
			days += global.daysOfMonths[i]
			i += 1
		days += global.timeDict["day"]
		#once we have calculated which day of the year it was
		#use the weekday to calculate when the start of the week was
		var startOfCurrentWeek = days + 1 - global.timeDict["weekday"]
		
		#if both weeks started at the same time
		#must be the same week
		outcome = startOfCurrentWeek == startOfLastWeek
	return outcome


func Is_Same_Day() -> bool:
	return(global.lastLoginDict.year == global.timeDict.year && global.lastLoginDict.month == global.timeDict.month && global.lastLoginDict.day == global.timeDict.day)


func Display_Post_It_Notes() -> void:
	#for every completed project, add a little post it note on the board
	for p in global.completedProjects:
		Add_Post_It_Note(p)

func Add_Post_It_Note(p) -> void:
	var clone = image.instantiate()
	#randomise position (x: 230-420),(y: 160-230) 
	clone.position.x = global.Generate_Random(-100, 100)
	clone.position.y = global.Generate_Random(-60, 45)
	#set scale based on x axis
	clone.scale.x = 1 - (clone.position.x / 500)
	clone.scale.y = 1 - (clone.position.x / 500)
	#randomise colour
	clone.modulate = Color(p.part2R, p.part2G, p.part2B, 1.0)
	#hide
	clone.visible = true
	#add to array
	completedProjectsSprites.append(clone)
	Cabin_Project_Board.get_node("Sprites/Pictures").add_child(clone)


func Display_Gifts() -> void:
	#for every gift, add a little trinket on the shelves
	var shelves = ["Bottom", "Middle", "Top"]
	for g in global.gifts:
		if g > 0:
			var node = Cabin_Shelves.get_node("Sprites/Shelves/" + shelves[global.Generate_Random(0, 2)] + "/Gift_Pos" + type_convert(global.Generate_Random(1, 14), TYPE_STRING))
			var gift = giftImage.instantiate()
			#randomise size
			gift.scale.x = global.Generate_Random_Float(0.3, 1.0)
			gift.scale.y = gift.scale.x
			#randomize colour
			gift.modulate = Color(global.Generate_Random_Float(0.0, 1.0), global.Generate_Random_Float(0.0, 1.0), global.Generate_Random_Float(0.0, 1.0), 1.0)
			node.add_child(gift)
			giftSprites.append(gift)

func Animate_Fire() -> void:
	if global.fireplaceOn:
		if !chooseFocusEnabled:
			var fire = global.Generate_Random(0, 7)
			Cabin_Fireplace.get_node("Sprites/Fire/Back").frame = fire
			Cabin_Fireplace.get_node("Sprites/Fire/Middle").frame = fire
			Cabin_Fireplace.get_node("Sprites/Fire/Front").frame = fire
			
			var fireFloat : float = fire
			fireFloat += 5.0
			Cabin_Light.get_node("Fireplace_Light").scale.x = (fireFloat + 1) / 15
			Cabin_Light.get_node("Fireplace_Light").scale.y = (fireFloat + 1) / 15
		
		await get_tree().create_timer(1).timeout
		Animate_Fire()

func Animate_Windows() -> void:
	if global.curtainsOpen:
		if !chooseFocusEnabled:
			var light = global.Generate_Random(98, 100)
			var lightFloat : float = light
			Cabin_Light.get_node("Window_Light").scale.x = lightFloat / 100
			Cabin_Light.get_node("Window_Light").scale.y = lightFloat / 100
		
		await get_tree().create_timer(1).timeout
		Animate_Windows()

func Calculate_Light_Level() -> void:
	global.lightLevel = 0
	if global.curtainsOpen:
		global.lightLevel += 1
	if global.fireplaceOn:
		global.lightLevel += 1
	Cabin_Light.get_node("Room_Light/AnimationPlayer").play(type_convert(global.lightLevel, TYPE_STRING))

func Set_State() -> void:
	if global.fireplaceOn:
		Cabin_Fireplace.get_node("Sprites/Fireplace/Sprite2D").frame = 0
		Cabin_Fireplace.get_node("Sprites/Fire").show()
		Cabin_Light.get_node("Fireplace_Light").show()
	else:
		Cabin_Fireplace.get_node("Sprites/Fireplace/Sprite2D").frame = 1
		Cabin_Fireplace.get_node("Sprites/Fire").hide()
		Cabin_Light.get_node("Fireplace_Light").hide()
	
	if global.curtainsOpen:
		Cabin_Window.get_node("Sprites/Curtains").frame = 1
		Cabin_Light.get_node("Window_Light").show()
	else:
		Cabin_Window.get_node("Sprites/Curtains").frame = 0
		Cabin_Light.get_node("Window_Light").hide()


func Get_Time() -> void:
	time = Time.get_time_dict_from_system()
	
	var testing : bool = false
	
	if testing:
		var i : int = 0
		while(true):
			time.hour = i
			Set_Light(time)
			i += 1
			if i == 24:
				i = 0
			await get_tree().create_timer(1).timeout
	
	Set_Light(time)
	
	await get_tree().create_timer(60).timeout
	Get_Time()


func Set_Light(time) -> void:
	#should be less transparent during peaks: 12pm, 12am
	var transparency : float = 0.0
	#transparency: ((1 - abs(12 - time.hour) / 6) / 2
	
	#when past 5pm, shade should switch to be 0.0 (dark)
	#when past 7am, shade should switch to be 1.0 (light)
	var shade : float
	if time.hour < 4:
		shade = 0.0
		transparency = 0.45
	elif time.hour < 9:
		shade = 0.0
		transparency = ((1 - (type_convert(time.hour, TYPE_FLOAT) / 9))) / 2
	elif time.hour >= 17:
		shade = 0.0
		transparency = ((1 - (type_convert(abs(24 - time.hour), TYPE_FLOAT) / 7)))
	elif time.hour >= 9:
		shade = 0.0
		transparency = 0.0
	
	$CanvasLayer/Centre/Outside/ColorRect.color = Color(shade, shade, shade, transparency)
	
	if time.hour >= 6 and time.hour < 12:
		Cabin_Light.get_node("Window_Light/AnimationPlayer").play("morning")
	elif time.hour >= 12 and time.hour < 17:
		Cabin_Light.get_node("Window_Light/AnimationPlayer").play("day")
	elif time.hour >= 17 and time.hour < 21:
		Cabin_Light.get_node("Window_Light/AnimationPlayer").play("evening")
	else:
		Cabin_Light.get_node("Window_Light/AnimationPlayer").play("night")


#___________________________________________________________ BUTTON PRESSES

#SWITCHING BETWEEN CHOOSE FOCUS SCENE AND MAIN MENU
func _on_button_pressed_START_FOCUS() -> void:
	Mute_Button.hide()
	sounds.Make_Sound_Effect("button_click1")
	#choose focus scene pops up
	switchingChooseFocus = true
	Choose_Focus.show()
	#pause animations
	Cabin_Cat.get_node("Idle_Player").pause()
	Cabin_Door.get_node("Aura/AnimationPlayer").pause()
	$AnimationPlayer.play("choose_focus")

func _on_button_pressed_COD() -> void:
	Mute_Button.hide()
	sounds.Make_Sound_Effect("zip")
	#char cust scene pops up
	switchingCharCust = true
	Character_Customisation.show()
	#pause animations
	Cabin_Cat.get_node("Idle_Player").pause()
	Cabin_Door.get_node("Aura/AnimationPlayer").pause()
	$AnimationPlayer.play("character_customisation")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "choose_focus" and chooseFocusEnabled:
		#choose focus is here
		#prevent animation triggering twice
		chooseFocusEnabled = false
		switchingChooseFocus = false
		Choose_Focus.hide()
		#play animations
		Cabin_Cat.get_node("Idle_Player").play("idle")
		Cabin_Door.get_node("Aura/AnimationPlayer").play("idle")
		Mute_Button.show()
	elif anim_name == "choose_focus":
		#choose focus gone
		chooseFocusEnabled = true
		switchingChooseFocus = false
	
	if anim_name == "character_customisation" and characterCustomisationEnabled:
		#choose focus is here
		#prevent animation triggering twice
		characterCustomisationEnabled = false
		switchingCharCust = false
		Character_Customisation.hide()
		#play animations
		Cabin_Cat.get_node("Idle_Player").play("idle")
		Cabin_Door.get_node("Aura/AnimationPlayer").play("idle")
		Mute_Button.show()
	elif anim_name == "character_customisation":
		#choose focus gone
		characterCustomisationEnabled = true
		switchingCharCust = false


func _on_choose_focus_home_clicked() -> void:
	sounds.Make_Sound_Effect("button_click2")
	save.save_data()
	#choose ficus scene goes away
	switchingChooseFocus = true
	$AnimationPlayer.play_backwards("choose_focus")
	Update_Weekly_Time()


func _on_character_customisation_char_cust_home_clicked() -> void:
	sounds.Make_Sound_Effect("button_click2")
	save.save_data()
	#character customisation window goes away
	switchingChooseFocus = true
	$AnimationPlayer.play_backwards("character_customisation")
	Update_Weekly_Time()

#-------------------------------

func _on_button_pressed_WINDOW() -> void:
	global.curtainsOpen = !global.curtainsOpen
	if global.curtainsOpen:
		sounds.Make_Sound_Effect("curtain_opening")
		Cabin_Window.get_node("Sprites/Curtains").frame = 1
		Cabin_Light.get_node("Window_Light").show()
		Animate_Windows()
	else:
		sounds.Make_Sound_Effect("curtain_closing")
		Cabin_Window.get_node("Sprites/Curtains").frame = 0
		Cabin_Light.get_node("Window_Light").hide()
	Calculate_Light_Level()

func _on_button_pressed_GIFT() -> void:
	if fireplaceNoise != null:
		fireplaceNoise.queue_free()
	sounds.Make_Sound_Effect("button_click1")
	#switch to gifts scene
	get_tree().get_root().add_child(Gift_Scene)
	queue_free()

func _on_button_pressed_PROJECTS() -> void:
	if fireplaceNoise != null:
		fireplaceNoise.queue_free()
	sounds.Make_Sound_Effect("button_click1")
	#switch to completed projects scene
	get_tree().get_root().add_child(Completed_Projects_Scene)
	queue_free()

func _on_button_pressed_FIREPLACE() -> void:
	#turn off fireplace
	global.fireplaceOn = !global.fireplaceOn
	if global.fireplaceOn:
		sounds.Make_Sound_Effect("fireplace_lit")
		Play_Fire_Noise()
		Cabin_Fireplace.get_node("Sprites/Fireplace/Sprite2D").frame = 0
		Cabin_Fireplace.get_node("Sprites/Fire").show()
		Cabin_Light.get_node("Fireplace_Light").show()
		Animate_Fire()
	else:
		sounds.Make_Sound_Effect("fireplace_extinguished")
		fireplaceNoise.queue_free()
		fireplaceNoise = null
		Cabin_Fireplace.get_node("Sprites/Fireplace/Sprite2D").frame = 1
		Cabin_Fireplace.get_node("Sprites/Fire").hide()
		Cabin_Light.get_node("Fireplace_Light").hide()
	Calculate_Light_Level()



func _on_choose_focus_start_focus() -> void:
	if fireplaceNoise != null:
		fireplaceNoise.queue_free()
	Transition.AP.play("out")


#___________________________________________________________  BUTTON ANIMATIONS

func _on_button_mouse_entered_DOOR() -> void:
	Cabin_Door.get_node("AnimationPlayer").play("highlight")


func _on_button_mouse_exited_DOOR() -> void:
	Cabin_Door.get_node("AnimationPlayer").play_backwards("highlight")
#___________________________________________________________


func _on_button_mouse_entered_WINDOW() -> void:
	Cabin_Window.get_node("AnimationPlayer").play("highlight")


func _on_button_mouse_exited_WINDOW() -> void:
	Cabin_Window.get_node("AnimationPlayer").play_backwards("highlight")
#___________________________________________________________


func _on_control_mouse_entered_SLEEPING_CAT() -> void:
	Cabin_Cat.get_node("AnimationPlayer").play("highlight")
	#show weekly time


func _on_control_mouse_exited_SLEEPING_CAT() -> void:
	Cabin_Cat.get_node("AnimationPlayer").play_backwards("highlight")
	#hide weekly time
#___________________________________________________________

func _on_button_mouse_entered_GIFT() -> void:
	Cabin_Shelves.get_node("AnimationPlayer").play("highlight")


func _on_button_mouse_exited_GIFT() -> void:
	Cabin_Shelves.get_node("AnimationPlayer").play_backwards("highlight")
#___________________________________________________________

func _on_button_mouse_entered_PROJECTS() -> void:
	Cabin_Project_Board.get_node("AnimationPlayer").play("highlight")


func _on_button_mouse_exited_PROJECTS() -> void:
	Cabin_Project_Board.get_node("AnimationPlayer").play_backwards("highlight")

#___________________________________________________________

func _on_button_mouse_entered_FIREPLACE() -> void:
	sounds.Make_Sound_Effect("wood2")
	Cabin_Fireplace.get_node("AnimationPlayer").play("highlight")


func _on_button_mouse_exited_FIREPLACE() -> void:
	sounds.Make_Sound_Effect("wood3")
	Cabin_Fireplace.get_node("AnimationPlayer").play_backwards("highlight")

#___________________________________________________________

func _on_button_mouse_entered_COD() -> void:
	sounds.Make_Sound_Effect("wood4")
	Cabin_COD.get_node("AnimationPlayer").play("highlight")


func _on_button_mouse_exited_COD() -> void:
	sounds.Make_Sound_Effect("wood1")
	Cabin_COD.get_node("AnimationPlayer").play_backwards("highlight")
#___________________________________________________________

func _on_control_mouse_entered_ARMCHAIR() -> void:
	sounds.Make_Sound_Effect("wood4")
	Cabin_Armchair.get_node("AnimationPlayer").play("highlight")


func _on_control_mouse_exited_ARMCHAIR() -> void:
	sounds.Make_Sound_Effect("wood1")
	Cabin_Armchair.get_node("AnimationPlayer").play_backwards("highlight")


func _on_transition_done():
	await get_tree().create_timer(1.0).timeout
	focusTimeScene.focus = Choose_Focus.currentFocus
	get_tree().get_root().add_child(focusTimeScene)
	queue_free()


func _on_control_pressed_SLEEPING_cAT():
	sounds.Make_Sound_Effect("cat_meow" + type_convert(global.Generate_Random(1, 4), TYPE_STRING))


func _on_button_pressed_ARMCHAIR():
	if fireplaceNoise != null:
		fireplaceNoise.queue_free()
	sounds.Make_Sound_Effect("button_click1")
	#switch to stats scene
	get_tree().get_root().add_child(stats_Scene)
	queue_free()
