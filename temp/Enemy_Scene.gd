extends Node2D

func _ready():
	print("ready called")
	for child in get_children():
		remove_child(child)
		get_parent().add_child(child)
