extends "res://scripts/joint_body.gd"

export var apply_force := true

func _physics_process(_delta):
	if apply_force:
		var pos = $wind.transform.origin
		var force = $wind/force.transform.origin
		add_force(pos, force)
