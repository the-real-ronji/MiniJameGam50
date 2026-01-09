extends Control

@onready var feedback: Label = $Feedback
var active := false
var timer := 0.0

func start_qte() -> void:
	show()
	feedback.text = "Press SPACE!"
	active = true
	timer = 0.0
	set_process(true)

func _process(delta: float) -> void:
	if active:
		timer += delta

func _unhandled_input(event: InputEvent) -> void:
	if active and event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		if timer >= 0.5 and timer <= 1.0:
			feedback.text = "Success!"
		else:
			feedback.text = "Failed!"
		active = false
		set_process(false)
		await get_tree().create_timer(1.0).timeout
		hide()
 
