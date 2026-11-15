extends CharacterBody3D

"""Our victims of the hour.

* Should they wander?
* Should they give odd benifits, like seeing through walls, or forcefully splitting us?
"""

const lethal_velocity = 100

@export var sound_list : Array[AudioStream] 
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

#ADD ANY EATING SHENANIGANS NOW.
func eaten():
	mesh_instance_3d.hide()
	collision_shape_3d.disabled = true 
	gpu_particles_3d.emitting = true 
	var sound_duration = _play_death_sound()
	await get_tree().create_timer(max(gpu_particles_3d.lifetime, sound_duration)).timeout
	queue_free()

#Death, for when they fall to thier doom, and we want gore and viscera. Does nothing for now.
var dead = false

func die():
	dead = true

func _play_death_sound() -> float:
	var idx = randi_range(0, sound_list.size() - 1)
	audio_player.stream = sound_list[idx]
	audio_player.pitch_scale = randf_range(0.8, 1.2)
	audio_player.volume_db = -10.0
	audio_player.play()
	return audio_player.stream.get_length()
