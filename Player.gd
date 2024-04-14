extends RigidBody2D

var screen_size
var thrust = 2000
var height
var player_state;
var on_ground_threshold = 2;

enum STATE {GROUND, AIR}

signal hook_launch(mouse_pos, player_pos)
signal release_signal()

func _ready():
	screen_size = get_viewport_rect().size 
	height = $CollisionShape2D.get_shape().get_extents().y
	
func _integrate_forces(state):
	switch_to_air()
	if(!get_colliding_bodies().empty()):
		for i in range(get_colliding_bodies().size()):
			var collision_point = to_local(state.get_contact_local_position(i)).y
			if abs(collision_point - height) < on_ground_threshold:
				switch_to_ground()
		
	var x = thrust * sin(PI/4)
	var y = thrust * cos(PI/4)
	var player_pos = global_position
	var mouse_pos = get_global_mouse_position()
	
	if Input.is_action_just_pressed("mouse_left_press"):
		emit_signal("hook_launch", mouse_pos, player_pos)
	if Input.is_action_just_pressed("unhook"):
		emit_signal("release_signal")
	
	# movement based actions
	applied_force = Vector2()
	if Input.is_action_pressed("move_left") && move_horizontal_condition():
		move_left(x, y)
	if Input.is_action_pressed("move_right") && move_horizontal_condition():
		move_right(x, y)
	if Input.is_action_just_pressed("jump") && is_on_ground():
		jump(y)

func switch_to_ground():
	player_state = STATE.GROUND
func switch_to_air():
	player_state = STATE.AIR

func move_horizontal_condition():
	if player_state == STATE.GROUND:
		return true
	if player_state == STATE.AIR && is_hooked():
		return true
	return false;
func is_on_ground():
	player_state == STATE.GROUND

func is_hooked():
	return $"../Hook".is_hooked()

func move_left(x, y):
	applied_force += Vector2(-x, -y)
func move_right(x, y):
	applied_force += Vector2(x, -y)
func jump(y):
	applied_force += Vector2(0, -20*y)
