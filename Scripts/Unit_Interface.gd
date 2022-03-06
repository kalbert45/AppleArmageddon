extends NinePatchRect

func _ready():
	pass
	
func set_initial_values(unit_texture, attack, defense, attack_speed, move_speed, max_hp, max_mana):
	if unit_texture != null:
		$Unit_Pic.texture = unit_texture
		
	$Attack_Symbol/Label.text = str(attack)
	$Defense_Symbol/Label.text = str(defense)
	$AttSpeed_Symbol/Label.text = str(attack_speed)
	$Movement_Symbol/Label.text = str(move_speed)
	$HP_Bar.max_value = max_hp
	$Juice_Bar.max_value = max_mana
	
func update_values(hp, mana):
	$HP_Bar.value = hp
	$Juice_Bar.value = mana
