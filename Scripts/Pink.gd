extends KinematicBody2D

# Unit/enemy shared variables
#------------------------------------------------------------------
#--********************************************************-----
signal death
signal new_unit(unit)

const IDLE_ANIM_NAME = "Idle"
const MOVEMENT_ANIM_NAME = "Move"
const ATTACK_ANIM_NAME = "Attack"
const CAST_ANIM_NAME = "Cast"

const ACCEL = 100
const DEACCEL = 120
# TO-DO
var _timer = null
var retarget_loop = true
#temp
var active = false
var bound = true
var first_target = false

var speed = 0
var direction = Vector2.ZERO
var velocity = Vector2.ZERO

var knock_speed = 100
var knock_direction = Vector2.ZERO

var target = null
var attacking = false
var casting = false
#----------------------------------------------------------
# Unit stats
var max_hp = 100
var current_hp = 100

var attack_damage = 15
var attack_speed = 1.0
var defense = 0
var movement_speed = 50



var mouse_hover = false
var mouse_select = false

var initial_pos = Vector2.ZERO
#----************************************************-----
#----------------------------------------------------------

#----------------------------------------------------------
#-----*******************************************-------
#Unit-type exclusive variables
var max_mana = 1
var current_mana = 0

var position_invalid = false
#-****************************************************---
#--------------------------------------------------------
# Pink exclusive variables
var movement_target = Vector2.ZERO
var label = "Pink"
var description = "Pink Lady: Keeps distance and knocks back with each hit."
var upgradable = true
var upgrade_cost = 5
#------------------------------------------------------
# Augment related variables
var General1 = false
var General3 = false
var Pink0 = false
var Pink1 = false
#------------------------------------------------------

onready var attack_range = $Attack_Range
onready var animation_manager = $AnimationPlayer
onready var sfx = $SFX
onready var raycasts_node = $Raycasts
onready var hp_bar = $Bars/HP_Bar
onready var sprite = $Sprite

var attack_sfx = preload("res://Assets/Sounds/SFX/pink_attack_sfx.wav")
var picture = preload("res://Assets/Sprites/red.png")

var damage_number_scene = preload("res://Scenes/Other/Damage_Number.tscn")
var apple_death_scene = preload("res://Scenes/Other/Apple_Death.tscn")

var upgrade_scene = preload("res://Scenes/Units/Big_Pink.tscn")
#-------------------------------------------------------------

func _ready():
	if Global.augments["Pink0"]:
		Pink0 = true
	if Global.augments["Pink1"]:
		Pink1 = true
		
	if Pink0:
		attack_damage += 10
	
	ready_bars()
	animation_manager.animation_speeds["Attack"] = attack_speed
	animation_manager.set_animation(IDLE_ANIM_NAME)
	global_position = initial_pos
	
	for raycast in raycasts_node.get_children():
		raycast.add_exception(self)
		
	_timer = Timer.new()
	add_child(_timer)
	
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(true)
	_timer.start()
	
func ready_bars():

	#var juice_bar = $Bars/Juice_Bar
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	hp_bar.rect_size = Vector2(int(max_hp/10), 3)
	hp_bar.rect_position = Vector2(ceil(-hp_bar.rect_size.x/2)-1, -16)
	
	#juice_bar.max_value = max_mana
	#juice_bar.rect_size = Vector2(int(max_mana/10), 1)
	#juice_bar.rect_position = Vector2(ceil(-juice_bar.rect_size.x/2)-1, -13)
	
func _process(delta):
	#process_stat_values(delta)
	process_mouse(delta)
	
	#if Input.is_action_just_pressed("ui_select"):
	#	active = true
	

func _physics_process(delta):
	if active:
		process_movement(delta)
	else:
		if animation_manager.current_state != IDLE_ANIM_NAME:
			animation_manager.set_animation(IDLE_ANIM_NAME)

		if General3:
			var extra_att_speed = (1.25)*((max_hp-current_hp) / max_hp)
			extra_att_speed = clamp(extra_att_speed, 0, 1)
			extra_att_speed *= 0.5
			animation_manager.animation_speeds["Attack"] = attack_speed + extra_att_speed

#------------------------------------------------------------
# process in-game stat values, i.e. hp, mana, armor, etc.
#func process_stat_values(_delta):
	#if current_mana >= max_mana:
	#	if animation_manager.current_state == IDLE_ANIM_NAME:
	#		current_mana = 0
	#		animation_manager.set_animation(CAST_ANIM_NAME)
			
	#$Bars/Juice_Bar.value = current_mana
#	$Bars/HP_Bar.value = current_hp
#-----------------------------------------------------------

