
extends KinematicBody


onready var cameraNode = get_node("Yaw/Camera")

var view_sensitivity = 0.15 setget set_view_sensitivity
var yaw = 0
var pitch = 0

var holder_sway_ang = Vector3()

var velocity = Vector3()
var speed = 6

var health = 10 setget set_health

var attack_pressed = false
var can_attack = true

var is_moving = false
var is_attacking = false
var is_dead = false

var anim = "idle"


func _ready():
	set_process_input(true)
	set_fixed_process(true)
	set_process(true)
	
	CURSOR.set_cursor_mode(CURSOR.CURSOR_TYPE_CAPTURED)
	
	Input.warp_mouse_pos(OS.get_window_size()/2)
	
	cameraNode.set_perspective(GLOBAL.settings["fov"], 0.1, 100)
	set_view_sensitivity(GLOBAL.settings["view_sensitivity"])


func _input(event):
	if not is_dead:
		if event.type == InputEvent.MOUSE_MOTION and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			#pitch and yaw
			yaw = fmod(yaw - event.relative_x * view_sensitivity, 360)
			pitch = clamp(pitch - event.relative_y * view_sensitivity, -85, 85)
			
			holder_sway_ang += Vector3(event.relative_y, event.relative_x, 0)
			
#			var q = Quat(Vector3(0, 1, 0), deg2rad(yaw)) * Quat(Vector3(1, 0, 0), deg2rad(pitch))
#			var t = Transform(q)
#			t.origin = cameraNode.get_translation()
#			cameraNode.set_transform(t)
			
			get_node("Yaw").set_rotation(Vector3(0, deg2rad(yaw), 0))
			cameraNode.set_rotation(Vector3(deg2rad(pitch), 0, 0))
		
		if event.is_action_pressed("ATTACK1"):
			attack_pressed = true
		
		if event.is_action_released("ATTACK1"):
			attack_pressed = false
		
		if event.is_action_pressed("HUD_MAP"):
			get_node("SamplePlayer").play("button_press")
			get_node("HUD").toggle_map()
	
	if event.is_action_pressed("HUD_MENU"):
		get_node("HUD").toggle_menu()


func _fixed_process(delta):
	var movef = Input.is_action_pressed("MOVE_FOWARD")
	var moveb = Input.is_action_pressed("MOVE_BACK")
	var mover = Input.is_action_pressed("MOVE_RIGHT")
	var movel = Input.is_action_pressed("MOVE_LEFT")
	
	var dir = Vector3()
	
	if not is_dead:
		var aim = get_node("Yaw").get_transform().basis
		if movef:
			dir -= aim.z
		if moveb:
			dir += aim.z
		if mover:
			dir += aim.x
		if movel:
			dir -= aim.x
	
	dir.y = 0
	dir = dir.normalized() * speed
	
	if is_attacking:
		dir *= 0.25
	
	var nvel = velocity
	nvel = nvel.linear_interpolate(dir, 6 * delta)
	velocity = nvel
	
	var motion = move(velocity * delta)
	if is_colliding():
		motion = get_collision_normal().slide(motion)
		motion.y = 0
		move(motion)
	
	is_moving = movef or moveb or mover or movel


func _process(delta):
	if not is_dead:
		#sway weapon holder
		holder_sway_ang *= 0.5 * delta
		var ang = get_node("Yaw/Camera/Holder").get_rotation()
		var t_ang = ang.linear_interpolate(holder_sway_ang, 3 * delta)
		get_node("Yaw/Camera/Holder").set_rotation(t_ang)
		
		#attack
		if attack_pressed:
			do_attack()
		
		#animate
		if is_attacking:
			set_animation("attack")
			
		elif is_moving:
			set_animation("walk", 1.1)
			
		else:
			set_animation("idle")


func set_animation(n_anim, n_speed=1):
	get_node("AnimationPlayer").set_speed(n_speed)
	
	if anim != n_anim:
		anim = n_anim
		get_node("AnimationPlayer").play(anim)


func do_attack(dmg=1):
	if can_attack:
		get_node("Attack Timer").start()
		get_node("Attack Offset Timer").start()
		get_node("Can Attack Cooldown Timer").start()
		is_attacking = true
		can_attack = false
		
		#Attack
		yield(get_node("Attack Offset Timer"), "timeout")
		var enemies = get_node("Yaw/Attack Area").get_overlapping_bodies()
		for e in enemies:
			if e.is_in_group("Enemy"):
				yield(get_tree(), "idle_frame") #delay each hit 1 frame so enemies don't die same frame
				e.take_damage(dmg)


func take_damage(amnt):
	health -= amnt
	
	get_node("SamplePlayer").play("player_hurt")
	COLOR_MANAGER.animate_white("flash", Color("b52d1b"))
	get_node("HUD").set_health(health)
	
	if health <= 0:
		is_dead = true
		set_animation("death")
		get_node("HUD").death_menu()
		MUSIC.play_music("JRPG_gameOver", false)


func heal(amnt):
	set_health(min(health + amnt, 10))
	get_node("SamplePlayer").play("heal")
	COLOR_MANAGER.animate_white("flash", Color("59b32d"))


func _on_Attack_Timer_timeout():
	is_attacking = false


func _on_Can_Attack_Cooldown_Timer_timeout():
	can_attack = true


func set_health(amnt):
	health = amnt
	get_node("HUD").set_health(health)


func set_view_sensitivity(num):
	view_sensitivity = (num / 100.0)


