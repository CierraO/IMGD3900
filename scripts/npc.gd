extends Area2D
## An actionable that triggers dialogue when it is interacted with.

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"


func action() -> void:
	if PlayerState.state == PlayerState.State.MOVING:
		PlayerState.state = PlayerState.State.IN_MENU
		DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start)
		await DialogueManager.dialogue_ended
		PlayerState.state = PlayerState.State.MOVING
