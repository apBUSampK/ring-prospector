extends Label

func _process(_delta: float) -> void:
	visible = get_parent().is_current()
	set_text("FPS " + str(Engine.get_frames_per_second()))
