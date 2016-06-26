
extends Node


var cur_pointer = preload("res://sprites/gui/cursor.png")
var cur_cross = preload("res://sprites/gui/crosshair.png")

var CURSOR_TYPE_VISIBLE = 1
var CURSOR_TYPE_HIDDEN = 2
var CURSOR_TYPE_CAPTURED = 3
var CURSOR_TYPE_CAPTURED_HIDDEN = 4

onready var cursor_sprite_node = get_node("Cursor Sprite")


func _ready():
	set_cursor_mode(CURSOR_TYPE_HIDDEN)


func set_cursor_mode(n_type):
	if n_type == CURSOR_TYPE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		set_process(true)
		cursor_sprite_node.set_texture(cur_pointer)
		cursor_sprite_node.set_centered(false)
		cursor_sprite_node.set_pos(get_viewport().get_mouse_pos())
		
	elif n_type == CURSOR_TYPE_HIDDEN:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		set_process(false)
		cursor_sprite_node.set_texture(null)
		cursor_sprite_node.set_centered(false)
		cursor_sprite_node.set_pos(Vector2(0, 0))
		
	elif n_type == CURSOR_TYPE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		set_process(false)
		cursor_sprite_node.set_texture(cur_cross)
		cursor_sprite_node.set_centered(true)
		cursor_sprite_node.set_pos(get_viewport().get_rect().size * 0.5)
		
	elif n_type == CURSOR_TYPE_CAPTURED_HIDDEN:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		set_process(false)
		cursor_sprite_node.set_texture(null)
		cursor_sprite_node.set_centered(false)
		cursor_sprite_node.set_pos(Vector2(0, 0))


func _process(delta):
	cursor_sprite_node.set_pos(get_viewport().get_mouse_pos())


