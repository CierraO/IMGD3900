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

## Equipment
enum WEAPONS {WITCH_SWORD, KNIGHT_WAND, THIEF_DAGGER}
var WEAPON_MAPPINGS = [
	{"name": "Witch's Wand",
	"icon": preload("res://assets/witch-wand.png"),
	"hp": 0,
	"atk": 1,
	"mag": 4,
	"def": 0},
	
	{"name": "Knight's Sword",
	"icon": preload("res://assets/sword-item.png"),
	"hp": 0,
	"atk": 6,
	"mag": 0,
	"def": 1},
	
	{"name": "Thief's Dagger",
	"icon": preload("res://assets/sword-item.png"),
	"hp": 0,
	"atk": 8,
	"mag": 0,
	"def": 0},
]
var weapons_collected = []

enum HELMETS {WITCH_HAT, KNIGHT_HELM, THIEF_MASK}
var HELMET_MAPPINGS = [
	{"name": "Witch's Hat",
	"icon": preload("res://assets/witch-hat.png"),
	"hp": 0,
	"atk": 0,
	"mag": 1,
	"def": 1},
	
	{"name": "Knight's Helm",
	"icon": preload("res://assets/helmet-item.png"),
	"hp": 0,
	"atk": 0,
	"mag": 0,
	"def": 2},
	
	{"name": "Thief's Mask",
	"hp": 0,
	"atk": 2,
	"mag": 0,
	"def": 1},
]
var helmets_collected = []

enum CHESTPIECES {WITCH_CLOAK, KNIGHT_PLATE, THIEF_CLOAK}
var CHESTPIECE_MAPPINGS = [
	{"name": "Witch's Cloak",
	"icon": preload("res://assets/witch-cloak.png"),
	"hp": 1,
	"atk": 0,
	"mag": 3,
	"def": 2},
	
	{"name": "Knight's Chestplate",
	"icon": preload("res://assets/chest-item.png"),
	"hp": 2,
	"atk": 0,
	"mag": 0,
	"def": 5},
	
	{"name": "Thief's Cloak",
	"icon": preload("res://assets/thief-cloak.png"),
	"hp": 0,
	"atk": 6,
	"mag": 0,
	"def": 2},
]
var chestpieces_collected = []

enum BOOTS {WITCH_BOOTS, KNIGHT_BOOTS, THIEF_BOOTS}
var BOOT_MAPPINGS = [
	{"name": "Witch's Boots",
	"hp": 0,
	"atk": 0,
	"mag": 1,
	"def": 1},
	
	{"name": "Knight's Boots",
	"hp": 0,
	"atk": 0,
	"mag": 0,
	"def": 2},
	
	{"name": "Thief's Boots",
	"hp": 0,
	"atk": 2,
	"mag": 0,
	"def": 1},
]
var boots_collected = []

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
	"Basic Magic Attack": preload("res://scripts/magic_attacks/basic.gd"),
	"Lower Enemy Defense": preload("res://scripts/magic_attacks/lower_enemy_def.gd"),
}
