extends Node2D

onready var camera = $Camera2D
onready var tween = $Tween

func _ready():
	camera.position = Vector2(320, 180)

func _on_Scout_Button_pressed():
	print("pressed")
	tween.interpolate_property(camera, "position", camera.position, Vector2(960, 180), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()


func _on_Back_Button_pressed():
	tween.interpolate_property(camera, "position", camera.position, Vector2(320, 180), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
