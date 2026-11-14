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
@onready var player = get_tree().get_first_node_in_group("player")

func _ready() -> void:
	var world_gen = WorldGen.new(world_size.x, world_size.y, world_size.z)
	var cells = world_gen.create_maze(256, 32)
	
	
	
	for x in world_gen.WIDTH:
		for y in world_gen.HEIGHT:
			for z in world_gen.LENGTH:
				set_cell_item(Vector3i(x, y, z), cells[x][y][z])
	
	place_player()
	place_victims(world_gen.maze_cells)


func place_player():
	var start_tile = world_size / 2
	#While we are in midair, move us down by one tile.
	while get_cell_item(start_tile + Vector3.DOWN) == -1:
		start_tile.y -= 1
	
	#Puts player in the center, or close to it.
	player.position = map_to_local(start_tile)


func place_victims(dead_ends : Array ):
	for dead_end in dead_ends:
		#if a dead end is the center, skip, as that is where the player is.
		if dead_end == Vector3.ONE * 16:
			continue
		var random_chance = randf()
		#if there is a victim scene and we are below the victim chance.
		if random_chance <= victim_chance and victim_scene:
			var new_victim = victim_scene.instantiate()
			new_victim.position = map_to_local(dead_end)
			add_child(new_victim)
