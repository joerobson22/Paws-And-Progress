extends Node2D

@onready var Button_Home = $CanvasLayer/HBoxContainer/Buttons/Home

var mouse_in : int = 0
var Main_Menu_Scene : String = "res://windows/main/main_menu.tscn"

var projectImage = preload("res://windows/completed-projects/completed_project.tscn")

var page : int = 0
var totalPages : int = ceil(float(global.totalCompletedProjects) / 20)

var allImages = []

func _ready() -> void:
	#run through all completed projects and create a new image for each one
	Display_Page()


func Display_Page() -> void:
	for n in allImages:
		n.queue_free()
	allImages.clear()
	
	var j : int = page * 20
	var i : int = 0
	var k : int = 0
	for p in global.completedProjects:
		if i < 20 and k >= j:
			Add_Project_Image(p, i)
			i += 1
		elif i >= 20:
			break
		k += 1
	Update_Arrows()


func Add_Project_Image(p, i):
	var instance = projectImage.instantiate()
	instance.project = p
	instance.z_index = 3
	instance.scale.x = 0.5
	instance.scale.y = 0.5
	instance.projectNum = i
	get_node("CanvasLayer/HBoxContainer/Positions/Pos" + type_convert(i + 1, TYPE_STRING)).add_child(instance)
	allImages.append(instance)


func Update_Arrows() -> void:
	if page > 0:
		#show left arrow
		$CanvasLayer/HBoxContainer/Buttons/Left_Arrow.show()
	else:
		#hide left arrow
		$CanvasLayer/HBoxContainer/Buttons/Left_Arrow.hide()
	
	if page < totalPages - 1:
		#show right arrow
		$CanvasLayer/HBoxContainer/Buttons/Right_Arrow.show()
	else:
		#hide right arrow
		$CanvasLayer/HBoxContainer/Buttons/Right_Arrow.hide()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if mouse_in == 1:
			global.showTransition = false
			sounds.Make_Sound_Effect("button_click2")
			get_tree().change_scene_to_file(Main_Menu_Scene)
			queue_free()
		else:
			pass


func _on_control_mouse_entered_HOME() -> void:
	mouse_in = 1
	Button_Home.get_node("AnimationPlayer").play("in")


func _on_control_mouse_exited_HOME() -> void:
	mouse_in = 0
	Button_Home.get_node("AnimationPlayer").play_backwards("in")


func _on_left_arrow_pressed():
	sounds.Make_Sound_Effect("button_click2")
	page -= 1
	Display_Page()


func _on_left_arrow_mouse_entered():
	$CanvasLayer/HBoxContainer/Buttons/Left_Arrow/AnimationPlayer.play("in")


func _on_left_arrow_mouse_exited():
	$CanvasLayer/HBoxContainer/Buttons/Left_Arrow/AnimationPlayer.play_backwards("in")


func _on_right_arrow_pressed():
	sounds.Make_Sound_Effect("button_click2")
	page += 1
	Display_Page()


func _on_right_arrow_mouse_entered():
	$CanvasLayer/HBoxContainer/Buttons/Right_Arrow/AnimationPlayer.play("in")


func _on_right_arrow_mouse_exited():
	$CanvasLayer/HBoxContainer/Buttons/Right_Arrow/AnimationPlayer.play_backwards("in")
