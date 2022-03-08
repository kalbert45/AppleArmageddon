extends Node2D

signal stage_cleared
signal defeat

var enemies
var money = 0

var apple_scene = preload("res://Scenes/Apple.tscn")

onready var units_node = $TileMap/YSort

func _ready():
	enemies = get_tree().get_nodes_in_group("Enemies")
	
	for enemy in enemies:
		enemy.connect("death", self, "_on_enemy_death")
		
func _on_enemy_death():
	if get_tree().get_nodes_in_group("Enemies").size() == 1:
		yield(get_tree().create_timer(0.5), "timeout")
		emit_signal("stage_cleared")

# saved_data is dictionary with keys: Money, Units, Enemies, Tilemap
func load_data(saved_data):
	print(saved_data)
	for unit in saved_data["Units"]:
		var instance = unit[0].instance()
		instance.initial_pos = unit[1]
		units_node.add_child(instance)
		
	money = saved_data["Money"]

func save_data():
	var units = []
	for unit in get_tree().get_nodes_in_group("Units"):
		match unit.label:
			"Apple":
				units.append([apple_scene, unit.initial_pos])
		
	return {"Units": units, "Money": money}
