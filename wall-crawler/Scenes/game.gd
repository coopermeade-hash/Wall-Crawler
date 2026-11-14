extends Node

const head_camera = preload("uid://bpyo24twggm1d")

@onready var screen_container: GridContainer = $CenterContainer/GridContainer

var level_to_load : String = "uid://cbf11a0ekw2j8"
var first_subviewport : SubViewport = null
var level_node : Node3D = null

func add_new_player_viewport(new_head : HeadOfBody) -> void:
	var new_subviewportcontainer : SubViewportContainer = SubViewportContainer.new()
	var new_subviewport : SubViewport = SubViewport.new()
	
	var new_camera3d : Camera3D = head_camera.instantiate()
	new_subviewportcontainer.add_child(new_subviewport)
	new_subviewport.add_child(new_camera3d)
	
	if first_subviewport: #There is already 1 subviewport
		new_head.get_node("RemoteTransform3D").remote_path = new_camera3d.get_path()
		new_subviewport.world_3d = first_subviewport.world_3d
	else:
		level_node = load(level_to_load).instantiate() 
		new_subviewport.add_child(level_node)
		first_subviewport = new_subviewport
		level_node.get_tree().get_nodes_in_group("player")[0].get_node("RemoteTransform3D").remote_path = new_camera3d.get_path() 
	
