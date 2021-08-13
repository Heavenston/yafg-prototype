extends Resource
class_name ItemInfo

export(String) var name: String
export(Texture) var texture: Texture
export(PackedScene) var place_scene: PackedScene

func _init(p_name = "", p_texture = null, p_place_scene = null):
	name = p_name
	texture = p_texture
	place_scene = p_place_scene
