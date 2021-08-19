extends Spatial

var connected_to = null

export var joint_id: String
export(Array, String) var allowed_connection_ids: Array
export var global_placement: bool

func can_connect_to(to) -> bool:
	return not is_instance_valid(connected_to) and not is_instance_valid(to.connected_to) and \
			allowed_connection_ids.has(to.joint_id) and to.allowed_connection_ids.has(joint_id)

func connect_to(to):
	if to.connected_to != null or connected_to != null:
		return

	connected_to = to
	to.connected_to = self


