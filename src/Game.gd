extends Node2D

const scene_promotion_menu := preload("res://scenes/PromotionMenu.tscn")

var white_turn: bool:
	set(w): white_turn = w; $TurnLabel.text = turn_text()
var paused: bool = false:
	set(x): paused = x; $TurnLabel.text = "" if x else turn_text()

func turn_text():
	return "[center]" + ("White" if white_turn else "Black") + "[/center]"

func turn_over():
	white_turn = !white_turn

func promotion_menu(piece: Piece):
	paused = true
	var menu := scene_promotion_menu.instantiate()
	menu.position -= menu.size * menu.scale / 2.0
	menu.piece = piece
	add_child(menu)

# Called when the node enters the scene tree for the first time.
func _ready():
	white_turn = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
