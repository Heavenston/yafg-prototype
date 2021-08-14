extends Spatial

export(String) var item_id

func _ready():
	var item_info = ItemManager.get_item(item_id)
	assert(item_info != null)
