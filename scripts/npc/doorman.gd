extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if $"../Porta".aberta == true:
		$SubViewport/Doorman2dModel/AnimatedSprite2D.play("reward")
		await get_tree().create_timer(2.0).timeout
		self.queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is PlayerExploration:
		$SubViewport/Doorman2dModel/AnimatedSprite2D.play("hitting")


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is PlayerExploration:
		$SubViewport/Doorman2dModel/AnimatedSprite2D.play("idle")
