extends Node3D

@export var magazine_size: int = 8
@export var reserve_ammo: int = 30

@export var projectile_scene: PackedScene
@export var cooldown_duration: float = 0.5

@onready var hitscan_raycast: RayCast3D = $"../../HitscanRaycast"
@onready var melee_raycast: RayCast3D = $"../../MeleeRaycast"
@onready var animation_player = $AnimationPlayer
@onready var shoot_sound = $AudioStreamPlayer3D
@onready var cooldown_timer = $CooldownTimer
@onready var projectile_spawn_point = $ProjectileSpawnPoint
@onready var knife = $Knife 
@onready var slashsound = $slash

@onready var empty_sound = $EmptySound
@onready var reload_sound = $ReloadSound
@onready var ammo_label: Label = $"../../../../../UI/AmmoLabel"

var current_ammo: int
var can_melee = true
var is_reloading = false

func _ready():
	cooldown_timer.one_shot = true
	knife.hide()
	
	current_ammo = magazine_size
	update_ui()

func _unhandled_input(event: InputEvent):
	if not is_reloading and is_visible_in_tree() and Input.is_action_just_pressed("shoot") and cooldown_timer.is_stopped():
		shoot()
		
	if not is_reloading and Input.is_action_just_pressed("melee_attack") and can_melee:
		can_melee = false
		await quick_melee_attack()
		can_melee = true
		
	if Input.is_action_just_pressed("reload"):
		reload()

func reload():
	if is_reloading or current_ammo == magazine_size or reserve_ammo <= 0:
		return 
		
	is_reloading = true
	reload_sound.play()
	animation_player.play("MagazineAction") 
	
	await animation_player.animation_finished
	
	var needed_ammo = magazine_size - current_ammo
	var ammo_to_transfer = min(reserve_ammo, needed_ammo)
	
	current_ammo += ammo_to_transfer
	reserve_ammo -= ammo_to_transfer
	
	is_reloading = false
	update_ui()

func quick_melee_attack():
	knife.show()
	var knife_anim_player = knife.get_node("AnimationPlayer")
	knife_anim_player.play("handle_lowAction_001")
	slashsound.play()
	melee_raycast.force_raycast_update()
	if melee_raycast.is_colliding():
		var collider = melee_raycast.get_collider() 
		if collider.is_in_group("targets") and collider.has_method("hit"):
			collider.hit()
	await knife_anim_player.animation_finished
	knife.hide()

func shoot():
	if current_ammo > 0:
		current_ammo -= 1 
		
		animation_player.play_section("SlideAction", 3.2667, 3.4167, -1, 1.0, false)
		shoot_sound.seek(1)
		shoot_sound.play()
		cooldown_timer.start(cooldown_duration)
		
		var hit_position: Vector3
		hitscan_raycast.force_raycast_update()
		
		if hitscan_raycast.is_colliding():
			var collider = hitscan_raycast.get_collider()
			hit_position = hitscan_raycast.get_collision_point()
			if collider.is_in_group("targets") and collider.has_method("hit"):
				collider.hit()
		else:
			hit_position = hitscan_raycast.to_global(hitscan_raycast.target_position)

		if projectile_scene:
			var projectile = projectile_scene.instantiate()
			get_tree().root.add_child(projectile)
			projectile.global_transform = projectile_spawn_point.global_transform
			projectile.look_at(hit_position)
			
		update_ui()
			
	else:
		empty_sound.play()

func update_ui():
	if ammo_label:
		ammo_label.text = "%s / %s" % [current_ammo, reserve_ammo]
