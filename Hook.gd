extends Area2D


var velocity = Vector2(1,1) * 100
var ang = 2*PI
enum STATE {INACTIVE, ACTIVE, HOOKED, RETURN}
var hook_state = STATE.INACTIVE

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().connect("hook_launch", self, "shoot")
	get_parent().connect("release_signal", self, "release")

func _process(delta):
	var direction = Vector2()
	match hook_state:
		STATE.INACTIVE:
			pass
			
		STATE.ACTIVE: 
			direction.x = velocity.x * cos(ang)
			direction.y = velocity.y * sin(ang)
			position += direction * delta
			
		STATE.HOOKED:
			pass
			
		STATE.RETURN:
			pass

func shoot(mouse_pos, player_pos):
	hook_state = STATE.ACTIVE
	ang = mouse_pos.angle_to_point(player_pos)
	set_global_position(player_pos)
	set_global_rotation(ang)

func _on_Hook_body_entered(body):
	hook_state = STATE.HOOKED

func release():
	if(hook_state == STATE.HOOKED):
		hook_state = STATE.INACTIVE
