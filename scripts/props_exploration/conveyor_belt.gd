extends StaticBody3D
class_name ConveyorBelt

@export var velocidade_esteira: float = 3.0

# Desmarcado = frente
# Marcado = trás
@export var inverter_direcao: bool = false

@onready var area: Area3D = $Area3D


func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if body is PlayerExploration:
		body.entrar_esteira(self)


func _on_body_exited(body: Node3D) -> void:
	if body is PlayerExploration:
		body.sair_esteira(self)


func get_direcao() -> Vector3:
	var direcao = -global_transform.basis.z.normalized()

	if inverter_direcao:
		direcao *= -1.0

	return direcao
