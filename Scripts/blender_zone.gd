extends TextureRect

var recipe: Dictionary = {}
var collected: Dictionary = {}

signal recipe_complete

func showfeedback() -> void:
	$VisualFeedback.visible = true
	await get_tree().create_timer(2.0).timeout
	$VisualFeedback.visible = false

func set_recipe(new_recipe: Dictionary) -> void:
	recipe = new_recipe
	collected.clear()
	print("Blender set with recipe: %s" % recipe)

func accept_ingredient(ingredientName: String) -> bool:
	if recipe.has(ingredientName) and GameManager.stage == "childhood":
		collected[ingredientName] = (collected.get(ingredientName, 0) + 1)
		print("Ingredient correct: %s" % ingredientName)
		_check_recipe()
		return true
	else:
		showfeedback()
		GameManager.attempt += 1
		if GameManager.attempt == 5:
			GameManager.attempt = 0
			$"../UIs/GameOver".show()
			get_tree().paused = true
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
	print("All ingredients collected! Recipe complete.")
	collected.clear()
	emit_signal("recipe_complete")
