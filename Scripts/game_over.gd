extends CanvasLayer


func _ready() -> void:
	self.hide()

func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Main.tscn")
