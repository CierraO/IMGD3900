extends Control

signal battle_finished
signal textbox_closed

@export var enemy: Resource

@onready var actions: HBoxContainer = $ActionsPanel/MarginContainer/Actions
@onready var spells: HBoxContainer = $ActionsPanel/MarginContainer/Spells
@onready var spell_item_list: ItemList = %SpellItemList
@onready var spell_textbox: RichTextLabel = %SpellTextbox
@onready var inventory: HBoxContainer = $ActionsPanel/MarginContainer/Inventory
@onready var inv_item_list: ItemList = %InvItemList
@onready var inv_textbox: RichTextLabel = %InvTextbox
@onready var enemy_health_bar = $EnemyCenterContainer/EnemyContainer/HealthBar
@onready var player_health_bar = $MarginContainer/PlayerInfo/VBoxContainer/HealthBar
@onready var player_mana_bar = $MarginContainer/PlayerInfo/ManaBar
@onready var attack = $ActionsPanel/MarginContainer/Actions/MarginContainer/HBoxContainer/Attack
@onready var animation_player = $AnimationPlayer

## Player and enemy stats.
## For the battle, base stats include equipment buffs but not potion buffs.
var current_player_stats = {
		"hp": 0, "max_hp": 0, "mana": 10,
		"base_atk": 0, "atk": 0,
		"base_mag": 0, "mag": 0,
		"base_def": 0, "def": 0,
		"next_dmg_taken_modifier": 1,  # proportion of total calculated dmg to take
		"passive_dmg_taken": 0,  # amount of damage to take every turn
		}
var current_enemy_stats = {
		"hp": 0, "max_hp": 0,
		"base_atk": 0, "atk": 0,
		"base_mag": 0, "mag": 0,
		"base_def": 0, "def": 0,
		"next_dmg_taken_modifier": 1,  # proportion of total calculated dmg to take
		"passive_dmg_taken": 0,  # amount of damage to take every turn
		}

var tween: Tween


# Called when the node enters the scene tree for the first time.
func _ready():
	# Set up textures and health bars
	%Enemy.texture = enemy.texture
	update_player_progress_bar(PlayerState.player_stats["hp"], false)
	update_progress_bar(player_mana_bar, "Mana", 10, 10, false)
	update_enemy_progress_bar(enemy.health, false)
	update_spells()
	update_inventory()
	inv_item_list.get_v_scroll_bar().hide()
	inv_item_list.get_v_scroll_bar().visibility_changed.connect(_hide_scroll_bar)
	
	# Set up stats
	current_player_stats["hp"] = PlayerState.player_stats["hp"]
	current_player_stats["max_hp"] = PlayerState.player_stats["max_hp"]
	current_player_stats["base_atk"] = PlayerState.player_stats["atk"]
	current_player_stats["atk"] = PlayerState.player_stats["atk"]
	current_player_stats["base_mag"] = PlayerState.player_stats["mag"]
	current_player_stats["mag"] = PlayerState.player_stats["mag"]
	current_player_stats["base_def"] = PlayerState.player_stats["def"]
	current_player_stats["def"] = PlayerState.player_stats["def"]
	
	current_enemy_stats["hp"] = enemy.health
	current_enemy_stats["max_hp"] = enemy.health
	current_enemy_stats["base_atk"] = enemy.atk
	current_enemy_stats["atk"] = enemy.atk
	current_enemy_stats["base_mag"] = enemy.mag
	current_enemy_stats["mag"] = enemy.mag
	current_enemy_stats["base_def"] = enemy.def
	current_enemy_stats["def"] = enemy.def
	
	%Textbox.hide()
	actions.hide()
	spells.hide()
	inventory.hide()
	
#	# Display encounter text, then show battle menu
	display_text(enemy.encounter_text)
	await(textbox_closed)
	actions.show()
	attack.grab_focus()


# Displays text in the panel
func display_text(text):
	actions.hide()
	%Textbox.show()
	%Textbox.text = text
	
	%Textbox.visible_ratio = 0.0
	tween = create_tween().bind_node(%Textbox)
	tween.tween_property(%Textbox, "visible_ratio", 1.0, text.length() * 0.03)


# Updates the progress bar's value, max value, and label (if a label exists)
# progress_bar: the progress bar node to be updated
# health: the current HP
# max_health: the maximum HP
func update_progress_bar(progress_bar, label, health, max_health, to_tween=true):
	progress_bar.max_value = max_health
	var t_tween = create_tween().bind_node(progress_bar)
	if to_tween:
		t_tween.tween_property(progress_bar, "value", health, 0.5)
	else:
		progress_bar.value = health
	if label:
		progress_bar.get_node("Label").text = "%s: %d/%d" % [label, health, max_health]


