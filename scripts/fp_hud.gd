extends Control

var selected_slot: int = 0 setget set_selected_slot
var total_slots: int = 10

func _get_slot(id: int) -> Control:
	var slot: Control = get_node("CenterContainer/PanelContainer/MarginContainer/HBoxContainer/Slot"+String(id + 1))
	assert(is_instance_valid(slot))
	return slot

func set_selected_slot(value: int):
	_get_slot(selected_slot).is_selected = false
	_get_slot(value).is_selected = true
	selected_slot = value

func select_next_slot():
	var new_slot = selected_slot + 1
	if new_slot >= total_slots:
		new_slot = 0
	set_selected_slot(new_slot)

func select_previous_slot():
	var new_slot = selected_slot - 1
	if new_slot < 0:
		new_slot = total_slots - 1
	set_selected_slot(new_slot)
