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

# Swing stats
var swing_time : int
var curr_swing_time : int
var swing_speed
var swing_direction : Vector2
var hit_occured 

# TEMP
var hook_line : Vector2

enum STATE {INAIR, ONGROUND, HOOKED}

func _ready():
	speed = 20
	swing_time = 50
	curr_swing_time = swing_time/2
	swing_speed = 0
	swing_direction = Vector2(1,1)
	hit_occured = false

func _draw():
	var plots = []
	if Input.is_action_pressed("mouse_left_press"):
		plots.append(Vector2.ZERO)
		plots.append(hook_line)
	draw_polyline(plots, Color.black)

func _process(delta):
	var direction = right() - left() + dash_boost()
	if(player_state == STATE.HOOKED ):
		if(curr_swing_time == swing_time):
			swing_direction.x = -1
		if(curr_swing_time == 0):
			swing_direction.x = 1
		curr_swing_time += swing_direction.x
		velocity.x += swing_speed * swing_direction.x
		
		print(velocity)
	else:
		if is_on_floor():
			on_ground()
			velocity.y = 0
		else:
			in_air()
		# Horizontal Movement
		velocity.x = direction
		if direction == 0:
			velocity.x = 0
		
		# Vertical Movement
		if Input.is_action_just_pressed("jump") && player_state == STATE.ONGROUND:
			velocity.y -= scale_speed(25)
		velocity.y += scale_speed(1)
	
	if Input.is_action_just_pressed("unhook") && dash_cd > 0:
		dash_cd -= 1
		dash_timer = 5
	
	if Input.is_action_just_pressed("mouse_left_press") && player_state != STATE.HOOKED:
		hook_line.x = 100*sin(PI*7/8)
		hook_line.y = 100*cos(PI*7/8)
		
		hook = Hook.instance()
		add_child(hook)
		get_node("Hook").connect("hit_detected", self, "_hook_hit_detected")
		animation_frame_remainder = 15
		
	if Input.is_action_just_pressed("mouse_left_press") && player_state == STATE.HOOKED:
		in_air()
		hit_occured = false
		
	if animation_frame_remainder > 0:
		animation_frame_remainder -= 1
		in_animation()
		if animation_frame_remainder == 0 && hit_occured:
			is_hooked()
	
	
	move_and_slide(velocity, Vector2.UP)
	update()
	
	if dash_timer > 0:
		dash_timer -= 1
	if direction > 0:
		player_direction = 1
	if direction < 0:
		player_direction = -1

func on_ground():
	player_state = STATE.ONGROUND
	dash_cd = 1
func in_air():
	player_state = STATE.INAIR
func is_hooked():
	player_state = STATE.HOOKED
	curr_swing_time = swing_time/2
func in_animation():
	velocity = Vector2(0, 0)

func left():
	if Input.is_action_pressed("move_left"):
		return scale_speed(10)
	return 0
func right():
	if Input.is_action_pressed("move_right"):
		return scale_speed(10)
	return 0
func dash_boost():
	return dash_timer * speed * 20 * player_direction

func scale_speed(var i : int):
	return i * speed

func _hook_hit_detected(var hit_location):
	var distance = abs(hit_location.x - global_position.x)
	swing_speed = get_swinging_acceleration(distance, swing_time) 
	hit_occured = true

func get_swinging_acceleration(var length : int, var time : int):
	# formula is a = (length*cos(PI/8)) / (n^2 - (n-1)/2)
	var a = length / (time*time - (time + 1)/2)
	return length
