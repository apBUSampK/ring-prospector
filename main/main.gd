extends Node

var Asteroid = preload("res://asteroid/asteroid.gd")
@onready var asteroids = Array()

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	for i in range(50):
		var asteroid = Asteroid.new(Asteroid.GenType.BULGE, [26, 250, 20, .3, 100, 6, .6])
		asteroid.set_angular_velocity(randf_range(-1, 1))
		asteroid.set_position(Vector2(randf_range(-4000, 4000), randf_range(-4000, 4000)))
		asteroids.append(asteroid)
		add_child(asteroid)
	for i in range(200):
		var asteroid = Asteroid.new(Asteroid.GenType.SIMPLE, [14, 80, 5, .1])
		asteroid.set_angular_velocity(randf_range(-1, 1))
		asteroid.set_position(Vector2(randf_range(-4000, 4000), randf_range(-4000, 4000)))
		asteroids.append(asteroid)
		add_child(asteroid)


func _input(event):
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_ESCAPE:
		get_tree().quit()
