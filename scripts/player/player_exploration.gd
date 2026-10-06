
extends CharacterBody3D
class_name PlayerExploration

const JUMP_VELOCITY = 5.2
const velQueda = 1.7
const controleAereo = 5.0
const freiarAereo = 8.0

const aceleracao = 20.0
const desaceleracao = 8.0
const coyote = 0.20
const buffer = 0.30
const freiar = 20.0

var dashing = false
var dash_aereo_disponivel = true

const dash_duracao = 0.15
const dash_forca = 14.0
const dash_chao_duracao = 0.20
const dash_chao_forca = 20.0


const WALL_JUMP_FORCE = 8.0
const WALL_JUMP_VERTICAL = 7.0
const WALL_KICK_DASH_FORCE = 14.0
const WALL_KICK_DASH_VERTICAL = 8.0

var na_parede := false
var normal_parede := Vector3.ZERO
var wall_jump_usado := false
var ultima_parede_normal := Vector3.ZERO

@onready var wall_area: Area3D = $Wall

var parede_atual: Node3D = null

var SPEED = 5.0
var bufferTimer = 0.0
var coyoteTimer = 0.0

@onready var cameras = [$Cameras/SpringArm1/Camera1,$Cameras/SpringArm2/Camera2,$Cameras/SpringArm3/Camera3,$Cameras/SpringArm4/Camera4,$Cameras/SpringArm5/Camera5,$Cameras/SpringArm6/Camera6,$Cameras/SpringArm7/Camera7,$Cameras/SpringArm8/Camera8]

var camera_atual := 0
var cooldown = false
var cooldown_time = 0.0

const BALAO_FORCA = 0.5
const BALAO_FORCA_DASH = 2.0

@onready var balloon_detector: Area3D = $BalloonDetector


func _ready():
	trocar_camera(camera_atual)

	Global.timer_on = true
	global_position = Global.player_return_pos
	Global.stop_player = false
	Global.words_in_storage = 0


func _process(delta: float) -> void:
	manage_battles()

	if Global.end_game:
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://scenes/stages/main_menu.tscn")

	if Global.stop_player:
		SPEED = 0.0
	else:
		SPEED = 5.0

	if cooldown_time <= 1.0:
		cooldown = true
	else:
		cooldown = false

	if cooldown_time > 0.0:
		cooldown_time -= delta

		if cooldown_time < 0.0:
			cooldown_time = 0.0


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

	if not is_on_floor() and not dashing:
		velocity += get_gravity() * delta

		if velocity.y < 0:
			velocity += get_gravity() * (velQueda - 1.0) * delta

	if is_on_floor():
		coyoteTimer = coyote
		dash_aereo_disponivel = true
		wall_jump_usado = false
	else:
		coyoteTimer -= delta

	if Input.is_action_just_pressed("ui_accept"):
		bufferTimer = buffer
	else:
		bufferTimer -= delta

	detectar_parede_area()

	if bufferTimer > 0.0:
		if na_parede and not wall_jump_usado:
			wall_jump()

			bufferTimer = 0.0
			coyoteTimer = 0.0

		elif coyoteTimer > 0.0:
			velocity.y = JUMP_VELOCITY
			bufferTimer = 0.0
			coyoteTimer = 0.0

	if Input.is_action_just_released("ui_accept"):
		if velocity.y > 0.0:
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

	if dashing:
		$VFX_Footstep.emitting = false
		move_and_slide()
		empurrar_baloes()
		check_dash_wall_collision()
		return

	if direction:
		var target_velocity = direction * SPEED
		var velocidade_atual = Vector3(velocity.x,0,velocity.z)

		var aceleracaoAtual = aceleracao
		var freioAtual = freiar

		if not is_on_floor():
			freioAtual = freiarAereo
			aceleracaoAtual = controleAereo

		if velocidade_atual.length() > 0:
			var dot = velocidade_atual.normalized().dot(direction)

			if dot < 0:
				velocity.x = move_toward(velocity.x,0,freioAtual * delta)
				velocity.z = move_toward(velocity.z,0,freioAtual * delta)
			else:
				velocity.x = move_toward(velocity.x,target_velocity.x,aceleracaoAtual * delta)
				velocity.z = move_toward(velocity.z,target_velocity.z,aceleracaoAtual * delta)

		else:
			velocity.x = move_toward(velocity.x,target_velocity.x,aceleracaoAtual * delta)
			velocity.z = move_toward(velocity.z,target_velocity.z,aceleracaoAtual * delta)

			$AudioStreamPlayer.play()

		$VFX_Footstep.emitting = true

	else:
		velocity.x = move_toward(velocity.x,0,desaceleracao * delta)
		velocity.z = move_toward(velocity.z,0,desaceleracao * delta)

		$VFX_Footstep.emitting = false

	move_and_slide()
	empurrar_baloes()

func detectar_parede_area():
	na_parede = false
	normal_parede = Vector3.ZERO

	if is_on_floor():
		return

	var corpos = wall_area.get_overlapping_bodies()

	for corpo in corpos:
		if corpo == self:
			continue

		var direcao = global_position - corpo.global_position

		if direcao.length_squared() < 0.001:
			continue

		direcao = direcao.normalized()

		if abs(direcao.y) >= 0.5:
			continue

		na_parede = true
		normal_parede = direcao

		# Entrou em uma nova parede
		if corpo != parede_atual:
			parede_atual = corpo
			wall_jump_usado = false

		return


