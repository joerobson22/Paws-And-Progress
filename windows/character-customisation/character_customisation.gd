extends Node2D

@onready var Button_SkinTones = $Buttons/Skin_Tones
@onready var Button_HairColours = $Buttons/Hair_Colours

@onready var Scrollers = $Customisation_Scrollers

@onready var Human = $Display/Human
@onready var Aura = $Display/Aura


var currentAnimation : int = 0
var animations = ["RESET", "idle", "walk"]
var scrollerTypes = ["hat", "hair", "face" , "jumper", "neckwear", "handwear", "walking_stick", "trousers"]

signal char_cust_home_clicked

func _ready() -> void:
	$ColorRect.show()
	Aura.get_node("AnimationPlayer").play("idle")
	
	var i : int = 0
	for node in Button_SkinTones.get_node("Tones").get_children():
		global.skinColours.append(node.modulate)
		node.toneNumber = i
		node.customising = 0
		i += 1
	
	i = 0
	for node in Button_HairColours.get_node("Colours").get_children():
		global.hairColours.append(node.modulate)
		node.toneNumber = i
		node.customising = 1
		i += 1
	
	i = 0
	for node in Scrollers.get_children():
		node.scrollerType = scrollerTypes[i]
		node.scrollerNum = i
		node.Initialise()
		i += 1
	
	Human.Set_Appearance()



func _on_human_mouse_entered() -> void:
	$Display/AnimationPlayer.play("in")


func _on_human_mouse_exited() -> void:
	$Display/AnimationPlayer.play_backwards("in")


func update_human() -> void:
	Human.Set_Appearance()


func _on_home_button_pressed():
	emit_signal("char_cust_home_clicked")


func _on_human_pressed():
	currentAnimation += 1
	if currentAnimation > animations.size() - 1:
		currentAnimation = 0
	Human.get_node("Movement_AnimationPlayer").play(animations[currentAnimation])
