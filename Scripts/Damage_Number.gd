extends Position2D

onready var label = $Label
onready var tween = $Tween
var amount = 0
var type = ""

var velocity = Vector2.ZERO

func _ready():
	randomize()
	var side_movement = 10
	velocity = Vector2(side_movement, 10)
	
	label.text = str(amount)
	match type:
		"Enemy":
			label.set("custom_colors/font_color", Color("ef7d57"))
		"Unit":
			label.set("custom_colors/font_color", Color("5d275d"))
		"Heal":
			label.set("custom_colors/font_color", Color("38b764"))
		_:
			print(type + " is not a damage number type")
			

	#tween.interpolate_property(self, 'scale', Vector2(0.7,0.7), Vector2(1,1), 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'modulate', Color(1,1,1,0), Color(1,1,1,1), 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	#tween.interpolate_property(self, 'scale', Vector2(1,1), Vector2(0.5,0.5), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.2)
	tween.interpolate_property(self, 'modulate', Color(1,1,1,1), Color(1,1,1,0), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.2)
	tween.start()
	

func _on_Tween_tween_all_completed():
	queue_free()

func _process(delta):
	position += velocity * delta
