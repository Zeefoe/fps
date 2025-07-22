extends Node3D

@export var projectile_scene: PackedScene
@export var cooldown_duration: float = 0.5

@onready var hitscan_raycast: RayCast3D = $"../../HitscanRaycast"
@onready var melee_raycast: RayCast3D = $"../../MeleeRaycast"
@onready var animation_player = $AnimationPlayer
@onready var shoot_sound = $AudioStreamPlayer3D
@onready var cooldown_timer = $CooldownTimer
@onready var projectile_spawn_point = $ProjectileSpawnPoint

@onready var knife = $Knife 

var can_melee = true # Flag to prevent spamming the melee attack.

func _ready():
	cooldown_timer.one_shot = true
	knife.hide()

func _unhandled_input(event: InputEvent):
	if is_visible_in_tree() and Input.is_action_just_pressed("shoot") and cooldown_timer.is_stopped():
		shoot()
		
	if Input.is_action_just_pressed("melee_attack") and can_melee:
		can_melee = false
		print('yes')
		await quick_melee_attack()
		
		can_melee = true

func quick_melee_attack():
	knife.show()
	
	var knife_anim_player = knife.get_node("AnimationPlayer")
	
	knife_anim_player.play("handle_lowAction_001")
	melee_raycast.force_raycast_update() # Get the latest collision info.
	
	if melee_raycast.is_colliding():
		var collider = melee_raycast.get_collider()
		
		# We use the EXACT SAME logic as the gun!
		# If the thing we hit is a target, call its "hit" function.
		if collider.is_in_group("targets") and collider.has_method("hit"):
			collider.hit()
			print("Melee hit:", collider.name) # Optional: for debugging
			
	await knife_anim_player.animation_finished
	
	knife.hide()

func shoot():
	animation_player.play_section("SlideAction", 3.2667, 3.4167, -1, 1.0, false)
	shoot_sound.seek(1)
	shoot_sound.play()
	cooldown_timer.start(cooldown_duration)
	
	var hit_position: Vector3
	hitscan_raycast.force_raycast_update()
	
	if hitscan_raycast.is_colliding():
		var collider = hitscan_raycast.get_collider()
		hit_position = hitscan_raycast.get_collision_point()
		
		# Apply damage if we hit a valid target.
		if collider.is_in_group("targets") and collider.has_method("hit"):
			collider.hit()
	else:
		# If we hit nothing, aim the projectile far away.
		hit_position = hitscan_raycast.to_global(hitscan_raycast.target_position)

	# --- Spawn the visual projectile ---
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		get_tree().root.add_child(projectile)
		projectile.global_transform = projectile_spawn_point.global_transform
		projectile.look_at(hit_position)
