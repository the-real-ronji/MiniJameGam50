extends Node

@onready var blender: TextureRect = $Control/BlenderZone
@onready var qte_panel: Control = $QTEPanel

func _ready() -> void:
	if blender:
		blender.connect("recipe_complete", Callable(self, "_on_recipe_complete"))
		# ✅ Set the recipe from GameManager
		var recipe = GameManager.get_childhood_recipe()
		blender.set_recipe(recipe)
	else:
		push_error("BlenderZone not found in scene tree")

	if qte_panel:
		qte_panel.hide()

func _on_recipe_complete() -> void:
	print("Recipe complete! Starting QTE...")
	if qte_panel and qte_panel.has_method("start_qte"):
		qte_panel.start_qte()
	else:
		push_error("QTEPanel missing or has no start_qte()")
