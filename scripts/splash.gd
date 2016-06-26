
extends Control


func _ready():
	set_process_input(true)


func _input(event):
	if event.type == InputEvent.KEY and event.pressed:
		anim_end()


func start_music():
	MUSIC.play_music("JRPG_mainTheme")


func anim_end():
	get_tree().change_scene("res://scenes/main_menu.scn")


