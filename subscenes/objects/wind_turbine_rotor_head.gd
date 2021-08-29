extends "res://scripts/joint_body.gd"

const BLADE_DISTANCE: float = 0.25
export var blade_amount: float = 3.0

func _ready():
	for i in range(0, blade_amount):
		var joint = preload("res://subscenes/joints/generic_joint_female.tscn").instance()
		var theta = (i as float / blade_amount as float) * PI * 2
		joint.transform.origin = Vector3(cos(theta) * BLADE_DISTANCE, sin(theta) * BLADE_DISTANCE, 0)
		joint.transform.basis = Transform.IDENTITY.looking_at(-joint.transform.origin, Vector3(0, 0, 1)).basis
		joint.transform.origin.z = -0.05
		$joints.add_child(joint)

