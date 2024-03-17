extends Area2D

var velocity = Vector2(1,1) * 500
var ang = 2*PI
enum STATE {INACTIVE, ACTIVE, HOOKED, RETURN}
var hook_state = STATE.INACTIVE
var active_hook_duration = 0

##### TO DO: ######   
# visual link between player and hook
##### ------ ######

func _ready():
	get_node("../Player").connect("hook_launch", self, "shoot")
	get_node("../Player").connect("release_signal", self, "release")

func _process(delta):
	var direction = Vector2()
	var max_hook_duration = 40
	match hook_state:
		STATE.INACTIVE:
			pass
		STATE.HOOKED:
			pass
		STATE.ACTIVE: 
			direction.x = velocity.x * cos(ang)
			direction.y = velocity.y * sin(ang)
			position += direction * delta
			
			active_hook_duration += 1
			if active_hook_duration >= max_hook_duration:
				self.switch_to_return()
		STATE.RETURN:
			var player = get_node("../Player")
			ang = position.angle_to_point(player.position)
			
			set_global_rotation(ang)
			direction.x = velocity.x * cos(ang)
			direction.y = velocity.y * sin(ang)
			position -= direction*delta

func shoot(mouse_pos, player_pos):
	if(hook_state == STATE.INACTIVE || hook_state == STATE.HOOKED):
		self.switch_to_active()
		ang = mouse_pos.angle_to_point(player_pos)
		set_global_position(player_pos)
		set_global_rotation(ang)
		active_hook_duration = 0

func _on_Hook_body_entered(body):
	if(body == get_node("../Player") && hook_state == STATE.RETURN):
		self.switch_to_inactive()
	if(body != get_node("../Player")):
		self.switch_to_hooked()

func release():
	if(hook_state == STATE.HOOKED):
		self.switch_to_inactive()

func switch_to_inactive():
	visible = false
	hook_state = STATE.INACTIVE

func switch_to_active():
	visible = true
	hook_state = STATE.ACTIVE

func switch_to_hooked():
	hook_state = STATE.HOOKED

func switch_to_return():
	hook_state = STATE.RETURN


