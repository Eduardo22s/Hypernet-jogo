extends ColorRect

signal GlitchFinished

@export var Duration: float = 1.5
@export_range(0.0, 1.0) var FadeOut: float = 0.3
@export var PlayOnReady: bool = false

var ElapsedTime: float = 0.0
var IsPlaying: bool = false

var GlitchMaterial: ShaderMaterial


func _ready():
	if material is ShaderMaterial:
		GlitchMaterial = material.duplicate() as ShaderMaterial
		material = GlitchMaterial

	visible = false
	set_process(false)

	if PlayOnReady:
		PlayGlitch()


func _process(Delta):
	ElapsedTime += Delta

	var Progress = clamp(ElapsedTime / max(Duration, 0.001), 0.0, 1.0)

	GlitchMaterial.set_shader_parameter("EffectProgress", Progress)

	if ElapsedTime >= Duration:
		StopGlitch()


func PlayGlitch():
	if GlitchMaterial == null:
		push_warning("GlitchMaterial não encontrado!")
		return

	ElapsedTime = 0.0
	IsPlaying = true

	GlitchMaterial.set_shader_parameter("EffectProgress", 0.0)
	GlitchMaterial.set_shader_parameter("FadeOut", FadeOut)

	visible = true
	set_process(true)


func StopGlitch():
	IsPlaying = false
	visible = false
	set_process(false)

	GlitchFinished.emit()
