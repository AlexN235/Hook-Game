extends Node

var Hook = preload("res://Hook.tscn")
var mover = load("res://MoverPair.cs")

var portal
var hook
var player_pos
var mouse_pos
var hook_angle

# Called when the node enters the scene tree for the first time.
func _ready():
	var s = Vector2(500, 148)
	var e = Vector2(632, 148)
	portal = $MoverPair
	portal.set_entrance_position(s)
	portal.set_exit_position(e)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func create_hook(p_pos, m_pos):
	hook = Hook.instantiate()
	add_child(hook)
	player_pos = p_pos
	mouse_pos = m_pos
	
	hook.global_position = player_pos
	hook_angle = m_pos.angle_to_point(p_pos)
	hook.set_angle(hook_angle)
	get_node("Hook").connect("hit_detected",Callable(self,"_hook_hit_detected"))

func _hook_hit_detected(hook_pos, body_id, body):
	var player = get_node("PlayerChar")
	player.hook_hit_detected(hook_pos)
	hook.queue_free()
	
	

