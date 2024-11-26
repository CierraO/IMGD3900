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
var weapon_equipped = -1

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
	
	{"name": "Thief's Hood",
	"icon": preload("res://assets/thief-hood.png"),
	"hp": 0,
	"atk": 2,
	"mag": 0,
	"def": 1},
]
var helmets_collected = []
var helmet_equipped = -1

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
var chestpiece_equipped = -1

enum BOOTS {WITCH_BOOTS, KNIGHT_BOOTS, THIEF_BOOTS}
var BOOT_MAPPINGS = [
	{"name": "Witch's Boots",
	"icon": preload("res://assets/witch-boots.png"),
	"hp": 0,
	"atk": 0,
	"mag": 1,
	"def": 1},
	
	{"name": "Knight's Boots",
	"icon": preload("res://assets/boots-item.png"),
	"hp": 0,
	"atk": 0,
	"mag": 0,
	"def": 2},
	
	{"name": "Thief's Boots",
	"icon": preload("res://assets/boots-item.png"),
	"hp": 0,
	"atk": 2,
	"mag": 0,
	"def": 1},
]
var boots_collected = []
var boots_equipped = -1

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


## Add the equipment to the player's collection.
## type is one of ["weapon", "helmet", "chestpiece", "boot"].
## equipment is an equipment enum value for the given type.
func collect_equipment(type: String, equipment: int):
	if not ["weapon", "helmet", "chestpiece", "boot"].has(type):
		printerr("collect_equipment(): Invalid equipment type!")
		return
	
	if get((type + "s").to_upper()).values().has(equipment):
		get(type + "s_collected").append(equipment)
	else:
		printerr("collect_equipment(): %s doesn't exist!" % type)


## type is one of ["weapon", "helmet", "chestpiece", "boot"].
## collected_equipment is an index into the array of collected equipment of that type,
## which itself contains indexes into the MAPPINGS aray (or enum values)
func equip(type: String, collected_equipment: int):
	if not ["weapon", "helmet", "chestpiece", "boot"].has(type):
		printerr("equip(): Invalid equipment type!")
		return
	
	var equipments_collected = get(type + "s_collected")
	var EQUIP_MAPPINGS = get(type.to_upper() + "_MAPPINGS")
	
	if (equipments_collected.size() - 1 < collected_equipment
			or EQUIP_MAPPINGS.size() - 1 < equipments_collected[collected_equipment]):
		printerr("equip(): %s does not exist!" % type)
		return
	
	var equipped = get(type + "_equipped")
	if equipped != -1:
		_remove_equipment_modifiers(equipped)
	set(type + "_equipped", equipments_collected[collected_equipment])
	
	var equipment_dict = EQUIP_MAPPINGS[equipped]
	_add_equipment_modifiers(equipment_dict)


## equipment is a dictionary of equipment attributes
func _remove_equipment_modifiers(equipment: Dictionary):
	player_stats["max_hp"] -= equipment["hp"]
	player_stats["atk"] -= equipment["atk"]
	player_stats["mag"] -= equipment["mag"]
	player_stats["def"] -= equipment["def"]


## equipment is a dictionary of equipment attributes
func _add_equipment_modifiers(equipment: Dictionary):
	player_stats["max_hp"] += equipment["hp"]
	player_stats["atk"] += equipment["atk"]
	player_stats["mag"] += equipment["mag"]
	player_stats["def"] += equipment["def"]


func get_equipped_dict(type: String):
	if not ["weapon", "helmet", "chestpiece", "boot"].has(type):
		printerr("equip(): Invalid equipment type!")
		return
	
	var equipped = get(type + "_equipped")
	var EQUIP_MAPPINGS = get(type.to_upper() + "_MAPPINGS")
	return EQUIP_MAPPINGS[equipped]
