extends Area2D


@export var enemy: Resource = preload("res://resources/skull.tres")
@export var respawns: bool = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	# Prevent player from receiving movement input during battle
	body.set_state(1)
	
	# Encounter animation
	animation_player.play("encounter")
	await(animation_player.animation_finished)
	
	# Prepare a battle node and add it to the scene
	var battle: Node = load("res://scenes/battle.tscn").instantiate()
	battle.set_enemy(enemy)
	get_tree().current_scene.get_node("CanvasLayer").add_child(battle)
	
	# When the battle is over, destroy it and return movement controls to the player
	await(battle.battle_finished)
	battle.queue_free()
	body.set_state(0)
	
	remove_from_scene()

func remove_from_scene():
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)
	await (tween.finished)
	
	if respawns:
		$CollisionShape2D.disabled = true
		await (get_tree().create_timer(3).timeout)
		
		tween = create_tween()
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)
		await (tween.finished)
		$CollisionShape2D.disabled = false
	else:
		queue_free()
