extends CharacterBody3D

"""This is a simple player controller. Splitscreen effects are to added later.

We need the snake component, though i'm unsure if it'll work in these tight cooridoors, and if it'll be fun.
We also need the spliiting component, i'm leaving that for saturday.
"""

##NOTE: PLAYER COLLISON IS A SPHERE TO AVOID BEING NUDGED WHEN ROTATING IN X AXIS. DO NOT CHANGE IT. THIS MEANS YOU.

#How long a turn takes in seconds.
const TURN_SPEED = 0.2
#How long it takes to move a tile in seconds.
const MOVE_SPEED = 0.1
#The time it takes to wait inbetween a move and being able to move again. Made for fast move speeds.
const WAIT_TIME = 0.1

@onready var map : GridMap = get_tree().get_first_node_in_group("map")

@onready var camera = $Camera3D
@onready var raycast = $RayCast3D
@onready var downcast = $Downcast

#This varible makes sure the player doesn't input while a tween is active, putting them offgrid.
var can_input = true

var ghost_mode = true

#Checks if our 'down' is equal to true down, by comparing the distance.
func check_if_sticking_to_wall(distance_limit = 0.01):
	var our_down = (basis * Vector3.DOWN).normalized()
	return (our_down - Vector3.DOWN).length_squared() < distance_limit


func _unhandled_input(event: InputEvent) -> void:
	#if can_input == false, we can't input
	if not can_input: return
	
	##TODO: replace with dedicated functions and tweens
	#Turn left or right 90 degrees.
	if event.is_action_pressed("turn_left"):
		turn()
	elif event.is_action_pressed("turn_right"):
		turn(-1)
	
	#Face a wall on crawl onto it.
	if event.is_action_pressed("wall_crawl"):
		wall_crawl()
	
	#Move forwards or backwards 1 meter.
	if event.is_action("move_forward"):
		await try_move(Vector3.FORWARD)
	elif event.is_action("move_backward"):
		await try_move(Vector3.BACK)
	
	#Kill people
	if event.is_action_pressed("attack"):
		try_attack()


#Direction is how many degrees the character will turn, in 90 degree increments.
#Basis axis is the axis of rotation, generaly being in our y axis.
func turn(dir := 1, basis_axis := basis.y):
	var original_scale = scale
	var original_basis = basis
	#Make sure we can't input while tweening
	can_input = false
	var tween = get_tree().create_tween()
	#Turn 90 degrees in TURN_SPEED seconds.
	
	
	
	##NOTE: I got the target basis and slerp idea from google's AI. 
	##I tested the damn thing piece by piece so I would use as little as possible, but it would give errors about scaling.
	##I'm sorry, please dont stone me. -Cooper
	
	#This allows turning to work when wall crawling.
	var target_basis = basis.rotated(basis_axis.normalized(), PI / 2 * dir)
	
	tween.tween_method(
		#This function is needed or else we'll get errors when turning, as tweening basises causes problems.
		#I would make this a seperate function, but it needs stuff in the orignal function, like target basis.
		func(slerp_weight : float):
			basis = original_basis.slerp(target_basis, slerp_weight)
			scale = original_scale
	, 0.0, 1.0, TURN_SPEED)
	##END AI INFLUENCED SECTION.
	await tween.finished
	#Wait until tween is done, then make tween work.
	can_input = true


#Really more of a turning 'Up' onto a wall.
func wall_crawl(dir = 1):
	#Make sure we are facing a wall to start crawling it.
	raycast.target_position = (camera.basis * Vector3.FORWARD).normalized() * 2
	raycast.force_raycast_update()
	
	if not ghost_mode:
		if not raycast.is_colliding():
			return
		if not raycast.get_collider() is GridMap:
			return
	#Now we perform a turn in the x axis.
	await turn(1, basis.x)
	


#Direction is where we are moving, length is how long a step is in meters.
func try_move(direction : Vector3, length = 2):
	
	#Set the raycast to where the next tile is, and update it.
	
	##NOTE: we set the raycast to the real direction, not the basis direction since will rotate with the player, 
	##as it is a child node.
	raycast.target_position = direction * length
	raycast.force_raycast_update()
	
	#The downcast is so when we are wall crawling, we walk onto thin air and reveal that we don't have gravity while wall crawling.
	downcast.position = raycast.target_position
	
	
	#If the raycast collides, something is blocking it, and we shouldn't move.
	#TODO: Make this into a bump animation, where we run into the wall.
	if not ghost_mode:
		
		if raycast.is_colliding():
			return
		
		#TODO: Make this into a stumbble animation, where we almost fall off but catch ourselves. 
		##NOTE: This makes falling impossible! For now i've removed falling, since we can't do it.
		if not downcast.is_colliding():
			return
	
	#The basis, times the direction so it properly goes to where we are facing, times two so we move a full tile.
	var basis_dir = (self.basis * direction).normalized() * length
	
	can_input = false
	var tween = get_tree().create_tween()
	#Turn 90 degrees in TURN_SPEED seconds.
	tween.tween_property(self, "position", position + basis_dir, MOVE_SPEED)
	await tween.finished
	
	##NOTE: Aadded this to make holding W not as fast on fast movespeeds. Waits a additional time period.
	await get_tree().create_timer(WAIT_TIME).timeout
	#Wait until tween is done, then make tween work.
	can_input = true
	


func try_attack():
	print(Vector3.FORWARD.rotated(Vector3.UP, rotation.y))
	raycast.target_position = Vector3.FORWARD * 2
	raycast.force_raycast_update()
	
	if not raycast.is_colliding():
		return
	if raycast.get_collider() is GridMap:
		return
	
	var collider = raycast.get_collider()
	if collider.has_method("eaten"):
		collider.eaten()
	
	
