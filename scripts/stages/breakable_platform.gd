extends StaticBody3D
class_name BreakablePlatform


@export var tempo_antes_quebrar := 1      # tempo entre pisar e quebrar
@export var tempo_respawn := 3.0            # tempo para voltar (0 = nunca volta)
@export var intensidade_tremor := 0.04
@export var respawn_ativo := true

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var colisao: CollisionShape3D = $CollisionShape3D
@onready var detector: Area3D = $DetectorTopo

var ativada := false
var quebrada := false
var tremendo := false
var posicao_original := Vector3.ZERO


func _ready() -> void:
	posicao_original = mesh.position
	detector.body_entered.connect(_on_detector_body_entered)


func _process(_delta: float) -> void:
	if tremendo:
		mesh.position = posicao_original + Vector3(
			randf_range(-intensidade_tremor, intensidade_tremor),0.0,randf_range(-intensidade_tremor, intensidade_tremor))


func _on_detector_body_entered(body: Node3D) -> void:
	if ativada or quebrada:
		return

	if not body.is_in_group("player"):
		return

	ativada = true
	iniciar_quebra()


func iniciar_quebra() -> void:
	tremendo = true

	await get_tree().create_timer(tempo_antes_quebrar).timeout

	quebrar()


func quebrar() -> void:
	tremendo = false
	quebrada = true
	mesh.position = posicao_original

	# set_deferred evita erro ao mexer na física durante o callback de colisão
	colisao.set_deferred("disabled", true)
	mesh.visible = false

	if not respawn_ativo:
		return

	await get_tree().create_timer(tempo_respawn).timeout

	restaurar()


func restaurar() -> void:
	colisao.set_deferred("disabled", false)
	mesh.visible = true
	quebrada = false
	ativada = false

	# Se o jogador ainda estiver em cima quando voltar, quebra de novo
	for body in detector.get_overlapping_bodies():
		if body.is_in_group("player"):
			ativada = true
			iniciar_quebra()
			break
