extends Component

onready var _color_material := SpatialMaterial.new()
export(Array, NodePath) var mesh_instances = []

func reset():
	set_material(null)

func set_material(material: Material):
	for mesh in mesh_instances:
		(get_node(mesh) as MeshInstance).material_override = material

func set_color(color: Color):
	_color_material.albedo_color = color
	_color_material.flags_unshaded = true
	set_material(_color_material)
