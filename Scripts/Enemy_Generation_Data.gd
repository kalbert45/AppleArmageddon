extends Resource

# all enemy scenes
const GRUNT = preload("res://Scenes/Enemy_Dummy.tscn")
const GUNMAN = preload("res://Scenes/Gunman.tscn")
const RIFLEMAN = preload("res://Scenes/Rifleman.tscn")
const BUNKER = preload("res://Scenes/Turret.tscn")

# dictionary that sorts units by difficulty
var units_dict

# dictionary that stores templates
# Structure: dictionary where keys are difficulties, values are arrays of templates
# Each template is an array of arrays of arrays containing 2d positions and unit difficulty
# i.e. [[Vector2, Vector2],1], etc.
# hierarchy: dictionary->difficulty level->templates->position sets->positions and difficulty
var enemy_templates


func _init():
	units_dict = {0: [GRUNT, GUNMAN],
				1:[RIFLEMAN],
				2:[BUNKER]
				}
				
	enemy_templates = {0:[[[[Vector2(880,85),Vector2(880,105),Vector2(900,85)],0],
						[[Vector2(880,265),Vector2(880,285),Vector2(900,265)],0]],
	
						[[[Vector2(900,125),Vector2(900,145)],0],
						[[Vector2(900,165),Vector2(900,185),Vector2(900,205),Vector2(900,225)],0]]],
	
	1:[[[[Vector2(900,85),Vector2(900,105),Vector2(900,125),Vector2(900,145)],1],
		[[Vector2(900,165),Vector2(900,185),Vector2(900,205),Vector2(900,225)],1]],
		
		[[[Vector2(880,85),Vector2(880,105),Vector2(900,85),Vector2(900,105)],1],
		[[Vector2(880,265),Vector2(880,285),Vector2(900,265),Vector2(900,285)],1]]],
	
	2:[[[[Vector2(900,85)],2],
		[[Vector2(900,265)],2]],
		
		[[[Vector2(880,85),Vector2(880,105),Vector2(900,85),Vector2(900,105)],1],
		[[Vector2(880,265),Vector2(880,285),Vector2(900,265),Vector2(900,285)],1],
		[[Vector2(850,85),Vector2(850,105),Vector2(850,125),Vector2(850,145)],0],
		[[Vector2(850,165),Vector2(850,185),Vector2(850,205),Vector2(850,225)],0]
		]],
		
	3:[[[[Vector2(1000,250), Vector2(1000, 290)],2],
		[[Vector2(1040,230),Vector2(1040,250),
		Vector2(1040,270),Vector2(1040,290),
		Vector2(1040,310)],1],
		[[Vector2(1000,130), Vector2(1000, 90)],2],
		[[Vector2(1040,70),Vector2(1040,90),
		Vector2(1040,110),Vector2(1040,130),
		Vector2(1040,150)],1]]
		
		]
	}
