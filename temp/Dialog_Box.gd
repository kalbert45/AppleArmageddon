extends RichTextLabel

signal line_end
#signal dialog_end

var line = "[center]Placeholder line[/center]"
var character_wait = 0.05
var pitch = 0.6
var end_wait = 2
var finished = false
onready var timer = $Timer
onready var timer2 = $Timer2
onready var sfx = $SFX
var length

func _ready():
	sfx.pitch_scale = pitch
#	bbcode_text = line
#	length = line.length()
#	percent_visible = 0
#	timer.wait_time = character_wait
#	timer2.wait_time = end_wait
#	timer.start()
	#print("timer started")
	
func new_line(new_text):
	sfx.pitch_scale = pitch
	sfx.play()
	bbcode_text = new_text
	length = new_text.length()
	percent_visible = 0
	timer.wait_time = character_wait
	timer2.wait_time = end_wait
	timer.start()
	
func new_animation(new_animation):
	get_parent().play(new_animation)

func _on_Timer_timeout():
	if not sfx.playing:
		sfx.play()
	#sfx.play()
	#print(percent_visible)
	percent_visible += 1.0/length

	if percent_visible >= 1:
		#sfx.stop()
		timer.stop()
		timer2.start()

func _on_Timer2_timeout():
	percent_visible = 0
	emit_signal("line_end")
	#print("timeout2")
	


