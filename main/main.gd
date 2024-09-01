extends Node2D


@onready var cameras = [get_node("FreeCamera"), get_node("ShipCamera")]
var cameraCount = 2
var activeCamera = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	cameras[activeCamera].make_current()


func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
		if event.keycode == KEY_C:
			activeCamera = (activeCamera + 1) % cameraCount
			cameras[activeCamera].make_current()
