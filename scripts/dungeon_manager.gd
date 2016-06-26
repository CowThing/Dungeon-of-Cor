
extends Node

#persistent vars
var dungeon_level = 1
var player_health = 10
var player_kills = 0

#level, [white, black]
var level_colors = [
	[1, [Color("558f34"), Color("4a3228")]], #Grass levels
	[3, [Color("456975"), Color("28354a")]], #Dungeon levels
	[5, [Color("468f99"), Color("2f2852")]], #Ice levels
	[7, [Color("322839"), Color("8e2d38")]], #Lava levels
	[9, [Color("3f5b53"), Color("232237")]]  #Onyx levels
]

#level, [{name, chance, billboard, roation}, ++]
var clutter = [
	[1, [{name = "grass", chance = 50, billboard = true, rotation = false},
		{name = "flower", chance = 50, billboard = true, rotation = false}]],
	[3, [{name = "bricks", chance = 30, billboard = false, rotation = false},
		{name = "pot", chance = 20, billboard = true, rotation = false},
		{name = "pot_broken", chance = 20, billboard = false, rotation = true},
		{name = "bone", chance = 30, billboard = true, rotation = false}]],
	[5, [{name = "pot_broken", chance = 10, billboard = false, rotation = true},
		{name = "spike", chance = 20, billboard = true, rotation = false},
		{name = "crack", chance = 30, billboard = false, rotation = true},
		{name = "rocka", chance = 20, billboard = true, rotation = false},
		{name = "rockb", chance = 20, billboard = true, rotation = false}]],
	[7, [{name = "spike", chance = 30, billboard = true, rotation = false},
		{name = "crack", chance = 30, billboard = false, rotation = true},
		{name = "rocka", chance = 20, billboard = true, rotation = false},
		{name = "rockb", chance = 20, billboard = true, rotation = false}]]
]

#level, [min, max]
var room_size = [
	[1, [7, 9]],
	[3, [5, 7]],
	[5, [5, 9]],
	[7, [7, 8]],
	[9, [5, 9]]
]

#level, [min, max]
var monster_per_room = [
	[1, [1, 2]],
	[3, [1, 3]],
	[5, [2, 3]],
	[7, [2, 4]],
	[9, [2, 5]]
]

#level, [{name, chance}, ++]
var monsters = [
	[1, [{name = "mushroom", chance = 50},
		{name = "rogue", chance = 10},
		{name = "bat", chance = 40}]],
	[3, [{name = "rogue", chance = 30},
		{name = "goblin", chance = 50},
		{name = "bat", chance = 20}]],
	[5, [{name = "goblin", chance = 10},
		{name = "slime", chance = 30},
		{name = "troll", chance = 30},
		{name = "wolf", chance = 30}]],
	[7, [{name = "skull", chance = 30},
		{name = "skeleton", chance = 40},
		{name = "slime", chance = 20},
		{name = "troll", chance = 10}]],
	[9, [{name = "skull", chance = 30},
		{name = "skeleton", chance = 50},
		{name = "grim", chance = 20}]]
]

#only one item :(
var items_per_room = [
	[1, [0, 1]]
]

var items = [
	[1, [{name = "health", chance = 100}]]
]

#music
var music = [
	[1, "JRPG_fields_loop"],
	[3, "JRPG_dungeon_loop"],
	[5, "JRPG_mysticIsle"],
	[7, "JRPG_labyrinth_loop"],
	[9, "JRPG_battleBoss_loop"]
]


func next_level():
	dungeon_level += 1
	player_health = get_node("/root/Main").get_player().health
	get_tree().reload_current_scene()


func update_dungeon():
	MUSIC.play_music(from_dungeon_level(music))
	
	var col = from_dungeon_level(level_colors)
	COLOR_MANAGER.set_colors(col[0], col[1])


func from_dungeon_level(table):
	for i in range(table.size(), 0, -1):
		i -= 1
		var level = table[i][0]
		var value = table[i][1]
		if dungeon_level >= level:
			return value


func leave_dungeon():
	dungeon_level = 1
	player_health = 10
	player_kills = 0


func add_kill():
	player_kills += 1
	get_node("/root/Main").get_player().get_node("HUD").update_kills()


func check_dungeon_end():
	var enemy_array = get_tree().get_nodes_in_group("Enemy")
	if enemy_array.size() <= 1:
		var last_enemy = enemy_array[0]
		
		var ladder = preload("res://scenes/objects/ladder.scn").instance()
		ladder.set_translation(last_enemy.get_translation())
		get_node("/root/Main/Map").add_child(ladder)
		
		return true
	
	return false


