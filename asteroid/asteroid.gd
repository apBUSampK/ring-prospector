class_name Asteroid extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

enum GenType{
	SIMPLE,
	BULGE
}

func _init(type: GenType, args: Array) -> void:
	var poly_array = PackedVector2Array()	
	match(type):
		GenType.SIMPLE:
			poly_array = _simple_gen(args)
		GenType.BULGE:
			poly_array = _bulge_gen(args)
	var cpolygon = CollisionPolygon2D.new()
	var polygon = Polygon2D.new()
	polygon.set_polygon(poly_array)
	cpolygon.set_polygon(poly_array)
	add_child(polygon)
	add_child(cpolygon)
	
func _simple_gen(args: Array) -> PackedVector2Array:
	var v = args[0]
	var phi_step = 2 * PI / v
	var dphi = args[3] * phi_step
	var r0 = args[1]
	var dr = args[2]
	var poly_array = PackedVector2Array()
	for i in range(v):
		var r_delta = randfn(0, dr)
		var phi_delta = phi_step + randf_range(-dphi, dphi)
		r_delta = r_delta if abs(r_delta) < phi_delta * r0 / 3 else phi_delta * r0 / 3 * sign(r_delta)
		var phi = phi_delta + phi_step * (i - 1)
		var r = r0 + r_delta
		poly_array.append(Vector2(r * cos(phi), r * sin(phi)))
	set_mass(r0**3)
	return poly_array
	
func _bulge_gen(args: Array) -> PackedVector2Array:
	var v = args[0]
	var phi_step = 2 * PI / v
	var dphi = args[3] * phi_step
	var r0 = args[1]
	var dr = args[2]
	var bulk_r = args[4]
	var size = args[5]
	var incl_size = args[6] * size / 2
	var bulk_dr = bulk_r / incl_size
	var poly_array = PackedVector2Array()
	var offset = Vector2(bulk_r * cos(size / 2 * phi_step) / 2, bulk_r * sin(size / 2 * phi_step) / 2)
	for i in range(v):
		var r_delta = randfn(0, dr)
		var phi_delta = phi_step + randf_range(-dphi, dphi)
		r_delta = r_delta if abs(r_delta) < phi_delta * r0 / 3 else phi_delta * r0 / 3 * sign(r_delta)
		var phi = phi_delta + phi_step * (i - 1)
		var r = r0 + r_delta
		if i < size:
			r += bulk_r
			if i <= incl_size:
				r -= (incl_size - i) * bulk_dr
			if i >= size - incl_size:
				r += (size - i - incl_size) * bulk_dr
		poly_array.append(Vector2(r * cos(phi), r * sin(phi)) - offset)
	set_mass((r0**2 + (r0 + bulk_r / 2)**2)**1.5)
	return poly_array
