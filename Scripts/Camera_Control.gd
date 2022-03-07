extends Node2D

onready var camera = $Camera2D
onready var tween = $Tween
onready var scout_button = $Scout_Button
onready var back_button = $Back_Button
onready var play_button = $Play_Button
onready var sfx = $SFX

func _ready():
	back_button.modulate.a = 0
	camera.position = Vector2(320, 180)
	camera.current = true

func _on_Scout_Button_pressed():
	sfx.play()
	scout_button.disabled = true
	back_button.disabled = false
	tween.interpolate_property(camera, "position", camera.position, Vector2(960, 180), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(scout_button, "modulate", scout_button.modulate, Color(1,1,1,0), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(back_button, "modulate", back_button.modulate, Color(1,1,1,1), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()


func _on_Back_Button_pressed():
	sfx.play()
	scout_button.disabled = false
	back_button.disabled = true
	tween.interpolate_property(camera, "position", camera.position, Vector2(320, 180), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(scout_button, "modulate", scout_button.modulate, Color(1,1,1,1), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(back_button, "modulate", back_button.modulate, Color(1,1,1,0), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()


func _on_Play_Button_pressed():
	sfx.play()
	scout_button.disabled = true
	back_button.disabled = true
	play_button.disabled = true
	tween.interpolate_property(camera, "position", camera.position, Vector2(960, 180), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(scout_button, "modulate", scout_button.modulate, Color(1,1,1,0), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(back_button, "modulate", back_button.modulate, Color(1,1,1,0), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(play_button, "modulate", play_button.modulate, Color(1,1,1,0), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	
	for unit in get_tree().get_nodes_in_group("Units"):
		unit.active = true
