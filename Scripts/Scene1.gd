extends Node2D

signal stage_cleared
signal defeat

var enemies

func _ready():
	enemies = get_tree().get_nodes_in_group("Enemies")
	
	for enemy in enemies:
		enemy.connect("death", self, "_on_enemy_death")
		
func _on_enemy_death():
	if get_tree().get_nodes_in_group("Enemies").size() == 1:
		emit_signal("stage_cleared")

	
	
