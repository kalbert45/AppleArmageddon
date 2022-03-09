extends Node2D

signal update_money

# Scene only works as a child of stage, must pass in node that units become a children of
var units_node_target = null
var rng = RandomNumberGenerator.new()

var tier = 0
var roll_odds = null
var shop_spots = [null, null, null]
var pool = []

var shop_sprite_scene = preload("res://Scenes/Shop_Sprite.tscn")

# store scene, shop sprite, price in each variable
var apple = [preload("res://Scenes/Apple.tscn"), preload("res://Assets/Sprites/apple.png"), 1]
var temp_apple = [preload("res://Scenes/Apple.tscn"), preload("res://Assets/Sprites/appletemp.png"), 2]

func _ready():
	rng.randomize()
	# adjust number of shop spots and pool based on tier of shop
	match tier:
		0:
			pool = [apple, temp_apple]
			
	# initialize shop
	for i in range(shop_spots.size()):
		var roll = roll()
		var shop_sprite = shop_sprite_scene.instance()
		shop_sprite.unit_scene = roll[0]
		shop_sprite.set_sprite_texture(roll[1])
		shop_sprite.price = roll[2]
		shop_spots[i] = shop_sprite
		shop_sprite.initial_pos = Vector2(global_position.x-40 + 40*i, global_position.y)
		add_child(shop_sprite)

func reroll_shop():
	pass

# properly adds unit to the stage. remove from shop
func buy_unit(unit):
	if unit.price > Global.money:
		return

	Global.money -= unit.price
	emit_signal("update_money")
	
	var new_unit = unit.unit_scene.instance()
	new_unit.initial_pos = unit.global_position
	
	units_node_target.add_child(new_unit)
	unit.queue_free()
	
func roll():
	var size = pool.size()
	return pool[rng.randi_range(0, size-1)]
