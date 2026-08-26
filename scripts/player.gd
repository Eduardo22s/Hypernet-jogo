extends CharacterBody3D
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var cameras = [$Camera1,$Camera2,$Camera3,$Camera4,$Camera5,$Camera6,$Camera7,$Camera8]
var camera_atual := 0


# Belezinha
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var input_dir := Input.get_vector("move_left","move_right","move_forward","move_backward")
	var camera = cameras[camera_atual]
	var forward = camera.global_transform.basis.z
	var right = camera.global_transform.basis.x
	forward.y = 0
	right.y = 0
	forward = forward.normalized()
	right = right.normalized()
	var direction = (right * input_dir.x + forward * input_dir.y).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func _ready():
	trocar_camera(camera_atual)

func _input(event):
	if event.is_action_pressed("trocar_camera_horario"):
		camera_atual += 1
		if camera_atual >= cameras.size(): #de 0 ao número de cameras
			camera_atual = 0
		trocar_camera(camera_atual)
	if event.is_action_pressed("trocar_camera_antihorario"):
		camera_atual -= 1
		if camera_atual < 0:
			camera_atual = cameras.size() - 1
		trocar_camera(camera_atual)

func trocar_camera(indice):
	for camera in cameras:
		camera.current = false 
	cameras[indice].current = true #troca de camera conforme o índice
