extends Control

@export var sound_list : Array[AudioStream] 
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	play_random_loop()
	
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Control/start_menu.tscn")

func play_random_loop():
	while true:
		var idx = randi_range(0, sound_list.size() - 1)
		audio_stream_player.stream = sound_list[idx]
		audio_stream_player.volume_db = -15.
		audio_stream_player.pitch_scale = randf_range(0.2, 1)
		audio_stream_player.play()
		await get_tree().create_timer(randf_range(.5, 3)).timeout 
