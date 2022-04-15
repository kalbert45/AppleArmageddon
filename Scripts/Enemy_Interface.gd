extends NinePatchRect

var shown_unit = null

onready var tooltip = $Tooltip
onready var unit_tooltip = $Unit_Tooltip
onready var tooltip_label = $Tooltip/Label
onready var unit_tooltip_label = $Unit_Tooltip/Label

onready var hp_bar = $HP_Bar
onready var hp_bar_label = $HP_Bar/Label2
onready var juice_bar = $Juice_Bar

func _ready():
	tooltip.visible = false
	unit_tooltip.visible = false
	
func set_initial_values(unit):
	shown_unit = unit
	
	unit_tooltip_label.bbcode_text = Global.ENEMY_TEXT[unit.label]
	
	if unit.picture != null:
		$Unit_Pic.texture = unit.picture
		
	#if unit.max_mana == 1:
	#	$Juice_Bar.visible = false
	#else:
	#	$Juice_Bar.visible = true
		
	$Attack_Symbol/Label.text = str(unit.attack_damage)
	$Defense_Symbol/Label.text = str(unit.defense)
	$AttSpeed_Symbol/Label.text = str(unit.attack_speed)
	$Movement_Symbol/Label.text = str(unit.movement_speed)
	hp_bar.value = int(unit.current_hp)
	hp_bar.max_value = unit.max_hp
	hp_bar_label.text = str(int(unit.current_hp)) + "/" + str(unit.max_hp)
	#$Juice_Bar.max_value = unit.max_mana
	
func update_values():
	if is_instance_valid(shown_unit):
		hp_bar.value = int(shown_unit.current_hp)
		hp_bar_label.text = str(int(shown_unit.current_hp)) + "/" + str(shown_unit.max_hp)
		#juice_bar.value = shown_unit.current_mana


func _on_Attack_Symbol_mouse_entered():
	tooltip.visible = true
	tooltip_label.bbcode_text = "[color=#b13e53]Power[/color]: affects damage dealt by all attacks"


func _on_Defense_Symbol_mouse_entered():
	tooltip.visible = true
	tooltip_label.bbcode_text = "[color=#3b5dc9]Defense[/color]: mitigates all damage by flat amount. Is more effective with distance."


func _on_AttSpeed_Symbol_mouse_entered():
	tooltip.visible = true
	tooltip_label.bbcode_text = "[color=#ffcd75]Attack Speed[/color]: affects speed of regular attacks"


func _on_Movement_Symbol_mouse_entered():
	tooltip.visible = true
	tooltip_label.bbcode_text = "[color=#38b764]Movement Speed[/color]: more = fast"


func _on_Unit_Interface_mouse_exited():
	tooltip.visible = false
	unit_tooltip.visible = false


func _on_Unit_Pic_mouse_entered():
	unit_tooltip.visible = true
