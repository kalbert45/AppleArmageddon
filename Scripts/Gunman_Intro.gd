extends AnimatedSprite

export var dialog_label = 0



func _ready():
	play("Idle")
	
func _process(delta):
	if animation == "Run":
		flip_h = true
		position.x += 50*delta

func _on_Axeman_Intro_animation_finished():
	
#	if animation == "Pour blood":
#		play("Idle")
#		get_parent().get_node("Dialog_Handler").continue_dialog()
	if animation == "Run":
		get_parent().get_node("Dialog_Handler").continue_dialog()
		


func _on_VisibilityNotifier2D_screen_exited():
	call_deferred("spawn_unit")


func spawn_unit():
	var gunman = load("res://Scenes/Enemies/Gunman.tscn").instance()
	gunman.position = Vector2(1000, 120)
	gunman.dialog_label = dialog_label
	get_parent().add_child(gunman)
	call_deferred("free")
