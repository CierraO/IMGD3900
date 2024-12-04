extends "res://scripts/magic_attacks/base_stat_affector.gd"


func use(opponent_stats=null, self_stats=null, battle=null):
	if (battle):
		self_stats["hp"] = self_stats["max_hp"]
		battle.update_all_progress_bars()
		
		battle.inventory.hide()
	
		battle.display_text("You eat the cookies and regain all HP!")
		await (battle.textbox_closed)
		
	else:
		PlayerState.player_stats["hp"] = PlayerState.player_stats["max_hp"]
		
	completed_use.emit()
