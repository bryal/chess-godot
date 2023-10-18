@tool
class_name Square
extends Node2D

var loc: Vector2i

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
@export var color_selected: Color:
	set(c): color_selected = c; queue_redraw()
@export var color_destination: Color:
	set(c): color_destination = c; queue_redraw()

var hover: bool = false:
	set(x): hover = x; queue_redraw()
var pressed: bool = false:
	set(x): pressed = x; queue_redraw()
var selected: bool = false:
	set(x): selected = x; queue_redraw()
var target: Board.Move = null:
	set(x): target = x; queue_redraw()

func get_piece() -> Piece:
	"Returns null if square is not occupied"
	return get_node_or_null("Piece")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _draw():
	var shape: CollisionShape2D = get_child(0)
	var rect := shape.shape.get_rect()
	var color = color_white if white else color_black

	if target:
		color = color.blend(color_destination)
	elif selected:
		color = color.blend(color_selected)

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

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		var mevent := event as InputEventMouseButton
		pressed = mevent.pressed
		if mevent.button_index == MOUSE_BUTTON_LEFT and not mevent.pressed:
			get_parent().select_square(self)
