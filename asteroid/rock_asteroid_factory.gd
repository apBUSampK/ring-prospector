extends RefCounted

var atlas = preload("res://textures/atlas1.png")
var material_rock = preload("res://asteroid/rock.tres")
var a_size = atlas.get_size()[0]

func simple_gen(v: int, r0: float, dr: float, dphi: float) -> RigidBody2D:
	var phi_step = 2 * PI / v
	dphi *= phi_step
	var poly_array = PackedVector2Array()
	for i in range(v):
		var r_delta = randfn(0, dr)
		var phi_delta = phi_step + randf_range(-dphi, dphi)
		r_delta = r_delta if abs(r_delta) < phi_delta * r0 / 3 else phi_delta * r0 / 3 * sign(r_delta)
		var phi = phi_delta + phi_step * (i - 1)
		var r = r0 + r_delta
		poly_array.append(Vector2(r * cos(phi), r * sin(phi)))
	var asteroid = RigidBody2D.new()
	var cpolygon = CollisionPolygon2D.new()
	var polygon = Polygon2D.new()
	cpolygon.set_polygon(poly_array)
	polygon.set_polygon(_bezier_t(poly_array, .8, .16).tessellate(2))
	polygon.set_texture(atlas)
	polygon.set_texture_offset(Vector2(randf_range(0, a_size), randf_range(0, a_size)))
	polygon.set_texture_repeat(CanvasItem.TEXTURE_REPEAT_ENABLED)
	asteroid.set_mass(r0**3)
	asteroid.set_physics_material_override(material_rock)
	asteroid.add_child(cpolygon)
	asteroid.add_child(polygon)
	return asteroid


func bulge_gen(v: int, r0: float, dr: float, dphi: float, bulk_r: float, size: int, incl_size: float) -> RigidBody2D:
	var phi_step = 2 * PI / v
	dphi *= phi_step
	incl_size = incl_size * size / 2
	var bulk_dr = bulk_r / incl_size
	var poly_array = PackedVector2Array()
	var offset = Vector2(cos(size * phi_step / 2), sin(size * phi_step / 2)) * bulk_r * size / v / 2
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
	var asteroid = RigidBody2D.new()
	var cpolygon = CollisionPolygon2D.new()
	var polygon = Polygon2D.new()
	cpolygon.set_polygon(poly_array)
	polygon.set_polygon(_bezier_t(poly_array, .8, .16).tessellate(2))
	polygon.set_texture(atlas)
	polygon.set_texture_offset(Vector2(randf_range(0, a_size), randf_range(0, a_size)))
	polygon.set_texture_repeat(CanvasItem.TEXTURE_REPEAT_ENABLED)
	asteroid.set_mass((r0**2 + (r0 + bulk_r * size / v / 2)**2)**1.5)
	asteroid.set_physics_material_override(material_rock)
	asteroid.add_child(cpolygon)
	asteroid.add_child(polygon)
	return asteroid


func _bezier_t(arr: PackedVector2Array, cl: float, c_d: float) -> Curve2D:
	var _cl = 1 - cl
	var curve = Curve2D.new()
	for i in range(len(arr) - 1):
		var curr = arr[i]
		var prev = arr[i - 1]
		var next = arr[i + 1]
		curve.add_point(cl * curr + _cl * prev, c_d * (prev - curr), c_d * (curr - prev))
		curve.add_point(cl * curr + _cl * next, c_d * (curr - next), c_d * (next - curr))
	curve.add_point(cl * arr[-1] + _cl * arr[-2], c_d * (arr[-2] - arr[-1]), c_d * (arr[-1] - arr[-2])) #last point
	curve.add_point(cl * arr[-1] + _cl * arr[0], c_d * (arr[-1] - arr[0]), c_d * (arr[0] - arr[-1]))
	return curve
