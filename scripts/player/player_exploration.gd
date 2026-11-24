extends CharacterBody3D
class_name PlayerExploration

# =============================================================================
# CONSTANTES
# =============================================================================

# --- Movimento ---
const ACELERACAO := 20.0
const DESACELERACAO := 8.0
const CONTROLE_AEREO := 5.0

# --- Pulo ---
const JUMP_VELOCITY := 8.0
const JUMP_CUT_MULTIPLIER := 0.4      # soltar o botão no meio do pulo corta a subida
const MULTIPLICADOR_QUEDA := 1.7      # gravidade extra ao cair
const COYOTE_TEMPO := 0.20
const BUFFER_TEMPO := 0.30

# --- Dash ---
# O tempo segurando o botão define a distância: um toque dura o mínimo,
# e segurar estende o dash até o máximo. Distância ~ FORCA * duração.
const DASH_CHAO_FORCA := 15.0
const DASH_CHAO_DURACAO_MIN := 0.10
const DASH_CHAO_DURACAO_MAX := 0.35
const DASH_AEREO_FORCA := 10.0
const DASH_AEREO_DURACAO_MIN := 0.08
const DASH_AEREO_DURACAO_MAX := 0.26

# --- Parede ---
const WALL_CHECK_DIST := 0.7          # alcance da detecção (um pouco maior que o raio do player)
const WALL_RAY_COUNT := 8             # quantidade de raios ao redor
const WALL_RAY_HEIGHT := 0.5          # altura do raio em relação ao pé do player
const LIMITE_NORMAL_PAREDE := 0.5     # normais com |y| >= isso são chão/teto, não parede

const WALL_JUMP_FORCE := 8.0
const WALL_JUMP_VERTICAL := 7.0
const WALL_KICK_DASH_FORCE := 14.0
const WALL_KICK_DASH_VERTICAL := 8.0
const WALL_COYOTE := 0.12

const WALL_SLIDE_VELOCIDADE := -1.0   # velocidade máxima de queda na parede
const WALL_SLIDE_SUAVIZACAO := 20.0   # quão rápido a queda é "freada"
const WALL_SLIDE_ANGULO_MIN := 0.3    # exige estar minimamente virado/pressionando a parede

# --- Superfícies e zonas ---
const DESACELERACAO_ESTEIRA := 6.0

const VELOCIDADE_MAX_GELO := 14.0
const GELO_RAIO_ALTURA := 0.5
const GELO_RAIO_ALCANCE := 3.0
const GELO_RAMPA_LIMIAR := 0.999      # abaixo disso o chão é considerado rampa

const VENDAVAL_BLOQUEIO_PULO := 0.35
const VENDAVAL_BALANCO_VELOCIDADE := 0.003
const VENDAVAL_BALANCO_AMPLITUDE := 0.2
const VENDAVAL_GANHO := 4.0
const VENDAVAL_VY_MIN := -3.0
const VENDAVAL_ACELERACAO := 40.0

# --- Interações ---
const BALAO_FORCA := 0.5
const BALAO_FORCA_DASH := 2.0

const BUMPER_MIN_SPEED := 9.0
const BUMPER_PUSH_DISTANCE := 0.15
const BUMPER_CENTRO_Y := 0.1
const KNOCKBACK_DURATION := 0.25

const MIRROR_INTERVALO := 0.5         # segundos de espera entre um teleporte e outro
const COLETAVEL_ICONE_DURACAO := 0.75

# --- Câmera ---
const SENSIBILIDADE_MOUSE := 0.003
const PITCH_LIMITE_GRAUS := 70.0

# --- Modo voo (debug) ---
const CODIGO_VOO := "VOAR"
const VOO_VELOCIDADE := 12.0
const VOO_VELOCIDADE_RAPIDA := 30.0   # segurando Shift
const VOO_SUAVIZACAO := 10.0

# --- Fases / cheats ---
var checkpoint_atual: Node3D = null
var checkpoint_return = preload("res://scenes/props_exploration/checkpoint.tscn")
const CENA_JARDIM := "res://scenes/stages/fase_jardim.tscn"
const CENA_FLIPERAMA := "res://scenes/stages/fase_fliperama.tscn"
const CENA_GAME_OVER := "res://scenes/stages/game_over_menu.tscn"
const TEMPO_ATE_GAME_OVER := 4.5

