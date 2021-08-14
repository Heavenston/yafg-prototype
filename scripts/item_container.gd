extends Container

export(int) var inventory_slot: int = 0

var item_id: String = "" setget set_item

func _ready():
	SessionManager.connect("inventory_change", self, "_on_inventory_change")

func set_item(id: String):
	item_id = id
	
	var item_info = ItemManager.get_item(id)
	if not is_instance_valid(item_info):
		$ItemTexture.visible = false
		return
	
	$ItemTexture.visible = true
	$ItemTexture.texture = ItemManager.get_item_texture(item_id)

func _on_inventory_change(slots: Array):
	if slots.has(inventory_slot):
		set_item(SessionManager.player_inventory[inventory_slot])
