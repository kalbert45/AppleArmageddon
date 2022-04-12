extends Control

# Script for selecting units, handling combat begin/end
# Note: only works for units at the moment

# assumes selectable units have variables mouse_select, mouse_hover, position_invalid
var mouse_in_window = true

var space_state = null

var selected = []
var hovered = null
var clicked = null

var mouse_pos
var viewport_mouse_pos

var draw_drag_start = Vector2.ZERO
var drag_start = Vector2.ZERO
var select_rect = RectangleShape2D.new()

#var unit_starting_pos
var holding = false
var dragging = false

var shop

var unit_UI_scene = preload("res://Scenes/Unit_Interface.tscn")
var enemy_UI_scene = preload("res://Scenes/Enemy_Interface.tscn")
var unit_UI
var enemy_UI

var drop_sfx = preload("res://Assets/Sounds/SFX/character_drop.wav")
var tree_shake_sfx1 = preload("res://Assets/Sounds/SFX/tree_shake_sfx1.wav")
var tree_shake_sfx2 = preload("res://Assets/Sounds/SFX/tree_shake_sfx2.wav")
var tree_shake_sfx3 = preload("res://Assets/Sounds/SFX/tree_shake_sfx3.wav")
var pick_apple_sfx = preload("res://Assets/Sounds/SFX/pick_apple_sfx.wav")

onready var sfx = $SFX
onready var sfx2 = $SFX2
onready var sfx3 = $SFX3
#onready var upgrade_button = $Upgrade_Button

func _ready():
	space_state = get_world_2d().get_direct_space_state()
	unit_UI = unit_UI_scene.instance()
	unit_UI.visible = false
	enemy_UI = enemy_UI_scene.instance()
	enemy_UI.visible = false
	
	add_child(unit_UI)
	add_child(enemy_UI)
	
	unit_UI.connect("upgrade_button_pressed", self, "_on_Upgrade_Button_pressed")
	
	
func _physics_process(_delta):
	# guard against queue free
	if not is_instance_valid(shop):
		shop = null
	for unit in selected:
		if not is_instance_valid(unit):
			selected.erase(unit)
	if not is_instance_valid(hovered):
		hovered = null
	
	mouse_pos = get_node("/root/Main").get_global_mouse_position()
	viewport_mouse_pos = get_global_mouse_position()
	#var overall_result = space_state.intersect_point(mouse_pos, 2, [selected])
	var result = space_state.intersect_point(mouse_pos, 1, [], 1)
	var enemy_result = space_state.intersect_point(mouse_pos, 1, [], 2)
	
	var body = null
	if result.size() > 0:
		body = result[0]["collider"]
	elif enemy_result.size() > 0:
		body = enemy_result[0]["collider"]
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


	#-------------------------------------------
	# mouse inputs
	# Selection

	if Input.is_action_just_pressed("left_click"):
		if not selected.has(hovered):
			if not selected.empty():
				for unit in selected:
					unit.mouse_select = false
			selected.clear()
		
		clicked = hovered
		# box select if nothing hovered
		if hovered == null:
			drag_start = mouse_pos
			draw_drag_start = viewport_mouse_pos
			dragging = true
		# shift select
		elif Input.is_action_pressed("shift"):
			if clicked.is_in_group("Units"):
				var label = hovered.label
				for unit in get_tree().get_nodes_in_group("Units"):
					if unit.label == label:
						selected.append(unit)
						unit.mouse_select = true
				unit_UI.set_initial_values(hovered.description, hovered.picture, hovered.attack_damage, hovered.defense, 
				hovered.attack_speed, hovered.movement_speed, hovered.max_hp, hovered.max_mana, hovered.current_hp, hovered.current_mana)
				unit_UI.visible = true
				enemy_UI.visible = false
		# otherwise normal select and show UI
		else:
			# select and show UI
			if not selected.has(hovered):
				selected.append(hovered)
			hovered.mouse_select = true
			#unit_starting_pos = hovered.global_position
			if hovered.is_in_group("Units"):
				unit_UI.set_initial_values(hovered.description, hovered.picture, hovered.attack_damage, hovered.defense, 
				hovered.attack_speed, hovered.movement_speed, hovered.max_hp, hovered.max_mana, hovered.current_hp, hovered.current_mana)
				unit_UI.visible = true
				enemy_UI.visible = false
				
			elif hovered.is_in_group("Enemies"):
				enemy_UI.set_initial_values(hovered.description, hovered.picture, hovered.attack_damage, hovered.defense, 
				hovered.attack_speed, hovered.movement_speed, hovered.max_hp, hovered.current_hp)
				enemy_UI.visible = true
				unit_UI.visible = false
		
		#--------------------------------------------
	# number key inputs for buying from shop
	if not holding:
		if is_instance_valid(shop):
			if !shop.disabled:
				if (Input.is_action_pressed("buy_1")) or (Input.is_action_pressed("buy_2")) or (Input.is_action_pressed("buy_3")):
					var shop_index = 0
					if Input.is_action_pressed("buy_1"):
						shop_index = 0
					elif Input.is_action_pressed("buy_2"):
						shop_index = 1
					elif Input.is_action_pressed("buy_3"):
						shop_index = 2
					#deselect
					if not selected.empty():
						for unit in selected:
							unit.mouse_select = false
					selected.clear()
					#hovered = null
					
					selected.append(shop.shop_spots[shop_index])
					if not is_instance_valid(selected[0]):
						selected.clear()
					if not selected.empty():
						clicked = selected[0]
						selected[0].mouse_select = true
				#			unit_starting_pos = selected.global_position
						holding = true
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
	#-------------------------------------------
	# Hold + move
	if not selected.has(hovered):
		if not selected.empty():
			if is_instance_valid(selected[0]):
				if not selected[0].active:
					if not holding:
						if Input.is_action_pressed("left_click"):
							if selected[0].is_in_group("Units"):
								holding = true
								
							if (selected[0].has_method("set_sprite_texture")) and (selected.size() == 1):
								holding = true
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
				
	
	# handle mouse hold and drag, check if position invalid
	var overall_result = []
	if holding:
		for unit in selected:
			unit.global_position = unit.initial_pos + (mouse_pos - clicked.initial_pos)
			for intersection in space_state.intersect_point(unit.global_position, 1, [unit]):
				overall_result.append(intersection)
		#selected.initial_pos = mouse_pos
		if (not overall_result.empty()) or (!mouse_in_viewport()):
			for unit in selected:
				unit.position_invalid = true
		else:
			for unit in selected:
				unit.position_invalid = false
			
	if dragging:
		if Input.is_action_pressed("left_click"):
			update()
			
	# button release
	if Input.is_action_just_released("left_click"):
		handle_release()
	if (Input.is_action_just_released("buy_1")) or (Input.is_action_just_released("buy_2")) or (Input.is_action_just_released("buy_3")):
		handle_release()
				
	#--------------------------------------------
	# Upgrade button
	if not selected.empty():
		if selected[0].is_in_group("Units"):
			if selected[0].upgradable:
				var enable_button = true
				var unit_label = selected[0].label
				for unit in selected:
					if unit.label != unit_label:
						enable_button = false
						break
				if enable_button:
					unit_UI.upgrade_disabled = false
				else:
					unit_UI.upgrade_disabled = true
				unit_UI.update_upgrade()
	else:
		unit_UI.upgrade_disabled = true
		unit_UI.update_upgrade()
	
	#---------------------------------------------
	# Unit UI
	if selected.size() >= 1:
		if selected[0].is_in_group("Units"):
			unit_UI.update_values(selected[0].current_hp, selected[0].max_hp, selected[0].current_mana, selected[0].max_mana)
			#if selected[0].upgradable:
			#	upgrade_button.disabled = false
		elif selected[0].is_in_group("Enemies"):
			enemy_UI.update_values(selected[0].current_hp, selected[0].max_hp)
	else:
		unit_UI.visible = false
		#upgrade_button.disabled = true
		enemy_UI.visible = false
		
	# ----------------------------------------------
	# unit upgrades
	if not unit_UI.upgrade_disabled:
		if Input.is_action_just_pressed("upgrade"):
			selected[0].upgrade()
			selected.remove(0)
			
	
