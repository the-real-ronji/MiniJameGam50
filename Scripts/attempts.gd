extends Label


func _process(_delta: float) -> void:
	self.text = "Attempt: " + str(GameManager.attempt)

	if GameManager.attempt ==10:
		$"../Control/UIs/GameOver".show()
		GameManager.attempt = 0
		print(8)