const POSICOES_DE_ENTRADA := {
	"arcade_routeA": Vector3(-40.3, 71.8, -7.4),
	"arcade_routeB": Vector3(-27.0, 61.0, 45.0),
	"igloo": Vector3(-57.1, 136.1, 5.8),
	"fall_to_garden": Vector3(-23.5, 74.6, 7.5),
	"fall_to_arcade": Vector3(-28.5, 140.5, -0.6),
}

const CHEATS_DE_FASE := {
	"cheat_garden": {"which_way": "", "cena": CENA_JARDIM},
	"cheat_arcade": {"which_way": "arcade_routeA", "cena": CENA_FLIPERAMA},
	"cheat_igloo": {"which_way": "igloo", "cena": CENA_FLIPERAMA},
}

# --- Animação de movimento ---
# A ordem importa: a primeira combinação pressionada vence.
# Sem "flip", o flip_h atual do sprite é mantido.
const ANIMACOES_MOVIMENTO := [
	{"acoes": ["move_right", "move_forward"], "anim": "diagonal_up", "flip": true},
	{"acoes": ["move_left", "move_forward"], "anim": "diagonal_up", "flip": false},
	{"acoes": ["move_right", "move_backward"], "anim": "diagonal_down", "flip": true},
	{"acoes": ["move_left", "move_backward"], "anim": "diagonal_down", "flip": false},
	{"acoes": ["move_left"], "anim": "sides", "flip": false},
	{"acoes": ["move_right"], "anim": "sides", "flip": true},
	{"acoes": ["move_forward"], "anim": "up"},
	{"acoes": ["move_backward"], "anim": "down"},
]

# =============================================================================
# NÓS
# =============================================================================

@onready var player_camera: Camera3D = $Cameras/SpringArm1/Camera1
@onready var cameras: Node3D = $Cameras
@onready var spring_arm: Node3D = $Cameras/SpringArm1
@onready var balloon_detector: Area3D = $BalloonDetector
@onready var mirror_detector: Area3D = $MirrorDetector
@onready var bumper_detector: Area3D = $BumperDetector
@onready var passos_player: AudioStreamPlayer = $AudioStreamPlayer

# Sem tipo de propósito: o tipo exato dos sprites não é conhecido aqui.
@onready var moving_sprite = $SubViewport/Player2dModel/AnimatedMoving
@onready var idle_sprite = $SubViewport/Player2dModel/AnimatedIdle

# =============================================================================
# ESTADO
# =============================================================================

var SPEED := 5.0
var call_once := true

# Pulo
var bufferTimer := 0.0
var coyoteTimer := 0.0
var jump_pad_atual: Area3D = null

# Dash
var dashing := false
var dash_aereo_disponivel := true
var dash_tempo := 0.0
var dash_duracao_min := 0.0
var dash_duracao_max := 0.0

# Parede
var na_parede := false
var normal_parede := Vector3.ZERO
var wall_jump_usado := false
var ultima_parede_normal := Vector3.ZERO
var wall_sliding := false
var wall_coyote_timer := 0.0
var normal_parede_coyote := Vector3.ZERO

# Bumper / knockback
var bumper_knockback_timer := 0.0

# Teleporte
var mirror_teleporting := false

# Vendaval
var dentro_vendaval := false
var vendaval_forca := 0.0
var vendaval_altura_alvo := 0.0
var vendaval_atual: Area3D = null
var vendaval_bloqueio := 0.0

# Esteira
var esteira_atual: ConveyorBelt = null
var velocidade_esteira_atual := Vector3.ZERO

# Gelo
var gelo_atual: IcePlatform = null
var normal_chao := Vector3.UP

# Câmera
var camera_pitch := 0.0

# Modo voo
var modo_voo := false
var codigo_digitado := ""
var mascara_colisao_original := 0

# Não usados neste script; mantidos caso outros scripts/cenas dependam deles.
@export var mirror_teleports: Array[Node3D] = []
var throw_velocity := Vector3.ZERO
var throw_height := 0.0

# =============================================================================
# CICLO DE VIDA
# =============================================================================

