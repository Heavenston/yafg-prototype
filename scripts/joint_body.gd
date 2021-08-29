extends KinematicBody

var is_joint_body = true

var linear_velocity = Vector3.ZERO
var angular_velocity: float = 0

func _is_directly_connected_to_ground() -> bool:
	if not has_node("joints"):
		return false

	for joint in $joints.get_children():
		if is_instance_valid(joint.connected_to):
			if JointUtils.is_body_ground(joint.connected_to.get_node("../..")):
				return true

	return false

func _get_parent_joint() -> Spatial:
	if not has_node("joints"):
		return null

	for joint in $joints.get_children():
		if is_instance_valid(joint.joint_parent):
			return joint
	
	return null

func _position_update(done: Array = [], joint: Spatial = null):
	if joint != null:
		transform = JointUtils.get_object_placement(joint, joint.connected_to, joint.joint_rotation)

	for n_joint in get_node("joints").get_children():
		if is_instance_valid(n_joint.joint_child) and not done.has(n_joint.joint_child.get_node("../..")):
			var b = n_joint.joint_child.get_node("../..")
			done.append(b)
			if b.has_method("_position_update"):
				b._position_update(done, n_joint.joint_child)

func _physics_process(delta):
	var parented_joint: Spatial = _get_parent_joint()
	if is_instance_valid(parented_joint):
		var parent_joint = parented_joint.joint_parent
		if parent_joint.freedom_rotation and abs(angular_velocity) > 0:
			
			parent_joint.joint_rotation += angular_velocity * delta
			angular_velocity = lerp(angular_velocity, 0, parented_joint.angular_damp * delta)
		else:
			angular_velocity = 0

	transform.origin += linear_velocity * delta

	if _is_directly_connected_to_ground():
		_position_update([self])	

func add_force(position: Vector3, force: Vector3):
	var parented_joint: Spatial = _get_parent_joint()
	if not is_instance_valid(parented_joint):
		return
	var parent_joint = parented_joint.joint_parent
	var p = parent_joint.get_node("../..")

	var global_force = global_transform.basis.xform(force)

	if parent_joint.freedom_rotation:
		var r = parent_joint.global_transform.xform_inv(global_transform.xform(position))
		r.z = 0
		r = parent_joint.global_transform.basis.xform(r)

		var axis = parent_joint.global_transform.basis.z
		var orthogonal_force = global_force - (global_force.dot(axis) * axis)

		var torque = r.cross(orthogonal_force)
		var relative_torque = parented_joint.global_transform.basis.xform_inv(torque)
		angular_velocity -= relative_torque.z

	if "is_joint_body" in p:
		p.add_force(p.global_transform.xform_inv(global_transform.xform(position)), p.global_transform.basis.xform_inv(global_force))

