extends Node

var _body_cache := Dictionary()

func _physics_process(_delta):
	_body_cache = {}

func can_remove_body(body) -> bool:
	if not body.has_node("joints"):
		return false

	var body_cache = {}
	var ignore_list = [body]
	for joint in body.get_node("joints").get_children():
		if is_instance_valid(joint.connected_to):
			if not is_body_grounded(joint.connected_to.get_node("../.."), body_cache, ignore_list):
				return false

	return true

func is_body_grounded(body, ignore_list: Array = [], body_cache: Dictionary = _body_cache):
	if body_cache.has(body):
		return body_cache.get(body)
	ignore_list.append(body)
	var grounded := false

	if body.has_node("joints"):
		for joint in body.get_node("joints").get_children():
			if is_instance_valid(joint.connected_to):
				if joint.joint_id == "object_floor":
					grounded = true
					break
				if not ignore_list.has(joint.connected_to.get_node("../..")):
					if is_body_grounded(joint.connected_to.get_node("../.."), ignore_list, body_cache):
						grounded = true
						break

	body_cache[body] = grounded
	ignore_list.erase(body)
	return grounded

func get_object_placement(joint: Spatial, target_joint: Spatial, rotation: float = 0, normal: Vector3 = Vector3.ZERO, point: Vector3 = Vector3.ZERO) -> Transform:
	var target_view := Vector3.FORWARD
	var target_up := Vector3.UP
	var final_position := Vector3.ZERO
	if target_joint.global_placement:
		target_view = normal
		target_up = Vector3(1, 0, 0)
		final_position = point
	else:
		target_view = -target_joint.global_transform.basis.xform(Vector3.FORWARD)
		target_up = target_joint.global_transform.basis.xform(Vector3.UP)
		final_position = target_joint.global_transform.origin

	if target_joint.allow_placement_rotations:
		target_up = target_up.rotated(target_view, rotation)

	var new_transform = Transform.IDENTITY.looking_at(target_view, target_up)
	new_transform *= joint.transform.inverse()
	new_transform.origin += final_position
	
	return new_transform


