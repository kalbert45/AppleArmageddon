extends Node2D

signal next_stage

var new_stylebox
var pool = ["Add_blood"]
var choices = [null, null, null]

onready var sfx = $SFX

func _ready():
	new_stylebox = StyleBoxTexture.new()
	new_stylebox.texture = load("res://Assets/Sprites/GUI/GUI_EnemyPanel_selected.png")
	new_stylebox.margin_left = 4
	new_stylebox.margin_right = 4
	new_stylebox.margin_bottom = 4
	new_stylebox.margin_top = 4
	
	randomize()
	pool = ["Add_blood"]
	var possible_augments = Global.augments.keys()
	for augment in possible_augments:
		if Global.augments[augment]:
			continue
		else:
			pool.append(augment)
			
	#print(pool)


	for i in range(3):
		var rand = randi() % pool.size()
		choices[i] = pool[rand]
		pool.remove(rand)

	#print(pool)
	#print(choices)

	button_setup()

func button_setup():
	$Augment_Button1/Label.text = Global.AUGMENT_TEXT[choices[0]]
	$Augment_Button2/Label.text = Global.AUGMENT_TEXT[choices[1]]
	$Augment_Button3/Label.text = Global.AUGMENT_TEXT[choices[2]]
	
	$Augment_Button1/TextureRect.texture = Global.AUGMENT_TEXTURES[choices[0]]
	$Augment_Button2/TextureRect.texture = Global.AUGMENT_TEXTURES[choices[1]]
	$Augment_Button3/TextureRect.texture = Global.AUGMENT_TEXTURES[choices[2]]
	
	$Continue_Button.disabled = true

func _on_Augment_Button1_pressed():
	if choices[0] == "Add_blood":
		Global.money += 30
	else:
		Global.augments[choices[0]] = true
	disable_buttons()
	$Augment_Button1.set("custom_styles/disabled", new_stylebox)
	sfx.play()

func _on_Augment_Button2_pressed():
	if choices[1] == "Add_blood":
		Global.money += 30
	else:
		Global.augments[choices[1]] = true
	disable_buttons()
	$Augment_Button2.set("custom_styles/disabled", new_stylebox)
	sfx.play()


func _on_Augment_Button3_pressed():
	if choices[2] == "Add_blood":
		Global.money += 30
	else:
		Global.augments[choices[2]] = true
	disable_buttons()
	$Augment_Button3.set("custom_styles/disabled", new_stylebox)
	sfx.play()


func _on_Continue_Button_pressed():
	#print(Global.augments)
	sfx.play()
	emit_signal("next_stage")


func disable_buttons():
	$Augment_Button1.disabled = true
	$Augment_Button2.disabled = true
	$Augment_Button3.disabled = true
	$Continue_Button.disabled = false
