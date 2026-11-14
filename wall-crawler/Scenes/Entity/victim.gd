extends CharacterBody3D

"""Our victims of the hour.

* Should they wander?
* Should they give odd benifits, like seeing through walls, or forcefully splitting us?
"""

const lethal_velocity = 100

#ADD ANY EATING SHENANIGANS NOW.
func eaten():
	queue_free()

#Death, for when they fall to thier doom, and we want gore and viscera. Does nothing for now.
var dead = false
func die():
	dead = true


var velocity_last_frame : Vector3
func _physics_process(delta: float) -> void:
	velocity += 10 * Vector3.DOWN * delta
	
	if (velocity_last_frame - velocity).length() > lethal_velocity and not dead:
		die()
	
	velocity_last_frame = velocity
