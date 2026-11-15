extends CharacterBody3D
class_name HeadOfBody 

##NOTE: BODY AND HEAD COLLISON IS A SPHERE TO AVOID BEING NUDGED WHEN ROTATING IN X AXIS. DO NOT CHANGE IT.

signal change_can_input(tof : bool)

#How long a turn takes in seconds.
const TURN_SPEED = 0.2
#How long it takes to move a tile in seconds.
const MOVE_SPEED = 0.1
#The time it takes to wait inbetween a move and being able to move again. Made for fast move speeds.
const WAIT_TIME = 0.05
#The body segment scene
const BODY_SEGMENT_SCENE = preload("uid://b0ldss6pcm4bu") 
# How long a step is in meters
const STEP_SIZE : int = 2 

var head_id : int = 0 
var current_segments : int = 1
var dir : Vector3 = Vector3.FORWARD

@onready var raycast = $RayCast3D
@onready var downcast = $Downcast
@onready var remote_transform_3d: RemoteTransform3D = $RemoteTransform3D
@onready var body: Node3D = $Body

func _ready() -> void:
	current_segments = 1 + body.get_child_count()
	
#Checks if our 'down' is equal to true down, by comparing the distance.
func check_if_sticking_to_wall(distance_limit = 0.01):
	var our_down = (basis * Vector3.DOWN).normalized()
	return (our_down - Vector3.DOWN).length_squared() < distance_limit


#Direction is how many degrees the character will turn, in 90 degree increments.
#Basis axis is the axis of rotation, generaly being in our y axis.
func turn(dir := 1, basis_axis := basis.y):
	var original_scale = scale
	var original_basis = basis
	
	#Make sure we can't input while tweening
	change_can_input.emit(false)
	var tween = get_tree().create_tween()
	
	#This allows turning to work when wall crawling.
	var target_basis = basis.rotated(basis_axis.normalized(), PI / 2 * dir)
	
	#Turn 90 degrees in TURN_SPEED seconds.
	tween.tween_method(
		#This function is needed or else we'll get errors when turning, as tweening basises causes problems.
		#I would make this a seperate function, but it needs stuff in the orignal function, like target basis.
		func(slerp_weight : float):
			basis = original_basis.slerp(target_basis, slerp_weight)
			scale = original_scale
	, 0.0, 1.0, TURN_SPEED)
	await tween.finished
	
	#Wait until tween is done, then make tween work.
	change_can_input.emit(true)
	


#Really more of a turning 'Up' onto a wall.
func wall_crawl(dir = 1):
	#Make sure we are facing a wall to start crawling it.
	raycast.target_position = (remote_transform_3d.basis * Vector3.FORWARD).normalized() * 2
	raycast.force_raycast_update()
	
	if not raycast.is_colliding():
		return
	if not raycast.get_collider() is GridMap:
		return
	#Now we perform a turn in the x axis.
	await turn(1, basis.x)
	


#Direction is where we are moving, length is how long a step is in meters.
func try_move(direction : Vector3, length = STEP_SIZE):
	#Set the raycast to where the next tile is, and update it.
	
	##NOTE: we set the raycast to the real direction, not the basis direction since will rotate with the player, 
	##      as it is a child node.
	raycast.target_position = direction * length
	raycast.force_raycast_update()
	
	#The downcast is so when we are wall crawling, we walk onto thin air and reveal that we don't have gravity while wall crawling.
	downcast.position = raycast.target_position
	
	#If the raycast collides, something is blocking it, and we shouldn't move.
	if raycast.is_colliding():
		return
	
	# Check to make sure some segment is touching solid ground
	if body.get_child_count() == 0:
		if not downcast.is_colliding(): return 
	elif not _colliding_segments_downcast():
		return
	
	#The basis, times the direction so it properly goes to where we are facing, times two so we move a full tile.
	dir = direction 
	var basis_dir = (self.basis * direction).normalized() * length
	
	#save old position for segments 
	var old_position = position 
	
	#Move to new position in MOVE_SPEED seconds
	change_can_input.emit(false)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", position + basis_dir, MOVE_SPEED)
	await tween.finished
	
	#Moves segments recursively 
	_move_segment(0, old_position, basis_dir)
	
	print(position) 
	
	##NOTE: Aadded this to make holding W not as fast on fast movespeeds. Waits a additional time period.
	await get_tree().create_timer(WAIT_TIME).timeout
	
	#Wait until tween is done, then make tween work.
	change_can_input.emit(true)


func try_attack():
	raycast.target_position = Vector3.FORWARD * 2
	raycast.force_raycast_update()
	
	if not raycast.is_colliding():
		return
	if raycast.get_collider() is GridMap:
		return
	
	var collider = raycast.get_collider()
	if collider.has_method("eaten"):
		_spawn_segment(body.get_child_count())
		collider.eaten()


# Halves the players segments during a split
# NOTE: CURRENTLY UNUSED 
func halve():
	var halved_segments = ceil(current_segments / 2.0)
	var segment_count = body.get_child_count()
	var seg_nodes = body.get_children()
	
	for i in range(halved_segments, segment_count):
		seg_nodes[i].queue_free()
	
	current_segments = halved_segments
	print("Previous segments: " + str(segment_count) + "\n Current segments:" + str(current_segments))


#spawn segment of body and position behind last 
func _spawn_segment(i : int): 
	var seg = BODY_SEGMENT_SCENE.instantiate()
	body.add_child(seg) 
	
	if i == 0: 
		var direc = (self.basis * dir).normalized() * STEP_SIZE
		seg.position = position - direc
	else: 
		var last_segment = body.get_child(i-1)
		var direc = (last_segment.basis * last_segment.dir).normalized() * STEP_SIZE
		seg.position = last_segment.position - direc 
	
	print ("Spawned segment " + str(body.get_child_count()))


# move segment to a recursive position 
func _move_segment(i : int, new_pos : Vector3, basis_dir : Vector3): 
	if body.get_child_count() <= 0: return #base case 
	
	print("Moved segment" + str(i))
	
	var segment = body.get_child(i) 
	var old_pos = segment.position
	var old_dir = segment.dir 
	
	segment.dir = basis_dir
	segment.update_shapecast() 
	segment.position = new_pos 
	
	#tail recursion 
	if body.get_child_count() - (i+1) > 0: 
		_move_segment(i+1, old_pos, old_dir)


#check that any segments in the body are touching SOMETHING
func _colliding_segments_downcast() -> bool: 
	if body.get_child_count() == 0: return true 
	
	var segment_touching_ground : bool = false 
	for segment in body.get_children():
		if segment.shapecast.is_colliding():
			for i in range(segment.shapecast.get_collision_count()):
				var collider = segment.shapecast.get_collider(i)
				
				# Check if the collider is of a specific built-in type
				if collider is GridMap:
					segment_touching_ground = true 
	return segment_touching_ground
