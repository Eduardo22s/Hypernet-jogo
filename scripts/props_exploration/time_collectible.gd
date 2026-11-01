extends Area3D

@export_enum("1 segundo:1", "3 segundos:3", "5 segundos:5", "10 segundos:10")
var bonus_seconds: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$AnimatedSprite3D.play("Idle")


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("player"):
		return

	Global.add_time(bonus_seconds)

	queue_free()
