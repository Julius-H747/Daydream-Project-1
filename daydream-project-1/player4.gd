extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -400.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta):
	if velocity.x != 0 or velocity.y != 0:
		$AnimatedSprite2D.animation = "walk"
	# See the note below about the following boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.animation = "idle"
	var direction = Input.get_vector("left", "right", "up", "down")
	if direction.y < 0:
		animated_sprite_2d.scale -= Vector2(0.03, 0.03)
	elif direction.y > 0:
		animated_sprite_2d.scale += Vector2(0.03, 0.03)
	animated_sprite_2d.scale.x = clamp(animated_sprite_2d.scale.x, 0.5, 2.0)
	animated_sprite_2d.scale.y = clamp(animated_sprite_2d.scale.y, 0.5, 2.0)
	velocity = direction * SPEED
	if animated_sprite_2d.scale.x <= 0.5:
		get_tree().change_scene_to_file("res://cave.tscn")
	move_and_slide()
