extends AnimatedSprite2D

@export var accepted_ingredients: Array[String] = ["apple", "milk"]
@onready var prep_phase: Control = $"../../QTEPanel/Phases/PrepPhase"

func accept_ingredient(name: String) -> bool:
	return name in accepted_ingredients

func get_global_rect() -> Rect2:
	var tex := sprite_frames.get_frame_texture(animation, frame)
	if tex == null:
		return Rect2(global_position, Vector2.ZERO)
	var size := tex.get_size()
	return Rect2(global_position - size / 2, size)

func blend_with(name: String):
	if accept_ingredient(name):
		if not prep_phase.finished.is_connected(_on_prep_finished):
			prep_phase.finished.connect(_on_prep_finished)
		prep_phase.start({"lifeStage": QTEPanel.Stage.YoungAdult})
	else:
		print("Invalid ingredient:", name)

func _on_prep_finished(success: bool, data: Dictionary) -> void:
	if success:
		print("Blending succeeded with prep quality:", data.get("prep_quality"))
	else:
		print("Blending failed, reason:", data.get("reason"))