func handle_release():
	if not (holding or dragging):
		return
	
	
	# if selection is colliding, check if it should be sold, else return to original position
	if not selected.empty():
		if not selected[0].active:
			if selected[0].position_invalid:
				if selected.size() == 1:
					if selected[0].has_method("attack_hit"):
						if shop != null:
							var sold = shop.sell_unit(selected[0])
							if sold:
								selected.erase(selected[0])
				return_to_original_pos()
				
			# check if selection is a shop item to be bought, otherwise just drop
			else:
				# has_method(set_sprite_texture) checks if selection is a shop item
				if selected[0].has_method("set_sprite_texture"):
					var new_unit = shop.buy_unit(selected[0])
					if new_unit == null:
						return_to_original_pos()
					else:
						selected.remove(0)
						sfx.stream = drop_sfx
						sfx.play()
				else:
					sfx.stream = drop_sfx
					sfx.play()
					for unit in selected:
						unit.initial_pos = unit.global_position
			
	holding = false
	
	if dragging:
		dragging = false
		update()
		var drag_end = mouse_pos
		select_rect.extents = (drag_end - drag_start)/2
		#select_rect.transform = Transform2D(0, (drag_end-drag_start)/2)
		var query = Physics2DShapeQueryParameters.new()
		query.set_shape(select_rect)
		query.set_collision_layer(1)
		query.transform = Transform2D(0, drag_start + ((drag_end - drag_start)/2))
		for item in space_state.intersect_shape(query):
			var unit = item.collider
			if unit.is_in_group("Units"):
				selected.append(unit)
				unit.mouse_select = true
		
func return_to_original_pos():
	for unit in selected:
		unit.global_position = unit.initial_pos
		unit.position_invalid = false
		
func mouse_in_viewport():
	if mouse_pos.x <= 0:
		return false
	if mouse_pos.x >= get_viewport().size.x:
		return false
	if mouse_pos.y <= 0:
		return false
	if mouse_pos.y >= get_viewport().size.y:
		return false
	return true

# draw drag select rectangle
func _draw():
	if dragging:
		draw_rect(Rect2(draw_drag_start, viewport_mouse_pos - draw_drag_start), Color(.25,.65,.96,0.5), false)


func _on_Upgrade_Button_pressed():
	selected[0].upgrade()
	selected.remove(0)
