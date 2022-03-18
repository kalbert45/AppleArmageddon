extends Node2D

var source = Vector2.ZERO

const BULLET_SPEED = 400
var damage = 10
var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var lifetime = 1


func _ready():
	$Timer.wait_time = 1
	velocity = direction * BULLET_SPEED
	source = global_position
	
func _process(delta):
	global_position += velocity * delta

func _on_Area2D_body_entered(body):
	body.attack_hit(source, damage, true, 50)
	queue_free()
	

func _on_Timer_timeout():
	queue_free()
