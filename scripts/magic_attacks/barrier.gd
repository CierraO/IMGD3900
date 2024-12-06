extends "res://scripts/magic_attacks/base_stat_affector.gd"


func use(opponent_stats=null, self_stats=null, battle=null):
	battle.display_text("You form a protective barrier around yourself."
			if (self_stats == battle.current_player_stats) else "%s forms a protective barrier." % battle.enemy.name)
	await(battle.textbox_closed)
	
	self_stats["next_dmg_taken_modifier"] = 0
	
	completed_use.emit()
	return 1


func get_description():
	return "Makes you immune to damage this turn."
