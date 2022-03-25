extends NinePatchRect

onready var tooltip = $Tooltip
onready var unit_tooltip = $Unit_Tooltip
onready var tooltip_label = $Tooltip/Label
onready var unit_tooltip_label = $Unit_Tooltip/Label

func _ready():
	tooltip.visible = false
	unit_tooltip.visible = false
	
func set_initial_values(unit_text, unit_texture, attack, defense, attack_speed, move_speed, max_hp, max_mana, current_hp, current_mana):
	unit_tooltip_label.text = unit_text
	
	if unit_texture != null:
		$Unit_Pic.texture = unit_texture
		
	if max_mana == 1:
		$Juice_Bar.visible = false
	else:
		$Juice_Bar.visible = true
		
	$Attack_Symbol/Label.text = str(attack)
	$Defense_Symbol/Label.text = str(defense)
	$AttSpeed_Symbol/Label.text = str(attack_speed)
	$Movement_Symbol/Label.text = str(move_speed)
	$HP_Bar.value = current_hp
	$HP_Bar.max_value = max_hp
	$HP_Bar/Label2.text = str(current_hp) + "/" + str(max_hp)
	$Juice_Bar.max_value = max_mana
	
func update_values(hp,max_hp, mana, max_mana):
	$HP_Bar.value = hp
	$HP_Bar/Label2.text = str(hp) + "/" + str(max_hp)
	$Juice_Bar.value = mana


func _on_Attack_Symbol_mouse_entered():
	tooltip.visible = true
	tooltip_label.text = "Power: affects damage dealt by all attacks"


func _on_Defense_Symbol_mouse_entered():
	tooltip.visible = true
	tooltip_label.text = "Defense: mitigates all damage by flat amount"


func _on_AttSpeed_Symbol_mouse_entered():
	tooltip.visible = true
	tooltip_label.text = "Attack Speed: affects speed of regular attacks"


func _on_Movement_Symbol_mouse_entered():
	tooltip.visible = true
	tooltip_label.text = "Movement Speed: more = fast"


func _on_Unit_Interface_mouse_exited():
	unit_tooltip.visible = false
	tooltip.visible = false


func _on_Unit_Pic_mouse_entered():
	unit_tooltip.visible = true
