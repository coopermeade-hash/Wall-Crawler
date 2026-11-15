extends StaticBody3D

const STEP_SIZE : float = 2.0 
var dir : Vector3 = Vector3.FORWARD :
	set(new_dir):
		dir = new_dir 

@onready var caterpillar_body: Node3D = $Caterpillar_Body

@onready var shapecast: ShapeCast3D = $Shapecast

func update_shapecast(): 
	shapecast.position = dir * STEP_SIZE
