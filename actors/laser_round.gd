extends CharacterBody2D


@export var speed: float = 5000.0

func _physics_process(delta: float) -> void:
	velocity = Vector2.UP.rotated(rotation) * speed
	move_and_slide()
	var collisionInfo := get_last_slide_collision()
	if collisionInfo != null:
		var collider := collisionInfo.get_collider()
		if collider is ResNode:
			collider.emit_signal("destroyed", collider)
		queue_free()
