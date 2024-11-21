extends "res://scripts/magic_attacks/base_stat_affector.gd"


func use(opponent_stats=null, self_stats=null, battle=null):
	if (battle):
		self_stats["hp"] = min(self_stats["max_hp"], self_stats["hp"] + 0.25 * self_stats["max_hp"])
		battle.update_all_progress_bars()
		
		battle.inventory.hide()
	
		battle.display_text("You take the potion and heal some HP!")
		await (battle.textbox_closed)
		
	else:
		PlayerStats.player_stats["hp"] = min(PlayerStats.player_stats["max_hp"],
				PlayerStats.player_stats["hp"] + 0.5 * PlayerStats.player_stats["max_hp"])
		
	completed_use.emit()
