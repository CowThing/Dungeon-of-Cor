
extends Node

var settings = {
	view_sensitivity = 20,
	fov = 80,
	music_vol = 100,
	sound_vol = 100
}


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func save_settings(n_settings):
	for k in settings.keys():
		settings[k] = n_settings[k]
	
	var savesettings = File.new()
	savesettings.open("user://settings.ini", File.WRITE)
	savesettings.store_string(settings.to_json())
	savesettings.close()


func load_settings():
	var savesettings = File.new()
	if !savesettings.file_exists("user://settings.ini"):
		return
	
	savesettings.open("user://settings.ini", File.READ)
	var current_line = {}
	var line = savesettings.get_line()
	if not line.empty():
		current_line.parse_json(line)
		for k in current_line.keys():
			settings[k] = current_line[k]
	
	savesettings.close()


#utility
func rand_range_int(min_i, max_i):
	return min_i + (randi() % int(max_i - min_i + 1))


func lookup_value(table, x):
	#find the value in the table that corrisponds with x
	var cumulative_weight = 0
	for i in range(table.size()):
		var weight = table[i]["chance"]
		cumulative_weight += weight
		if x <= cumulative_weight:
			return table[i]


func rand_choice(table):
	#get random value from a table
	var sum_of_weights = 0
	for i in range(table.size()):
		var weight = table[i]["chance"]
		sum_of_weights += weight
	
	var x = sum_of_weights * randf()
	return lookup_value(table, x)


