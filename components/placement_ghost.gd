extends Component

export(Array, NodePath) var _meshes_paths: Array
export(Array, NodePath) var _collisions_paths: Array

func _ready():
	for mesh_path in _meshes_paths:
		assert(get_node(mesh_path) is MeshInstance)
	for col_path in _collisions_paths:
		assert(get_node(col_path) is CollisionShape)

func create() -> PlacementGhost:
	var ghost := PlacementGhost.new()
	
	for mesh_path in _meshes_paths:
		var mesh: MeshInstance = get_node(mesh_path).duplicate(Node.DUPLICATE_USE_INSTANCING)
		mesh.material_override = ghost.material
		ghost.add_child(mesh)
	for col_path in _collisions_paths:
		ghost.add_child(get_node(col_path).duplicate(Node.DUPLICATE_USE_INSTANCING))
	
	return ghost
