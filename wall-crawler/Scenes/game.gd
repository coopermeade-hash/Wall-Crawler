extends Node

const head_camera = preload("uid://bpyo24twggm1d")

@onready var screen_container: GridContainer = $CenterContainer/GridContainer

var level_to_load : String = "uid://buu8sxvplnax0"
var first_subviewport : SubViewport = null
var level_node : Node3D = null

func _ready() -> void:
	_add_new_player_viewport(null)
	_update_viewport_size() 
	
func _add_new_player_viewport(new_head : HeadOfBody ) -> void: 
	#player should not have camera, it is added to their heads in this function
	#then connected via remote transform
	
	var new_subviewportcontainer : SubViewportContainer = SubViewportContainer.new()
	var new_subviewport : SubViewport = SubViewport.new()
	var new_camera3d : Camera3D = head_camera.instantiate()
	
	screen_container.add_child(new_subviewportcontainer) #container contains several containers, GOT IT?
	new_subviewportcontainer.add_child(new_subviewport)
	new_subviewport.add_child(new_camera3d)
	
	if first_subviewport: #There is already 1 subviewport
		new_head.get_node("RemoteTransform3D").remote_path = new_camera3d.get_path() #ah the magic of remote transforms
		new_subviewport.world_3d = first_subviewport.world_3d
	else:
		level_node = load(level_to_load).instantiate() 
		new_subviewport.add_child(level_node)
		first_subviewport = new_subviewport
		level_node.get_tree().get_nodes_in_group("player")[0].get_node("RemoteTransform3D").remote_path = new_camera3d.get_path()
		 
	
func _update_viewport_size() -> void:
	screen_container.columns = ceil(screen_container.get_child_count() / 2.0) 
	for viewport_node in screen_container.get_children():
		var subviewport_node : SubViewport = viewport_node.get_child(0)
		var game_size : Vector2 = get_viewport().get_visible_rect().size 
		
		#second subviewport splits y, not x 
		subviewport_node.size.x = game_size.x / screen_container.columns
		subviewport_node.size.y = game_size.y / ceil(float(screen_container.get_child_count()) / float(screen_container.columns))
