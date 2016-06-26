
extends Control


var n_settings = {
	view_sensitivity = 0,
	fov = 0,
	music_vol = 0,
	sound_vol = 0
}


func _ready():
	CURSOR.set_cursor_mode(CURSOR.CURSOR_TYPE_VISIBLE)
	GLOBAL.load_settings()
	for k in GLOBAL.settings.keys():
		n_settings[k] = GLOBAL.settings[k]
		get_node("Settings/Container/" + k).set_value(n_settings[k])


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		save_new_settings()


func save_new_settings():
	for k in n_settings.keys():
		n_settings[k] = get_node("Settings/Container/" + k).get_value()
	
	GLOBAL.save_settings(n_settings)


func _on_Start_Button_pressed():
	get_node("SamplePlayer").play("button_press")
	save_new_settings()
	MAP_MANAGER.set_seed(get_node("Game Start/SeedInput").get_text())
	get_tree().change_scene("res://scenes/main_game.scn")


func _on_Game_Start_Back_Button_pressed():
	get_node("SamplePlayer").play("button_press")
	get_node("Game Start").hide()
	get_node("Main").show()


func _on_Info_Back_Button_pressed():
	get_node("SamplePlayer").play("button_press")
	get_node("Info").hide()
	get_node("Main").show()


func _on_Settings_Back_Button_pressed():
	get_node("SamplePlayer").play("button_press")
	get_node("Settings").hide()
	get_node("Main").show()


func _on_To_Start_Button_pressed():
	get_node("SamplePlayer").play("button_press")
	get_node("Main").hide()
	get_node("Game Start").show()


func _on_To_Info_pressed():
	get_node("SamplePlayer").play("button_press")
	get_node("Main").hide()
	get_node("Info").show()


func _on_To_Settings_Button_pressed():
	get_node("SamplePlayer").play("button_press")
	get_node("Main").hide()
	get_node("Settings").show()


func _on_Quit_Button_pressed():
	get_node("SamplePlayer").play("button_press")
	save_new_settings()
	get_tree().quit()


func _on_Main_Menu_enter_tree():
	MUSIC.play_music("JRPG_mainTheme")
	DUNGEON_MANAGER.leave_dungeon()


func _on_sound_vol_value_changed( value ):
	AudioServer.set_fx_global_volume_scale(value / 100)


func _on_music_vol_value_changed( value ):
	AudioServer.set_stream_global_volume_scale(value / 100)


