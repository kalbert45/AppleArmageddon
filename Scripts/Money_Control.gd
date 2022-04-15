extends Node2D

var disabled = false

onready var money = $Money
onready var money_label = $Money/Label
onready var tween = $Tween

func _ready():
	if disabled:
		money.modulate.a = 0
		
func enable():
	tween.interpolate_property(money, "modulate", money.modulate, Color(1,1,1,1), 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()

func _process(delta):
	money_label.text = str(Global.money)
