extends Node2D

signal update_money
signal stage_cleared
signal defeat
signal enable_all

var intro = false
var activate = false

var enemies
var units
var difficulty = 0

var enemy_scene = null
var enemy_generator_scene = preload("res://Scenes/Enemy_Generator.tscn")

var shop_scene = preload("res://Scenes/Shop.tscn")
var shop

var apple_scene = preload("res://Scenes/Units/Apple.tscn")
var crabapple_scene = preload("res://Scenes/Units/Crabapple.tscn")
var golden_scene = preload("res://Scenes/Units/Golden.tscn")
var green_scene = preload("res://Scenes/Units/Green.tscn")
var pink_scene = preload("res://Scenes/Units/Pink.tscn")

var big_apple_scene = preload("res://Scenes/Units/Charge_Apple.tscn")
var big_crabapple_scene = preload("res://Scenes/Units/Dogapple.tscn")
var big_golden_scene = preload("res://Scenes/Units/Golden_Malicious.tscn")
var big_green_scene = preload("res://Scenes/Units/Big_Green.tscn")
var big_pink_scene = preload("res://Scenes/Units/Big_Pink.tscn")

onready var units_node = $TileMap/YSort

func _ready():
	if enemy_scene == null:
		var enemy_generator = enemy_generator_scene.instance()
		enemy_generator.generate_enemies(difficulty, units_node)
		enemy_generator.queue_free()
	else:
		var enemy_node = enemy_scene.instance()
		units_node.add_child(enemy_node)
		enemy_node.connect("dialog_end", self, "_on_dialog_end")
	
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
	if intro:
		shop.disabled = true
	$TileMap.add_child(shop)
	
func _on_enemy_death():
	emit_signal("update_money")
	enemies = get_tree().get_nodes_in_group("Enemies")
	if enemies.size() <= 1:
		yield(get_tree().create_timer(0.5), "timeout")
		enemies = get_tree().get_nodes_in_group("Enemies")
		if enemies.empty():
			#Global.money += 20 * (difficulty + 1)
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
	#test
	#Global.augments["Red1"] = true
	
	for unit in Global.units:
		var instance = unit[0].instance()
		instance.initial_pos = unit[1]
		
		#Augments
		if Global.augments["General0"]:
			instance.movement_speed += 10
		if Global.augments["General1"]:
			instance.General1 = true
		if Global.augments["General2"]:
			instance.attack_damage += 2
		if Global.augments["General3"]:
			instance.General3 = true
		
		units_node.add_child(instance)
		
		
	units = get_tree().get_nodes_in_group("Units")
	for unit in units:
		unit.connect("death", self, "_on_unit_death")

func save_data():
	units = []
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
				
			"Brappler":
				units.append([big_apple_scene, unit.initial_pos])
			"Golden Malicious":
				units.append([big_golden_scene, unit.initial_pos])
			"Dogapple":
				units.append([big_crabapple_scene, unit.initial_pos])
			"Big Green":
				units.append([big_green_scene, unit.initial_pos])
			"Big Pink":
				units.append([big_pink_scene, unit.initial_pos])
				
		
	Global.units = units

func _on_update_money():
	emit_signal("update_money")
	
func _on_new_unit(unit):
	unit.connect("death", self, "_on_unit_death")
	
func disable_shop():
	shop.disable()

func _on_dialog_end(timeline_name):
	match timeline_name:
		"intro_timeline":
			activate = true
			_on_enemy_spawn()
			
			
func _input(event):
	if activate:
		if (event is InputEventMouseButton) or (event is InputEventKey):
			shop.enable()
			emit_signal("enable_all")
			activate = false
		
