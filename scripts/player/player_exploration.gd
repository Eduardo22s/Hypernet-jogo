extends CharacterBody3D
class_name PlayerExploration

const JUMP_VELOCITY = 8.0
const velQueda = 1.7
const controleAereo = 5.0
const freiarAereo = 8.0

const WALL_CHECK_DIST := 0.7   # alcance da detecção (um pouco maior que o raio do player)
const WALL_RAY_COUNT := 8      # quantidade de raios ao redor
const WALL_RAY_HEIGHT := 0.5   # altura do raio em relação ao pé do player

const aceleracao = 20.0
const desaceleracao = 8.0
const coyote = 0.20
const buffer = 0.30
const freiar = 20.0

var dashing = false
var dash_aereo_disponivel = true

const dash_duracao = 0.15
const dash_forca = 10.0
const dash_chao_duracao = 0.20
const dash_chao_forca = 15.0

const WALL_JUMP_FORCE = 8.0
const WALL_JUMP_VERTICAL = 7.0
const WALL_KICK_DASH_FORCE = 14.0
const WALL_KICK_DASH_VERTICAL = 8.0

var na_parede := false
var normal_parede := Vector3.ZERO
var wall_jump_usado := false
var ultima_parede_normal := Vector3.ZERO

@onready var wall_area: Area3D = $Wall


var SPEED = 5.0
var bufferTimer = 0.0
var coyoteTimer = 0.0

const SENSIBILIDADE_MOUSE = 0.003
var camera_pitch := 0.0
@onready var player_camera: Camera3D = $Cameras/SpringArm1/Camera1

const BALAO_FORCA = 0.5
const BALAO_FORCA_DASH = 2.0

@onready var balloon_detector: Area3D = $BalloonDetector

@export var mirror_teleports: Array[Node3D] = []

@onready var mirror_detector: Area3D = $MirrorDetector

@onready var border: Border = $"../Environment/Border"

@onready var bumper_detector: Area3D = $BumperDetector

const BUMPER_MIN_SPEED = 9.0
const BUMPER_PUSH_DISTANCE = 0.15

var bumper_knockback_timer := 0.0
const BUMPER_KNOCKBACK_DURATION = 0.18

var throw_velocity = Vector3.ZERO
var throw_height: float = 0.0

var mirror_teleporting = false

var dentro_vendaval := false
var vendaval_subindo := false
var vendaval_flutuando := false
var vendaval_altura_alvo := 0.0

const VENDA_VAL_FORCA := 4.0
const VENDA_VAL_ALTURA := 1.0

var esteira_atual: ConveyorBelt = null
const FORCA_ESTEIRA := 12.0

<<<<<<< HEAD
var call_once = true
=======
var jump_pad_atual: JumpPad = null

>>>>>>> d5ff737c59de6dae2d27f5a9cd4432e01bfb07b7

func _ready():
	$HUD/Fade/AnimationPlayer.play_backwards("fade")
	add_to_group("player")
	mirror_detector.area_entered.connect(_on_mirror_detector_area_entered)
	bumper_detector.area_entered.connect(_on_bumper_area_entered)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	#global_position = Global.player_return_pos
	Global.stop_player = false
	Global.words_in_storage = 0

func _process(_delta: float) -> void:
	if Global.end_game:
		if call_once:
			$HUD/Flash/S_ScreenFlashLayer/ScreenFlash.PlayFlash()
			$HUD/Fade/AnimationPlayer.play("fade")
			call_once = false
		
		await get_tree().create_timer(4.0).timeout
		get_tree().change_scene_to_file("res://scenes/stages/game_over_menu.tscn")

	if Global.stop_player:
		SPEED = 0.0
	else:
		SPEED = 5.0


func _physics_process(delta: float) -> void:
	var moving_sprite = $SubViewport/Player2dModel/AnimatedMoving
	var idle_sprite = $SubViewport/Player2dModel/AnimatedIdle

	var move_right := Input.is_action_pressed("move_right")
	var move_left := Input.is_action_pressed("move_left")
	var move_up := Input.is_action_pressed("move_forward")
	var move_down := Input.is_action_pressed("move_backward")
	
	if dentro_vendaval:
		if vendaval_subindo:
			velocity.y = VENDA_VAL_FORCA
		elif vendaval_flutuando:
			velocity.y = 0.0

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

	if not is_on_floor() and not dashing and not dentro_vendaval:
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
		if jump_pad_atual != null:
			jump_pad_atual.ativar(self)
			bufferTimer = 0.0
		else:
			bufferTimer = buffer
	else:
		bufferTimer -= delta

	detectar_parede_area()

	if bufferTimer > 0.0 and not dentro_vendaval:
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
	
	var forward = player_camera.global_transform.basis.z
	var right = player_camera.global_transform.basis.x

