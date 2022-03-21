extends Control

# Script for selecting units, handling combat begin/end
# Note: only works for units at the moment

# assumes selectable units have variables mouse_select, mouse_hover, position_invalid

var selected = null
var hovered = null
var mouse_pos

var unit_starting_pos
var holding = false

var shop

var unit_UI_scene = preload("res://Scenes/Unit_Interface.tscn")
var unit_UI

var drop_sfx = preload("res://Assets/Sounds/SFX/character_drop.wav")
var tree_shake_sfx1 = preload("res://Assets/Sounds/SFX/tree_shake_sfx1.wav")
var tree_shake_sfx2 = preload("res://Assets/Sounds/SFX/tree_shake_sfx2.wav")
var tree_shake_sfx3 = preload("res://Assets/Sounds/SFX/tree_shake_sfx3.wav")
var pick_apple_sfx = preload("res://Assets/Sounds/SFX/pick_apple_sfx.wav")

onready var sfx = $SFX
onready var sfx2 = $SFX2
onready var sfx3 = $SFX3

func _ready():
	unit_UI = unit_UI_scene.instance()
	unit_UI.visible = false
	add_child(unit_UI)
	
	
func _process(_delta):
	# guard against queue free
	if not is_instance_valid(shop):
		shop = null
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
					unit_UI.set_initial_values(selected.picture, selected.attack_damage, selected.defense, 
					selected.attack_speed, selected.movement_speed, selected.max_hp, selected.max_mana)
					unit_UI.visible = true
		
	#-------------------------------------------
	# Hold + move
	if selected != hovered:
		if selected != null:
			if not selected.active:
				if not holding:
					if Input.is_action_pressed("left_click"):
						holding = true
						unit_starting_pos = selected.global_position
						if selected.has_method("set_sprite_texture"):
							sfx2.stream = pick_apple_sfx
							sfx2.play()
							var i = randi() % 3
							match i:
								0:
									sfx3.stream = tree_shake_sfx1
								1:
									sfx3.stream = tree_shake_sfx2
								2:
									sfx3.stream = tree_shake_sfx3
							sfx3.pitch_scale = ((randi() % 3) + 4)/5.0
							sfx3.play()
				
	handle_left_release()
		
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
	
func handle_left_release():
	if Input.is_action_just_released("left_click"):
		if not holding:
			return
		if selected == null:
			holding = false
			return
		if selected.active:
			holding = false
			return
			
		
		# if selection is colliding, check if it should be sold, else return to original position
		if selected.is_colliding():
			if selected.has_method("attack_hit"):
				if shop != null:
					shop.sell_unit(selected)
			return_to_original_pos()
			
		# check if selection is a shop item to be bought, otherwise just drop
		else:
			# has_method(set_sprite_texture) checks if selection is a shop item
			if selected.has_method("set_sprite_texture"):
				var new_unit = shop.buy_unit(selected)
				if new_unit == null:
					return_to_original_pos()
				else:
					sfx.stream = drop_sfx
					sfx.play()
			else:
				sfx.stream = drop_sfx
				sfx.play()
		holding = false
		
func return_to_original_pos():
	if not is_instance_valid(selected):
		selected = null
	else:
		selected.global_position = unit_starting_pos
		selected.initial_pos = unit_starting_pos
		unit_starting_pos = null
		selected.position_invalid = false
