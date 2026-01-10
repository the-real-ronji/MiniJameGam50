extends TextureRect

var recipe: Dictionary = {}
var collected: Dictionary = {}

signal recipe_complete

func set_recipe(new_recipe: Dictionary) -> void:
	recipe = new_recipe
	collected.clear()
	print("Blender set with recipe: %s" % recipe)

func accept_ingredient(name: String) -> bool:
	if recipe.has(name) and GameManager.stage == "childhood":
		collected[name] = (collected.get(name, 0) + 1)
		print("Ingredient correct: %s" % name)
		_check_recipe()
		return true
	else:
		match name:
			"sugarcubes":
				$VisualFeedback.text = "Too bitter for a kid’s drink!"
			"ice":
				$VisualFeedback.text = "Too cold, childhood should feel warm!"
			_:
				$VisualFeedback.text = "That doesn’t taste right..."
		return false

func _check_recipe() -> void:
	for k in recipe.keys():
		if collected.get(k, 0) < recipe[k]:
			return
	$VisualFeedback.text = "All ingredients collected! Recipe complete."
	collected.clear()
	emit_signal("recipe_complete")
