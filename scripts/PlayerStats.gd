extends Node
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
