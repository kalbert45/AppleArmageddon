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
var max_hp = 100
var current_hp = 100

var attack_damage = 20
var attack_speed = 1.0
var defense = 0
var movement_speed = 60



var mouse_hover = false
var mouse_select = false

#----************************************************-----
#----------------------------------------------------------

#----------------------------------------------------------
#-----*******************************************-------

#-****************************************************---
#--------------------------------------------------------

var label = "Rifleman"
#------------------------------------------------------

onready var attack_range = $Attack_Range
onready var animation_manager = $AnimationPlayer
onready var sfx = $SFX
onready var raycasts_node = $Raycasts
onready var hp_bar = $Bars/HP_Bar

var attack_sfx = preload("res://Assets/Sounds/SFX/rifle_sfx2.wav")
var picture = preload("res://Assets/Sprites/rifleman.png")

#var damage_number_scene = preload("res://Scenes/Damage_Number.tscn")
var apple_death_scene = preload("res://Scenes/Person_Death.tscn")
var bullet_scene = preload("res://Scenes/Rifle_Bullet.tscn")

#-------------------------------------------------------------

func _ready():
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
#	process_stat_values(delta)
	process_mouse(delta)
	
	#if Input.is_action_just_pressed("ui_select"):
	#	active = true
	

func _physics_process(delta):
	if active:
		process_movement(delta)

#------------------------------------------------------------
# process in-game stat values, i.e. hp, mana, armor, etc.
#unc process_stat_values(_delta):
	
			
#	$Bars/HP_Bar.value = current_hp
#-----------------------------------------------------------

#-----------------------------------------------------------
# process mouse_input
func process_mouse(_delta):
	if mouse_hover or mouse_select:
		$Sprite.material.set_shader_param("width", 1.0)
		$Sprite.z_index = 1
	else:
		$Sprite.material.set_shader_param("width", 0.0)
		$Sprite.z_index = 0
		
	if mouse_select:
		$Sprite.material.set_shader_param("outline_color", Color(1,0.2,0.2,1))
	else:
		$Sprite.material.set_shader_param("outline_color", Color(1,0.2,0.2,1))
		
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
	if (first_target) and (target == null) and (retarget_loop):
		target_closest(null)
		retarget_loop = false
		_timer.start()

	
	if animation_manager.current_state != CAST_ANIM_NAME:
		# Movement towards target
		if (target != null) and (!attacking):
			$Sprite.set_flip_h(global_position.x < target.global_position.x)
			speed += ACCEL * delta
			direction += calculate_local_avoidance()
			direction += (15/global_position.distance_to(target.global_position))*(target.global_position - global_position)
			attacking = attack_range.overlaps_body(target)
			if (animation_manager.current_state != MOVEMENT_ANIM_NAME) and (speed > 10):
				animation_manager.set_animation(MOVEMENT_ANIM_NAME)
			
		# Attack target
		elif (target != null) and attacking:
			$Sprite.set_flip_h(global_position.x < target.global_position.x)
			speed -= DEACCEL * delta
			direction += (15/global_position.distance_to(target.global_position))*(target.global_position - global_position)
			attacking = attack_range.overlaps_body(target)
			if animation_manager.current_state != ATTACK_ANIM_NAME:
				animation_manager.set_animation(ATTACK_ANIM_NAME)
			
		# Run until first target, else return to idle
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
	
	var slide_count = get_slide_count()
	if slide_count:
		if first_target and !attacking:
			target_closest(null)
	
	if $Sprite.flip_h:
		$Bullet_Position.position.x = 12.5
	else:
		$Bullet_Position.position.x = -12.5
		
#----------------------------------------------------------
# use raycasts for retargetting or stopping
func process_raycasts(potential_target):
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
func calculate_local_avoidance():
	var total = Vector2.ZERO
	var weight
	var dist2
	for body in get_tree().get_nodes_in_group("Enemies"):
		if self == body:
			continue
		if is_instance_valid(body):
			dist2 = global_position.distance_squared_to(body.global_position)
			if dist2 == 0:
				dist2 = 1
			weight = 10/ dist2
			total += weight * (global_position - body.global_position)
	return total
	
#--------------------------------------------------------------

#----------------------------------------------------------------
#Targeting
func _on_Aggro_Area_body_entered(body):
	if target == null:
		if body.is_in_group("Units"):
			target = body
			first_target = true
			

#Re-targeting
func _on_Aggro_Area_body_exited(body):
	if target == body:
		target = null

						
# Target closest enemy when there is no target
func target_closest(body):
	if not first_target:
		return
	if not active:
		return
	#if target != null:
	#	return
	var enemies = get_tree().get_nodes_in_group("Units")
	if enemies.empty():
		return
	
	var closest = null
	var min_dist = 0
	for enemy in enemies:
		if enemy == body:
			continue
		if closest == null:
			closest = enemy
			min_dist = global_position.distance_to(closest.position)
		else:
			var dist = global_position.distance_to(enemy.position)
			if dist < min_dist:
				closest = enemy
				min_dist = dist
	target = process_raycasts(closest)
#----------------------------------------------------------------------------

#------------------------------------------------------------------------
#Attacks
func basic_attack():
	if target != null:
		var bullet = bullet_scene.instance()
		bullet.damage = attack_damage
		bullet.global_position = $Bullet_Position.global_position
		bullet.direction = (target.global_position - $Bullet_Position.global_position).normalized()
		bullet.rotation = bullet.direction.angle()
		get_node("/root/Main/World").add_child(bullet)

		
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
func attack_hit(enemy_position, damage, knock, knock_power=50):
	if knock:
		knock_direction = (global_position - enemy_position).normalized()
		knock_speed = knock_power
	
	var dmg = damage - defense
	dmg = clamp(dmg, 0, damage)
	current_hp -= dmg
	hp_bar.value = current_hp
	if current_hp <= 0:
		die(dmg)
	
	#var damage_number = damage_number_scene.instance()
	#damage_number.amount = dmg
	#damage_number.type = "Enemy"
	#add_child(damage_number)
	
		
func die(damage):
	emit_signal("death")
	
	var apple_death = apple_death_scene.instance()
	apple_death.global_position = global_position
	get_node("/root/Main/World").add_child(apple_death)
	
	#var damage_number = damage_number_scene.instance()
	#damage_number.amount = damage
	#damage_number.type = "Enemy"
	#apple_death.add_child(damage_number)
	
	queue_free()
#--------------------------------------------------------------------------

# make retargetting loop slow
func _on_Timer_timeout():
	retarget_loop = true

