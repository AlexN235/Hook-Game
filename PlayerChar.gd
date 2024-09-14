extends CharacterBody2D

var Hook = preload("res://Hook.tscn")
var player_state
var hook
var buffer
var buffer_timer : int
var velo : Vector2 
var speed : int
var player_direction : int
var dash_timer : int
var dash_cd : int
var hor_movement : int
var jump_animation : int
var mouse_position : Vector2
@onready var animation = $Sprite2D/animation
var rope_length
var hook_point
var OutOfRange : bool

# Swing stats
var swing_time : Vector2
var curr_swing_time : Vector2		
var swing_speed : Vector2	
var swing_direction : Vector2
var hit_occured : bool

# TEMP
var hook_line : Vector2

enum STATE {INAIR, ONGROUND, HOOKED, JUMP}
enum ACTION {JUMP, HOOK, DASH}

func _ready():
	speed = 20
	swing_time = Vector2(50, 25) 
	curr_swing_time = Vector2(int(sqrt(pow(swing_time.x, 2))/2), int(sqrt(pow(swing_time.y, 2))/2))
	swing_speed = Vector2.ZERO
	swing_direction = Vector2(1,1)
	hit_occured = false

func _draw():
	var plots = []
	if Input.is_action_pressed("hook"):
		plots.append(Vector2.ZERO)
		plots.append(hook_line - global_position)
	draw_polyline(plots, Color.BLACK)

func _process(delta):
	# Camera3D
	var cam = get_node("Camera2D")
	
	animation.play("idle");
	
	hor_movement = right() - left() + dash_boost()
	
	## Action with completely locked animations.
	if Input.is_action_pressed("jump"):
		buffer = ACTION.JUMP
		set_buffer_timer()
	if(player_state == STATE.HOOKED):
		movement_in_hooked()
	else:
		movement_in_ground_air()
	velo.y += scale_speed(1)
	
	## Actions with semi-locked animations.
	if Input.is_action_just_pressed("hook"):
		mouse_position = get_global_mouse_position()
		buffer = ACTION.HOOK
		set_buffer_timer()
	## Actions with no locked animations.
	if Input.is_action_just_pressed("dash"):
		buffer = ACTION.DASH
		set_buffer_timer()
	
	# action buffer
	var act = perform_action(get_next_action())
	if act == true:
		buffer = null

#
#	## Animation lock checker (only used for hook animation)
#	if animation_frame_remainder > 0:
#		animation_frame_remainder -= 1
#		in_animation()
#		if animation_frame_remainder == 0 && hit_occured:
#			is_hooked()
	
	# timers
	if dash_timer > 0:
		dash_timer -= 1
	elif(buffer_timer == 0):
		buffer = null
	
	# player direction
	if hor_movement > 0:
		player_direction = 1
	if hor_movement < 0:
		player_direction = -1

	# player velocity limit
	limit_velocity()
	
	set_velocity(velo)
	set_up_direction(Vector2.UP)
	move_and_slide()
	queue_redraw()

################################################################################
############################ State Change Functions ############################
################################################################################
func on_ground():
	player_state = STATE.ONGROUND
	dash_cd = 1
func in_air():
	player_state = STATE.INAIR
func is_hooked():
	player_state = STATE.HOOKED
func is_jump():
	player_state = STATE.JUMP
	jump_animation = 10
func in_action():
	player_state != STATE.ONGROUND || player_state != STATE.INAIR
func in_animation():
	velo = Vector2(0, 0)

################################################################################
############################## Movement functions ##############################
################################################################################
func left():
	if Input.is_action_pressed("move_left"):
		return scale_speed(10)
	return 0
func right():
	if Input.is_action_pressed("move_right"):
		return scale_speed(10)
	return 0
func dash_boost():
	return dash_timer * scale_speed(20) * player_direction
func scale_speed(i : float):
	# speed of objects all scaled by this function.
	return i * speed
func limit_velocity():
	var horizontal_limit = 300 
	var verticle_limit = 300
	
	if(velo.x > horizontal_limit):
		velo.x = horizontal_limit
	elif(velo.x < -horizontal_limit):
		velo.x = -horizontal_limit
	
	if(velo.y > verticle_limit):
		velo.y = verticle_limit
	elif(velo.y < -verticle_limit*2):
		velo.y = -verticle_limit*2
		
	
func hook_hit_detected(hit_location):
	hook_point = hit_location
	var player_location : Vector2
	
	player_location = global_position
	rope_length = global_position.distance_to(hit_location)
	
	player_state = STATE.HOOKED
	
func hook_finding_wall(player_pos : Vector2, mouse_pos : Vector2):
	var angle = player_pos.angle_to_point(mouse_pos)
	## Find wall along path from player to a certain distance
	
func movement_in_hooked():
	# Player's movement during the 'hooked' state.
	
	## TO DO:
	# 1. Swing works for south quadrant but fails in west, east. Try dealing 
	# with movement and momentum by quadrants
	# 2. Player controlled left and right movement
	
	OutOfRange = abs(global_position.distance_to(hook_point)) > rope_length
	if OutOfRange:
		var ang = global_position.angle_to_point(hook_point)
		# Keeping player within rope length
		var new_pos = Vector2(rope_length, 0)
		new_pos = new_pos.rotated(ang+PI)
		global_position = hook_point + new_pos
		#velo.y = 0
		
		# Velocity/Momentum
		var new_velo_y = Vector2(velo.y, 0).rotated(ang)
		new_velo_y.y = new_velo_y.x/10
		velo.y = 0
		print(velo, " : ", new_velo_y, " :: ", global_position)
		velo += new_velo_y
		
		# Player Movement
		var velo_ang = PI/2 - ang
		var velo_change = Vector2(-hor_movement/10, 0).rotated(velo_ang)
		
		velo += velo_change
		

func determine_hook_end():
	hook_point
	rope_length
	
	pass

func movement_in_ground_air():
	# Movement of player when they are in the air or on the ground. Also deals
	# with player state changes during those times.
	if player_state == STATE.JUMP:
		if jump_animation == 0:
			in_air()
		jump_animation -= 1;
	elif is_on_floor():
		on_ground()
		velo.y = 0
	else:
		in_air()
		
	# Horizontal Movement
	velo.x = hor_movement
	if hor_movement == 0:
		velo.x = 0
	
	# Vertical Movement
	if Input.is_action_just_pressed("jump") && player_state == STATE.ONGROUND:
		is_jump()
	

################################################################################
############################### Action functions ###############################
################################################################################
func get_next_action():
	if buffer != null:
		return buffer
	return null

func perform_action(action):
	var action_success = false
	# Jump Action
	if action == ACTION.JUMP && jump_animation > 0:
		velo.y -= scale_speed(1.2*jump_animation/2)
		action_success = true

	# Hook Action
	if action == ACTION.HOOK:
		# Throw out hook
		if player_state != STATE.HOOKED:
			## Call Map to instantiate hook.
			var map = get_parent()
			map.create_hook(global_position, mouse_position)
			
		# Retract hook
		elif player_state == STATE.HOOKED:
			in_air()
			hit_occured = false
		action_success = true

	# Dash action
	if action == ACTION.DASH && dash_cd > 0:
		dash_cd -= 1
		dash_timer = 5
		action_success = true

	return action_success

func set_buffer_timer():
	buffer_timer = 5
	
