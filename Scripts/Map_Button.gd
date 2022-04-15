extends Node2D

signal pressed(point, difficulty, type)

var disabled = true
var point = Vector2.ZERO

var difficulty = 0
var type = "Normal"

onready var button = $TextureButton

func _ready():
	button.disabled = disabled
	match type:
		"Normal":
			pass
		"Question":
			button.texture_normal = load("res://Assets/Sprites/GUI/map_question_button.png")
			button.texture_hover = load("res://Assets/Sprites/GUI/map_question_button_hovered.png")
			button.texture_pressed = load("res://Assets/Sprites/GUI/map_question_button_pressed.png")
			button.texture_disabled = load("res://Assets/Sprites/GUI/map_question_button_disabled.png")
		"Augment":
			button.texture_normal = load("res://Assets/Sprites/GUI/map_augment_button.png")
			button.texture_hover = load("res://Assets/Sprites/GUI/map_augment_button_hovered.png")
			button.texture_pressed = load("res://Assets/Sprites/GUI/map_augment_button_pressed.png")
			button.texture_disabled = load("res://Assets/Sprites/GUI/map_augment_button_disabled.png")
		"Boss":
			button.texture_normal = load("res://Assets/Sprites/GUI/map_boss_button.png")
			button.texture_hover = load("res://Assets/Sprites/GUI/map_boss_button_hovered.png")
			button.texture_pressed = load("res://Assets/Sprites/GUI/map_boss_button_pressed.png")
			button.texture_disabled = load("res://Assets/Sprites/GUI/map_boss_button_disabled.png")

func clear():
	button.texture_disabled = load("res://Assets/Sprites/GUI/stage_cleared.png")
	
func possible():
	match type:
		"Normal":
			button.texture_disabled = load("res://Assets/Sprites/GUI/map_button_possible.png")
		"Question":
			button.texture_disabled = load("res://Assets/Sprites/GUI/map_question_button_possible.png")
		"Augment":
			button.texture_disabled = load("res://Assets/Sprites/GUI/map_augment_button_possible.png")
		"Boss":
			pass
	
	
func undisable():
	disabled = false
	button.disabled = disabled
	
func disable():
	disabled = true
	button.disabled = disabled

func _on_TextureButton_pressed():
	emit_signal("pressed", point, difficulty, type)
