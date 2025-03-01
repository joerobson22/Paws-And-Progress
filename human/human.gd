extends Node2D

@onready var Legs = $Legs
@onready var Arms = $Arms
@onready var Body = $Body
@onready var Hair = $Body/Hair
@onready var Face = $Body/Face/Sprite2D
@onready var Jumper = $Body/Jumper/Sprite2D
@onready var Hat = $Body/Hat/Sprite2D
@onready var Neckwear = $Body/Neckwear/Sprite2D
@onready var Handwear = $Arms/Forearm/Forearm_Forearm/Handwear

@onready var Skin_Legs = $Legs/Skin
@onready var Skin_Body = $Body/Skin


func Set_Appearance() -> void:
	#set global variables
	global.hat = global.cosmetics[0]
	global.hair = global.cosmetics[1]
	global.face = global.cosmetics[2]
	global.jumper = global.cosmetics[3]
	global.neckwear = global.cosmetics[4]
	global.handwear = global.cosmetics[5]
	global.walking_stick = global.cosmetics[6]
	global.trousers = global.cosmetics[7]
	
	#set skin colour
	Skin_Body.modulate = global.skinColours[global.skinColour]
	Arms.get_node("Backarm/Backarm_Bicep").self_modulate = global.skinColours[global.skinColour]
	Arms.get_node("Backarm/Backarm_Forearm").self_modulate = global.skinColours[global.skinColour]
	Arms.get_node("Forearm/Forearm_Bicep").self_modulate = global.skinColours[global.skinColour]
	Arms.get_node("Forearm/Forearm_Forearm").self_modulate = global.skinColours[global.skinColour]
	Skin_Legs.get_node("Backleg").self_modulate = global.skinColours[global.skinColour]
	Skin_Legs.get_node("Foreleg").self_modulate = global.skinColours[global.skinColour]
	
	#set hair colour
	Hair.modulate = global.hairColours[global.hairColour]
	
	#set hair style
	Hair.get_node("Sprite2D").frame = global.hair
	
	#set hat
	Hat.frame = global.hat
	
	#set face
	Face.frame = global.face
	
	#set jumper
	Jumper.frame = global.jumper
	Arms.get_node("Backarm/Backarm_Bicep/Jumper").frame = global.jumper
	Arms.get_node("Backarm/Backarm_Forearm/Jumper").frame = global.jumper
	Arms.get_node("Forearm/Forearm_Bicep/Jumper").frame = global.jumper
	Arms.get_node("Forearm/Forearm_Forearm/Jumper").frame = global.jumper
	
	#set trousers
	Skin_Legs.get_node("Backleg/Trouser").frame = global.trousers
	Skin_Legs.get_node("Foreleg/Trouser").frame = global.trousers
	
	#set accessories
	#set neckwear
	Neckwear.frame = global.neckwear
	
	#set handwear
	Handwear.frame = global.handwear
	
	#setup walking stick
	if global.walking_stick > 0:
		Arms.get_node("Forearm/Forearm_Forearm/Walking_Stick").show()
		Arms.get_node("Forearm/AnimationPlayer").play("walking_stick")
		Arms.get_node("Forearm/Forearm_Forearm/Walking_Stick").frame = global.walking_stick
	else:
		Arms.get_node("Forearm/Forearm_Forearm/Walking_Stick").hide()
		Arms.get_node("Forearm/AnimationPlayer").play("RESET")
