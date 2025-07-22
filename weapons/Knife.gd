# weapon_manager.gd
extends Node3D

@onready var gun = $Gun
@onready var knife = $Knife
@onready var weapon_animator = $WeaponAnimator

# This flag prevents us from shooting or starting another melee while one is in progress.
var is_in_quick_melee = false

func _ready():
	# Ensure the gun is visible and the knife is hidden at the start.
	gun.show()
	knife.hide()

func _unhandled_input(event: InputEvent):
	# Check if we pressed the button AND we are not already in a melee animation.
	if Input.is_action_just_pressed("weapon_switch") and not is_in_quick_melee:
		
		# Set the flag to true to lock other actions.
		is_in_quick_melee = true
		
		# Play our master animation.
		weapon_animator.play("Quick_Melee")
		
		# Wait until the animation is completely finished.
		await weapon_animator.animation_finished
		
		# Once finished, reset the flag so we can act again.
		is_in_quick_melee = false
