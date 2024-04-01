extends RigidBody2D

var screen_size
var thrust = 10000
var torque = 20000

signal hook_launch(mouse_pos, player_pos)
signal release_signal()

func _ready():
	screen_size = get_viewport_rect().size 
func _integrate_forces(state):
	var x = thrust * sin(PI/4)
	var y = thrust * cos(PI/4)
	
	if Input.is_action_just_pressed("mouse_left_press"):
		var player_pos = global_position
		var mouse_pos = get_global_mouse_position()
		
		emit_signal("hook_launch", mouse_pos, player_pos)
		
	if Input.is_action_just_pressed("unhook"):
		emit_signal("release_signal")
	if Input.is_action_just_pressed("move_right"):
		applied_force = Vector2(x, -y)
	else:
		applied_force = Vector2()
	if Input.is_action_just_pressed("move_left"):
		applied_force = Vector2(-x, -y)


