extends "res://scripts/magic_attacks/base_stat_affector.gd"


func use(opponent_stats=null, self_stats=null, battle=null):
	if (battle):
		self_stats["hp"] = min(self_stats["max_hp"], self_stats["hp"] + 0.25 * self_stats["max_hp"])
		battle.update_all_progress_bars()
		
		battle.inventory.hide()
	
		battle.display_text("You take the potion and heal some HP!")
		await (battle.textbox_closed)
		
	else:
		PlayerStats.current_health = min(PlayerStats.max_health,\
									PlayerStats.current_health + 0.25 * PlayerStats.max_health)
	
	
	completed_use.emit()
