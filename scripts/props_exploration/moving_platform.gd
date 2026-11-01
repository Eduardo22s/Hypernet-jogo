extends AnimatableBody3D

enum TipoMovimento {HORIZONTAL,VERTICAL}

@export var tipo_movimento: TipoMovimento = TipoMovimento.HORIZONTAL

@export var velocidade: float = 2.0
@export var distancia: float = 5.0

var posicao_inicial: Vector3
var tempo: float = 0.0

func _ready():
	posicao_inicial = global_position
	sync_to_physics = true

func _physics_process(delta):
	tempo += delta * velocidade

	var deslocamento = sin(tempo) * distancia

	var nova_posicao = posicao_inicial

	if tipo_movimento == TipoMovimento.HORIZONTAL:
		nova_posicao.x += deslocamento

	elif tipo_movimento == TipoMovimento.VERTICAL:
		nova_posicao.y += deslocamento

	global_position = nova_posicao