func _ready() -> void:
	Global.end_game = false
	Global.stop_player = false
	Global.words_in_storage = 0
	call_once = true

	$HUD/Fade/AnimationPlayer.play_backwards("fade")
	add_to_group("player")
	mirror_detector.area_entered.connect(_on_mirror_detector_area_entered)
	bumper_detector.area_entered.connect(_on_bumper_area_entered)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if POSICOES_DE_ENTRADA.has(Global.which_way):
		global_position = POSICOES_DE_ENTRADA[Global.which_way]


func _unhandled_input(_event: InputEvent) -> void:
	if modo_voo:
		return
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		$AudioStreamPlayer3.play()
	if Input.is_action_just_pressed("dash") and not dashing:
		$AudioStreamPlayer2.play()


func _input(event: InputEvent) -> void:
	_checar_codigo_voo(event)

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_girar_camera(event.relative)

	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(_delta: float) -> void:
	if Global.end_game:
		await _processar_game_over()
		return

	Global.stop_player = false
	SPEED = 5.0
	await _checar_cheats_de_fase()


func _physics_process(delta: float) -> void:
	if modo_voo:
		_processar_voo(delta)
		return

	jump_to_checkpoint()
	create_checkpoints()
	_atualizar_animacao()
	_atualizar_vendaval(delta)
	_aplicar_gravidade(delta)
	_atualizar_coyote_e_buffer(delta)
	detectar_gelo()
	detectar_parede_area()
	_atualizar_wall_coyote(delta)
	_processar_pulo()

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := _get_move_direction(input_dir)
	atualizar_wall_slide(delta, direction)

	_processar_input_dash()
	_atualizar_dash(delta)

	if bumper_knockback_timer > 0.0:
		bumper_knockback_timer -= delta
		_mover_e_empurrar_baloes()
		return

	if dashing:
		_mover_e_empurrar_baloes()
		check_dash_wall_collision()
		return

	_aplicar_movimento_horizontal(direction, delta)
	aplicar_gelo(delta)
	aplicar_esteira(delta)

	velocity += velocidade_esteira_atual
	move_and_slide()
	velocity -= velocidade_esteira_atual
	empurrar_baloes()

# =============================================================================
# FIM DE JOGO / CHEATS
# =============================================================================

func _processar_game_over() -> void:
	Global.stop_player = true

	if call_once:
		Global.which_way = ""
		$AudioStreamPlayer4.play()
		$Cameras/AnimationPlayer.play("death")
		$HUD/Flash/S_ScreenFlashLayer/ScreenFlash.PlayFlash()
		$HUD/Fade/AnimationPlayer.play("fade")
		call_once = false

	set_process(false)
	set_physics_process(false)
	await get_tree().create_timer(TEMPO_ATE_GAME_OVER).timeout
	await get_tree().process_frame
	get_tree().change_scene_to_file(CENA_GAME_OVER)


func _checar_cheats_de_fase() -> void:
	for acao in CHEATS_DE_FASE:
		if Input.is_action_just_pressed(acao):
			await _trocar_de_fase(CHEATS_DE_FASE[acao])
			return


func _trocar_de_fase(destino: Dictionary) -> void:
	Global.which_way = destino["which_way"]
	set_process(false)
	set_physics_process(false)
	await get_tree().process_frame
	get_tree().change_scene_to_file(destino["cena"])

# =============================================================================
# ANIMAÇÃO
# =============================================================================

func _atualizar_animacao() -> void:
	for entrada in ANIMACOES_MOVIMENTO:
		if not _todas_pressionadas(entrada["acoes"]):
			continue

		idle_sprite.visible = false
		moving_sprite.visible = true
		if entrada.has("flip"):
			moving_sprite.flip_h = entrada["flip"]
		moving_sprite.play(entrada["anim"])
		return

	idle_sprite.visible = true
	moving_sprite.visible = false


func _todas_pressionadas(acoes: Array) -> bool:
	for acao in acoes:
		if not Input.is_action_pressed(acao):
			return false
	return true


func _set_footstep(ativo: bool) -> void:
	$VFX_Footstep.emitting = ativo


