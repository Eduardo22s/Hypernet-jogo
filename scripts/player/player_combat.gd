extends CharacterBody3D
class_name PlayerCombat

@onready var myself = $"." as Node3D
@onready var pivot = $Cameras/AttackPivot
@onready var attack_pivot = $Cameras/AttackPivot/Attack as Node3D
@onready var attack_collision = $Cameras/AttackPivot/Attack/Area3D/CollisionShape3D

const JUMP_VELOCITY = 5.2
const velQueda = 1.7
const controleAereo = 5.0
const freiarAereo = 8.0

const aceleracao = 20.0
const desaceleracao = 8.0
const coyote = 0.20
const buffer = 0.15
const freiar = 20.0

var dashing = false
var SPEED = 5.0
var bufferTimer = 0.0
var coyoteTimer = 0.0

var orbit_speed := 100.0
var cooldown = false
var cooldown_time = 0

const SENSIBILIDADE_MOUSE = 0.003
var camera_pitch := 0.0
@onready var player_camera: Camera3D = $Cameras/SpringArm1/Camera1


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.timer_on = false

func _process(delta: float) -> void:
	if dashing:
		SPEED = 500.0
	else:
		SPEED = 5.0

	if cooldown_time <= 1:
		cooldown = true
	else:
		cooldown = false

	if cooldown_time >= 0:
		cooldown_time -= cooldown_time * delta

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Rotação horizontal
		$Cameras.rotate_y(-event.relative.x * SENSIBILIDADE_MOUSE)

		# Rotação vertical
		camera_pitch -= event.relative.y * SENSIBILIDADE_MOUSE
		camera_pitch = clamp(camera_pitch, deg_to_rad(-70.0), deg_to_rad(70.0))

		$Cameras/SpringArm1.rotation.x = camera_pitch

	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	handle_attack()

	var moving_sprite = $SubViewport/Player2dModel/AnimatedMoving
	var idle_sprite = $SubViewport/Player2dModel/AnimatedIdle

	var move_right := Input.is_action_pressed("move_right")
	var move_left := Input.is_action_pressed("move_left")
	var move_up := Input.is_action_pressed("move_forward")
	var move_down := Input.is_action_pressed("move_backward")

	if move_right and move_up:
		idle_sprite.visible = false
		moving_sprite.visible = true
		moving_sprite.flip_h = true
		moving_sprite.play("diagonal_up")

	elif move_left and move_up:
		idle_sprite.visible = false
		moving_sprite.visible = true
		moving_sprite.flip_h = false
		moving_sprite.play("diagonal_up")

	elif move_right and move_down:
		idle_sprite.visible = false
		moving_sprite.visible = true
		moving_sprite.flip_h = true
		moving_sprite.play("diagonal_down")

	elif move_left and move_down:
		idle_sprite.visible = false
		moving_sprite.visible = true
		moving_sprite.flip_h = false
		moving_sprite.play("diagonal_down")

	elif move_left:
		idle_sprite.visible = false
		moving_sprite.visible = true
		moving_sprite.flip_h = false
		moving_sprite.play("sides")

	elif move_right:
		idle_sprite.visible = false
		moving_sprite.visible = true
		moving_sprite.flip_h = true
		moving_sprite.play("sides")

	elif move_up:
		idle_sprite.visible = false
		moving_sprite.visible = true
		moving_sprite.play("up")

	elif move_down:
		idle_sprite.visible = false
		moving_sprite.visible = true
		moving_sprite.play("down")

	else:
		idle_sprite.visible = true
		moving_sprite.visible = false
		$AudioStreamPlayer.stop()

	#gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta
		# Queda mais rápida
		if velocity.y < 0:
			velocity += get_gravity() * (velQueda - 1.0) * delta

	#coyote time
	if is_on_floor():
		coyoteTimer = coyote
	else:
		coyoteTimer -= delta

	#buffer
	if Input.is_action_just_pressed("ui_accept"):
		bufferTimer = buffer
	else:
		bufferTimer -= delta

	#pulo
	if bufferTimer > 0 and coyoteTimer > 0:
		velocity.y = JUMP_VELOCITY

		bufferTimer = 0
		coyoteTimer = 0

	#pulo dinamico
	if Input.is_action_just_released("ui_accept") and velocity.y > 0:
		velocity.y *= 0.4

	var input_dir := Input.get_vector("move_left","move_right","move_forward","move_backward")
	var forward = player_camera.global_transform.basis.z
	var right = player_camera.global_transform.basis.x

	forward.y = 0
	right.y = 0

	forward = forward.normalized()
	right = right.normalized()

	var direction = (right * input_dir.x +forward * input_dir.y).normalized()
	if direction:
		var target_velocity = direction * SPEED
		var velocidade_atual = Vector3(velocity.x,0,velocity.z)
		var aceleracaoAtual = aceleracao
		var freioAtual = freiar
		
		$VFX_Footstep.emitting = true
		
		if not is_on_floor():
			freioAtual = freiarAereo
			aceleracaoAtual = controleAereo
		
		#freiagem
		if velocidade_atual.length() > 0:
			var dot = velocidade_atual.normalized().dot(direction)

			if dot < 0:
				# freiando
				velocity.x = move_toward(velocity.x,0,freioAtual * delta)
				velocity.z = move_toward(velocity.z,0,freioAtual * delta)
			else:
				#normal
				velocity.x = move_toward(velocity.x,target_velocity.x,aceleracaoAtual * delta)
				velocity.z = move_toward(velocity.z,target_velocity.z,aceleracaoAtual * delta)
		else:
			# aceleração
			velocity.x = move_toward(velocity.x,target_velocity.x,aceleracaoAtual * delta)
			velocity.z = move_toward(velocity.z,target_velocity.z,aceleracaoAtual * delta)
			$AudioStreamPlayer.play()

	# desaceleração
	else:
		velocity.x = move_toward(velocity.x,0,desaceleracao * delta)
		velocity.z = move_toward(velocity.z,0,desaceleracao * delta)
		$VFX_Footstep.emitting = false

	move_and_slide()


func get_facing_direction() -> Vector3:
	return -attack_pivot.global_transform.basis.z

func get_camera_direction() -> Vector3:
	var forward = -$Cameras.global_transform.basis.z

	forward.y = 0.0

	if forward.length_squared() <= 0.001:
		return Vector3.ZERO

	return forward.normalized()

func handle_attack():
	if cooldown:
		if Input.is_action_just_pressed("attack"):
			$Cameras/AttackPivot/AnimationAttack.play("attack")
			attack_collision.disabled = false
			await get_tree().create_timer(0.5).timeout
			$Cameras/AttackPivot/Attack/Area3D/CollisionShape3D.position.z = 0
			attack_collision.disabled = true
			cooldown_time = 3.0

func dash():
	dashing = true
	await get_tree().create_timer(0.5).timeout
	dashing = false
