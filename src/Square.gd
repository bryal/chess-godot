@tool
class_name Square
extends Node2D

@export var white: bool:
	set(w): white = w; queue_redraw()

@export var color_white: Color:
	set(c): color_white = c; queue_redraw()
@export var color_black: Color:
	set(c): color_black = c; queue_redraw()
@export var color_hover: Color:
	set(c): color_hover = c; queue_redraw()
@export var color_pressed: Color:
	set(c): color_pressed = c; queue_redraw()

var hover: bool = false:
	set(h): hover = h; queue_redraw()
var pressed: bool = false:
	set(p): pressed = p; queue_redraw()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _draw():
	var shape: CollisionShape2D = get_child(0)
	var rect: Rect2 = shape.shape.get_rect()
	var color = color_white if white else color_black
	if pressed:
		color = color.blend(color_pressed)
	elif hover:
		color = color.blend(color_hover)
	draw_rect(rect, color)

func _on_mouse_entered():
	hover = true

func _on_mouse_exited():
	hover = false
	pressed = false

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		var mevent: InputEventMouseButton = event as InputEventMouseButton
		pressed = mevent.pressed
