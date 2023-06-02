class_name Asteroid extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func init(v: int, r0, dr, dphi):
	var phi_step = 2 * PI / v
	dphi *= phi_step
	var poly_array = PackedVector2Array()
	for i in range(v):
		var phi = phi_step * i + randf_range(-dphi, dphi)
		var r = r0 + randfn(0, dr)
		poly_array.append(Vector2(r * cos(phi), r * sin(phi)))
	var cpolygon = CollisionPolygon2D.new()
	var polygon = Polygon2D.new()
	polygon.set_polygon(poly_array)
	cpolygon.set_polygon(poly_array)
	add_child(polygon)
	add_child(cpolygon)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
