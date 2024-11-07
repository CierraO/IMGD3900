extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(3.0).timeout
	SceneManager.change_scene(SceneManager.MAIN_MENU)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		SceneManager.change_scene(SceneManager.MAIN_MENU)
