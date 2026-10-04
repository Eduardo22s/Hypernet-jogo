extends Node3D
class_name WordsBad

@onready var border: Border = $"../Environment/Border"

@onready var target: PlayerCombat = $"../PlayerCombat"
@onready var heart: Node3D = $"../Heart"

@onready var animated_word_1: AnimatedSprite2D = $SubViewport/WordsBad2DModel/AnimatedWord1
@onready var animated_word_2: AnimatedSprite2D = $SubViewport/WordsBad2DModel/AnimatedWord2
@onready var animated_word_3: AnimatedSprite2D = $SubViewport/WordsBad2DModel/AnimatedWord3

var grabbed = false
var thrown = false
var ricocheted = false
var in_heart = false

var throw_velocity = Vector3.ZERO
var throw_height: float = 0.0

const SPEED = 5.0
const THROW_SPEED = 12.0


func _on_timer_timeout() -> void:
	self.queue_free()

func _on_activation_zone_area_entered(area: Area3D) -> void:
	if area is Grab:
		grabbed = true
		$Hitzone.monitoring = true
		$Sprite3D.modulate = Color(1.0, 1.0, 1.0, 1)

func _on_hitzone_area_entered(area: Area3D) -> void:
	if area is Border:
		var normal = area.global_transform.basis.z.normalized()
		throw_velocity = throw_velocity.bounce(normal)
		global_transform.origin += normal * 0.1
	
	if area is HeartHitzone:
		thrown = false
		in_heart = true
		Global.emit_signal("taking_damage")
		Global.word_kind = "Bad"
		Global.words_in_storage += 1
		Global.bad_results += 1
		$AudioStreamPlayer.play()
		$Sprite3D.visible = false
		$Bubble.visible = false

func _ready() -> void:
	change_sprite()

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


func change_sprite():
	if Global.npc_battle == "DD":
		if Global.words_in_storage == 0:
			self.animated_word_1.frame = randi_range(0, 2)
		elif Global.words_in_storage == 1:
			self.animated_word_1.frame = randi_range(0, 2)
			animated_word_1.visible = false
		elif Global.words_in_storage == 2:
			self.animated_word_1.frame = randi_range(0, 2)
			animated_word_2.visible = false

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
