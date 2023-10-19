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
	func _init(piece_: Piece.Role, src_: Vector2i, move_: Move):
		piece = piece_
		src = src_
		move = move_
class HistPromotion extends HistMove:
	var prom: Piece.Role
	func _init(orig: Piece.Role, new: Piece.Role, src_: Vector2i, move_: Move):
		super(orig, src_, move_)
		prom = new

var last_move: HistMove = null

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

		var piece = scene_piece.instantiate()
		piece.white = white
		piece.role = role
		piece.unmoved = true
		square_by_algebraic(pos).add_child(piece)

func select_square(sq: Square):
	if get_parent().paused:
		return
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
		for move in Board.piece_moves(src.loc, current_board_state(), last_move):
			square_by_loc(move.dst).target = move

func select_destination(dst: Square):
	var src_piece := selected_piece
	var src: Square = src_piece.get_parent()
	var move := dst.target
	if move == null:
		return
	if false: # move is Capture
		pass
	else:
		cancel_move()
		last_move = HistMove.new(src_piece.role, src.loc, move)
		if move is Capture:
			var cmove := move as Capture
			capture_piece(square_by_loc(cmove.capture).get_piece())
		elif move is Castling:
			var cmove := move as Castling
			var passed_over: Vector2i = src.loc + (cmove.dst - src.loc).sign()
			var rook_piece: Piece = square_by_loc(cmove.rook).get_piece()
			rook_piece.reparent(square_by_loc(passed_over), false)
			rook_piece.unmoved = false
		src_piece.reparent(dst, false)
		src_piece.unmoved = false
		if src_piece.role == Piece.Role.PAWN and (dst.loc.y == 0 or dst.loc.y == 7):
			get_parent().promotion_menu(src_piece)
		else:
			get_parent().turn_over()

func select_promotion(piece: Piece, role: Piece.Role):
	last_move = HistPromotion.new(piece.role, role, last_move.src, last_move.move)
	piece.role = role
	get_parent().turn_over()
	get_parent().paused = false

func capture_piece(piece: Piece):
	piece.get_parent().remove_child(piece)
	piece.queue_free()

func cancel_move():
	if get_parent().paused:
		return
	if selected_piece != null:
		selected_piece = null
		for square in squares:
			square.selected = false
			square.target = null

static func piece_moves(piece_loc: Vector2i, board_st: BoardState, prev: HistMove) -> Array[Move]:
	var moves := reckless_piece_moves(piece_loc, board_st, prev)
	var piece := board_st.get_piece(piece_loc)
	for i in range(moves.size()-1, -1, -1):
		var hmove := HistMove.new(piece.role, piece_loc, moves[i])
		if !threats_to_king(piece.white, board_st.with_move(hmove), hmove).is_empty():
			moves.remove_at(i)
	return moves

# All legal moves, except that they may threaten their own king
static func reckless_piece_moves(piece_loc: Vector2i, board_st: BoardState, prev: HistMove) -> Array[Move]:
	var moves: Array[Move] = []
	var piece := board_st.get_piece(piece_loc)
	if piece == null:
		return moves
	match piece.role: # lots of todo
		Piece.Role.KING:
			add_king_moves(moves, piece_loc, board_st, prev)
		Piece.Role.QUEEN:
			add_rook_moves(moves, piece_loc, board_st)
			add_bishop_moves(moves, piece_loc, board_st)
		Piece.Role.BISHOP:
			add_bishop_moves(moves, piece_loc, board_st)
		Piece.Role.KNIGHT:
			add_knight_moves(moves, piece_loc, board_st)
		Piece.Role.ROOK:
			add_rook_moves(moves, piece_loc, board_st)
		Piece.Role.PAWN:
			add_pawn_moves(moves, piece_loc, board_st, prev)
	return moves

static func add_king_moves(moves: Array[Move], src: Vector2i, board: BoardState, prev: HistMove) -> void:
	const deltas := orthogonal_dirs + diagonal_dirs
	for delta in deltas:
		var move := jump_move(src, src + delta, board)
		if move != null:
			moves.push_back(move)

	# Castling
	var psrc := board.get_piece(src)
	var y0 := 0 if psrc.white else 7
	if board.ever_moved(src):
		return
	assert(src.x == 4 or src.y == y0)
	for rook in [Vector2i(0, y0), Vector2i(7, y0)]:
		if board.ever_moved(rook):
			continue
		var prook := board.get_piece(rook)
		if prook == null or prook.role != Piece.Role.ROOK:
			continue
		var dx: int = sign(rook.x - src.x)
		if range(src.x + dx, rook.x, dx).any(func(x: int) -> bool:
			return board.get_piece(Vector2i(x, y0)) != null
		):
			continue
		var dst: Vector2i = src + (rook - src).sign() * 2
		moves.push_back(Castling.new(dst, rook))

static func add_knight_moves(moves: Array[Move], src: Vector2i, board: BoardState) -> void:
	const deltas := [
		Vector2i( 2,  1), Vector2i( 2, -1),
		Vector2i(-2,  1), Vector2i(-2, -1),
		Vector2i( 1,  2), Vector2i(-1,  2),
		Vector2i( 1, -2), Vector2i(-1, -2)
	]
	for delta in deltas:
		var move := jump_move(src, src + delta, board)
		if move != null:
			moves.push_back(move)

