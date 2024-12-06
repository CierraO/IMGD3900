extends "res://scripts/magic_attacks/base_stat_affector.gd"


func use(opponent_stats=null, self_stats=null, battle=null):
	battle.display_text("You attack." if (self_stats == battle.current_player_stats) else "%s attacks you spell." % battle.enemy.name)
	await(battle.textbox_closed)
	
	var dmg = max(0, self_stats["atk"] - opponent_stats["def"]) + (randi() % 2)
	dmg = dmg * opponent_stats["next_dmg_taken_modifier"] * 0.5
	var prev_def = opponent_stats["def"]
	opponent_stats["def"] = max(0, opponent_stats["def"] - dmg)
	
	if (self_stats == battle.current_player_stats):
		battle.animation_player.play("melee_attack")
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
