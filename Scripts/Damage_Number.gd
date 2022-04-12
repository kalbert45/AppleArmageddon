extends Position2D

onready var label = $Label
onready var tween = $Tween
var amount = 0
var type = ""

var velocity = Vector2.ZERO

func _ready():
	randomize()
	#var side_movement = randi() % 5
	
	label.text = str(amount)
	match type:
		"Enemy":
			label.set("custom_colors/font_color", Color("b13e53"))
			label.text = "+" + label.text
		"Unit":
			label.set("custom_colors/font_color", Color("5d275d"))
			#side_movement += -10
		"Heal":
			label.set("custom_colors/font_color", Color("38b764"))
			#side_movement += -10
		_:
			print(type + " is not a damage number type")
			
	#side_movement = 0
	#velocity = Vector2(side_movement, -10)
	
	tween.interpolate_property(self, 'position', position, Vector2(position.x,position.y - 10), 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'modulate', Color(1,1,1,0), Color(1,1,1,1), 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	
	tween.interpolate_property(self, 'position', Vector2(position.x,position.y - 10), position, 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.5)
	tween.interpolate_property(self, 'modulate', Color(1,1,1,1), Color(1,1,1,0), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.5)
	tween.start()
	

func _on_Tween_tween_all_completed():
	queue_free()

#func _process(delta):
#	position += velocity * delta
