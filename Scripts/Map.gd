extends Node2D

signal begin_stage(difficulty, type)


var buttons = {}

var paths = []
var current_path = []
# points -> buttons
var current_point = null
var map_stages = {}

var map_button_scene = preload("res://Scenes/Other/Map_Button.tscn")
var map_generator_scene = preload("res://Scenes/Other/Map_Generator.tscn")

onready var camera = $Camera2D
onready var apple = $Apple
onready var tween = $Tween
onready var sfx = $SFX

func _ready():
	if Global.current_point == null:
		
		generate()
	else:
		paths = Global.paths
		current_point = Global.current_point
		current_path = Global.current_path
		map_stages = Global.map_stages
		update()
		
	camera.position.x = current_point.x
	
	apple.position = current_point - Vector2(0, 10)
	apple.play("Idle")
	
func _process(delta):
	if Input.is_action_pressed("ui_right"):
		camera.position.x += 200*delta
	elif Input.is_action_pressed("ui_left"):
		camera.position.x -= 200*delta
	camera.position.x = clamp(camera.position.x, 320, 960)

func _on_Next_Stage_Button_pressed(point, difficulty, type):
	if apple.animation == "Walk":
		return
		
	sfx.play()
		
	apple.play("Walk")
	tween.interpolate_property(apple, 'position', apple.position, point- Vector2(0, 10), 1, Tween.TRANS_LINEAR,Tween.EASE_IN)
	tween.start()
	
	current_point = point
	current_path.append(current_point)
	save_data()

	yield(tween, "tween_all_completed")
	yield(get_tree().create_timer(0.5), "timeout")

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
	#print(paths)
	# preprocess points
	for i in range(paths.size()):
		for j in range(paths[i].size()):
			#paths[i][j] *= 40
			paths[i][j] += Vector2(180, 140) 
	
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
				map_button.difficulty = int(floor(i * (Global.MAX_DIFFICULTY + 1) / path.size()))
				# randomly make some points mystery stages and augment stages
				if i % 2 == 1:
					var rand = randi() % 2
					if rand == 0:
						map_button.type = "Question"
				if i % 5 == 4:
					var rand = randi() % 2
					if rand == 0:
						map_button.type = "Augment"
				# make last point boss stage
				if i == path.size() - 1:
					map_button.type = "Boss"
				map_button.set_position(path[i] - Vector2(12,12))
				map_button.disabled = true
				map_button.connect("pressed", self, "_on_Next_Stage_Button_pressed")
				add_child(map_button)
				map_button.point = path[i]
				buttons[path[i]] = map_button
				map_stages[path[i]] = [map_button.difficulty, map_button.type]
			if i != 0:
				draw_line(path[i-1], path[i], Color(0.5,0.5,0.5,1), 2)
				
	# draw available paths in white, enable appropriate buttons
	for path in paths:
		if current_point in path:
			var index = 0
			for i in range(path.size()):
				if path[i] == current_point:
					index = i
				buttons[path[i]].possible()
			#available paths
			draw_line(path[index], path[index+1], Color("859e72"), 2)
			#enable buttons
			var button = buttons[path[index+1]]
			button.undisable()

	# draw path thus far
	for i in range(current_path.size()):
		buttons[current_path[i]].clear()
		if i > 0:
			draw_line(current_path[i-1], current_path[i], Color("b06a76"), 2)



