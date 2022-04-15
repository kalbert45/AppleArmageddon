extends Resource

# all enemy scenes
const GRUNT = preload("res://Scenes/Enemies/Enemy_Dummy.tscn")
const AXEMAN = preload("res://Scenes/Enemies/Axeman.tscn")
const GUNMAN = preload("res://Scenes/Enemies/Gunman.tscn")
const RIFLEMAN = preload("res://Scenes/Enemies/Rifleman.tscn")
const RIFLEMAN_HORSEBACK = preload("res://Scenes/Enemies/Rifleman_Horseback.tscn")
#const BUNKER = preload("res://Scenes/Enemies/Turret.tscn")
const MOLOTOVMAN = preload("res://Scenes/Enemies/Molotovman.tscn")
const TRACTOR = preload("res://Scenes/Enemies/Tractor.tscn")
const BIG_LIZZIE = preload("res://Scenes/Enemies/Big_Lizzie.tscn")

# all enemy stages
const ENEMIES0_0 = preload("res://Scenes/Enemy_Scenes/Enemies0_0.tscn")
const ENEMIES0_1 = preload("res://Scenes/Enemy_Scenes/Enemies0_1.tscn")
const ENEMIES1_0 = preload("res://Scenes/Enemy_Scenes/Enemies1_0.tscn")
const ENEMIES1_1 = preload("res://Scenes/Enemy_Scenes/Enemies1_1.tscn")
const ENEMIES1_2 = preload("res://Scenes/Enemy_Scenes/Enemies1_2.tscn")
const ENEMIES2_0 = preload("res://Scenes/Enemy_Scenes/Enemies2_0.tscn")
const ENEMIES2_1 = preload("res://Scenes/Enemy_Scenes/Enemies2_1.tscn")
const ENEMIES3_0 = preload("res://Scenes/Enemy_Scenes/Enemies3_0.tscn")
const ENEMIES3_1 = preload("res://Scenes/Enemy_Scenes/Enemies3_1.tscn")
const ENEMIES4_0 = preload("res://Scenes/Enemy_Scenes/Enemies4_0.tscn")
const ENEMIES4_1 = preload("res://Scenes/Enemy_Scenes/Enemies4_1.tscn")
const ENEMIES5_0 = preload("res://Scenes/Enemy_Scenes/Enemies5_0.tscn")

# dictionary that sorts units by difficulty
var units_dict

# dictionary that stores templates
# difficulty -> template
var enemy_templates


func _init():
	units_dict = {0: [GRUNT, AXEMAN, GUNMAN],
				1:[RIFLEMAN, MOLOTOVMAN],
				2:[RIFLEMAN_HORSEBACK, TRACTOR],
				"Boss":[BIG_LIZZIE]
				}
				
	enemy_templates = {0:[ENEMIES0_0, ENEMIES0_1],
						1:[ENEMIES1_0, ENEMIES1_1, ENEMIES1_2],
					2:[ENEMIES2_0, ENEMIES2_1],
					3:[ENEMIES3_0, ENEMIES3_1],
					4:[ENEMIES4_0, ENEMIES4_1],
					5:[ENEMIES5_0],
	}
