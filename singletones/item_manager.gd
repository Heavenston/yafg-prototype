extends Node

var _items_cache: Dictionary = {}
var _items_textures_cache: Dictionary = {}

func _ready():
	var files := []
	
	var dir := Directory.new()
	dir.open("res://resources/data/items_info")
	dir.list_dir_begin()
	
	while true:
		var file := dir.get_next()
		if file == "":
			break
		if file.ends_with(".tres"):
			get_item(file.trim_suffix(".tres"))
	
	print("Finished loading items, ", _items_cache.size(), " items loaded")

func _take_item_screenshot_cleanup(photoboot: Viewport, final_texture: ImageTexture, viewport_texture: ViewportTexture):
	yield(VisualServer, "frame_post_draw")
	
	final_texture.create_from_image(viewport_texture.get_data())
	photoboot.queue_free()

func _take_item_screenshot(item: ItemInfo) -> Texture:
	print("Making a photo for item "+item.name)
	var photoboot: Viewport = preload("res://subscenes/photoboot.tscn").instance()

	get_tree().get_root().call_deferred("add_child", photoboot)
	var texture := photoboot.get_texture()
	var item_instance: Spatial = item.place_scene.instance()
	photoboot.get_node("Root").add_child(item_instance)
	item_instance.scale = item.photo_scale
	
	var final_texture := ImageTexture.new()
	_take_item_screenshot_cleanup(photoboot, final_texture, texture)
	
	print("Finished photo for "+item.name)
	return final_texture

func get_item(id: String) -> ItemInfo:
	if _items_cache.has(id):
		return _items_cache.get(id)
	var item: ItemInfo = load("res://resources/data/items_info/"+id+".tres")
	if item == null:
		return null
	_items_cache[id] = item
	return item

func get_item_texture(id: String) -> Texture:
	var item = get_item(id)
	if not is_instance_valid(item):
		printerr("Invalid item id")
		return null
	
	if item.texture == null \
	and item.place_scene != null:
		if _items_textures_cache.has(id):
			return _items_textures_cache[id]
		var texture = _take_item_screenshot(item)
		_items_textures_cache[id] = texture
		return texture
	return item.texture
