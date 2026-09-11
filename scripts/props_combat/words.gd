extends Node3D
class_name Words

@onready var target: PlayerCombat = $"../PlayerCombat"
@onready var heart: Node3D = $"../Heart"

var grabbed = false
var thrown = false
var throw_velocity = Vector3.ZERO

const SPEED = 5.0
const THROW_SPEED = 12.0

func _on_hitzone_area_entered(area: Area3D) -> void:
	if area is Grab:
		grabbed = true
	
	if area is Border:
		thrown = false
	
	if area is HeartHitzone:
		thrown = false
		Global.emit_signal("taking_damage")
		global_transform.origin = heart.global_position

func _process(delta: float) -> void:
	if target && grabbed:
		var target_position = target.global_position
		global_transform.origin = global_transform.origin.lerp(target_position, SPEED * delta)

		if Input.is_action_just_pressed("attack"):
			throw()
	elif thrown:
		global_transform.origin += throw_velocity * delta

func throw() -> void:
	grabbed = false
	thrown = true

	var facing_direction = target.get_facing_direction()
	throw_velocity = facing_direction.normalized() * THROW_SPEED
