extends Node

# Handle controller switching
# Controller interface (everthing is optional):
#   on_enable() -> void
#     Called after transitioning
#   on_disable() -> void
#     called before transitioning
#   get_camera() -> Camera
#     Used for transition between controllers

const CAMERA_TRANSITION_DURATION = 1

var controller_queue = []
var is_transitioning = false

func _set_transitioning(val: bool):
	is_transitioning = val

func get_current_controller() -> Node:
	if controller_queue.size() == 0:
		return null
	return controller_queue[controller_queue.size() - 1]

func push(controller: Node):
	if is_transitioning:
		push_error("Can't push or pop controller when transitioning (use is_transitioning property)")
		return
	var last = get_current_controller()
	if last != null and last.has_method("on_disable"):
		last.on_disable()
	controller_queue.push_back(controller) 
	if last != null and controller.has_method("get_camera") and last.has_method("get_camera"):
		var last_camera = last.get_camera()
		var new_camera = controller.get_camera()
		is_transitioning = true
		var tween = CameraManager.change_camera(last_camera, new_camera, CAMERA_TRANSITION_DURATION)
		tween.connect("tween_all_completed", self, "_set_transitioning", [false])
		if controller.has_method("on_enable"):
			tween.connect("tween_all_completed", controller, "on_enable")
	elif controller.has_method("on_enable"):
		controller.on_enable()

func pop():
	if is_transitioning:
		push_error("Can't push or pop controller when transitioning (use is_transitioning property)")
		return
	var last = get_current_controller()
	print(controller_queue.size())
	if last != null:
		controller_queue.pop_back()
		if last.has_method("on_disable"):
			last.on_disable()
	print(controller_queue.size())
	var new = get_current_controller()
	print(last, new)
	if last != null and new != null and last.has_method("get_camera") and new.has_method("get_camera"):
		var last_camera = last.get_camera()
		var new_camera = new.get_camera()
		is_transitioning = true
		var tween = CameraManager.change_camera(last_camera, new_camera, CAMERA_TRANSITION_DURATION)
		tween.connect("tween_all_completed", self, "_set_transitioning", [false])
		if new.has_method("on_enable"):
			tween.connect("tween_all_completed", new, "on_enable")
	elif new != null and new.has_method("on_enable"):
		new.on_enable()
