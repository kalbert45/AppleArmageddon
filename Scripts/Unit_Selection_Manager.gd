extends Control

# Script for selecting units, handling combat begin/end
# Note: only works for units at the moment

# assumes selectable units have variables mouse_select, mouse_hover, position_invalid

var selected = null
var hovered = null
var mouse_pos

var unit_starting_pos
var holding = false

var unit_UI_scene = preload("res://Scenes/Unit_Interface.tscn")
var unit_UI

var drop_sfx = preload("res://Assets/Sounds/SFX/character_drop.wav")

onready var sfx = $SFX

func _ready():
	unit_UI = unit_UI_scene.instance()
	unit_UI.visible = false
	add_child(unit_UI)
	
func _process(_delta):
	# guard against queue free
	if not is_instance_valid(selected):
		selected = null
	if not is_instance_valid(hovered):
		hovered = null
	
	mouse_pos = get_node("/root/Main").get_global_mouse_position()
	
	var space_state = get_world_2d().get_direct_space_state()
	var result = space_state.intersect_point(mouse_pos, 1, [], 1)
	
	var body = null
	if result.size() > 0:
		body = result[0]["collider"]
	#--------------------------------------------------
	
	#----------------------------------------------
	# Mouse hover
	if not holding:
		if body != hovered:
			if hovered != null:
				hovered.mouse_hover = false
				hovered = null
			
			if body != null:
				hovered = body
				hovered.mouse_hover = true
	#--------------------------------------------
	
	#-------------------------------------------
	# Selection
	if selected != hovered:
		if Input.is_action_just_pressed("left_click"):
			if selected != null:
				selected.mouse_select = false
			selected = hovered
			if selected != null:
				selected.mouse_select = true
				unit_starting_pos = selected.global_position
				if selected.is_in_group("Units"):
					unit_UI.set_initial_values(null, selected.attack_damage, selected.defense, 
					selected.attack_speed, selected.movement_speed, selected.max_hp, selected.max_mana)
					unit_UI.visible = true
		
	#-------------------------------------------
	# Hold + move
	else:
		if selected != null:
			if not selected.active:
				if Input.is_action_just_pressed("left_click"):
					holding = true
					unit_starting_pos = selected.global_position
				
	if Input.is_action_just_released("left_click"):
		if selected != null:
			if not selected.active:
				if selected.is_colliding():
					selected.global_position = unit_starting_pos
					selected.initial_pos = unit_starting_pos
					unit_starting_pos = null
					selected.position_invalid = false
				else:
					if holding:
						# has_method(set_sprite_texture) checks if selection is a shop item
						if selected.has_method("set_sprite_texture"):
							var shop = selected.get_parent()
							var new_unit = shop.buy_unit(selected)
							if new_unit == null:
								selected.global_position = unit_starting_pos
								selected.initial_pos = unit_starting_pos
								unit_starting_pos = null
								selected.position_invalid = false
							else:
								selected = shop.buy_unit(selected)
							
						sfx.stream = drop_sfx
						sfx.play()
		holding = false
		
	if holding:
		selected.global_position = mouse_pos
		selected.initial_pos = mouse_pos
		if selected.is_colliding():
			selected.position_invalid = true
		else:
			selected.position_invalid = false
				
	#--------------------------------------------
	
	#---------------------------------------------
	# Unit UI
	if selected != null:
		if selected.is_in_group("Units"):
			unit_UI.update_values(selected.current_hp, selected.current_mana)
	else:
		unit_UI.visible = false
	
