extends Spatial

var connected_to = null

export var joint_id: String
export(Array, String) var allowed_connection_ids: Array
export var global_placement: bool = false
export var allow_placement_rotations: bool = false

func can_connect_to(to) -> bool:
	return (not is_instance_valid(connected_to) or global_placement) and\
			(not is_instance_valid(to.connected_to) or to.global_placement) and \
			allowed_connection_ids.has(to.joint_id) and to.allowed_connection_ids.has(joint_id)

func connect_to(to):
	if (is_instance_valid(to.connected_to) and not to.global_placement) or\
		(is_instance_valid(connected_to) and not global_placement):
		return

	connected_to = to
	to.connected_to = self


