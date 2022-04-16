extends Node2D

signal next_stage


var pool = ["Add blood"]
var choices = [null, null, null]

onready var sfx = $SFX

func _ready():
	pool = ["Add blood"]
	var possible_augments = Global.augments.keys()
	for augment in possible_augments:
		if Global.augments[augment]:
			continue
		else:
			pool.append(augment)

	randomize()
	for i in range(3):
		var rand = randi() % possible_augments.size()
		choices[i] = possible_augments[rand]
		possible_augments.remove(rand)

	button_setup()

func button_setup():
	$Augment_Button1/Label.text = Global.AUGMENT_TEXT[choices[0]]
	$Augment_Button2/Label.text = Global.AUGMENT_TEXT[choices[1]]
	$Augment_Button3/Label.text = Global.AUGMENT_TEXT[choices[2]]
	$Continue_Button.disabled = true

func _on_Augment_Button1_pressed():
	if choices[0] == "Add Blood":
		Global.money += 40
	else:
		Global.augments[choices[0]] = true
	disable_buttons()
	sfx.play()

func _on_Augment_Button2_pressed():
	if choices[1] == "Add Blood":
		Global.money += 40
	else:
		Global.augments[choices[1]] = true
	disable_buttons()
	sfx.play()


func _on_Augment_Button3_pressed():
	if choices[2] == "Add Blood":
		Global.money += 40
	else:
		Global.augments[choices[2]] = true
	disable_buttons()
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
