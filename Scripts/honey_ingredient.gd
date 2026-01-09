extends TextureRect

var dragging: bool = false
@export var ingredient_name: String = "honey"
var original_position: Vector2

func _ready() -> void:
	original_position = position  # remember starting spot
	mouse_filter = Control.MOUSE_FILTER_PASS  # ensure _gui_input receives events

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			dragging = true
			grab_focus()
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			dragging = false
			_check_drop_zone()

	elif event is InputEventMouseMotion and dragging:
		position += event.relative

func _check_drop_zone() -> void:
	var blender: Node = get_parent().get_node("BlenderZone")
	var ingredient_rect: Rect2 = Rect2(global_position, size)
	var blender_rect: Rect2 = Rect2(blender.global_position, blender.size)

	if ingredient_rect.intersects(blender_rect):
		if blender.has_method("accept_ingredient"):
			var accepted: bool = blender.accept_ingredient(ingredient_name)
			if accepted:
				# Snap into blender zone
				position = blender.position + Vector2(20, 20)
			else:
				# Wrong ingredient → return to shelf
				position = original_position
		else:
			# Fallback if blender has no accept_ingredient
			position = original_position
	else:
		# Dropped outside blender → return to shelf
		position = original_position
