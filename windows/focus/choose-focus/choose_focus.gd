extends Node2D

@onready var TextEdit_ProjectName = $TextEdit/Project_Name
@onready var TextEdit_AnimalName = $TextEdit/Animal_Name

@onready var Label_ProjectName = $Labels/Project_Name/Label
@onready var Label_AnimalName = $Labels/Animal_Name/Label
@onready var Label_TotalTime = $Labels/Total_Time_Label/Label

@onready var Button_StartFocus = $Buttons/Start_Focus
@onready var Button_LeftArrow = $Buttons/Left_Arrow
@onready var Button_RightArrow = $Buttons/Right_Arrow
@onready var Button_AnimalLeftArrow = $Buttons/Animal_Left_Arrow
@onready var Button_AnimalRightArrow = $Buttons/Animal_Right_Arrow
@onready var Button_Home = $Buttons/Home
@onready var Button_Delete = $Buttons/Delete
@onready var Button_Complete = $Buttons/Complete

@onready var Colour_Customisation = $Colour_Customisation

signal home_clicked
signal start_focus

var project = preload("res://projects/project.tscn")

var currentFocus : int = 0
var newProjectAnimal : int = 0
var newProjectAnimalColours = [Color(0.0, 0.0, 0.0, 1.0), Color(0.0, 0.0, 0.0, 1.0), Color(0.0, 0.0, 0.0, 1.0)]


var mouse_in : int = 0
# 1: start focus
# 2: left project arrow
# 3: right project arrow
# 4: home button
# 5: delete button
# 6: complete button
# 7: left animal button
# 8: right animal button

var switchedVisuals : bool = true
var switching : bool = false

func _ready() -> void:
	$ColorRect.show()
	Update_Visuals()
	Button_StartFocus.get_node("Aura/AnimationPlayer").play("idle")


func _process(_delta: float) -> void:
	if global.projects[currentFocus] == null and !switching and switchedVisuals and isColourCustomisable(global.animals[newProjectAnimal]):
		newProjectAnimalColours[0] = Colour_Customisation.get_node("Colour1/Button/ColorPickerButton").color
		newProjectAnimalColours[1] = Colour_Customisation.get_node("Colour2/Button/ColorPickerButton").color
		newProjectAnimalColours[2] = Colour_Customisation.get_node("Colour3/Button/ColorPickerButton").color
		
		Button_StartFocus.get_node("Animal/Animal/Legs").modulate = newProjectAnimalColours[0]
		Button_StartFocus.get_node("Animal/Animal/Body/Part2").modulate = newProjectAnimalColours[1]
		Button_StartFocus.get_node("Animal/Animal/Body/Part3").modulate = newProjectAnimalColours[2]


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#mouse has been clicked, identify what on
		if mouse_in == 0:
			pass
		elif mouse_in == 1:
			#start focus
			if global.projects[currentFocus] != null:
				#switch scene to focus time with that focus
				sounds.Make_Sound_Effect(global.animalSounds[global.projects[currentFocus].animal])
				Focus()
			elif TextEdit_ProjectName.text != "" and TextEdit_AnimalName.text != "":
				#create new project
				sounds.Make_Sound_Effect(global.animalSounds[newProjectAnimal])
				Create_New_Project()
		elif mouse_in == 2:
			#left project arrow
			sounds.Make_Sound_Effect("button_click1")
			_on_button_pressed_LEFT_ARROW()
		elif mouse_in == 3:
			#right project arrow
			sounds.Make_Sound_Effect("button_click1")
			_on_button_pressed_RIGHT_ARROW()
		elif mouse_in == 4:
			#home button
			emit_signal("home_clicked")
		elif mouse_in == 5:
			#delet button
			sounds.Make_Sound_Effect("button_click2")
			_on_button_pressed_DELETE()
		elif mouse_in == 6:
			#complete button
			sounds.Make_Sound_Effect("button_click2")
			_on_button_pressed_COMPLETE()
		elif mouse_in == 7:
			#left animla button
			sounds.Make_Sound_Effect("button_click3")
			_on_button_pressed_LEFT_ANIMAL_ARROW()
		elif mouse_in == 8:
			#right animla button
			sounds.Make_Sound_Effect("button_click3")
			_on_button_pressed_RIGHT_ANIMAL_ARROW()

