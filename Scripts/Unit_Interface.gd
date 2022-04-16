extends NinePatchRect

signal upgrade_button_pressed

var upgrade_disabled = true
var shown_unit = null

onready var tooltip = $Tooltip
onready var unit_tooltip = $Unit_Tooltip
onready var tooltip_label = $Tooltip/Label
onready var unit_tooltip_label = $Unit_Tooltip/Label
onready var upgrade_cost_tooltip = $Upgrade_Tooltip
onready var upgrade_cost_label = $Upgrade_Tooltip/Label

onready var upgrade_box = $Upgrade_Rect
onready var upgrade_button = $Upgrade_Rect/Upgrade_Button


onready var hp_bar = $HP_Bar
onready var hp_bar_label = $HP_Bar/Label2
onready var juice_bar = $Juice_Bar
onready var juice_bar_label = $Juice_Bar/Label2\

func _ready():
	upgrade_button.disabled = true
	tooltip.visible = false
	unit_tooltip.visible = false
	upgrade_cost_tooltip.visible = false
	

	
func set_initial_values(unit):
	shown_unit = unit
	upgrade_cost_tooltip.visible = false
	unit_tooltip_label.bbcode_text = Global.UNIT_TEXT[unit.label]
	
	if unit.picture != null:
		$Unit_Pic.texture = unit.picture
		
	if unit.max_mana == 1:
		juice_bar.visible = false
	else:
		juice_bar.visible = true
		
	$Attack_Symbol/Label.text = str(unit.attack_damage)
	$Defense_Symbol/Label.text = str(unit.defense)
	$AttSpeed_Symbol/Label.text = str(unit.attack_speed)
	$Movement_Symbol/Label.text = str(unit.movement_speed)
	hp_bar.value = int(unit.current_hp)
	hp_bar.max_value = unit.max_hp
	hp_bar_label.text = str(int(unit.current_hp)) + "/" + str(unit.max_hp)
	juice_bar.value = int(unit.current_mana)
	juice_bar.max_value = unit.max_mana
	juice_bar_label.text = str(int(unit.current_mana)) + "/" + str(unit.max_mana)
	
func update_values():
	if is_instance_valid(shown_unit):
		if shown_unit.upgradable:
			if (Global.money < shown_unit.upgrade_cost) or !shown_unit.bound:
				upgrade_disabled = true
				upgrade_button.disabled = true
		hp_bar.value = int(shown_unit.current_hp)
		hp_bar_label.text = str(int(shown_unit.current_hp)) + "/" + str(shown_unit.max_hp)
		juice_bar.value = int(shown_unit.current_mana)
		juice_bar_label.text = str(int(shown_unit.current_mana)) + "/" + str(shown_unit.max_mana)

func update_upgrade():
	upgrade_button.disabled = upgrade_disabled
	if is_instance_valid(shown_unit):
		if shown_unit.upgradable:
			upgrade_cost_label.text = str(shown_unit.upgrade_cost)

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
	unit_tooltip.visible = false
	tooltip.visible = false
	


func _on_Unit_Pic_mouse_entered():
	unit_tooltip.visible = true



func _on_Upgrade_Button_pressed():
	emit_signal("upgrade_button_pressed")




#func _on_Upgrade_Rect_mouse_entered():
#	upgrade_cost_tooltip.visible = true


func _on_Upgrade_Button_mouse_entered():
	if is_instance_valid(shown_unit):
		if shown_unit.upgradable:
			upgrade_cost_tooltip.visible = true


func _on_Upgrade_Button_mouse_exited():
	upgrade_cost_tooltip.visible = false
