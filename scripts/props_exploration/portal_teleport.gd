extends Node3D
class_name PortalTeleport

@export var destination: Node3D

@onready var anim: AnimatedSprite3D = get_node_or_null("AnimatedSprite3D")
@onready var efeito: Node = get_node_or_null("PortalEffect")


func _ready() -> void:
	_forcar_particulas_locais()

	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("abrir"):
		anim.play("abrir")


func _forcar_particulas_locais() -> void:
	if efeito == null:
		return

	for p in efeito.find_children("*", "GPUParticles3D", true, false):
		p.local_coords = true
		p.restart()

	for p in efeito.find_children("*", "CPUParticles3D", true, false):
		p.local_coords = true
		p.restart()
