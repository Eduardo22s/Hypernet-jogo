extends Node3D
class_name Words

@onready var border: Border = $"../Environment/Border"

@onready var target: PlayerCombat = $"../PlayerCombat"
@onready var heart: Node3D = $"../Heart"

var grabbed = false
var thrown = false
var ricocheted = false
var in_heart = false

var throw_velocity = Vector3.ZERO
var throw_height: float = 0.0

const SPEED = 5.0
const THROW_SPEED = 12.0

func _on_hitzone_area_entered(area: Area3D) -> void:
	if area is Grab:
		grabbed = true
	
	if area is Border:
		var normal = area.global_transform.basis.z.normalized()
		throw_velocity = throw_velocity.bounce(normal)
		global_transform.origin += normal * 0.1
	
	if area is HeartHitzone:
		thrown = false
		in_heart = true
		Global.emit_signal("taking_damage")
		$AudioStreamPlayer.play()
		$Bubble.Destroy()


func _process(delta: float) -> void:
	if in_heart:
		global_transform.origin = heart.global_position
	
	if target && grabbed:
		throw()
		var target_position = target.global_position
		global_transform.origin = global_transform.origin.lerp(target_position, SPEED * delta)

		if Input.is_action_just_pressed("attack"):
			throw()
	elif thrown:
		global_transform.origin += throw_velocity * delta
		global_transform.origin.y = throw_height
		_contain_inside_border()

func throw() -> void:
	grabbed = false
	thrown = true

	var facing_direction = target.get_facing_direction()
	facing_direction.y = 0
	throw_velocity = facing_direction.normalized() * THROW_SPEED
	throw_height = global_transform.origin.y

func _contain_inside_border() -> void:
	var offset = global_transform.origin - border.global_position
	offset.y = 0
	var dist = offset.length()

	if dist > border.radius:
		var normal = offset.normalized()
		throw_velocity = throw_velocity.bounce(normal)
		throw_velocity.y = 0
		global_transform.origin = border.global_position + normal * border.radius
		global_transform.origin.y = throw_height
