@tool
extends TextureRect

var white: bool = true:
	set(x): white = x; update_texture()

@export var role: Piece.Role:
	set(x): role = x; update_texture()

func _ready():
	pass

func _process(_delta):
	pass

func update_texture():
	var w := 2560.0 / 6.0
	var h := 853.0 / 2.0
	texture.region = Rect2(role * w, 0.0 if white else h, w, h)
	queue_redraw()


func _on_gui_input(event):
	if event is InputEventMouseButton:
		var mevent := event as InputEventMouseButton
		if mevent.button_index == MOUSE_BUTTON_LEFT and not mevent.pressed:
			accept_event()
			var root = get_tree().current_scene
			var menu = get_parent().get_parent().get_parent()
			root.remove_child(menu)
			menu.queue_free()
			root.select_promotion(menu.piece, role)
