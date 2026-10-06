class_name PatrolState
extends State

@export var speed := 1.5
@export var rotation_speed := 5.0
@export var random_radius := 5.0

var target_point: Node3D
var model: Node3D


func enter() -> void:
	model = npc.get_node("Day_Dream")

	# Começa indo para o PointB
	target_point = npc.point_b


func update(delta: float) -> void:
	if target_point == null:
		return

	var target_position := target_point.global_position

	# Mantém o NPC na mesma altura
	target_position.y = npc.global_position.y

	var direction := target_position - npc.global_position

	# Chegou ao ponto
	if direction.length() < 0.1:
		_on_reach_point()
		return

	direction = direction.normalized()

	# Movimento
	npc.global_position += direction * speed * delta

	# Rotação do modelo
	var target_angle := atan2(direction.x, direction.z)

	model.rotation.y = lerp_angle(model.rotation.y,target_angle,rotation_speed * delta)


func _on_reach_point() -> void:
	# Escolhe qual ponto acabou de alcançar
	if target_point == npc.point_a:
		# PointA foi alcançado
		randomize_point(npc.point_a)

		# Agora vai para PointB
		target_point = npc.point_b

	else:
		# PointB foi alcançado
		randomize_point(npc.point_b)

		# Agora vai para PointA
		target_point = npc.point_a


func randomize_point(point: Node3D) -> void:
	var random_x := randf_range(-random_radius, random_radius)
	var random_z := randf_range(-random_radius, random_radius)

	point.global_position = npc.global_position + Vector3(random_x,0.0,random_z)
