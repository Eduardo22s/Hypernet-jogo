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

@onready var player_exploration: PlayerExploration = $"." as Node3D

@export var mirror_teleports: Array[Node3D] = []

@onready var mirror_teleport = preload("res://scenes/props_combat/mirror_teleport.tscn")

@onready var mirror_detector: Area3D = $MirrorDetector

@onready var border: Border = $"../Environment/Border"

@onready var bumper_detector: Area3D = $BumperDetector

const BUMPER_MIN_SPEED = 9.0
const BUMPER_PUSH_DISTANCE = 0.15
var dash_id := 0

var bumper_knockback_timer := 0.0
const BUMPER_KNOCKBACK_DURATION = 0.18
const KNOCKBACK_DURATION = 0.25

var throw_velocity = Vector3.ZERO
var throw_height: float = 0.0

const MIRROR_INTERVALO := 0.5   # segundos de espera entre um teleporte e outro
var mirror_teleporting = false

var dentro_vendaval := false
var vendaval_forca :=0.0
var vendaval_altura_alvo := 0.0
var vendaval_atual: Area3D = null
var vendaval_bloqueio := 0.0
const VENDAVAL_BLOQUEIO_PULO := 0.35


var esteira_atual: ConveyorBelt = null
const FORCA_ESTEIRA := 12.0
var velocidade_esteira_atual :=Vector3.ZERO
const DESACELERACAO_ESTEIRA:=6.0

var gelo_atual:IcePlatform=null
var normal_chao:=Vector3.UP
const VELOCIDADE_MAX_GELO:=14.0

var call_once = true

var jump_pad_atual: Area3D = null

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") && is_on_floor():
		$AudioStreamPlayer3.play()

	if Input.is_action_just_pressed("dash") and not dashing:
		$AudioStreamPlayer2.play()

func _ready():
	#Global.reset_timer()
	Global.end_game = false
	call_once = true
	$HUD/Fade/AnimationPlayer.play_backwards("fade")
	add_to_group("player")
	mirror_detector.area_entered.connect(_on_mirror_detector_area_entered)
	bumper_detector.area_entered.connect(_on_bumper_area_entered)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	#global_position = Global.player_return_pos
	Global.stop_player = false
	Global.words_in_storage = 0
	
	if Global.which_way == "arcade_routeA":
		global_position = Vector3(-40.3, 71.8, -7.4)
		
	if Global.which_way == "arcade_routeB":
		global_position = Vector3(-27.0, 61.0, 45.0)
		
	if Global.which_way == "igloo":
		global_position = Vector3(-57.1, 136.1, 5.8)
	
	if Global.which_way == "fall_to_garden":
		global_position = Vector3(-23.5, 74.6, 7.5)
	
	if Global.which_way == "fall_to_arcade":
		global_position = Vector3(-28.5, 140.5, -0.6)

func _process(_delta: float) -> void:
	if Global.end_game:
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
		await get_tree().create_timer(4.5).timeout
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://scenes/stages/game_over_menu.tscn")
	else:
		Global.stop_player = false

	if Global.stop_player:
		SPEED = 0.0
	else:
		SPEED = 5.0
		
	if Input.is_action_just_pressed("cheat_garden"):
		Global.which_way = ""
		set_process(false)
		set_physics_process(false)
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://scenes/stages/fase_jardim.tscn")

	if Input.is_action_just_pressed("cheat_arcade"):
		Global.which_way = "arcade_routeA"
		set_process(false)
		set_physics_process(false)
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://scenes/stages/fase_fliperama.tscn")

	if Input.is_action_just_pressed("cheat_igloo"):
		Global.which_way = "igloo"
		set_process(false)
		set_physics_process(false)
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://scenes/stages/fase_fliperama.tscn")


