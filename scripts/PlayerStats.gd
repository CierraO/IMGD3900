extends Node

## Inventory items
enum ITEMS {HEALTH_POTION, GREATER_HEALTH_POTION, GRANDMAS_COOKIES, ARMORSKIN_POTION, STALE_BREAD}
var ITEM_MAPPINGS = [
	{"name": "Health Potion",
	"icon": preload("res://assets/health-potion.png"),
	"script": preload("res://scripts/items/health_potion.gd"),
	"desc": "Heals 25% of max health."},
	
	{"name": "Greater Health Potion",
	"icon": preload("res://assets/greater-health-potion.png"),
	"script": preload("res://scripts/items/greater_health_potion.gd"),
	"desc": "Heals 50% of max health."},
	
	{"name": "Grandma's Cookies",
	"icon": preload("res://assets/grandma-cookies.png"),
	"script": preload("res://scripts/items/grandmas_cookies.gd"),
	"desc": "Restores all health."},
	
	{"name": "Armorskin Potion",
	"icon": preload("res://assets/armorskin-potion.png"),
	"script": preload("res://scripts/items/armorskin_potion.gd"),
	"desc": "Increases defense by 50% of base defense."},
	
	{"name": "Stale Bread",
	"icon": preload("res://assets/stale-bread.png"),
	"script": preload("res://scripts/items/stale_bread.gd"),
	"desc": "Increases defense by 100% of base defense."},
]
var inventory = [ITEMS.HEALTH_POTION]

## Player stats
## Base stats are the player's stats without equipment or potions,
## while the normal stats take modifiers into account.
var player_stats = {
	"base_max_hp": 100, "max_hp": 100, "hp": 100,
	"base_atk": 5, "atk": 5,
	"base_mag": 5, "mag": 5,
	"base_def": 2, "def": 2,
	}

var magic_attacks = {
	"Basic": preload("res://scripts/magic_attacks/basic.gd"),
	"Lower Enemy Defense": preload("res://scripts/magic_attacks/lower_enemy_def.gd"),
}
var weapons = {}
var artifacts = {}
var helmets = {}
var chestplates = {}
var boots = {}
