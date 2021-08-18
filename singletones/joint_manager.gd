extends Node

var _connections := {}

func are_joints_connected(one, two):
	if _connections.has(one) and _connections[one].has(two):
		assert(_connections.has(two) and _connections[two].has(one))
		return true
	if _connections.has(two) and _connections[two].has(one):
		assert(_connections.has(one) and _connections[one].has(two))
		return true

func _connect_joint(from, to):
	if _connections.has(from):
		_connections[from].push_back(to)
	else:
		_connections[from] = [to]
	
	from.call_deferred("_on_connect_to", to)

func connect_joints(one, two):
	if are_joints_connected(one, two):
		return

	_connect_joint(one, two)
	_connect_joint(two, one)
