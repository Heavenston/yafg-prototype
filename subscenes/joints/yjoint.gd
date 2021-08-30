extends Spatial

enum JointConnectionWay {
	Parent,
	Child,
}

var joint_child setget , get_joint_child
var joint_parent setget , get_joint_parent
var connected_to = null
var connection_way: int = -1

export var joint_id: String
export(Array, String) var allowed_connection_ids: Array
export var global_placement: bool = false
export var allow_placement_rotations: bool = false

export var freedom_rotation: bool = false
var _angular_damp: float = 100
export var angular_damp: float setget set_angular_damp, get_angular_damp
var _joint_rotation: float = 0
export var joint_rotation: float setget set_joint_rotation, get_joint_rotation

func get_joint_child():
	if connection_way == JointConnectionWay.Parent:
		return connected_to
	return null

func get_joint_parent():
	if connection_way == JointConnectionWay.Child:
		return connected_to
	return null

func set_angular_damp(value: float):
	if is_instance_valid(connected_to):
		connected_to._angular_damp = value
	_angular_damp = value

func get_angular_damp() -> float:
	if is_instance_valid(connected_to) and connection_way == JointConnectionWay.Child:
		return connected_to._angular_damp
	return _angular_damp

func set_joint_rotation(value: float):
	if is_instance_valid(connected_to):
		connected_to._joint_rotation = value
	_joint_rotation = value

func get_joint_rotation() -> float:
	if is_instance_valid(connected_to) and connection_way == JointConnectionWay.Child:
		return connected_to._joint_rotation
	return _joint_rotation

func can_connect_to(to) -> bool:
	return (not is_instance_valid(connected_to) or global_placement) and\
			(not is_instance_valid(to.connected_to) or to.global_placement) and \
			allowed_connection_ids.has(to.joint_id) and to.allowed_connection_ids.has(joint_id)

func connect_to(to):
	if (is_instance_valid(to.connected_to) and not to.global_placement) or\
		(is_instance_valid(connected_to) and not global_placement):
		printerr("Invalid connection")
		return

	connection_way = JointConnectionWay.Parent
	to.connection_way = JointConnectionWay.Child
	connected_to = to
	to.connected_to = self


