extends Node2D

onready var tween = $Tween
onready var sfx = $SFX
var rng = RandomNumberGenerator.new()

func _ready():
	
	rng.randomize()
	sfx.pitch_scale = rng.randf_range(0.8,1.2)
	$Particles2D.emitting = true
	
	tween.interpolate_property(self, 'modulate', Color(1,1,1,1), Color(1,1,1,1), 0.4, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'modulate', Color(1,1,1,1), Color(1,1,1,0), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.4)
	tween.start()

func _on_Tween_tween_all_completed():
	queue_free()
