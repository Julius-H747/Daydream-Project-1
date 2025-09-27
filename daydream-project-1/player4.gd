extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta):
# Get input for up and down (and left/right if needed)
	if velocity.x != 0 or velocity.y != 0:
		$AnimatedSprite2D.animation = "walk"
	# See the note below about the following boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.animation = "idle"
	var direction = Input.get_vector("left", "right", "up", "down")
	if direction:
		animated_sprite_2d.scale -= Vector2(0.01, 0.01)
		velocity = direction * SPEED
		move_and_slide()
