extends Node2D

signal update_money
signal stage_cleared
signal defeat

var enemies
var units
var difficulty = 0

var enemy_generator_scene = preload("res://Scenes/Enemy_Generator.tscn")

var shop_scene = preload("res://Scenes/Shop.tscn")
var shop

var apple_scene = preload("res://Scenes/Apple.tscn")
var crabapple_scene = preload("res://Scenes/Crabapple.tscn")
var golden_scene = preload("res://Scenes/Golden.tscn")
var green_scene = preload("res://Scenes/Green.tscn")
var pink_scene = preload("res://Scenes/Pink.tscn")

onready var units_node = $TileMap/YSort

func _ready():
	var enemy_generator = enemy_generator_scene.instance()
	enemy_generator.generate_enemies(difficulty, units_node)
	enemy_generator.queue_free()
	
	enemies = get_tree().get_nodes_in_group("Enemies")
	units = get_tree().get_nodes_in_group("Units")
	
	for enemy in enemies:
		enemy.connect("death", self, "_on_enemy_death")
		enemy.connect("spawn_enemies", self, "_on_enemy_spawn")
	for unit in units:
		unit.connect("death", self, "_on_unit_death")
		
	shop = shop_scene.instance()
	shop.global_position = Vector2(480, 40)
	shop.units_node_target = units_node
	shop.connect("update_money", self, "_on_update_money")
	shop.connect("new_unit", self, "_on_new_unit")
	$TileMap.add_child(shop)
	
func _on_enemy_death():
	enemies = get_tree().get_nodes_in_group("Enemies")
	if enemies.size() <= 1:
		yield(get_tree().create_timer(0.5), "timeout")
		enemies = get_tree().get_nodes_in_group("Enemies")
		if enemies.empty():
			Global.money += 20 * (difficulty + 1)
			emit_signal("stage_cleared")

func _on_enemy_spawn():
	enemies = get_tree().get_nodes_in_group("Enemies")
	for enemy in enemies:
		if not enemy.is_connected("death", self, "_on_enemy_death"):
			enemy.connect("death", self, "_on_enemy_death")
		
func _on_unit_death():
	
	units = get_tree().get_nodes_in_group("Units")
	if units.size() <= 1:
		yield(get_tree().create_timer(0.5), "timeout")
		units = get_tree().get_nodes_in_group("Units")
		if units.empty():
			
			emit_signal("defeat")

# saved_data is dictionary with keys: Money, Units, Enemies, Tilemap
func load_data():
	for unit in Global.units:
		var instance = unit[0].instance()
		instance.initial_pos = unit[1]
		instance.current_hp = unit[2]
		instance.current_mana = unit[3]
		units_node.add_child(instance)
		
	units = get_tree().get_nodes_in_group("Units")
	for unit in units:
		unit.connect("death", self, "_on_unit_death")

func save_data():
	units = []
	for unit in get_tree().get_nodes_in_group("Units"):
		match unit.label:
			"Apple":
				units.append([apple_scene, unit.initial_pos, unit.current_hp, unit.current_mana])
			"Crabapple":
				units.append([crabapple_scene, unit.initial_pos, unit.current_hp, unit.current_mana])
			"Golden":
				units.append([golden_scene, unit.initial_pos, unit.current_hp, unit.current_mana])
			"Green":
				units.append([green_scene, unit.initial_pos, unit.current_hp, unit.current_mana])
			"Pink":
				units.append([pink_scene, unit.initial_pos, unit.current_hp, unit.current_mana])
				
		
	Global.units = units

func _on_update_money():
	emit_signal("update_money")
	
func _on_new_unit(unit):
	unit.connect("death", self, "_on_unit_death")
	
func disable_shop():
	shop.disable()
