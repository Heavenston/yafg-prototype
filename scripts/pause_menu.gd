extends Control

var last_mouse_state

func _input(event):

	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = not get_tree().paused
		var pause_state = get_tree().paused
		visible = pause_state
		if pause_state:
			last_mouse_state = Input.get_mouse_mode()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(last_mouse_state)
