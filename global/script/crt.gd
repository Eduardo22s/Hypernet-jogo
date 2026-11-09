extends ColorRect

func _process(_delta: float) -> void:
	if Global.crt:
		$".".visible = true
	else:
		$".".visible = false
