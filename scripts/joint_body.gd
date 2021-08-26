extends RigidBody

func _is_directly_connected_to_ground() -> bool:
	if not has_node("joints"):
		return false

	for joint in $joints.get_children():
		if is_instance_valid(joint.connected_to):
			if JointUtils.is_body_ground(joint.connected_to.get_node("../..")):
				return true

	return false

func _integrate_forces(_state: PhysicsDirectBodyState):
	pass

func _position_update(done: Array = [], joint: Spatial = null):
	if joint != null:
		transform = JointUtils.get_object_placement(joint, joint.connected_to, joint.joint_rotation)

	for n_joint in get_node("joints").get_children():
		if is_instance_valid(n_joint.joint_child) and not done.has(n_joint.joint_child.get_node("../..")):
			var b = n_joint.joint_child.get_node("../..")
			done.append(b)
			if b.has_method("_position_update"):
				b._position_update(done, n_joint.joint_child)

func _physics_process(_delta):
	if _is_directly_connected_to_ground():
		_position_update([self])	
	
