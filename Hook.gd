extends Area2D

var velocity
var ang
var duration
var player
var direction : Vector2

signal hit_detected(hit_location)

### Possible Problems ###
# Detection is made by a traveling body. If that body is moving too fast it can skip areas
# it should detect. Ideally want to be able to detect a hit instantly but can not happen in
# this implementaion. 
# Best to try to find a new implementation that is in constant detection.
###

func _ready():
	player = get_parent()
	velocity = Vector2(1,1) * 1000
	ang = PI*5/8
	duration = 10

func _process(delta):
	if(duration == 0):
		queue_free()
	direction.x = velocity.x * cos(ang) * player.player_direction
	direction.y = velocity.y * sin(ang)
	position -= direction * delta
	duration -= 1

func _on_Hook_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	emit_signal("hit_detected", global_position)
