@tool
extends PanelContainer

var piece: Piece

@export var white: bool:
	set(x): white = x; for p in get_child(0).get_children(): p.white = x

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_gui_input(_event):
	accept_event()
