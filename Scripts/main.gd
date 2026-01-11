extends Node

@onready var blender = $Control/BlenderZone
@onready var qte_panel: QTEPanel = $QTEPanel
@onready var successOverlay: CanvasLayer = $Success

var phases : Array[PackedScene]= [
	preload("res://scenes/prep_phase.tscn"),
	preload("res://scenes/blend_phase.tscn"),
	preload("res://scenes/pour_phase.tscn")
]


func _ready() -> void:
	if blender:
		blender.connect("recipe_complete", Callable(self, "_on_recipe_complete"))
		var recipe = GameManager.get_childhood_recipe()
		blender.set_recipe(recipe)
	else:
		push_error("BlenderZone not found in scene tree")

	if qte_panel:
		qte_panel.hide()
		qte_panel.finished.connect(_on_qte_finished)
	else:
		push_error("QTE not found in scene tree")

func _on_recipe_complete() -> void:
	print("Recipe complete! Starting QTE...")
	
	var qte_context := {
		"stage": "childhood",
		"difficulty": 1,
		"base_score": 100
	}

	qte_panel.show()
	qte_panel.start_qte(phases, qte_context)

func _on_qte_finished(success: bool, data: Dictionary) -> void:
	qte_panel.hide()
	
	if success:
		print("Drink prepared successfully!")
		print("Run data: ", data)
		successOverlay.show()
	else:
		if GameManager.attempt >= 5:
			print("Drink failed!")
			print("Failure data: ", data)
		else:
			GameManager.attempt += 1
			get_tree().reload_current_scene()
