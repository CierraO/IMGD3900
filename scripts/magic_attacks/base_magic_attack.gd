extends Node


signal completed_attack

# The function to perform when the magic attack is used
# Should change any stats the attack affects, including HP
func use(opponent_stats=null, self_stats=null, battle=null):
	printerr("No effect was specified for this attack.")
