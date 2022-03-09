extends KinematicBody2D

var mouse_hover = false
var mouse_select = false
var position_invalid = false
var initial_pos = Vector2.ZERO
var active = false

var unit_scene = ""
var price = 0

func _ready():
	global_position = initial_pos
	
func set_sprite_texture(texture):
	$Sprite.texture = texture
	
#Check if colliding with anything (for select and drag)
func is_colliding():
	var bodies = $Body_Area.get_overlapping_bodies()
	if bodies.size() > 1:
		return true
	else:
		return false

func _process(delta):
	process_mouse(delta)
	
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
		$Sprite.material.set_shader_param("outline_color", Color(0.22,0.72,0.39,1))
	else:
		$Sprite.material.set_shader_param("outline_color", Color(0.22,0.72,0.39,1))
		
	# Keep character in window
	global_position.x = clamp(global_position.x, 0, get_viewport().size.x)
	global_position.y = clamp(global_position.y, 0, get_viewport().size.y)
	

