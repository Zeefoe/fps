# enemy.gd
extends CharacterBody3D

@export var speed: float = 4.0
@export var health: int = 100

# A reference to the player node
var player: Node3D
# A reference to the navigation agent node
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	# Find the player in the scene.
	# For this to work, your player node must be in a group called "player".
	# To do this, select your player, go to Node -> Groups, and add it.
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not is_instance_valid(player):
		# If the player is gone, stop moving.
		velocity = Vector3.ZERO
		return

	# Set the navigation agent's target to the player's current position.
	nav_agent.target_position = player.global_position
	
	# Get the next point on the calculated path.
	var next_path_position = nav_agent.get_next_path_position()
	
	# Calculate the direction from the enemy to that next point.
	var direction = global_position.direction_to(next_path_position)
	
	# Set the velocity and move.
	velocity = direction * speed
	move_and_slide()

# This function will be called by the projectile.
func take_damage(amount: int):
	health -= amount
	print("Enemy took damage, health is now: ", health)
	if health <= 0:
		queue_free() # Destroy the enemy if health is zero.
