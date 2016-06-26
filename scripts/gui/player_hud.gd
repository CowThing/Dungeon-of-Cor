
extends Control


onready var owner = get_parent()
onready var player_sprite = get_node("Map Popup/2DMap/TileMap/Player Sprite")

var map_vis_rect = Rect2(0, 0, 11, 11)
var old_ply_pos = Vector2()


func _ready():
	#set_health(DUNGEON_MANAGER.player_health)
	get_node("Menu Popup/Container/Seed/Seed Button").set_text(str(MAP_MANAGER.current_seed))
	get_node("Menu Popup/Container/Dungeon Floor").set_text("Floor: " + str(DUNGEON_MANAGER.dungeon_level))
	update_kills()
	
	for x in range(MAP_MANAGER.MAP_WIDTH):
		for y in range(MAP_MANAGER.MAP_HEIGHT):
			get_node("Map Popup/2DMap/TileMap").set_cell(x, y, 0)
	
	set_process(true)
	set_process_input(true)


func _input(event):
	if get_node("Menu Popup").is_visible():
		if event.is_action_pressed("ATTACK1"):
			get_tree().set_input_as_handled()


func _process(delta):
	get_node("FPS Label").set_text(str(OS.get_frames_per_second()))
	
	var plypos = MAP_MANAGER.get_map_pos(owner.get_translation())
	if old_ply_pos != plypos:
		update_map()
		old_ply_pos = plypos
	
	if get_node("Map Popup").is_visible():
		player_sprite.set_pos(MAP_MANAGER.get_map_pos(owner.get_translation(), false) * 6)
		player_sprite.set_rot(deg2rad(owner.yaw))


func death_menu():
	if get_node("Map Popup").is_visible():
		get_node("Map Popup").hide()
	
	get_node("Menu Popup/Container/Label").set_text("You died")
	get_node("Menu Popup").popup_centered()
	CURSOR.set_cursor_mode(CURSOR.CURSOR_TYPE_VISIBLE)


func toggle_map():
	if get_node("Map Popup").is_visible():
		get_node("Map Popup").hide()
		CURSOR.set_cursor_mode(CURSOR.CURSOR_TYPE_CAPTURED)
	else:
		get_node("Map Popup").popup_centered()
		
		if get_node("Menu Popup").is_visible():
			get_node("Menu Popup").hide()
		
		CURSOR.set_cursor_mode(CURSOR.CURSOR_TYPE_CAPTURED_HIDDEN)


func toggle_menu():
	if get_node("Menu Popup").is_visible():
		get_node("Menu Popup").hide()
		CURSOR.set_cursor_mode(CURSOR.CURSOR_TYPE_CAPTURED)
	else:
		get_node("Menu Popup").popup_centered()
		
		if get_node("Map Popup").is_visible():
			get_node("Map Popup").hide()
		
		CURSOR.set_cursor_mode(CURSOR.CURSOR_TYPE_VISIBLE)


func update_map():
	var plypos = MAP_MANAGER.get_map_pos(owner.get_translation())
	var rec = map_vis_rect
	rec.pos = plypos - (rec.size * 0.5).floor()
	rec = rec.clip(Rect2(0, 0, MAP_MANAGER.MAP_WIDTH, MAP_MANAGER.MAP_HEIGHT)) #visibility rect can't go outside map
	
	for x in range(rec.pos.x, rec.end.x):
		for y in range(rec.pos.y, rec.end.y):
			var map_tile = MAP_MANAGER.map[x][y]
			
			if map_tile.type == 1: #tile is floor
				if x - rec.pos.x <= 0 or x - rec.pos.x >= rec.size.x - 1 \
				or y - rec.pos.y <= 0 or y - rec.pos.y >= rec.size.y - 1: #tile is on edge
					if not map_tile.seen:
						map_tile.seen_edge = true
						get_node("Map Popup/2DMap/TileMap").set_cell(x, y, 1)
					
				else:
					map_tile.seen = true
					get_node("Map Popup/2DMap/TileMap").set_cell(x, y, 2)


func update_kills():
	get_node("Menu Popup/Container/Player Kills").set_text("Kills: " + str(DUNGEON_MANAGER.player_kills))


func set_health(amnt, maxhp=10):
	get_node("Healthbar").set_value((amnt / float(maxhp)) * 100)


func _on_Map_Popup_popup_hide():
	CURSOR.set_cursor_mode(CURSOR.CURSOR_TYPE_CAPTURED)


func _on_Menu_Popup_popup_hide():
	CURSOR.set_cursor_mode(CURSOR.CURSOR_TYPE_CAPTURED)


func _on_Seed_Button_pressed():
	OS.set_clipboard(str(MAP_MANAGER.current_seed))


func _on_Menu_Button_pressed():
	get_tree().change_scene("res://scenes/main_menu.scn")


