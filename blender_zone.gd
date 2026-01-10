extends TextureRect

# Current recipe (ingredient name -> required count)
var recipe: Dictionary = {}
# Track collected ingredients
var collected: Dictionary = {}

# Signal emitted when recipe is complete
signal recipe_complete

# --- Public API ---
func set_recipe(new_recipe: Dictionary) -> void:
	recipe = new_recipe
	collected.clear()
	print("Blender set with recipe: %s" % recipe)

func accept_ingredient(name: String) -> bool:
	if recipe.has(name):
		collected[name] = (collected.get(name, 0) + 1)
		print("Ingredient correct: %s" % name)
		_check_recipe()
		return true
	else:
		print("Ingredient wrong: %s" % name)
		return false

# --- Internal Helpers ---
func _check_recipe() -> void:
	for k in recipe.keys():
		if collected.get(k, 0) < recipe[k]:
			return  # Still missing something
	print("All ingredients collected! Recipe complete.")
	collected.clear()
	emit_signal("recipe_complete")
