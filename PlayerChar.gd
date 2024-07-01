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
var animation_frame_remainder : int
var hor_movement : int
var jump_animation : int
@onready var animation = $Sprite2D/animation

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
	
	## Actions with semi-locked animations.
	if Input.is_action_just_pressed("hook"):
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
	
	## Animation lock checker (only used for hook animation)
	if animation_frame_remainder > 0:
		animation_frame_remainder -= 1
		in_animation()
		if animation_frame_remainder == 0 && hit_occured:
			is_hooked()
	
	# timers
	if dash_timer > 0:
		dash_timer -= 1
	if(buffer_timer > 0):
		buffer_timer -= 1
	elif(buffer_timer == 0):
		buffer = null
	
	# player direction
	if hor_movement > 0:
		player_direction = 1
	if hor_movement < 0:
		player_direction = -1

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
	curr_swing_time.x = int(sqrt(pow(swing_time.x, 2))/2)
	curr_swing_time.y = int(sqrt(pow(swing_time.y, 2))/2)
	swing_direction.y = 1
	swing_direction.x = player_direction
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
func _hook_hit_detected(hit_location):
	var dist : Vector2
	var angle = global_position.angle_to_point(hit_location)
	var h = global_position.distance_to(hit_location)
	
	# calculated distance of player to hit location.
	dist.y = h - (h * sin(angle))
	dist.x = abs(hit_location.x - global_position.x)
	
	# determine swinging speed to simulate pendulum effect.
	swing_speed.x = get_swinging_acceleration(dist.x, swing_time.x) 
	swing_speed.y = get_swinging_acceleration(dist.y, swing_time.y) 
	
	hit_occured = true
	hook_line = hit_location ## TEMP
func get_swinging_acceleration(length : float, time : float): 
	# determine the acceleration needed for player to have a pendulum effect.
	var a = (2*length)/(time*time)
	return a*speed
func movement_in_hooked():
	# Player's movement during the 'hooked' state.
	if(curr_swing_time.x == swing_time.x):
		swing_direction.x = -1
		velo.x = scale_speed(swing_speed.x*swing_time.x)/2
	if(curr_swing_time.x == 0):
		swing_direction.x = 1
		velo.x = -scale_speed(swing_speed.x*swing_time.x)/2
	if(curr_swing_time.y == swing_time.y):
		swing_direction.y = -1
		velo.y = scale_speed(swing_speed.y*swing_time.y)/2
	if(curr_swing_time.y == 0):
		swing_direction.y = 1
		velo.y = -scale_speed(swing_speed.y*swing_time.y)/2
	
	curr_swing_time.x += swing_direction.x
	curr_swing_time.y += swing_direction.y
	velo.x += scale_speed(swing_speed.x * swing_direction.x)
	velo.y += scale_speed(swing_speed.y * swing_direction.y)
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
	velo.y += scale_speed(1)

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
			hook = Hook.instantiate()
			add_child(hook)
			get_node("Hook").connect("hit_detected",Callable(self,"_hook_hit_detected"))
			animation_frame_remainder = 15
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
	
