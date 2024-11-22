extends "res://scripts/magic_attacks/base_stat_affector.gd"


func use(opponent_stats=null, self_stats=null, battle=null):
	if (battle):
		self_stats["def"] = self_stats["def"] + self_stats["base_def"]
		
		battle.inventory.hide()
	
		battle.display_text("You eat the stale bread and increase your defense!")
		await (battle.textbox_closed)
	
	completed_use.emit()