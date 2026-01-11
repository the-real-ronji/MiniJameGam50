extends TextureRect

@export var drop_position: Vector2 = Vector2(476, 257)
@export var drop_scale: Vector2 = Vector2(0.5, 0.5)

var dragging := false
var ingredient_name := "cucumber"
var original_position : Vector2
var locked := false

var original_texture : Texture2D
var drag_texture : Texture2D = preload("res://Sprites/final sprites/CUMCUMCUMBERWhite.png")

func _ready():
	original_position = position
	original_texture = texture
	original_position = position
	original_texture = texture
	var blender = get_parent().get_node_or_null("BlenderZone")
	print("Found blender:", blender)

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
	var blender = get_parent().get_node_or_null("BlenderZone")
	if blender == null:
		print("BlenderZone not found!")
		return

	var ingredient_rect = Rect2(global_position, size)
	var blender_rect = blender.get_global_rect()

	if ingredient_rect.intersects(blender_rect):
		if blender.accept_ingredient(ingredient_name):
			position = drop_position - size / 4
			scale = drop_scale
			locked = true
		else:
			return_to_original()
	else:
		return_to_original()

func return_to_original() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position", original_position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
