extends Area
class_name PlacementGhost

var material: SpatialMaterial
var is_valid := false setget set_is_valid

func _init():
	monitorable = false
	
	material = SpatialMaterial.new()
	material.flags_transparent = true
	material.params_depth_draw_mode = SpatialMaterial.DEPTH_DRAW_ALWAYS

	set_is_valid(is_valid)

func _set_color(color: Color):
	material.albedo_color = color
	material.albedo_color.a = 0.5

func set_is_valid(val: bool):
	is_valid = val
	if is_valid:
		_set_color(Color.white)
	else:
		_set_color(Color.red)


