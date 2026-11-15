extends Area3D



func _on_body_entered(body: Node3D) -> void:
	if not body is GridMap:
		get_tree().change_scene_to_file("res://Scenes/Control/end_screen.tscn")
