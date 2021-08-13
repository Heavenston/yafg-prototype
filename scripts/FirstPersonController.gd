extends KinematicBody
class_name FpsController

export(bool) var enable_on_ready: bool  = true

export(float) var gravity: float        = ProjectSettings.get_setting("physics/3d/default_gravity")
# Walking speed in meters per seconds
export(float) var walking_speed: float  = 4.5
# Running speed in meters per seconds
export(float) var runnning_speed: float = 10.4
# Walking acceleration in % of max speed per seconds
export(float) var walking_acc: float    = 10.0
export(float) var air_acc: float        = 1.0
export(float) var mouse_sensitivity: float = ProjectSettings.get_setting("global/mouse_sensitivity")
export(float) var jump_height: float    = 1.5
onready var jump_speed: float           = sqrt(2 * gravity * jump_height)
export(float) var interaction_reach     = 8.0

onready var head = $Head
onready var camera = $Head/Camera
onready var interact_raycast: RayCast = $InteractRaycast

var velocity: Vector3 = Vector3(0.0, 0.0, 0.0)
var is_running: bool = false
var last_mouse_pos = null
var is_in_interaction_mode = false

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

func _input(event):
	if GameplayManager.get_current_controller() != self:
		return
	
	if event.is_action_pressed("fp_interaction_mode"):
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		if ProjectSettings.get("global/restore_mouse_pos_interaction_mode") and\
		 last_mouse_pos != null:
			get_viewport().warp_mouse(last_mouse_pos)
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		is_in_interaction_mode = true
		interact_raycast.enabled = true
	
	if event.is_action_released("fp_interaction_mode"):
		last_mouse_pos = get_viewport().get_mouse_position()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		is_in_interaction_mode = false
		interact_raycast.enabled = false
	
	if event.is_action_pressed("fp_run"):
		is_running = true
	if event.is_action_released("fp_run"):
		is_running = false
	
	if is_in_interaction_mode\
	and event.is_action_pressed("fp_interaction_mode_use_primary"):
		pass
	if is_in_interaction_mode\
	and event.is_action_pressed("fp_interaction_mode_use_seconday"):
		pass
	
	if event is InputEventMouseMotion:
		if is_in_interaction_mode:
			var cast_to = camera.project_position(get_viewport().get_mouse_position(), interaction_reach)
			cast_to = interact_raycast.global_transform.inverse() * cast_to
			interact_raycast.cast_to = cast_to
		else:
			rotate_y(-event.relative.x * mouse_sensitivity)
			head.rotate_x(-event.relative.y * mouse_sensitivity)
	

func _physics_process(delta):
	velocity.y -= gravity * delta
	velocity.y = move_and_slide(velocity, Vector3.UP, true, 4, deg2rad(70), false).y
	
	var collider = interact_raycast.get_collider()
	
	if is_in_interaction_mode and collider is CollisionObject\
	 and collider.has_node("interactable"):
		# SET
		pass
	else:
		# RESET
		pass

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






