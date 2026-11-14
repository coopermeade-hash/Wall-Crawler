extends Node3D

"""
	This player controller acts as the brain to all of the heads in the Body.
	It controls them separately, simultaneously
	And controls split screen functionality. 
"""

signal split_body (head) 

@onready var map : GridMap = get_tree().get_first_node_in_group("map")
@onready var heads: Node3D = $Heads

#This varible makes sure the player doesn't input while a tween is active, putting them offgrid.
var can_input = true

func _ready() -> void:
	for segment in heads.get_children(): 
		if segment is HeadOfBody: 
			segment.change_can_input.connect(func(x): can_input = x )

func _unhandled_input(event: InputEvent) -> void:
	#if can_input == false, we can't input
	if not can_input: return
	
	for segment in heads.get_children():  
		if segment is not HeadOfBody: return 
		
		if event.is_action_pressed("turn_left"):
			segment.turn()
		elif event.is_action_pressed("turn_right"):
			segment.turn(-1)
		
		#Face a wall on crawl onto it.
		if event.is_action_pressed("wall_crawl"):
			segment.wall_crawl()
		
		#Move forwards or backwards 1 meter.
		if event.is_action("move_forward"):
			await segment.try_move(Vector3.FORWARD)
		elif event.is_action("move_backward"):
			await segment.try_move(Vector3.BACK)
		
		#Kill people
		if event.is_action_pressed("attack"):
			segment.try_attack()
			
		#Split
		if event.is_action_pressed("split"):
			var max_segments = 0 
			var largest_body = null 
			for head in heads.get_children(): 
				if head is HeadOfBody:
					var segments = head.current_segments 
					if segments > max_segments: max_segments = segments 
					largest_body = head 
				
			if max_segments >= 2: 
				split_body.emit(largest_body) 
			else:
				print("Could not split; too few segments:" + str(max_segments))
