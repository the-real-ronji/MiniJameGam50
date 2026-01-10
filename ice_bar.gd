extends TextureProgressBar

func _process(delta: float) -> void:
	ice_bar.value = clamp(elapsed/ 1.0, 0.0, 1.0)
	print("Bar value:", ice_bar.value)
