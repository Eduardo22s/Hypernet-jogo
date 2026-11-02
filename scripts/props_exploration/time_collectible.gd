extends Area3D

@export_enum("1 segundo:1", "3 segundos:3", "5 segundos:5", "10 segundos:10")
var bonus_seconds: int = 1

var collected: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$AnimatedSprite3D2.visible = false
	$AnimatedSprite3D.play("Idle")


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	if collected:
		return

	collected = true

	# Impede que seja coletado novamente
	monitoring = false

	# Adiciona o tempo
	Global.add_time(bonus_seconds)
	$Bubble.visible = false

	# Toca a animação de coleta
	$AnimatedSprite3D2.visible = true
	$AnimatedSprite3D.play("Tempo")
	$AnimatedSprite3D2.play("Pop")
	
	# Espera a animação terminar
	await $AnimatedSprite3D2.animation_finished
	$AnimatedSprite3D2.visible = false
	
	await $AnimatedSprite3D.animation_finished

	# Faz o objeto desaparecer
	queue_free()