#-----------------------------------------------------------
# process mouse_input
func process_mouse(_delta):
	if mouse_hover or mouse_select:
		sprite.material.set_shader_param("width", 1.0)
		sprite.z_index = 1
		
		
		if position_invalid:
			sprite.material.set_shader_param("outline_color", Color(1,0.2,0.2,1))
		elif mouse_select:
			sprite.material.set_shader_param("outline_color", Color(1,0.75,0.2,1))
		else:
			sprite.material.set_shader_param("outline_color", Color(0.99,1,0.25,1))
	else:
		sprite.material.set_shader_param("width", 0.0)
		sprite.z_index = 0

		
	# Keep character in window
	if bound:
		global_position.x = clamp(global_position.x, 0, get_viewport().size.x)
		global_position.y = clamp(global_position.y, 0, get_viewport().size.y)
	else:
		global_position.x = clamp(global_position.x, 0, 2*get_viewport().size.x)
		global_position.y = clamp(global_position.y, 0, 2*get_viewport().size.y)
#-------------------------------------------------------------

#--------------------------------------------------------------
# process movement of unit
func process_movement(delta):
	if not is_instance_valid(target):
		target = null
	if (first_target) and (retarget_loop):
		target_closest(target)
		retarget_loop = false
		_timer.start()
	
	if animation_manager.current_state != CAST_ANIM_NAME:
		# Movement towards target
		if (target != null) and (!attacking):
			movement_target = set_movement_target()
			sprite.set_flip_h(global_position.x > target.global_position.x)
			speed += ACCEL * delta
			#direction += calculate_local_avoidance()
			#direction += (15/global_position.distance_to(movement_target))*(movement_target - global_position)
			direction += movement_target - global_position
			attacking = attack_range.overlaps_body(target)
			if (animation_manager.current_state != MOVEMENT_ANIM_NAME) and (speed > 10):
				animation_manager.set_animation(MOVEMENT_ANIM_NAME)
			
		# Attack target
		elif (target != null) and attacking:
			movement_target = set_movement_target()
			sprite.set_flip_h(global_position.x > target.global_position.x)
			speed -= DEACCEL * delta
	
			#direction += (15/global_position.distance_to(movement_target))*(movement_target - global_position)
			direction += movement_target - global_position
			attacking = attack_range.overlaps_body(target)
			if animation_manager.current_state != ATTACK_ANIM_NAME:

				animation_manager.set_animation(ATTACK_ANIM_NAME)
			
		# Run until first target, else return to idle
		else:
			if not first_target:
				direction = Vector2(1,0)
				speed += ACCEL * delta
				if animation_manager.current_state == IDLE_ANIM_NAME:
					animation_manager.set_animation(MOVEMENT_ANIM_NAME)
			else:
				speed -= DEACCEL * delta
				if animation_manager.current_state == MOVEMENT_ANIM_NAME:
					animation_manager.set_animation(IDLE_ANIM_NAME)
	else:
		# deaccel while casting
		speed -= DEACCEL * delta
	
	
	
	speed = clamp(speed, 0, movement_speed)
	direction = direction.clamped(1)
	velocity = direction * speed
	velocity += knock_direction * knock_speed
	velocity = move_and_slide(velocity)
	
	if sprite.flip_h:
		sprite.offset = Vector2(-32, 0)
	else:
		sprite.offset = Vector2(32, 0)
		
	if knock_speed > 0:
		knock_speed -= 100 * delta
	knock_speed = clamp(knock_speed, 0, 100)
	
	#var slide_count = get_slide_count()
	#if slide_count:
	#	if first_target and !attacking:
	#		target_closest(null)
	
# Pink has different movement target due to strange attack area
func set_movement_target():
	var target1 = Vector2(target.global_position.x - 64, target.global_position.y)
	var target2 = Vector2(target.global_position.x + 64, target.global_position.y)
	target1.x = clamp(target1.x, get_viewport().size.x, 2*get_viewport().size.x)
	target1.y = clamp(target1.y, 0, get_viewport().size.y)
	target2.x = clamp(target2.x, get_viewport().size.x, 2*get_viewport().size.x)
	target2.y = clamp(target2.y, 0, get_viewport().size.y)
	if global_position.distance_squared_to(target1) < global_position.distance_squared_to(target2):
		return target1
	else:
		return target2
		
#----------------------------------------------------------
# use raycasts for retargetting or stopping
func process_raycasts(potential_target):
	if !is_instance_valid(potential_target):
		return
	var retarget = true
	var new_target = null
	var raycasts = raycasts_node.get_children()
	var potential_direction = potential_target.global_position-global_position
	if potential_direction.length() > 0:
		raycasts_node.rotation = potential_direction.angle()
	for raycast in raycasts:
		var body = raycast.get_collider()
		if (body == potential_target) or (body == null):
			retarget = false
			break
		if body.is_in_group("Enemies"):
			new_target = body
	if retarget:
		return new_target
	else:
		return potential_target
		#if target == null:
		#	target_closest(null)