# Updates the player's progress bar's value, max value, and label; health is the player's current HP
func update_player_progress_bar(health=current_player_stats["hp"], to_tween=true):
	update_progress_bar(player_health_bar, "HP", \
			health, PlayerState.player_stats["max_hp"], to_tween)


# Updates the enemy's progress bar's value and max value; health is the enemy's current HP
func update_enemy_progress_bar(health=current_enemy_stats["hp"], to_tween=true):
	update_progress_bar(enemy_health_bar, false, health, enemy.health, to_tween)


# Update both the player's and enemy's health bars
func update_all_progress_bars(player_hp=current_player_stats["hp"], enemy_hp=current_enemy_stats["hp"]):
	update_player_progress_bar(player_hp)
	update_enemy_progress_bar(enemy_hp)
	update_progress_bar(player_mana_bar, "Mana", current_player_stats["mana"], 10)


func enemy_turn():	
	var move = pick_enemy_move()
	
	# Normal attack
	if (move < 0):
		await enemy_attack()
	# Magic attack
	else:
		var m_atk = enemy.magic_attacks[move].new()
		current_player_stats["next_dmg_taken_modifier"] = await m_atk.call("use", current_player_stats, current_enemy_stats, self)
		m_atk.queue_free()
	
	current_player_stats["mana"] = min(10, current_player_stats["mana"] + 1)
	update_progress_bar(player_mana_bar, "Mana", current_player_stats["mana"], 10, false)
	
	await apply_passive_damage()
	actions.show()
	attack.grab_focus()


# Normal non-magic attack
func enemy_attack():
	display_text("%s attacks you." % enemy.name)
	await(textbox_closed)
	
	var dmg = (max(0, current_enemy_stats["atk"] - current_player_stats["def"]) + (randi() % 3)) * current_player_stats["next_dmg_taken_modifier"]
	
	if dmg > 0:
		current_player_stats["hp"] = max(0, current_player_stats["hp"] - dmg)
		update_player_progress_bar(current_player_stats["hp"])
		
		animation_player.play("player_dmg")
		await(animation_player.animation_finished)
		display_text("%s deals %d damage." % [enemy.name, dmg])
		await(textbox_closed)
		
		check_if_player_died()
	else:
		display_text("%s's attack whiffed." % enemy.name)
		await(textbox_closed)


func pick_enemy_move():
	return randi_range(-1, enemy.magic_attacks.size() - 1)


