
extends Area

var speed = 6.5
var damage = 3
var direction = Vector3()

var is_active = true


func _ready():
	pass


func _fixed_process(delta):
	set_translation(get_translation() + (direction * speed * delta))
	
	#check if fireball is inside a wall.
	var map_pos = MAP_MANAGER.get_map_pos(get_translation())
	if MAP_MANAGER.map[map_pos.x][map_pos.y].type != 1:
		queue_free()


func shoot(pos, dir):
	set_translation(pos)
	dir.y = 0
	direction = dir.normalized()
	
	set_fixed_process(true)


func _on_Fire_Ball_body_enter( body ):
	if is_active:
		if body.is_in_group("Player"):
			is_active = false
			body.take_damage(damage)
			queue_free()