func _physics_process(delta: float) -> void:
	var moving_sprite = $SubViewport/Player2dModel/AnimatedMoving
	var idle_sprite = $SubViewport/Player2dModel/AnimatedIdle

	var move_right := Input.is_action_pressed("move_right")
	var move_left := Input.is_action_pressed("move_left")
	var move_up := Input.is_action_pressed("move_forward")
	var move_down := Input.is_action_pressed("move_backward")
	
	if vendaval_bloqueio > 0.0:
		vendaval_bloqueio -= delta
		if vendaval_bloqueio <= 0.0 and vendaval_atual != null and not dentro_vendaval:
			_ativar_vendaval()
	
	if dentro_vendaval:
		var balanco:= sin(Time.get_ticks_msec()*0.003)*0.2
		var erro:= (vendaval_altura_alvo+balanco)-global_position.y
		var vy_alvo:= clampf(erro*4.0,-3.0,vendaval_forca)
		velocity.y=move_toward(velocity.y,vy_alvo,40.0*delta)
		

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
	detectar_gelo()
	detectar_parede_area()

	if bufferTimer > 0.0:
		if na_parede and not wall_jump_usado and not dentro_vendaval:
			wall_jump()

			bufferTimer = 0.0
			coyoteTimer = 0.0

		elif coyoteTimer > 0.0 or dentro_vendaval:
			if vendaval_atual != null:
				dentro_vendaval = false
				vendaval_bloqueio = VENDAVAL_BLOQUEIO_PULO
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
		empurrar_baloes()
		return

	if dashing:
		$VFX_Footstep.emitting = false

		move_and_slide()
		empurrar_baloes()
		check_dash_wall_collision()
		return

	if direction:
		var target_velocity = direction * SPEED
		var aceleracaoAtual = aceleracao
		if not is_on_floor():
			aceleracaoAtual = controleAereo
		elif gelo_atual:
			aceleracaoAtual = gelo_atual.aceleracao_gelo

		velocity.x = move_toward(velocity.x,target_velocity.x,aceleracaoAtual * delta)
		velocity.z = move_toward(velocity.z,target_velocity.z,aceleracaoAtual * delta)

		$VFX_Footstep.emitting = true

	else:
		var desacel = desaceleracao
		if gelo_atual:
			desacel=gelo_atual.aceleracao_gelo
		velocity.x = move_toward(velocity.x,0.0,desacel * delta)
		velocity.z = move_toward(velocity.z,0.0,desacel * delta)

		$VFX_Footstep.emitting = false

	aplicar_gelo(delta)
	aplicar_esteira(delta, input_dir)

	velocity+=velocidade_esteira_atual
	move_and_slide()
	velocity-=velocidade_esteira_atual
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
	dash_id += 1
	var meu_id := dash_id

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

	if dashing and dash_id == meu_id:
		dashing = false

func dash_aereo():
	if not dash_aereo_disponivel:
		return
	if dashing:
		return

	dash_aereo_disponivel = false
	dashing = true
	dash_id += 1
	var meu_id := dash_id

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

	if dashing and dash_id == meu_id:
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
	if mirror_teleporting:
		return

	if area is PortalZone:
		var portal := _encontrar_portal(area)
		if portal == null or portal.destination == null:
			push_warning("Portal sem destination")
			return
		dashing = false
		velocity = Vector3.ZERO
		teleport_player(portal.destination)
		return

	if not (area is MirrorZone):
		return

	var espelho := _encontrar_espelho(area)
	if espelho == null or espelho.destination == null:
		push_warning("Espelho sem destination ou sem MirrorTeleport acima da zona")
		return

	teleport_player(espelho.destination)


func _encontrar_portal(zona: Node) -> PortalTeleport:
	var no: Node = zona
	while no != null:
		if no is PortalTeleport:
			return no as PortalTeleport
		no = no.get_parent()
	return null

func _on_mirror_detector_area_exited(area: Area3D) -> void:
	if area is MirrorZone:
		pass


func teleport_player(destino: Node3D) -> void:
	$AudioStreamPlayer5.play()
	mirror_teleporting = true
	global_position = destino.global_position

	await get_tree().create_timer(MIRROR_INTERVALO).timeout
	mirror_teleporting = false


func _encontrar_espelho(zona: Node) -> MirrorTeleport:
	var no: Node = zona
	while no != null:
		if no is MirrorTeleport:
			return no as MirrorTeleport
		no = no.get_parent()
	return null



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

	dash_aereo_disponivel = true
	dashing = false
	wall_jump_usado = false

	# Evita que a movimentação anule o impulso
	#bumper_knockback_timer = BUMPER_KNOCKBACK_DURATION

	# Pequeno afastamento
	global_position += normal * BUMPER_PUSH_DISTANCE
	
	



func entrar_esteira(esteira: ConveyorBelt) -> void:
	esteira_atual = esteira


