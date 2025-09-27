extends RigidBody2D

func _physics_process(delta):
	$AnimatedSprite2D.animation = "default"
	$AnimatedSprite2D.play()
