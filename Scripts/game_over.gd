extends CanvasLayer


func _ready() -> void:
	self.hide()

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()