# Ignora completamente a inclinação vertical da câmera
	forward.y = 0.0
	right.y = 0.0

	forward = forward.normalized()
	right = right.normalized()

	var direction = (right * input_dir.x +forward * input_dir.y).normalized()
	if direction.length_squared() > 0.001:
		direction = direction.normalized()

	# O dash agora possui um comando próprio, sem depender de ataque.
	if Input.is_action_just_pressed("dash") and not dashing:
		$OrbitalPivot/AnimationAttack.play("attack")
		if is_on_floor():
			dash()
		elif dash_aereo_disponivel:
			dash_aereo()
	
	if bumper_knockback_timer > 0.0:
		bumper_knockback_timer -= delta

		$VFX_Footstep.emitting = false

		
		move_and_slide()
		finalizar_movimento_vendaval()
		empurrar_baloes()
		return

	if dashing:
		$VFX_Footstep.emitting = false

		move_and_slide()
		finalizar_movimento_vendaval()
		empurrar_baloes()
		check_dash_wall_collision()
		return
	

	if direction:
		var target_velocity = direction * SPEED
		var aceleracaoAtual = aceleracao
		if not is_on_floor():
			aceleracaoAtual = controleAereo

		velocity.x = move_toward(velocity.x,target_velocity.x,aceleracaoAtual * delta)
		velocity.z = move_toward(velocity.z,target_velocity.z,aceleracaoAtual * delta)

		$AudioStreamPlayer.play()
		$VFX_Footstep.emitting = true

	else:
		velocity.x = move_toward(velocity.x,0.0,desaceleracao * delta)
		velocity.z = move_toward(velocity.z,0.0,desaceleracao * delta)

		$VFX_Footstep.emitting = false

	aplicar_esteira(delta, input_dir)

	move_and_slide()
	finalizar_movimento_vendaval()
	empurrar_baloes()

func get_camera_direction() -> Vector3:
	var forward = -$Cameras.global_transform.basis.z

	forward.y = 0.0

	if forward.length_squared() <= 0.001:
		return Vector3.ZERO

	return forward.normalized()


func detectar_parede_area():
	na_parede = false
	normal_parede = Vector3.ZERO

	if is_on_floor():
		return

	var space := get_world_3d().direct_space_state
	var origem := global_position + Vector3.UP * WALL_RAY_HEIGHT

	var melhor_dist := INF
	var melhor_normal := Vector3.ZERO

	for i in WALL_RAY_COUNT:
		var ang := TAU * i / WALL_RAY_COUNT
		var dir := Vector3(cos(ang), 0.0, sin(ang))

		var query := PhysicsRayQueryParameters3D.create(origem, origem + dir * WALL_CHECK_DIST)
		query.exclude = [get_rid()]
		query.collision_mask = collision_mask

		var hit := space.intersect_ray(query)
		if hit.is_empty():
			continue

		var n: Vector3 = hit.normal

		# Ignora chão e teto
		if abs(n.y) >= 0.5:
			continue

		var dist := origem.distance_to(hit.position)
		if dist < melhor_dist:
			melhor_dist = dist
			melhor_normal = n

	if melhor_normal == Vector3.ZERO:
		return

	melhor_normal.y = 0.0
	melhor_normal = melhor_normal.normalized()

	na_parede = true
	normal_parede = melhor_normal

	# Como o GridMap é um corpo só, a "parede nova" é detectada pela normal, não pelo nó
	if melhor_normal.dot(ultima_parede_normal) < 0.9:
		wall_jump_usado = false


func dash():
	if dashing:
		return

	dashing = true

	var forward = player_camera.global_transform.basis.z
	var right = player_camera.global_transform.basis.x

	forward.y = 0.0
	right.y = 0.0

	forward = forward.normalized()
	right = right.normalized()

	var input_dir := Input.get_vector("move_left","move_right","move_forward","move_backward")
	var direction: Vector3
	# Sem W/A/S/D → dash para onde a câmera está olhando
	if input_dir.length_squared() <= 0.001:
		direction = -forward
	else:
		# Com W/A/S/D → mantém a direção dos controles
		direction = right * input_dir.x + forward * input_dir.y
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

	var forward = player_camera.global_transform.basis.z
	var right = player_camera.global_transform.basis.x

	forward.y = 0.0
	right.y = 0.0

	forward = forward.normalized()
	right = right.normalized()

	var input_dir := Input.get_vector("move_left","move_right","move_forward","move_backward")

	var direction: Vector3

	if input_dir.length_squared() <= 0.001:
		direction = -forward
	else:
		direction = right * input_dir.x + forward * input_dir.y
		direction = direction.normalized()

	velocity.x = direction.x * dash_forca
	velocity.z = direction.z * dash_forca
	velocity.y = 0.0

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


