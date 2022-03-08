extends CanvasLayer

signal begin_stage

func _on_Next_Stage_Button_pressed():
	emit_signal("begin_stage")
