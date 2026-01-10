extends Control

signal finished(success: bool, data: Dictionary)

@export var sequence: Array[String] = []  # will be set at start
@export var input_time_window: float = 3.0
@export var sequenceSize := 4

# Preload your number sprites here
@export var numberTextures: Dictionary[String, Texture] = {
	"1": preload("res://Sprites/temp sprites prototype/numbers/1.jpg"),
	"2": preload("res://Sprites/temp sprites prototype/numbers/2.jpg"),
	"3": preload("res://Sprites/temp sprites prototype/numbers/3.jpg"),
	"4": preload("res://Sprites/temp sprites prototype/numbers/4.jpg"),
	"5": preload("res://Sprites/temp sprites prototype/numbers/5.jpg"),
	"6": preload("res://Sprites/temp sprites prototype/numbers/6.jpg"),
	"7": preload("res://Sprites/temp sprites prototype/numbers/7.jpg"),
	"8": preload("res://Sprites/temp sprites prototype/numbers/8.jpg"),
	"9": preload("res://Sprites/temp sprites prototype/numbers/9.jpg"),
	"0": preload("res://Sprites/temp sprites prototype/numbers/0.jpg")
}

@onready var image: TextureRect = $image

var current_index: int = 0
var timer: float = 0.0
var success: bool = true
var waiting_for_enter: bool = false
var fail_reason: String = ""

# Map sequence entries to actual keycodes (top row numbers)
var keycodes = {
	"1": KEY_1, "2": KEY_2, "3": KEY_3, "4": KEY_4, "5": KEY_5,
	"6": KEY_6, "7": KEY_7, "8": KEY_8, "9": KEY_9, "0": KEY_0
}

# Allow numpad keys too
var numpad_keycodes = {
	"1": KEY_KP_1, "2": KEY_KP_2, "3": KEY_KP_3, "4": KEY_KP_4, "5": KEY_KP_5,
	"6": KEY_KP_6, "7": KEY_KP_7, "8": KEY_KP_8, "9": KEY_KP_9, "0": KEY_KP_0
}

func _ready() -> void:
	randomize()
	$"blendphase tutorial".show()

func start(_sharedData: Dictionary = {}) -> void:
	var pool: Array[String] = ["1","2","3","4","5","6","7","8","9","0"]
	sequence = []
	while sequence.size() < sequenceSize:
		var choice = pool[randi() % pool.size()]
		if not sequence.has(choice):
			sequence.append(choice)

	current_index = 0
	timer = 0.0
	success = true
	waiting_for_enter = false
	fail_reason = ""
	set_process(true)
	set_process_unhandled_input(true)
	_update_image()
	print("Blend phase started! Sequence: ", sequence)

func _process(delta: float) -> void:
	if $"blendphase tutorial".visible:
		return
	if not success or current_index >= sequence.size():
		return
	_update_image()
	timer += delta
	if timer > input_time_window:
		_fail("Too slow!")

func _unhandled_input(event: InputEvent) -> void:
	if $"blendphase tutorial".visible:
		return
	if not success or current_index >= sequence.size():
		return

	if event is InputEventKey and event.pressed:
		var expected = sequence[current_index]
		var top_row = keycodes.get(expected, -1)
		var numpad = numpad_keycodes.get(expected, -1)

		if event.keycode == top_row or event.keycode == numpad:
			if timer <= input_time_window:
				print("Input %s correct!" % expected)
				current_index += 1
				timer = 0.0
				if current_index >= sequence.size():
					_success()
			else:
				_fail("Too slow!")

func _update_image() -> void:
	if current_index < sequence.size():
		var key = sequence[current_index]
		if numberTextures.has(key):
			image.texture = numberTextures[key]
		else:
			image.texture = null
	else:
		image.texture = null

func _success() -> void:
	success = true
	print("\nBlend phase completed perfectly!")
	_end_phase(true, {"blend_success": true, "inputs_hit": current_index})

func _fail(reason: String) -> void:
	if not success:
		return
	success = false
	waiting_for_enter = true
	fail_reason = reason
	set_process(false)
	print("Blend phase failed: ", reason)
	image.texture = null
	_end_phase(false, {"blend_success": false, "inputs_hit": current_index})

func _end_phase(successful: bool, data: Dictionary) -> void:
	set_process(false)
	set_process_unhandled_input(false)
	finished.emit(successful, data)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			if waiting_for_enter:
				waiting_for_enter = false
				$"blendphase tutorial".hide()
				_end_phase(false, {
					"blend_success": false,
					"failed_at": current_index,
					"reason": fail_reason
				})
			else:
				$"blendphase tutorial".hide()
				timer = 0.0
 
