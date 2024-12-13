extends Window

@onready var input = %Input
@onready var output = %Output

var history = []
var index = -1
var methods = []


# Called when the node enters the scene tree for the first time.
func _ready():
	methods = get_script().get_script_method_list().map(func (x): return x.name)
	methods = methods.filter(func (x): return not x.begins_with("_"))


# Called during the processing step of the main loop.
func _process(delta):
	if Input.is_action_just_pressed("dev_console_toggle"):
		_toggle()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	_on_history(event)
	_on_autocomplete(event)
	_run_command(event)


# Toggle the dev console.
func _toggle():
	if not PlayerState.state == PlayerState.State.MOVING and !visible:
		return
	
	input.text = ""
	visible = !visible
	PlayerState.state = PlayerState.State.IN_MENU if visible else PlayerState.State.MOVING
	if visible:
		input.grab_focus()


# Handle autocompletion of method names.
func _on_autocomplete(event):
	if event.is_action_released("ui_text_completion_replace"):
		for method in methods:
			if method.begins_with(input.text):
				input.text = method
				input.caret_column = input.text.length()
				break


# Cycle through the previous commands on up or down arrow presses.
func _on_history(event):
	if event.is_action_released("text_ui_up") and history:
		index = clamp(index + 1, 0, history.size() - 1)
		input.text = history[history.size() - (index + 1)]
		input.caret_column = input.text.length()
	elif event.is_action_released("text_ui_down") and history:
		if index != -1:
			index = clamp(index - 1, 0, history.size() - 1)
			input.text = history[history.size() - (index + 1)]
			input.caret_column = input.text.length()


# Evaluate and, if it is parseable, execute the inputted expression.
func _run_command(event):
	if event.is_action_released("ui_text_completion_accept"):
		index = -1
		var expression = Expression.new()
		
		if input.text:
			history.append(input.text)
			output.text += "> " + input.text + "\n"
		
		var error = expression.parse(input.text)
		if error != OK:
			output.text += expression.get_error_text() + "\n"
			
		var result = expression.execute([], self)
		if expression.has_execute_failed():
			output.text += expression.get_error_text() + "\n"
		elif result:
			output.text += str(result) + "\n"
		
		input.text = ""
		output.scroll_vertical = output.get_line_count() - 1


# Display a list of commands
func help():
	return "COMMANDS:\n" + "\n".join(methods)


func collect_attack(attack):
	if PlayerState.Attacks.values().has(attack) and not PlayerState.attacks_collected.has(attack):
		PlayerState.attacks_collected.append(attack)
		return "Collected %s." % PlayerState.Attacks.find_key(attack)
	elif not PlayerState.Attacks.values().has(attack):
		return "ERROR: Attack does not exist."
	else:
		return "ERROR: You already have that attack!"


func collect_all_attacks():
	for atk in PlayerState.Attacks.values():
		if not PlayerState.attacks_collected.has(atk):
			PlayerState.attacks_collected.append(atk)


func reset_attacks():
	PlayerState.attacks_collected = [PlayerState.Attacks.BASIC_MAGIC_ATK, PlayerState.Attacks.PARRY, PlayerState.Attacks.RECKLESS_ATK]


func collect_spell(attack):
	if PlayerState.MagicAttacks.values().has(attack) and not PlayerState.magic_attacks_collected.has(attack):
		PlayerState.magic_attacks_collected.append(attack)
		return "Collected %s." % PlayerState.MagicAttacks.find_key(attack)
	elif not PlayerState.MagicAttacks.values().has(attack):
		return "ERROR: Attack does not exist."
	else:
		return "ERROR: You already have that attack!"


func collect_all_spells():
	for atk in PlayerState.MagicAttacks.values():
		if not PlayerState.magic_attacks_collected.has(atk):
			PlayerState.magic_attacks_collected.append(atk)


func reset_spells():
	PlayerState.magic_attacks_collected = [PlayerState.MagicAttacks.BASIC_MAGIC_ATK, PlayerState.MagicAttacks.TOXIC_CLOUD, PlayerState.MagicAttacks.BARRIER]


func collect_equipment(type, variation):
	if type < 0 or type >= Inventory.equipment_types.size():
		return "ERROR: Invalid equipment type."
	
	Inventory.collected_equipment.emit()
	
	match type:
		0:
			if Inventory.weapons_collected.has(variation):
				return "ERROR: You already have that weapon!"
			elif not Inventory.WEAPONS.values().has(variation):
				return "ERROR: Invalid weapon type!"
			Inventory.weapons_collected.append(variation)
			return "Collected %s." % Inventory.WEAPONS.find_key(variation)
		1:
			if Inventory.helmets_collected.has(variation):
				return "ERROR: You already have that helmet!"
			elif not Inventory.HELMETS.values().has(variation):
				return "ERROR: Invalid helmet type!"
			Inventory.helmets_collected.append(variation)
			return "Collected %s." % Inventory.HELMETS.find_key(variation)
		2:
			if Inventory.chestpieces_collected.has(variation):
				return "ERROR: You already have that chestpiece!"
			elif not Inventory.CHESTPIECES.values().has(variation):
				return "ERROR: Invalid chestpiece type!"
			Inventory.chestpieces_collected.append(variation)
			return "Collected %s." % Inventory.CHESTPIECES.find_key(variation)
		3:
			if Inventory.boots_collected.has(variation):
				return "ERROR: You already have that pair of boots!"
			elif not Inventory.BOOTS.values().has(variation):
				return "ERROR: Invalid boots type!"
			Inventory.boots_collected.append(variation)
			return "Collected %s." % Inventory.BOOTS.find_key(variation)


func collect_all_equipment():
	Inventory.weapons_collected = [0, 1, 2]
	Inventory.helmets_collected = [0, 1, 2]
	Inventory.chestpieces_collected = [0, 1, 2]
	Inventory.boots_collected = [0, 1, 2]
	Inventory.collected_equipment.emit()


func clear_equipment():
	Inventory.weapons_collected .clear()
	Inventory.helmets_collected.clear()
	Inventory.chestpieces_collected.clear()
	Inventory.boots_collected.clear()


func collect_item(item):
	if Inventory.ITEMS.values().has(item):
		Inventory.add_inventory_item(item)
		return "Collected %s." % Inventory.ITEMS.find_key(item)
	else:
		return "ERROR: Invalid item."


func clear_inventory():
	Inventory._inventory.clear()


func get_states():
	return PlayerState.get_states()


func change_state(var_name: String, val):
	PlayerState.set(var_name, val)


func _on_close_requested():
	_toggle()
