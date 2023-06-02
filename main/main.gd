extends Node2D

var Asteroid = preload("res://asteroid/asteroid.gd")
@onready var asteroids = Array()

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	for i in range(30):
		var asteroid = Asteroid.new()
		asteroid.init(6, 25, 0, 0)
		asteroid.set_angular_velocity(randf_range(-1, 1))
		asteroid.set_axis_velocity(Vector2(randfn(0, 50), randfn(0, 50)))
		asteroid.set_position(Vector2(randf_range(100, 1820), randf_range(100, 980)))
		asteroids.append(asteroid)
		add_child(asteroid)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
