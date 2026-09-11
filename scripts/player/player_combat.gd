extends CharacterBody3D
class_name PlayerCombat

const JUMP_VELOCITY = 5.2

const velQueda = 1.7
const controleAereo = 5.0
const freiarAereo = 8.0

const aceleracao = 20.0
const desaceleracao = 8.0
const coyote = 0.20
const buffer = 0.15
const freiar = 20.0

@onready var myself = $"." as Node3D
@onready var pivot = $OrbitalPivot
@onready var orbit_attack = $OrbitalPivot/Attack as Node3D
@onready var attack_collision = $OrbitalPivot/Attack/Area3D/CollisionShape3D

var SPEED = 5.0
var bufferTimer = 0.0
var coyoteTimer = 0.0

var orbit_speed := 100.0
var cooldown = false
var cooldown_time = 0

func _ready():
	Global.invert_bools(["stop_player"])
	Global.trigger_battle = false

func _process(delta: float) -> void:
	if Global.stop_player:
		SPEED = 0.0
	else:
		SPEED = 5.0

	if cooldown_time <= 1:
		cooldown = true
	else:
		cooldown = false

	if cooldown_time >= 0:
		cooldown_time -= cooldown_time * delta


func _physics_process(delta: float) -> void:
	handle_attack()

	var moving_sprite = $SubViewport/Player2dModel/AnimatedMoving
	var idle_sprite = $SubViewport/Player2dModel/AnimatedIdle

	var move_right := Input.is_action_pressed("move_right")
	var move_left := Input.is_action_pressed("move_left")
	var move_up := Input.is_action_pressed("move_forward")
	var move_down := Input.is_action_pressed("move_backward")

	if move_right and move_up:
		idle_sprite.visible = false
		moving_sprite.visible = true
		moving_sprite.flip_h = true
		moving_sprite.play("diagonal_up")

	elif move_left and move_up:
		idle_sprite.visible = false
		moving_sprite.visible = true
		moving_sprite.flip_h = false
		moving_sprite.play("diagonal_up")

	elif move_right and move_down:
		idle_sprite.visible = false
		moving_sprite.visible = true
		moving_sprite.flip_h = true
		moving_sprite.play("diagonal_down")

	elif move_left and move_down:
		idle_sprite.visible = false
		moving_sprite.visible = true
		moving_sprite.flip_h = false
		moving_sprite.play("diagonal_down")

	elif move_left:
		idle_sprite.visible = false
		moving_sprite.visible = true
		moving_sprite.flip_h = false
		moving_sprite.play("sides")

	elif move_right:
		idle_sprite.visible = false
		moving_sprite.visible = true
		moving_sprite.flip_h = true
		moving_sprite.play("sides")

	elif move_up:
		idle_sprite.visible = false
		moving_sprite.visible = true
		moving_sprite.play("up")

	elif move_down:
		idle_sprite.visible = false
		moving_sprite.visible = true
		moving_sprite.play("down")

	else:
		idle_sprite.visible = true
		moving_sprite.visible = false
		$AudioStreamPlayer3D.stop()

	#gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta
		# Queda mais rápida
		if velocity.y < 0:
			velocity += get_gravity() * (velQueda - 1.0) * delta

	#coyote time
	if is_on_floor():
		coyoteTimer = coyote
	else:
		coyoteTimer -= delta

	#buffer
	if Input.is_action_just_pressed("ui_accept"):
		bufferTimer = buffer
	else:
		bufferTimer -= delta

	#pulo
	if bufferTimer > 0 and coyoteTimer > 0:
		velocity.y = JUMP_VELOCITY

		bufferTimer = 0
		coyoteTimer = 0

	#pulo dinamico
	if Input.is_action_just_released("ui_accept") and velocity.y > 0:
		velocity.y *= 0.4

	var input_dir := Input.get_vector("move_left","move_right","move_forward","move_backward")
	var forward = myself.global_transform.basis.z
	var right = myself.global_transform.basis.x

	forward.y = 0
	right.y = 0

	forward = forward.normalized()
	right = right.normalized()

	var direction = (right * input_dir.x +forward * input_dir.y).normalized()
	if direction:
		var target_velocity = direction * SPEED
		var velocidade_atual = Vector3(velocity.x,0,velocity.z)
		var aceleracaoAtual = aceleracao
		var freioAtual = freiar
		
		if not is_on_floor():
			freioAtual = freiarAereo
			aceleracaoAtual = controleAereo
		
		#freiagem
		if velocidade_atual.length() > 0:
			var dot = velocidade_atual.normalized().dot(direction)

			if dot < 0:
				# freiando
				velocity.x = move_toward(velocity.x,0,freioAtual * delta)
				velocity.z = move_toward(velocity.z,0,freioAtual * delta)
			else:
				#normal
				velocity.x = move_toward(velocity.x,target_velocity.x,aceleracaoAtual * delta)
				velocity.z = move_toward(velocity.z,target_velocity.z,aceleracaoAtual * delta)
		else:
			# aceleração
			velocity.x = move_toward(velocity.x,target_velocity.x,aceleracaoAtual * delta)
			velocity.z = move_toward(velocity.z,target_velocity.z,aceleracaoAtual * delta)

	# desaceleração
	else:
		velocity.x = move_toward(velocity.x,0,desaceleracao * delta)
		velocity.z = move_toward(velocity.z,0,desaceleracao * delta)
	
	move_and_slide()
	
	
	var horizontal_movement = Vector2(velocity.x, velocity.z).length()
	
	if horizontal_movement > 0.1:
		var target_pos = orbit_attack.global_transform.origin + Vector3(-velocity.x, 0, -velocity.z)
		pivot.rotate_y(orbit_speed * delta)
		
		orbit_attack.look_at(target_pos, Vector3.UP)

func get_facing_direction() -> Vector3:
	return orbit_attack.global_transform.basis.z

func handle_attack():
	if cooldown:
		if Input.is_action_pressed("attack"):
			$OrbitalPivot/Attack/Area3D/CollisionShape3D.position.z += 0.1
			if $OrbitalPivot/Attack/Area3D/CollisionShape3D.position.z >= 10.0:
				$OrbitalPivot/Attack/Area3D/CollisionShape3D.position.z = 10.0

		if Input.is_action_just_released("attack"):
			$OrbitalPivot/AnimationAttack.play("attack")
			attack_collision.disabled = false
			await get_tree().create_timer(0.5).timeout
			$OrbitalPivot/Attack/Area3D/CollisionShape3D.position.z = 0
			attack_collision.disabled = true
			cooldown_time = 3.0
