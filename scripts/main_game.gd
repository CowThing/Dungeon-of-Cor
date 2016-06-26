
extends Node


func _ready():
	get_node("WorldEnvironment").get_environment().set_background(Environment.BG_COLOR)
	get_node("Level Label/Label").set_text("FLOOR " + str(DUNGEON_MANAGER.dungeon_level))
	
	#build map
	MAP_MANAGER.set_owner(self)
	MAP_MANAGER.make_map()
	
	#setup player
	get_player().set_translation(get_player().get_translation() + Vector3(0.5, 0, 0.5))
	get_player().set_health(DUNGEON_MANAGER.player_health)


func get_player():
	return get_node("Map/Player")


func _on_Main_exit_tree():
	MAP_MANAGER.clear_map()


