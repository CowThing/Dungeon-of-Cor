
extends Node


export(float) var animated_color_white = 0
export(float) var animated_color_black = 0

onready var ColorMat = get_node("BackBufferCopy/Color Shader").get_material()

export var WhiteColor = Color("456975")
export var BlackColor = Color("28354a")
var temp_WhiteColor = WhiteColor
var temp_BlackColor = BlackColor


func _ready():
	ColorMat.set_shader_param("Color_White", WhiteColor)
	ColorMat.set_shader_param("Color_Black", BlackColor)
	
	get_tree().connect("screen_resized", self, "on_screen_resized")
	on_screen_resized()


func _process(delta):
	ColorMat.set_shader_param("Color_White", hsv_lerp(WhiteColor, temp_WhiteColor, animated_color_white))


func animate_white(n_anim, tcol):
	set_process(true)
	temp_WhiteColor = tcol
	get_node("AnimationPlayer").play("white_" + n_anim, 0.1)


func end_color_animation():
	set_process(false)


func set_colors(c_w, c_b):
	WhiteColor = c_w
	BlackColor = c_b
	
	ColorMat.set_shader_param("Color_White", WhiteColor)
	ColorMat.set_shader_param("Color_Black", BlackColor)


func hsv_lerp(cola, colb, t):
	var h
	var ha = cola.h
	var hb = colb.h
	var d = hb - ha
	if ha <= hb:
		if d > 0.5:
			h = fmod(lerp(ha + 1, hb, t), 1)
		else:
			h = lerp(ha, hb, t)
	else:
		d = -d
		if d > 0.5:
			h = fmod(lerp(ha, hb + 1, t), 1)
		else:
			h = lerp(ha, hb, t)
	
	var newcol = Color()
	newcol.v = lerp(cola.v, colb.v, t)
	newcol.s = lerp(cola.s, colb.s, t)
	newcol.h = h
	
	newcol = newcol.linear_interpolate(cola.linear_interpolate(colb, t), 0.5)
	
	return newcol


func on_screen_resized():
	var minsize = Vector2(1024, 720)
	var winsize = OS.get_window_size()
	var newwinsize = Vector2(max(minsize.x, winsize.x), max(minsize.y, winsize.y))
	OS.set_window_size(newwinsize)
	
	get_node("BackBufferCopy/Color Shader").set_size(newwinsize)


