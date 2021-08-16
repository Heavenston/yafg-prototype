extends KinematicBody
class_name FpsController

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
export(float) var jump_height: float    = 0.7112
onready var jump_speed: float           = sqrt(2 * gravity * jump_height)
export(float) var interaction_reach     = 5.0

onready var head = $Head
onready var camera = $Head/Camera
onready var interact_raycast := $InteractRaycast

var velocity: Vector3 = Vector3(0.0, 0.0, 0.0)
var is_running: bool = false
var last_mouse_pos = null
var is_in_interaction_mode = false
var interact_hover = null

var placement_item_id: String = ""
var placement_object: Spatial = null
var placement_ghost: Area = null

func _ready():
	interact_raycast.add_exception(self)
	if enable_on_ready:
		GameplayManager.push(self)

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
	get_tree().current_scene.add_child(placement_object)
	placement_object.global_transform = placement_ghost.global_transform
	placement_object = null
	_reset_object_placement()
	
	SessionManager.remove_item($HUD.selected_slot)

func _input(event):
	if GameplayManager.get_current_controller() != self:
		return
	
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
		$HUD.select_next_slot()
	if event.is_action_pressed("fp_previous_hotbar_slot"):
		$HUD.select_previous_slot()
	
	for i in range(0, SessionManager.player_inventory_size):
		if event.is_action_pressed("fp_selector_hotbar_"+String(i)):
			$HUD.set_selected_slot(i)
	
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
		
		pass
	if is_in_interaction_mode \
	and event.is_action_pressed("fp_interaction_mode_use_secondary"):
		
		if is_instance_valid(interact_hover) \
		and interact_hover.has_node("components/pickupable"):
			var result = SessionManager.give_item(interact_hover.get_node("components/item").item_id)
			if result:
				interact_hover.queue_free()

func _reset_interaction_hover():
	if not is_instance_valid(interact_hover):
		return
	
	if interact_hover.has_node("components/mesh_recolor"):
		interact_hover.get_node("components/mesh_recolor").reset()
	
	interact_hover = null

func _reset_object_placement():
	if is_instance_valid(placement_object):
		placement_object.queue_free()
	if is_instance_valid(placement_ghost):
		placement_ghost.queue_free()
	placement_item_id = ""
	placement_ghost = null
	placement_object = null

func _physics_process(delta):
	velocity.y -= gravity * delta
	velocity.y = move_and_slide(velocity, Vector3.UP, true, 4, deg2rad(70), false).y
	
	if not is_in_interaction_mode:
		_reset_interaction_hover()
		_reset_object_placement()
		return
	
	if $HUD.get_selected_item() != "":
		interact_raycast.collision_mask = 0b10
		_reset_interaction_hover()
		
		if $HUD.get_selected_item() != placement_item_id:
			_reset_object_placement()
			placement_item_id = $HUD.get_selected_item()
			placement_object = ItemManager.get_item(placement_item_id).place_scene.instance()
			placement_ghost = placement_object.get_node("components/placement_ghost").create()
			get_tree().get_root().add_child(placement_ghost)
		
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
		var recolor = collider.get_node("components/mesh_recolor")
		if is_instance_valid(recolor):
			recolor.set_color(Color.white)
	
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
		velocity.y = jump_speed
	
	if is_instance_valid(placement_ghost):
		var new_pos = interact_raycast.global_transform * interact_raycast.cast_to
		if interact_raycast.is_colliding():
			new_pos = interact_raycast.get_collision_point()
		if placement_object.has_node("joints/floor"):
			new_pos -= (placement_object.get_node("joints/floor") as Spatial).transform.origin
		placement_ghost.global_transform.origin = new_pos






