extends TextureRect

var label = ""

onready var tooltip = $Node2D/Augment_Tooltip

func _ready():
	$Node2D/Augment_Tooltip/RichTextLabel.bbcode_text = Global.AUGMENT_TEXT[label]
	#pass
	
func _on_Augment_Icon_mouse_entered():
	tooltip.visible = true
	#print("entered")


func _on_Augment_Icon_mouse_exited():
	tooltip.visible = false
	#print("exited")
