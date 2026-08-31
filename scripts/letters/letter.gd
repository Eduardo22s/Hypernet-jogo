extends Node3D

@onready var letters = [$SubViewport/Letters2DModels/letter_A, $SubViewport/Letters2DModels/letter_B, $SubViewport/Letters2DModels/letter_C, $SubViewport/Letters2DModels/letter_D, $SubViewport/Letters2DModels/letter_E, $SubViewport/Letters2DModels/letter_F, $SubViewport/Letters2DModels/letter_G, $SubViewport/Letters2DModels/letter_H, $SubViewport/Letters2DModels/letter_I, $SubViewport/Letters2DModels/letter_J, $SubViewport/Letters2DModels/letter_K, $SubViewport/Letters2DModels/letter_L, $SubViewport/Letters2DModels/letter_M, $SubViewport/Letters2DModels/letter_N, $SubViewport/Letters2DModels/letter_O, $SubViewport/Letters2DModels/letter_P, $SubViewport/Letters2DModels/letter_Q, $SubViewport/Letters2DModels/letter_R, $SubViewport/Letters2DModels/letter_S, $SubViewport/Letters2DModels/letter_T, $SubViewport/Letters2DModels/letter_U, $SubViewport/Letters2DModels/letter_V, $SubViewport/Letters2DModels/letter_W, $SubViewport/Letters2DModels/letter_X, $SubViewport/Letters2DModels/letter_Y, $SubViewport/Letters2DModels/letter_Z]

var current_letter = ""

func _on_hitzone_area_entered(area: Area3D) -> void:
	if area is Attack:
		Global.guessed_letter = current_letter
