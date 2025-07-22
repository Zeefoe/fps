# weapon_manager.gd
extends Node3D

@onready var gun = $Gun
@onready var knife = $Knife

var is_in_quick_melee = false

func _ready():
	gun.show()
	knife.hide()

func _unhandled_input(event: InputEvent):
	if Input.is_action_just_pressed("weapon_switch") and not is_in_quick_melee:
		is_in_quick_melee = true
		
		print("--- MELEE START ---") # DEBUG
		
		gun.hide()
		knife.show()
		
		print("MANAGER: Calling knife's animation function...") # DEBUG
		await knife.play_stab_animation()
		print("MANAGER: Knife function has returned.") # DEBUG
		
		knife.hide()
		gun.show()
		
		is_in_quick_melee = false
		print("--- MELEE END ---") # DEBUG
