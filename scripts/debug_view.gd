extends CanvasLayer


@onready var rich_text_label = %RichTextLabel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("debug_toggle"):
		visible = !visible
		
	if visible and rich_text_label:
		rich_text_label.text = "[right]" + "\n".join(PlayerState.get_states()) + "[/right]"
