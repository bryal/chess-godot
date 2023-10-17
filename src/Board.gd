@tool
extends Node2D

const scene_square := preload("res://scenes/Square.tscn")
const scene_piece := preload("res://scenes/Piece.tscn")

var squares: Array[Square]
var pieces: Array[Piece]

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 8:
		for j in 8:
			var s := scene_square.instantiate()
			s.position = Vector2(-350 + j * 100, -350 + i * 100)
			s.white = (i % 2 == 0) == (j % 2 == 0)
			squares.push_back(s)
			add_child(s)

	const initial_positions = [
		[true, Piece.Role.KING,    "e1"],
		[true, Piece.Role.QUEEN,   "d1"],
		[true, Piece.Role.BISHOP,  "c1"],
		[true, Piece.Role.BISHOP,  "f1"],
		[true, Piece.Role.KNIGHT,  "b1"],
		[true, Piece.Role.KNIGHT,  "g1"],
		[true, Piece.Role.ROOK,    "a1"],
		[true, Piece.Role.ROOK,    "h1"],
		[true, Piece.Role.PAWN,    "a2"],
		[true, Piece.Role.PAWN,    "b2"],
		[true, Piece.Role.PAWN,    "c2"],
		[true, Piece.Role.PAWN,    "d2"],
		[true, Piece.Role.PAWN,    "e2"],
		[true, Piece.Role.PAWN,    "f2"],
		[true, Piece.Role.PAWN,    "g2"],
		[true, Piece.Role.PAWN,    "h2"],
		[false, Piece.Role.KING,   "e8"],
		[false, Piece.Role.QUEEN,  "d8"],
		[false, Piece.Role.BISHOP, "c8"],
		[false, Piece.Role.BISHOP, "f8"],
		[false, Piece.Role.KNIGHT, "b8"],
		[false, Piece.Role.KNIGHT, "g8"],
		[false, Piece.Role.ROOK,   "a8"],
		[false, Piece.Role.ROOK,   "h8"],
		[false, Piece.Role.PAWN,   "a7"],
		[false, Piece.Role.PAWN,   "b7"],
		[false, Piece.Role.PAWN,   "c7"],
		[false, Piece.Role.PAWN,   "d7"],
		[false, Piece.Role.PAWN,   "e7"],
		[false, Piece.Role.PAWN,   "f7"],
		[false, Piece.Role.PAWN,   "g7"],
		[false, Piece.Role.PAWN,   "h7"],
	]
	for initial_position in initial_positions:
		var white: bool = initial_position[0]
		var role: Piece.Role = initial_position[1]
		var pos: String = initial_position[2]
		print("white: %s, role: %s, pos: %s" % [white, role, pos])

		var piece = scene_piece.instantiate()
		pieces.push_back(piece)
		piece.white = white
		piece.role = role
		square_by_algebraic(pos).add_child(piece)

func square_by_algebraic(s: String) -> Square:
	var file := s.unicode_at(0) - "a".unicode_at(0)
	var rank := s.unicode_at(1) - "1".unicode_at(0)
	return squares[(7 - rank) * 8 + file]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
