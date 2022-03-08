extends KinematicBody2D

# Unit/enemy shared variables
#------------------------------------------------------------------
#--********************************************************-----
const IDLE_ANIM_NAME = "Idle"
const MOVEMENT_ANIM_NAME = "Move"
const ATTACK_ANIM_NAME = "Attack"
const CAST_ANIM_NAME = "Cast"

const ACCEL = 100
const DEACCEL = 120
# TO-DO
#
#temp
var active = false
var first_target = false

var speed = 0
var direction = Vector2.ZERO
var velocity = Vector2.ZERO

var target = null
var attacking = false
var casting = false
#----------------------------------------------------------
# Unit stats
var max_hp = 100
var current_hp = 100

var attack_damage = 10
var attack_speed = 1.0
var attack_range_size = 1.0
var defense = 10
var movement_speed = 50

var attacking_modes = ["Default", "Stand by", "Chase"]
var attacking_mode = "Default"

var mouse_hover = false
var mouse_select = false

var initial_pos = Vector2.ZERO
#----************************************************-----
#----------------------------------------------------------

#----------------------------------------------------------
#-----*******************************************-------
#Unit-type exclusive variables
var max_mana = 100
var current_mana = 20

var position_invalid = false
#-****************************************************---
#--------------------------------------------------------
# Apple exclusive variable
var label = "Apple"
#------------------------------------------------------

onready var attack_range = $Attack_Range
onready var animation_manager = $AnimationPlayer
onready var sfx = $SFX

var attack_sfx = preload("res://Assets/Sounds/SFX/attack_sfx.wav")
var damage_number_scene = preload("res://Scenes/Damage_Number.tscn")
var apple_death_scene = preload("res://Scenes/Apple_Death.tscn")

#-------------------------------------------------------------

func _ready():
	animation_manager.set_animation(IDLE_ANIM_NAME)
	global_position = initial_pos
	
func _process(delta):
	process_stat_values(delta)
	process_mouse(delta)
	
	#if Input.is_action_just_pressed("ui_select"):
	#	active = true
	

func _physics_process(delta):
	if active:
		process_movement(delta)

#------------------------------------------------------------
# process in-game stat values, i.e. hp, mana, armor, etc.
func process_stat_values(_delta):
	if current_mana >= max_mana:
		if animation_manager.current_state == IDLE_ANIM_NAME:
			current_mana = 0
			animation_manager.set_animation(CAST_ANIM_NAME)
			
	$Bars/Juice_Bar.value = current_mana
	$Bars/HP_Bar.value = current_hp
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
		
	if position_invalid:
		$Sprite.material.set_shader_param("outline_color", Color(1,0.2,0.2,1))
	elif mouse_select:
		$Sprite.material.set_shader_param("outline_color", Color(1,0.75,0.2,1))
	else:
		$Sprite.material.set_shader_param("outline_color", Color(0.99,1,0.25,1))
		
	# Keep character in window
	if not active:
		global_position.x = clamp(global_position.x, 0, get_viewport().size.x)
		global_position.y = clamp(global_position.y, 0, get_viewport().size.y)
	else:
		global_position.x = clamp(global_position.x, 0, 2*get_viewport().size.x)
		global_position.y = clamp(global_position.y, 0, 2*get_viewport().size.y)
#-------------------------------------------------------------

#--------------------------------------------------------------
# process movement of unit
func process_movement(delta):
	if animation_manager.current_state != CAST_ANIM_NAME:
		# Movement towards target
		if (target != null) and (!attacking):
			$Sprite.set_flip_h(global_position.x > target.global_position.x)
			speed += ACCEL * delta
			direction = (target.global_position - global_position).normalized()
			attacking = attack_range.overlaps_body(target)
			if animation_manager.current_state == IDLE_ANIM_NAME:
				animation_manager.set_animation(MOVEMENT_ANIM_NAME)
			
		# Attack target
		elif (target != null) and attacking:
			$Sprite.set_flip_h(global_position.x > target.global_position.x)
			speed -= DEACCEL * delta
			direction = (target.global_position - global_position).normalized()
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
	
	velocity = direction * speed
	velocity = move_and_slide(velocity)
	
#--------------------------------------------------------------

#----------------------------------------------------------------
#Targeting
func _on_Aggro_Area_body_entered(body):
	if target == null:
		if body.is_in_group("Enemies"):
			target = body
			first_target = true
			

#Re-targeting
func _on_Aggro_Area_body_exited(body):
	if target == body:
		target = null
		var min_dist = null
		var bodies = $Aggro_Area.get_overlapping_bodies()
		for new_body in bodies:
			if new_body == body:
				continue
			if new_body.is_in_group("Enemies"):
				if target == null:
					target = new_body
					min_dist = global_position.distance_to(new_body.global_position)
				else:
					var dist = global_position.distance_to(new_body.global_position)
					if dist < min_dist:
						target = new_body
#----------------------------------------------------------------------------

#------------------------------------------------------------------------
#Attacks
func basic_attack():
	if target != null:
		target.attack_hit(self, attack_damage)
		current_mana += 20
		
		sfx.stream = attack_sfx
		sfx.play()
		
func cast_attack():
	if target != null:
		target.attack_hit(self, 2*attack_damage)
		
#------------------------------------------------------------------------

#-------------------------------------------------------------------------
#Check if colliding with anything (for select and drag)
func is_colliding():
	var bodies = $Body_Area.get_overlapping_bodies()
	if bodies.size() > 1:
		return true
	else:
		return false
#--------------------------------------------------------------------------

#-----------------------------------------------------------------------
# Taking damage
func attack_hit(enemy, damage):
	current_hp -= damage
	if current_hp <= 0:
		die(damage)
	
	var damage_number = damage_number_scene.instance()
	damage_number.amount = damage
	damage_number.type = "Unit"
	add_child(damage_number)
	
		
func die(damage):
	var apple_death = apple_death_scene.instance()
	apple_death.global_position = global_position
	get_node("/root/Main/World").add_child(apple_death)
	
	var damage_number = damage_number_scene.instance()
	damage_number.amount = damage
	damage_number.type = "Unit"
	apple_death.add_child(damage_number)
	
	queue_free()

