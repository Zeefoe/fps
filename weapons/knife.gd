# knife.gd
class_name Knife
extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var slashsound = $slash

func _ready():
	# This function will print the scene tree from this script's point of view.
	print("--- Tree structure from knife.gd's perspective: ---")
	print_tree()
	print("--------------------------------------------------")
	
	# We'll also check if the variable is null right here.
	if animation_player == null:
		print("CRITICAL ERROR: 'animation_player' is NULL inside _ready(). The path '$AnimationPlayer' is wrong from my location.")
	else:
		print("SUCCESS: 'animation_player' was found successfully.")


func play_stab_animation():
	# The script will crash on the next line if animation_player is null
	animation_player.play("handle_lowAction_001")
	slashsound.play()
	await animation_player.animation_finished
