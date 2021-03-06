extends KinematicBody
class_name FpsController

const ENABLE_FREE_PLACEMENT: bool = true
const FREE_PLACEMENT_REACH: float = 2.0

export(bool) var enable_on_ready: bool  = true

export(float) var gravity: float        = ProjectSettings.get_setting("physics/3d/default_gravity")
# Walking speed in meters per seconds
export(float) var walking_speed: float  = 3.3
# Running speed in meters per seconds
export(float) var runnning_speed: float = 7
# Walking acceleration in % of max speed per seconds
export(float) var walking_acc: float    = 10.0
export(float) var air_acc: float        = 1.0
export(float) var mouse_sensitivity: float = ProjectSettings.get_setting("global/mouse_sensitivity")
export(float) var jump_height: float    = 1
export(float) var interaction_reach     = 5.0

onready var head = $Head
onready var camera = $Head/Camera
onready var interact_raycast := $InteractRaycast
onready var hud := $HUD/HUD/HUD

var velocity: Vector3 = Vector3(0.0, 0.0, 0.0)
var is_running: bool = false
var last_mouse_pos = null

var is_in_interaction_mode = false
var interact_hover = null
var interact_hover_bodies := []
var interact_hover_recolors := []
var interact_hover_can_pickup := false

var placement_item_id: String = ""
var placement_object: Spatial = null
var placement_object_joints: Array = []
var placement_ghost: Area = null
var placement_joint1 = null
var placement_joint2 = null
var placement_rotation = 0

func _ready():
	interact_raycast.add_exception(self)

	on_disable()
	if enable_on_ready:
		on_enable()

