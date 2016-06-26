
extends KinematicBody


var death_blood_scene = preload("res://scenes/effects/death_blood.scn")
var smoke_scene = preload("res://scenes/effects/smoke.scn")

onready var navigation = get_parent()
onready var ply = get_node("/root/Main").get_player()

export(ImageTexture) var death_sprite
export var speed = 2
export var max_hp = 3
export var ranged_attack = false
export var attack_distance = 1.5
export var attack_damage = 1

var velocity = Vector3()

onready var health = max_hp

var ai_home_position = Vector3()

var ai_can_attack = true
var ai_can_see_player = false
var ai_player_in_range = false
var ai_player_in_max_range = false

var attack_can_hit_player = false

var is_moving = false
var is_attacking = false

var anim = "idle"

var current_state = 0
var next_state = 0

const AI_STATE_IDLE = 0
const AI_STATE_TARGETING = 1
const AI_STATE_DAMAGE_STUN = 2


func _ready():
	ai_home_position = get_translation()
	set_fixed_process(true)
	
	#Reset shapes so that inherited enemies can have their own collisions
	clear_shapes()
	var col = get_node("CollisionShape")
	add_shape(col.get_shape(), col.get_transform())
	
	var areas = ["Yaw/Attack Area", "Detect Area", "Max Range Area"]
	for a in areas:
		get_node(a).clear_shapes()
		var col = get_node(a + "/CollisionShape")
		get_node(a).add_shape(col.get_shape(), col.get_transform())


func _fixed_process(delta):
	var dir = Vector3()
	is_moving = false
	
	if current_state == AI_STATE_IDLE:
		if ai_player_in_range and not ply.is_dead:
			set_state(AI_STATE_TARGETING)
		
		if ai_can_see_player and not ply.is_dead:
			if ai_player_in_max_range:
				set_state(AI_STATE_TARGETING)
		
		var points = navigation.get_simple_path(get_translation(), ai_home_position)
		if points.size() > 1:
			var distance = (get_translation() - ai_home_position).length()
			if distance > 1:
				dir = (points[1] - get_translation())
				is_moving = true
		
	elif current_state == AI_STATE_TARGETING:
		if ply.is_dead:
			set_state(AI_STATE_IDLE)
		
		var ss = get_world().get_direct_space_state()
		var ofs = Vector3(0, 1, 0)
		var results = ss.intersect_ray(get_translation() + ofs, ply.get_translation() + ofs, [self])
		
		if not ai_can_see_player:
			if not results.empty():
				ai_can_see_player = results.collider == ply
		
		if ai_can_see_player:
			var distance = (ply.get_translation() - get_translation()).length()
			
			var opt = false
			if not results.empty():
				opt = results.collider == ply
			
			var points = navigation.get_simple_path(get_translation(), ply.get_translation(), opt)
			if points.size() > 1 and distance > attack_distance:
				dir = (points[1] - get_translation())
				is_moving = true
			
			if distance <= attack_distance:
				if ai_can_attack:
					do_attack()
		
		if not ai_player_in_max_range:
			ai_can_see_player = false
			set_state(AI_STATE_IDLE)
		
	elif current_state == AI_STATE_DAMAGE_STUN:
		dir = (get_translation() - ply.get_translation())
	
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
	
	current_state = next_state


func _process(delta):
	var target = ply.get_translation()
	target.y = get_node("Yaw").get_global_transform().origin.y
	get_node("Yaw").look_at(target, Vector3(0, 1, 0))
	
	if current_state == AI_STATE_IDLE:
		if is_moving:
			set_animation("walk")
		else:
			set_animation("idle")
		
	elif current_state == AI_STATE_TARGETING:
		if is_attacking:
			set_animation("attack")
		elif is_moving:
			set_animation("walk")
		else:
			set_animation("idle")
		
	elif current_state == AI_STATE_DAMAGE_STUN:
		set_animation("damage stun")


func set_animation(n_anim, n_speed=1):
	get_node("AnimationPlayer").set_speed(n_speed)
	
	if anim != n_anim:
		anim = n_anim
		get_node("AnimationPlayer").play(anim)


func set_state(n_state):
	next_state = n_state


func do_attack():
	if not is_attacking:
		get_node("AI Attack Cooldown Timer").start()
		ai_can_attack = false
		
		get_node("Attack Timer").start()
		get_node("Attack Offset Timer").start()
		is_attacking = true
		
		#Attack
		yield(get_node("Attack Offset Timer"), "timeout")
		if is_attacking:
			if not ranged_attack:
				if attack_can_hit_player:
					ply.take_damage(attack_damage)
				
			else:
				var fireball = preload("res://scenes/effects/fireball.scn").instance()
				fireball.shoot(get_translation() + Vector3(0, 1, 0), ply.get_translation() - get_translation())
				get_parent().add_child(fireball)


func take_damage(amnt):
	get_node("AI Damage Stun Timer").start()
	set_state(AI_STATE_DAMAGE_STUN)
	is_attacking = false
	
	health -= amnt
	
	get_node("SpatialSamplePlayer").play("enemy_hurt")


func _on_Detect_Area_body_enter( body ):
	if body.is_in_group("Player"):
		ai_player_in_range = true


func _on_Detect_Area_body_exit( body ):
	if body.is_in_group("Player"):
		ai_player_in_range = false


func _on_Max_Range_Area_body_enter( body ):
	if body.is_in_group("Player"):
		ai_player_in_max_range = true


func _on_Max_Range_Area_body_exit( body ):
	if body.is_in_group("Player"):
		ai_player_in_max_range = false


func _on_Attack_Timer_timeout():
	is_attacking = false


func _on_AI_Attack_Cooldown_Timer_timeout():
	ai_can_attack = true


func _on_Attack_Area_body_enter( body ):
	if body.is_in_group("Player"):
		attack_can_hit_player = true


func _on_Attack_Area_body_exit( body ):
	if body.is_in_group("Player"):
		attack_can_hit_player = false


func _on_AI_Damage_Stun_Timer_timeout():
	if health <= 0:
		var last_enemy = DUNGEON_MANAGER.check_dungeon_end()
		DUNGEON_MANAGER.add_kill()
		
		if not last_enemy:
			var dbe = death_blood_scene.instance()
			dbe.set_death_sprite(death_sprite)
			dbe.set_translation(get_translation())
			get_parent().add_child(dbe)
		
		var se = smoke_scene.instance()
		se.set_translation(get_translation())
		get_parent().add_child(se)
		
		queue_free()
		
	else:
		set_state(AI_STATE_IDLE)


func _on_VisibilityNotifier_enter_screen():
	set_process(true)


func _on_VisibilityNotifier_exit_screen():
	set_process(false)


