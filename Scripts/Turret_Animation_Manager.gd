extends AnimationPlayer

var states = {
	"Idle":["Idle", "Attack_Left", "Attack_Up", "Attack_Right", "Attack_Down"],
	"Attack_Left":["Idle"],
	"Attack_Up":["Idle"],
	"Attack_Right":["Idle"],
	"Attack_Down":["Idle"]
}
var animation_speeds = {
	"Idle":1,
	"Attack_Left":1,
	"Attack_Up":1,
	"Attack_Right":1,
	"Attack_Down":1
}

var current_state = null

func _ready():
	set_animation("Idle")
	connect("animation_finished", self, "animation_ended")
	
func set_animation(animation_name):
	if animation_name == current_state:
		print("Turret_Animation_Manager.gd -- WARNING: animation is already ", animation_name)
		return true
		
	if has_animation(animation_name):
		if current_state != null:
			var possible_animations = states[current_state]
			if animation_name in possible_animations:
				current_state = animation_name
				play(animation_name, -1, animation_speeds[animation_name])
				return true
			else:
				print("Turret_Animation_Manager.gd -- WARNING: Cannot change to ", animation_name)
				return false
		else:
			current_state = animation_name
			play(animation_name, -1, animation_speeds[animation_name])
			return true
	return false
	
func animation_ended(animation_name):
	if animation_name == "Attack_Left":
		set_animation("Idle")
	if animation_name == "Attack_Up":
		set_animation("Idle")
	if animation_name == "Attack_Right":
		set_animation("Idle")
	if animation_name == "Attack_Down":
		set_animation("Idle")
