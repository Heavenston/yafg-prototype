extends Control

export(int) var inventory_slot: int = 0
export(bool) var is_selected: bool = false setget set_is_selected

var item_id: String = "" setget set_item

func _ready():
	SessionManager.connect("inventory_change", self, "_on_inventory_change")
	
	set_is_selected(is_selected)

func set_item(id: String):
	item_id = id
	
	var item_info = ItemManager.get_item(id)
	if not is_instance_valid(item_info):
		$MarginContainer/ItemTexture.visible = false
		return
	
	$MarginContainer/ItemTexture.visible = true
	$MarginContainer/ItemTexture.texture = ItemManager.get_item_texture(item_id)

func _on_inventory_change(slots: Array):
	if slots.has(inventory_slot):
		set_item(SessionManager.player_inventory[inventory_slot])

func set_is_selected(value: bool):
	is_selected = value
	
	if is_selected:
		$ColorRect.color = Color.white
	else:
		$ColorRect.color = Color.transparent



