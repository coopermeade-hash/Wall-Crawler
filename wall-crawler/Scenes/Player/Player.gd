extends CharacterBody3D

"""This is a simple player controller. Splitscreen effects are to added later.

We need the snake component, though i'm unsure if it'll work in these tight cooridoors, and if it'll be fun.
We also need the wall crawling component, though with how I've coded it, it could work by:
	Simply rotating the player 90 degrees in the correct axis so it looks like they are walking on a wall.
	We could also change the player's gravity to mess with them more, if we want to go in a more escher-like direction.
		And for gravity we could swap this for a character controller or a rigid body if we want to be lazy.
"""

#How long a turn takes in seconds.
const TURN_SPEED = 0.5
#How long it takes to move a tile in seconds.
const MOVE_SPEED = 0.1
#The time it takes to wait inbetween a move and being able to move again. Made for fast move speeds.
const WAIT_TIME = 0.1

@onready var camera = $Camera3D
@onready var raycast = $RayCast3D

#This varible makes sure the player doesn't input while a tween is active, putting them offgrid.
var can_input = true


func _unhandled_input(event: InputEvent) -> void:
	#if can_input == false, we can't input
	if not can_input: return
	
	##TODO: replace with dedicated functions and tweens
	#Turn left or right 90 degrees.
	if event.is_action_pressed("turn_left"):
		turn()
	elif event.is_action_pressed("turn_right"):
		turn(-1)
	
	if event.is_action_pressed("wall_crawl"):
		wall_crawl()
	
	#Move forwards or backwards 1 meter.
	if event.is_action("move_forward"):
		await try_move(Vector3.FORWARD)
	elif event.is_action("move_backward"):
		await try_move(Vector3.BACK)


#Direction is how many degrees the character will turn, in 90 degree increments.
#Basis axis is the axis of rotation, generaly being in our y axis.
func turn(dir := 1, basis_axis := basis.y):
	var original_scale = scale
	var original_basis = basis
	#Make sure we can't input while tweening
	can_input = false
	var tween = get_tree().create_tween()
	#Turn 90 degrees in TURN_SPEED seconds.
	
	
	#This allows turning to work when wall crawling.
	var target_basis = basis.rotated(basis_axis.normalized(), PI / 2 * dir)
	
	tween.tween_method(
		#This function is needed or else we'll get errors when turning, as tweening basises causes problems.
		#I would make this a seperate function, but it needs stuff in the orignal function, like target basis.
		func(slerp_weight : float):
			basis = original_basis.slerp(target_basis, slerp_weight)
			scale = original_scale
	, 0.0, 1.0, TURN_SPEED)
	
	await tween.finished
	#Wait until tween is done, then make tween work.
	can_input = true


#Really more of a turning 'Up' onto a wall.
func wall_crawl(dir = 1):
	#Make sure we are facing a wall to start crawling it.
	raycast.target_position = (camera.basis * Vector3.FORWARD).normalized() * 2
	raycast.force_raycast_update()
	
	if not raycast.is_colliding():
		return
	if not raycast.get_collider() is GridMap:
		return
	
	#Now we perform a turn in the x axis.
	turn(1, basis.x)
	

	


#Direction is where we are moving, length is how long a step is in meters.
func try_move(direction : Vector3, length = 2):
	
	#Set the raycast to where the next tile is, and update it.
	
	##NOTE: we set the raycast to the real direction, not the basis direction since will rotate with the player, 
	##as it is a child node.
	raycast.target_position = direction * length
	raycast.force_raycast_update()
	
	#If the raycast collides, something is blocking it, and we shouldn't move.
	#TODO: Add the wallcrawling element.
	if raycast.is_colliding():
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
	
