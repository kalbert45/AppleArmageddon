extends Node2D

var pitch_scale = 1.0
var stream = null
var db = -10

onready var sfx = $SFX

func _ready():
	sfx.pitch_scale = pitch_scale
	sfx.volume_db = db
	sfx.stream = stream
	
	sfx.play()


func _on_SFX_finished():
	queue_free()
