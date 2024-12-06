extends "res://scripts/magic_attacks/base_stat_affector.gd"


func use(opponent_stats=null, self_stats=null, battle=null):
	battle.display_text("You prepare to block %s's next attack." % battle.enemy.name
			if (self_stats == battle.current_player_stats) else "%s prepares to block your next attack." % battle.enemy.name)
	await(battle.textbox_closed)
	
	if (self_stats == battle.current_player_stats):
		battle.animation_player.play("full_block_attack")
		await(battle.animation_player.animation_finished)
	self_stats["next_dmg_taken_modifier"] = 0
	
	completed_use.emit()
	return 1


func get_description():
	return "Makes you immune to damage this turn."