## Toca a playlist de passos enquanto anda no chão; para nos outros casos.
func _atualizar_som_passos(andando: bool) -> void:
	if andando:
		if not passos_player.playing:
			passos_player.play()
	elif passos_player.playing:
		passos_player.stop()

# =============================================================================
# MOVIMENTO BASE
# =============================================================================

## Eixo da câmera projetado no plano horizontal (ignora a inclinação vertical).
func _eixo_horizontal(eixo: Vector3) -> Vector3:
	eixo.y = 0.0
	return eixo.normalized()


## Direção de movimento relativa à câmera. Zero se não houver input.
func _get_move_direction(input_dir: Vector2) -> Vector3:
	var cam_basis := player_camera.global_transform.basis
	var direita := _eixo_horizontal(cam_basis.x)
	var tras := _eixo_horizontal(cam_basis.z)
	return (direita * input_dir.x + tras * input_dir.y).normalized()


func get_camera_direction() -> Vector3:
	var forward := -cameras.global_transform.basis.z
	forward.y = 0.0

	if forward.length_squared() <= 0.001:
		return Vector3.ZERO

	return forward.normalized()


func _aplicar_gravidade(delta: float) -> void:
	if is_on_floor() or dashing or dentro_vendaval:
		return

	velocity += get_gravity() * delta
	if velocity.y < 0.0:
		velocity += get_gravity() * (MULTIPLICADOR_QUEDA - 1.0) * delta


func _aplicar_movimento_horizontal(direction: Vector3, delta: float) -> void:
	var alvo := Vector2.ZERO
	var taxa := DESACELERACAO

	if direction:
		alvo = Vector2(direction.x, direction.z) * SPEED
		taxa = ACELERACAO
		if not is_on_floor():
			taxa = CONTROLE_AEREO
		elif gelo_atual:
			taxa = gelo_atual.aceleracao_gelo
	elif gelo_atual:
		taxa = gelo_atual.aceleracao_gelo

	velocity.x = move_toward(velocity.x, alvo.x, taxa * delta)
	velocity.z = move_toward(velocity.z, alvo.y, taxa * delta)
	var andando := direction != Vector3.ZERO and is_on_floor()
	_set_footstep(direction != Vector3.ZERO)
	_atualizar_som_passos(andando)


## Move sem controle do jogador (knockback e dash).
func _mover_e_empurrar_baloes() -> void:
	_set_footstep(false)
	_atualizar_som_passos(false)
	move_and_slide()
	empurrar_baloes()

# =============================================================================
# PULO
# =============================================================================

func _atualizar_coyote_e_buffer(delta: float) -> void:
	if is_on_floor():
		coyoteTimer = COYOTE_TEMPO
		dash_aereo_disponivel = true
		wall_jump_usado = false
	else:
		coyoteTimer -= delta

	if Input.is_action_just_pressed("ui_accept"):
		if jump_pad_atual != null:
			jump_pad_atual.ativar(self)
			bufferTimer = 0.0
		else:
			bufferTimer = BUFFER_TEMPO
	else:
		bufferTimer -= delta


func _processar_pulo() -> void:
	if bufferTimer > 0.0:
		var pode_wall_jump := (na_parede or wall_coyote_timer > 0.0) \
				and not wall_jump_usado \
				and not dentro_vendaval \
				and not is_on_floor()

		if pode_wall_jump:
			if not na_parede:
				na_parede = true
				normal_parede = normal_parede_coyote
			wall_coyote_timer = 0.0
			wall_jump()
			_consumir_buffer_de_pulo()

		elif coyoteTimer > 0.0 or dentro_vendaval:
			if vendaval_atual != null:
				dentro_vendaval = false
				vendaval_bloqueio = VENDAVAL_BLOQUEIO_PULO
			velocity.y = JUMP_VELOCITY
			_consumir_buffer_de_pulo()

	# Soltar o botão corta a subida (pulo variável)
	if Input.is_action_just_released("ui_accept") and velocity.y > 0.0:
		velocity.y *= JUMP_CUT_MULTIPLIER


func _consumir_buffer_de_pulo() -> void:
	bufferTimer = 0.0
	coyoteTimer = 0.0

# =============================================================================
# DASH
# =============================================================================

