extends Node2D

signal dialog_end(timeline_name)
const DIALOG_BOX = preload("res://temp/Dialog_Box.tscn")
onready var dialog_handler = $Dialog_Handler

func _ready():
	dialog_handler.connect("dialog_end", self, "end_dialog")
	for child in get_children():
		if "dialog_label" in child:
			if child.dialog_label >= 0:
				var dialog_box = DIALOG_BOX.instance()
				child.add_child(dialog_box)
				#dialog_box.set_position(Vector2.ZERO)
				dialog_handler.speakers[child.dialog_label] = dialog_box
		remove_child(child)
		get_parent().add_child(child)
	#print(dialog_handler.speakers[0].get_position())
	yield(get_tree().create_timer(1.5), "timeout")
	dialog_handler.start_dialog("intro_timeline")

func end_dialog():
	emit_signal("dialog_end", "intro_timeline")
