extends Node2D

var entrance 
var exit

func _ready():
	entrance = $MapMover
	exit = $MapMoverExit

#func _process(delta):
#	pass

func set_entrance_position(var pos):
	entrance.global_position = pos

func set_exit_position(var pos):
	exit.global_position = pos
