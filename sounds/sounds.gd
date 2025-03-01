extends Node2D

var soundEffect = preload("res://sounds/sound_effect.tscn")


func Make_Sound_Effect(effectName) -> void:
	var se = soundEffect.instantiate()
	se.effectName = effectName
	get_tree().get_root().add_child.call_deferred(se)


#sound effects to add:
	#MAIN MENU - DONE:
		#hovering over any object (unique sound or just something satisfying?)
		#clicking cat: meow
		#clicking chest of drawers: zip noise
		#clicking window: curtains pulling/ opening
		#clicking fireplace: fire extinguished/ lit
		#clicking shelves/projects/door: funky noise
	#CHARACTER CUSTOMISATION - DONE:
		#clicking arrows: boop
		#clicking home: funky noise
	#CHOOSE FOCUS - DONE:
		#clicking arrows: boop
		#click animal: play respective animal's noise (bark, meow)
		#clicking home: funky noise
	#COMPLETED PROJECTS - DONE:
		#moving image: papery noise
		#clicking home: funky noise
	#GIFTS - DONE:
		#hovering over gift: clunky noise
		#trade: funky noise
	#FOCUS TIME:
		#maybe add birds and crickets then night time noise
	#END FOCUS:
		#none i think


#sounds.Sound_Effect("meow")
