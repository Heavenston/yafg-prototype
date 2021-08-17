extends Area
class_name PlacementGhost

var material: SpatialMaterial
var is_valid := false

func _init():
	monitorable = false
	
	material = SpatialMaterial.new()
	material.flags_transparent = true
	material.params_depth_draw_mode = SpatialMaterial.DEPTH_DRAW_ALWAYS
	_set_color(Color.white)

func _set_color(color: Color):
	material.albedo_color = color
	material.albedo_color.a = 0.5

func _physics_process(_delta):
	var overlapping_bodies = get_overlapping_bodies()
	var colliding = false
	var colliding_ground = false
	for body in overlapping_bodies:
		if body.collision_layer & 0b10 == 0:
			colliding = true
		else:
			colliding_ground = true
	
	if colliding or not colliding_ground:
		_set_color(Color.red)
		is_valid = false
	else:
		_set_color(Color.white)
		is_valid = true
