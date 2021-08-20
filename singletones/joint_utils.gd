extends Node

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

func is_body_grounded(body, ignore_list: Array = [], body_cache: Dictionary = {}):
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

