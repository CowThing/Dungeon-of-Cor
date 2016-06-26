
extends Sprite3D


onready var ply = get_node("/root/Main").get_player()


func set_clutter_type(table):
	#[{name, chance, billboard, roation}, ++]
	var clutter = GLOBAL.rand_choice(table)
	var tex = load("res://sprites/clutter/" + clutter["name"] + ".png")
	set_texture(tex)
	
	if clutter["billboard"]:
		set_offset(Vector2(tex.get_size().x * -0.5, 0))
		get_node("VisibilityNotifier").connect("enter_screen", self, "_on_VisibilityNotifier_enter_screen")
		get_node("VisibilityNotifier").connect("exit_screen", self, "_on_VisibilityNotifier_exit_screen")
	else:
		set_centered(true)
		set_axis(Vector3.AXIS_Y)
	
	if clutter["rotation"]:
		set_rotation(Vector3(0, deg2rad(randf() * 360), 0))


func _process(delta):
	var target = ply.get_translation()
	target.y = get_global_transform().origin.y
	look_at(target, Vector3(0, 1, 0))


func _on_VisibilityNotifier_enter_screen():
	set_process(true)


func _on_VisibilityNotifier_exit_screen():
	set_process(false)


