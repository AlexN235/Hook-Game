extends Area2D

var exit_portal

signal hit_detected

func _ready():
	exit_portal = get_node("../MapMoverExit")

#func _process(delta):
#	pass

func _on_MapMover_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	emit_signal("hit_detected")
