extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_3d: Camera3D = $CameraPivot/SpringArm3D/Camera3D

#@onready var mouse_orbit_point: Node3D = $"Mouse Orbit Point"

var rot_x: float = 0.0
var rot_y: float = 0.0

@export var mouse_sensitivity := 0.005
@export var tilt_upper_limit := PI / 3.0   # ~60 degrees up
@export var tilt_lower_limit := -PI / 8.0  # ~-22 degrees down

@onready var spring_arm: SpringArm3D = $"CameraPivot"/SpringArm3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	startAimTimer = startAimTimer
	endAimTimer = endAimTime



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		spring_arm.rotate_x(-event.relative.y * mouse_sensitivity)
		spring_arm.rotation.x = clamp(
			spring_arm.rotation.x,
			tilt_lower_limit,
			tilt_upper_limit
		)
	elif event.is_action_pressed("Aim"):
		StartAim()
	elif event.is_action_released("Aim"):
		EndAim()

@export var startAimTime: float = .5
@export var startAimTimer: float = .5
@export var endAimTime: float = .5
@export var endAimTimer: float = .5

func StartAim():
	camera_3d.fov = 60
	startAim = true

func EndAim():
	camera_3d.fov = 90
	endAim = false

var startAim: bool
var endAim: bool

@export var fov: float
@export var aimFov: float

func _physics_process(delta: float) -> void:
	
	if(startAim):
		if(startAimTimer > 0):
			startAimTimer -= delta
			camera_3d.fov = lerp(aimFov,fov,startAimTimer/startAimTime)
		else:
			startAimTimer = startAimTime
			startAim = false
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
