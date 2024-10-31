extends Node

@onready var animation_player = $AnimationPlayer
@onready var black = $AnimationPlayer/Black

const TEST_LEVEL = "res://scenes/test_level.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	black.hide()


# Change the scene to the given file or PackedScene
func change_scene(scene):
	# Fade in
	black.show()
	animation_player.play("fade_in")
	await animation_player.animation_finished
	
	# Change the scene
	if (scene is PackedScene):
		get_tree().change_scene_to_packed(scene)
	else:
		get_tree().change_scene_to_file(scene)
	
	animation_player.play("fade_out")
	await animation_player.animation_finished
	black.hide()
		
	
