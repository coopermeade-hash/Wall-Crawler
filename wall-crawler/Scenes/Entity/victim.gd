extends CharacterBody3D

"""Our victims of the hour.

* Should they wander?
* Should they give odd benifits, like seeing through walls, or forcefully splitting us?
"""

const lethal_velocity = 100

@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

#ADD ANY EATING SHENANIGANS NOW.
func eaten():
	mesh_instance_3d.hide()
	gpu_particles_3d.emitting = true 
	await get_tree().create_timer(gpu_particles_3d.lifetime).timeout
	queue_free()

#Death, for when they fall to thier doom, and we want gore and viscera. Does nothing for now.
var dead = false

func die():
	dead = true
