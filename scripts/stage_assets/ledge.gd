extends Area2D

@export_range(0, 1) var ledge_side = 0
@onready var label = $Label
@onready var collision = $CollisionShape2D
var is_grabbed = false

func _on_body_exited(body):
	is_grabbed = false

func _ready():
	label.text = "LedgeL" if ledge_side == 0 else "LedgeR"
