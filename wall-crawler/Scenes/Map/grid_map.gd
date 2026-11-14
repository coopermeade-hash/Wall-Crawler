extends GridMap

"""The gridmap is where we populate the random map gotten by world_gen.gd into a lively place full of victims to murder.

"""
##NOTE: The gridmap is set at 2x2x2 meter cells, so all player and tile movement will be a 2m increments unless we change it.

@export var world_size = Vector3(32,32,32)

#Made this an export in case we change the directory for the victim
@export var victim_scene : PackedScene
#How often a victim will be generated.
@export_range(0.0, 1.0, 0.01) var victim_chance = 0.1

#The player node, TODO: Replace this with something more fitting later when we get the splitting done.
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

var exits = []

func _ready() -> void:
	var world_gen = WorldGen.new(world_size.x, world_size.y, world_size.z, 0)
	var cells = world_gen.create_maze(1024, 32)
	
	#Get exits for each direction
	var left_exits = []
	var right_exits = []
	
	var down_exits = []
	var up_exits = []
	
	var forward_exits = []
	var backward_exits = []
	
	#for each dead end, check if the dead end is at one end of the maze, if it is, add to the exits.
	for dead_end in world_gen.dead_ends:
		if dead_end.x == 0:
			left_exits.append(dead_end)
		if dead_end.x == world_size.x - 2:
			right_exits.append(dead_end)
		
		if dead_end.y == 0:
			down_exits.append(dead_end)
		if dead_end.y == world_size.y - 2:
			up_exits.append(dead_end)
		
		if dead_end.z == 0:
			forward_exits.append(dead_end)
		if dead_end.z == world_size.z - 2:
			backward_exits.append(dead_end)
	
	#Get a list of all the exits. We could use this to point twoards the nearest when.
	exits = left_exits + right_exits + down_exits + up_exits + forward_exits + backward_exits
	
	#Set cells, offset from the center
	for x in world_gen.WIDTH + 1:
		for y in world_gen.HEIGHT + 1:
			for z in world_gen.LENGTH + 1:
				set_cell_item(Vector3i(x, y, z), cells[x - 1][y -1][z - 1])
	
	#Place the player, the victims, and the exits.
	place_player()
	place_victims(world_gen.dead_ends)
	
	for l_exit in left_exits:
		


#Place the player in the center of the maze.
func place_player():
	var start_tile = (world_size / 2) - Vector3.ONE
	#While we are in midair, move us down by one tile.
	while get_cell_item(start_tile + Vector3.DOWN) == -1:
		start_tile.y -= 1
	
	#Puts player in the center, or close to it.
	player.position = map_to_local(start_tile)

#Put victims randomly in the maze.
func place_victims(dead_ends : Array ):
	for dead_end in dead_ends:
		#if a dead end is the center, skip, as that is where the player is.
		var random_chance = randf()
		#if there is a victim scene and we are below the victim chance.
		if random_chance <= victim_chance and victim_scene:
			var new_victim = victim_scene.instantiate()
			new_victim.position = map_to_local(dead_end)
			add_child(new_victim)

#Place an exit at the star point, going in a certain direction
func place_exits(start : Vector3, direction : Vector3, pit_length := 6, ledge_length = 3):
	var point = start
	for l in pit_length + ledge_length:
		point += direction
		set_cell_item(point, -1)
		if l > pit_length:
			set_cell_item(point + Vector3.DOWN, 0)
