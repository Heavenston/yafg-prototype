extends Node

const INTERPOLATION_SPEED = 10.0

func change_camera(from: Camera, to: Camera, duration: float = 1.0) -> Tween:
	var tween = Tween.new()
	add_child(tween)
	
	var transitional_camera: Camera = from.duplicate(0)
	add_child(transitional_camera)
	transitional_camera.current = true
	
	var ea = Tween.EASE_IN_OUT
	var tra = Tween.TRANS_CUBIC
	
	tween.interpolate_property(transitional_camera, "global_transform", from.global_transform, to.global_transform, duration, tra, ea)
	tween.interpolate_property(transitional_camera, "fov", from.fov, to.fov, duration, tra, ea)
	tween.start()
	
	return tween
