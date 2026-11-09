extends Node3D

@export var seconds: int

@export var portal_scene: PackedScene          # arraste portal_teleport.tscn aqui
@export var portal_spawn_point: Marker3D       # onde o portal aparece
@export var portal_destino: Marker3D           # para onde o player vai

var atacando := false
var recompensa_ativada := false
var player_perto: PlayerExploration = null
var portal_criado := false

@onready var sprite: AnimatedSprite2D = $SubViewport/Doorman2dModel/AnimatedSprite2D


func _process(_delta: float) -> void:
	if recompensa_ativada or not is_instance_valid(player_perto):
		return

	if pode_passar():
		liberar()
	elif not atacando:
		atacar()


func pode_passar() -> bool:
	# Só passa se tiver MAIS tempo do que o segurança exige
	return Global.seconds > seconds


func liberar() -> void:
	recompensa_ativada = true
	$AudioStreamPlayer.play()
	sprite.play("reward")
	spawnar_portal()
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(sprite):
		sprite.play("idle")


func spawnar_portal() -> void:
	if portal_criado or portal_scene == null or portal_spawn_point == null:
		return
	portal_criado = true

	var portal := portal_scene.instantiate() as PortalTeleport
	portal.destination = portal_destino
	get_parent().add_child(portal)
	portal.global_transform = portal_spawn_point.global_transform
	portal.reset_physics_interpolation()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is PlayerExploration:
		player_perto = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body == player_perto:
		player_perto = null
		if not atacando and not recompensa_ativada:
			sprite.play("idle")


func atacar() -> void:
	if atacando or recompensa_ativada or not is_instance_valid(player_perto):
		return

	atacando = true
	var alvo = player_perto
	
	$AudioStreamPlayer2.play()
	sprite.play("hitting")

	await get_tree().create_timer(0.35).timeout

	# Só acerta se o player continuar perto e ainda sem tempo suficiente
	if is_instance_valid(alvo) and alvo == player_perto and not pode_passar():
		alvo.aplicar_knockback(global_position, 10.0, 3.0)

	await get_tree().create_timer(0.4).timeout

	atacando = false

	if not recompensa_ativada:
		sprite.play("idle")
