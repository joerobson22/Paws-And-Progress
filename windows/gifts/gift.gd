extends Node2D

@onready var Label_ItemName = $Item_Information/Panel/Item_Name_Label
@onready var Label_ItemDescription = $Item_Information/Panel/Item_Description_Label
@onready var Label_TradeRequirements = $Item_Information/Panel/Trade_Requirements_Label
@onready var Progress_Bar = $Item_Information/Panel/ProgressBar
@onready var Panel_AnimationPlayer = $Item_Information/Panel/AnimationPlayer
@onready var Animation_Player = $AnimationPlayer
@onready var Sprite = $Sprite2D



var rarityNum : int
var rarities = ["common", "rare", "epic"]
var giftNum : int
var giftName : String
var giftDescription : String

var tradeRequirements = [20, 10, 2]

var quantity : int

var mouse_in : bool = false

func _ready() -> void:
	giftDescription = global.giftDescriptions[giftName]
	Label_ItemName.text = giftName
	Label_ItemDescription.text = giftDescription
	Sprite.frame = giftNum
	Panel_AnimationPlayer.play(rarities[rarityNum])
	
	Label_TradeRequirements.text = "You have: " + type_convert(quantity, TYPE_STRING) + "/" + type_convert(tradeRequirements[rarityNum], TYPE_STRING) + " to trade"
	if quantity >= tradeRequirements[rarityNum]:
		Progress_Bar.get_node("AnimationPlayer").play("highlight")
	Progress_Bar.max_value = tradeRequirements[rarityNum]
	Progress_Bar.value = quantity


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and mouse_in:
		if quantity >= tradeRequirements[rarityNum]:
			#give new random gift of higher rarity
			#decrease quantity of gift
			quantity -= tradeRequirements[rarityNum]
			global.gifts[giftNum] = quantity
			
			global.newGiftRarity = 2
			global.giveNewGift = true


func _on_control_mouse_entered() -> void:
	sounds.Make_Sound_Effect("wood4")
	mouse_in = true
	Animation_Player.play("in")


func _on_control_mouse_exited() -> void:
	sounds.Make_Sound_Effect("wood1")
	mouse_in = false
	Animation_Player.play_backwards("in")
