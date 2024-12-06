extends Node


enum State {MOVING, BATTLING, IN_MENU}
var state: State = State.MOVING

## Player stats
## Base stats are the player's stats without equipment or potions,
## while the normal stats take modifiers into account.
var player_stats = {
	"base_max_hp": 100, "max_hp": 100, "hp": 100,
	"base_atk": 5, "atk": 5,
	"base_mag": 5, "mag": 5,
	"base_def": 2, "def": 2,
	}


""" Magic attacks """
## Magic attack IDs
enum MagicAttacks {BASE_MAGIC_ATK, TOXIC_CLOUD, BARRIER, MANA_BOLT, ARCANE_CHARGE, FIREBALL, FROST_BOLT}
## Magic attack data, where each attack dict's index is its ID
var MAGIC_ATTACK_MAPPINGS = [
	{"name": "Basic Magic Attack",
	"script": preload("res://scripts/magic_attacks/basic.gd"),
	"mana_cost": 2},
	
	{"name": "Toxic Cloud",
	"script": preload("res://scripts/magic_attacks/toxic_cloud.gd"),
	"mana_cost": 4},
	
	{"name": "Barrier",
	"script": preload("res://scripts/magic_attacks/barrier.gd"),
	"mana_cost": 5},
	
	{"name": "Mana Bolt",
	"script": preload("res://scripts/magic_attacks/mana_bolt.gd"),
	"mana_cost": 4},
	
	{"name": "Arcane Charge",
	"script": preload("res://scripts/magic_attacks/arcane_charge.gd"),
	"mana_cost": 5},
	
	{"name": "Fireball",
	"script": preload("res://scripts/magic_attacks/fireball.gd"),
	"mana_cost": 10},
	
	{"name": "Frost Bolt",
	"script": preload("res://scripts/magic_attacks/frost_bolt.gd"),
	"mana_cost": 5},
]
## List of magic attack IDs
var magic_attacks_collected = [MagicAttacks.BASE_MAGIC_ATK, MagicAttacks.TOXIC_CLOUD, MagicAttacks.BARRIER, MagicAttacks.MANA_BOLT, MagicAttacks.ARCANE_CHARGE, MagicAttacks.FIREBALL, MagicAttacks.FROST_BOLT]
