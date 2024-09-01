extends Node2D


const ResNode = preload("res://asteroid/ResNode.tscn")
const Piece = preload("res://asteroid/Piece.tscn")
var allLumps : Array[RigidBody2D]


const atlas = preload("res://textures/atlas1.png")
const material_rock = preload("res://asteroid/rock.tres")
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
	polygon.set_name("Polygon")
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
	polygon.set_name("Polygon")
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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(50):
		var asteroid = bulge_gen(26, 250, 20, .3, 100, 6, .6)
		asteroid.set_angular_velocity(randf_range(-1, 1))
		asteroid.set_position(Vector2(randf_range(-4000, 4000), randf_range(-4000, 4000)))
		add_child(asteroid)
		add_lumps(asteroid, 1)
	for i in range(200):
		var asteroid = simple_gen(14, 80, 5, .1)
		asteroid.set_angular_velocity(randf_range(-1, 1))
		asteroid.set_position(Vector2(randf_range(-4000, 4000), randf_range(-4000, 4000)))
		add_child(asteroid)

class _asteroidSide:
	const lumpLength := 60.0
	
	var start : Vector2
	var end : Vector2
	var side : Vector2
	var max_lump_count : int
	var assigned_lump_count : int
	
	func _init(start : Vector2, end : Vector2) -> void:
		self.start = start
		self.end = end
		self.side = end - start
		self.max_lump_count = int(side.length() / lumpLength)
	
	func get_lumps() -> Array[RigidBody2D]:
		var lumps : Array[RigidBody2D]
		var step = (1.0 / assigned_lump_count) * side
		for i in assigned_lump_count:
			var lump = ResNode.instantiate()
			lump.position = start + step * (i + randf_range(0, (step.length() - lumpLength) /step.length()))
			lump.rotation = step.angle()
			lumps.append(lump)
		return lumps


func add_lumps(asteroid: RigidBody2D, frac: float = .2) -> void:
	var asteroid_path := asteroid.get_path()
	var total_lump_count := 0
	var lumps : Array[RigidBody2D]
	# find polygon
	var polygon: PackedVector2Array = asteroid.find_child("Polygon", false, false).get_polygon()
	# set up sides:
	var sides : Array[_asteroidSide]
	for i in len(polygon):
		sides.append(_asteroidSide.new(polygon[i], polygon[(i + 1) % len(polygon)]))
		total_lump_count += sides[i].max_lump_count
	total_lump_count *= frac
	for side in sides:
		if total_lump_count == 0:
			break
		side.assigned_lump_count = min(side.max_lump_count, total_lump_count)
		total_lump_count -= side.assigned_lump_count
		lumps.append_array(side.get_lumps())
	for lump in lumps:
		asteroid.add_child(lump)
		lump.freeze = true
		lump.destroyed.connect(_on_lump_destroyed)
	allLumps.append_array(lumps)

func _on_lump_destroyed(obj: RigidBody2D) -> void:
	var i := 0
	while i < len(allLumps):
		if allLumps[i] == obj:
			break
		i += 1
	if i < len(allLumps):
		var piece = Piece.instantiate()
		piece.position = allLumps[i].global_position
		piece.rotation = randf_range(0, 2*PI)
		allLumps[i].queue_free()
		allLumps.remove_at(i)
		self.add_child(piece)
