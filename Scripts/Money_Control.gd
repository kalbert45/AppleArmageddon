extends Node2D

var disabled = false

var icon_scene = preload("res://Scenes/Other/Augment_Icon.tscn")

onready var money = $Money
onready var money_label = $Money/Label
onready var tween = $Tween
onready var augment_container = $Augment_Container

func _ready():
	if disabled:
		money.modulate.a = 0
		
func enable():
	tween.interpolate_property(money, "modulate", money.modulate, Color(1,1,1,1), 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

func _process(_delta):
	money_label.text = str(Global.money)
	
func update_augments():
	clear_augments()
	for augment in Global.augments.keys():
		if Global.augments[augment]:
			var new_icon = icon_scene.instance()
			new_icon.texture = Global.AUGMENT_TEXTURES[augment]
			new_icon.label = augment
			augment_container.add_child(new_icon)
			
func clear_augments():
	for child in augment_container.get_children():
		child.queue_free()
