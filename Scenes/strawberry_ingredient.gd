extends TextureRect

var dragging := false
var ingredient_name := "strawberry"
var original_position : Vector2

func _ready():
	original_position = position  # remember starting spot

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			dragging = true
			grab_focus()
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			dragging = false
			_check_drop_zone()

	if event is InputEventMouseMotion and dragging:
		position += event.relative

func _check_drop_zone():
	var blender = get_parent().get_node("BlenderZone")
	var ingredient_rect = get_global_rect()
	var blender_rect = blender.get_global_rect()

	if ingredient_rect.intersects(blender_rect):
		var accepted = blender.accept_ingredient(ingredient_name)
		if accepted:
			# ✅ Correct ingredient stays inside blender
			position = blender.position + Vector2(20, 20)  # offset so it sits inside
		else:
			# ❌ Wrong ingredient goes back to shelf
			position = original_position
	else:
		# ↩️ Not dropped in blender → return to shelf
		position = original_position
