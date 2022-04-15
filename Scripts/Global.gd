extends Node

# variables to store for each run
var units = []
var money = 0

var paths = []
var current_point = null
var current_path = []
var map_stages = {}

const MAX_DIFFICULTY = 5

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
					"Red1":"Red apples explode upon death dealing 10% of their maximum hp",
					"Green0":"Green apples only require half the juice to cast",
					"Green1":"Green apples gain 10 defense",
					"Golden0":"Golden apples have increased range",
					"Golden1":"Golden apples' cast has a larger area of effect",
					"Pink0":"Pink apples gain 10 power",
					"Pink1":"Pink apples gain more knockback power",
					"Crab0":"Crabapples gain 30% avoidability",
					"Crab1":"Crabapples gain 30% attack speed",
					"General0":"All apples gain 10 movement speed",
					"General1":"All apples heal 10% of their maximum hp upon killing someone",
					"General2":"All apples gain 2 power",
					"General3":"All apples gain up to 50% attack speed as hp decreases (maximum at 20% hp)",
					"Add_blood":"Gain 40 blood",
					}

const UNIT_TEXT = {"Apple": "[color=teal]Attack[/color]: Deal damage equal to [color=#b13e53]POWER[/color]\n[color=teal]Range[/color]: Close",
				"Brappler": "[color=teal]Attack[/color]: Deal damage equal to [color=#b13e53]POWER[/color]\n[color=teal]Range[/color]: Close\n[color=teal]Special[/color]: When moving at a certain speed, gain 10 defense",
				"Green": "[color=teal]Attack[/color]: Deal damage equal to [color=#b13e53]POWER[/color]\n[color=teal]Range[/color]: Mid\n[color=teal]Cast[/color]: Heal the lowest hp target for 6*[color=#b13e53]POWER[/color]",
				"Big Green": "[color=teal]Range[/color]: Mid\n[color=teal]Cast[/color]: Heal up to 10 apples for [color=#b13e53]POWER[/color]\n[color=teal]Special[/color]: Does not attack, but gains 10 juice per second",
				"Pink": "[color=teal]Attack[/color]: Deal damage and knockback\n[color=teal]Range[/color]: Mid",
				"Big Pink": "[color=teal]Attack[/color]: Deal damage and knockback\n[color=teal]Range[/color]: Mid\n[color=teal]Cast[/color]: Swipe front area for 2*[color=#b13e53]POWER[/color]",
				"Golden": "[color=teal]Attack[/color]: Deal damage equal to [color=#b13e53]POWER[/color]\n[color=teal]Range[/color]: Far\n[color=teal]Cast[/color]: Fire a juice lob that hits an area for [color=#b13e53]POWER[/color]",
				"Golden Malicious": "[color=teal]Attack[/color]: Deal damage equal to [color=#b13e53]POWER[/color]\n[color=teal]Range[/color]: Far\n[color=teal]Cast[/color]: Fire a juice(?) lob that hits an area for [color=#b13e53]POWER[/color]",
				"Crabapple": "[color=teal]Attack[/color]: Deal damage equal to [color=#b13e53]POWER[/color]\n[color=teal]Range[/color]: Close\n[color=teal]Special[/color]: Runs until hitting an enemy or the right stage end",
				"Dogapple": "[color=teal]Attack[/color]: Deal damage equal to [color=#b13e53]POWER[/color]\n[color=teal]Range[/color]: Close"
				}

const ENEMY_TEXT = {"Axeman": "[color=teal]Attack[/color]: Deal damage equal to [color=#b13e53]POWER[/color]\n[color=teal]Range[/color]: Close",
					"Gunman": "[color=teal]Attack[/color]: Deal damage equal to [color=#b13e53]POWER[/color]\n[color=teal]Range[/color]: Far",
					"Grunt":"[color=teal]Attack[/color]: Deal damage and knockback\n[color=teal]Range[/color]: Close",
					"Molotovman": "[color=teal]Attack[/color]: Throw a molotov that deals [color=#b13e53]POWER[/color] damage in an area\n [color=teal]Range[/color]: Far",
					"Rifleman": "[color=teal]Attack[/color]: Deal damage and knockback\n[color=teal]Range[/color]: Far",
					"Rifleman Horseback": "[color=teal]Attack[/color]: Deal damage equal to [color=#b13e53]POWER[/color]\n[color=teal]Range[/color]: Far",
					"Tractor": "[color=teal]Attack[/color]: Deal damage and knockback in an area\n[color=teal]Range[/color]: Close"
					}

# timelines. boolean for animation or not
const TIMELINES = {"intro_timeline":[[0, "[center]Umm... you sure this is a good idea?[/center]", false],
									[1, "[center]Son, I've been doin' this for years now.[/center]", false],
									[1, "[center]Trees need their protein.[/center]", false],
									[1, "[center]Now watch.[/center]", false],
									[1, "Pour blood", true],
									[1, "[center]See? No harm done.[/center]", false],
									[0, "[center]......[/center]", false],
									[0, "[center]I dunno... I've got this bad feeling...[/center]", false],
									[1, "[center]Boy, stop bein' a wuss.[/center]", false],
									[1, "[center]Let's head back.[/center]", false],
									[0, "[center]Okay..[/center]", false],
									[0, "Run", true],
									[1, "Run", true]
									]}
