extends TextureRect

var recipe := {"honey": 1, "milk": 1, "banana": 1}
var collected := {}
signal recipe_complete

func accept_ingredient(name: String) -> bool:
	if name in recipe.keys():
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
