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

var magic_attacks = {
	"Basic Magic Attack": preload("res://scripts/magic_attacks/basic.gd"),
	"Lower Enemy Defense": preload("res://scripts/magic_attacks/lower_enemy_def.gd"),
}
