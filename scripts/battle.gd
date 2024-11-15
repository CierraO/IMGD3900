extends Control

signal battle_finished
signal textbox_closed

@export var enemy: Resource

@onready var actions = $ActionsPanel/MarginContainer/Actions
@onready var spells = $ActionsPanel/MarginContainer/Spells
@onready var equipment = $ActionsPanel/MarginContainer/Equipment
@onready var inventory: HBoxContainer = $ActionsPanel/MarginContainer/Inventory
@onready var inv_item_list: ItemList = $ActionsPanel/MarginContainer/Inventory/ItemList
@onready var enemy_health_bar = $EnemyContainer/HealthBar
@onready var player_health_bar = $ActionsPanel/MarginContainer/Actions/PlayerInfo/HealthBar
@onready var attack = $ActionsPanel/MarginContainer/Actions/HBoxContainer/Attack
@onready var eq_back = $ActionsPanel/MarginContainer/Equipment/Back
@onready var animation_player = $AnimationPlayer

var current_player_stats = {"hp": 0, "atk": 0, "mag":0, "def": 0}
var current_enemy_stats = {"hp": 0, "atk": 0, "mag":0, "def": 0}

var tween: Tween


# Called when the node enters the scene tree for the first time.
func _ready():
	# Set up textures and health bars
	%Enemy.texture = enemy.texture
	update_player_progress_bar(PlayerStats.current_health)
	update_enemy_progress_bar(enemy.health)
	
	current_player_stats["hp"] = PlayerStats.current_health
	current_player_stats["atk"] = PlayerStats.atk
	current_player_stats["mag"] = PlayerStats.mag
	current_player_stats["def"] = PlayerStats.def
	
	current_enemy_stats["hp"] = enemy.health
	current_enemy_stats["atk"] = enemy.atk
	current_enemy_stats["mag"] = enemy.mag
	current_enemy_stats["def"] = enemy.def
	
	%Textbox.hide()
	actions.hide()
	spells.hide()
	equipment.hide()
	inventory.hide()
	
	# Add spells
	var theme = load("res://resources/theme.tres")
	for spell in PlayerStats.magic_attacks.keys():
		var button = Button.new()
		button.text = spell
		button.theme = theme
		button.pressed.connect(use_magic_attack.bind(spell))
		
		if spells.get_child_count() > 0:
			spells.add_spacer(false)
		spells.add_child(button)
	
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
func update_progress_bar(progress_bar, has_label, health, max_health):
	progress_bar.max_value = max_health
	progress_bar.value = health
	if has_label:
		progress_bar.get_node("Label").text = "HP: %d/%d" % [health, max_health]


# Updates the player's progress bar's value, max value, and label; health is the player's current HP
func update_player_progress_bar(health=current_player_stats["hp"]):
	update_progress_bar(player_health_bar, true, \
		health, PlayerStats.max_health)


# Updates the enemy's progress bar's value and max value; health is the enemy's current HP
func update_enemy_progress_bar(health=current_enemy_stats["hp"]):
	update_progress_bar(enemy_health_bar, false, health, enemy.health)


# Update both the player's and enemy's health bars
func update_all_progress_bars(player_hp=current_player_stats["hp"], enemy_hp=current_enemy_stats["hp"]):
	update_player_progress_bar(player_hp)
	update_enemy_progress_bar(enemy_hp)


func enemy_turn():
	var move = pick_enemy_move()
	
	# Normal attack
	if (move < 0):
		await enemy_attack()
	# Magic attack
	else:
		var m_atk = enemy.magic_attacks[move].new()
		m_atk.call("use", current_player_stats, current_enemy_stats, self)
		await(m_atk.completed_attack)
		m_atk.queue_free()
	actions.show()
	attack.grab_focus()


# Normal non-magic attack
func enemy_attack():
	display_text("%s attacks you." % enemy.name)
	await(textbox_closed)
	
	var dmg = max(0, current_enemy_stats["atk"] - current_player_stats["def"]) + (randi() % 3)
	
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
		leave_battle()


func check_if_player_died():
	if current_player_stats["hp"] == 0:
		animation_player.play("defeat")
		await(animation_player.animation_finished)
		display_text("You have been defeated.")
		await (textbox_closed)
		SceneManager.change_scene(SceneManager.GAME_OVER)


func leave_battle():
	PlayerStats.current_health = current_player_stats["hp"]
	battle_finished.emit()
	queue_free()


# Set the enemy resource
func set_enemy(e):
	enemy = e


func _on_magic_pressed() -> void:
	actions.hide()
	spells.show()
	
	if spells.get_child_count() > 0:
		spells.get_child(0).grab_focus()


func use_magic_attack(attack_name):
	actions.hide()
	spells.hide()
	var m_atk = PlayerStats.magic_attacks[attack_name].new()
	m_atk.call("use", current_enemy_stats, current_player_stats, self)
	await(m_atk.completed_attack)
	m_atk.queue_free()
	enemy_turn()


func _on_equipment_pressed() -> void:
	actions.hide()
	inventory.show()
	inv_item_list.grab_focus()
	inv_item_list.select(0)
	#equipment.show()
	#eq_back.grab_focus()


# Leave the equipment/inventory menu
func _on_back_pressed() -> void:
	equipment.hide()
	inventory.hide()
	actions.show()
	attack.grab_focus()


func _on_item_list_item_activated(index: int) -> void:
	if inv_item_list.get_item_text(index) == "Health Potion":
		current_player_stats["hp"] = min(PlayerStats.max_health,\
									current_player_stats["hp"] + 0.25 * PlayerStats.max_health)
	elif inv_item_list.get_item_text(index) == "Greater Health Potion":
		current_player_stats["hp"] = min(PlayerStats.max_health,\
									current_player_stats["hp"] + 0.5 * PlayerStats.max_health)
	
	update_player_progress_bar()
	
	inventory.hide()
	
	display_text("You take the potion and heal some HP!")
	await (textbox_closed)
	
	enemy_turn()
