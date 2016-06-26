
extends Area


onready var ply = get_node("/root/Main").get_player()


func _on_Ladder_body_enter( body ):
	if body.is_in_group("Player"):
		DUNGEON_MANAGER.next_level()


func _process(delta):
	var target = ply.get_translation()
	target.y = get_node("Ladder").get_global_transform().origin.y
	get_node("Ladder").look_at(target, Vector3(0, 1, 0))


func _on_VisibilityNotifier_enter_screen():
	set_process(true)


func _on_VisibilityNotifier_exit_screen():
	set_process(false)


