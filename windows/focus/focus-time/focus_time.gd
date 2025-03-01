extends Node2D

@onready var timer = $HBoxContainer/Foreground/Timer
@onready var Animal = $HBoxContainer/Foreground/Animal/Animal
@onready var Human = $HBoxContainer/Foreground/Human
@onready var Camera = $HBoxContainer/Foreground/Camera2D

@onready var Parallax_Background = $HBoxContainer/Background/Parallax_Background/ParallaxBackground

@onready var Button_EndFocus = $HBoxContainer/Foreground/Buttons/End_Focus
@onready var Button_PauseFocus = $HBoxContainer/Foreground/Buttons/Pause_Focus
@onready var Button_Mute = $HBoxContainer/Foreground/Buttons/Mute_Button

@onready var EndFocus = $HBoxContainer/Foreground/End_Focus

@onready var Transition = $HBoxContainer/Foreground/Camera2D/Transition

@onready var Label_Common = $HBoxContainer/Foreground/Gift_Probabilities/Panel/Common_Chance
@onready var Label_Rare = $HBoxContainer/Foreground/Gift_Probabilities/Panel/Rare_Chance
@onready var Label_Epic = $HBoxContainer/Foreground/Gift_Probabilities/Panel/Epic_Chance

var Main_Menu_Scene : String = "res://windows/main/main_menu.tscn"

var focus : int
var animalName : String
var animalNum : int


const immediateWalkSpeed : float = 0
const normalWalkSpeed : float = 1

var walkSpeed : float

var mouse_in : int = 0
var focusPaused : bool = false

var time = Time.get_time_dict_from_system()
var ambienceNode = null
var waterAmbience = null
var soundEffect = preload("res://sounds/sound_effect.tscn")

func _ready() -> void:
	$HBoxContainer/Foreground/Camera2D/Light.show()
	Transition.AP.play("RESET")
	Set_Scene()
	Button_EndFocus.hide()
	Button_PauseFocus.hide()
	Button_Mute.hide()
	walkSpeed = immediateWalkSpeed
	
	Show_Probabilities()
	
	save.save_data()
	
	Randomise_Background()
	
	animalNum = global.projects[focus].animal
	animalName = global.animals[animalNum] #e.g. 'dog1'
	
	#set modulation and textures
	var proj = global.projects[focus]
	Animal.get_node("AnimationPlayer").play(animalName)
	Animal.get_node("Legs").modulate = proj.colours[0]
	Animal.get_node("Body/Part2").modulate = proj.colours[1]
	Animal.get_node("Body/Part3").modulate = proj.colours[2]
	
	$HBoxContainer/Foreground/Animal_Position_AnimationPlayer.play(animalName)
	
	Human.Set_Appearance()
	
	Human.get_node("Movement_AnimationPlayer").play("idle")
	
	$HBoxContainer/Foreground/Working_On.text = "Working on " + global.projects[focus].projectName
	
	#$HBoxContainer/Foreground/Camera2D/Border.show()
	
	await get_tree().create_timer(1.0).timeout
	$HBoxContainer/Foreground.position.x = global.Generate_Random(0, 20000)
	Transition.AP.play("in")
	
	await get_tree().create_timer(2.5).timeout
	
	Button_PauseFocus.get_node("Sprites/Icon").frame = 0
	
	Button_EndFocus.show()
	Button_PauseFocus.show()
	Button_Mute.show()
	
	walkSpeed = normalWalkSpeed * global.walkSpeeds[animalNum]
	
	timer.timing = true
	timer.Stopwatch()
	
	#play walking animation indefinitely
	Animal.get_node("Movement_Animation_Player").play(animalName + "_walk")
	
	Human.get_node("Movement_AnimationPlayer").speed_scale = global.walkSpeeds[animalNum]
	Human.get_node("Movement_AnimationPlayer").play("walk")



func Randomise_Background() -> void:
	for p in Parallax_Background.get_node("Lake_Components").get_children():
		for n in p.get_children():
			n.Randomise()
	
	for p in Parallax_Background.get_node("Land_Close/Grass").get_children():
		p.get_node("AnimationPlayer").play(type_convert(global.Generate_Random(1, 3), TYPE_STRING))
	
	for p in Parallax_Background.get_node("Shore_Close/Grassy").get_children():
		p.get_node("AnimationPlayer").play(type_convert(global.Generate_Random(1, 3), TYPE_STRING))
	
	for p in Parallax_Background.get_node("Trees_Close").get_children():
		p.Randomise()


