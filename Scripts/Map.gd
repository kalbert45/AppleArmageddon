extends Node2D

signal begin_stage(difficulty, type)

var new = false
var buttons = {}

var paths = []
var current_path = []
# points -> buttons
var current_point = null
var map_stages = {}

var map_button_scene = preload("res://Scenes/Map_Button.tscn")
var map_generator_scene = preload("res://Scenes/Map_Generator.tscn")

func _ready():
	if new:
		Global.paths = []
		Global.current_point = null
		Global.current_path = []
		Global.map_stages = {}
		generate()
		new = false
	else:
		paths = Global.paths
		current_point = Global.current_point
		current_path = Global.current_path
		map_stages = Global.map_stages
		update()
		

func _on_Next_Stage_Button_pressed(point, difficulty, type):
	current_point = point
	current_path.append(current_point)
	save_data()
	emit_signal("begin_stage", difficulty, type)
	
func save_data():
	Global.paths = paths
	Global.current_point = current_point
	Global.current_path = current_path
	Global.map_stages = map_stages


func generate():
	buttons = {}
	var map_generator = map_generator_scene.instance()
	paths = map_generator.generate()
	map_generator.queue_free()
	# preprocess points
	for i in range(paths.size()):
		for j in range(paths[i].size()):
			paths[i][j] *= 20
			paths[i][j] += Vector2(180, 0) 
	
	current_point= paths[0][0]
	current_path.append(current_point)
	update()
				
func _draw():
	# if map already exists, add all buttons
	for index in map_stages:
		var button_properties = map_stages[index]
		var map_button = map_button_scene.instance()
		map_button.difficulty = button_properties[0]
		map_button.type = button_properties[1]
		map_button.set_position(index - Vector2(12,12))
		map_button.disabled = true
		map_button.connect("pressed", self, "_on_Next_Stage_Button_pressed")
		add_child(map_button)
		map_button.point = index
		buttons[index] = map_button
	
	# draw entire map in grey, add disabled buttons if necessary
	for path in paths:
		for i in range(path.size()):
			if not buttons.has(path[i]):
				var map_button = map_button_scene.instance()
				# set difficulty of map stage based on progress in path
				map_button.difficulty = int(floor((i+1) * 2 / path.size()))
				# randomly make some points mystery stages
				if i % 2 == 1:
					var rand = randi() % 2
					if rand == 0:
						map_button.type = "Question"
				# make last point boss stage
				#--
				map_button.set_position(path[i] - Vector2(12,12))
				map_button.disabled = true
				map_button.connect("pressed", self, "_on_Next_Stage_Button_pressed")
				add_child(map_button)
				map_button.point = path[i]
				buttons[path[i]] = map_button
				map_stages[path[i]] = [map_button.difficulty, map_button.type]
			if i != 0:
				draw_line(path[i-1], path[i], Color(0.5,0.5,0.5,1))
				
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
		draw_line(current_path[i], current_path[i+1], Color(1,1,1,1), 2)
