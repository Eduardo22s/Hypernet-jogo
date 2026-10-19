
extends Node

signal EffectFinished

@export_group("Referências")
@export var TargetSprite: AnimatedSprite2D
@export var TargetCollision: CollisionShape2D
@export var EffectMaterial: ShaderMaterial

@export_group("Flash")
@export_range(0.01, 1.0, 0.01) var FlashInDuration: float = 0.06
@export_range(0.01, 1.0, 0.01) var FlashOutDuration: float = 0.16

@export_group("Derretimento")
@export_range(0.1, 5.0, 0.1) var MeltDuration: float = 3

var IsPlaying: bool = false
var OriginalMaterial: Material
var RuntimeMaterial: ShaderMaterial


func PlayDeathEffect() -> void:
	print("CoraçãoMorteEffect: PlayDeathEffect foi chamado!")

	if IsPlaying:
		print("CoraçãoMorteEffect: o efeito já está em execução.")
		return

	if TargetSprite == null:
		push_warning("CoraçãoMorteEffect: atribua TargetSprite no Inspector.")
		return

	if EffectMaterial == null:
		push_warning("CoraçãoMorteEffect: atribua EffectMaterial no Inspector.")
		return

	if EffectMaterial.shader == null:
		push_warning("CoraçãoMorteEffect: o ShaderMaterial não possui shader.")
		return

	IsPlaying = true

	# Guarda o material que o sprite estava usando.
	OriginalMaterial = TargetSprite.material

	# Cria uma cópia independente para animar os parâmetros.
	RuntimeMaterial = EffectMaterial.duplicate() as ShaderMaterial

	if RuntimeMaterial == null:
		push_warning("CoraçãoMorteEffect: não foi possível duplicar o material.")
		IsPlaying = false
		return

	TargetSprite.material = RuntimeMaterial

	# Congela a animação no quadro atual.
	TargetSprite.pause()

	# Desativa a colisão durante o efeito, se houver uma configurada.
	if TargetCollision != null:
		TargetCollision.set_deferred("disabled", true)

	# Reinicia os parâmetros do shader.
	RuntimeMaterial.set_shader_parameter("FlashAmount", 0.0)
	RuntimeMaterial.set_shader_parameter("MeltProgress", 0.0)

	print("CoraçãoMorteEffect: iniciando flash.")

	# Etapa 1: o sprite fica branco e depois recupera suas cores.
	var FlashTween: Tween = create_tween()

	FlashTween.tween_property(
		RuntimeMaterial,
		"shader_parameter/FlashAmount",
		1.0,
		FlashInDuration
	)

	FlashTween.tween_property(
		RuntimeMaterial,
		"shader_parameter/FlashAmount",
		0.0,
		FlashOutDuration
	)

	await FlashTween.finished

	print("CoraçãoMorteEffect: iniciando derretimento.")

	# Etapa 2: os pixels começam a desaparecer.
	var MeltTween: Tween = create_tween()

	MeltTween.tween_property(
		RuntimeMaterial,
		"shader_parameter/MeltProgress",
		1.0,
		MeltDuration
	)

	await MeltTween.finished

	# Etapa 3: garante que o sprite desapareça completamente.
	TargetSprite.visible = false

	print("CoraçãoMorteEffect: efeito finalizado.")

	IsPlaying = false
	EffectFinished.emit()


func ResetDeathEffect() -> void:
	if TargetSprite == null:
		return

	# Restaura o material e a visibilidade para permitir novo teste.
	TargetSprite.visible = true
	TargetSprite.material = OriginalMaterial

	if TargetCollision != null:
		TargetCollision.set_deferred("disabled", false)

	if RuntimeMaterial != null:
		RuntimeMaterial.set_shader_parameter("FlashAmount", 0.0)
		RuntimeMaterial.set_shader_parameter("MeltProgress", 0.0)

	IsPlaying = false

	print("CoraçãoMorteEffect: efeito reiniciado.")
