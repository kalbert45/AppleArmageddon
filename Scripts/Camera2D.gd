extends Camera2D

func _process(delta):
	if Input.is_action_pressed("ui_right"):
		global_position.x += 10*delta