func _input(event):
	if ((Input.is_action_just_released("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) \
		and %Textbox.visible):
			if %Textbox.visible_ratio < 1:
				tween.kill()
				%Textbox.visible_ratio = 1
			else:
				%Textbox.hide()
				textbox_closed.emit()


func _on_run_pressed():
	display_text("You run away.")
	await(textbox_closed)
	leave_battle()


func _on_attack_pressed():
	display_text("You attack.")
	await(textbox_closed)
	
	var dmg = max(0, current_player_stats["atk"] - current_enemy_stats["def"]) + (randi() % 3)
	
	if dmg > 0:
		current_enemy_stats["hp"] = max(0, current_enemy_stats["hp"] - dmg)
		update_enemy_progress_bar(current_enemy_stats["hp"])
		
		animation_player.play("melee_attack")
		await(animation_player.animation_finished)
		animation_player.play("enemy_damaged")
		display_text("%s takes %d damage." % [enemy.name, dmg])
		await(textbox_closed)
		
		await check_if_enemy_died()
	else:
		display_text("Your attack whiffed.")
		await(textbox_closed)
	
	enemy_turn()


func check_if_enemy_died():
	if current_enemy_stats["hp"] == 0:
		display_text("%s has been defeated!" % enemy.name)
		await (textbox_closed)
		animation_player.play("enemy_died")
		await(animation_player.animation_finished)
		
		# Enemy drops
		var drop = randi_range(-1, Inventory.ITEMS.size() - 1)
		if drop != -1:
			display_text("%s dropped %s!" % [enemy.name, Inventory.ITEM_MAPPINGS[drop]["name"]])
			await(textbox_closed)
			Inventory.add_inventory_item(drop)
		leave_battle()


func check_if_player_died():
	if current_player_stats["hp"] == 0:
		animation_player.play("defeat")
		await(animation_player.animation_finished)
		display_text("You have been defeated.")
		await (textbox_closed)
		SceneManager.change_scene(SceneManager.GAME_OVER)


func leave_battle():
	PlayerState.player_stats["hp"] = current_player_stats["hp"]
	battle_finished.emit()
	queue_free()


# Set the enemy resource
func set_enemy(e):
	enemy = e


func apply_passive_damage():
	if current_enemy_stats["passive_dmg_taken"] > 0:
		current_enemy_stats["hp"] = max(0, current_enemy_stats["hp"] - current_enemy_stats["passive_dmg_taken"])
		update_all_progress_bars()
		animation_player.play("enemy_damaged")
		display_text("%s takes poison damage!" % [enemy.name])
		await(textbox_closed)
	
	if current_player_stats["passive_dmg_taken"] > 0:
		current_player_stats["hp"] = max(0, current_player_stats["hp"] - current_player_stats["passive_dmg_taken"])
		update_all_progress_bars()
		animation_player.play("player_dmg")
		await(animation_player.animation_finished)
		display_text("You take poison damage!")
		await(textbox_closed)


func _on_magic_pressed() -> void:
	actions.hide()
	spells.show()
	spell_item_list.grab_focus()


func _on_spell_item_list_item_activated(index: int) -> void:
	await get_tree().create_timer(0.1).timeout
	actions.hide()
	spells.hide()
	inv_textbox.text = ""
	
	var spell_dict = PlayerState.MAGIC_ATTACK_MAPPINGS[PlayerState.magic_attacks_collected[index]]
	var mana_cost = spell_dict["mana_cost"]
	if (current_player_stats["mana"] >= mana_cost):
		current_player_stats["mana"] -= mana_cost
		update_progress_bar(player_mana_bar, "Mana", current_player_stats["mana"], 10)
		var m_atk = spell_dict["script"].new()
		current_enemy_stats["next_dmg_taken_modifier"] = await m_atk.call("use", current_enemy_stats, current_player_stats, self)
		m_atk.queue_free()
		enemy_turn()
	else:
		display_text("You don't have enough mana!")
		await(textbox_closed)
		actions.show()
		attack.grab_focus()


func _on_inventory_pressed() -> void:
	actions.hide()
	inventory.show()
	inv_item_list.grab_focus()


# Leave the inventory menu
func _on_back_pressed() -> void:
	spell_textbox.text = ""
	inv_textbox.text = ""
	spells.hide()
	inventory.hide()
	actions.show()
	attack.grab_focus()


func _on_inv_item_list_item_activated(index: int) -> void:
	await get_tree().create_timer(0.1).timeout
	inventory.hide()
	
	var m_item = Inventory.ITEM_MAPPINGS[Inventory._inventory[index]]["script"].new()
	m_item.call("use", current_enemy_stats, current_player_stats, self)
	await(m_item.completed_use)
	m_item.queue_free()
	Inventory.remove_inventory_item_at_index(index)
	inv_item_list.remove_item(index)
	
	update_player_progress_bar()
	
	enemy_turn()


func update_spells():
	spell_item_list.clear()
	for spell in PlayerState.magic_attacks_collected:
		spell_item_list.add_item(PlayerState.MAGIC_ATTACK_MAPPINGS[spell]["name"])


func update_inventory():
	inv_item_list.clear()
	for item in Inventory._inventory:
		inv_item_list.add_item(Inventory.ITEM_MAPPINGS[item]["name"],
				Inventory.ITEM_MAPPINGS[item]["icon"])


func _on_inv_item_list_item_selected(index: int) -> void:
	inv_textbox.text = Inventory.ITEM_MAPPINGS[Inventory._inventory[index]]["desc"]


func _on_item_list_focus_exited(item_list_path, textbox_path) -> void:
	var item_list = get_node(item_list_path)
	var textbox = get_node(textbox_path)
	item_list.deselect_all()
	textbox.text = ""


func _on_item_list_focus_entered(item_list_path) -> void:
	var item_list = get_node(item_list_path)
	if (item_list.get_item_count() > 0):
		item_list.select(0)
		item_list.item_selected.emit(0)
		item_list.ensure_current_is_visible()


# For some reason, even after hiding, the scrollbar shows itself again.
func _hide_scroll_bar() -> void:
	inv_item_list.get_v_scroll_bar().hide()


func _on_spell_item_list_item_selected(index: int) -> void:
	var spell_dict = PlayerState.MAGIC_ATTACK_MAPPINGS[PlayerState.magic_attacks_collected[index]]
	var m_atk = spell_dict["script"].new()
	var desc = m_atk.call("get_description") + " Mana: %d." % spell_dict["mana_cost"]
	spell_textbox.text = desc
	m_atk.queue_free()
