extends Node3D

@export var door_kind: Node3D 

var atacando := false
var player_perto: PlayerExploration = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
var recompensa_ativada := false

func _process(_delta: float) -> void:
	if door_kind != null and door_kind.aberta and not recompensa_ativada:
		recompensa_ativada = true
		$SubViewport/Doorman2dModel/AnimatedSprite2D.play("reward")
		await get_tree().create_timer(2.0).timeout
		queue_free()



func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is PlayerExploration:
		player_perto = body

		if not atacando:
			atacar()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == player_perto:
		player_perto = null

		if not atacando:
			$SubViewport/Doorman2dModel/AnimatedSprite2D.play("idle")


func atacar() -> void:
	if atacando or not is_instance_valid(player_perto):
		return

	atacando = true

	var sprite = $SubViewport/Doorman2dModel/AnimatedSprite2D
	var alvo = player_perto

	sprite.play("hitting")

	# Tempo até o golpe acertar
	await get_tree().create_timer(0.35).timeout

	# Só acerta se o player continuar perto
	if is_instance_valid(alvo) and alvo == player_perto:
		alvo.aplicar_knockback(global_position, 10.0, 3.0)

	# Finaliza o ataque sem depender do sinal da animação
	await get_tree().create_timer(0.4).timeout

	if is_instance_valid(sprite):
		if is_instance_valid(player_perto):
			sprite.play("hitting")
		else:
			sprite.play("idle")

	atacando = false
