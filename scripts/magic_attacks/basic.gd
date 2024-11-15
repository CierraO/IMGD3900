extends "res://scripts/magic_attacks/base_magic_attack.gd"


func use(opponent_stats=null, self_stats=null, battle=null):
	battle.display_text("You cast a basic spell." if (self_stats == battle.current_player_stats) else "%s casts a basic spell." % battle.enemy.name)
	await(battle.textbox_closed)
	
	var dmg = self_stats["mag"]
	opponent_stats["hp"] = max(0, opponent_stats["hp"] - dmg)
	battle.update_all_progress_bars()
	
	if (self_stats == battle.current_player_stats):
		battle.animation_player.play("magic_attack")
		await(battle.animation_player.animation_finished)
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
	completed_attack.emit()
