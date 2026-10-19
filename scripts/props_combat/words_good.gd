extends Node3D
class_name WordsGood

@onready var border: Border = $"../Environment/Border"

@onready var target: PlayerCombat = $"../PlayerCombat"
@onready var heart: Node3D = $"../Heart"

var inactive = true
var grabbed = false
var thrown = false
var ricocheted = false
var in_heart = false

var one_shot = false

var throw_velocity = Vector3.ZERO
var throw_height: float = 0.0

const SPEED = 5.0
const THROW_SPEED = 12.0


func _on_activation_zone_area_entered(area: Area3D) -> void:
	if area is Grab:
		Global.word_selected = true
		self.inactive = false
		grabbed = true
		$Sprite3D.modulate = Color(1.0, 1.0, 1.0, 1)

		if !one_shot:
			$Hitzone.monitoring = true
			one_shot = true

func _on_hitzone_area_entered(area: Area3D) -> void:
	if area is Border:
		var normal = area.global_transform.basis.z.normalized()
		throw_velocity = throw_velocity.bounce(normal)
		throw_velocity *= 0.5
		global_transform.origin += normal * 0.1
	
	if area is HeartHitzone:
		thrown = false
		in_heart = true
		Global.emit_signal("taking_damage")
		Global.word_kind = "Good"
		Global.words_in_storage += 1
		Global.good_results += 1
		$".".visible = false
		$Hitzone.queue_free()
		$AudioStreamPlayer.play()
		$Flash/S_ScreenFlashLayer/ScreenFlash.PlayFlash()

	if area is MirrorZone:
		var random_mirror = randi_range(1, 4)
		match random_mirror:
			1:
				global_transform.origin = $"../MirrorTeleport".global_position
			2:
				global_transform.origin = $"../MirrorTeleport2".global_position
			3:
				global_transform.origin = $"../MirrorTeleport3".global_position
			4:
				global_transform.origin = $"../MirrorTeleport4".global_position


func _ready() -> void:
	change_sprite()

func _process(delta: float) -> void:
	if in_heart:
		global_transform.origin = heart.global_position
	
	if inactive and Global.word_selected:
		queue_free()
	
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
			$SubViewport/WordsGood2DModel/AnimatedWord1.play("DD1")
		elif Global.words_in_storage == 1:
			$SubViewport/WordsGood2DModel/AnimatedWord2.play("DD2")
			$SubViewport/WordsGood2DModel/AnimatedWord2.visible = true
			$SubViewport/WordsGood2DModel/AnimatedWord1.visible = false
		elif Global.words_in_storage == 2:
			$SubViewport/WordsGood2DModel/AnimatedWord3.play("DD3")
			$SubViewport/WordsGood2DModel/AnimatedWord3.visible = true
			$SubViewport/WordsGood2DModel/AnimatedWord2.visible = false

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
