extends "res://scripts/magic_attacks/base_stat_affector.gd"


func use(opponent_stats=null, self_stats=null, battle=null):
	battle.display_text("You cast a frost bolt." if (self_stats == battle.current_player_stats) else "%s casts a frost bolt." % battle.enemy.name)
	await(battle.textbox_closed)
	
	var dmg = self_stats["mag"] * opponent_stats["next_dmg_taken_modifier"] * 0.75
	opponent_stats["hp"] = max(0, opponent_stats["hp"] - dmg)
	battle.update_all_progress_bars()
	
	self_stats["next_dmg_taken_modifier"] = 0.5
	
	if (self_stats == battle.current_player_stats):
		battle.animation_player.play("magic_attack")
		await(battle.animation_player.animation_finished)
		if (dmg > 0):
			battle.animation_player.play("enemy_damaged")
		battle.display_text("%s takes %d damage." % [battle.enemy.name, dmg])
		await(battle.textbox_closed)
	else:
		if (dmg > 0):
			battle.animation_player.play("player_dmg")
			await(battle.animation_player.animation_finished)
		battle.display_text("%s deals %d damage." % [battle.enemy.name, dmg])
		await(battle.textbox_closed)
	
	await battle.check_if_enemy_died()
	await battle.check_if_player_died()
	completed_use.emit()
	return 1


func get_description():
	return "You deal less damage, but also take less damage this turn."
