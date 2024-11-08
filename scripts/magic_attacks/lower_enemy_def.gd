extends "res://scripts/magic_attacks/base_magic_attack.gd"


func use(battle):
	battle.display_text("You cast a basic spell.")
	await(battle.textbox_closed)
	
	battle.current_enemy_def = max(0, battle.current_enemy_def - PlayerStats.mag)
	
	battle.animation_player.play("magic_attack")
	await(battle.animation_player.animation_finished)
	
	battle.display_text("The enemy's defense is lowered!")
	await(battle.textbox_closed)
	
	completed_attack.emit()
