@tool
extends Node2D

@export var white: bool:
	set(w):
		if white != w:
			white = w
			queue_redraw()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _draw():
	var outer = Rect2(-50, -50, 100, 100)
	var inner = Rect2(-46, -46,  92,  92)
	if white:
		draw_rect(outer, Color(0.75, 0.65, 0.45))
		draw_rect(inner, Color(0.80, 0.72, 0.60))
	else:
		draw_rect(outer, Color(0.25, 0.20, 0.10))
		draw_rect(inner, Color(0.20, 0.15, 0.05))
