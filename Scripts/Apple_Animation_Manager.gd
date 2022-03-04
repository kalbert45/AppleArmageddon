extends AnimationPlayer

var states = {
	"Idle":["Idle", "Move", "Attack", "Cast"],
	"Move":["Idle", "Attack", "Cast"],
	"Attack":["Idle", "Move", "Cast"],
	"Cast":["Idle", "Move", "Attack"]
}
var animation_speeds = {
	"Idle":1,
	"Move":1,
	"Attack":1,
	"Cast":1
}

var current_state = null

func _ready():
	set_animation("Idle")
	connect("animation_finished", self, "animation_ended")
	
func set_animation(animation_name):
	if animation_name == current_state:
		print("Apple_Animation_Manager.gd -- WARNING: animation is already ", animation_name)
		return true
		
	if has_animation(animation_name):
		if current_state != null:
			var possible_animations = states[current_state]
			if animation_name in possible_animations:
				current_state = animation_name
				play(animation_name, -1, animation_speeds[animation_name])
				return true
			else:
				print("Apple_Animation_Manager.gd -- WARNING: Cannot change to ", animation_name)
				return false
		else:
			current_state = animation_name
			play(animation_name, -1, animation_speeds[animation_name])
			return true
	return false
	
func animation_ended(animation_name):
	if animation_name == "Cast":
		set_animation("Idle")
	if animation_name == "Attack":
		set_animation("Idle")
