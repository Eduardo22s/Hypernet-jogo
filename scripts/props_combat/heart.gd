extends Node3D

@onready var border: Border = $"../Environment/Border"

@export var start_delay: float = 1.75
@export var start_direction: Vector3 = Vector3.RIGHT
@export var bounce_random_angle_deg: float = 35.0

var thrown = false
var throw_velocity = Vector3.ZERO
var throw_height: float = 0.0

const THROW_SPEED = 12.0


func _on_hitzone_area_entered(area: Area3D) -> void:
	if area is Border:
		var normal = area.global_transform.basis.z.normalized()
		normal.y = 0
		_bounce(normal)
		global_transform.origin += normal * 0.1


func _ready() -> void:
	Global.taking_damage.connect(_take_damage)
	throw_height = global_transform.origin.y
	$SubViewport/Heart2dModel/AnimatedJuice.play("hit_init")

	await get_tree().create_timer(start_delay).timeout
	$SubViewport/Heart2dModel/AnimatedJuice.visible = false
	_start_moving()

func _process(delta: float) -> void:
	if thrown:
		global_transform.origin += throw_velocity * delta
		global_transform.origin.y = throw_height
		_contain_inside_border()


func _start_moving() -> void:
	var direction = start_direction
	direction.y = 0
	throw_velocity = direction.normalized() * THROW_SPEED
	thrown = true

func _contain_inside_border() -> void:
	var offset = global_transform.origin - border.global_position
	offset.y = 0
	var dist = offset.length()

	if dist > border.radius:
		var normal = offset.normalized()
		_bounce(normal)
		global_transform.origin = border.global_position + normal * border.radius
		global_transform.origin.y = throw_height

func _bounce(normal: Vector3) -> void:
	throw_velocity = throw_velocity.bounce(normal)
	throw_velocity.y = 0

	var angle = deg_to_rad(randf_range(-bounce_random_angle_deg, bounce_random_angle_deg))
	throw_velocity = throw_velocity.rotated(Vector3.UP, angle)

func _take_damage():
	$SubViewport/Heart2dModel/AnimatedHeart.play("hit")
	await get_tree().create_timer(2.0).timeout
	$SubViewport/Heart2dModel/AnimatedHeart.play("normal")
