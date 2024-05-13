extends KinematicBody2D

var Hook = preload("res://Hook.tscn")
var player_state
var hook
var velocity : Vector2 
var speed : int
var player_direction : int
var dash_timer : int
var dash_cd : int
var animation_frame_remainder : int
var hor_movement : int

# Swing stats
var swing_time : Vector2
var curr_swing_time : Vector2		
var swing_speed : Vector2	
var swing_direction : Vector2
var hit_occured : bool

# TEMP
var hook_line : Vector2

enum STATE {INAIR, ONGROUND, HOOKED}

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
	draw_polyline(plots, Color.black)

func _process(delta):
	hor_movement = right() - left() + dash_boost()
	if(player_state == STATE.HOOKED):
		movement_in_hooked()
	else:
		movement_in_ground_air()
		
	if Input.is_action_just_pressed("dash") && dash_cd > 0:
		dash_cd -= 1
		dash_timer = 5
	
	if Input.is_action_just_pressed("hook") && player_state != STATE.HOOKED:
		hook = Hook.instance()
		add_child(hook)
		get_node("Hook").connect("hit_detected", self, "_hook_hit_detected")
		animation_frame_remainder = 15
		
	if Input.is_action_just_pressed("hook") && player_state == STATE.HOOKED:
		in_air()
		hit_occured = false
		
	if animation_frame_remainder > 0:
		animation_frame_remainder -= 1
		in_animation()
		if animation_frame_remainder == 0 && hit_occured:
			is_hooked()
	
	if dash_timer > 0:
		dash_timer -= 1
	if hor_movement > 0:
		player_direction = 1
	if hor_movement < 0:
		player_direction = -1
	
	move_and_slide(velocity, Vector2.UP)
	update()

# State change functions
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
func in_animation():
	velocity = Vector2(0, 0)

# Movement and action functions
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
func scale_speed(var i : float):
	return i * speed
func _hook_hit_detected(var hit_location):
	var dist : Vector2
	var angle = global_position.angle_to_point(hit_location)
	var h = global_position.distance_to(hit_location)
	dist.y = h - (h * sin(angle))
	dist.x = abs(hit_location.x - global_position.x)
	swing_speed.x = get_swinging_acceleration(dist.x, swing_time.x) 
	swing_speed.y = get_swinging_acceleration(dist.y, swing_time.y) 
	hit_occured = true
	hook_line = hit_location
	print(hook_line)
func get_swinging_acceleration(var length : float, var time : float): 
	var a = (2*length)/(time*time)
	return a*speed
func movement_in_hooked():
	if(curr_swing_time.x == swing_time.x):
		swing_direction.x = -1
		velocity.x = scale_speed(swing_speed.x*swing_time.x)/2
	if(curr_swing_time.x == 0):
		swing_direction.x = 1
		velocity.x = -scale_speed(swing_speed.x*swing_time.x)/2
	if(curr_swing_time.y == swing_time.y):
		swing_direction.y = -1
		velocity.y = scale_speed(swing_speed.y*swing_time.y)/2
	if(curr_swing_time.y == 0):
		swing_direction.y = 1
		velocity.y = -scale_speed(swing_speed.y*swing_time.y)/2
	
	curr_swing_time.x += swing_direction.x
	curr_swing_time.y += swing_direction.y
	velocity.x += scale_speed(swing_speed.x * swing_direction.x)
	velocity.y += scale_speed(swing_speed.y * swing_direction.y)
func movement_in_ground_air():
	if is_on_floor():
		on_ground()
		velocity.y = 0
	else:
		in_air()
	# Horizontal Movement
	velocity.x = hor_movement
	if hor_movement == 0:
		velocity.x = 0
	
	# Vertical Movement
	if Input.is_action_just_pressed("jump") && player_state == STATE.ONGROUND:
		velocity.y -= scale_speed(25)
	velocity.y += scale_speed(1)
