extends Node2D

var player
var entrance 
var exit

func _ready():
	player = get_node("../PlayerChar")
	entrance = $MapMover
	exit = $MapMoverExit
	get_node("MapMover").connect("hit_detected",Callable(self,"_teleport_player"))

#func _process(delta):
#	pass

func set_entrance_position(pos):
	entrance.global_position = pos

func set_exit_position(pos):
	exit.global_position = pos

func _teleport_player():
	player.set_global_position(exit.global_position)
