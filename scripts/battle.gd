extends Control

signal battle_finished
signal textbox_closed

@export var enemy: Resource

@onready var actions = $ActionsPanel/MarginContainer/Actions
@onready var enemy_health_bar = $EnemyContainer/HealthBar
@onready var player_health_bar = $ActionsPanel/MarginContainer/Actions/PlayerInfo/HealthBar
@onready var attack = $ActionsPanel/MarginContainer/Actions/Attack
@onready var animation_player = $AnimationPlayer

var current_player_health = 0
var current_enemy_health = 0

var tween: Tween


# Called when the node enters the scene tree for the first time.
func _ready():
	# Set up textures and health bars
	%Enemy.texture = enemy.texture
	update_player_progress_bar(PlayerStats.current_health)
	update_enemy_progress_bar(enemy.health)
	
	current_player_health = PlayerStats.current_health
	current_enemy_health = enemy.health
	
	%Textbox.hide()
	actions.hide()
	
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
		progress_bar.get_node("Label").text = "WILLPOWER: %d/%d" % [health, max_health]
		
# Updates the player's progress bar's value, max value, and label; health is the player's current HP
func update_player_progress_bar(health):
	update_progress_bar(player_health_bar, true, \
		health, PlayerStats.max_health)

# Updates the enemy's progress bar's value and max value; health is the enemy's current HP
func update_enemy_progress_bar(health):
	update_progress_bar(enemy_health_bar, false, health, enemy.health)
	
func enemy_turn():
	display_text("%s attacks you." % enemy.name)
	await(textbox_closed)
	
	var dmg = max(0, enemy.atk - PlayerStats.def) + (randi() % 3)
	
	if dmg > 0:
		current_player_health = max(0, current_player_health - dmg)
		update_player_progress_bar(current_player_health)
		
		animation_player.play("player_dmg")
		await(animation_player.animation_finished)
		display_text("%s deals %d damage." % [enemy.name, dmg])
		await(textbox_closed)
		
		if current_player_health == 0:
			animation_player.play("defeat")
			await(animation_player.animation_finished)
			display_text("You have been defeated.")
			await (textbox_closed)
			SceneManager.change_scene(SceneManager.TEST_LEVEL)
	else:
		display_text("%s's attack whiffed." % enemy.name)
		await(textbox_closed)
		
	actions.show()
	attack.grab_focus()

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
	battle_finished.emit()

func _on_attack_pressed():
	display_text("You attack.")
	await(textbox_closed)
	
	var dmg = max(0, PlayerStats.atk - enemy.def) + (randi() % 3)
	
	if dmg > 0:
		current_enemy_health = max(0, current_enemy_health - dmg)
		update_enemy_progress_bar(current_enemy_health)
		
		animation_player.play("enemy_damaged")
		await(animation_player.animation_finished)
		display_text("%s takes %d damage." % [enemy.name, dmg])
		await(textbox_closed)
		
		if current_enemy_health == 0:
			display_text("%s has been defeated!" % enemy.name)
			await (textbox_closed)
			animation_player.play("enemy_died")
			await(animation_player.animation_finished)
			PlayerStats.current_health = current_player_health
			battle_finished.emit()
	else:
		display_text("Your attack whiffed.")
		await(textbox_closed)
	
	enemy_turn()

# Set the enemy resource
func set_enemy(e):
	enemy = e
