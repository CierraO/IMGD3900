extends Node

# Inventory items
enum ITEMS {HEALTH_POTION, GREATER_HEALTH_POTION}
var ITEM_MAPPINGS = [
	{"name": "Health Potion", \
	"icon": preload("res://assets/health-potion.png"), \
	"script": preload("res://scripts/items/health_potion.gd")},
	
	{"name": "Greater Health Potion", \
	"icon": preload("res://assets/greater-health-potion.png"), \
	"script": preload("res://scripts/items/greater_health_potion.gd")},
	
	{"name": "Grandma's Cookies", \
	"icon": preload("res://assets/grandma-cookies.png"), \
	"script": preload("res://scripts/items/grandmas_cookies.gd")}
]
var inventory = [ITEMS.HEALTH_POTION]

var atk = 5
var mag = 5
var def = 2
var max_health = 100
var current_health = 100

var magic_attacks = {
	"Basic": preload("res://scripts/magic_attacks/basic.gd"),
	"Lower Enemy Defense": preload("res://scripts/magic_attacks/lower_enemy_def.gd")
}
var weapons = {}
var artifacts = {}
var helmets = {}
var chestplates = {}
var boots = {}
