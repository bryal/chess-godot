@tool
extends Node2D

var scene_square = preload("res://scenes/Square.tscn")

var squares: Array[Square]

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 8:
		for j in 8:
			var s = scene_square.instantiate()
			s.position = Vector2(-350 + j * 100, -350 + i * 100)
			s.white = (i % 2 == 0) == (j % 2 == 0)
			squares.push_back(s)
			add_child(s)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
