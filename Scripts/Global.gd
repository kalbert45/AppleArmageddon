extends Node

# variables to store for each run
var units = []
var money = 0

var paths = []
var current_point = null
var current_path = []
var map_stages = {}

# Augments:
#Red0: red apples invulnerable to knockback
#Red1: red apples explode on death
#Green0: green apples have half juice requirements
#Green1: green apples +10 defense
#Pink0: pink apples can hit multiple
#Pink1: pink apples 
#Golden0: golden apples have increased range
#Golden1: golden apples cast has bigger aoe
#Crab0: crabapples get avoidability
#Crab1: crabapples attack faster

#General0: all apples +10 move speed
#General1: apples heal on kill
#General2: all apples + 2 power
#(instant augment) +40 blood
#General3: attack speed up when low hp

var augments = {"Red0": false, "Red1":false,
				"Green0": false, "Green1":false,
				"Pink0": false, "Pink1":false,
				"Golden0": false, "Golden1":false,
				"Crab0": false, "Crab1":false,
				"General0": false, "General1":false,"General2": false, "General3":false
				}

const AUGMENT_TEXT = {"Red0":"All red apples are invulnerable to knockback", 
					"Red1":"Red apples explode upon death dealing a percentage of their maximum hp",
					"Green0":"Green apples only require half the juice to cast",
					"Green1":"Green apples gain 10 defense",
					"Golden0":"Golden apples have increased range",
					"Golden1":"Golden apples' cast has a larger area of effect",
					"Pink0":"Pink apples can hit one extra enemy per attack",
					"Pink1":"dunno yet",
					"Crab0":"Crabapples gain 30% avoidability",
					"Crab1":"Crabapples gain 30% attack speed",
					"General0":"All apples gain 10 movement speed",
					"General1":"All apples heal 10% of their maximum hp upon killing someone",
					"General2":"All apples gain 2 power",
					"General3":"All apples gain up to 50% attack speed as hp decreases (maximum at 20% hp)",
					"Add_blood":"Gain 40 blood",
					}
