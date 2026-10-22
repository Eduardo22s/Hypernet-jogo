extends CharacterBody3D

@export var velocidade: float = 3.5
@export var distancia_deteccao: float = 15.0
@export var distancia_dash: float = 4.0

@export var forca_dash: float = 16.0
@export var duracao_dash: float = 0.25
@export var tempo_preparacao: float = 0.5
@export var cooldown_dash: float = 1.5

var player: CharacterBody3D = null

var estado: String = "perseguindo"
var direcao_dash: Vector3 = Vector3.ZERO
var gravidade: float = 20.0

var timer: float = 0.0

@export var knockback_forca: float = 12.0
@export var knockback_vertical: float = 4.0

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

var acertou_player: bool = false


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as CharacterBody3D


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as CharacterBody3D
		return

	# Gravidade
	if not is_on_floor():
		velocity.y -= gravidade * delta
	else:
		if velocity.y < 0.0:
			velocity.y = 0.0

	var distancia = global_position.distance_to(player.global_position)

	match estado:
		"perseguindo":
			perseguir(delta, distancia)

		"preparando":
			preparar_dash(delta)

		"dash":
			executar_dash(delta)

		"cooldown":
			aguardar_dash(delta)

	move_and_slide()
	if estado == "dash":
		verificar_colisao_dash()



func perseguir(delta: float, distancia: float) -> void:
	if distancia > distancia_deteccao:
		velocity.x = move_toward(velocity.x, 0.0, velocidade * 4.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, velocidade * 4.0 * delta)
		return

	if distancia <= distancia_dash:
		# Mira na posição atual do jogador
		direcao_dash = player.global_position - global_position
		direcao_dash.y = 0.0

		if direcao_dash.length_squared() > 0.001:
			direcao_dash = direcao_dash.normalized()

		# Inicia o dash imediatamente
		timer = duracao_dash
		acertou_player = false
		estado = "dash"

		velocity.x = direcao_dash.x * forca_dash
		velocity.z = direcao_dash.z * forca_dash
		sprite.play("dash")
		return

	var direcao = player.global_position - global_position
	direcao.y = 0.0

	if direcao.length_squared() > 0.001:
		direcao = direcao.normalized()

		velocity.x = direcao.x * velocidade
		velocity.z = direcao.z * velocidade

		if sprite.animation != "andar" or not sprite.is_playing():
			sprite.play("andar")


func preparar_dash(delta: float) -> void:
	sprite.play("idle")
	velocity.x = 0.0
	velocity.z = 0.0

	timer -= delta

	if timer <= 0.0:
		timer = duracao_dash
		acertou_player = false
		estado = "dash"

		velocity.x = direcao_dash.x * forca_dash
		velocity.z = direcao_dash.z * forca_dash


func executar_dash(delta: float) -> void:
	sprite.play("dash")
	timer -= delta

	velocity.x = direcao_dash.x * forca_dash
	velocity.z = direcao_dash.z * forca_dash

	if timer <= 0.0:
		velocity.x = 0.0
		velocity.z = 0.0

		timer = cooldown_dash
		estado = "cooldown"


func aguardar_dash(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, velocidade * 8.0 * delta)
	velocity.z = move_toward(velocity.z, 0.0, velocidade * 8.0 * delta)

	timer -= delta

	if timer <= 0.0:
		estado = "perseguindo"



func verificar_colisao_dash() -> void:
	if acertou_player:
		return

	for i in range(get_slide_collision_count()):
		var colisao = get_slide_collision(i)
		var corpo = colisao.get_collider()

		if corpo == player:
			acertou_player = true

			if player.has_method("aplicar_knockback"):
				player.aplicar_knockback(global_position,knockback_forca,knockback_vertical)
			return
