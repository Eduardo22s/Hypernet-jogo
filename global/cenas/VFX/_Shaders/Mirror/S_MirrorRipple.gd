
extends Area3D

@export var MirrorMesh: MeshInstance3D

var MirrorMaterial: ShaderMaterial
var RingTween: Tween


func _ready() -> void:
	if MirrorMesh == null:
		push_error("MirrorMesh não foi atribuído no Inspector.")
		return

	MirrorMaterial = MirrorMesh.get_active_material(0) as ShaderMaterial

	if MirrorMaterial == null:
		push_error("ShaderMaterial não encontrado no MirrorMesh.")
		return

	MirrorMaterial.set_shader_parameter("RingProgress", 1.0)

func PlayRingAnimation() -> void:
	if MirrorMaterial == null:
		return

	if RingTween != null and RingTween.is_running():
		RingTween.kill()

	var Duration: float = MirrorMaterial.get_shader_parameter("RingDuration")

	MirrorMaterial.set_shader_parameter("RingProgress", 0.0)

	RingTween = create_tween()
	RingTween.tween_method(SetRingProgress, 0.0, 1.0, Duration)


func SetRingProgress(Value: float) -> void:
	if MirrorMaterial != null:
		MirrorMaterial.set_shader_parameter("RingProgress", Value)


func _on_body_entered(_Body: Node3D) -> void:
	PlayRingAnimation()
