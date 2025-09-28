extends TileMapLayer

func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	get_tree().change_scene_to_file("res://boss_room.tscn")
