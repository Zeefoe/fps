extends Node3D

@export var speed: float = 5000

# The destination for the projectile, set by the gun that fires it.
var target_position: Vector3

@onready var lifetime_timer = $Timer

func _ready():
	# Look towards the target position when spawned
	look_at(target_position)
	# Start the self-destruct timer
	lifetime_timer.start()

func _physics_process(delta):
	# Move towards the target position at a constant speed
	var distance_to_target = global_position.distance_to(target_position)
	
	# If we are very close to the target, destroy the projectile
	# This prevents it from overshooting slightly
	if distance_to_target < 1.0:
		queue_free()
		return
		
	# Move forward in the direction we are facing
	global_position += -global_transform.basis.z * speed * delta

# This function is called when the lifetime Timer finishes.
func _on_timer_timeout():
	queue_free()
