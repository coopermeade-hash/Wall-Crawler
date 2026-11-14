class_name WorldGen extends Node

"""READ ME:
	This only applies to generating the map. I feel like populating the map randomly,
	or messing with it programaticly should be done in grid_map.gd
"""

#The WIDTH, HEIGHT, and LENGTH of the maze. Constants are in caps.
const WIDTH = 32
const HEIGHT = 32
const LENGTH = 32

#The six cardinal directions of 3D space. 
const DIRS = [Vector3.LEFT, Vector3.RIGHT, Vector3.UP, Vector3.DOWN, Vector3.FORWARD, Vector3.BACK]

#If the point is out of bounds, return true, otherwise, return false
func is_out_of_bounds(point : Vector3):
	var is_false = point.x < 0 or point.y < 0 or point.z < 0 or point.x >= WIDTH or point.y >= HEIGHT or point.z >= LENGTH
	return is_false

#Create a maze. walker_LENGTH is how long each walker will walk if it doesn't hit anything
#Path count is the number of walkers
#THe maze works by doing a random walker until it hits itself, then it goes to a random spot in the maze.
func create_maze(walker_LENGTH = 256, path_count = 32):
	#Create a empty array, that will eventualy become
	var cells = []
	
	#Create a empty array that will have where our maze junctions are.
	var maze_cells = []
	
	#Create a empty 3D array of cells
	for x in WIDTH:
		cells.append([])
		for y in HEIGHT:
			cells[x].append([])
			for z in LENGTH:
				
				cells[x][y].append(-1)
	
	
	
	
	# For each walker we want...
	for path in path_count:
		#Make our staring cell the middle of the maze
		#If we arent the first walker, pick a random cell in the maze to start.
		var current_cell = Vector3(WIDTH / 2, HEIGHT / 2, LENGTH / 2)
		if maze_cells.size() > 0:
			current_cell = maze_cells.pick_random()
		
		#Set the current cell to be part of the maze.
		cells[current_cell.x][current_cell.y][current_cell.z] = 0
		
		maze_cells.append(current_cell)
		
		
		#For the life of each walker...
		for i in walker_LENGTH:
			
			#Get the surrounding cells
			var dirs = []
			for dir in DIRS:
				print(dir)
				var test_cell = current_cell + dir * 2
				
				#see if digging would put us out of bounds or hit part of the maze.
				#if this is true, reject this candidate direction.
				if is_out_of_bounds(test_cell) or maze_cells.has(test_cell):
					continue
				dirs.append(dir)
			
			#if the dirs are empty, die, and start a new walker.
			if dirs.is_empty():
				break
			
			#Pick a random selected direction
			var selected_dir = dirs.pick_random()
			#Dig two tiles in that direction, then set where we end up as part of the maze
			#Since we dig two tiles, we will never hit anywhere that isn't a junction point.
			for l in 2:
				current_cell += selected_dir
				
				cells[current_cell.x][current_cell.y][current_cell.z] = 0
				
			maze_cells.append(current_cell)
	#Return the finished map.
	return cells
