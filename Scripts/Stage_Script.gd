extends Node2D

func _ready():
	$HUD/Camera_Control.connect("units_go", self, "_activate_units")
	
func _activate_units():

