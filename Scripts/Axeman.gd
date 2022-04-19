extends KinematicBody2D

# Unit/enemy shared variables
#------------------------------------------------------------------
#--********************************************************-----
signal death

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
var first_target = false

var speed = 0
var direction = Vector2.ZERO
var velocity = Vector2.ZERO

var knock_speed = 0
var knock_direction = Vector2.ZERO

var target = null
var attacking = false
var casting = false
#----------------------------------------------------------
# Unit stats
var max_hp = 120
var current_hp = 120

var attack_damage = 15
var attack_speed = 1.0
var defense = 0
var movement_speed = 50


var mouse_hover = false
var mouse_select = false

#----************************************************-----
#----------------------------------------------------------

#----------------------------------------------------------
#-----*******************************************-------

#-****************************************************---
#--------------------------------------------------------
# Grunt exclusive variable
var label = "Axeman"
var description = "Chump: Punches apples on sight."

const BLOOD = 3
export var dialog_label = 0
export var flip_h = false
#------------------------------------------------------

onready var attack_range = $Attack_Range
onready var sprite = $Sprite
onready var animation_manager = $AnimationPlayer
onready var sfx = $SFX
onready var raycasts_node = $Raycasts
onready var hp_bar = $Bars/HP_Bar

var attack_sfx = preload("res://Assets/Sounds/SFX/punch_sfx.wav")
var picture = preload("res://Assets/Sprites/axeman.png")

var damage_number_scene = preload("res://Scenes/Other/Damage_Number.tscn")
var apple_death_scene = preload("res://Scenes/Other/Person_Death.tscn")

#-------------------------------------------------------------

func _ready():
	sprite.flip_h = flip_h
	
	ready_bars()
	animation_manager.animation_speeds["Attack"] = attack_speed
	animation_manager.set_animation(IDLE_ANIM_NAME)
	#global_position = initial_pos
	for raycast in raycasts_node.get_children():
		raycast.add_exception(self)
		
	_timer = Timer.new()
	add_child(_timer)
	
	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(true)
	_timer.start()
	
func ready_bars():
	hp_bar.max_value = max_hp
	hp_bar.rect_size = Vector2(int(max_hp/10), 3)
	hp_bar.rect_position = Vector2(ceil(-hp_bar.rect_size.x/2)-1, -15)
	
func _process(delta):
	#process_stat_values(delta)
	process_mouse(delta)
	
	#if Input.is_action_just_pressed("ui_select"):
	#	active = true
	

func _physics_process(delta):
	if active:
		process_movement(delta)

#------------------------------------------------------------
# process in-game stat values, i.e. hp, mana, armor, etc.
#func process_stat_values(_delta):
	
			
#	$Bars/HP_Bar.value = current_hp
#-----------------------------------------------------------

#-----------------------------------------------------------
# process mouse_input
func process_mouse(_delta):
	if mouse_hover or mouse_select:
		sprite.material.set_shader_param("width", 1.0)
		sprite.z_index = 1
		
		if mouse_select:
			sprite.material.set_shader_param("outline_color", Color(1,0.2,0.2,1))
		else:
			sprite.material.set_shader_param("outline_color", Color(1,0.2,0.2,1))
	else:
		sprite.material.set_shader_param("width", 0.0)
		sprite.z_index = 0
		

		
	# Keep character in window

	global_position.x = clamp(global_position.x, 0, 2*get_viewport().size.x)
	global_position.y = clamp(global_position.y, 0, 2*get_viewport().size.y)
#-------------------------------------------------------------

#--------------------------------------------------------------
# process movement of unit
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
			sprite.set_flip_h(global_position.x < target.global_position.x)
			speed += ACCEL * delta
			#direction += calculate_local_avoidance()
			#direction += (15/global_position.distance_to(target.global_position))*(target.global_position - global_position)
			direction += target.global_position - global_position
			attacking = attack_range.overlaps_body(target)
			if (animation_manager.current_state != MOVEMENT_ANIM_NAME) and (speed > 10):
				animation_manager.set_animation(MOVEMENT_ANIM_NAME)
			
		# Attack target
		elif (target != null) and attacking:
			sprite.set_flip_h(global_position.x < target.global_position.x)
			speed -= DEACCEL * delta

			#direction += (15/global_position.distance_to(target.global_position))*(target.global_position - global_position)
			direction += target.global_position - global_position
			attacking = attack_range.overlaps_body(target)
			if animation_manager.current_state != ATTACK_ANIM_NAME:
				animation_manager.set_animation(ATTACK_ANIM_NAME)
			
		#  idle
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
	
	if knock_speed > 0:
		knock_speed -= 100 * delta
	knock_speed = clamp(knock_speed, 0, 100)
	
	#var slide_count = get_slide_count()
	#if slide_count:
	#	if first_target and !attacking:
	#		target_closest(null)
			
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
		if body.is_in_group("Units"):
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
#		if body.is_in_group("Enemies"):
#			dist2 = global_position.distance_squared_to(body.global_position)
#			weight = 10/ dist2
#			total += weight * (global_position - body.global_position)
#	return total
	
#--------------------------------------------------------------

#----------------------------------------------------------------
#Targeting
func _on_Aggro_Area_body_entered(body):
	if target == null:
		if body.is_in_group("Units"):
			active = true
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
	var enemies = get_tree().get_nodes_in_group("Units")
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
		target.attack_hit(self, attack_damage, false)
		
		sfx.stream = attack_sfx
		sfx.play()
		
#func cast_attack():
#	if target != null:
#		target.attack_hit(self, 2*attack_damage)
		
#------------------------------------------------------------------------


#-----------------------------------------------------------------------
# Taking damage
func attack_hit(enemy, damage, knock, knock_power=50):
	if current_hp <= 0:
		return
	
	if knock:
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
		if enemy.General1:
			if is_instance_valid(enemy):
				enemy.heal(self, enemy.max_hp / 10)
		die(dmg)
	
	#var damage_number = damage_number_scene.instance()
	#damage_number.amount = dmg
	#damage_number.type = "Enemy"
	#add_child(damage_number)
	
		
func die(_damage):
	Global.money += BLOOD
	emit_signal("death")
	
	var apple_death = apple_death_scene.instance()
	apple_death.global_position = global_position
	get_node("/root/Main/World").add_child(apple_death)
	
	var damage_number = damage_number_scene.instance()
	damage_number.amount = BLOOD
	damage_number.type = "Enemy"
	apple_death.add_child(damage_number)
	
	call_deferred("free")
#--------------------------------------------------------------------------

# make retargetting loop slow
func _on_Timer_timeout():
	retarget_loop = true
