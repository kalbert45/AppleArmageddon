extends Control

signal retry

func _ready():
	get_tree().paused = true

func _on_Retry_Button_pressed():
	emit_signal("retry")

func _enable_button():
	$Retry_Button.disabled = false
