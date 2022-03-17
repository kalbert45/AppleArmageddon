extends Node2D

signal update_money
signal stage_cleared
signal defeat

var enemies
var units

var shop_scene = preload("res://Scenes/Shop.tscn")
var shop

var apple_scene = preload("res://Scenes/Apple.tscn")
var crabapple_scene = preload("res://Scenes/Crabapple.tscn")
var golden_scene = preload("res://Scenes/Golden.tscn")
var green_scene = preload("res://Scenes/Green.tscn")
var pink_scene = preload("res://Scenes/Pink.tscn")

onready var units_node = $TileMap/YSort

func _ready():
	enemies = get_tree().get_nodes_in_group("Enemies")
	units = get_tree().get_nodes_in_group("Units")
	
	for enemy in enemies:
		enemy.connect("death", self, "_on_enemy_death")
	for unit in units:
		unit.connect("death", self, "_on_unit_death")
		
	shop = shop_scene.instance()
	shop.global_position = Vector2(480, 40)
	shop.units_node_target = units_node
	shop.connect("update_money", self, "_on_update_money")
	$TileMap.add_child(shop)
func _on_enemy_death():
	if get_tree().get_nodes_in_group("Enemies").size() <= 1:
		yield(get_tree().create_timer(0.5), "timeout")
		enemies = get_tree().get_nodes_in_group("Enemies")
		if enemies.empty():
			emit_signal("stage_cleared")
		else:
			for enemy in enemies:
				enemy.connect("death", self, "_on_enemy_death")
		
func _on_unit_death():
	if get_tree().get_nodes_in_group("Units").size() <= 1:
		yield(get_tree().create_timer(0.5), "timeout")
		emit_signal("defeat")

# saved_data is dictionary with keys: Money, Units, Enemies, Tilemap
func load_data():
	for unit in Global.units:
		var instance = unit[0].instance()
		instance.initial_pos = unit[1]
		units_node.add_child(instance)

func save_data():
	var units = []
	for unit in get_tree().get_nodes_in_group("Units"):
		match unit.label:
			"Apple":
				units.append([apple_scene, unit.initial_pos])
			"Crabapple":
				units.append([crabapple_scene, unit.initial_pos])
			"Golden":
				units.append([golden_scene, unit.initial_pos])
			"Green":
				units.append([green_scene, unit.initial_pos])
			"Pink":
				units.append([pink_scene, unit.initial_pos])
				
		
	Global.units = units

func _on_update_money():
	emit_signal("update_money")
	
func disable_shop():
	shop.disable()
