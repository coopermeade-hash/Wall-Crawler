extends Node3D

@onready var camera = $Camera3D

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("turn_left"):
		rotation_degrees.y += 15
	elif event.is_action_pressed("turn_right"):
		rotation_degrees.y -= 15
	elif event.is_action_pressed("look_up"):
		camera.rotation_degrees.x += 15
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
	elif event.is_action_pressed("look_down"):
		camera.rotation_degrees.x -= 15
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
	
	if event.is_action_pressed("move_forward"):
		position += (self.basis * Vector3.FORWARD).normalized()
	elif event.is_action_pressed("move_backward"):
		position += (self.basis * Vector3.BACK).normalized()
	
