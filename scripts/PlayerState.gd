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
enum MagicAttacks {BASE_MAGIC_ATK, LOWER_ENEMY_DEF}
## Magic attack data, where each attack dict's index is its ID
var MAGIC_ATTACK_MAPPINGS = [
	{"name": "Basic Magic Attack",
	"script": preload("res://scripts/magic_attacks/basic.gd"),
	"mana_cost": 4},
	
	{"name": "Lower Enemy Defense",
	"script": preload("res://scripts/magic_attacks/lower_enemy_def.gd"),
	"mana_cost": 6},
]
## List of magic attack IDs
var magic_attacks_collected = [MagicAttacks.BASE_MAGIC_ATK, MagicAttacks.LOWER_ENEMY_DEF]
