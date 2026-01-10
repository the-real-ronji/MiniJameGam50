extends CanvasLayer


func _ready() -> void:
	self.hide()

func _on_retry_pressed() -> void:
	GameManager.attempt = 0
	get_tree().reload_current_scene()
