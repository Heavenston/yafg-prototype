extends "res://scripts/joint_body.gd"

export var apply_force := true

func _physics_process(_delta):
	if apply_force:
		add_force(Vector3.ZERO, Vector3.UP * 10)
