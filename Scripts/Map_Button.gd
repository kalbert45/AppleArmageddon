extends Node2D

signal pressed(pos)

var disabled = true
var point = Vector2.ZERO

onready var button = $TextureButton

func _ready():
	button.disabled = disabled
	
func undisable():
	disabled = false
	button.disabled = disabled
	
func disable():
	disabled = true
	button.disabled = disabled

func _on_TextureButton_pressed():
	emit_signal("pressed", point)
