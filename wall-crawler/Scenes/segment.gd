extends StaticBody3D

const STEP_SIZE : float = 2.0 
var dir : Vector3 = Vector3.FORWARD

@onready var shapecast: ShapeCast3D = $Shapecast

func update_shapecast(): 
	shapecast.position = dir * STEP_SIZE
