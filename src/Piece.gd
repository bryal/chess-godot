@tool
class_name Piece
extends Sprite2D

@export var role: Role:
	set(r): role = r; update_sprite()
@export var white: bool:
	set(w): white = w; update_sprite()

enum Role {
	KING,
	QUEEN,
	BISHOP,
	KNIGHT,
	ROOK,
	PAWN
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_sprite():
	frame_coords = Vector2i(role, 0 if white else 1)
	queue_redraw()
