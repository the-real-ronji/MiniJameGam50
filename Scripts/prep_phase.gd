extends Control

var pressed := false
var elapsed := 0.0
var min_time := 0.5   # earliest valid press
var max_time := 1.0   # latest valid press

func _ready():
	pressed = false
	elapsed = 0.0
	print("Prep phase started! Press SPACE between 0.5s and 1.0s.")

func _process(delta):
	if not pressed:
		elapsed += delta
		if elapsed > max_time:
			_fail("Too late!")

func _input(event):
	if event.is_action_pressed("ui_accept") and not pressed:
		pressed = true
		if elapsed >= min_time and elapsed <= max_time:
			_success()
		elif elapsed < min_time:
			_fail("Too early!")
		else:
			_fail("Too late!")

func _success():
	print("✅ Perfect ice prep! Timing was ", elapsed, " seconds.")
	# TODO: signal QTEManager to move to BlendPhase

func _fail(reason: String):
	print("❌ Prep failed: ", reason, " (pressed at ", elapsed, " seconds)")
	# TODO: allow retry or lower score
