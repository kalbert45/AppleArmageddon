extends KinematicBody2D

# Unit/enemy shared variables
#------------------------------------------------------------------
#--********************************************************-----
signal death



const ACCEL = 100
const DEACCEL = 120
# TO-DO
#
#temp
var active = false


var direction = Vector2.ZERO


var target = null
var attacking = false
var casting = false
#----------------------------------------------------------
# Unit stats
var max_hp = 100
var current_hp = 100

var attack_damage = 10
var attack_speed = 1.0
var defense = 0

var attacking_modes = ["Default", "Stand by", "Chase"]
var attacking_mode = "Default"

var mouse_hover = false
var mouse_select = false

#----************************************************-----
#----------------------------------------------------------

#----------------------------------------------------------
#-----*******************************************-------

#-****************************************************---
#--------------------------------------------------------
# Turret exclusive variables
var label = "Turret"

const IDLE_ANIM_NAME = "Idle"
const ATTACK_LEFT_ANIM_NAME = "Attack_Left"
const ATTACK_UP_ANIM_NAME = "Attack_Up"
const ATTACK_RIGHT_ANIM_NAME = "Attack_Right"
const ATTACK_DOWN_ANIM_NAME = "Attack_Down"

var bullet_position1 = Vector2.ZERO
var bullet_position2 = Vector2.ZERO
#------------------------------------------------------

onready var attack_range = $Attack_Range
onready var animation_manager = $AnimationPlayer
onready var sfx1 = $SFX
onready var sfx2 = $SFX2

onready var bullet_position_left1 = $Bullet_Positions/Bullet_Position_Left1
onready var bullet_position_left2 = $Bullet_Positions/Bullet_Position_Left2
onready var bullet_position_up1 = $Bullet_Positions/Bullet_Position_Up1
onready var bullet_position_up2 = $Bullet_Positions/Bullet_Position_Up2
onready var bullet_position_right1 = $Bullet_Positions/Bullet_Position_Right1
onready var bullet_position_right2 = $Bullet_Positions/Bullet_Position_Right2
onready var bullet_position_down1 = $Bullet_Positions/Bullet_Position_Down1
onready var bullet_position_down2 = $Bullet_Positions/Bullet_Position_Down2

var attack_sfx = preload("res://Assets/Sounds/SFX/rifle_sfx2.wav")

#var damage_number_scene = preload("res://Scenes/Damage_Number.tscn")
var apple_death_scene = preload("res://Scenes/Turret_Death.tscn")
var rifleman_scene = preload("res://Scenes/Rifleman.tscn")
var bullet_scene = preload("res://Scenes/Rifle_Bullet.tscn")

#-------------------------------------------------------------

func _ready():
	ready_bars()
	animation_manager.animation_speeds["Attack_Left"] = attack_speed
	animation_manager.animation_speeds["Attack_Up"] = attack_speed
	animation_manager.animation_speeds["Attack_Right"] = attack_speed
	animation_manager.animation_speeds["Attack_Down"] = attack_speed
	animation_manager.set_animation(IDLE_ANIM_NAME)
	#global_position = initial_pos
	# change size of bars based on max_hp max_mana
	
func ready_bars():
	var hp_bar = $Bars/HP_Bar
	hp_bar.max_value = max_hp
	hp_bar.rect_size = Vector2(int(max_hp/10), 3)
	hp_bar.rect_position = Vector2(ceil(-hp_bar.rect_size.x/2)-1, -21)
	
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
		
	if mouse_select:
		$Sprite.material.set_shader_param("outline_color", Color(1,0.75,0.2,1))
	else:
		$Sprite.material.set_shader_param("outline_color", Color(0.99,1,0.25,1))
		
	# Keep character in window

	global_position.x = clamp(global_position.x, 0, 2*get_viewport().size.x)
	global_position.y = clamp(global_position.y, 0, 2*get_viewport().size.y)
#-------------------------------------------------------------

