extends Sprite2D

var original_position: Vector2
var dragging: bool = false

func _ready() -> void:
	original_position = position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and get_rect().has_point(to_local(event.position)):
			dragging = true

	if event is InputEventMouseButton and not event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and dragging:
			dragging = false
			return_to_original()

	if event is InputEventMouseMotion and dragging:
		position = event.position

func return_to_original() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", original_position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
