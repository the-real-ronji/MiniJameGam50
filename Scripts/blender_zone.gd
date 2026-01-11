extends Node2D
class_name BlenderZone

signal recipe_complete

@export var blend_animation := "blend"

var recipe: Dictionary = {}
var collected: Dictionary = {}

@onready var feedback_label: Label = $VisualFeedback
@onready var blender_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	feedback_label.visible = false
	blender_sprite.stop()


func show_feedback(text: String) -> void:
	feedback_label.text = text
	feedback_label.visible = true
	await get_tree().create_timer(2.0).timeout
	feedback_label.visible = false


func set_recipe(new_recipe: Dictionary) -> void:
	recipe = new_recipe
	collected.clear()
	print("Blender set with recipe:", recipe)


func accept_ingredient(name: String) -> bool:
	# Only allow correct ingredients during childhood
	if recipe.has(name) and GameManager.stage == "childhood":
		collected[name] = collected.get(name, 0) + 1
		print("Ingredient correct:", name)
		_check_recipe()
		return true
	else:
		_handle_wrong_ingredient(name)
		return false


func _handle_wrong_ingredient(name: String) -> void:
	GameManager.attempt += 1

	if GameManager.attempt >= 5:
		GameManager.attempt = 0
		$"../UIs/GameOver".show()
		get_tree().paused = true
		return

	match name:
		"sugarcubes":
			show_feedback("Too bitter for a kid’s drink!")
		"ice":
			show_feedback("Too cold, childhood should feel warm!")
		_:
			show_feedback("That doesn’t taste right...")

func get_global_rect() -> Rect2:
	if blender_sprite == null:
		return Rect2()

	var texture := blender_sprite.sprite_frames.get_frame_texture(
		blender_sprite.animation,
		blender_sprite.frame
	)

	if texture == null:
		return Rect2()

	var size: Vector2 = texture.get_size() * blender_sprite.global_scale

	# AnimatedSprite2D is centered
	var top_left: Vector2 = blender_sprite.global_position - size / 2.0

	return Rect2(top_left, size)


func _check_recipe() -> void:
	for ingredient in recipe.keys():
		if collected.get(ingredient, 0) < recipe[ingredient]:
			return

	# Recipe complete
	print("All ingredients collected! Recipe complete.")
	collected.clear()

	_play_blend_animation()
	emit_signal("recipe_complete")


func _play_blend_animation() -> void:
	if blender_sprite.sprite_frames.has_animation(blend_animation):
		blender_sprite.play(blend_animation)
	else:
		push_warning("Blend animation not found on AnimatedSprite2D")
