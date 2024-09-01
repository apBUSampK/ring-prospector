class_name ResNode extends RigidBody2D 

signal destroyed(obj: RigidBody2D)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			emit_signal("destroyed", self)
