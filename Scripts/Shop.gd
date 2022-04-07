extends Node2D

signal update_money
signal new_unit(unit)

var disabled = false

# Scene only works as a child of stage, must pass in node that units become a children of
var units_node_target = null
var rng = RandomNumberGenerator.new()

var reroll_enabled = true
var eat_readied = false
var eat = false
var tier = 0
var roll_odds = null
var shop_spots = [null, null, null]
var pool = []

var eat_sfx1 = preload("res://Assets/Sounds/SFX/apple_eat1.wav")
var eat_sfx2 = preload("res://Assets/Sounds/SFX/apple_eat2.wav")
var tree_shake_sfx1 = preload("res://Assets/Sounds/SFX/tree_shake_sfx1.wav")
var tree_shake_sfx2 = preload("res://Assets/Sounds/SFX/tree_shake_sfx2.wav")
var tree_shake_sfx3 = preload("res://Assets/Sounds/SFX/tree_shake_sfx3.wav")

var sfx_scene = preload("res://Scenes/SFX.tscn")
var shop_sprite_scene = preload("res://Scenes/Shop_Sprite.tscn")
var shop_sprite

# store scene, shop sprite, price in each variable
var apple = [preload("res://Scenes/Units/Apple.tscn"), preload("res://Assets/Sprites/apple2.png"), 2]
var crabapple = [preload("res://Scenes/Units/Crabapple.tscn"), preload("res://Assets/Sprites/crabapple.png"), 1]
var golden = [preload("res://Scenes/Units/Golden.tscn"), preload("res://Assets/Sprites/golden.png"), 4]
var green = [preload("res://Scenes/Units/Green.tscn"), preload("res://Assets/Sprites/green2.png"), 3]
var pink = [preload("res://Scenes/Units/Pink.tscn"), preload("res://Assets/Sprites/red.png"), 3]

onready var reroll_button = $Reroll_Button
onready var animation_player = $AnimationPlayer
onready var sfx = $SFX

onready var labels = [$Label1, $Label2, $Label3, $Label4]

func _ready():
	randomize()
	rng.randomize()
	#animation_player.connect("animation_finished", self, "animation_ended")
	# adjust number of shop spots and pool based on tier of shop
	match tier:
		0:
			pool = [apple, crabapple, golden, green, pink]
			
	# initialize shop
	for i in range(shop_spots.size()):
		var roll = roll()
		shop_sprite = shop_sprite_scene.instance()
		shop_sprite.unit_scene = roll[0]
		shop_sprite.set_sprite_texture(roll[1])
		shop_sprite.price = roll[2]
		shop_spots[i] = shop_sprite
		shop_sprite.initial_pos = Vector2(global_position.x-40 + 40*i, global_position.y)
		add_child(shop_sprite)
		labels[i].set_position(Vector2(-40+40*i-3, -30))
		labels[i].text = str(shop_sprite.price)

	reroll_button.set_global_position(Vector2(shop_sprite.initial_pos.x + 40 - reroll_button.get_rect().size.x/2 , 
											shop_sprite.initial_pos.y - reroll_button.get_rect().size.y/2))
	labels[3].set_position(Vector2(77, -30))
	
func _physics_process(_delta):
	if Input.is_action_just_pressed("reroll"):
		if reroll_enabled:
			reroll_shop()
	
func reroll_shop():
	if disabled:
		return
	if 1 > Global.money:
		return
		
	Global.money -= 1
	emit_signal("update_money")
	
	for i in range(shop_spots.size()):
		if is_instance_valid(shop_spots[i]):
			shop_spots[i].queue_free()
		
		var roll = roll()
		shop_sprite = shop_sprite_scene.instance()
		shop_sprite.unit_scene = roll[0]
		shop_sprite.set_sprite_texture(roll[1])
		shop_sprite.price = roll[2]
		shop_spots[i] = shop_sprite
		shop_sprite.initial_pos = Vector2(global_position.x-40 + 40*i, global_position.y)
		add_child(shop_sprite)
		labels[i].text = str(shop_sprite.price)

	var tree_sfx = sfx_scene.instance()
	tree_sfx.pitch_scale = rng.randf_range(0.8, 1.2)
	tree_sfx.db = -10
	var j = rng.randi_range(0, 2)
	match j:
		0:
			tree_sfx.stream = tree_shake_sfx1
		1:
			tree_sfx.stream = tree_shake_sfx2
		2:
			tree_sfx.stream = tree_shake_sfx3
	units_node_target.add_child(tree_sfx)
	
# properly adds unit to the stage. remove from shop
func buy_unit(unit):
	if disabled:
		return
	if unit.price > Global.money:
		return

	Global.money -= unit.price
	emit_signal("update_money")
	
	var new_unit = unit.unit_scene.instance()
	new_unit.initial_pos = unit.global_position
	
	units_node_target.add_child(new_unit)
	emit_signal("new_unit", new_unit)
	unit.queue_free()
	return new_unit
	
func roll():
	var size = pool.size()
	return pool[rng.randi_range(0, size-1)]

func _on_Reroll_Button_pressed():
	reroll_shop()
	
	
# Handle "selling" units
func sell_unit(unit):
	if not eat_readied:
		return false
		
	eat = true
	unit.die(-1)
	Global.money += 1
	emit_signal("update_money")
	
	var i = randi() % 2
	if i == 0:
		sfx.stream = eat_sfx1
	else:
		sfx.stream = eat_sfx2
	sfx.play()
	
	return true
	

func eat_ready():
	if eat_readied:
		eat_readied = false
	else:
		eat_readied = true
		

func _on_Face_body_entered(body):
	if body.has_method("set_sprite_texture"):
		return
	animation_player.play("Open")

func _on_Face_body_exited(body):
	if body.has_method("set_sprite_texture"):
		return
	if eat:
		animation_player.play("Eat")
		eat = false
	else:
		animation_player.play_backwards("Open")

#func animation_ended(animation_name):
#	pass
	
#handle disable
func disable():
	$StaticBody/CollisionShape2D.disabled = true
	disabled = true


func _on_VisibilityNotifier2D_screen_exited():
	reroll_enabled = false
	if disabled:
		queue_free()


func _on_VisibilityNotifier2D_screen_entered():
	reroll_enabled = true
