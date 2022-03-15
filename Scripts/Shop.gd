extends Node2D

signal update_money

# Scene only works as a child of stage, must pass in node that units become a children of
var units_node_target = null
var rng = RandomNumberGenerator.new()

var eat_ready = false
var tier = 0
var roll_odds = null
var shop_spots = [null, null, null]
var pool = []

var shop_sprite_scene = preload("res://Scenes/Shop_Sprite.tscn")
var shop_sprite

# store scene, shop sprite, price in each variable
var apple = [preload("res://Scenes/Apple.tscn"), preload("res://Assets/Sprites/apple.png"), 2]
var crabapple = [preload("res://Scenes/Crabapple.tscn"), preload("res://Assets/Sprites/crabapple.png"), 1]
var golden = [preload("res://Scenes/Golden.tscn"), preload("res://Assets/Sprites/golden.png"), 4]
var green = [preload("res://Scenes/Green.tscn"), preload("res://Assets/Sprites/green2.png"), 4]

onready var reroll_button = $Reroll_Button
onready var animation_player = $AnimationPlayer

func _ready():
	rng.randomize()
	animation_player.connect("animation_finished", self, "animation_ended")
	# adjust number of shop spots and pool based on tier of shop
	match tier:
		0:
			pool = [apple, crabapple, golden, green]
			
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

	reroll_button.set_global_position(Vector2(shop_sprite.initial_pos.x + 40 - reroll_button.get_rect().size.x/2 , 
											shop_sprite.initial_pos.y - reroll_button.get_rect().size.y/2))
func reroll_shop():
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

# properly adds unit to the stage. remove from shop
func buy_unit(unit):
	if unit.price > Global.money:
		return

	#Global.money -= unit.price
	emit_signal("update_money")
	
	var new_unit = unit.unit_scene.instance()
	new_unit.initial_pos = unit.global_position
	
	units_node_target.add_child(new_unit)
	unit.queue_free()
	
func roll():
	var size = pool.size()
	return pool[rng.randi_range(0, size-1)]

func _on_Reroll_Button_pressed():
	reroll_shop()
	
	
# Handle "selling" units
func sell_unit(unit):
	if not eat_ready:
		return false
	unit.die(-1)
	Global.money += 1
	emit_signal("update_money")
	return true
	

func eat_ready():
	if eat_ready:
		eat_ready = false
	else:
		eat_ready = true
		

func _on_Face_body_entered(body):
	if body.has_method("set_sprite_texture"):
		return
	animation_player.play("Open")

func _on_Face_body_exited(body):
	if body.has_method("set_sprite_texture"):
		return
	animation_player.play_backwards("Open")

func animation_ended(animation_name):
	pass
	
#handle disable
func disable():
	queue_free()
