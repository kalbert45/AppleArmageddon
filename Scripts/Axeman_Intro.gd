extends AnimatedSprite

export var dialog_label = 0

signal intro_ended

func _ready():
	play("Idle")
	
func _process(delta):
	if animation == "Run":
		flip_h = true
		position.x += 50*delta

func _on_Axeman_Intro_animation_finished():
	
	if animation == "Pour blood":
		play("Idle")
		get_parent().get_node("Dialog_Handler").continue_dialog()
	elif animation == "Run":
		get_parent().get_node("Dialog_Handler").continue_dialog()
		
	


func _on_VisibilityNotifier2D_screen_exited():
	call_deferred("spawn_unit")


func spawn_unit():
	get_parent().get_node("Dialog_Handler").emit_signal("dialog_end")
	var axeman = load("res://Scenes/Enemies/Axeman.tscn").instance()
	axeman.position = Vector2(940, 100)
	axeman.flip_h = true
	axeman.dialog_label = dialog_label
	get_parent().add_child(axeman)
	call_deferred("free")