func _processar_input_dash() -> void:
	if not Input.is_action_just_pressed("dash") or dashing:
		return

	$OrbitalPivot/AnimationAttack.play("attack")
	if is_on_floor():
		dash()
	else:
		dash_aereo()


## Dash no chão. A distância cresce com o tempo segurando o botão.
func dash() -> void:
	if dashing:
		return
	_iniciar_dash(DASH_CHAO_FORCA, DASH_CHAO_DURACAO_MIN, DASH_CHAO_DURACAO_MAX)


## Dash no ar (um por pulo). A distância cresce com o tempo segurando o botão.
func dash_aereo() -> void:
	if dashing or not dash_aereo_disponivel:
		return
	dash_aereo_disponivel = false
	_iniciar_dash(DASH_AEREO_FORCA, DASH_AEREO_DURACAO_MIN, DASH_AEREO_DURACAO_MAX)
	velocity.y = 0.0


func _iniciar_dash(forca: float, duracao_min: float, duracao_max: float) -> void:
	dashing = true
	dash_tempo = 0.0
	dash_duracao_min = duracao_min
	dash_duracao_max = duracao_max

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direcao := _get_dash_direction(input_dir)
	velocity.x = direcao.x * forca
	velocity.z = direcao.z * forca


## Sem input, o dash vai para onde a câmera olha; com input, segue os controles.
func _get_dash_direction(input_dir: Vector2) -> Vector3:
	if input_dir.length_squared() <= 0.001:
		return -_eixo_horizontal(player_camera.global_transform.basis.z)
	return _get_move_direction(input_dir)


## O dash dura no mínimo `dash_duracao_min`; depois disso continua enquanto o
## botão estiver pressionado, até `dash_duracao_max`.
func _atualizar_dash(delta: float) -> void:
	if not dashing:
		return

	dash_tempo += delta

	var atingiu_maximo := dash_tempo >= dash_duracao_max
	var soltou_apos_minimo := not Input.is_action_pressed("dash") and dash_tempo >= dash_duracao_min
	if atingiu_maximo or soltou_apos_minimo:
		dashing = false


func check_dash_wall_collision() -> void:
	if not dashing:
		return

	for i in get_slide_collision_count():
		var normal := get_slide_collision(i).get_normal()
		if absf(normal.y) < LIMITE_NORMAL_PAREDE:
			normal_parede = normal
			wall_kick_dash()
			return


func wall_kick_dash() -> void:
	if not dashing:
		return

	wall_jump_usado = true
	ultima_parede_normal = normal_parede
	dashing = false
	dash_aereo_disponivel = false

	velocity = Vector3(
		normal_parede.x * WALL_KICK_DASH_FORCE,
		WALL_KICK_DASH_VERTICAL,
		normal_parede.z * WALL_KICK_DASH_FORCE
	)

# =============================================================================
# PAREDE
# =============================================================================

func detectar_parede_area() -> void:
	na_parede = false
	normal_parede = Vector3.ZERO

	if is_on_floor():
		return

	var origem := global_position + Vector3.UP * WALL_RAY_HEIGHT
	var melhor_dist := INF
	var melhor_normal := Vector3.ZERO

	for i in WALL_RAY_COUNT:
		var ang := TAU * i / WALL_RAY_COUNT
		var dir := Vector3(cos(ang), 0.0, sin(ang))

		var hit := _raycast(origem, origem + dir * WALL_CHECK_DIST)
		if hit.is_empty():
			continue

		var n: Vector3 = hit.normal
		if absf(n.y) >= LIMITE_NORMAL_PAREDE:   # ignora chão e teto
			continue

		var dist := origem.distance_to(hit.position)
		if dist < melhor_dist:
			melhor_dist = dist
			melhor_normal = n

	if melhor_normal == Vector3.ZERO:
		return

	melhor_normal.y = 0.0
	na_parede = true
	normal_parede = melhor_normal.normalized()

	# Como o GridMap é um corpo só, a "parede nova" é detectada pela normal, não pelo nó
	if normal_parede.dot(ultima_parede_normal) < 0.9:
		wall_jump_usado = false


func _atualizar_wall_coyote(delta: float) -> void:
	if na_parede:
		wall_coyote_timer = WALL_COYOTE
		normal_parede_coyote = normal_parede
	else:
		wall_coyote_timer -= delta


