extends Control

signal finished(success: bool, data: Dictionary)

@export var sequence: Array[String] = ["W", "D", "S", "A", "W", "D", "S", "A"]  # Default: childhood
@export var input_map: Dictionary[String, String] = {"W": "w", "A": "a", "D": "d", "S": "s"}  # Key mapping
@export var input_time_window: float = 3.0  # seconds allowed per input
@onready var texture_rect: TextureRect = $TextureRect

var current_index: int = 0
var timer: float = 0.0
var success: bool = true

func start(sharedData: Dictionary = {}) -> void:
	current_index = 0
	timer = 0.0
	success = true
	set_process(true)
	set_process_unhandled_input(true)
	print("Blend phase started! Sequence: ", sequence)

func _process(delta: float) -> void:
	if not success or current_index >= sequence.size():
		return
	
	timer += delta
	if timer > input_time_window:
		_fail("Too slow!")

func _unhandled_input(event: InputEvent) -> void:
	if not success or current_index >= sequence.size():
		return
	
	var expected_key: String = input_map.get(sequence[current_index], "")
	if expected_key == "":
		push_error("No mapping for input: %s" % sequence[current_index])
		return

	if event.is_action_pressed(expected_key):
		if timer <= input_time_window:
			print("Input %s correct!" % sequence[current_index])
			current_index += 1
			timer = 0.0
			if current_index >= sequence.size():
				_success()
		else:
			_fail("Too slow!")

func _success() -> void:
	success = true
	print("✅ Blend phase completed perfectly!")
	_end_phase(true, {"blend_success": true, "inputs_hit": current_index})

func _fail(reason: String) -> void:
	if not success:
		return
	success = false
	print("❌ Blend phase failed: ", reason)
	_end_phase(false, {"blend_success": false, "failed_at": current_index, "reason": reason})

func _end_phase(successful: bool, data: Dictionary) -> void:
	set_process(false)
	set_process_unhandled_input(false)
	finished.emit(successful, data)