func Set_Scene() -> void:
	var time = Time.get_time_dict_from_system()
	
	if false:
		var i : int = 0
		while(true):
			time.hour = i
			Set_Light(time)
			Set_Sky(time)
			Set_Ambience(time)
			i += 1
			if i == 24:
				i = 0
			await get_tree().create_timer(1).timeout
	
	
	Set_Light(time)
	Set_Sky(time)
	Set_Ambience(time)
	
	await get_tree().create_timer(30).timeout
	Set_Scene()


func Set_Light(time) -> void:
	#should be less transparent during peaks: 12pm, 12am
	var transparency : float = 0.0
	#transparency: ((1 - abs(12 - time.hour) / 6) / 2
	
	#when past 5pm, shade should switch to be 0.0 (dark)
	#when past 7am, shade should switch to be 1.0 (light)
	var shade : float
	if time.hour < 9:
		shade = 0.0
		transparency = ((1 - (type_convert(time.hour, TYPE_FLOAT) / 9))) / 2
	elif time.hour >= 17:
		shade = 0.0
		transparency = ((1 - (type_convert(abs(24 - time.hour), TYPE_FLOAT) / 7))) / 2
	elif time.hour >= 9:
		shade = 0.0
		transparency = 0.0
	
	Camera.get_node("Light").color = Color(shade, shade, shade, transparency)
	
	print("shade: " + type_convert(shade, TYPE_STRING))
	print("transparency: " + type_convert(transparency, TYPE_STRING))
	
	print(time)


func Set_Sky(time) -> void:
	if time.hour >= 6 and time.hour < 12:
		Parallax_Background.get_node("Sky/AnimationPlayer").play("morning")
		Parallax_Background.get_node("Light/AnimationPlayer").play("day")
		Parallax_Background.get_node("Fog_Medium/AnimationPlayer").play("morning")
		Parallax_Background.get_node("Land_Close/Fireflies").hide()
		Parallax_Background.get_node("Lake_Transparent/AnimationPlayer").play("morning")
	elif time.hour >= 12 and time.hour < 17:
		Parallax_Background.get_node("Sky/AnimationPlayer").play("day")
		Parallax_Background.get_node("Light/AnimationPlayer").play("day")
		Parallax_Background.get_node("Fog_Medium/AnimationPlayer").play("day")
		Parallax_Background.get_node("Land_Close/Fireflies").hide()
		Parallax_Background.get_node("Lake_Transparent/AnimationPlayer").play("day")
	elif time.hour >= 17 and time.hour < 21:
		Parallax_Background.get_node("Sky/AnimationPlayer").play("evening")
		Parallax_Background.get_node("Light/AnimationPlayer").play("night")
		Parallax_Background.get_node("Fog_Medium/AnimationPlayer").play("evening")
		Parallax_Background.get_node("Land_Close/Fireflies").hide()
		Parallax_Background.get_node("Lake_Transparent/AnimationPlayer").play("evening")
	else:
		Parallax_Background.get_node("Sky/AnimationPlayer").play("night")
		Parallax_Background.get_node("Light/AnimationPlayer").play("night")
		Parallax_Background.get_node("Fog_Medium/AnimationPlayer").play("night")
		Parallax_Background.get_node("Land_Close/Fireflies").show()
		Parallax_Background.get_node("Lake_Transparent/AnimationPlayer").play("night")


func Set_Ambience(time) -> void:
	var seName : String
	if time.hour >= 6 and time.hour < 12:
		#morning
		seName = "morning_birds"
	elif time.hour >= 12 and time.hour < 21:
		#day time / evening
		seName = "daytime_birds"
	else:
		#night
		seName = "night_ambience"
	
	if ambienceNode == null:
		var se = soundEffect.instantiate()
		se.effectName = seName
		ambienceNode = se
		add_child(se)
	elif ambienceNode.effectName != seName:
		ambienceNode.queue_free()
		ambienceNode = null
		Set_Ambience(time)
	
	if waterAmbience == null:
		var se = soundEffect.instantiate()
		se.effectName = "water"
		waterAmbience = se
		add_child(se)


