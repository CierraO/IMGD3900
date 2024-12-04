extends CharacterBody2D


@onready var actionable_finder = $ActionableFinder
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D

const SPEED = 100.0

var direction = "down"

func _physics_process(delta):
	# Handle movement
	if (PlayerState.state == PlayerState.State.MOVING):
		var x_direction = Input.get_axis("ui_left", "ui_right")
		if x_direction:
			velocity.x = x_direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		var y_direction = Input.get_axis("ui_up", "ui_down")
		if y_direction:
			velocity.y = y_direction * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)

		update_anim(x_direction, y_direction)
		move_and_slide()
	else:
		update_anim(0, 0)


func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_accept"):
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size() > 0:
			actionables[0].action()


func update_anim(x_direction, y_direction):
	if x_direction or y_direction:
		if x_direction:
			sprite_2d.flip_h = x_direction < 0
			direction = "side"
		elif y_direction:
			if y_direction > 0:
				direction = "down"
			else:
				direction = "up"
		sprite_2d.play("walk_" + direction)
	else:
		sprite_2d.play(direction)
