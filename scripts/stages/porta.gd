extends Node3D


enum TipoResultado {GOOD,NEUTRAL,BAD}


@export_category("Requisito")
@export var tipo_resultado: TipoResultado = TipoResultado.GOOD
@export var pontos_necessarios: int = 1


var jogador_perto := false
var aberta := false


@onready var corpo: StaticBody3D = $Corpo
@onready var area: Area3D = $Area3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
	area.body_entered.connect(_on_area_body_entered)
	area.body_exited.connect(_on_area_body_exited)


func _process(_delta):
	if jogador_perto and not aberta:
		if Input.is_action_just_pressed("interagir"):
			tentar_abrir()


func _on_area_body_entered(body):
	if body is PlayerExploration:
		jogador_perto = true


func _on_area_body_exited(body):
	if body is PlayerExploration:
		jogador_perto = false


func tentar_abrir():
	if pode_abrir():
		abrir()
	else:
		mostrar_requisito()


func pode_abrir() -> bool:
	return get_pontos() >= pontos_necessarios


func get_pontos() -> int:
	match tipo_resultado:
		TipoResultado.GOOD:
			return Global.good_results

		TipoResultado.NEUTRAL:
			return Global.neutral_results

		TipoResultado.BAD:
			return Global.bad_results

	return 0


func abrir():
	if aberta:
		return

	aberta = true

	corpo.set_collision_layer_value(1, false)
	corpo.set_collision_mask_value(1, false)

	animation_player.play("abrindo")


func mostrar_requisito():
	print("Pontos insuficientes!")
