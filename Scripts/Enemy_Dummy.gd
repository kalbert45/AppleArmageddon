extends KinematicBody2D

var count = 0
onready var max_hp = 100
onready var current_hp = 100
onready var hp_bar = $HP_Bar/ProgressBar

var apple_death_scene = preload("res://Scenes/Apple_Death.tscn")
var damage_number_scene = preload("res://Scenes/Damage_Number.tscn")

func _ready():
	pass
	
func _process(_delta):
	hp_bar.value = current_hp
	
func _physics_process(delta):
	global_position.y = 180+60*sin(count)
	count += 0.01

func attack_hit(enemy, damage):
	current_hp -= damage
	if current_hp <= 0:
		die(damage)
	
	var damage_number = damage_number_scene.instance()
	damage_number.amount = damage
	damage_number.type = "Enemy"
	add_child(damage_number)
	
		
func die(damage):
	var apple_death = apple_death_scene.instance()
	apple_death.global_position = global_position
	get_node("/root/Main/World").add_child(apple_death)
	
	var damage_number = damage_number_scene.instance()
	damage_number.amount = damage
	damage_number.type = "Enemy"
	apple_death.add_child(damage_number)
	
	queue_free()
