@tool
extends PanelContainer

@export var piece: Piece:
	set(x): piece = x; for p in $MarginContainer/Pieces.get_children(): p.white = x.white

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_gui_input(_event):
	accept_event()
