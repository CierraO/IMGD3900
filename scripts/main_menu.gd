extends CanvasLayer


@onready var start_game: Button = $CenterContainer/VBoxContainer/StartGame
@onready var quit: Button = $CenterContainer/VBoxContainer/Quit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	start_game.grab_focus()
	AudioPlayer.play()


func _on_start_game_pressed() -> void:
	SceneManager.change_scene(SceneManager.TEST_LEVEL)


func _on_quit_pressed() -> void:
	get_tree().quit()
