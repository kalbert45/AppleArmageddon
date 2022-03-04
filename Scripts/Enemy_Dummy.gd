extends KinematicBody2D

var count = 0
onready var max_hp = 100
onready var current_hp = 100
onready var hp_bar = $HP_Bar/ProgressBar

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
		die()
		
func die():
	queue_free()
