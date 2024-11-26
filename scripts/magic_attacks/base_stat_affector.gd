extends Node


signal completed_use

# The function to perform when the magic attack or item is used.
# Should change any stats the affector affects, including HP
func use(opponent_stats=null, self_stats=null, battle=null):
	printerr("No effect was specified for this attack.")


## Get a description for the UI
func get_description() -> String:
	return "No description is available."
