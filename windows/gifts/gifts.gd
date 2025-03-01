extends Node2D

@onready var Button_Home = $CanvasLayer/HBoxContainer/Buttons/Home

@onready var Give_Gift = $CanvasLayer/HBoxContainer/Gift

var mouse_in : int = 0

var Main_Menu_Scene : String = "res://windows/main/main_menu.tscn"

var gift = preload("res://windows/gifts/gift.tscn")

var gifts = []

var givingNewGift : bool = false

func _ready() -> void:
	for g in gifts:
		g.queue_free()
	gifts.clear()
	#run through all gifts in global.gifts
	#generate a new gift object at sequential positions
	var i : int = 0 #keeps track of what gift in global.gifts array we're on
	var j : int = 0 #indexes into global.animals array
	var k : int = 0 #indexes into the array inside the global.animalGifts dictionary
	var pos : int = 1
	for g in global.gifts:
		if g > 0:
			var instance = gift.instantiate()
			instance.giftNum = i
			instance.quantity = g
			instance.giftName = global.animalGifts[global.animals[j]][k]
			instance.z_index = 3
			instance.rarityNum = k
			instance.scale.x = 0.85
			instance.scale.y = 0.85
			
			gifts.append(instance)
			
			get_node("CanvasLayer/HBoxContainer/Positions/Pos" + type_convert(pos, TYPE_STRING)).add_child(instance)
			pos += 1
		k += 1
		if k % 3 == 0:
			k = 0
			j += 1
		i += 1
	#gift objects allow you to hover over them with mouse
	#view how many you have
	
	#trading??


func _process(_delta: float) -> void:
	if global.giveNewGift:
		Give_New_Gift()


func Give_New_Gift() -> void:
	sounds.Make_Sound_Effect("trade")
	givingNewGift = true
	global.giveNewGift = false
	var canGiveNewGift : bool = false
	var newGift : int
	var newGiftNum : int
	#first check if there is a new higher rarity item
	var i : int = global.newGiftRarity
	while i < global.gifts.size():
		if global.gifts[i] == 0:
			canGiveNewGift = true
			break
		i += 3
	#give new gift
	var valid : bool = false
	while !valid:
		newGiftNum = global.Generate_Random(0, global.animals.size() - 1)
		newGift = newGiftNum * 3
		newGift += global.newGiftRarity
		if global.gifts[newGift] == 0 or !canGiveNewGift:
			valid = true
			global.gifts[newGift] += 1
	#display
	Give_Gift.get_node("You_Received_Label/Label").text = "You received a..."
	Give_Gift.get_node("Gift_Label/Label").text = global.animalGifts[global.animals[newGiftNum]][global.newGiftRarity]
	var rarities = ["common", "rare", "epic"]
	Give_Gift.get_node("Gift").frame = newGift
	Give_Gift.get_node("Shine/AnimationPlayer2").play(rarities[global.newGiftRarity])
	Give_Gift.get_node("Shine/AnimationPlayer").play("wiggle")
	
	Give_Gift.show()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if givingNewGift:
			sounds.Make_Sound_Effect("button_click2")
			givingNewGift = false
			Give_Gift.hide()
			_ready()
		
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
