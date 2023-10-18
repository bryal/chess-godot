@tool
class_name Board
extends Node2D

const scene_square := preload("res://scenes/Square.tscn")
const scene_piece := preload("res://scenes/Piece.tscn")

var squares: Array[Square]

var selected_piece: Piece = null

class HistMove:
	var piece: Piece.Role
	var src: Vector2i
	var move: Move

var history: Array[HistMove] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 8:
		for j in 8:
			var s := scene_square.instantiate()
			s.loc = Vector2i(j, i)
			s.position = Vector2(-350 + j * 100, 350 - i * 100)
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
		# print("white: %s, role: %s, pos: %s" % [white, role, pos])

		var piece = scene_piece.instantiate()
		piece.white = white
		piece.role = role
		square_by_algebraic(pos).add_child(piece)

func select_square(sq: Square):
	if selected_piece != null:
		select_destination(sq)
	else:
		select_source(sq)

func select_source(src: Square):
	var src_piece: Piece = src.get_piece()
	if src_piece == null or src_piece == selected_piece or src_piece.white != get_parent().white_turn:
		cancel_move()
	else:
		cancel_move()
		selected_piece = src_piece
		src.selected = true
		for move in Board.piece_moves(src.loc, current_board_state(), history):
			square_by_loc(move.dst).target = move

func select_destination(dst: Square):
	var src_piece := selected_piece
	var move := dst.target
	if move == null:
		return
	if false: # move is Capture
		pass
	else:
		cancel_move()
		if move is Capture:
			var cmove: Capture = move as Capture
			capture_piece(square_by_loc(cmove.capture).get_piece())
		src_piece.reparent(dst, false)
		src_piece.queue_redraw()
		get_parent().turn_over()

func capture_piece(piece: Piece):
	piece.get_parent().remove_child(piece)
	piece.queue_free()

func cancel_move():
	if selected_piece != null:
		selected_piece = null
		for square in squares:
			square.selected = false
			square.target = null

static func piece_moves(piece_loc: Vector2i, board_st: BoardState, _hist: Array[HistMove]) -> Array[Move]:
	var moves: Array[Move] = []
	var piece := board_st.get_piece(piece_loc)
	if piece == null:
		return moves
	match piece.role: # lots of todo
		Piece.Role.KNIGHT:
			add_knight_moves(moves, piece_loc, board_st)
		_:
			pass
	for i in range(moves.size()-1, -1, -1):
		if threatens_king(moves[i]):
			moves.remove_at(i)
	return moves

static func add_knight_moves(moves: Array[Move], src: Vector2i, board: BoardState) -> void:
	const deltas := [
		Vector2i( 2,  1), Vector2i( 2, -1),
		Vector2i(-2,  1), Vector2i(-2, -1),
		Vector2i( 1,  2), Vector2i(-1,  2),
		Vector2i( 1, -2), Vector2i(-1, -2)
	]
	for delta in deltas:
		var dst: Vector2i = src + delta
		if !in_bounds(dst):
			continue
		var move := jump_move(src, dst, board)
		if move != null:
			moves.push_back(move)

static func jump_move(src: Vector2i, dst: Vector2i, board: BoardState) -> Move:
	var psrc := board.get_piece(src)
	var pdst := board.get_piece(dst)
	if pdst == null:
		return Move.new(dst)
	if psrc.white == pdst.white:
		return null
	return Capture.new(dst, dst)

static func threatens_king(_move: Move) -> bool:
	return false # todo

func current_board_state() -> BoardState:
	var st := BoardState.new()
	for ix in 64:
		var piece := squares[ix].get_piece()
		if piece != null:
			st.place_piece(Board.ix_to_loc(ix), piece.white, piece.role)
	return st

class BoardState:
	# each byte is a square, optionally with a piece (role & color)
	# 0xFF => no piece
	# highest bit set => white, unset => black
	# rest is role
	var squares: PackedByteArray

	func _init(xs:PackedByteArray=[]):
		squares = xs
		if squares.size() != 64:
			squares.resize(64)
			squares.fill(0xFF)

	func get_piece(loc: Vector2i) -> PieceLite:
		var sq: int = squares[Board.loc_to_ix(loc)]
		if sq == 0xFF:
			return null
		return PieceLite.new(sq & 0x80, sq & 0x7F)

	func duplicate() -> BoardState:
		return BoardState.new(squares.duplicate())

	func remove_piece(loc: Vector2i):
		squares[Board.loc_to_ix(loc)] = 0xFF

	func place_piece(loc: Vector2i, white: bool, role: Piece.Role):
		squares[Board.loc_to_ix(loc)] = role | (0x80 if white else 0x00)

class PieceLite:
	var white: bool
	var role: Piece.Role

	func _init(w: bool, r: Piece.Role):
		white = w
		role = r

class Move:
	var dst: Vector2i
	func _init(dst_: Vector2i):
		dst = dst_
class Capture extends Move:
	var capture: Vector2i
	func _init(dst_: Vector2i, capture_: Vector2i):
		super(dst_)
		capture = capture_

# class Castling extends Move
# class Promotion extends Move

static func in_bounds(loc: Vector2) -> bool:
	return loc == loc.clamp(Vector2i(0, 0), Vector2i(7, 7))

func square_by_algebraic(s: String) -> Square:
	var file := s.unicode_at(0) - "a".unicode_at(0)
	var rank := s.unicode_at(1) - "1".unicode_at(0)
	return square_by_loc(Vector2i(file, rank))

func square_by_loc(loc: Vector2i) -> Square:
	return squares[Board.loc_to_ix(loc)]

static func loc_to_ix(loc: Vector2i) -> int:
	return loc.y * 8 + loc.x

static func ix_to_loc(ix: int) -> Vector2i:
	return Vector2i(ix % 8, ix / 8)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _unhandled_input(event):
	if event is InputEventMouseButton:
		var mevent := event as InputEventMouseButton
		if mevent.button_index == MOUSE_BUTTON_RIGHT and mevent.pressed:
			cancel_move()
