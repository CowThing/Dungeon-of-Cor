
extends Node


var owner

var MAP_WIDTH = 30
var MAP_HEIGHT = 30

var MAX_ROOM_MONSTERS = 3
var MAX_ROOMS = 30

var current_seed = 0

var map = []

var enemyscene = preload("res://scenes/characters/mushroom.scn")
var clutterscene = preload("res://scenes/effects/clutter.scn")


class tile:
	var type = -1
	var seen_edge = false
	var seen = false
	
	func _init(i_type):
		type = i_type


func _init():
	for x in range(MAP_WIDTH):
		map.append([])
		for y in range(MAP_HEIGHT):
			map[x].append(tile.new(0))


func clear_map():
	for x in range(MAP_WIDTH):
		for y in range(MAP_HEIGHT):
			map[x][y] = tile.new(0)
			#owner.get_node("Map/GridMap").set_cell_item(x, 0, y, -1)


func set_owner(n_owner):
	owner = n_owner


func set_seed(seed_string):
	current_seed = string_to_seed(seed_string)


func make_map():
	#reset seed for every new level, plus the dungeon level so every level is different
	seed(current_seed + (DUNGEON_MANAGER.dungeon_level - 1))
	
	var rooms = []
	var num_rooms = 0
	
	var room_size = DUNGEON_MANAGER.from_dungeon_level(DUNGEON_MANAGER.room_size)
	
	for r in range(MAX_ROOMS):
		var w = GLOBAL.rand_range_int(room_size[0], room_size[1])
		var h = GLOBAL.rand_range_int(room_size[0], room_size[1])
		var x = GLOBAL.rand_range_int(0, MAP_WIDTH - w - 1)
		var y = GLOBAL.rand_range_int(0, MAP_HEIGHT - h - 1)
		
		var new_room = Rect2(x, y, w, h)
		
		var failed = false
		for other_room in rooms:
			if new_room.intersects(other_room):
				failed = true
				break
		
		if not failed:
			create_room(new_room)
			
			var new_room_pos = room_center(new_room)
			
			if num_rooms == 0:
				#first room
				set_map_pos(owner.get_player(), new_room_pos)
				
			else:
				#remaining rooms
				var prev_room_pos = room_center(rooms[num_rooms - 1])
				
				if randi()%2 == 0:
					#H first then V
					create_h_tunnel(prev_room_pos.x, new_room_pos.x, prev_room_pos.y)
					create_v_tunnel(prev_room_pos.y, new_room_pos.y, new_room_pos.x)
				else:
					#V first then H
					create_v_tunnel(prev_room_pos.y, new_room_pos.y, prev_room_pos.x)
					create_h_tunnel(prev_room_pos.x, new_room_pos.x, new_room_pos.y)
				
				place_objects(new_room)
			
			rooms.append(new_room)
			num_rooms += 1
	
	update_grid_map()
	DUNGEON_MANAGER.update_dungeon()


func place_objects(room):
	#place enemies
	var monster_per_room = DUNGEON_MANAGER.from_dungeon_level(DUNGEON_MANAGER.monster_per_room)
	var num_of_monsters = GLOBAL.rand_range_int(monster_per_room[0], monster_per_room[1])
	var monster_types = DUNGEON_MANAGER.from_dungeon_level(DUNGEON_MANAGER.monsters)
	
	for i in range(num_of_monsters):
		var x = rand_range(room.pos.x + 1.5, room.end.x - 0.5)
		var y = rand_range(room.pos.y + 1.5, room.end.y - 0.5)
		
		var ran_mon = GLOBAL.rand_choice(monster_types)["name"]
		var new_obj = load("res://scenes/characters/" + ran_mon + ".scn").instance()
		set_map_pos(new_obj, Vector2(x, y))
		owner.get_node("Map").add_child(new_obj)
	
	#place clutter
	var num_of_clutter = GLOBAL.rand_range_int(2, floor(room.get_area() * 0.125))
	var clutter_types = DUNGEON_MANAGER.from_dungeon_level(DUNGEON_MANAGER.clutter)
	
	for i in range(num_of_clutter):
		var x = rand_range(room.pos.x + 1.5, room.end.x - 0.5)
		var y = rand_range(room.pos.y + 1.5, room.end.y - 0.5)
		
		var new_obj = clutterscene.instance()
		set_map_pos(new_obj, Vector2(x, y))
		new_obj.set_clutter_type(clutter_types)
		owner.get_node("Map").add_child(new_obj)
	
	#place objects
	var items_per_room = DUNGEON_MANAGER.from_dungeon_level(DUNGEON_MANAGER.items_per_room)
	var num_of_items = GLOBAL.rand_range_int(items_per_room[0], items_per_room[1])
	var item_types = DUNGEON_MANAGER.from_dungeon_level(DUNGEON_MANAGER.items)
	
	for i in range(num_of_items):
		var x = rand_range(room.pos.x + 1.5, room.end.x - 0.5)
		var y = rand_range(room.pos.y + 1.5, room.end.y - 0.5)
		
		var ran_item = GLOBAL.rand_choice(item_types)["name"]
		var new_obj = load("res://scenes/objects/" + ran_item + ".scn").instance()
		set_map_pos(new_obj, Vector2(x, y))
		owner.get_node("Map").add_child(new_obj)


func create_room(room):
	for x in range(room.pos.x + 1, room.end.x):
		for y in range(room.pos.y + 1, room.end.y):
			map[x][y].type = 1


func room_center(room):
	var pos = (room.pos + Vector2(1, 1) + room.end) * 0.5
	return pos.floor()


func create_h_tunnel(x1, x2, y):
	for x in range(min(x1, x2), max(x1, x2) + 1):
		map[x][y].type = 1


func create_v_tunnel(y1, y2, x):
	for y in range(min(y1, y2), max(y1, y2) + 1):
		map[x][y].type = 1


func update_grid_map():
	for x in range(MAP_WIDTH):
		for y in range(MAP_HEIGHT):
			owner.get_node("Map/GridMap").set_cell_item(x, 0, y, map[x][y].type)


func set_map_pos(obj, pos):
	obj.set_translation(Vector3(pos.x, 0, pos.y) * 2)


func get_map_pos(n_pos, rounded=true):
	var pos = Vector2(n_pos.x, n_pos.z) * 0.5
	if rounded:
		pos = pos.floor()
	return pos


#Random seed
func string_to_seed(seedstr):
	if seedstr.length() == 0:
		randomize()
		return randi()
		
	else:
		var rx = RegEx.new() #check if a string is a number or not
		rx.compile("^\\d+$")
		
		if rx.find(seedstr) == -1:
			#convert to int
			var seedascii = seedstr.to_ascii()
			var num = 0
			for i in seedascii:
				num += i #int from string
			
			return num
		
		return int(seedstr)