#function for creating a new project
func Create_New_Project():
	#create new instance
	var instance = project.instantiate()
	instance.projectName = TextEdit_ProjectName.text
	instance.animalName = TextEdit_AnimalName.text
	instance.animal = newProjectAnimal
	#legs
	instance.part1R = newProjectAnimalColours[0].r
	instance.part1G = newProjectAnimalColours[0].g
	instance.part1B = newProjectAnimalColours[0].b
	#body
	instance.part2R = newProjectAnimalColours[1].r
	instance.part2G = newProjectAnimalColours[1].g
	instance.part2B = newProjectAnimalColours[1].b
	#pattern
	instance.part3R = newProjectAnimalColours[2].r
	instance.part3G = newProjectAnimalColours[2].g
	instance.part3B = newProjectAnimalColours[2].b
	
	instance.setColours()
	
	#set date created
	var date = Time.get_datetime_dict_from_system()
	instance.dateStarted = type_convert(date.day, TYPE_STRING) + "/" + type_convert(date.month, TYPE_STRING) + "/" + type_convert(date.year, TYPE_STRING)
	#add to global array
	global.projects[currentFocus] = instance
	global.projects.append(null)
	global.totalCurrentProjects += 1
	#button pressed, popup appears, enter details, save the project to the global projects array
	TextEdit_ProjectName.text = ""
	TextEdit_AnimalName.text = ""
	
	
	Update_Visuals()

#function for scrolling through projects
func Update_Visuals():
	switching = false
	switchedVisuals = false
	if currentFocus != global.totalCurrentProjects:
		#display current project with button to start focus
		Label_ProjectName.text = global.projects[currentFocus].projectName
		Label_AnimalName.text = global.projects[currentFocus].animalName
		#as well as project's stats 
		Label_TotalTime.text = global.Convert_Time(global.projects[currentFocus].totalFocusTime)
		Button_Complete.show()
		
		Button_StartFocus.get_node("Aura").show()
		
		get_node("TextEdit").hide()
		Button_AnimalLeftArrow.hide()
		Button_AnimalRightArrow.hide()
		
		Button_Delete.show()
		
		#hide the colour picker stuff
		Colour_Customisation.hide()
		
		Button_StartFocus.get_node("Animal/AnimationPlayer").play("switch")
	else:
		#change title text
		Label_ProjectName.text = "Create New Project"
		Label_AnimalName.text = ""
		Label_TotalTime.text = ""
		Button_Complete.hide()
		
		Button_StartFocus.get_node("Aura").hide()
		
		#show text edits etc
		get_node("TextEdit").show()
		Button_AnimalLeftArrow.show()
		Button_AnimalRightArrow.show()
		Button_Delete.hide()
		Colour_Customisation.show()
		
		Button_StartFocus.get_node("Animal/AnimationPlayer").play("switch")
	
	#disable or enable arrows
	Set_Arrow_Button_Status()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "switch" and !switchedVisuals:
		#what is the project we're switching to?
		Display_Animal()
		Button_StartFocus.get_node("Animal/AnimationPlayer").play_backwards("switch")
		switchedVisuals = true
	elif switchedVisuals and anim_name == "switch":
		switching = false

#function used to display the current animal, be it an existing or non-existing project
func Display_Animal() -> void:
	#first takes into account if the current focus exists or not
	if global.projects[currentFocus] == null:
		#changes sprite textures to be the last looked at animal (newProjectAnimal)
		Button_StartFocus.get_node("Animal/Animal/Plus").show()
		Button_StartFocus.get_node("Animal/Animal/Plus/AnimationPlayer").play("idle")
		Button_StartFocus.get_node("Animal/Animal/AnimationPlayer").play(global.animals[newProjectAnimal])
		
		var colourCustomisable : bool = isColourCustomisable(global.animals[newProjectAnimal])
		
		var i : int = 0
		for n in Colour_Customisation.get_children():
			n.visible = colourCustomisable
			n.get_node("Label/Label").text = global.animalParts[global.animals[newProjectAnimal]][i]
			i += 1
		
		if !colourCustomisable:
			newProjectAnimalColours = [Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 1.0)]
	else:
		Button_StartFocus.get_node("Animal/Animal/Plus").hide()
		#changes sprite textures
		var proj = global.projects[currentFocus]
		Button_StartFocus.get_node("Animal/Animal/AnimationPlayer").play(global.animals[proj.animal])
		#changes modulation of sprites
		Button_StartFocus.get_node("Animal/Animal/Legs").modulate = proj.colours[0]
		Button_StartFocus.get_node("Animal/Animal/Body/Part2").modulate = proj.colours[1]
		Button_StartFocus.get_node("Animal/Animal/Body/Part3").modulate = proj.colours[2]


func isColourCustomisable(name : String) -> bool:
	for n in global.colourNotCustomisable:
		if n == name:
			return false
	return true

#function for switching windows
func Focus() -> void:
	#switch scene to focus time, pass in 'current focus'
	emit_signal("start_focus")

#function for enabling or disabling arrows
func Set_Arrow_Button_Status():
	if currentFocus == 0:
		#we are at the leftmost project, no projects left of here
		#disable left arrow
		Button_LeftArrow.hide()
		if global.totalCurrentProjects > 0:
			#if there are more projects to the right, enable the right button
			Button_RightArrow.show()
		else:
			#otherwise, disable it
			Button_RightArrow.hide()
	elif currentFocus == global.totalCurrentProjects:
		#if we are at the rightmost project, we cannot go any further right
		#disable right arrow
		Button_RightArrow.hide()
		#there are projects to the left due to the first if statement
		Button_LeftArrow.show()
	else:
		#enable them both
		Button_LeftArrow.show()
		Button_RightArrow.show()

