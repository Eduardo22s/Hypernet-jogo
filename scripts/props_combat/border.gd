extends Area3D
class_name Border

@export var radius: float = 10.0

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D

func _ready():
	add_to_group("player_bumpers")
	sprite.play("Idle")