func wall_jump() -> void:
	if not na_parede or wall_jump_usado:
		return

	wall_jump_usado = true
	ultima_parede_normal = normal_parede
	dashing = false

	# Empurra para longe da parede e sobe
	var direcao := _eixo_horizontal(normal_parede)
	velocity = Vector3(
		direcao.x * WALL_JUMP_FORCE,
		WALL_JUMP_VERTICAL,
		direcao.z * WALL_JUMP_FORCE
	)


func atualizar_wall_slide(delta: float, direction: Vector3) -> void:
	wall_sliding = false

	if is_on_floor() or dashing or dentro_vendaval or not na_parede:
		return
	if velocity.y > 0.0:   # só desliza quando está caindo
		return

	# Só desliza se o jogador estiver empurrando na direção da parede
	# (normal_parede aponta para fora da parede, então o input contra ela é o oposto)
	if direction.length_squared() <= 0.001 or direction.dot(-normal_parede) < WALL_SLIDE_ANGULO_MIN:
		return

	wall_sliding = true
	velocity.y = move_toward(velocity.y, WALL_SLIDE_VELOCIDADE, WALL_SLIDE_SUAVIZACAO * delta)

# =============================================================================
# SUPERFÍCIES E ZONAS (gelo, esteira, vendaval)
# =============================================================================

