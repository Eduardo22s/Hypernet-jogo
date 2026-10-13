
class_name S_ScreenFlash
extends ColorRect


@export_group("Flash")

@export var FlashColor: Color = Color.WHITE
@export_range(0.1, 10.0, 0.1) var TotalDuration: float = 5.0
@export_range(0.0, 5.0, 0.05) var HoldDuration: float = 0.15


@export_group("Speed")

@export_range(0.1, 5.0, 0.1) var ExpansionSpeed: float = 1.0
@export_range(0.1, 5.0, 0.1) var RetractionSpeed: float = 1.0


@export_group("Appearance")

@export_range(0.001, 0.5, 0.001) var Softness: float = 0.04
@export_range(0.1, 2.0, 0.05) var MaxRadius: float = 1.2
@export_range(2.0, 64.0, 1.0) var PixelSize: float = 10.0
@export_range(0.0, 1.0, 0.05) var Fragmentation: float = 0.7


var _FlashMaterial: ShaderMaterial
var _FlashTween: Tween


func _ready() -> void:
	_FlashMaterial = material as ShaderMaterial

	if _FlashMaterial == null:
		push_error("S_ScreenFlash precisa de um ShaderMaterial.")
		return

	_FlashMaterial = _FlashMaterial.duplicate() as ShaderMaterial
	material = _FlashMaterial

	_UpdateShaderParameters()
	_SetProgress(0.0)

	mouse_filter = Control.MOUSE_FILTER_IGNORE

func PlayFlash() -> void:
	if _FlashMaterial == null:
		return

	if _FlashTween != null and _FlashTween.is_running():
		_FlashTween.kill()

	_UpdateShaderParameters()
	_SetProgress(0.0)

	var SafeTotalDuration: float = maxf(TotalDuration, 0.1)
	var SafeHoldDuration: float = minf(HoldDuration, SafeTotalDuration * 0.9)
	var MovingDuration: float = SafeTotalDuration - SafeHoldDuration
	var SafeExpansionSpeed: float = maxf(ExpansionSpeed, 0.1)
	var SafeRetractionSpeed: float = maxf(RetractionSpeed, 0.1)
	var ExpansionDuration: float = MovingDuration * (1.0 / SafeExpansionSpeed) / ((1.0 / SafeExpansionSpeed) + (1.0 / SafeRetractionSpeed))
	var RetractionDuration: float = MovingDuration - ExpansionDuration

	_FlashTween = create_tween()

	_FlashTween.tween_method(_SetProgress, 0.0, 1.0, ExpansionDuration)
	_FlashTween.tween_interval(SafeHoldDuration)
	_FlashTween.tween_method(_SetProgress, 1.0, 0.0, RetractionDuration)


func _UpdateShaderParameters() -> void:
	_FlashMaterial.set_shader_parameter("FlashColor", FlashColor)
	_FlashMaterial.set_shader_parameter("Softness", Softness)
	_FlashMaterial.set_shader_parameter("MaxRadius", MaxRadius)
	_FlashMaterial.set_shader_parameter("PixelSize", PixelSize)
	_FlashMaterial.set_shader_parameter("Fragmentation", Fragmentation)


func _SetProgress(Value: float) -> void:
	if _FlashMaterial != null:
		_FlashMaterial.set_shader_parameter("Progress", Value)
