extends Area2D


@export var enemy: Resource = preload("res://resources/skeleton.tres")
@export var respawns: bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var level = 1
var disabled = false


# Called when the node enters the scene tree for the first time.
func _ready():
	Inventory.collected_equipment.connect(_increase_stats)
	Inventory.equipped_equipment.connect(_increase_stats)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if not disabled:
		# Prevent player from receiving movement input during battle
		PlayerState.state = PlayerState.State.BATTLING
		
		# Encounter animation
		animation_player.play("encounter")
		await(animation_player.animation_finished)
		
		# Prepare a battle node and add it to the scene
		var battle: Node = load("res://scenes/battle.tscn").instantiate()
		battle.set_enemy(enemy)
		get_tree().current_scene.get_node("CanvasLayer").add_child(battle)
		
		# When the battle is over, destroy it and return movement controls to the player
		await(battle.battle_finished)
		PlayerState.state = PlayerState.State.MOVING
		
		remove_from_scene()

func remove_from_scene():
	disabled = true
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)
	await (tween.finished)
	
	if respawns:
		await (get_tree().create_timer(3).timeout)
		if has_overlapping_bodies():
			await body_exited
		
		tween = create_tween()
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)
		await (tween.finished)
		disabled = false
	else:
		queue_free()


func _increase_stats():
	var all_collected_equipment = Inventory.get_all_collected_equipment()
	var num_equipment_types = Inventory.equipment_types.size()
	var num_equipment = Inventory.get_all_equipment().size()
	
	if ((level == 1 and PlayerState.player_stats["atk"] >= 11)
			or (level < 3 and all_collected_equipment.size() == num_equipment)):
		if enemy.level_up:
			enemy = enemy.level_up
			level += 1
