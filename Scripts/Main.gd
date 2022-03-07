extends Node2D

onready var transition_handler = $Transition_Handler
onready var HUD = $HUD
onready var world = $World

var scene1 = preload("res://Scenes/Scene1.tscn")
var unit_selection = preload("res://Scenes/Unit_Selection.tscn")
var camera_control = preload("res://Scenes/Camera_Control.tscn")
var game_menu = preload("res://Scenes/Game_Menu.tscn")

func _ready():
	pass

func _on_Title_Screen_start_game():
	print("signal get")
	transition_handler.transition([$HUD/Title_Screen], [[world, scene1.instance()],
	[HUD, unit_selection.instance()], [HUD, camera_control.instance()], [self, game_menu.instance()]])
