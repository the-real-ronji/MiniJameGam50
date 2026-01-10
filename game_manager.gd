extends Node

# --- Ingredient pools ---
# childhood stage
var childhood_correct = ["banana", "honey", "milk"]
var childhood_decoys = ["soda", "coffee", "spicy chips", "raw meat", "energy drink", "garlic", "vinegar", "alcohol"]

# adolescence stage
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

func get_adolescence_recipes() -> Array:
	var num_correct = randi_range(3, 6)
	var selected_correct = adolescence_correct.duplicate()
	selected_correct.shuffle()
	selected_correct = selected_correct.slice(0, num_correct)

	var total_size = randi_range(12, 15)
	var selected_decoys = adolescence_decoys.duplicate()
	selected_decoys.shuffle()
	var recipe_pool = selected_correct + selected_decoys.slice(0, total_size - selected_correct.size())

	recipe_pool.shuffle()
	return recipe_pool

# --- Fixed recipe dictionaries (for Blender validation) ---
func get_childhood_recipe() -> Dictionary:
	return {
		"honey": 1,
		"milk": 1,
		"banana": 1,
		"apple": 1,
		"strawberry": 1,
		"cookies": 1
	}

func get_adolescence_recipe() -> Dictionary:
	return {
		"chocolate": 1,
		"protein_bar": 1,
		"energy_drink": 1,
		"peanut_butter": 1,
		"soda": 1
	}
