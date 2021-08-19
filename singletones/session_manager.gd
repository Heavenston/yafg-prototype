extends Node

signal inventory_change(slots)

var player_inventory: Array = ["crate", "crate", "crate", "crate", "crate"]
var player_inventory_size: int = 10

func give_item(item_id: String) -> bool:
	var item_info = ItemManager.get_item(item_id)
	if not is_instance_valid(item_info):
		printerr("Invalid item id")
	
	if player_inventory.size() >= player_inventory_size:
		return false
	player_inventory.append(item_id)
	emit_signal("inventory_change", [player_inventory.size() - 1])
	print("Added an item to the player inventory")
	return true

func remove_item(slot: int):
	player_inventory.remove(slot)
	
	emit_signal("inventory_change", range(0, player_inventory_size))
