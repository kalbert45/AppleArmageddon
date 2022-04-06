extends Node2D

signal next_stage
signal disable_shop

onready var camera = $Camera2D
onready var tween = $Tween
onready var scout_button = $Scout_Button
onready var back_button = $Back_Button
onready var play_button = $Play_Button
onready var next_button = $Next_Stage_Button
onready var sfx = $SFX
onready var money_label = $Money/Label

func _ready():
	back_button.modulate.a = 0
	
	camera.position = Vector2(320, 180)
	camera.current = true
	
	next_button.disabled = true
	next_button.visible = false
	next_button.modulate.a = 0

func _on_Scout_Button_pressed():
	sfx.play()
	scout_button.disabled = true
	back_button.disabled = false
	tween.interpolate_property(camera, "position", camera.position, Vector2(960, 180), 0.6, Tween.EASE_OUT, Tween.EASE_OUT)
	tween.interpolate_property(scout_button, "modulate", scout_button.modulate, Color(1,1,1,0), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(back_button, "modulate", back_button.modulate, Color(1,1,1,1), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()


func _on_Back_Button_pressed():
	sfx.play()
	scout_button.disabled = false
	back_button.disabled = true
	tween.interpolate_property(camera, "position", camera.position, Vector2(320, 180), 0.6, Tween.EASE_OUT, Tween.EASE_OUT)
	tween.interpolate_property(scout_button, "modulate", scout_button.modulate, Color(1,1,1,1), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(back_button, "modulate", back_button.modulate, Color(1,1,1,0), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()


func _on_Play_Button_pressed():
	sfx.play()
	scout_button.disabled = true
	back_button.disabled = true
	play_button.disabled = true
	tween.interpolate_property(camera, "position", camera.position, Vector2(960, 180), 0.6, Tween.EASE_OUT, Tween.EASE_OUT, 1)
	tween.interpolate_property(scout_button, "modulate", scout_button.modulate, Color(1,1,1,0), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(back_button, "modulate", back_button.modulate, Color(1,1,1,0), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(play_button, "modulate", play_button.modulate, Color(1,1,1,0), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	
	for unit in get_tree().get_nodes_in_group("Units"):
		unit.active = true
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		enemy.active = true
		
	emit_signal("disable_shop")


func _on_Next_Stage_Button_pressed():
	emit_signal("next_stage")
	
func activate_next_button():
	next_button.disabled = false
	next_button.visible = true
	tween.interpolate_property(next_button, "modulate", next_button.modulate, Color(1,1,1,1), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	
func update_money():
	money_label.text = str(Global.money)
	
