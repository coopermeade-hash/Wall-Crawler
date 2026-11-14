extends GridMap

"""The gridmap is where we populate the random map gotten by world_gen.gd into a lively place full of victims to murder.

"""
##NOTE: The gridmap is set at 2x2x2 meter cells, so all player and tile movement will be a 2m increments unless we change it.

#The player node, TODO: Replace this with something more fitting later when we get the splitting done.
@onready var player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	var world_gen = WorldGen.new()
	var cells = world_gen.create_maze()
	
	
	
	for x in world_gen.WIDTH:
		for y in world_gen.HEIGHT:
			for z in world_gen.LENGTH:
				set_cell_item(Vector3i(x, y, z), cells[x][y][z])
	
	place_player()


func place_player():
	#Puts player in the center.
	player.position = map_to_local(Vector3i.ONE * 16)
