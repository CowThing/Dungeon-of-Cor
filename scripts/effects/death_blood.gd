
extends Sprite3D


onready var ply = get_node("/root/Main").get_player()


func _ready():
	set_rotation(Vector3(0, deg2rad(randf() * 360), 0))


func _process(delta):
	var target = ply.get_translation()
	target.y = get_node("Death Sprite").get_global_transform().origin.y
	get_node("Death Sprite").look_at(target, Vector3(0, 1, 0))


func set_death_sprite(tex):
	get_node("Death Sprite").set_texture(tex)
	get_node("Death Sprite").set_offset(Vector2(tex.get_size().x * -0.5, 0))


func _on_VisibilityNotifier_enter_screen():
	set_process(true)


func _on_VisibilityNotifier_exit_screen():
	set_process(false)
