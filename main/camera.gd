extends Camera2D

var pan_speed = 400
var pan_speed_delta = 50
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.is_action_pressed("ui_left"):
		position.x -= pan_speed * delta
	if Input.is_action_pressed("ui_right"):
		position.x += pan_speed * delta
	if Input.is_action_pressed("ui_up"):
		position.y -= pan_speed * delta
	if Input.is_action_pressed("ui_down"):
		position.y += pan_speed * delta

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_EQUAL:
			pan_speed += pan_speed_delta
		if event.keycode == KEY_MINUS:
			pan_speed -= pan_speed_delta
			if pan_speed < 0:
				pan_speed = 0