#_________________________________________________________
#button pressed functions

#function for scrolling left
func _on_button_pressed_LEFT_ARROW() -> void:
	if !switching:
		#scroll to the left
		currentFocus -= 1
		#update visuals
		Update_Visuals()

#function for scrolling right
func _on_button_pressed_RIGHT_ARROW() -> void:
	if !switching:
		#scroll to the right
		currentFocus += 1
		#update visuals
		Update_Visuals()


#function for completing current project
func _on_button_pressed_COMPLETE() -> void:
	if global.projects[currentFocus].totalFocusTime > 0:
		sounds.Make_Sound_Effect("project_complete")
		var p = global.projects[currentFocus]
		#set to complete
		global.projects[currentFocus].complete = true
		var date = Time.get_datetime_dict_from_system()
		global.projects[currentFocus].dateFinished = type_convert(date.day, TYPE_STRING) + "/" + type_convert(date.month, TYPE_STRING) + "/" + type_convert(date.year, TYPE_STRING)
		#move the project into the completed projects array
		global.completedProjects.append(global.projects[currentFocus])
		global.projects.remove_at(currentFocus)
		#update pointers
		global.totalCompletedProjects += 1
		global.totalCurrentProjects -= 1
		
		get_parent().get_parent().get_parent().Add_Post_It_Note(p)
		
		Update_Visuals()


#funciton for deleting a project
func _on_button_pressed_DELETE() -> void:
	if currentFocus < global.totalCurrentProjects:
		#remove current focus
		global.projects.remove_at(currentFocus)
		#update pointers
		global.totalCurrentProjects -= 1
		
		Update_Visuals()


func _on_button_pressed_LEFT_ANIMAL_ARROW() -> void:
	if newProjectAnimal == 0:
		newProjectAnimal = global.numAnimals - 1
	else:
		newProjectAnimal -= 1
	Update_Visuals()


func _on_button_pressed_RIGHT_ANIMAL_ARROW() -> void:
	if newProjectAnimal == global.numAnimals - 1:
		newProjectAnimal = 0
	else:
		newProjectAnimal += 1
	Update_Visuals()

#_______________________________________________________________

#mouse in an out functions
func _on_control_mouse_entered_FOCUS() -> void:
	mouse_in = 1
	Button_StartFocus.get_node("AnimationPlayer").play("in")


func _on_control_mouse_exited() -> void:
	mouse_in = 0


func _on_control_mouse_entered_LEFT_ARROW() -> void:
	mouse_in = 2
	Button_LeftArrow.get_node("AnimationPlayer").play("in")


func _on_control_mouse_entered_RIGHT_ARROW() -> void:
	mouse_in = 3
	Button_RightArrow.get_node("AnimationPlayer").play("in")


func _on_control_mouse_entered_HOME() -> void:
	mouse_in = 4
	Button_Home.get_node("AnimationPlayer").play("in")


func _on_control_mouse_entered_DELETE() -> void:
	mouse_in = 5
	Button_Delete.get_node("AnimationPlayer").play("in")


func _on_control_mouse_entered_COMPLETE() -> void:
	mouse_in = 6
	Button_Complete.get_node("AnimationPlayer").play("in")


func _on_control_mouse_entered_ANIMAL_LEFT_ARROW() -> void:
	mouse_in = 7
	Button_AnimalLeftArrow.get_node("AnimationPlayer").play("in")


func _on_control_mouse_entered_ANIMAL_RIGHT_ARROW() -> void:
	mouse_in = 8
	Button_AnimalRightArrow.get_node("AnimationPlayer").play("in")

#______________________________________ 

func _on_control_mouse_exited_START_FOCUS() -> void:
	Button_StartFocus.get_node("AnimationPlayer").play_backwards("in")


func _on_control_mouse_exited_LEFT_ARROW() -> void:
	Button_LeftArrow.get_node("AnimationPlayer").play_backwards("in")


func _on_control_mouse_exited_RIGHT_ARROW() -> void:
	Button_RightArrow.get_node("AnimationPlayer").play_backwards("in")


func _on_control_mouse_exited_ANIMAL_LEFT_ARROW() -> void:
	Button_AnimalLeftArrow.get_node("AnimationPlayer").play_backwards("in")


func _on_control_mouse_exited_ANIMAL_RIGHT_ARROW() -> void:
	Button_AnimalRightArrow.get_node("AnimationPlayer").play_backwards("in")


func _on_control_mouse_exited_HOME() -> void:
	Button_Home.get_node("AnimationPlayer").play_backwards("in")


func _on_control_mouse_exited_DELETE() -> void:
	Button_Delete.get_node("AnimationPlayer").play_backwards("in")


func _on_control_mouse_exited_COMPLETE() -> void:
	Button_Complete.get_node("AnimationPlayer").play_backwards("in")
