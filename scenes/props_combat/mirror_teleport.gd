extends Node3D
class_name MirrorTeleport

## Onde o player aparece ao atravessar este espelho.
## Use um Marker3D posicionado na frente do OUTRO espelho.
@export var destination: Node3D


func _ready() -> void:
	if destination == null:
		push_warning("%s: destination não foi definido no inspetor" % name)
