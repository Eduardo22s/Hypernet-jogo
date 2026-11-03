extends Area3D
class_name JumpPad

@export var jump_force: float = 12.0

var players_inside: Array[PlayerExploration] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$AnimatedSprite3D.play("Idle")


func _on_body_entered(body: Node3D) -> void:
	if body is PlayerExploration:
		if not players_inside.has(body):
			players_inside.append(body)
			body.jump_pad_atual = self


func _on_body_exited(body: Node3D) -> void:
	if body is PlayerExploration:
		players_inside.erase(body)

		if body.jump_pad_atual == self:
			body.jump_pad_atual = null


func ativar(player: PlayerExploration) -> void:
	if not players_inside.has(player):
		return

	player.velocity.y = jump_force
	player.bufferTimer = 0.0
	player.coyoteTimer = 0.0
