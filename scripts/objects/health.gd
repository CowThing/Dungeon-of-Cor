
extends Area


onready var ply = get_node("/root/Main").get_player()


func _ready():
	set_process(true)


func _process(delta):
	var target = ply.get_translation()
	target.y = get_global_transform().origin.y
	look_at(target, Vector3(0, 1, 0))


func _on_Health_Potion_body_enter( body ):
	if body.is_in_group("Player"):
		if not body.is_dead:
			if body.health < 10:
				body.heal(3)
				queue_free()


