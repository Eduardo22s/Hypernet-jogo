extends CharacterBody3D
class_name PlayerExploration
#olá
const JUMP_VELOCITY = 5.2

const velQueda = 1.7
const controleAereo = 5.0
const freiarAereo = 8.0

const aceleracao = 20.0
const desaceleracao = 8.0
const coyote = 0.20
const buffer = 0.15
const freiar = 20.0

var SPEED = 5.0
var bufferTimer = 0.0
var coyoteTimer = 0.0

@onready var cameras = [$Cameras/Camera1,$Cameras/Camera2,$Cameras/Camera3,$Cameras/Camera4,$Cameras/Camera5,$Cameras/Camera6,$Cameras/Camera7,$Cameras/Camera8]

var camera_atual := 0


func _ready():
	trocar_camera(camera_atual)

func _process(_delta: float) -> void:
	if Global.stop_player:
		SPEED = 0.0
	else:
		SPEED = 5.0

func _physics_process(delta: float) -> void:
	manage_battles()

	if Input.is_action_pressed("move_left"):
		$SubViewport/Player2dModel/AnimatedSprite2D.frame = 2
	elif Input.is_action_pressed("move_backward"):
		$SubViewport/Player2dModel/AnimatedSprite2D.frame = 0
	elif Input.is_action_pressed("move_forward"):
		$SubViewport/Player2dModel/AnimatedSprite2D.frame = 4
	elif Input.is_action_pressed("move_right"):
		$SubViewport/Player2dModel/AnimatedSprite2D.frame = 6

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

	var camera = cameras[camera_atual]

	var forward = camera.global_transform.basis.z
	var right = camera.global_transform.basis.x

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
			$AudioStreamPlayer3D.play()

	# desaceleração
	else:
		velocity.x = move_toward(velocity.x,0,desaceleracao * delta)
		velocity.z = move_toward(velocity.z,0,desaceleracao * delta)
		$AudioStreamPlayer3D.stop()

	move_and_slide()


func manage_battles():
	if Global.trigger_battle:
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://cenas/stages/combat_" +str(Global.npc_battle) +".tscn")


func _input(event):
	if event.is_action_pressed("trocar_camera_horario"):
		camera_atual += 1
		$SubViewport/Player2dModel/AnimatedSprite2D.frame += 1
		if camera_atual >= cameras.size():
			$SubViewport/Player2dModel/AnimatedSprite2D.frame = 0
			camera_atual = 0

		trocar_camera(camera_atual)

	if event.is_action_pressed("trocar_camera_antihorario"):
		camera_atual -= 1
		$SubViewport/Player2dModel/AnimatedSprite2D.frame -= 1
		if camera_atual < 0:
			$SubViewport/Player2dModel/AnimatedSprite2D.frame = 7
			camera_atual = cameras.size() - 1

		trocar_camera(camera_atual)


func trocar_camera(indice):
	for camera in cameras:
		camera.current = false

	cameras[indice].current = true # trocar camera
