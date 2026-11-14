extends GridMap


func _ready() -> void:
	var world_gen = WorldGen.new()
	var cells = world_gen.create_maze()
	
	
	
	for x in world_gen.WIDTH:
		for y in world_gen.HEIGHT:
			for z in world_gen.LENGTH:
				set_cell_item(Vector3i(x, y, z), cells[x][y][z])
	
	print(get_used_cells_by_item(0))
