extends Control

onready var master_slider = $VBoxContainer/Master_Slider
onready var music_slider = $VBoxContainer/Music_Slider
onready var sound_slider = $VBoxContainer/Sound_Slider
onready var back_button = $Back_Button

onready var master_bus = AudioServer.get_bus_index("Master")
onready var music_bus = AudioServer.get_bus_index("Music")
onready var sound_bus = AudioServer.get_bus_index("SFX")

func _ready():
	master_slider.value = db2linear(AudioServer.get_bus_volume_db(master_bus))
	music_slider.value = db2linear(AudioServer.get_bus_volume_db(music_bus))
	sound_slider.value = db2linear(AudioServer.get_bus_volume_db(sound_bus))


func enable():
	mouse_filter = MOUSE_FILTER_PASS
	visible = true
	
	master_slider.editable = true
	music_slider.editable = true
	sound_slider.editable = true
	
	back_button.disabled = false
	
func disable():
	mouse_filter = MOUSE_FILTER_IGNORE
	visible = false
	
	master_slider.editable = false
	music_slider.editable = false
	sound_slider.editable = false
	
	back_button.disabled = true


func _on_Master_Slider_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus, linear2db(value))


func _on_Music_Slider_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus, linear2db(value))


func _on_Sound_Slider_value_changed(value):
	AudioServer.set_bus_volume_db(sound_bus, linear2db(value))
