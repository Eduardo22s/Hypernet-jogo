extends Area3D

@export var altura_sustentacao := 5.0
@export var forca_vento:=9.0
@export var tamanho_area:= Vector3(3.0,8.0,3.0)

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$AnimatedSprite3D.play("Idle")
	
	var shape_node:= $CollisionShape3D as CollisionShape3D
	if shape_node.shape is BoxShape3D:
		shape_node.shape = shape_node.shape.duplicate()
		shape_node.shape.size = tamanho_area
		shape_node.position.y= tamanho_area.y*0.5


func _on_body_entered(body):
	if body is PlayerExploration:
		body.entrar_vendaval(self)

func _on_body_exited(body):
	if body is PlayerExploration:
		body.sair_vendaval(self)
