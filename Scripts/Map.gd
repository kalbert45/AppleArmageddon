extends Node2D

signal begin_stage(difficulty, type)

var new = false
var paths = []
var current_path = []
# points -> buttons
var buttons = {}
var current_point = null

var map_button_scene = preload("res://Scenes/Map_Button.tscn")
var map_generator_scene = preload("res://Scenes/Map_Generator.tscn")

func _ready():
	if new:
		Global.paths = []
		Global.current_point = null
		Global.current_path = []
		Global.stage_difficulty = 0
		generate()
		new = false
	else:
		paths = Global.paths
		current_point = Global.current_point
		current_path = Global.current_path
		update()
		

func _on_Next_Stage_Button_pressed(point):
	Global.stage_difficulty += 1
	current_point = point
	current_path.append(current_point)
	save_data()
	emit_signal("begin_stage", Global.stage_difficulty, null)
	
func save_data():
	Global.paths = paths
	Global.current_point = current_point
	Global.current_path = current_path


func generate():
	buttons = {}
	var map_generator = map_generator_scene.instance()
	paths = map_generator.generate()
	# preprocess points
	for i in range(paths.size()):
		for j in range(paths[i].size()):
			paths[i][j] *= 20
			paths[i][j] += Vector2(180, 0) 
	
	current_point= paths[0][0]
	current_path.append(current_point)
	update()
				
func _draw():
	# draw entire map in grey, disabled buttons
	for path in paths:
		var prev_point = null
		for point in path:
			if not buttons.has(point):
				var map_button = map_button_scene.instance()
				map_button.set_position(point - Vector2(12,12))
				map_button.disabled = true
				map_button.connect("pressed", self, "_on_Next_Stage_Button_pressed")
				add_child(map_button)
				buttons[point] = map_button
				map_button.point = point
			if prev_point != null:
				draw_line(prev_point, point, Color(0.5,0.5,0.5,1))
			prev_point = point
				
	# draw available paths in white, enable appropriate buttons
	for path in paths:
		if current_point in path:
			var index = 0
			for i in range(path.size()):
				if path[i] == current_point:
					index = i
					break
			#available paths
			draw_line(path[index], path[index+1], Color(1,1,1,1))
			#enable buttons
			var button = buttons[path[index+1]]
			button.undisable()

	# draw path thus far
	for i in range(current_path.size()-1):
		draw_line(current_path[i], current_path[i+1], Color(1,1,1,1))
