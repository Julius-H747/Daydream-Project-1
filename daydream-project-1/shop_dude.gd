extends RigidBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D # Assuming AnimatedSprite2D is a child

func _physics_process(delta: float) -> void:
	animated_sprite.play("idle")
