extends Area3D

@export var altura_sustentacao := 5.0

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$AnimatedSprite3D.play("Idle")


func _on_body_entered(body):

	if body is PlayerExploration:

		body.dentro_vendaval = true
		body.vendaval_subindo = true
		body.vendaval_flutuando = false
		body.vendaval_altura_alvo = (body.global_position.y + altura_sustentacao)


func _on_body_exited(body):

	if body is PlayerExploration:

		body.dentro_vendaval = false
		body.vendaval_subindo = false
		body.vendaval_flutuando = false
