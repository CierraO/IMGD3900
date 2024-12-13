extends "res://scripts/magic_attacks/base_stat_affector.gd"


func use(opponent_stats=null, self_stats=null, battle=null):
	if (battle):
		self_stats["def"] = self_stats["def"] + 0.5 * self_stats["base_def"]
		
		battle.inventory.hide()
	
		battle.display_text("You take the potion and increase your defense!")
		await (battle.textbox_closed)
	
	completed_use.emit()
	return battle != null
