extends "res://scripts/magic_attacks/base_magic_attack.gd"


func use(opponent_stats=null, self_stats=null, battle=null):
	battle.display_text("You cast a basic spell." if (self_stats == battle.current_player_stats) else "%s casts a basic spell." % battle.enemy.name)
	await(battle.textbox_closed)
	
	opponent_stats["def"] = max(0, opponent_stats["def"] - self_stats["mag"])
	
	if (self_stats == battle.current_player_stats):
		battle.animation_player.play("magic_attack")
		await(battle.animation_player.animation_finished)
		battle.display_text("The enemy's defense is lowered!")
		await(battle.textbox_closed)
	else:
		battle.display_text("Your defense is lowered!")
		await(battle.textbox_closed)
	
	completed_attack.emit()
