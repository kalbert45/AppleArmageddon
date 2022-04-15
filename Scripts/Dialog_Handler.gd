extends Node

signal dialog_end

var speakers = {}
var timeline
var index = 0
var line = ""

func start_dialog(timeline_name):
	for person in speakers.keys():
		speakers[person].connect("line_end", self, "continue_dialog")
	
	timeline = Global.TIMELINES[timeline_name]
	
	continue_dialog()
	#if !timeline[index][2]:
	#	line = timeline[index][1]
	#	speakers[timeline[index][0]].new_line(line)

func continue_dialog():
	
	if index < timeline.size():
		line = timeline[index][1]
		if !timeline[index][2]:
			speakers[timeline[index][0]].new_line(line)
		else:
			speakers[timeline[index][0]].new_animation(line)
			
	index += 1
