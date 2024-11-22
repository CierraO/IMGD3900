extends "res://scripts/magic_attacks/base_stat_affector.gd"


func use(opponent_stats=null, self_stats=null, battle=null):
	if (battle):
		var prev_hp = self_stats["hp"]
		self_stats["hp"] = min(self_stats["max_hp"], self_stats["hp"] + 0.25 * self_stats["max_hp"])
		battle.update_all_progress_bars()
		
		battle.inventory.hide()
	
		battle.display_text("You drink the potion and heal some HP!" if prev_hp
				else "You drink the potion, but you were already at max HP, \
				so it doesn't do anything.")
		await (battle.textbox_closed)
		
	else:
		PlayerStats.player_stats["hp"] = min(PlayerStats.player_stats["max_hp"],
				PlayerStats.player_stats["hp"] + 0.5 * PlayerStats.player_stats["max_hp"])
		
	completed_use.emit()
