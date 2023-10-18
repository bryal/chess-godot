extends Node2D

var white_turn :bool :
	set(w): white_turn = w; $TurnLabel.text = "[center]" + ("White" if w else "Black") + "[/center]"

# Called when the node enters the scene tree for the first time.
func _ready():
	white_turn = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
