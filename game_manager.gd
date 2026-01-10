extends Node

# --- Ingredient pools (lowercase) ---
var childhood_correct = ["fruit", "milk"]
var childhood_decoys = ["sugar cubes", "ice"]

var adolescence_correct = ["chocolate", "protein_bar", "energy_drink", "peanut_butter", "soda"]
var adolescence_decoys = ["herbal_tea", "warm_milk", "yogurt", "turmeric", "kale", "wine", "candy_sprinkles", "ginger"]

# --- Random pool generator (for spawning items) ---
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

# --- Fixed recipe dictionaries (for Blender validation) ---
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
