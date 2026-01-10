extends Node

var attempt: int = 0
var stage: String = "childhood"
var childhood_correct = ["fruit", "milk"]
var childhood_decoys = ["sugar cubes", "ice"]

func get_childhood_recipes() -> Array:
	var num_correct = randi_range(3, 6)
	var selected_correct = childhood_correct.duplicate()
	selected_correct.shuffle()
	selected_correct = selected_correct.slice(0, num_correct)

	var total_size = randi_range(12, 15)
	var selected_decoys = childhood_decoys.duplicate()
	selected_decoys.shuffle()
	var recipe_pool = selected_correct + selected_decoys.slice(0, total_size - selected_correct.size())

	recipe_pool.shuffle()
	return recipe_pool

func get_childhood_recipe() -> Dictionary:
	return {
		"apple": 1,
		"milk": 1,
	}

func get_adolescence_recipe() -> Dictionary:
	return {
		"chocolate": 1,
		"protein_bar": 1,
		"energy_drink": 1,
		"peanut_butter": 1,
		"soda": 1
	}
