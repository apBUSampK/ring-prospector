extends Node2D

var AsteroidFactory = preload("res://asteroid/rock_asteroid_factory.gd")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var factory = AsteroidFactory.new()
	for i in range(50):
		var asteroid = factory.bulge_gen(26, 250, 20, .3, 100, 6, .6)
		asteroid.set_angular_velocity(randf_range(-1, 1))
		asteroid.set_position(Vector2(randf_range(-4000, 4000), randf_range(-4000, 4000)))
		add_child(asteroid)
	for i in range(200):
		var asteroid = factory.simple_gen(14, 80, 5, .1)
		asteroid.set_angular_velocity(randf_range(-1, 1))
		asteroid.set_position(Vector2(randf_range(-4000, 4000), randf_range(-4000, 4000)))
		add_child(asteroid)


func _input(event):
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_ESCAPE:
		get_tree().quit()
