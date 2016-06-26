
extends StreamPlayer


var current_music = ""


func play_music(music, loop=true):
	if current_music != music:
		current_music = music
		set_stream(load("res://music/" + music + ".ogg"))
		play()
		set_loop(loop)


