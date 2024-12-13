extends "res://scripts/magic_attacks/base_stat_affector.gd"


func use(opponent_stats=null, self_stats=null, battle=null):
	battle.display_text("You cast a toxic cloud." if (self_stats == battle.current_player_stats) else "%s casts a toxic cloud." % battle.enemy.name)
	await(battle.textbox_closed)
	
	# Calculate passive damage
	var dmg = max(1, self_stats["mag"] * 0.3)
	opponent_stats["passive_dmg_taken"] += dmg
	
	# Apply damage modifier
	dmg = dmg * opponent_stats["next_dmg_taken_modifier"]
	opponent_stats["hp"] = max(0, opponent_stats["hp"] - dmg)
	battle.update_all_progress_bars()
	
	if (self_stats == battle.current_player_stats):
		battle.animation_player.play("toxic_cloud_attack")
		await(battle.animation_player.animation_finished)
		if dmg > 0:
			battle.animation_player.play("enemy_damaged")
			battle.display_text("%s takes poison damage!" % [battle.enemy.name])
			await(battle.textbox_closed)
	else:
		if dmg > 0:
			battle.animation_player.play("player_dmg")
			await(battle.animation_player.animation_finished)
			battle.display_text("You take poison damage!")
			await(battle.textbox_closed)
	
	await battle.check_if_enemy_died()
	await battle.check_if_player_died()
	completed_use.emit()
	return 1


func get_description():
	return "Causes the enemy to take small amounts of damage each turn."
