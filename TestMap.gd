extends Node


var portal


# Called when the node enters the scene tree for the first time.
func _ready():
	var s = Vector2(50, 550)
	var e = Vector2(400, 400)
	portal = $MoverPair
	portal.set_entrance_position(s)
	portal.set_exit_position(e)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