static func add_rook_moves(moves: Array[Move], src: Vector2i, board: BoardState) -> void:
	for dir in orthogonal_dirs:
		var dst := src
		while true:
			dst += dir
			var move := jump_move(src, dst, board)
			if move == null:
				break
			moves.push_back(move)
			if move is Capture:
				break

static func add_bishop_moves(moves: Array[Move], src: Vector2i, board: BoardState) -> void:
	for dir in diagonal_dirs:
		var dst := src
		while true:
			dst += dir
			var move := jump_move(src, dst, board)
			if move == null:
				break
			moves.push_back(move)
			if move is Capture:
				break

static func add_pawn_moves(moves: Array[Move], src: Vector2i, board: BoardState, prev: HistMove) -> void:
	var psrc := board.get_piece(src)
	var dy := 1 if psrc.white else -1
	var move1 := jump_move(src, src + Vector2i(0, dy), board)
	if move1 is Capture:
		move1 = null
	else:
		moves.push_back(move1)
	var move2 := jump_move(src, src + Vector2i(0, 2 * dy), board)
	if move1 != null and move2 != null and not (move2 is Capture) and src.y == (1 if psrc.white else 6):
		moves.push_back(move2)

	for dx in [-1, 1]:
		var move := jump_move(src, src + Vector2i(dx, dy), board)
		if move == null:
			continue
		if move is Capture:
			moves.push_back(move)

		if prev == null:
			continue
		if (
			prev.piece != Piece.Role.PAWN or
			prev.src != src + Vector2i(dx, 2 * dy) or
			prev.move.dst != src + Vector2i(dx, 0)
		):
			continue
		moves.push_back(Capture.new(move.dst, prev.move.dst))

const orthogonal_dirs := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const diagonal_dirs := [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]

static func jump_move(src: Vector2i, dst: Vector2i, board: BoardState) -> Move:
	if !in_bounds(dst):
		return null
	var psrc := board.get_piece(src)
	var pdst := board.get_piece(dst)
	if pdst == null:
		return Move.new(dst)
	if psrc.white == pdst.white:
		return null
	return Capture.new(dst, dst)

static func threats_to_king(king_white: bool, board: BoardState, prev: HistMove) -> Array[Vector2i]:
	var threats: Array[Vector2i] = []
	var king_loc := Vector2i.LEFT
	for x in 8:
		for y in 8:
			var p := board.get_piece(Vector2i(x, y))
			if p != null and p.role == Piece.Role.KING and p.white == king_white:
				king_loc = Vector2i(x, y)
	assert(king_loc != Vector2i.LEFT)
	for x in 8:
		for y in 8:
			var src := Vector2i(x, y)
			var psrc := board.get_piece(src)
			if psrc == null or psrc.white == king_white:
				continue
			for move in reckless_piece_moves(src, board, prev):
				if move is Capture and move.capture == king_loc:
					threats.push_back(src)
					break
	return threats

func current_board_state() -> BoardState:
	var st := BoardState.new()
	for ix in 64:
		var piece := squares[ix].get_piece()
		if piece != null:
			if piece.unmoved:
				st.place_unmoved_piece(Board.ix_to_loc(ix), PieceLite.new(piece.white, piece.role))
			else:
				st.place_moved_piece(Board.ix_to_loc(ix), PieceLite.new(piece.white, piece.role))
	return st

class BoardState:
	# each byte is a square, optionally with a piece (role & color)
	# 0xFF => no piece
	# highest bit set => white, unset => black
	# second highest bit set => piece hasn't ever moved
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
		return PieceLite.new(sq & 0x80, sq & 0x3F)

	func duplicate() -> BoardState:
		return BoardState.new(squares.duplicate())

	func remove_piece(loc: Vector2i):
		squares[Board.loc_to_ix(loc)] = 0xFF

	func place_moved_piece(loc: Vector2i, piece: PieceLite):
		squares[Board.loc_to_ix(loc)] = ((1<<7) if piece.white else 0) | (0<<6) | piece.role

	func place_unmoved_piece(loc: Vector2i, piece: PieceLite):
		squares[Board.loc_to_ix(loc)] = ((1<<7) if piece.white else 0) | (1<<6) | piece.role

	func ever_moved(loc: Vector2i) -> bool:
		return (squares[Board.loc_to_ix(loc)] & 0x40) == 0

	func move_piece(src: Vector2i, dst: Vector2i):
		place_moved_piece(dst, get_piece(src))
		remove_piece(src)

	func with_move(move: HistMove) -> BoardState:
		var board := self.duplicate()
		board.apply_move(move)
		return board

	func apply_move(hmove: HistMove) -> void:
		var src := hmove.src
		var move := hmove.move
		if move is Capture:
			remove_piece(move.capture)
		elif move is Castling:
			var passed_over: Vector2i = src + (move.dst - src).sign()
			move_piece(move.rook, passed_over)
		var piece := get_piece(src)
		remove_piece(src)
		place_moved_piece(move.dst, PieceLite.new(piece.white, hmove.prom) if hmove is HistPromotion else piece)

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
class Castling extends Move:
	var rook: Vector2i
	func _init(dst_: Vector2i, rook_: Vector2i):
		super(dst_)
		rook = rook_

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

func _process(_delta):
	pass

func _unhandled_input(event):
	if event is InputEventMouseButton:
		var mevent := event as InputEventMouseButton
		if mevent.button_index == MOUSE_BUTTON_RIGHT and mevent.pressed:
			cancel_move()