func _on_mirror_detector_area_entered(area: Area3D) -> void:
	if area is MirrorZone:
		teleport_player()


func teleport_player() -> void:
	if mirror_teleporting:
		return

	if mirror_teleports.is_empty():
		return

	mirror_teleporting = true

	var random_mirror = randi_range(0, mirror_teleports.size() - 1)

	global_position = mirror_teleports[random_mirror].global_position

	await get_tree().create_timer(0.25).timeout

	mirror_teleporting = false
	
	
func _on_bumper_area_entered(area: Area3D) -> void:

	if not area.is_in_group("player_bumpers"):
		return
	
	var sprite = area.get_node_or_null("AnimatedSprite3D")

	if sprite:
		sprite.stop()
		sprite.play("Idle")

	# Centro aproximado do jogador
	var player_center = global_position + Vector3.UP * 0.1

	# Direção do centro do Bumper até o jogador
	var normal = player_center - area.global_position

	if normal.length_squared() < 0.001:
		return

	normal = normal.normalized()

	# Velocidade de impacto
	var impacto = velocity.dot(normal)

	# Preserva a velocidade tangencial
	var velocidade_lateral = velocity.slide(normal)

	# Calcula a força do ricochete
	var forca_saida = maxf(-impacto, BUMPER_MIN_SPEED)

	# Aplica o ricochete
	velocity = velocidade_lateral + normal * forca_saida

	# Interrompe dash
	dashing = false

	# Evita que a movimentação anule o impulso
	bumper_knockback_timer = BUMPER_KNOCKBACK_DURATION

	# Pequeno afastamento
	global_position += normal * BUMPER_PUSH_DISTANCE
	
	
func finalizar_movimento_vendaval():

	if not dentro_vendaval:
		return

	# Enquanto sobe, verifica se chegou ao topo
	if vendaval_subindo:
		if global_position.y >= vendaval_altura_alvo:
			global_position.y = vendaval_altura_alvo
			velocity.y = 0.0
			vendaval_subindo = false
			vendaval_flutuando = true

	# Quando flutua, trava a altura
	elif vendaval_flutuando:
		global_position.y = vendaval_altura_alvo
		velocity.y = 0.0


func entrar_esteira(esteira: ConveyorBelt) -> void:
	esteira_atual = esteira


func sair_esteira(esteira: ConveyorBelt) -> void:
	if esteira_atual == esteira:
		esteira_atual = null



func aplicar_esteira(delta: float, input_dir: Vector2) -> void:

	if esteira_atual == null:
		return

	if not is_on_floor():
		return

	if dashing:
		return

	# Direção horizontal da esteira
	var direcao = esteira_atual.get_direcao()
	direcao.y = 0.0

	if direcao.length_squared() < 0.001:
		return

	direcao = direcao.normalized()

	# Utiliza exatamente a mesma orientação do movimento normal
	var forward = player_camera.global_transform.basis.z
	var right = player_camera.global_transform.basis.x

	forward.y = 0.0
	right.y = 0.0

	forward = forward.normalized()
	right = right.normalized()

	# Direção que o jogador está tentando seguir
	var direcao_jogador = (right * input_dir.x + forward * input_dir.y).normalized()

	# Influência do jogador sobre a esteira
	var influencia_jogador = 0.0

	if input_dir.length_squared() > 0.001:
		influencia_jogador = direcao_jogador.dot(direcao)

	# Velocidade desejada
	var velocidade_alvo = esteira_atual.velocidade_esteira + (influencia_jogador * SPEED)

	# Velocidade atual na direção da esteira
	var velocidade_atual = Vector3(velocity.x, 0.0, velocity.z)
	var velocidade_direcional = velocidade_atual.dot(direcao)

	# Ajusta a velocidade
	var nova_velocidade = move_toward(velocidade_direcional,velocidade_alvo,FORCA_ESTEIRA * delta)

	var diferenca = nova_velocidade - velocidade_direcional

	velocity.x += direcao.x * diferenca
	velocity.z += direcao.z * diferenca
