extends Node2D

var damage = 10
var lifetime = 1
var full_rotation = 0

var source = Vector2.ZERO
var target = Vector2.ZERO
var curve_point = Vector2.ZERO

var rng = RandomNumberGenerator.new()

var burst = false
var t = 0

onready var aoe = $AOE
onready var lob = $Lob
onready var splatter = $Splatter
onready var tween = $Tween

func _ready():
	lob.visible = true
	splatter.visible = false
	
	rng.randomize()
	curve_point = Vector2((source.x + target.x)/2, min(source.y, target.y) - 40)
	full_rotation = rng.randi_range(-720,720)
	var scale_factor = rng.randf_range(1, 1.2)
	scale = Vector2(scale_factor, scale_factor)

	
func _process(delta):
	if not burst:
		rotation_degrees = lerp(0, full_rotation, t)
		global_position = _quadratic_bezier(source, curve_point, target, t)
		t += delta/lifetime
		t = clamp(t, 0, 1)
		
		if t >= 1:
			burst = true
			explode()
	
func explode():
	lob.visible = false
	splatter.visible = true
	
	var bodies = aoe.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Enemies"):
			body.attack_hit(self, damage)
			
	tween.interpolate_property(self, 'modulate', Color(1,1,1,1), Color(1,1,1,0), 1, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR, 0.2)
	tween.start()
	
func _quadratic_bezier(p0, p1, p2, t):
	var q0 = lerp(p0, p1, t)
	var q1 = lerp(p1, p2, t)
	var r = lerp(q0, q1, t)
	return r


func _on_Tween_tween_all_completed():
	queue_free()