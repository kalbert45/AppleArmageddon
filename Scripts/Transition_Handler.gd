extends CanvasLayer

onready var animation_player = $AnimationPlayer
onready var color_rect = $ColorRect
onready var color_rect2 = $ColorRect2

func _ready():
	color_rect.visible = false
	color_rect2.visible = false
	
# from scenes array to free, to scenes array of arrays along with parents
func transition(from_scenes, to_scenes):
	get_tree().paused = true
	color_rect.visible = true
	color_rect2.visible = true
	animation_player.play("fade_out")
	yield(animation_player, "animation_finished")
	for from_scene in from_scenes:
		if is_instance_valid(from_scene):
			from_scene.queue_free()
	for to_scene in to_scenes:
		to_scene[0].add_child(to_scene[1])
	get_tree().paused = false
	animation_player.play("fade_in")
