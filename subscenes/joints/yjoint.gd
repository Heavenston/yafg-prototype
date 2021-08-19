extends Spatial

export(int, FLAGS, "Male", "Female") var gender: int = 0b01

var connected_to = null

var joint_id: String
var global_placement: bool

func _init(p_joint_id: String, p_global_placement: bool = false):
	joint_id = p_joint_id
	global_placement = p_global_placement

func connect_to(to):
	if to.connected_to != null or connected_to != null:
		return

	connected_to = to
	to.connected_to = self