func _raycast(origem: Vector3, destino: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(origem, destino)
	query.exclude = [get_rid()]
	query.collision_mask = collision_mask
	return get_world_3d().direct_space_state.intersect_ray(query)


func detectar_gelo() -> void:
	gelo_atual = null
	normal_chao = Vector3.UP

	if not is_on_floor():
		return

	var origem := global_position + Vector3.UP * GELO_RAIO_ALTURA
	var hit := _raycast(origem, origem + Vector3.DOWN * GELO_RAIO_ALCANCE)
	if hit.is_empty():
		return

	normal_chao = hit.normal
	if hit.collider is IcePlatform:
		gelo_atual = hit.collider


func aplicar_gelo(delta: float) -> void:
	floor_stop_on_slope = gelo_atual == null

	if gelo_atual == null:
		return

	if normal_chao.y < GELO_RAMPA_LIMIAR:
		var gravidade := Vector3.DOWN * gelo_atual.gravidade_rampa
		var deslize := gravidade.slide(normal_chao)
		velocity.x += deslize.x * delta
		velocity.z += deslize.z * delta

	var horizontal := Vector2(velocity.x, velocity.z).limit_length(VELOCIDADE_MAX_GELO)
	velocity.x = horizontal.x
	velocity.z = horizontal.y


func entrar_esteira(esteira: ConveyorBelt) -> void:
	esteira_atual = esteira


func sair_esteira(esteira: ConveyorBelt) -> void:
	if esteira_atual == esteira:
		esteira_atual = null


func aplicar_esteira(delta: float) -> void:
	if esteira_atual != null and is_on_floor() and not dashing:
		var direcao: Vector3 = esteira_atual.get_direcao()
		direcao.y = 0.0

		if direcao.length_squared() > 0.001:
			velocidade_esteira_atual = direcao.normalized() * esteira_atual.velocidade_esteira
			return

	velocidade_esteira_atual = velocidade_esteira_atual.move_toward(Vector3.ZERO, DESACELERACAO_ESTEIRA * delta)


func entrar_vendaval(area: Area3D) -> void:
	vendaval_atual = area
	vendaval_forca = area.forca_vento
	bufferTimer = 0.0   # descarta pulo bufferizado ao entrar na zona
	if vendaval_bloqueio <= 0.0:
		_ativar_vendaval()


func sair_vendaval(area: Area3D) -> void:
	if vendaval_atual == area:
		vendaval_atual = null
		dentro_vendaval = false


func _ativar_vendaval() -> void:
	dentro_vendaval = true
	vendaval_altura_alvo = global_position.y + vendaval_atual.altura_sustentacao


func _atualizar_vendaval(delta: float) -> void:
	if vendaval_bloqueio > 0.0:
		vendaval_bloqueio -= delta
		if vendaval_bloqueio <= 0.0 and vendaval_atual != null and not dentro_vendaval:
			_ativar_vendaval()

	if dentro_vendaval:
		var balanco := sin(Time.get_ticks_msec() * VENDAVAL_BALANCO_VELOCIDADE) * VENDAVAL_BALANCO_AMPLITUDE
		var erro := (vendaval_altura_alvo + balanco) - global_position.y
		var vy_alvo := clampf(erro * VENDAVAL_GANHO, VENDAVAL_VY_MIN, vendaval_forca)
		velocity.y = move_toward(velocity.y, vy_alvo, VENDAVAL_ACELERACAO * delta)

# =============================================================================
# INTERAÇÕES (bumper, balões, espelhos/portais, coletáveis)
# =============================================================================

func aplicar_knockback(origem: Vector3, forca: float, vertical: float) -> void:
	var dir := global_position - origem
	dir.y = 0.0

	if dir.length_squared() < 0.001:
		dir = player_camera.global_transform.basis.z
		dir.y = 0.0

	dir = dir.normalized()
	velocity.x = dir.x * forca
	velocity.z = dir.z * forca
	velocity.y = vertical

	dashing = false
	bumper_knockback_timer = KNOCKBACK_DURATION


func _on_bumper_area_entered(area: Area3D) -> void:
	if not area.is_in_group("player_bumpers"):
		return

	var sprite = area.get_node_or_null("AnimatedSprite3D")
	if sprite:
		sprite.stop()
		sprite.play("Idle")

	# Direção do centro do bumper até o centro aproximado do jogador
	var centro_jogador := global_position + Vector3.UP * BUMPER_CENTRO_Y
	var normal := centro_jogador - area.global_position
	if normal.length_squared() < 0.001:
		return
	normal = normal.normalized()

	# Ricochete: preserva a velocidade tangencial e reflete a de impacto
	var impacto := velocity.dot(normal)
	var velocidade_lateral := velocity.slide(normal)
	var forca_saida := maxf(-impacto, BUMPER_MIN_SPEED)
	velocity = velocidade_lateral + normal * forca_saida

	dash_aereo_disponivel = true
	dashing = false
	wall_jump_usado = false

	global_position += normal * BUMPER_PUSH_DISTANCE   # pequeno afastamento


func create_checkpoints() -> void:
	if not Input.is_action_just_pressed("create_checkpoint"):
		return
	if Global.points < 100 or Global.checkpoints >= 3:
		return

	Global.points -= 100
	Global.checkpoints += 1

	if is_instance_valid(checkpoint_atual):
		checkpoint_atual.queue_free()

	Global.checkpoint_in_scene = true
	checkpoint_atual = checkpoint_return.instantiate()
	get_parent().add_child(checkpoint_atual)
	checkpoint_atual.global_position = global_position
	Global.checkpoint_pos = checkpoint_atual.global_position

func jump_to_checkpoint():
	if Input.is_action_just_pressed("jump_to_checkpoint") && Global.checkpoint_in_scene:
		global_position = Global.checkpoint_pos
		$AudioStreamPlayer5.play()
	else:
		return


func empurrar_baloes() -> void:
	for corpo in balloon_detector.get_overlapping_bodies():
		var balao := corpo as RigidBody3D
		if balao == null or not balao.is_in_group("balloon"):
			continue

		var direcao := balao.global_position - global_position
		direcao.y = 0.0
		if direcao.length_squared() <= 0.001:
			continue

		var forca := BALAO_FORCA_DASH if dashing else BALAO_FORCA
		balao.apply_central_impulse(direcao.normalized() * forca)


func _on_mirror_detector_area_entered(area: Area3D) -> void:
	if mirror_teleporting:
		return

	if area is PortalZone:
		var portal := _encontrar_ancestral(area, PortalTeleport) as PortalTeleport
		if portal == null or portal.destination == null:
			push_warning("Portal sem destination")
			return
		velocity = Vector3.ZERO
		teleport_player(portal.destination)

	elif area is MirrorZone:
		var espelho := _encontrar_ancestral(area, MirrorTeleport) as MirrorTeleport
		if espelho == null or espelho.destination == null:
			push_warning("Espelho sem destination ou sem MirrorTeleport acima da zona")
			return
		teleport_player(espelho.destination)


# Mantido caso esteja conectado no editor.
func _on_mirror_detector_area_exited(_area: Area3D) -> void:
	pass


## Sobe pela árvore a partir de `no` até achar um nó do tipo `tipo`.
func _encontrar_ancestral(no: Node, tipo: Variant) -> Node:
	while no != null:
		if is_instance_of(no, tipo):
			return no
		no = no.get_parent()
	return null


func teleport_player(destino: Node3D) -> void:
	$AudioStreamPlayer5.play()
	set_physics_process(false)
	mirror_teleporting = true
	dashing = false   # o dash não pode continuar "congelado" durante o teleporte
	global_position = destino.global_position

	await get_tree().create_timer(MIRROR_INTERVALO).timeout
	set_physics_process(true)
	mirror_teleporting = false


func _on_collectable_detector_area_entered(area: Area3D) -> void:
	var icone := _icone_do_coletavel(area)
	if icone == null:
		return

	$HUD/Collectables/AnimationPlayer.play("collecting")
	icone.visible = true

	await get_tree().create_timer(COLETAVEL_ICONE_DURACAO).timeout

	icone.visible = false


func _icone_do_coletavel(area: Area3D) -> Node:
	if area is Collectable1seg:
		return $HUD/Collectables/AnimatedCollect1
	if area is Collectable3seg:
		return $HUD/Collectables/AnimatedCollect2
	if area is Collectable5seg:
		return $HUD/Collectables/AnimatedCollect3
	if area is Collectable10seg:
		return $HUD/Collectables/AnimatedCollect4
	return null

# =============================================================================
# CÂMERA
# =============================================================================

func _girar_camera(relative: Vector2) -> void:
	# Rotação horizontal
	cameras.rotate_y(-relative.x * SENSIBILIDADE_MOUSE)

	# Rotação vertical
	var limite := deg_to_rad(PITCH_LIMITE_GRAUS)
	camera_pitch = clampf(camera_pitch - relative.y * SENSIBILIDADE_MOUSE, -limite, limite)
	spring_arm.rotation.x = camera_pitch

# =============================================================================
# MODO VOO (debug) — ative digitando o código em CODIGO_VOO
# =============================================================================

func _checar_codigo_voo(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return

	var letra := OS.get_keycode_string(event.keycode).to_upper()
	if letra.length() != 1:
		return

	# Mantém só as últimas letras digitadas, do tamanho do código
	codigo_digitado = (codigo_digitado + letra).right(CODIGO_VOO.length())

	if codigo_digitado == CODIGO_VOO:
		codigo_digitado = ""
		alternar_modo_voo()


func alternar_modo_voo() -> void:
	modo_voo = not modo_voo

	if modo_voo:
		mascara_colisao_original = collision_mask
		collision_mask = 0   # atravessa tudo (noclip). Comente esta linha se quiser colidir.
		velocity = Vector3.ZERO
		dashing = false
		wall_sliding = false
		dentro_vendaval = false
		velocidade_esteira_atual = Vector3.ZERO
		bumper_knockback_timer = 0.0
	else:
		collision_mask = mascara_colisao_original
		velocity = Vector3.ZERO
		dash_aereo_disponivel = true
		wall_jump_usado = false

	print("Modo voo: ", "ATIVADO" if modo_voo else "DESATIVADO")


func _processar_voo(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	# Usa a câmera inteira (com o pitch), então voa para onde você olha
	var cam_basis := player_camera.global_transform.basis
	var direcao := cam_basis.x * input_dir.x + cam_basis.z * input_dir.y

	# Sobe com Espaço, desce com Ctrl
	if Input.is_key_pressed(KEY_SPACE):
		direcao += Vector3.UP
	if Input.is_key_pressed(KEY_CTRL):
		direcao += Vector3.DOWN

	var vel := VOO_VELOCIDADE_RAPIDA if Input.is_key_pressed(KEY_SHIFT) else VOO_VELOCIDADE
	var alvo := direcao.normalized() * vel if direcao.length_squared() > 0.001 else Vector3.ZERO

	velocity = velocity.lerp(alvo, clampf(VOO_SUAVIZACAO * delta, 0.0, 1.0))
	move_and_slide()
