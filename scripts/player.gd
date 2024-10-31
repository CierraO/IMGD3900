extends CharacterBody2D


@onready var actionable_finder = $ActionableFinder

const SPEED = 300.0

enum State {MOVING, BATTLING}
var state: State = State.MOVING


func _physics_process(delta):
	# Handle movement
	if (state == State.MOVING):
		var xDirection = Input.get_axis("ui_left", "ui_right")
		if xDirection:
			velocity.x = xDirection * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		var yDirection = Input.get_axis("ui_up", "ui_down")
		if yDirection:
			velocity.y = yDirection * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)

		move_and_slide()


func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_accept"):
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size() > 0:
			actionables[0].action()


func set_state(s: State):
	state = s