func Show_Probabilities() -> void:
	var probabilities = global.giftProbabilities[21600]
	#generate random number, probabilities of each gift dependent on how long they focussed for
	var thresholds = [600, 1800, 3600, 5400, 7200, 9000, 10800, 14400, 18000, 21600]
	#loop through thresholds to identify which one it is less than
	#set probabilities to be that one
	for n in thresholds:
		if timer.totalSeconds < n:
			probabilities = global.giftProbabilities[n]
			break
	
	Label_Common.text = "Common: " + type_convert(probabilities[0], TYPE_STRING) + "%"
	Label_Rare.text = "Rare: " + type_convert(probabilities[1], TYPE_STRING) + "%"
	Label_Epic.text = "Epic: " + type_convert(probabilities[2], TYPE_STRING) + "%"


func _process(delta: float) -> void:
	$HBoxContainer/Foreground.position.x += walkSpeed
	
	#Lead.points[0].x = Human.get_node("Arms/Backarm/Backarm_Forearm/Hand").global_position.x - 560
	#Lead.points[0].y = Human.get_node("Arms/Backarm/Backarm_Forearm/Hand").global_position.y - 304
	
	#Lead.points[1].x = Animal.get_node("Body/Neck").global_position.x - 560
	#Lead.points[1].y = Animal.get_node("Body/Neck").global_position.y - 304


func End_Focus() -> void:
	timer.timing = false
	Button_EndFocus.hide()
	Button_PauseFocus.hide()
	
	#change scene to end focus scene
	walkSpeed = 0
	
	EndFocus.focusTime = timer.totalSeconds
	EndFocus.focus = focus
	EndFocus.totalTimeString = timer.get_node("Label").text
	EndFocus.animal = animalNum
	EndFocus.Focus_Ended()
	
	Animal.get_node("Movement_Animation_Player").stop()
	Animal.get_node("AnimationPlayer").play(animalName)
	$HBoxContainer/Foreground/Animal_Position_AnimationPlayer.play(animalName)
	
	Human.get_node("Movement_AnimationPlayer").play("idle")
	
	Camera.get_node("AnimationPlayer").play("end_focus")



func Pause_Focus() -> void:
	timer.timing = !focusPaused
	if focusPaused:
		timer.get_node("AnimationPlayer").play("pause")
		walkSpeed = 0
		Button_PauseFocus.get_node("Sprites/Icon").frame = 1
		Animal.get_node("Movement_Animation_Player").stop()
		Animal.get_node("AnimationPlayer").play(animalName)
		$HBoxContainer/Foreground/Animal_Position_AnimationPlayer.play(animalName)
		Human.get_node("Movement_AnimationPlayer").play("idle")
	else:
		timer.get_node("AnimationPlayer").play_backwards("pause")
		walkSpeed = normalWalkSpeed * global.walkSpeeds[animalNum]
		Button_PauseFocus.get_node("Sprites/Icon").frame = 0
		Animal.get_node("Movement_Animation_Player").play(animalName + "_walk")
		Human.get_node("Movement_AnimationPlayer").play("walk")


func _on_end_focus_die_parent() -> void:
	Transition.AP.play("out")


func _input(event: InputEvent) -> void:
	#if clicked an arrow, scroll in that direction
	#then update the human's appearance 
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and mouse_in > 0:
		if mouse_in == 1:
			sounds.Make_Sound_Effect("button_click1")
			#end focus
			End_Focus()
		elif mouse_in == 2:
			sounds.Make_Sound_Effect("button_click2")
			#pause focus
			focusPaused = !focusPaused
			Pause_Focus()


func end_focus_mouse_entered() -> void:
	mouse_in = 1
	Button_EndFocus.get_node("AnimationPlayer").play("in")


func end_focus_mouse_exited() -> void:
	mouse_in = 0
	Button_EndFocus.get_node("AnimationPlayer").play_backwards("in")


func pause_focus_mouse_entered() -> void:
	mouse_in = 2
	Button_PauseFocus.get_node("AnimationPlayer").play("in")


func pause_focus_mouse_exited() -> void:
	mouse_in = 0
	Button_PauseFocus.get_node("AnimationPlayer").play_backwards("in")


func _on_transition_done():
	waterAmbience.Stop_Playing()
	ambienceNode.Stop_Playing()
	
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file(Main_Menu_Scene)
	EndFocus.queue_free()
	queue_free()
