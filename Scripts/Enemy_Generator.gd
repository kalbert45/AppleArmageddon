extends Node2D

# contains variables units_dict, enemy_templates, as well as enemy scenes as constants
var enemy_data = preload("res://Assets/Resources/enemy_generation_data.tres")
var enemy_templates
var units

var rng = RandomNumberGenerator.new()

func _ready():
	pass

# returns a node with enemies/placeholders as children
func generate_enemies(difficulty, _spawn_node, template=null):
	var enemies_instance
	if template != null:
		enemies_instance = template.instance()
	else:
		rng.randomize()
		var possible_templates = enemy_data.enemy_templates[difficulty]
		var random_template = possible_templates[rng.randi_range(0, possible_templates.size()-1)]
		enemies_instance = random_template.instance()
		
	if "units_dict" in enemies_instance:
		enemies_instance.units_dict = enemy_data.units_dict
	return enemies_instance
	
	#var positions
	#var unit_difficulty
	#var possible_units
	#var unit_scene
	#for position_set in random_template:
	#	positions = position_set[0]
	#	unit_difficulty = position_set[1]
	#	possible_units = enemy_data.units_dict[unit_difficulty]
	#	unit_scene = possible_units[rng.randi_range(0, possible_units.size()-1)]
	#	for pos in positions:
	#		var unit = unit_scene.instance()
	#		unit.global_position = pos
	#		spawn_node.add_child(unit)
	
	
