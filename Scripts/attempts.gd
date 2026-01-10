extends Label


func _process(delta: float) -> void:
	if GameManager.attempt >0:
		self.text = "Attempt: " + str(GameManager.attempt)
		$"../Control/UIs/GameOver".hide()
	if GameManager.attempt ==5:
		$"../Control/UIs/GameOver".show()
		GameManager.attempt = 0
