extends Resource
class_name ItemInfo

export(String) var id: String = ""
export(String) var name: String = ""
export(String, MULTILINE) var description: String = ""

export(Texture) var texture: Texture = null
export(PackedScene) var place_scene: PackedScene = null
export(Vector3) var photo_scale: Vector3 = Vector3.ONE