#--------------------------------------------------------------
# process movement of unit
func process_movement(delta):
	# Movement towards target
	if (target != null) and (!attacking):
		attacking = attack_range.overlaps_body(target)
		
	# Attack target
	elif (target != null) and attacking:
		direction = (target.global_position - global_position).normalized()
		attacking = attack_range.overlaps_body(target)
		var angle = rad2deg(direction.angle())
		if (angle >= 45) and (angle <= 135):
			if animation_manager.current_state == IDLE_ANIM_NAME:
				bullet_position1 = bullet_position_down1.global_position
				bullet_position2 = bullet_position_down2.global_position
				animation_manager.set_animation(ATTACK_DOWN_ANIM_NAME)
		elif (angle >= 135) or (angle <= -135):
			if animation_manager.current_state == IDLE_ANIM_NAME:
				bullet_position1 = bullet_position_left1.global_position
				bullet_position2 = bullet_position_left2.global_position
				animation_manager.set_animation(ATTACK_LEFT_ANIM_NAME)
		elif (angle <= -45) and (angle >= -135):
			if animation_manager.current_state == IDLE_ANIM_NAME:
				bullet_position1 = bullet_position_up1.global_position
				bullet_position2 = bullet_position_up2.global_position
				animation_manager.set_animation(ATTACK_UP_ANIM_NAME)
		else:
			if animation_manager.current_state == IDLE_ANIM_NAME:
				bullet_position1 = bullet_position_right1.global_position
				bullet_position2 = bullet_position_right2.global_position
				animation_manager.set_animation(ATTACK_RIGHT_ANIM_NAME)
	else:
		if animation_manager.current_state != IDLE_ANIM_NAME:
			animation_manager.set_animation(IDLE_ANIM_NAME)

	
#--------------------------------------------------------------

#----------------------------------------------------------------
#Targeting
func _on_Aggro_Area_body_entered(body):
	if target == null:
		if body.is_in_group("Units"):
			target = body
			

#Re-targeting
func _on_Aggro_Area_body_exited(body):
	if target == body:
		target = null
		var min_dist = null
		var bodies = $Aggro_Area.get_overlapping_bodies()
		for new_body in bodies:
			if not is_instance_valid(new_body):
				continue
			if new_body == body:
				continue
			if new_body.is_in_group("Units"):
				if target == null:
					target = new_body
					min_dist = global_position.distance_to(new_body.global_position)
				else:
					var dist = global_position.distance_to(new_body.global_position)
					if dist < min_dist:
						target = new_body
						
# Target closest enemy when there is no target
func target_closest(body):
	if not active:
		return
	if target != null:
		return
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
			min_dist = global_position.distance_to(closest.global_position)
		else:
			var dist = global_position.distance_to(enemy.global_position)
			if dist < min_dist:
				closest = enemy
				min_dist = dist
	target = closest
#----------------------------------------------------------------------------

#------------------------------------------------------------------------
#Attacks
func basic_attack1():
	if target != null:
		var bullet = bullet_scene.instance()
		bullet.damage = 20
		bullet.global_position = bullet_position1
		bullet.direction = (target.global_position - bullet_position1).normalized()
		bullet.rotation = bullet.direction.angle()
		get_node("/root/Main/World").add_child(bullet)

		
		sfx1.stream = attack_sfx
		sfx1.play()
		
		target = null
		target_closest(null)
		
func basic_attack2():
	if target != null:
		var bullet = bullet_scene.instance()
		bullet.damage = 20
		bullet.global_position = bullet_position2
		bullet.direction = (target.global_position - bullet_position2).normalized()
		bullet.rotation = bullet.direction.angle()
		get_node("/root/Main/World").add_child(bullet)

		
		sfx2.stream = attack_sfx
		sfx2.play()
		
		target = null
		target_closest(null)
		
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
func attack_hit(_enemy, damage, _knock, _knock_power=50):
	var dmg = damage - defense
	dmg = clamp(dmg, 0, damage)
	current_hp -= dmg
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
	
	for i in range(4):
		var rifleman = rifleman_scene.instance()
		rifleman.active = true
		rifleman.global_position = Vector2(global_position.x+i, global_position.y)
		get_parent().call_deferred("add_child", rifleman)
	
	queue_free()