func on_enable():
	camera.current = true
	set_process(true)
	set_physics_process(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func on_disable():
	camera.current = false
	set_process(false)
	set_physics_process(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	is_in_interaction_mode = false

func _get_jump_force() -> float:
	return sqrt(2 * gravity * jump_height)

func get_camera() -> Camera:
	return camera

func _get_input_vector() -> Vector2:
	var vec = Vector2(0.0, 0.0)
	
	if Input.is_action_pressed("fp_forward"):
		vec.y += 1
	if Input.is_action_pressed("fp_backward"):
		vec.y -= 1
	if Input.is_action_pressed("fp_right"):
		vec.x += 1
	if Input.is_action_pressed("fp_left"):
		vec.x -= 1
	
	return vec

func _update_interaction_mode_raycast(mouse_pos: Vector2 = get_viewport().get_mouse_position()):
	var cast_to = camera.project_position(mouse_pos, interaction_reach)
	cast_to = interact_raycast.global_transform.inverse() * cast_to
	interact_raycast.cast_to = cast_to

func _validate_placement():
	var rot = placement_rotation
	get_tree().current_scene.add_child(placement_object)
	placement_object.global_transform = placement_ghost.global_transform
	placement_object = null
	_reset_object_placement()
	placement_joint1.connect_to(placement_joint2)
	placement_joint1.joint_rotation = rot
	
	SessionManager.remove_item(hud.selected_slot)

func _input(event):
	if event is InputEventMouseMotion:
		if is_in_interaction_mode:
			_update_interaction_mode_raycast()
		else:
			rotate_y(-event.relative.x * mouse_sensitivity)
			head.rotate_x(-event.relative.y * mouse_sensitivity)
	
	if event.is_action_pressed("fp_run"):
		is_running = true
	if event.is_action_released("fp_run"):
		is_running = false
	
	if event.is_action_pressed("fp_next_hotbar_slot"):
		hud.select_next_slot()
	if event.is_action_pressed("fp_previous_hotbar_slot"):
		hud.select_previous_slot()
	
	for i in range(0, SessionManager.player_inventory_size):
		if event.is_action_pressed("fp_selector_hotbar_"+String(i)):
			hud.set_selected_slot(i)
	
	if event.is_action_pressed("fp_interaction_mode"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		if ProjectSettings.get("global/restore_mouse_pos_interaction_mode") and\
		 last_mouse_pos != null:
			get_viewport().warp_mouse(last_mouse_pos)
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		is_in_interaction_mode = true
		interact_raycast.enabled = true
		
		if last_mouse_pos != null:
			_update_interaction_mode_raycast(last_mouse_pos)
		else:
			_update_interaction_mode_raycast()
	
	if event.is_action_released("fp_interaction_mode"):
		last_mouse_pos = get_viewport().get_mouse_position()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		is_in_interaction_mode = false
		interact_raycast.enabled = false
	
	if is_in_interaction_mode \
	and event.is_action_pressed("fp_interaction_mode_use_primary"):
		
		if is_instance_valid(placement_object) \
		and is_instance_valid(placement_ghost) \
		and placement_ghost.is_valid:
			_validate_placement()
		
	if is_in_interaction_mode \
	and event.is_action_pressed("fp_interaction_mode_use_secondary"):
		
		if is_instance_valid(interact_hover) \
		and interact_hover_can_pickup \
		and interact_hover.has_node("components/pickupable"):
			if SessionManager.has_space_for(interact_hover_bodies.size() + 1):
				var _result = SessionManager.give_item(interact_hover.get_node("components/item").item_id)
				interact_hover.queue_free()
				for body in interact_hover_bodies:
					_result = SessionManager.give_item(body.get_node("components/item").item_id)
					body.queue_free()

func _reset_interaction_hover():
	
	for r in interact_hover_recolors:
		if is_instance_valid(r):
			r.reset()
	
	interact_hover = null
	interact_hover_recolors = []

func _reset_object_placement():
	if is_instance_valid(placement_object):
		placement_object.queue_free()
	if is_instance_valid(placement_ghost):
		placement_ghost.queue_free()
	placement_item_id = ""
	placement_ghost = null
	placement_object = null
	placement_rotation = 0

func _physics_process(delta):
	velocity.y -= gravity * delta
	velocity = move_and_slide(velocity, Vector3.UP, true, 4, deg2rad(70), false)
	
	if not is_in_interaction_mode:
		_reset_interaction_hover()
		_reset_object_placement()
		return
	
	if hud.get_selected_item() != "":
		_reset_interaction_hover()
		
		if hud.get_selected_item() != placement_item_id:
			_reset_object_placement()
			placement_item_id = hud.get_selected_item()
			placement_object = ItemManager.get_item(placement_item_id).place_scene.instance()
			placement_object_joints = placement_object.get_node("joints").get_children()

			placement_ghost = placement_object.get_node("components/placement_ghost").create()
			interact_raycast.add_exception(placement_ghost)
			get_tree().get_root().add_child(placement_ghost)

		if Input.is_action_pressed("fp_rotate_clockwise"):
			placement_rotation -= 1.5 * delta
		if Input.is_action_pressed("fp_rotate_counter_clockwise"):
			placement_rotation += 1.5 * delta

		# Placement ghost positioning
		if is_instance_valid(placement_ghost):
			var new_transform := Transform()
			var col_point = interact_raycast.global_transform * interact_raycast.cast_to
			new_transform.origin = col_point
			var col_normal = Vector3.UP
			var collider = null

			var closest_joint = null
			var closest_own_joint = null
			var closest_distance = 99999999

			# If the intreact_raycast is colliding, get the joint in the collider
			# If it's not colliding and free_placement is enabled, it's free placement, so test EVERY joints in the world
			if interact_raycast.is_colliding():
				col_point = interact_raycast.get_collision_point()
				col_normal = interact_raycast.get_collision_normal()
				collider = interact_raycast.get_collider()

				if collider.has_node("joints"):
					for joint in collider.get_node("joints").get_children():
						# Find a valid joint
						var joint2 = null
						for joint2_ in placement_object_joints:
							if not joint.can_connect_to(joint2_):
								continue
							joint2 = joint2_
							break
						if joint2 == null:
							continue

						var dist: float
						if joint.global_placement:
							dist = 0
						else:
							dist = joint.global_transform.origin.distance_squared_to(col_point)
						if dist < closest_distance:
							closest_joint = joint
							closest_own_joint = joint2
							closest_distance = dist

			elif ENABLE_FREE_PLACEMENT:
				# Find closest matching joint with collider
				for joint in get_tree().get_nodes_in_group("joints"):
					# Find a valid joint
					var joint2 = null
					for joint2_ in placement_object_joints:
						if not joint.can_connect_to(joint2_):
							continue
						joint2 = joint2_
						break
					if joint2 == null:
						continue
					# No global placement in free placement
					if joint.global_placement:
						continue

					var dist: float = joint.global_transform.origin.distance_squared_to(col_point)
					if dist < FREE_PLACEMENT_REACH and dist < closest_distance:
						closest_joint = joint
						closest_own_joint = joint2
						closest_distance = dist

			# If a valid joint is found show placement ghost
			# And do matrix magic to put the joint in the correct positions
			if closest_joint != null and is_instance_valid(closest_joint):
				placement_ghost.is_valid = true
				placement_joint1 = closest_joint
				placement_joint2 = closest_own_joint

				new_transform = JointUtils.get_object_placement(closest_own_joint, closest_joint, placement_rotation, col_normal, col_point)
				# Test for overlapping bodies
				for body in placement_ghost.get_overlapping_bodies():
					if body != collider:
						placement_ghost.is_valid = false
			else:
				placement_ghost.is_valid = false
				new_transform = Transform.translated(col_point)

			placement_ghost.global_transform = new_transform
		
		return
	else:
		interact_raycast.collision_mask = 0b01
		_reset_object_placement()
	
	if not interact_raycast.is_colliding():
		_reset_interaction_hover()
		_reset_object_placement()
		return
	
	var collider: CollisionObject = interact_raycast.get_collider()
	if collider == interact_hover:
		return
	_reset_interaction_hover()
	
	if collider.has_node("components/pickupable"):
		var attached_bodies: Array = JointUtils.get_all_connected_bodies(collider)
		var can_pickup := true
		for body in attached_bodies:
			if not body.has_node("components/pickupable"):
				can_pickup = false
		if not can_pickup:
			can_pickup = SessionManager.has_space_for(attached_bodies.size() + 1)

		interact_hover_can_pickup = can_pickup
		interact_hover_bodies = attached_bodies

		var coloring := Color.white if can_pickup else Color.red
		if collider.has_node("components/mesh_recolor"):
			var recolor = collider.get_node("components/mesh_recolor")
			interact_hover_recolors.append(recolor)
			recolor.set_color(coloring)
		for body in attached_bodies:
			if body.has_node("components/mesh_recolor"):
				var recolor = body.get_node("components/mesh_recolor")
				interact_hover_recolors.append(recolor)
				recolor.set_color(coloring)
	else:
		interact_hover_can_pickup = false

	interact_hover = collider

func _process(delta):
	var acc = walking_acc
	if not is_on_floor():
		acc = air_acc
	
	var speed = walking_speed
	if is_running:
		speed = runnning_speed
	
	var in_vec = _get_input_vector()
	var target_velocity = (transform.basis.x * in_vec.x) + (transform.basis.z * -in_vec.y)
	target_velocity = target_velocity.normalized() * speed
	
	velocity.x = lerp(velocity.x, target_velocity.x, acc * delta)
	if abs(velocity.x - target_velocity.x) < 0.01:
		velocity.x = target_velocity.x
	velocity.z = lerp(velocity.z, target_velocity.z, acc * delta)
	if abs(velocity.z - target_velocity.z) < 0.01:
		velocity.z = target_velocity.z
	
	if Input.is_action_pressed("fp_jump") and is_on_floor():
		velocity.y = _get_jump_force()
	






