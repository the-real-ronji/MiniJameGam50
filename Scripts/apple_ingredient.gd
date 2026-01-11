extends TextureRect

var dragging := false
var ingredient_name := "honey"
var original_position : Vector2
var locked := false

var original_texture : Texture2D
var drag_texture : Texture2D = preload("res://Sprites/APPLEWhite.png")

func _ready():
	original_position = position
	original_texture = texture

func _gui_input(event):
	if locked:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			dragging = true
			texture = drag_texture
			grab_focus()
		elif event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			dragging = false
			texture = original_texture
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
			position = blender.position + Vector2(20, 20)
			locked = true
		else:
			return_to_original()
	else:
		return_to_original()

func return_to_original() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", original_position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
