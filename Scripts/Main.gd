extends Node2D

onready var transition_handler = $Transition_Handler
onready var HUD = $HUD
onready var world = $World

var new_game = true

# UI and stage scenes
var scene1 = preload("res://Scenes/Scene1.tscn")
var unit_selection = preload("res://Scenes/Unit_Selection.tscn")
var camera_control = preload("res://Scenes/Camera_Control.tscn")
var game_menu = preload("res://Scenes/Game_Menu.tscn")
var title_screen = preload("res://Scenes/Title_Screen.tscn")
var map_scene = preload("res://Scenes/Map.tscn")


var stage
var unit_UI
var camera_UI
var menu
var title
var map

func _ready():
	title = title_screen.instance()
	title.connect("start_game", self, "_on_Title_Screen_start_game")
	HUD.add_child(title)
	
	if Global.units.empty():
		Global.units.append([load("res://Scenes/Apple.tscn"), Vector2(240,180)])
		Global.money = 10

func _on_Title_Screen_start_game():
	stage = scene1.instance()
	unit_UI = unit_selection.instance()
	camera_UI = camera_control.instance()
	menu = game_menu.instance()
	
	transition_handler.transition([title], [[world, stage],
	[HUD, unit_UI], [HUD, camera_UI], [self, menu]])
	
	yield(stage, "ready")
	stage.load_data()
	unit_UI.shop = stage.shop
	yield(camera_UI, "ready")
	camera_UI.update_money()

	
	stage.connect("stage_cleared", self, "_on_stage_cleared")
	stage.connect("update_money", self, "_on_update_money")
	camera_UI.connect("next_stage", self, "_on_camera_control_next_stage")
	camera_UI.connect("disable_shop", self, "_on_disable_shop")
	menu.connect("quit_to_title", self, "_on_game_menu_quit_to_title")
	
func _on_game_menu_quit_to_title():
	title = title_screen.instance()
	
	if is_instance_valid(stage):
		stage.save_data()
	
	transition_handler.transition([stage, map, unit_UI, camera_UI, menu], [[HUD, title]])
	
	title.connect("start_game", self, "_on_Title_Screen_start_game")
	
func _on_camera_control_next_stage():
	map = map_scene.instance()
	if new_game:
		map.new = true
		new_game = false
	
	stage.save_data()
	
	transition_handler.transition([stage, camera_UI], [[world, map]])
	
	map.connect("begin_stage", self, "_on_map_begin_stage")
	
func _on_map_begin_stage(difficulty, _type):
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
	stage.connect("update_money", self, "_on_update_money")
	camera_UI.connect("next_stage", self, "_on_camera_control_next_stage")
	camera_UI.connect("disable_shop", self, "_on_disable_shop")
	
func _on_stage_cleared():
	camera_UI.activate_next_button()
	
func _on_update_money():
	camera_UI.update_money()
	
func _on_disable_shop():
	stage.disable_shop()
	
