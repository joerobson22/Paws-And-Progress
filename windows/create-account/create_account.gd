extends Node2D

var MainMenuScene : String = "res://windows/main/main_menu.tscn"

@onready var Username_TextEdit = $CanvasLayer/Centre/Username_Enter_TextEdit/TextEdit

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	#load data
	var outcome : int = save.load_data()
	if outcome == -1:
		print("File does not exist")
		$CanvasLayer/Centre/Transition.hide()
		for p in global.animals:
			var i : int = 0
			while i < 3:
				if global.testing:
					global.gifts.append(40)
				else:
					global.gifts.append(0)
				i += 1
	elif outcome == 0:
		print("Error while reading data")
		get_tree().quit()
	elif outcome == 1:
		print("Data read successfully")
		if global.gifts.size() < global.numAnimals * 3:
			var diff : int = (global.numAnimals * 3) - global.gifts.size()
			var i : int = 0
			while i < diff:
				if global.testing:
					global.gifts.append(40)
				else:
					global.gifts.append(0)
				i += 1
		global.showTransition = true
		get_tree().change_scene_to_file(MainMenuScene)




func _on_button_pressed_ENTER() -> void:
	if Username_TextEdit.text != "":
		$CanvasLayer/Centre/Transition.show()
		$CanvasLayer/Centre/Transition/AnimationPlayer.play("out")


func _on_transition_done():
	global.username = Username_TextEdit.text
	global.showTransition = true
	get_tree().change_scene_to_file(MainMenuScene)
