extends TextureRect

# Current recipe (ingredient name -> required count)
var recipe: Dictionary = {}
# Track collected ingredients
var collected: Dictionary = {}

# Signal emitted when recipe is complete
signal recipe_complete

# --- Public API ---

# Assign a new recipe dictionary at runtime
func set_recipe(new_recipe: Dictionary) -> void:
	recipe = new_recipe
	collected.clear()
	print("Blender set with recipe: %s" % recipe)

# Called when an ingredient is dropped into the blender
func accept_ingredient(name: String) -> bool:
	# Check if ingredient is part of the recipe
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
	# Verify all required ingredients are collected
	for k in recipe.keys():
		if collected.get(k, 0) < recipe[k]:
			return  # Still missing something
	print("All ingredients collected! Recipe complete.")
	collected.clear()
	emit_signal("recipe_complete")
