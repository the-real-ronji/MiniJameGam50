extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()

func _on_button_pressed() -> void:
	var scene = get_tree().current_scene
	
	match scene.scene_file_path:
		"res://scenes/Main.tscn":
			get_tree().change_scene_to_file("res://scenes/stages/AdolescenceStage.tscn")
		"res://scenes/stages/AdolescenceStage.tscn":
			get_tree().change_scene_to_file("res://scenes/stages/YoungAdultStage.tscn")
		"res://scenes/stages/YoungAdultStage.tscn":
			get_tree().change_scene_to_file("res://scenes/stages/MiddleAgeStage.tscn")
		"res://scenes/stages/MiddleAgeStage.tscn":
			get_tree().change_scene_to_file("res://scenes/stages/SeniorStage.tscn")
