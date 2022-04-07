extends Node2D

onready var transition_handler = $Transition_Handler
onready var HUD = $HUD
onready var world = $World

#var new_game = true

# UI and stage scenes
var scene1 = preload("res://Scenes/Scene1.tscn")
var augment_stage = preload("res://Scenes/Augment_Stage.tscn")
var unit_selection = preload("res://Scenes/Unit_Selection.tscn")
var camera_control = preload("res://Scenes/Camera_Control.tscn")
var game_menu = preload("res://Scenes/Game_Menu.tscn")
var title_screen = preload("res://Scenes/Title_Screen.tscn")
var map_scene = preload("res://Scenes/Map.tscn")
var tutorial_scene = preload("res://Scenes/Tutorial.tscn")


var stage
var unit_UI
var camera_UI
var menu
var title
var map
var tutorial

func reset():
	Global.units = [[load("res://Scenes/Units/Apple.tscn"), Vector2(240,180)]]
	Global.money = 20
	
	Global.paths = []
	Global.current_point = null
	Global.current_path = []
	Global.map_stages = {}

	for augment in Global.augments.keys():
		Global.augments[augment] = false

func _ready():
	
	title = title_screen.instance()
	title.connect("start_game", self, "_on_Title_Screen_start_game")
	HUD.add_child(title)
	
	if Global.units.empty():
		reset()

func _on_Title_Screen_start_game():
	stage = scene1.instance()
	unit_UI = unit_selection.instance()
	camera_UI = camera_control.instance()
	menu = game_menu.instance()
	tutorial = tutorial_scene.instance()
	
	transition_handler.transition([title], [[world, stage],
	[HUD, unit_UI], [HUD, camera_UI], [self, menu], [world, tutorial]])
	
	yield(stage, "ready")
	stage.load_data()
	unit_UI.shop = stage.shop
	yield(camera_UI, "ready")
	camera_UI.update_money()

	
	stage.connect("stage_cleared", self, "_on_stage_cleared")
	stage.connect("defeat", self, "_on_stage_defeat")
	stage.connect("update_money", self, "_on_update_money")
	camera_UI.connect("next_stage", self, "_on_camera_control_next_stage")
	camera_UI.connect("disable_shop", self, "_on_disable_shop")
	menu.connect("quit_to_title", self, "_on_game_menu_quit_to_title")
	menu.connect("retry", self, "_on_retry")
	
func _on_game_menu_quit_to_title():
	title = title_screen.instance()
	
	if is_instance_valid(stage):
		stage.save_data()
	
	transition_handler.transition([stage, map, unit_UI, camera_UI, menu], [[HUD, title]])
	
	title.connect("start_game", self, "_on_Title_Screen_start_game")
	
func _on_camera_control_next_stage():
	map = map_scene.instance()

	
	#stage.save_data()
	
	transition_handler.transition([stage, camera_UI], [[world, map]])
	
	map.connect("begin_stage", self, "_on_map_begin_stage")
	
func _on_map_begin_stage(difficulty, type):
	match type:
		"Normal":
			stage = scene1.instance()
			stage.difficulty = difficulty
			camera_UI = camera_control.instance()

			transition_handler.transition([map], [[world, stage], [HUD, camera_UI]])
			
			yield(stage, "ready")
			stage.load_data()
			unit_UI.shop = stage.shop
			yield(camera_UI, "ready")
			camera_UI.update_money()
			
			stage.connect("stage_cleared", self, "_on_stage_cleared")
			stage.connect("defeat", self, "_on_stage_defeat")
			stage.connect("update_money", self, "_on_update_money")
			camera_UI.connect("next_stage", self, "_on_camera_control_next_stage")
			camera_UI.connect("disable_shop", self, "_on_disable_shop")
		
		"Question":
			stage = augment_stage.instance()
			
			transition_handler.transition([map], [[world, stage]])
			
			stage.connect("next_stage", self, "_on_camera_control_next_stage")
	
func _on_retry():
	reset()

	var new_stage = scene1.instance()
	var new_camera_UI = camera_control.instance()
	var new_menu = game_menu.instance()
	
	transition_handler.transition([stage, camera_UI, menu], [[world, new_stage], [HUD, new_camera_UI],[HUD, new_menu]])
	stage = new_stage
	camera_UI = new_camera_UI
	menu = new_menu
	
	yield(stage, "ready")
	stage.load_data()
	unit_UI.shop = stage.shop
	yield(camera_UI, "ready")
	camera_UI.update_money()
	
	stage.connect("stage_cleared", self, "_on_stage_cleared")
	stage.connect("defeat", self, "_on_stage_defeat")
	stage.connect("update_money", self, "_on_update_money")
	camera_UI.connect("next_stage", self, "_on_camera_control_next_stage")
	camera_UI.connect("disable_shop", self, "_on_disable_shop")
	menu.connect("quit_to_title", self, "_on_game_menu_quit_to_title")
	menu.connect("retry", self, "_on_retry")
	
func _on_stage_cleared():
	camera_UI.activate_next_button()
	
func _on_stage_defeat():
	menu.defeat()
	
func _on_update_money():
	camera_UI.update_money()
	
func _on_disable_shop():
	stage.disable_shop()
	stage.save_data()
	