#--------------------------------------------------------------
# Local Avoidance algorithm
#func calculate_local_avoidance():
#	var total = Vector2.ZERO
#	var weight
#	var dist2
#	for body in body_area.get_overlapping_bodies():
#		if !is_instance_valid(body):
#			continue
#		if self == body:
#			continue
#		if body.is_in_group("Units"):
#			dist2 = global_position.distance_squared_to(body.global_position)
#			weight = 10/ dist2
#			total += weight * (global_position - body.global_position)
#	return total

#----------------------------------------------------------------
#Targeting
func _on_Aggro_Area_body_entered(body):
	if target == null:
		if body.is_in_group("Enemies"):
			target = body
			first_target = true
			$Aggro_Area/CollisionShape2D.set_deferred("disabled", true)
			

#Re-targeting
#func _on_Aggro_Area_body_exited(body):
#	if target == body:
#		target = null

						
# Target closest enemy when there is no target
func target_closest(body):
	if attacking and target != null:
		return
	if not first_target:
		return
	if not active:
		return
	#if target != null:
	#	return
	var enemies = get_tree().get_nodes_in_group("Enemies")
	if enemies.empty():
		return
	
	if body != null:
		if attack_range.overlaps_body(body):
			target = body
			return
		var new_target = process_raycasts(body)
		if new_target != null:
			target = new_target
			return
	
	var closest = null
	var min_dist = 0
	for enemy in enemies:
		if enemy == body:
			continue
		if closest == null:
			closest = enemy
			min_dist = global_position.distance_squared_to(closest.position)
		else:
			var dist = global_position.distance_squared_to(enemy.position)
			if dist < min_dist:
				closest = enemy
				min_dist = dist
	if closest != null and attack_range.overlaps_body(closest):
		target = closest
	else:
		target = process_raycasts(closest)
#----------------------------------------------------------------------------

#------------------------------------------------------------------------
#Attacks
func basic_attack():
	if is_instance_valid(target):
		if Pink1:
			target.attack_hit(self, attack_damage, true, 80)
		else:
			target.attack_hit(self, attack_damage, true, 50)
		#current_mana += 20
		
		sfx.stream = attack_sfx
		sfx.play()
		
		target = null
		target_closest(null)
		
func cast_attack():
	if target != null:
		target.attack_hit(self, 2*attack_damage)
		
#------------------------------------------------------------------------



#-----------------------------------------------------------------------
# Taking damage
func attack_hit(enemy, damage, knock, knock_power=50):
	if current_hp <= 0:
		return
	
	if knock:
		if is_instance_valid(enemy):
			knock_direction = (position - enemy.position).normalized()
			knock_speed = knock_power
	
	var dist
	if is_instance_valid(enemy):
		dist = position.distance_to(enemy.position)
	else:
		dist = 120
	dist = clamp(dist, 0, 120)
	var mitigation = defense * (dist / 120)
	
	var dmg = damage - mitigation
	dmg = clamp(dmg, 0, damage)
	current_hp -= dmg
	hp_bar.value = current_hp
	if current_hp <= 0:
		die()
	
	#var damage_number = damage_number_scene.instance()
	#damage_number.amount = dmg
	#damage_number.type = "Unit"
	#add_child(damage_number)
	
# Receive heal
func heal(_unit, amount):
	current_hp += amount
	current_hp = clamp(current_hp, 0, max_hp)
	hp_bar.value = current_hp
	
	var damage_number = damage_number_scene.instance()
	damage_number.amount = amount
	damage_number.type = "Heal"
	add_child(damage_number)
		
func die():
	if active:
		emit_signal("death")
	
	var apple_death = apple_death_scene.instance()
	apple_death.global_position = global_position
	get_node("/root/Main/World").add_child(apple_death)
	
	#if damage >= 0:
	#	var damage_number = damage_number_scene.instance()
	#	damage_number.amount = damage
	#	damage_number.type = "Unit"
	#	apple_death.add_child(damage_number)
	
	call_deferred("free")

# make retargetting loop slow
func _on_Timer_timeout():
	retarget_loop = true

#-----------------------------------------------------------------
# upgrade unit by replacing with new unit
func upgrade():
	if Global.money < upgrade_cost:
		return
	Global.money -= upgrade_cost
	
	var new_apple = upgrade_scene.instance()
	new_apple.initial_pos = global_position
	get_parent().add_child(new_apple)
	emit_signal("new_unit", new_apple)
	#call_deferred("emit_signal", "new_unit", new_apple)
	
	call_deferred("free")
