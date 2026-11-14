extends Node3D


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		rotation_degrees.y += 15
	elif event.is_action_pressed("ui_right"):
		rotation_degrees.y -= 15
	if event.is_action_pressed("ui_up"):
		position += basis * Vector3.FORWARD
	if event.is_action_pressed("ui_down"):
		position += basis * Vector3.BACK
