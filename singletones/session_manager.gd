extends Node

signal inventory_change(slots)

var player_inventory: Array = ["wind_turbine_blade", "wind_turbine_blade", "wind_turbine_blade", "wind_turbine_body", "wind_turbine_head", "wind_turbine_rotor_head"]
var player_inventory_size: int = 10

func has_space_for(amount: int) -> bool:
	if player_inventory_size - player_inventory.size() >= amount:
		return true

	return false

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
