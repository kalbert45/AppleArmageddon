extends Control

# Script for selecting units, handling combat begin/end
# Note: only works for units at the moment

var selected = null
var hovered = null
var mouse_pos

var unit_starting_pos
var holding = false

func _ready():
	pass
	
func _process(_delta):
	# guard against queue free
	if not is_instance_valid(selected):
		selected = null
	if not is_instance_valid(hovered):
		hovered = null
	
	mouse_pos = get_viewport().get_mouse_position()
	
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
				if body.is_in_group("Units"):
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
				
		
	#-------------------------------------------
	# Hold + move
	else:
		if selected != null:
			if Input.is_action_just_pressed("left_click"):
				holding = true
				unit_starting_pos = selected.global_position
				
	if Input.is_action_just_released("left_click"):
		holding = false
		if selected != null:
			if selected.is_colliding():
				selected.global_position = unit_starting_pos
				unit_starting_pos = null
				selected.position_invalid = false
		
	if holding:
		selected.global_position = mouse_pos
		if selected.is_colliding():
			selected.position_invalid = true
		else:
			selected.position_invalid = false
				
	#--------------------------------------------
	
	#---------------------------------------------
	# Drop unit, revert to original position if invalid
