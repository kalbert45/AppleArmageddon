extends Node2D

#enemy data passed in
var units_dict = {}

# group_label -> index
var groups = {}

func _ready():
	randomize()
	for child in get_children():
		if "group_label" in child:
			var possible_enemies = units_dict[child.enemy_label]
			var index = 0
			if not child.group_label in groups.keys():
				index = randi() % possible_enemies.size()
				groups[child.group_label] = index
			else:
				index = groups[child.group_label]
				
			var new_enemy = possible_enemies[index].instance()
			new_enemy.global_position = child.global_position
			child.queue_free()
			get_parent().add_child(new_enemy)
			
		else:
			remove_child(child)
			get_parent().add_child(child)
	#print(dialog_handler.speakers[0].get_position())
	#yield(get_tree().create_timer(1.5), "timeout")
