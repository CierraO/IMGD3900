extends CanvasLayer

@onready var label: Label = $MarginContainer/VBoxContainer/Label

var started_game = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and not started_game:
		get_viewport().set_input_as_handled()
		label.hide()
		hide()
		started_game = true
	if event.is_action_pressed("ui_cancel") and started_game and not PlayerState.state == PlayerState.State.BATTLING:
		visible = not visible
		if visible:
			PlayerState.state = PlayerState.State.IN_MENU
		else:
			PlayerState.state = PlayerState.State.MOVING
