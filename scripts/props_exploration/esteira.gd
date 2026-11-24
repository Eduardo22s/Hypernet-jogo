extends Node3D

enum tipo {Vermelho, Azul}

@export var tipo_esteira : tipo


func _process(_delta: float) -> void:
	if tipo_esteira == tipo.Vermelho:
		$AnimatedSprite3D.visible = false
		$AnimatedSprite3D2.visible = true
	else:
		$AnimatedSprite3D.visible = true
		$AnimatedSprite3D2.visible = false
