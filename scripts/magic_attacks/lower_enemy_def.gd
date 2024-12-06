extends "res://scripts/magic_attacks/base_stat_affector.gd"


func use(opponent_stats=null, self_stats=null, battle=null):
	battle.display_text("You cast a basic spell." if (self_stats == battle.current_player_stats) else "%s casts a basic spell." % battle.enemy.name)
	await(battle.textbox_closed)
	
	var dmg = randi_range(1, self_stats["mag"])
	var prev_def = opponent_stats["def"]
	opponent_stats["def"] = max(0, opponent_stats["def"] - dmg)
	
	if (self_stats == battle.current_player_stats):
		battle.animation_player.play("magic_attack")
		await(battle.animation_player.animation_finished)
		
		battle.display_text("The enemy's defense is lowered!" if prev_def 
				else "The attack didn't do anything!")
		await(battle.textbox_closed)
	else:
		battle.display_text("Your defense is lowered!" if prev_def 
				else "The attack didn't do anything!")
		await(battle.textbox_closed)
	
	completed_use.emit()
	return 1


func get_description():
	return "Lowers the enemy's defense."
