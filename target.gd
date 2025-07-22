# target.gd
extends StaticBody3D

## The number of hits the target can take before breaking.
## You can change this in the Inspector for each target you place.
@export var health: int = 1

@onready var hit_sound = $HitSound

# This is the function our projectile will call.
func hit():
	# Decrement health by 1.
	health -= 1

	# Play the hit sound if it exists.
	if hit_sound:
		hit_sound.play()

	# If health is 0 or less, destroy the target.
	if health <= 0:
		# queue_free() safely removes the node at the end of the frame.
		queue_free()
