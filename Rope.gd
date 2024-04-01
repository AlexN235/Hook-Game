extends Node2D

var RopePiece = preload("res://RopePiece.tscn")
var RopeEndPiece = preload("res://RopeEnd.tscn")
var piece_length = 10.0
var rope_parts = []
var rope_points = []
var rope_end_piece

func _process(delta):
	get_rope_points()
	if !rope_points.empty():
		update()

func spawn_rope(var start_pos:Vector2, var end_pos:Vector2):
### Spawns a new rope in the scene based on player position and hook location. ###
	var distance = start_pos.distance_to(end_pos)
	var number_of_segments = round(distance / piece_length)
	var angle = start_pos.angle_to_point(end_pos) - PI/2

	create_end_piece(end_pos)
	create_rope(number_of_segments, rope_end_piece, angle)

func create_end_piece(var end_pos:Vector2):
	rope_end_piece = RopeEndPiece.instance()
	rope_end_piece.global_position = end_pos
	rope_parts.append(rope_end_piece)
	add_child(rope_end_piece)
	
func create_rope(var segment_num, var rope_end_piece, var angle):
	var parent = rope_end_piece
	rope_parts.append(parent)
	for i in segment_num:
		parent = add_piece(parent, 0, angle)
		rope_parts.append(parent)
	
	# Hook to player
	var player = get_node("../Player")
	var endJoint = parent.get_node("C/J")
	endJoint.node_a = parent.get_path()
	endJoint.node_b = player.get_path()

func add_piece(var parent, var id, var angle) -> Object:
### creates a segment of the rope. ###
	var pinJoint = parent.get_node("C/J")
	var piece = RopePiece.instance()
	piece.global_position = pinJoint.global_position
	piece.rotation = angle
	
	# Add to scene
	#piece.parent = self    # confusion between this and "parent" argument?
	add_child(piece)
	
	# Hook joint and piece together
	pinJoint.node_a = parent.get_path()
	pinJoint.node_b = piece.get_path()
	
	return piece

func get_rope_points():
### Get the points where the rope exists. ###
	rope_points = []
	for i in rope_parts:
		rope_points.append(i.global_position)

func _draw():
### Draw the rope. ###
	draw_polyline(rope_points, Color.black)