func sair_esteira(esteira: ConveyorBelt) -> void:
	if esteira_atual == esteira:
		esteira_atual = null



func aplicar_esteira(delta: float, input_dir: Vector2) -> void:
	var esteira_ativada:=esteira_atual !=null and is_on_floor() and not dashing
	
	if esteira_ativada:
		var direcao = esteira_atual.get_direcao()
		direcao.y=0.0
		
		if direcao.length_squared() > 0.001:
			direcao=direcao.normalized()
			velocidade_esteira_atual=direcao*esteira_atual.velocidade_esteira
			return
		
	velocidade_esteira_atual=velocidade_esteira_atual.move_toward(Vector3.ZERO,DESACELERACAO_ESTEIRA*delta)




func aplicar_knockback(origem:Vector3,forca:float,vertical:float)-> void:
	var dir:=global_position-origem
	dir.y=0.0
	
	if dir.length_squared()<0.001:
		dir=player_camera.global_transform.basis.z
		dir.y=0.0
	
	dir=dir.normalized()
	velocity.x=dir.x*forca
	velocity.z=dir.z*forca
	velocity.y=vertical
	
	dashing=false
	bumper_knockback_timer=KNOCKBACK_DURATION


func detectar_gelo()->void:
	gelo_atual=null
	normal_chao = Vector3.UP
	
	if not is_on_floor():
		return
	var space:=get_world_3d().direct_space_state
	var origem:= global_position + Vector3.UP*0.5
	var query:= PhysicsRayQueryParameters3D.create(origem, origem + Vector3.DOWN*3.0)
	query.exclude = [get_rid()]
	query.collision_mask = collision_mask
	
	var hit:= space.intersect_ray(query)
	if hit.is_empty():
		return

	normal_chao= hit.normal
	if hit.collider is IcePlatform:
		gelo_atual=hit.collider


func aplicar_gelo(delta:float)->void:
	floor_stop_on_slope=gelo_atual == null
	
	if gelo_atual == null:
		return

	if normal_chao.y<0.999:
		var gravidade:=Vector3.DOWN* gelo_atual.gravidade_rampa
		var deslize:= gravidade.slide(normal_chao)
		velocity.x += deslize.x* delta
		velocity.z += deslize.z* delta
		
	var horizontal:=Vector2(velocity.x, velocity.z)
	if horizontal.length() > VELOCIDADE_MAX_GELO:
		horizontal= horizontal.normalized()*VELOCIDADE_MAX_GELO
		velocity.x = horizontal.x
		velocity.z = horizontal.y


func _on_collectable_detector_area_entered(area: Area3D) -> void:
	if area is Collectable1seg:
		$HUD/Collectables/AnimationPlayer.play("collecting")
		$HUD/Collectables/AnimatedCollect1.visible = true
		
		await get_tree().create_timer(0.75).timeout
		$HUD/Collectables/AnimatedCollect1.visible = false

	if area is Collectable3seg:
		$HUD/Collectables/AnimationPlayer.play("collecting")
		$HUD/Collectables/AnimatedCollect2.visible = true
		
		await get_tree().create_timer(0.75).timeout
		$HUD/Collectables/AnimatedCollect2.visible = false

	if area is Collectable5seg:
		$HUD/Collectables/AnimationPlayer.play("collecting")
		$HUD/Collectables/AnimatedCollect3.visible = true
		
		await get_tree().create_timer(0.75).timeout
		$HUD/Collectables/AnimatedCollect3.visible = false

	if area is Collectable10seg:
		$HUD/Collectables/AnimationPlayer.play("collecting")
		$HUD/Collectables/AnimatedCollect4.visible = true
		
		await get_tree().create_timer(0.75).timeout
		$HUD/Collectables/AnimatedCollect4.visible = false


func entrar_vendaval(area: Area3D) -> void:
	vendaval_atual = area
	vendaval_forca = area.forca_vento
	bufferTimer = 0.0  # descarta pulo bufferizado ao entrar na zona
	if vendaval_bloqueio <= 0.0:
		_ativar_vendaval()

func sair_vendaval(area: Area3D) -> void:
	if vendaval_atual == area:
		vendaval_atual = null
		dentro_vendaval = false

func _ativar_vendaval() -> void:
	dentro_vendaval = true
	vendaval_altura_alvo = global_position.y + vendaval_atual.altura_sustentacao
