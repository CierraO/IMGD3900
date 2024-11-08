extends "res://scripts/magic_attacks/base_magic_attack.gd"


func use(battle):
	battle.display_text("You cast a basic spell.")
	await(battle.textbox_closed)
	
	battle.current_enemy_health = max(0, battle.current_enemy_health - PlayerStats.mag)
	battle.update_enemy_progress_bar(battle.current_enemy_health)
	
	battle.animation_player.play("magic_attack")
	await(battle.animation_player.animation_finished)
	battle.animation_player.play("enemy_damaged")
	battle.display_text("%s takes %d damage." % [battle.enemy.name, PlayerStats.mag])
	await(battle.textbox_closed)
	
	await battle.check_if_enemy_died()
	completed_attack.emit()
