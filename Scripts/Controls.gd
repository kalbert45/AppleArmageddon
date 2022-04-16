extends Control

onready var back_button = $Back_Button

func enable():
	mouse_filter = MOUSE_FILTER_PASS
	visible = true
	
	
	back_button.disabled = false
	
func disable():
	mouse_filter = MOUSE_FILTER_IGNORE
	visible = false
	
	back_button.disabled = true
