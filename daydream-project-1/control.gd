extends Control


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Main.tscn") # Replace with function body.

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://credits.tscn")

func _on_button_3_pressed() -> void:
	get_tree().quit() # Replace with function body.
