extends CanvasLayer

signal quit_to_title
signal retry

onready var color_rect = $ColorRect
onready var resume_button = $Resume_Button
onready var options_button = $Options_Button
onready var quit_title_button = $Quit_Title_Button
onready var quit_game_button = $Quit_Game_Button
onready var menu_button = $Menu_Button

var active = false

var defeat_screen_scene = preload("res://Scenes/Defeat_Screen.tscn")

func _ready():
	resume()
	
func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if active:
			resume()
		else:
			popup()

func popup():
	get_tree().paused = true
	
	menu_button.visible = false
	menu_button.mouse_filter = menu_button.MOUSE_FILTER_IGNORE
	menu_button.disabled = true
	
	active = true
	
	color_rect.visible = true
	resume_button.visible = true
	options_button.visible = true
	quit_title_button.visible = true
	quit_game_button.visible = true
	
	color_rect.mouse_filter = color_rect.MOUSE_FILTER_STOP
	resume_button.mouse_filter = resume_button.MOUSE_FILTER_STOP
	options_button.mouse_filter = options_button.MOUSE_FILTER_STOP
	quit_title_button.mouse_filter = quit_title_button.MOUSE_FILTER_STOP
	quit_game_button.mouse_filter = quit_game_button.MOUSE_FILTER_STOP
	
	resume_button.disabled = false
	options_button.disabled = false
	quit_title_button.disabled = false
	quit_game_button.disabled = false
	
func resume():
	get_tree().paused = false
	
	menu_button.visible = true
	menu_button.mouse_filter = menu_button.MOUSE_FILTER_STOP
	menu_button.disabled = false
	
	active = false
	
	color_rect.visible = false
	resume_button.visible = false
	options_button.visible = false
	quit_title_button.visible = false
	quit_game_button.visible = false
	
	color_rect.mouse_filter = color_rect.MOUSE_FILTER_IGNORE
	resume_button.mouse_filter = resume_button.MOUSE_FILTER_IGNORE
	options_button.mouse_filter = options_button.MOUSE_FILTER_IGNORE
	quit_title_button.mouse_filter = quit_title_button.MOUSE_FILTER_IGNORE
	quit_game_button.mouse_filter = quit_game_button.MOUSE_FILTER_IGNORE
	
	resume_button.disabled = true
	options_button.disabled = true
	quit_title_button.disabled = true
	quit_game_button.disabled = true


func _on_Resume_Button_pressed():
	resume()

func _on_Quit_Title_Button_pressed():
	emit_signal("quit_to_title")

func _on_Quit_Game_Button_pressed():
	get_tree().quit()



func _on_Menu_Button_pressed():
	popup()

func defeat():
	resume()
	var defeat_screen = defeat_screen_scene.instance()
	defeat_screen.connect("retry", self, "_on_retry")
	add_child(defeat_screen)
	
func _on_retry():
	emit_signal("retry")
