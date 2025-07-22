# ball.gd

# This registers "Ball" as a new type in your project, which is essential
# for the gun script to know about the shoot() function.
class_name Ball
extends RigidBody3D

# The forward speed of the ball.
@export var speed = 75.0

# This function is called by the gun that spawns the ball.
# It receives the gun's muzzle transform to know where to start and in what direction to go.
func shoot(spawn_transform: Transform3D):
	# Set the ball's global position and rotation to match the spawner.
	self.global_transform = spawn_transform
	
	# Apply a single, strong forward push (an impulse) to the ball.
	# -transform.basis.z is the local "forward" direction in Godot 3D.
	apply_central_impulse(-global_transform.basis.z * speed)
	
	# To prevent the game from filling up with thousands of balls,
	# we create a timer that will automatically delete the ball after 5 seconds.
	var lifetime_timer = Timer.new()
	lifetime_timer.wait_time = 5.0
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(queue_free) # queue_free() safely deletes the node.
	add_child(lifetime_timer)
	lifetime_timer.start()
