extends Area2D

signal collected  # signal for when the coin is collected

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	$AnimatedSprite2D.play("default")

func _on_body_entered(body: CharacterBody2D) -> void:
	if body.name == "Player 3":  # only trigger if Player touches it
		emit_signal("collected")  
		queue_free()  # remove the coin from the scene
