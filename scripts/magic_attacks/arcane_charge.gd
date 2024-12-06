extends "res://scripts/magic_attacks/base_stat_affector.gd"


func use(opponent_stats=null, self_stats=null, battle=null):
	battle.display_text("You charge up your next attack!"
			if (self_stats == battle.current_player_stats) else "%s charges up its next attack!" % battle.enemy.name)
	await(battle.textbox_closed)
	
	#opponent_stats["next_dmg_taken_modifier"] = 2
	
	completed_use.emit()
	return 2

func get_description():
	return "Doesn't deal damage this turn, but makes your next attack deal double damage."
