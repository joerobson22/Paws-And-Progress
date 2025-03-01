extends Node2D

var mouse_in : int = 0
var frames : int
var frame : int = 0
var scrollerType : String
var scrollerNum : int

var quantities = {
	"hat" : [1, 1, 1, 1, global.gifts[14], global.gifts[26], 0, 0],
	"hair" : [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0],
	"face" : [1, 1, 1, 1, 1, 1],
	"jumper" : [1, 1, 1, 1, 1, global.gifts[2], global.gifts[23], 0],
	"neckwear" : [1, global.gifts[8], global.gifts[29], 0, 0, 0, 0, 0],
	"handwear" : [1, global.gifts[11], global.gifts[20], 0],
	"walking_stick" : [1, global.gifts[5], global.gifts[17], 0],
	"trousers" : [1, 1, 1, 0]
}

var numFrames = {
	"hat" : 8,
	"hair" : 16,
	"face" : 6,
	"jumper" : 8,
	"neckwear" : 8,
	"handwear" : 4,
	"walking_stick" : 4,
	"trousers" : 4
}

signal update_human

func _ready() -> void:
	pass


func Initialise() -> void:
	#sets all values and frames corresponding to the scrollerNum and scrollerType
	#assigned to by parent
	$Style/AnimationPlayer.play(scrollerType)
	frames = numFrames[scrollerType] - 1
	frame = global.cosmetics[scrollerNum]
	$Style.hframes = frames + 1
	$Style.frame = frame
	emit_signal("update_human")


func Update() -> void:
	#updates frame and global variable
	$Style.frame = frame
	global.cosmetics[scrollerNum] = frame
	emit_signal("update_human")



func Scroll(change : int) -> void:
	sounds.Make_Sound_Effect("button_click1")
	#use dictionary 'quantities'
	#get current frame
	#change frame by 'change'
		#is next frame quantity > 0?
		#if not, then keep changing
		#otherwise, break
	var valid : bool = false
	while !valid:
		frame += change
		if frame < 0:
			frame = frames
		elif frame > frames:
			frame = 0
		
		if quantities[scrollerType][frame] > 0:
			valid = true
	
	if scrollerType == "hat" and frame > 0:
		#if changed hat, and has short hair (global.hair < 5)
		#then set hair to buzz cut for simplicity
		if global.hair > 1 && global.hair < 8:
			global.cosmetics[1] = 1
		get_parent().get_node("Hair_Scroller").Initialise()
	
	if scrollerType == "hair":
		#if changed hair to a short length, and has a hat on
		#take off the hat
		if frame > 1 && frame < 8:
			global.cosmetics[0] = 0
		get_parent().get_node("Hat_Scroller").Initialise()
	
	Update()


func _on_left_mouse_entered() -> void:
	mouse_in = 1
	$Arrows/Left_Arrow/AnimationPlayer.play("in")


func _on_left_mouse_exited() -> void:
	mouse_in = 0
	$Arrows/Left_Arrow/AnimationPlayer.play_backwards("in")


func _on_right_mouse_entered() -> void:
	mouse_in = 2
	$Arrows/Right_Arrow/AnimationPlayer.play("in")


func _on_right_mouse_exited() -> void:
	mouse_in = 0
	$Arrows/Right_Arrow/AnimationPlayer.play_backwards("in")


func _on_left_pressed():
	Scroll(-1)


func _on_right_pressed():
	Scroll(1)
