extends Spatial

export(int, FLAGS, "Male", "Female") var gender: int = 0b01

var joint_id: String
var global_placement: bool

func _init(p_joint_id: String, p_global_placement: bool = false):
	joint_id = p_joint_id
	global_placement = p_global_placement

func _on_connect_to(_to):
	pass

