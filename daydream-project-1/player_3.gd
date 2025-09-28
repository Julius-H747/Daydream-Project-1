extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if velocity.y == 0:
		if velocity.x != 0:
			$AnimatedSprite2D.animation = "walk"
		# See the note below about the following boolean assignment.
			$AnimatedSprite2D.flip_h = velocity.x < 0
			$AnimatedSprite2D.play()
		else:
			$AnimatedSprite2D.animation = "idle"
	else:
		$AnimatedSprite2D.animation = "jump"
		if not "-" in str(velocity.y):
			$AnimatedSprite2D.animation = "fall"
	move_and_slide()


func _on_soul_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
