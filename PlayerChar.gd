extends KinematicBody2D

var player_state
var velocity = Vector2(0, 0)
var speed = 20
var player_direction = 0
var dash_timer = 0
var dash_cd = 1

enum STATE {INAIR, ONGROUND}

func _ready():
	pass

func _process(delta):
	# Horizontal Movement
	var direction = right() - left() + dash_boost()
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
	
	move_and_slide(velocity, Vector2.UP)
	
	if dash_timer > 0:
		dash_timer -= 1
	if direction > 0:
		player_direction = 1
	if direction < 0:
		player_direction = -1
	
	if is_on_floor():
		on_ground()
		velocity.y = 0
	else:
		in_air()
		
func on_ground():
	player_state = STATE.ONGROUND
	dash_cd = 1
func in_air():
	player_state = STATE.INAIR

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