func handle_attack():
	if not cooldown:
		return

	if Input.is_action_just_pressed("attack"):
		if is_on_floor():
			dash()
		elif dash_aereo_disponivel:
			dash_aereo()

		$OrbitalPivot/AnimationAttack.play("attack")

		await get_tree().create_timer(0.5).timeout

		$OrbitalPivot/Attack/Area3D/CollisionShape3D.position.z = 0

		cooldown_time = 3.0


func dash():
	if dashing:
		return

	dashing = true

	var camera = cameras[camera_atual]

	var forward = camera.global_transform.basis.z
	var right = camera.global_transform.basis.x

	forward.y = 0
	right.y = 0

	forward = forward.normalized()
	right = right.normalized()

	var input_dir := Input.get_vector("move_left","move_right","move_forward","move_backward")

	var direction = (right * input_dir.x +forward * input_dir.y).normalized()

	if direction == Vector3.ZERO:
		direction = -global_transform.basis.z
		direction.y = 0
		direction = direction.normalized()

	velocity.x = direction.x * dash_chao_forca
	velocity.z = direction.z * dash_chao_forca

	await get_tree().create_timer(dash_chao_duracao).timeout

	if dashing:
		dashing = false


func dash_aereo():
	if not dash_aereo_disponivel:
		return

	if dashing:
		return

	dash_aereo_disponivel = false
	dashing = true

	var camera = cameras[camera_atual]

	var forward = camera.global_transform.basis.z
	var right = camera.global_transform.basis.x

	forward.y = 0
	right.y = 0

	forward = forward.normalized()
	right = right.normalized()

	var input_dir := Input.get_vector("move_left","move_right","move_forward","move_backward")

	var direction = (right * input_dir.x +forward * input_dir.y).normalized()

	if direction == Vector3.ZERO:
		direction = -global_transform.basis.z
		direction.y = 0
		direction = direction.normalized()

	velocity.x = direction.x * dash_forca
	velocity.z = direction.z * dash_forca
	velocity.y = 0

	await get_tree().create_timer(dash_duracao).timeout

	if dashing:
		dashing = false


func wall_jump():
	if not na_parede:
		return

	if wall_jump_usado:
		return

	wall_jump_usado = true

	ultima_parede_normal = normal_parede

	dashing = false

	var direcao = normal_parede
	direcao.y = 0.0
	direcao = direcao.normalized()

	# Zera a velocidade horizontal anterior
	velocity.x = 0.0
	velocity.z = 0.0

	# Empurra diretamente para longe da parede
	velocity.x = direcao.x * WALL_JUMP_FORCE
	velocity.z = direcao.z * WALL_JUMP_FORCE

	# Sobe
	velocity.y = WALL_JUMP_VERTICAL

	#virar_para_direcao(normal_parede)
	

func check_dash_wall_collision():
	if not dashing:
		return

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()

		if abs(normal.y) < 0.5:
			normal_parede = normal
			wall_kick_dash()
			return


func wall_kick_dash():
	if not dashing:
		return

	wall_jump_usado = true

	ultima_parede_normal = normal_parede

	dashing = false

	dash_aereo_disponivel = false

	velocity.x = normal_parede.x * WALL_KICK_DASH_FORCE
	velocity.z = normal_parede.z * WALL_KICK_DASH_FORCE
	velocity.y = WALL_KICK_DASH_VERTICAL

#	virar_para_direcao(normal_parede)


#func virar_para_direcao(direcao: Vector3):
	#if direcao.length() <= 0.01:
	#	return

#	var direcao_horizontal = Vector3(direcao.x,0,direcao.z).normalized()

	#if direcao_horizontal.length() <= 0.01:
		#return

	#look_at(global_position + direcao_horizontal,Vector3.UP)


func manage_battles():
	if Global.trigger_battle:
		set_physics_process(false)

		await get_tree().process_frame

		get_tree().change_scene_to_file("res://scenes/stages/combat_" +str(Global.npc_battle) +".tscn")


func _input(event):
	if event.is_action_pressed("trocar_camera_horario"):
		camera_atual += 1
		$SubViewport/Player2dModel/AnimatedIdle.frame += 1

		if camera_atual >= cameras.size():
			$SubViewport/Player2dModel/AnimatedIdle.frame = 0
			camera_atual = 0

		trocar_camera(camera_atual)

	if event.is_action_pressed("trocar_camera_antihorario"):
		camera_atual -= 1
		$SubViewport/Player2dModel/AnimatedIdle.frame -= 1

		if camera_atual < 0:
			$SubViewport/Player2dModel/AnimatedIdle.frame = 7
			camera_atual = cameras.size() - 1

		trocar_camera(camera_atual)


func trocar_camera(indice):
	for camera in cameras:
		camera.current = false
	cameras[indice].current = true


func empurrar_baloes():
	var baloes = balloon_detector.get_overlapping_bodies()

	for balao in baloes:
		if balao is RigidBody3D and balao.is_in_group("balloon"):

			var direcao = balao.global_position - global_position
			direcao.y = 0.0

			if direcao.length_squared() <= 0.001:
				continue

			direcao = direcao.normalized()

			if dashing:
				balao.apply_central_impulse(direcao * BALAO_FORCA_DASH)
			else:
				balao.apply_central_impulse(direcao * BALAO_FORCA)
