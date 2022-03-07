extends CanvasLayer

onready var color_rect = $ColorRect
onready var resume_button = $Resume_Button
onready var options_button = $Options_Button
onready var quit_title_button = $Quit_Title_Button
onready var quit_game_button = $Quit_Game_Button

var active = false

func _ready():
	resume()
	
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if active:
			resume()
		else:
			popup()

func popup():
	get_tree().paused = true
	
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
