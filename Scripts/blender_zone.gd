extends TextureRect

var recipe: Dictionary = {}
var collected: Dictionary = {}

signal recipe_complete

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

func _check_recipe() -> void:
	for k in recipe.keys():
		if collected.get(k, 0) < recipe[k]:
			return
	print("All ingredients collected! Recipe complete.")
	collected.clear()
	emit_signal("recipe_complete")
